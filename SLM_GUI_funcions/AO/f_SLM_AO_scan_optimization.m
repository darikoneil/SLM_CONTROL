function f_SLM_AO_scan_optimization(app)
disp('Starting optimization...');

time_stamp = clock;
%%
bead_im_window = 20;

an_params.n_corrections_to_use = 1;
an_params.correction_weight_step = 1;
an_params.plot_stuff = 1;

sigma_pixels = 1;
kernel_half_size = ceil(sqrt(-log(0.1)*2*sigma_pixels^2));
[X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*sigma_pixels^2));
conv_kernel = conv_kernel/sum(conv_kernel(:));

an_params.conv_kernel = conv_kernel;

%%
[m_idx, n_idx, ~,  reg1] = f_SLM_get_reg_deets(app, app.AOregionDropDown.Value);
SLMm = sum(m_idx);
SLMn = sum(n_idx);
beam_width = app.BeamdiameterpixEditField.Value;
xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
[fX, fY] = meshgrid(xln, xlm);
[theta, rho] = cart2pol( fX, fY );

%% initial AO_wfcl
AO_wf = zeros(SLMm, SLMn);
if isempty(reg1.AO_correction)
    AO_correction = [];
elseif strcmpi(reg1.AO_correction, 'none')
    AO_correction = [];
else
    idx_AO = strcmpi(reg1.AO_correction, app.SLM_ops.AO_correction(:,1));
    AO_correction = app.SLM_ops.AO_correction{idx_AO,2}.AO_correction;
end

%%
init_image = app.SLM_Image;
SLM_image = f_SLM_AO_add_correction(app, app.SLM_Image, AO_wf);
app.SLM_Image_pointer.Value = f_SLM_im_to_pointer(SLM_image);
f_SLM_BNS_update(app.SLM_ops, app.SLM_Image_pointer);

%%
% create patterns
zernike_table = app.ZernikeListTable.Data;

% generate all polynomials
num_modes = size(zernike_table,1);
all_modes = zeros(SLMm, SLMn, num_modes);
for n_mode = 1:num_modes
    Z_nm = f_SLM_zernike_pol(rho, theta, zernike_table(n_mode,2), zernike_table(n_mode,3));
    if app.AOzerooutsideunitcircCheckBox.Value
        Z_nm(rho>1) = 0;
    end
    all_modes(:,:,n_mode) = Z_nm;
end

