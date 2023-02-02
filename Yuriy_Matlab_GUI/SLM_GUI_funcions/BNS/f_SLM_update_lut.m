function f_SLM_update_lut(ops)

%%
if strcmpi(ops.SLM_type, 'BNS1920')
    f_SLM_BNS1920_update_lut(ops);
elseif strcmpi(ops.SLM_type, 'BNS512')
    f_SLM_BNS512_update_lut(ops);
else 
    disp('Lut update only available for non overdrive SLM, deactivate and change in default ops')
end

end