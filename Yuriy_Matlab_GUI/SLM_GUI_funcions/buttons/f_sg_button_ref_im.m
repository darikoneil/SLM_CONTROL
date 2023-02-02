function f_sg_button_ref_im(app)

coords = f_sg_mpl_get_coords(app, 'zero');
coords.xyzp = [app.SLM_ops.ref_offset, 0, 0;...
               -app.SLM_ops.ref_offset, 0, 0;...
                0, app.SLM_ops.ref_offset, 0;...
                0,-app.SLM_ops.ref_offset, 0];

reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
            
holo_phase = f_sg_xyz_gen_holo(coords, reg1);
holo_phase2 = angle(sum(exp(1i*(holo_phase)),3));

app.SLM_phase_corr(reg1.m_idx, reg1.n_idx) = holo_phase2;            
app.current_SLM_coord = coords;

app.SLM_phase_plot.CData = app.SLM_phase_corr+pi;
app.SLM_gh_phase_preview = app.SLM_phase_corr;

%% apply lut correction
app.SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(holo_phase2, reg1);

%% upload
f_sg_upload_image_to_SLM(app);    
fprintf('SLM ref image, %d  xy offsets uploaded\n', app.SLM_ops.ref_offset);


end