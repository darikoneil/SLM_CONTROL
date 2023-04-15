function f_sg_AO_scan_optimization(app)
disp('Starting optimization...');

timestamp = f_sg_get_timestamp();

%%
ao_params.bead_im_window = app.BeadwindowsizeEditField.Value;
ao_params.n_corrections_to_use = 1;
ao_params.correction_weight_step = 1;
ao_params.plot_stuff = app.PlotprogressCheckBox.Value;
ao_params.plot_stuff_extra = app.PlotextradeetsCheckBox.Value;
ao_params.sigma_pixels = 1;
ao_params.coord = app.current_SLM_coord;
ao_params.region_name = app.CurrentregionDropDown.Value;
ao_params.file_dir = app.ScanframesdirpathEditField.Value;

reg1 = f_sg_get_reg_deets(app, ao_params.region_name);

ao_params.region = reg1;
ao_params.init_coord = app.current_SLM_coord;
ao_params.init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;

%% first upload (maybe not needed. already there)
init_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
holo_im_pointer = f_sg_initialize_pointer(app);

if app.ApplyAOcorrectionButton.Value
    init_AO = f_sg_AO_get_z_corrections(app, reg1, ao_params.init_coord.xyzp(:,3));
else
    init_AO = zeros(reg1.SLMm, reg1.SLMn);
end

coord_corr = f_sg_coord_correct(reg1, ao_params.init_coord);
init_holo_phase = f_sg_PhaseHologram2(coord_corr, reg1);

% convert to exp and slm phase 
complex_exp_corr = exp(1i*(init_holo_phase+init_AO));
SLM_phase_corr = angle(complex_exp_corr);

% apply lut and upload
init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);
f_SLM_update(app.SLM_ops, holo_im_pointer);

%%
resetCounters(app.DAQ_session);
app.DAQ_session.outputSingleScan(0);
app.DAQ_session.outputSingleScan(0);

%path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-006';
path1 = app.ScanframesdirpathEditField.Value;
%exist(path1, 'dir');

f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
% make extra scan because stupid scanimage
f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
num_scans_done = 2;

f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

% get all files except last
frames = f_sg_AO_get_all_frames(path1);
num_frames = size(frames,3);

f1 = figure; axis equal tight;
imagesc(frames(:,:,num_frames));
title('Click on bead (1 click)')
bead_mn = zeros(1,2);
[bead_mn(2),bead_mn(1)] = ginput(1);
bead_mn = round(bead_mn);

%% bead window
kernel_half_size = ceil(sqrt(-log(0.1)*2*ao_params.sigma_pixels^2));
[X_gaus,Y_gaus] = meshgrid((-kernel_half_size):kernel_half_size);
conv_kernel = exp(-(X_gaus.^2 + Y_gaus.^2)/(2*ao_params.sigma_pixels^2));
conv_kernel = conv_kernel/sum(conv_kernel(:));

im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(1));
im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(2));

im_cut = frames(im_m_idx, im_n_idx,num_frames);

deets_pre = f_get_PFS_deets_fast(im_cut, conv_kernel);

%ao_params.intensity_win = ceil((deets_pre.X_fwhm + deets_pre.Y_fwhm)/4);
ao_params.intensity_win = 3;
ao_params.deets_pre = deets_pre;

if app.PlotprogressCheckBox.Value
    sp1 = subplot(1,2,1); hold on; axis tight equal;
    imagesc(im_cut);
    plot(deets_pre.cent_mn(2),deets_pre.cent_mn(1), 'ro');
    sp2 = subplot(1,2,2); hold on; axis tight;
    plot(0, deets_pre.intensity_raw, '-o');
    pl_idx_line = isprop(sp1.Children, 'LineStyle');
end

%% create patterns
zernike_table = app.ZernikeListTable.Data;
zernike_table2 = zernike_table(logical(zernike_table(:,7)),:);

% generate all polynomials
all_modes = f_sg_gen_zernike_modes(reg1, zernike_table);
ao_params.all_modes = all_modes;