% generate scan sequence
all_patterns = cell(num_modes,1);
for n_mode = 1:num_modes
    if zernike_table(n_mode,7)
        weights1 = zernike_table(n_mode,4):zernike_table(n_mode,5):zernike_table(n_mode,6);
        temp_patterns = [ones(numel(weights1),1)*zernike_table(n_mode,1), weights1']; 
        if app.InsertrefimageinscansCheckBox.Value
            all_patterns{n_mode} = [999,999; temp_patterns];
        else
            all_patterns{n_mode} = temp_patterns;
        end
    end
end

zernike_scan_sequence = cat(1,all_patterns{:});
zernike_scan_sequence = repmat(zernike_scan_sequence,app.ScanspermodeEditField.Value,1);
num_scans = size(zernike_scan_sequence,1);

%%
resetCounters(app.DAQ_session);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

num_frames = 0;

%path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
path1 = app.ScanframesdirpathEditField.Value;
exist(path1, 'dir');

f_SLM_scan_triggered_frame(app.DAQ_session);
num_scans_done = 1;

% wait for frame to convert
while num_frames < num_scans_done
    files1 = dir([path1 '\' '*tif']);
    fnames = {files1.name}';
    num_frames = numel(fnames);
    pause(0.005)
end

frames = f_AO_op_get_all_frames(path1);
num_frames = size(frames,3);

f1 = figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
bead_mn = round(bead_mn);

%%
im_m_idx = (-bead_im_window:bead_im_window) + bead_mn(1);
im_n_idx = (-bead_im_window:bead_im_window) + bead_mn(2);

im_cut = frames(im_m_idx, im_n_idx,num_frames);

deets_pre = f_get_PFS_deets_fast(im_cut, conv_kernel);

an_params.intensity_win = ceil((deets_pre.X_fwhm + deets_pre.Y_fwhm)/4);
%%
if app.PlotprogressCheckBox.Value
    sp1 = subplot(1,2,1); hold on; axis tight equal;
    imagesc(im_cut);
    plot(deets_pre.cent_mn(2),deets_pre.cent_mn(1), 'ro');
    sp2 = subplot(1,2,2); hold on; axis tight;
    plot(0, deets_pre.intensity_raw, '-o');
    pl_idx_line = isprop(sp1.Children, 'LineStyle');
end

%% scan
current_AO_wf = AO_wf;

holo_im_pointer = f_SLM_initialize_pointer(app);
for n_it = 1:app.NumiterationsSpinner.Value
    im_m_idx = (-bead_im_window:bead_im_window) + bead_mn(1);
    im_n_idx = (-bead_im_window:bead_im_window) + bead_mn(2);
    
    % add current wavefront correction
    current_im = init_image;
    current_im(m_idx,n_idx) = angle(exp(1i*(current_im(m_idx,n_idx) + current_AO_wf))) + pi;
    
    if app.ShufflemodesCheckBox.Value
        zernike_scan_sequence2 = zernike_scan_sequence(randsample(num_scans,num_scans),:);
    else
        zernike_scan_sequence2 = zernike_scan_sequence;
    end
    
    fprintf('Iteration %d...\n', n_it);
    
    for n_scan = 1:num_scans
        %% add zernike pol on top of image
        n_mode = zernike_scan_sequence2(n_scan,1);
        n_weight = zernike_scan_sequence2(n_scan,2);
        if n_mode == 999
            holo_im = app.SLM_ref_im;
        else
            holo_im = current_im;
            holo_im(m_idx,n_idx) = angle(exp(1i*(current_im(m_idx,n_idx) + all_modes(:,:,n_mode)*n_weight))) + pi;
        end
        holo_im_pointer.Value = f_SLM_im_to_pointer(holo_im);
        
        %%
        f_SLM_BNS_update(app.SLM_ops, holo_im_pointer)
        pause(0.005); % wait 3ms for SLM to stabilize
        
        f_SLM_scan_triggered_frame(app.DAQ_session);
        num_scans_done = num_scans_done + 1;
        
    end
    %% get frames and analyze 
    
    while num_frames < num_scans_done
        files1 = dir([path1 '\' '*tif']);
        fnames = {files1.name}';
        num_frames = numel(fnames);
        pause(0.005)
    end
    
    frames = f_AO_op_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx,(end-num_scans+1):end);
    
    [AO_correction_new] = f_AO_analyze_zernike(frames2, zernike_scan_sequence2, an_params);
    
    AO_correction = [AO_correction; {AO_correction_new}];

    %% scan all corrections
    current_AO_wf = zeros(SLMm, SLMn);
    for n_corr = 0:numel(AO_correction)
        if n_corr
            correction = AO_correction{n_corr};
            for n_mode = 1:size(correction,1)
                current_AO_wf = current_AO_wf + all_modes(:,:,correction(n_mode, 1))*correction(n_mode, 2);
            end
        end
        %%
        current_im = init_image;
        current_im(m_idx,n_idx) = angle(exp(1i*(current_im(m_idx,n_idx) + current_AO_wf))) + pi;
        holo_im_pointer.Value = f_SLM_im_to_pointer(current_im);

        f_SLM_BNS_update(app.SLM_ops, holo_im_pointer)
        pause(0.01); % wait 3ms for SLM to stabilize

        f_SLM_scan_triggered_frame(app.DAQ_session);
        num_scans_done = num_scans_done + 1;
    end
    
    % wait for frame to convert
    while num_frames<num_scans_done
        files1 = dir([path1 '\' '*tif']);
        fnames = {files1.name}';
        num_frames = numel(fnames);
        pause(0.005)
    end

    frames = f_AO_op_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx,(end-numel(AO_correction)):end);
    deets_corr = cell(numel(AO_correction)+1,1);
    intensit = zeros(numel(AO_correction)+1,1);
    for n_fr = 1:(numel(AO_correction)+1)
        deets_corr{n_fr} = f_get_PFS_deets_fast(frames2(:,:,n_fr), conv_kernel);
        intensit(n_fr) = deets_corr{n_fr}.intensity_raw;
    end
    cent_mn = deets_corr{n_fr}.cent_mn;
    %% maybe plot
    if app.PlotprogressCheckBox.Value
        figure(f1);
        sp1.Children(~pl_idx_line).CData = frames2(:,:,end);
        sp1.Children(pl_idx_line).XData = cent_mn(2);
        sp1.Children(pl_idx_line).YData = cent_mn(1);

        subplot(sp2);
        plot(0:numel(AO_correction), intensit, '-o');
    end
    
    bead_mn = bead_mn + round(cent_mn) - [bead_im_window bead_im_window];
end

save(sprintf('%s\\%s_%d_%d_%d_%dh_%dm.mat',...
            app.SLM_ops.save_AO_dir,...
            app.SavefiletagEditField.Value, ...
            time_stamp(2), time_stamp(3), time_stamp(1)-2000, time_stamp(4),...
            time_stamp(5)), 'AO_correction');

        app.
%% save stuff
disp('Done');
end