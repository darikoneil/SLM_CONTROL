function [best_mode_list, best_mode_w_list, mode_data] = f_AO_analyze_zernike(frames2, zernike_scan_sequence, params)
num_scans = size(zernike_scan_sequence,1);
deets_all = cell(num_scans,1);

%% find best mode and weight
scanned_modes = unique(zernike_scan_sequence(:,1));
weights1 = zernike_scan_sequence((zernike_scan_sequence(:,1)==scanned_modes(1)),2);
num_reps = round(numel(weights1)/numel(unique(weights1)));
num_scanned_modes = numel(scanned_modes);

mode_data = struct;
for n_scan = 1:num_scans
    mode_data(n_scan).scan_ind = n_scan;
    mode_data(n_scan).mode = zernike_scan_sequence(n_scan,1);
    mode_data(n_scan).weight = zernike_scan_sequence(n_scan,2);
    if zernike_scan_sequence(n_scan,1) == 999
        mode_data(n_scan).Zn = NaN;
        mode_data(n_scan).Zm = NaN;
    else
        mode_data(n_scan).Zn = zernike_table(zernike_scan_sequence(n_scan,1),2);
        mode_data(n_scan).Zm = zernike_table(zernike_scan_sequence(n_scan,1),3);
    end
    mode_data(n_scan).im = frames2(:,:,n_scan);
end

