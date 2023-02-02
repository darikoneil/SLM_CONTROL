function f_sg_gh_defocus(app)

% get reg
reg1 = f_sg_get_reg_deets(app, app.CurrentregionDropDown.Value);

beam_diameter = reg1.beam_diameter;
wavelength = reg1.wavelength*1e-9;

defocus_weight = app.DeficusWeightEditField.Value*1e-6; % convert to um

defocus_phase = f_sg_DefocusPhase(reg1.SLMm, reg1.SLMn,...
                app.SLM_ops.effective_NA,...
                app.SLM_ops.objective_RI,...
                wavelength, beam_diameter)*defocus_weight; % was wavelength*10 idk why

if app.ZerooutsideunitcircCheckBox.Value
    defocus_phase(reg1.holo_mask) = 0;
end
            
defocus_phase2=angle(sum(exp(1i*(defocus_phase)),3));

app.SLM_gh_phase_preview(reg1.m_idx, reg1.n_idx) = defocus_phase2;
app.SLM_phase_plot.CData = app.SLM_gh_phase_preview+pi;

end