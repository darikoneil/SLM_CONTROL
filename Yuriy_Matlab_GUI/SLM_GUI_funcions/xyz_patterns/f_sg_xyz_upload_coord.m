function f_sg_xyz_upload_coord(app, coord)

%% generate image
if ~isempty(coord)
    reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);
    
    %% update slm im
    holo_phase = f_sg_xyz_gen_holo(coord, reg1);
    
    SLM_phase = angle(sum(exp(1i*(holo_phase)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3));

    %% add ao corrections
    
    if app.ApplyAOcorrectionButton.Value
        AO_phase = f_sg_AO_get_z_corrections(app, reg1, coord.xyzp(:,3));
        app.GUI_buffer.current_AO_phase = AO_phase;

        holo_phase_corr = holo_phase+AO_phase;
    else
        holo_phase_corr = holo_phase;
        app.GUI_buffer.current_AO_phase = [];
    end

    %% superimpose points and apply weights
    SLM_phase_corr = angle(sum(exp(1i*(holo_phase_corr)).*reshape(coord.weight,[1 1 numel(coord.weight)]),3));
    %figure; imagesc(SLM_phase)
    
    %% apply lut correction
    SLM_phase_corr_lut = f_sg_lut_apply_reg_corr(SLM_phase_corr, reg1);
    
    %% save
    
    app.current_SLM_coord = coord;
    app.GUI_buffer.current_SLM_coord = coord;
    app.GUI_buffer.current_region = reg1;
    app.GUI_buffer.current_holo_phase = holo_phase;
    
    app.GUI_buffer.current_holo_phase_corr = holo_phase_corr;
    
    app.GUI_buffer.current_SLM_phase = SLM_phase;
    app.GUI_buffer.current_SLM_phase_corr = SLM_phase_corr;
    app.GUI_buffer.current_SLM_phase_corr_lut = SLM_phase_corr_lut;
    
    app.SLM_phase(reg1.m_idx, reg1.n_idx) = SLM_phase;
    app.SLM_phase_corr(reg1.m_idx, reg1.n_idx) = SLM_phase_corr;
    app.SLM_phase_corr_lut(reg1.m_idx, reg1.n_idx) = SLM_phase_corr_lut;
    
    %% upload local region to SLM
    f_sg_upload_image_to_SLM(app);
end

end