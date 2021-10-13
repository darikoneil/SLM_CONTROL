function [wf_out, params] = f_sg_AO_compute_wf2(app, reg1)
params = struct;
params.beam_width = app.BeamdiameterpixEditField.Value;
params.AO_iteration = 1;
params.zero_around_unit_circ = app.ZerooutsideunitcircCheckBox.Value;
params.AO_correction = [];

if isempty(reg1.AO_correction)
    wf_out = [];
elseif strcmpi(reg1.AO_correction, 'none')
    wf_out = [];
else
    %idx_AO = strcmpi(reg1.AO_correction, app.SLM_ops.AO_correction(:,1));
    %AO_correction = app.SLM_ops.AO_correction{idx_AO,2}.AO_correction;
    
    data = load([app.SLM_ops.AO_correction_dir '\' reg1.AO_correction]);
    
    if isstruct(data.AO_correction)
        wf_out = struct;
        for n_corr = 1:numel([data.AO_correction.Z])
            wf_out(n_corr).Z = data.AO_correction(n_corr).Z;
            
            params.beam_width = data.AO_correction(n_corr).ao_params.beam_width;
            full_correction = cat(1,data.AO_correction(n_corr).AO_correction{:,1});
            
            [m_idx, n_idx] = f_sg_get_reg_deets(app, reg1.name_tag); 
            SLMm = sum(m_idx);
            SLMn = sum(n_idx);
            beam_width = params.beam_width;
            xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
            xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
            [fX, fY] = meshgrid(xln, xlm);
            [theta, rho] = cart2pol( fX, fY );

            num_modes = size(full_correction,1);
            max_mode = max(full_correction(:,1));

            % compute n m
            zernike_nm_list_cell = cell(max_mode+1,1);
            for mode = 0:max_mode
                n_modes = (-mode:2:mode)';
                m_modes = ones(mode+1,1)*mode;
                zernike_nm_list_cell{mode+1} = [m_modes,n_modes]; 
            end
            zernike_nm_list = cat(1, zernike_nm_list_cell{:});

            % generate all polynomials
            all_modes = zeros(SLMm, SLMn, num_modes);
            for n_mode_idx = 1:num_modes
                n_mode = full_correction(n_mode_idx,1);
                Z_nm = f_sg_zernike_pol(rho, theta, zernike_nm_list(n_mode,1), zernike_nm_list(n_mode,2));
                all_modes(:,:,n_mode_idx) = Z_nm*full_correction(n_mode_idx,2);
            end

            all_modes_sum = sum(all_modes,3);
            if app.ZerooutsideunitcircCheckBox.Value
                all_modes_sum(rho>1) = 0;
            end

            wf_out(n_corr).wf_out = zeros(app.SLM_ops.height, app.SLM_ops.width);
            wf_out(n_corr).wf_out(m_idx, n_idx) = all_modes_sum;
        end
    else
        params.beam_width = data.ao_params.beam_width;
        full_correction = cat(1,data.AO_correction{:,1});

        [m_idx, n_idx] = f_sg_get_reg_deets(app, reg1.name_tag); 
        SLMm = sum(m_idx);
        SLMn = sum(n_idx);
        beam_width = params.beam_width;
        xlm = linspace(-SLMm/beam_width, SLMm/beam_width, SLMm);
        xln = linspace(-SLMn/beam_width, SLMn/beam_width, SLMn);
        [fX, fY] = meshgrid(xln, xlm);
        [theta, rho] = cart2pol( fX, fY );

        num_modes = size(full_correction,1);
        max_mode = max(full_correction(:,1));

        % compute n m
        zernike_nm_list_cell = cell(max_mode+1,1);
        for mode = 0:max_mode
            n_modes = (-mode:2:mode)';
            m_modes = ones(mode+1,1)*mode;
            zernike_nm_list_cell{mode+1} = [m_modes,n_modes]; 
        end
        zernike_nm_list = cat(1, zernike_nm_list_cell{:});

        % generate all polynomials
        all_modes = zeros(SLMm, SLMn, num_modes);
        for n_mode_idx = 1:num_modes
            n_mode = full_correction(n_mode_idx,1);
            Z_nm = f_sg_zernike_pol(rho, theta, zernike_nm_list(n_mode,1), zernike_nm_list(n_mode,2));
            all_modes(:,:,n_mode_idx) = Z_nm*full_correction(n_mode_idx,2);
        end

        all_modes_sum = sum(all_modes,3);
        if app.ZerooutsideunitcircCheckBox.Value
            all_modes_sum(rho>1) = 0;
        end

        wf_out = zeros(app.SLM_ops.height, app.SLM_ops.width);
        wf_out(m_idx, n_idx) = all_modes_sum;
        %figure; imagesc(wf_out)

        params.AO_correction = full_correction;
        params.AO_iteration = size(full_correction,1)+1;
    end
    
    
end

end