num_modes = size(zernike_table2,1);

W_step = app.WeightstepEditField.Value;
if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
    W_lim = app.WeightlimitEditField.Value;
    weights1 = -W_lim:W_step:W_lim;   
elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
    weights1 = [-W_step, W_step];
end

num_weights = numel(weights1);

scan_seq1 = cat(3, repmat(zernike_table2(:,1), [1, num_weights]), ones(num_modes, num_weights).*weights1);
scan_seq1 = permute(scan_seq1, [2, 1, 3]);
scan_seq1 = reshape(scan_seq1, [num_modes*num_weights, 2]);
scan_seq1 = repmat(scan_seq1, [app.ScanspermodeEditField.Value, 1]);

zernike_scan_sequence = num2cell(scan_seq1, 2);

num_scans = size(zernike_scan_sequence,1);

ao_params.zernike_scan_sequence = zernike_scan_sequence;

%% scan
AO_correction = {[1, 0]};

center_defocus_z_range = (-5:5);
current_coord = ao_params.init_coord;

mode_data_all = cell(app.NumiterationsSpinner.Value,1);
deeps_post = cell(app.NumiterationsSpinner.Value,1);

step_size = 0.01;

for n_it = 1:app.NumiterationsSpinner.Value
    fprintf('Iteration %d...\n', n_it);
    ao_params.iteration = n_it;
    
    current_AO_phase = f_sg_AO_corr_to_phase(cat(1,AO_correction{:,1}), ao_params) + init_AO;
    
    %% refocus in z
    
    num_scans_done2 = f_sg_AO_scan_z_defocus(app, holo_im_pointer, current_coord, center_defocus_z_range, current_AO_phase, ao_params);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;

    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);

    % analyze
    disp('fit defocus analysis here')
    
    current_coord_corr = f_sg_coord_correct(reg1, current_coord);
    current_holo_phase = f_sg_PhaseHologram2(current_coord_corr, reg1);
    
    
    %% scan gradient
    % pre scan 
    if app.ShufflemodesCheckBox.Value
        zernike_scan_sequence2 = zernike_scan_sequence(randsample(num_scans,num_scans));
    else
        zernike_scan_sequence2 = zernike_scan_sequence;
    end
    % scan mode sequence
    num_scans_done2 = f_sg_AO_scan_ao_seq(app, holo_im_pointer, current_holo_phase, current_AO_phase, zernike_scan_sequence2, ao_params);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;
    
    % get frames and analyze 
    im_m_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(1));
    im_n_idx = round(((-ao_params.bead_im_window/2):(ao_params.bead_im_window/2)) + bead_mn(2));
    
    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);
    
    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);
    
    if strcmpi(app.OptimizationmethodDropDown.Value, 'Grid search')
        % process find best mode
        [AO_correction_new, mode_data_all{n_it}] = f_sg_AO_find_best_mode_grid(frames2, zernike_scan_sequence2, ao_params);
    elseif strcmpi(app.OptimizationmethodDropDown.Value, 'Gradient desc')
        % can optimize most problematic mode here
        intensity = zeros(num_scans, 1);
        for n_scan = 1:num_scans
            deets1 = f_get_PFS_deets_fast(frames2(:,:,n_scan), conv_kernel);
            intensity(n_scan) = deets1.intensity_sm;
        end
        
        mode_weight_int = [cat(1, zernike_scan_sequence2{:}), intensity];
        
        [~, sort_idx] = sort(mode_weight_int(:,2));
        mode_weight_int2 = mode_weight_int(sort_idx,:);
        
        [~, sort_idx2] = sort(mode_weight_int2(:,1));
        mode_weight_int3 = mode_weight_int2(sort_idx2,:);
        
        mode_weight_int4 = squeeze(mean(reshape(mode_weight_int3, app.ScanspermodeEditField.Value, [], 3),1));
        
        mode_weight_int5 = reshape(mode_weight_int4, 2, [], 3);
        
        modes2 = mode_weight_int5(1, :, 1)';
        weights2 = mode_weight_int5(:, 1, 2);
        
        intens2 = mode_weight_int5(:,:,3);
        
        d_i = (intens2(2,:) - intens2(1,:))';
        d_w = weights2(2) - weights2(1);
        grad2 = d_i/d_w;

        w_step = grad2*step_size;
        
        AO_correction_new = [modes2, w_step];
        
        figure;
        subplot(2,1,1);
        plot(modes2, grad2)
        ylabel('weight gradient')
        title(sprintf('AO optimization iter%d', n_it));
        subplot(2,1,2);
        plot(modes2, abs(w_step))
        xlabel('mode')
        ylabel('abs weight step')

    end
    
    % update corrections
    AO_correction = [AO_correction; {AO_correction_new}];
    
    %% scan all corrections
    num_corrections = numel(AO_correction);
    scan_seq = repmat(1:num_corrections, 1, app.ScanspermodeEditField.Value)';
    num_scans_ver = numel(scan_seq);
    
    if app.ShufflemodesCheckBox.Value
        scan_seq2 = scan_seq(randsample(num_scans_ver,num_scans_ver),:);
    else
        scan_seq2 = scan_seq;
    end
    
    scan_seq3 = cell(num_scans_ver, 1);
    for n_seq = 1:num_scans_ver
        scan_seq3{n_seq} = cat(1,AO_correction{1:scan_seq2(n_seq),1});
    end
    
    num_scans_done2 = f_sg_AO_scan_ao_seq(app, holo_im_pointer, current_holo_phase, current_AO_phase, scan_seq3, ao_params);
    scan_start = num_scans_done + 1;
    scan_end = (scan_start+num_scans_done2-1);
    num_scans_done = num_scans_done + num_scans_done2;

    % make extra scan because stupid scanimage
    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    num_scans_done = num_scans_done + 1;
    f_sg_AO_wait_for_frame_convert(path1, num_scans_done);

    % load scanned frames
    frames = f_sg_AO_get_all_frames(path1);
    frames2 = frames(im_m_idx, im_n_idx, scan_start:scan_end);
    
    intensit = zeros(num_corrections,1);
    for n_fr = 1:num_corrections
        fr_idx1 = find(scan_seq2 == n_fr);
        for n_fr2 = 1:numel(fr_idx1)
            if n_fr2 == 1
                deets_corr = f_get_PFS_deets_fast(frames2(:,:,fr_idx1(n_fr2)), conv_kernel);
            else
                deets_corr(n_fr2) = f_get_PFS_deets_fast(frames2(:,:,fr_idx1(n_fr2)), conv_kernel);
            end
        end
        
        curr_fr = mean(frames2(:,:,fr_idx1),3);
        
        intensit(n_fr) = mean([deets_corr.intensity_raw]);
        cent_mn = mean([deets_corr.cent_mn],2);
    end
    
    deeps_post{n_it} = deets_corr;
    
    %% maybe plot
    if app.PlotprogressCheckBox.Value
        figure(f1);
        sp1.Children(~pl_idx_line).CData = curr_fr;
        sp1.Children(pl_idx_line).XData = cent_mn(2);
        sp1.Children(pl_idx_line).YData = cent_mn(1);

        subplot(sp2);
        plot(0:(numel(AO_correction)-1), intensit, '-o');
    end
    
    bead_mn = bead_mn + round(cent_mn) - [ao_params.bead_im_window/2 ao_params.bead_im_window/2];
end
ao_params.mode_data_all = mode_data_all;
ao_params.deeps_post = deeps_post;

name_tag = sprintf('%s\\%s_%s',...
            app.SLM_ops.save_AO_dir,...
            app.SavefiletagEditField.Value, ...
            timestamp);

save([name_tag '.mat'], 'AO_correction', 'ao_params', '-v7.3');
saveas(f1,[name_tag '.fig']);
%% save stuff
disp('Done');
end