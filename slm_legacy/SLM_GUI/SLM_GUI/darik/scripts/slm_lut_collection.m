%% Script for getting data for calibration lut
% can either use TDLC and grab frames or wait for trigger with some other method
% start by running the global calibration
% if need regional, use previos global for blaze deflect blank
% for better calibration, especially regional better to use photodiode and
% first order, not zero

% lut pipeline step 1/3

%% SANITIZE EBVIRONMENT

if exist('ops', 'var')
    if isfield(ops, 'sdkObj')
        ops.sdkObj.close();
    end
    if isfield(ops, 'igObj')
        ops.igObj.close();
    end
end

if exist('cam_out', 'var')
    if isfield(cam_out, 'hdl_cam')
        TLDC_set_Cam_Close(cam_out.hdl_cam);   
    end
end

clear;

%% PARAMETERS

save_pref = '920nm_coherent_darik_126pv_1kOhm_det10a_2r';
save_path = 'C:\Users\rylab\901c_slm\PycharmProjects
gui_dir = 'C:\Users\rylab_901c_slm\PycharmProjects\split_slm\mlb\SLM_GUI\SLM_GUI';
addpath(gui_dir);
addpath(genpath(gui_dir));
ops = f_SLM_default_ops(gui_dir);

%ops.lut_correction_fname = 'photodiode_lut_940_slm5221_4_7_22_right_half_corr2_sub_region_interp_corr.mat';
ops.lut_correction_fname = [];
ops.lut_fname = 'linear_cut_940_1064.lut';
ops.SLM_type = 'BNS1920';
SLM_params = ops.SLM_params(strcmpi({ops.SLM_params.SLM_name}, ops.SLM_type));
ops.SLM_params_use = SLM_params;

%% Parameters
ops.use_TLDC = 0;           % otherwise wait for trigger
ops.use_photodiode = 1;
ops.plot_phase = 1;
ops.NumGray = 256;          % bit depth
% to use meadolwark analysis need 8x8, to use their mask need equal m and n
ops.num_regions_m = 1;% 4 8;
ops.num_regions_n = 2;% 8 16;
ops.PixelsPerStripe = 8;	
ops.horizontalStripe = 0;
ops.DAQ_num_sessions = 200;
slm_roi = 'right_half';
ops.NumRegions = ops.num_regions_m  * ops.num_regions_n;
ops.time_stamp = sprintf('%s_%sh_%sm',datestr(now,'mm_dd_yy'),datestr(now,'HH'),datestr(now,'MM'));
ops.save_file_name = sprintf('lut_%s_%dr_%s.mat', save_pref,ops.NumRegions, ops.time_stamp);
if ~exist(ops.save_lut_dir, 'dir')
    mkdir(ops.save_lut_dir);
end
regions_run = f_lut_get_regions_run2(slm_roi, ops.num_regions_m, ops.num_regions_n);
regions_run = sort(regions_run(:));

%% Initialize SLM
ops = f_SLM_initialize(ops);
ops = f_imageGen_load(ops);
ops.igObj.init(ops.sdkObj.height, ops.sdkObj.width);
ops.guiObj = GUIobj(ops.sdkObj);

%% load lut correction data
lut_data = [];

