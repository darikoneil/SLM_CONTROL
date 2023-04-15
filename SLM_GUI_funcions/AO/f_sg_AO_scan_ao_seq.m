function num_scans_done = f_sg_AO_scan_ao_seq(app, holo_im_pointer, holo_phase, init_AO_phase, zernike_scan_sequence, ao_params)

reg1 = ao_params.region;
init_SLM_phase_corr_lut = ao_params.init_SLM_phase_corr_lut;

num_scans = numel(zernike_scan_sequence);
num_scans_done = 0;

for n_scan = 1:num_scans
    % add zernike pol on top of image
    full_corr = zernike_scan_sequence{n_scan};
    ao_corr = f_sg_AO_corr_to_phase(full_corr, ao_params);

    % convert to exp and slm phase 
    complex_exp_corr = exp(1i*(holo_phase + init_AO_phase + ao_corr));
    SLM_phase_corr = angle(complex_exp_corr);
    
    % apply lut and upload
    init_SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    holo_im_pointer.Value = reshape(init_SLM_phase_corr_lut', [],1);

    f_SLM_update(app.SLM_ops, holo_im_pointer)
    pause(0.005); % wait 3ms for SLM to stabilize

    f_sg_scan_triggered_frame(app.DAQ_session, app.PostscandelayEditField.Value);
    
    num_scans_done = num_scans_done + 1;
end

end