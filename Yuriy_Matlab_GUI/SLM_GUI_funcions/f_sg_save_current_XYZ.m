function f_sg_save_current_XYZ(app)

XYZ_data.region = app.CurrentregionDropDown.Value;
XYZ_data.pattern = app.PatterngroupDropDown.Value;
XYZ_data.coords_table = app.UIImagePhaseTable.Data;
XYZ_data.current_pattern = app.PatternSpinner.Value;
XYZ_data.current_XYZ_coords = app.current_SLM_coord;
XYZ_data.current_SLM_phase = app.SLM_phase;
XYZ_data.current_SLM_phase_corr = app.SLM_phase_corr;
XYZ_data.current_SLM_phase_corr_lut = app.SLM_phase_corr_lut;
XYZ_data.xyz_patterns = app.xyz_patterns;
XYZ_data.region_obj_params = app.region_obj_params;

temp_time = clock;
file_time = sprintf('%d_%d_%d_%dh_%dm',temp_time(2), temp_time(3), temp_time(1)-2000, temp_time(4), temp_time(5));

[file,path1] = uiputfile([app.SLM_ops.save_dir '\current_XYZ_' file_time '.mat']); % {'*.bmp';'*.*', 'pattern.bmp'}, 

if file
    save([path1 file], 'XYZ_data');
    disp('Saved');
end


end