if ~isempty(ops.lut_correction_fname)
    lut_corr_path = [ops.lut_dir '\' ops.lut_fname(1:end-4) '_correction\' ops.lut_correction_fname];
    lut_load = load(lut_corr_path);    
    lut_data2(1).lut_corr = lut_load.lut_corr.lut_corr;
    
    region_idx = f_gen_region_index_mask(ops.height, ops.width, ops.num_regions_m, ops.num_regions_n);
    
    n_idx = ones(ops.width, 1);
    n_px = ceil((1:ops.width)'/ops.width*ops.num_regions_n);
    if strcmpi(slm_roi, 'right_half')
        n_idx(n_px <= floor(ops.num_regions_n/2)) = 0;
    elseif strcmpi(slm_roi, 'left_half')
        n_idx(n_px > floor(ops.num_regions_n/2)) = 0;
    end
    
    lut_data2(1).m_idx = ones(ops.height, 1);
    lut_data2(1).n_idx = n_idx;
    lut_data = [lut_data; lut_data2];
end

ops.lut_data = lut_data;
ops.slm_roi = slm_roi;
ops.regions_run = regions_run;

%%
cont1 = input('Turn laser on and reply [y] to continue:', 's');

%%
if ops.use_TLDC
    if exist('cam_out', 'var')
        if isfield(cam_out, 'hdl_cam')
            TLDC_set_Cam_Close(cam_out.hdl_cam);   
        end
    end
    [cam_out, ops.cam_params] = f_TLDC_initialize(ops);
end

if ops.use_photodiode
    session = daq('ni');
    session.addinput('dev2','ai1','Voltage');
    % make the data acquisition 'SingleEnded, to separate the '
    for nchan = 1:length(session.Channels)
        if strcmpi(session.Channels(nchan).ID(1:2), 'ai')
           session.Channels(nchan).TerminalConfig = 'SingleEnded';
           session.Channels(nchan).Range = [-1 1];
       end
    end
    ops.DAQ_rate = 1000;
    session.Rate = ops.DAQ_rate;
end


%% create gratings and upload
if ops.sdkObj.SDK_created == 1 && strcmpi(cont1, 'y')
    region_gray = zeros(ops.NumGray*numel(regions_run),2);
    
    SLM_blank = ops.guiObj.generateBlank();
    f_SLM_update(ops, SLM_blank);
    
    SLM_mask = ops.guiObj.init_pointer();
    
    %% generate SLM image
    stripes = ops.guiObj.generateStripes(0,1,ops.PixelsPerStripe, ops.horizontalStripe);
    region_idx = ops.guiObj.generateRegionIndexMask(ops.num_regions_m, ops.num_regions_n);
    %%
    if ops.plot_phase
        SLM_fig = figure;
        SLM_im = imagesc(reshape(SLM_mask.Value, ops.sdkObj.width, ops.sdkObj.height)'); axis equal tight;
        caxis([0 255]);
        SLM_fig.Children.Title.String = 'SLM phase';
    end
    
    if ops.use_TLDC
        calib_im_series = zeros(size(cam_out.cam_frame,1), size(cam_out.cam_frame,2), ops.NumGray*numel(regions_run), 'uint8');
        cam_fig = figure;
        cam_im = imagesc(cam_out.cam_frame'); axis equal tight;
        %caxis([1 256]);
        cam_fig.Children.Title.String = 'Camera';
    end
    
    if ops.use_photodiode
        AI_intensity = zeros(ops.NumGray*numel(regions_run), 1);
        phd_fig = figure;
        x1 = ones(ops.NumGray, numel(regions_run))*255;
        y1 = zeros(ops.NumGray, numel(regions_run));
        phd_plot = plot(x1,y1); axis tight;
        %caxis([1 256]);
        phd_fig.Children.Title.String = 'Photodiode';
    end
    
    %loop through each region
    for n_reg = 1:numel(regions_run)
        for Gray = 0:(ops.NumGray-1)
            Region = regions_run(n_reg);
            idx1 = (n_reg-1)*ops.NumGray+Gray + 1;
            region_gray(idx1,:) = [Region, Gray];
            region_mask = ops.guiObj.generateBlank();
            region_mask(region_idx == Region) = 1;
            region_mask = flipud(region_mask);
            holo_image = stripes.*region_mask*Gray;
            holo_image_corr = f_apply_lut_corr(holo_image, lut_data, 0);
            SLM_mask.Value = reshape(rot90(uint8(holo_image_corr), 3),[],1);
            if ops.use_photodiode
                f_SLM_update(ops, SLM_mask);
                pause(0.01); %let the SLM settle for 10 ms
                % scan intensity
                data = read(session,ops.DAQ_num_sessions,"OutputFormat","Matrix");
                AI_intensity(idx1) = mean(data);
                phd_plot(n_reg).XData(Gray+1) = region_gray(idx1,2); 
                phd_plot(n_reg).YData(Gray+1) = AI_intensity(idx1);
                phd_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
            end
            
            if ops.use_TLDC   % Thorlabs camera
                f_SLM_update(ops, SLM_mask);
                pause(0.01); %let the SLM settle for 10 ms
                TLDC_get_Cam_Im(cam_out.hdl_cam);
                cam_im.CData = cam_out.cam_frame';
                calib_im_series(:,:,idx1) = (cam_out.cam_frame);
                cam_fig.Children.Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
                pause(.02);
            end
            
            if ops.plot_phase
                SLM_im.CData = reshape(SLM_mask.Value, ops.sdkObj.width, ops.sdkObj.height)';
                SLM_fig.Children(end).Title.String = sprintf('Gray %d/%d; Region %d/%d', Gray+1,ops.NumGray,Region+1,ops.NumRegions);
                drawnow;
            end
        end
    end
    f_SLM_update(ops, SLM_blank);
    
    if ops.use_photodiode
        save([ops.save_lut_dir '\photodiode_' ops.save_file_name], 'region_gray', 'AI_intensity', 'ops', '-v7.3');
        new_dir1 = [ops.save_lut_dir '\photodiode_' ops.save_file_name(1:end-4)];
        % dump the AI measurements to a csv file
        mkdir(new_dir1);
        for n_reg = 1:numel(regions_run)
            Region = regions_run(n_reg);
            r_idx = region_gray(:,1) == Region;
            filename = ['Raw' num2str(Region) '.csv'];
            csvwrite([new_dir1 '\' filename], [region_gray(r_idx,2), AI_intensity(r_idx)]);  
        end
    end
    if ops.use_TLDC
        save([ops.save_path '\TDLC_' ops.save_file_name], 'region_gray', 'calib_im_series', 'ops', '-v7.3');
    end
else
    disp('Not running anything...')
end

%% close SLM

cont1 = input('Done, turn off laser and press [y] close SLM:', 's');

f_SLM_close(ops);
ops.igObj.close();
if ops.use_TLDC
    TLDC_set_Cam_Close(cam_out.hdl_cam);            
end

