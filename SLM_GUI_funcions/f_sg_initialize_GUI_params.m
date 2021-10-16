function f_sg_initialize_GUI_params(app)
ops = app.SLM_ops;

%%
app.LUTDropDown.Items = app.lut_list;
app.LUTDropDown.Value = ops.lut_fname;

%% initialize region list
app.SelectRegionDropDown.Items = [app.region_list.name_tag];
app.CurrentregionDropDown.Items = [app.region_list.name_tag];

%%
app.LateralaffinetransformDropDown.Items = ops.lateral_calibration(:,1);
app.AOcorrectionDropDown.Items = ops.AO_correction(:,1);

%% update lut corrections
if ~isfield(app.region_list, 'lut_correction')
    app.region_list(1).lut_correction = [];
end
if ~isfield(app.region_list, 'lut_correction')
    for n_reg = 1:numel(app.region_list)
        app.region_list(n_reg).xyz_affine_tf_mat = diag(ones(3,1));
    end
end
if ~isfield(app.region_list, 'AO_correction')
    app.region_list(1).AO_correction = [];
end
if ~isfield(app.region_list, 'AO_wf')
    app.region_list(1).AO_wf = [];
end

f_sg_reg_update(app);

for n_reg = 1:numel(app.region_list)
    app.region_list(n_reg).xyz_affine_tf_mat = f_sg_compute_xyz_affine_tf_mat_reg(app, app.region_list(n_reg));
    app.region_list(n_reg).AO_wf = f_sg_AO_compute_wf(app, app.region_list(n_reg));
end

%% xyz table
% xyz_blank = table('Size', [0 6], 'VariableTypes', {'double', 'double','double', 'double', 'double', 'double'});
% xyz_blank.Properties.VariableNames = {'Pattern', 'Z', 'X', 'Y', 'NA', 'Weight'};
% app.GUI_ops.xyz_blank = xyz_blank;

f_sg_pat_update(app, 1);
app.PatternDropDownCtr.Items = [{'None'}, app.xyz_patterns.name_tag];
app.PatternDropDownAI.Items = [{'None'}, app.xyz_patterns.name_tag];

%%
app.SLMheightEditField.Value = ops.height;
app.SLMwidthEditField.Value = ops.width;

app.ObjectiveMagXEditField.Value = ops.objective_mag;
app.EffectiveNAEditField.Value = ops.effective_NA;
app.ManualNAEditField.Value = ops.effective_NA;
app.ObjectiveRIEditField.Value = ops.objective_RI;
app.WavelengthnmEditField.Value = ops.wavelength;
app.BeamdiameterpixEditField.Value = ops.beam_diameter;
app.SLMpresetoffsetXEditField.Value = ops.X_offset;
app.SLMpresetoffsetYEditField.Value = ops.Y_offset;
app.NIDAQdeviceEditField.Value = ops.NI_DAQ_dvice;
app.DAQcounterchannelEditField.Value = ops.NI_DAQ_counter_channel;
app.DAQAIchannelEditField.Value = ops.NI_DAQ_AI_channel;
app.DAQAOchannelEditField.Value = ops.NI_DAQ_AO_channel;

app.FOVsizeumEditField.Value = ops.FOV_size;

%%
% blank
app.BlankPixelValueEditField.Value = 0;

% Fresnel lens
app.FresCenterXEditField.Value = app.SLM_ops.width/2;
app.FresCenterYEditField.Value = app.SLM_ops.height/2;
app.FresRadiusEditField.Value = app.SLM_ops.height/2;
app.FresPowerEditField.Value = 1;
app.FresCylindricalCheckBox.Value = 1;
app.FresHorizontalCheckBox.Value = 0;

% Blazed grating
app.BlazPeriodEditField.Value = 127;
app.BlazIncreasingCheckBox.Value = 1;
app.BlazHorizontalCheckBox.Value = 0;

% Stripes
app.StripePixelPerStripeEditField.Value = 8;
app.StripePixelValueEditField.Value = 0;
app.StripeGrayEditField.Value = 127;

% zernike
app.CenterXEditField.Value = floor(app.SLM_ops.width/2);
app.CenterYEditField.Value = floor(app.SLM_ops.height/2);
app.RadiusEditField.Value = min([app.SLM_ops.height, app.SLM_ops.height])/2;

%%
% Multiplane imaging
tab_data = array2table([1, 1, 0, 0, 0, 1]);
tab_data.Properties.VariableNames = {'Idx', 'Pattern', 'X', 'Y', 'Z', 'Weight'};
app.UIImagePhaseTable.Data = tab_data;
f_sg_pat_save(app);

% AO zernike table
app.ZernikeListTable.Data = table();
f_sg_AO_fill_modes_table(app);
f_sg_LUT_update_total_frames(app);

% initialize af matrix
app.ApplyXYZcalibrationButton.Value = 1;
f_sg_apply_xyz_calibration(app);

% initialize blank image
app.SLM_blank_im = exp(1i*(zeros(app.SLM_ops.height,app.SLM_ops.width)));
app.SLM_blank_pointer = f_sg_initialize_pointer(app);
app.SLM_Image_pointer.Value = f_sg_im_to_pointer(angle(app.SLM_blank_im));

% initialize other pointers
app.SLM_Image = app.SLM_blank_im;
app.SLM_Image_pointer = f_sg_initialize_pointer(app);

app.SLM_Image_gh_preview = app.SLM_blank_im;
app.SLM_Image_plot = imagesc(app.UIAxesGenerateHologram, angle(app.SLM_blank_im)+pi);
axis(app.UIAxesGenerateHologram, 'tight');
axis(app.UIAxesGenerateHologram, 'equal');
caxis(app.UIAxesGenerateHologram, [0 2*pi]);

clim_x = linspace(app.UIAxesGenerateHologram.CLim(1), app.UIAxesGenerateHologram.CLim(2), size(app.UIAxesGenerateHologram.Colormap,1))/pi;
clim_im = reshape(app.UIAxesGenerateHologram.Colormap, [1 size(app.UIAxesGenerateHologram.Colormap,1) 3]);

app.SLM_Image_gh_climits = imagesc(app.UIAxesColorLimits, clim_x, [], clim_im);
axis(app.UIAxesColorLimits, 'tight');

app.current_SLM_coord = f_sg_mpl_get_coords(app, 'zero');
app.current_SLM_AO_Image = [];

if ~exist(ops.save_AO_dir, 'dir')
    mkdir(ops.save_AO_dir);
end

if ~exist(ops.save_patterns_dir, 'dir')
    mkdir(ops.save_patterns_dir);
end

if ~exist(ops.custom_phase_dir, 'dir')
    mkdir(ops.custom_phase_dir);
end

app.ImagepathEditField.Value = [ops.custom_phase_dir '\'];

if ~exist(ops.patter_editor_dir, 'dir')
    mkdir(ops.patter_editor_dir);
end

% initialize DAQ
f_sg_initialize_DAQ(app);
%

end