function f_sg_reg_update(app)
% set region values in app window

% select region
reg1 = app.region_list(strcmpi({app.region_list.reg_name},app.SelectRegionDropDown.Value));

% select region_objective params
reg_params_idx = f_sg_get_reg_params_idx(app, app.SelectRegionDropDown.Value);

if sum(reg_params_idx)
    reg_params = app.region_obj_params(reg_params_idx);
else
    reg_params = app.SLM_ops.default_region_params;
    if isempty(reg_params.beam_diameter)
        reg_params.beam_diameter = max([app.SLM_ops.height app.SLM_ops.width]);
    end
end

if ~isempty(reg1)
    app.RegionnameEditField.Value = reg1.reg_name;
    app.regionheightminEditField.Value = reg1.height_range(1);
    app.regionheightmaxEditField.Value = reg1.height_range(2);
    app.regionwidthminEditField.Value = reg1.width_range(1);
    app.regionwidthmaxEditField.Value = reg1.width_range(2);
end

if ~isempty(reg_params)
    % load region obj params
    app.regionWavelengthnmEditField.Value = reg_params.wavelength;
    app.regionBeamDiameterEditField.Value = reg_params.beam_diameter;
    app.regionEffectiveNAEditField.Value = reg_params.effective_NA;
    
    % update dropdown
    lut_fname = app.LUTDropDown.Value;
    lut_corr_fname = {'None'};
    
    % load saved correction value
    if ~isempty(reg_params.lut_correction_fname)
        lut_sublist = app.lut_corrections_list(strcmpi(app.lut_corrections_list(:,1), lut_fname),2);
        if ~isempty(lut_sublist)
            if sum(strcmpi(reg_params.lut_correction_fname, lut_sublist))
                lut_corr_fname = reg_params.lut_correction_fname;
            end
        end
    end

    app.LUTcorrectionDropDown.Items = app.lut_corrections_list(:,1);
    app.LUTcorrectionDropDown.Value = lut_corr_fname;

    XYZ_corr_fname = {'None'};
    if ~isempty(reg_params.xyz_affine_tf_fname)
        if sum(strcmpi(app.SLM_ops.xyz_corrections_list(:,1),reg_params.xyz_affine_tf_fname))
            XYZ_corr_fname = reg_params.xyz_affine_tf_fname;
        end
    end
    app.XYZaffinetransformDropDown.Value = XYZ_corr_fname;
    
    AO_corr_fname = {'None'};
    if ~isempty(reg_params.AO_correction_fname)
        if sum(strcmpi(app.SLM_ops.AO_corrections_list(:,1), reg_params.AO_correction_fname))
            AO_corr_fname = reg_params.AO_correction_fname;
        end
    end
    app.AOcorrectionDropDown.Value = AO_corr_fname;
    
else
    disp('Region update failed')
end

end


