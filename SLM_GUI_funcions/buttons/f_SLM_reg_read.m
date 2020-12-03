function region1 = f_SLM_reg_read(app)
%%
region1.name_tag = {app.RegionnameEditField.Value};
region1.height_range = [app.regionheightminEditField.Value, app.regionheightmaxEditField.Value];
region1.width_range = [app.regionwidthminEditField.Value, app.regionwidthmaxEditField.Value];
region1.wavelength = app.regionWavelengthnmEditField.Value;
if strcmpi(app.LUTcorrectionDropDown.Value, 'none')
    region1.lut_correction = [];
else
    region1.lut_correction = [{app.LUTDropDown.Value}, {app.LUTcorrectionDropDown.Value}];
end
if strcmpi(app.LateralaffinetransformDropDown.Value, 'none')
    region1.lateral_affine_transform = [];
else
    region1.lateral_affine_transform = app.LateralaffinetransformDropDown.Value;
end
if strcmpi(app.AxialcalibrationDropDown.Value, 'none')
    region1.axial_calibration = [];
else
    region1.axial_calibration = app.AxialcalibrationDropDown.Value;
end
if strcmpi(app.AOcorrectionDropDown.Value, 'none')
    region1.AO_correction = [];
else
    region1.AO_correction = app.AOcorrectionDropDown.Value;
end

region1.xyz_affine_tf_mat = f_SLM_compute_xyz_affine_tf_mat_reg(app, region1);

region1.AO_wf = f_SLM_AO_compute_wf(app, region1, app.AOnummodestouseSpinner.Value);

end