function f_sg_gui_close(app)

if app.ActivateSLMButton.Value
    f_SLM_update(app.SLM_ops, app.SLM_blank_pointer);
    app.SLM_ops = f_SLM_close(app.SLM_ops);
end

app.SLM_ops = f_sg_destruct_imageGen(app.SLM_ops);

delete(app);

end