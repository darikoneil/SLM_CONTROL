function f_sg_xyz_pat_update_reg(app)

new_reg = {app.CurrentregionDropDown.Value};
idx_pat = strcmpi(app.PatterngroupDropDown.Value, {app.xyz_patterns.pat_name});
app.xyz_patterns(idx_pat).SLM_region = new_reg;

end