%% compute the repeat num
for n_mode_ind = 1:num_scanned_modes
    n_mode = scanned_modes(n_mode_ind);
    temp_mode_data = mode_data([mode_data.mode] == n_mode);
    weights = unique([temp_mode_data.weight]');
    for n_w = 1:numel(weights)
        scan_reps_ind = [temp_mode_data([temp_mode_data.weight] == weights(n_w)).scan_ind];
        for n_rep = 1:numel(scan_reps_ind)
            mode_data(scan_reps_ind(n_rep)).num_repeat = n_rep;
        end
    end
end

%%
for n_scan = 1:num_scans
    deets_all{n_scan} = f_get_PFS_deets_fast(mode_data(n_scan).im, params.conv_kernel, params.intensity_win);
    fnames = fieldnames(deets_all{1,1});
    for n_fl = 1:numel(fnames)
        mode_data(n_scan).(fnames{n_fl}) = deets_all{n_it, n_scan}.(fnames{n_fl});
    end  
end

zernike_computed_weights = struct('mode',{});
for n_mode_ind = 1:(num_scanned_modes-1)
    n_mode = scanned_modes(n_mode_ind);
    temp_mode_data = mode_data([mode_data.mode] == n_mode);
    [~, temp_ind] = sort([temp_mode_data.weight]);
    temp_mode_data2 = temp_mode_data(temp_ind);
    [~, temp_ind] = sort([temp_mode_data2.num_repeat]);
    temp_mode_data3 = temp_mode_data2(temp_ind);

    weights = [temp_mode_data3([temp_mode_data3.num_repeat] == 1).weight];
    idx_zero_weight = weights == 0;

    X_peak = reshape([temp_mode_data3.X_peak],[],num_reps);
    Y_peak = reshape([temp_mode_data3.Y_peak],[],num_reps);
    sm_peak = smooth(mean([X_peak, Y_peak],2),10, 'loess');
    [peak_mag, peak_ind] = max(sm_peak);
    peak_change = peak_mag - sm_peak(idx_zero_weight);


    X_fwhm = reshape([temp_mode_data3.X_fwhm],[],num_reps);
    Y_fwhm = reshape([temp_mode_data3.Y_fwhm],[],num_reps);
    sm_fwhm = smooth(mean([X_fwhm, Y_fwhm],2),10, 'loess');
    [fwhm_mag, fwhm_ind] = min(sm_fwhm);
    fwhm_change = fwhm_mag - sm_fwhm(idx_zero_weight);

    im_intens = reshape([temp_mode_data3.intensity_raw],[],num_reps);
    im_intens_sm = smooth(mean(im_intens,2),10, 'loess');
    [intens_mag, intens_ind] = max(im_intens_sm);
    intens_change = intens_mag - im_intens_sm(idx_zero_weight);

    sm_peak_fwhm_ratio = sm_peak./sm_fwhm;
    [peak_fwhm_ratio_mag, peak_fwhm_ratio_ind] = max(sm_peak_fwhm_ratio);
    peak_fwhm_ratio_change = peak_fwhm_ratio_mag - sm_peak_fwhm_ratio(idx_zero_weight);

    sm_peak_x_intens = sm_peak.*im_intens_sm;
    [sm_peak_x_intens_mag, sm_peak_x_intens_ind] = max(sm_peak_x_intens);
    sm_peak_x_intens_change = sm_peak_x_intens_mag - sm_peak_x_intens(idx_zero_weight);

    sm_peak_x_intens_div_fwhm = sm_peak_x_intens./sm_fwhm;
    [sm_peak_x_intens_div_fwhm_mag, sm_peak_x_intens_div_fwhm_ind] = max(sm_peak_x_intens_div_fwhm);
    sm_peak_x_intens_div_fwhm_change = sm_peak_x_intens_div_fwhm_mag - sm_peak_x_intens_div_fwhm(idx_zero_weight);

    zernike_computed_weights(n_mode_ind).mode = n_mode;
    zernike_computed_weights(n_mode_ind).Zn = temp_mode_data3(1).Zn;
    zernike_computed_weights(n_mode_ind).Zm = temp_mode_data3(1).Zm;
    zernike_computed_weights(n_mode_ind).best_peak_weight = weights(peak_ind);
    zernike_computed_weights(n_mode_ind).best_fwhm_weight = weights(fwhm_ind);
    zernike_computed_weights(n_mode_ind).best_intensity_weight = weights(intens_ind);
    zernike_computed_weights(n_mode_ind).best_peak_fwhm_ratio_weight = weights(peak_fwhm_ratio_ind);
    zernike_computed_weights(n_mode_ind).best_sm_peak_x_intens_weight = weights(sm_peak_x_intens_ind);
    zernike_computed_weights(n_mode_ind).sm_peak_x_intens_div_fwhm_weight = weights(sm_peak_x_intens_div_fwhm_ind);
    zernike_computed_weights(n_mode_ind).peak_change = peak_change;
    zernike_computed_weights(n_mode_ind).fwhm_change = fwhm_change;
    zernike_computed_weights(n_mode_ind).intensity_change = intens_change;
    zernike_computed_weights(n_mode_ind).peak_fwhm_ratio_change = peak_fwhm_ratio_change;
    zernike_computed_weights(n_mode_ind).sm_peak_x_intens_change = sm_peak_x_intens_change;
    zernike_computed_weights(n_mode_ind).sm_peak_x_intens_div_fwhm_change = sm_peak_x_intens_div_fwhm_change;
    
    if params.plot_stuff
        figure;
        subplot(2,3,1); hold on;
        plot(weights,X_peak, 'b');
        plot(weights,Y_peak, 'g');
        plot(weights,mean([X_peak, Y_peak],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_peak,'Linewidth',2, 'Color','m');
        plot(weights(peak_ind), sm_peak(peak_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('X peak and Y peak');

        subplot(2,3,3); hold on;
        plot(weights,X_fwhm, 'b')
        plot(weights,Y_fwhm, 'g')
        plot(weights,mean([X_fwhm, Y_fwhm],2),'Linewidth',2, 'Color','k');
        plot(weights,sm_fwhm,'Linewidth',2, 'Color','m');
        plot(weights(fwhm_ind), sm_fwhm(fwhm_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('X fwhm and Y fwhm');

        subplot(2,3,2); hold on;
        plot(weights,im_intens)
        plot(weights,mean(im_intens,2),'Linewidth',2, 'Color','k')
        plot(weights,im_intens_sm,'Linewidth',2, 'Color','m');
        plot(weights(intens_ind), im_intens_sm(intens_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('intensity');

        subplot(2,3,4); hold on;
        plot(weights,sm_peak./sm_fwhm,'Linewidth',2, 'Color','m');
        plot(weights(peak_fwhm_ratio_ind), sm_peak_fwhm_ratio(peak_fwhm_ratio_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('max/fwhm ratio');

        subplot(2,3,5); hold on;
        plot(weights,sm_peak_x_intens,'Linewidth',2, 'Color','m');
        plot(weights(sm_peak_x_intens_ind), sm_peak_x_intens(sm_peak_x_intens_ind), '*g','MarkerSize',14,'Linewidth',2);
        title('peak * intensity');
        suptitle(sprintf('zernike mode %d', n_mode));
    end
end


[~, best_mode_ind] = sort([zernike_computed_weights.sm_peak_x_intens_div_fwhm_change], 'descend');

% [~, best_mode_ind] = max([zernike_computed_weights.sm_peak_x_intens_div_fwhm_change]);
% best_mode = zernike_computed_weights(best_mode_ind).mode;
% best_mode_w = zernike_computed_weights(best_mode_ind).best_sm_peak_x_intens_weight;

best_mode_list = [zernike_computed_weights(best_mode_ind).mode];
best_mode_w_list = [zernike_computed_weights(best_mode_ind).best_sm_peak_x_intens_weight];

end