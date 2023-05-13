% fitting gaussian for each dimension

clear;
close all;

data_source = 10;

if data_source == 1
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\etl_psf_prairie1_3_28_23\';
    data_path2 = {'z100_20um_256_32ave-003',...
                  'z50_20um_256_32ave-002',...
                  'z0_20um_256_32ave-001',...
                  'z-50_20um_256_32ave-005',...
                  'z-100_20um_256_32ave-007'};
    z_loc = [100, 50, 0, -50, -100];
    description = 'EL-10-30-C';

elseif data_source == 2
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\4_10_23\PSF_prairie2_25X_no_orb_ETLobj\';  
    data_path2 = {'PSF_ETLp2_25x_16z_01um_256_z150-006',...
                  'PSF_ETLp2_25x_16z_01um_256_z100-005',...
                  'PSF_ETLp2_25x_16z_01um_256_z50-004',...
                  'PSF_ETLp2_25x_16z_01um_256_z0-003',...
                  'PSF_ETLp2_25x_16z_01um_256_z-50-007',...
                  'PSF_ETLp2_25x_16z_01um_256_z-100-008',...
                  'PSF_ETLp2_25x_16z_01um_256_z-150-009'};
    z_loc = [150, 100, 50, 0, -50, -100, -150];
    description = 'EL-16-40-TC-Obj'; 
elseif data_source == 3
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\4_10_23\PSF_prairie2_25x_no_orb\';
    data_path2 = {'PSF_25x_16z_01um_256-001',...
                  'PSF_25x_16z_01um_256-002'};
              
    z_loc = [0, 0];
    description = 'Regular path';
elseif data_source == 4
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\4_10_23\PSF_prairie2_25x_no_orb_SLM_AO\';
    data_path2 = {'PSF_SLM_256_z16_01um_z150_AO-009',...
                  'PSF_SLM_256_z16_01um_z100_AO-007',...
                  'PSF_SLM_256_z16_01um_z50_AO-005',...
                  'PSF_SLM_256_z16_01um_z0-001',...
                  'PSF_SLM_256_z16_01um_z0-002',...
                  'PSF_SLM_256_z16_01um_z0-003',...
                  'PSF_SLM_256_z16_01um_z-50_AO-011',...
                  'PSF_SLM_256_z16_01um_z-100_AO-012',...
                  'PSF_SLM_256_z16_01um_z-150_AO-015'};
              
    z_loc = [150, 100, 50, 0, 0, 0, -50, -100, -150];
    description = 'SLM AO 4_10_23';
elseif data_source == 5
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\4_10_23\PSF_prairie2_25x_no_orb_SLM\';
    data_path2 = {'PSF_SLM_256_z16_01um_z150-008',...
                  'PSF_SLM_256_z16_01um_z100-006',...
                  'PSF_SLM_256_z16_01um_z50-004',...
                  'PSF_SLM_256_z16_01um_z0-001',...
                  'PSF_SLM_256_z16_01um_z0-002',...
                  'PSF_SLM_256_z16_01um_z0-003',...
                  'PSF_SLM_256_z16_01um_z-50-010',...
                  'PSF_SLM_256_z16_01um_z-100-013',...
                  'PSF_SLM_256_z16_01um_z-100-014',...
                  'PSF_SLM_256_z16_01um_z-150-016'};
              
    z_loc = [150, 100, 50, 0, 0, 0, -50, -100, -100, -150];
    description = 'SLM no AO';
elseif data_source == 6
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\4_24_23\';
    data_path2 = {'PSF_25x_150AO_32ave-003',...
                  'PSF_25x_100AO_32ave-004',...
                  'PSF_25x_50AO_32ave-007',...
                  'PSF_25x_0AO_32ave-008',...
                  'PSF_25x_-50AO_32ave-006',...
                  'PSF_25x_-100AO_32ave-005',...
                  'PSF_25x_-150AO_32ave-002'};
              
    z_loc = [150, 100, 50, 0, -50, -100, -150];
    description = 'SLM AO 4_24_23';
elseif data_source == 7
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\5_9_23\';
    data_path2 = {'z_scan_z0_AO-001',...
                  'z_scan_z150_AO-003',...
                  'z_scan_z200_AO-002'};
              
    z_loc = [0, 150, 200];
    description = 'SLM  AO 5_9_23';
elseif data_source == 8
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\5_11_23\';
    data_path2 = {'PSF_AO_z-250_16x_32ave-007',...
                  'PSF_AO_z-200_16x_32ave-008',...
                  'PSF_AO_z-150_16x_32ave-009',...
                  'PSF_AO_z-100_16x_32ave-010',...
                  'PSF_AO_z-50_16x_32ave-011',...
                  'PSF_AO_z0_16x_32ave-001',...
                  'PSF_AO_z50_16x_32ave-006',...
                  'PSF_AO_z100_16x_32ave-005',...
                  'PSF_AO_z150_16x_32ave-004',...
                  'PSF_AO_z200_16x_32ave-003',...
                  'PSF_AO_z250_16x_32ave-002'};
              
    z_loc = [-250, -200, -150, -100, -50, 0, 50, 100, 150, 200, 250];
    description = 'SLM  AO 5_11_23';
elseif data_source == 9
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\5_12_23\';
    data_path2 = {'PSF_z-250_AO_5_12_23_16x_32ave-012',...
                  'PSF_z-200_AO_5_12_23_16x_32ave-011',...
                  'PSF_z-150_AO_5_12_23_16x_32ave-010',...
                  'PSF_z-100_AO_5_12_23_16x_32ave-009',...
                  'PSF_z-50_AO_5_12_23_16x_32ave-008',...
                  'PSF_z0_AO_5_12_23_16x_32ave-006',...
                  'PSF_z0_noAO_5_12_23_16x_32ave-007',...
                  'PSF_z50_AO_5_12_23_16x_32ave-005',...
                  'PSF_z100_AO_5_12_23_16x_32ave-004',...
                  'PSF_z150_AO_5_12_23_16x_32ave-003',...
                  'PSF_z200_AO_5_12_23_16x_32ave-002',...
                  'PSF_z250_AO_5_12_23_16x_32ave-001'};
              
    z_loc = [-250, -200, -150, -100, -50, 0, 0, 50, 100, 150, 200, 250];
    description = 'SLM  AO 5_12_23';
elseif data_source == 10
    data_path = 'C:\Users\ys2605\Desktop\stuff\data\PSF_data\SLM_25x_AO\5_13_23\';
    data_path2 = {'PSF_z250_AO_5_12_23_16x_32ave-013',...
                  'PSF_z250_AO_5_12_23_16x_32ave-015',...
                  'PSF_z250_AO_5_12_23_16x_32ave-016',...
                  'PSF_z200_AO_5_12_23_16x_32ave-017',...
                  'PSF_z200_AO_5_12_23_16x_32ave-018',...
                  };
              
    z_loc = [250, 250, 250, 200, 200];
    description = 'SLM  AO 5_13_23';
end

%%
FOV_size = 497; % in um (from prairie2 25x no orb)
pix = 256;
zoom = 16;
dz = 0.1; % in um

FOV_half_size = 30;

min_dist_from_cent = 80;

baceline_prc = 98;
sm_std3 = [2, 2, 1];
interp_factor = 5;
intens_thresh = 0.2;

psf_fit = 'poly2';

min_dist = FOV_half_size * 2.5;

pix_size = FOV_size/zoom/pix;

do_mean = 0;

labs = {'y', 'x', 'z'};

manual_selection = 0;

dims_all = 1:3;
%%

plot_deets = 1;
plot_superdeets = 1;

num_fil = numel(data_path2);



z_loc2 = unique(z_loc);
num_loc = numel(z_loc2);


points_all = cell(num_loc,1);
fwhm_all = cell(num_loc,1);
intensity_5pct = cell(num_loc,1);
intensity_mean_max_max = cell(num_loc,1);

for n_loc = 1:num_loc

    fil_idx = find(z_loc == z_loc2(n_loc));
    
    num_fil = numel(fil_idx);
    points_all2 = {};
    fil_idx_all = [];
    data_all = {};
    %PSF_all = {};
    for n_fil = 1:num_fil
        n_fil2 = fil_idx(n_fil);
        data = f_collect_prairie_tiffs4([data_path, data_path2{n_fil2}]);
        
        data_all = [data_all; data];
        
        [x1, y1, z1] = size(data);
        
        cent_x = (x1)/2;
        cent_y = (y1)/2;
        
        pts2 = {};
        if manual_selection
            f1 = figure; 
            imagesc(mean(data,3))
            title('click to select psf');

            [x,y] = ginput(1);
            close(f1)

            points_all2 = [points_all2; [round(y), round(x)]];
            pts2 = [pts2; [y_coord, x_coord]];
            fil_idx_all = [fil_idx_all; n_fil];
        else
            mean_frame = mean(data,3);

            base = mean(mean_frame(:));
            std1 = std(mean_frame(:));

            mean_frame2 = mean_frame;
            look = 1;
            while look
                [val1, idx1] = max(mean_frame2(:));
                if val1 > (base + 5*std1)
                    [y_coord, x_coord] = ind2sub([x1, y1], idx1);

                    z_lice = data(y_coord, x_coord,:);

                    [~, idx1]  = max(z_lice);

                    % check if peak is too close to edge
                    y_min = max(y_coord - FOV_half_size, 1);
                    y_max = min(y_coord + FOV_half_size, y1);
                    x_min = max(x_coord - FOV_half_size, 1);
                    x_max = min(x_coord + FOV_half_size, x1);
                    
                    pts_all3 = cat(1,pts2{:});
                    
                    if min([idx1, z1 - idx1]) > z1/4
                        % check if far enough from cent
                        if sqrt((y_coord - cent_y)^2 + (x_coord - cent_x)^2) < min_dist_from_cent
                            % check if far from edge
                            if min([y_coord, y1 - y_coord]) > FOV_half_size
                                if min([x_coord, x1 - x_coord]) > FOV_half_size
                                    % check if points are not too close
                                    if ~numel(pts_all3) || (min(sqrt((y_coord - pts_all3(:,1)).^2 + (x_coord - pts_all3(:,2)).^2)) > min_dist)
                                        points_all2 = [points_all2; [y_coord, x_coord]];
                                        fil_idx_all = [fil_idx_all; n_fil];
                                        pts2 = [pts2; [y_coord, x_coord]];
                                        %PSF_all = [PSF_all; double(data(y_min:y_max, x_min:x_max,:))];
                                    end
                                end
                            end
                        end
                    end
                    
                    mean_frame2(y_min:y_max, x_min:x_max) = 0;
                else
                    look = 0;
                end
            end

        end
        num_pts2 = numel(pts2);
        
        if plot_deets
            figure; 
            imagesc(mean_frame); hold on; axis equal tight
            for n_pt = 1:num_pts2
                rectangle('Position',[pts2{n_pt}(2) - FOV_half_size, pts2{n_pt}(1) - FOV_half_size, 2*FOV_half_size+1, 2*FOV_half_size+1])
            end
            xlabel('x axis');
            ylabel('y axis')
            title(sprintf('selected points, z=%d; file %d', z_loc(n_loc), n_fil2));
            
            figure; 
            imagesc(squeeze(mean(data,2))); hold on; axis equal tight
            for n_pt = 1:num_pts2
                rectangle('Position',[round(z1/40), pts2{n_pt}(1) - FOV_half_size, z1-round(z1/20), 2*FOV_half_size+1])
            end
            xlabel('z axis');
            ylabel('y axis');
            title(sprintf('marg over x, z=%d; file %d', z_loc(n_loc), n_fil2));
        end
    end
    
    num_pts = numel(points_all2);

    fwhm_all2 = zeros(num_pts,3);
    intensity_5pct2 = zeros(num_pts,1);
    intensity_mean_max_max2 = zeros(num_pts,1);
    for n_pt = 1:num_pts
        
        name_tag_pt = sprintf('z %d; point %d; %s fit;', z_loc(n_loc), n_pt, psf_fit);
        
        data2 = data_all{fil_idx_all(n_pt)};
        [x1, y1, z1] = size(data2);
        
        prc1 = prctile(data2(:), baceline_prc);       
        baseline = mean(data2(data2(:)<prc1));
        % baseline = median(reshape(mean(data,3),1,[]));

        data3 = double(data2) - baseline;
        
        coord1 = points_all2{n_pt};
        y_min = max(coord1(1) - FOV_half_size, 1);
        y_max = min(coord1(1) + FOV_half_size, y1);
        x_min = max(coord1(2) - FOV_half_size, 1);
        x_max = min(coord1(2) + FOV_half_size, x1);
        
        data_cut = data3(y_min:y_max, x_min:x_max,:);
        
        x = (-FOV_half_size:FOV_half_size)'*pix_size;
        y = (-FOV_half_size:FOV_half_size)'*pix_size;
        z = linspace(-z1/2, z1/2, z1)'*dz;
        ax3 = {y, x, z};
        
%         if plot_deets
%             [x3, y3 ,z3] = meshgrid(x, y, z);
%             figure;
%             slice(x3, y3, z3, data_cut, 0, 0, 0);
%         end
        
        X = 1:(FOV_half_size*2+1);
        Xip = linspace(X(1), X(end), numel(X)*interp_factor-interp_factor+1);
        [Xq,Yq,Zq] = meshgrid(Xip, Xip, 1:z1);
        
        data_cut_sm = f_smooth_nd(data_cut, sm_std3);
        data_cut_smip = interp3(data_cut_sm, Xq,Yq,Zq, 'spline'); % 

        [siz1, siz2, num_z] = size(data_cut_smip);
        xy_locs = zeros(num_z,2);
        xy_intens = zeros(num_z,1);
        for n_z = 1:num_z
            temp_data = data_cut_smip(:,:,n_z);
            [xy_intens(n_z), idx1] = max(temp_data(:));
            [xy_locs(n_z, 2), xy_locs(n_z, 1)] = ind2sub([siz1, siz2], idx1);
        end
        
        xy_locs2 = Xip(xy_locs);
        
        xy_intens = xy_intens - min(xy_intens);
        max_intens = max(xy_intens);

        idx_intens2 = xy_intens > (max_intens*intens_thresh);
        
        
        
        zfit = (1:num_z)';
        yfx = fit(zfit(idx_intens2), xy_locs2(idx_intens2,1), psf_fit);
        yfy = fit(zfit(idx_intens2), xy_locs2(idx_intens2,2), psf_fit);
        
        if plot_deets
            figure; 
            subplot(2,1,1); hold on;
            plot(zfit, xy_locs2(:,1));
            plot(zfit, yfx(zfit));
            plot(xy_locs2(:,2));
            plot(zfit, yfy(zfit));
            subplot(2,1,2); hold on;
            plot(xy_intens);
            plot(idx_intens2*max_intens*intens_thresh);
            sgtitle(sprintf('%s; axial fit', name_tag_pt));

            figure; 
            subplot(2,1,1);hold on;
            imagesc(squeeze(mean(data_cut,2))); axis tight
            plot(zfit, yfy(zfit), 'r');
            ylabel('y')
            xlabel('z')
            subplot(2,1,2);hold on;
            imagesc(squeeze(mean(data_cut,1))); axis tight
            plot(zfit, yfx(zfit), 'r');
            ylabel('x')
            xlabel('z')
            sgtitle(sprintf('%s; axial fit', name_tag_pt));
        end
        data4 = zeros(FOV_half_size*2+1, FOV_half_size*2+1, num_z);
        pad2 = 2;
        mean_z = zeros(num_z,1);
        for n_z = 1:num_z
            x_cent = round(yfx(n_z) - FOV_half_size - 1 + coord1(2));
            y_cent = round(yfy(n_z) - FOV_half_size - 1 + coord1(1));
            
            x_min = x_cent-FOV_half_size;
            x_max = x_cent+FOV_half_size;
            y_min = y_cent-FOV_half_size;
            y_max = y_cent+FOV_half_size;
            
            x_min_pad = max([1 - x_min, 0]);
            x_max_pad = min([x1 - x_max, 0]);
            y_min_pad = max([1 - y_min, 0]);
            y_max_pad = min([y1 - y_max, 0]);
            
            data4((1+y_min_pad):(end-y_max_pad),(1+x_min_pad):(end-x_max_pad),n_z) = data3((y_min+y_min_pad):(y_max+y_max_pad), (x_min+x_min_pad):(x_max+x_max_pad),n_z);
            temp_data = data3((y_cent-pad2):(y_cent+pad2), (x_cent-pad2):(x_cent+pad2),n_z);
            mean_z(n_z) = mean(temp_data(:));
        end

        %figure; imagesc(mean(data4,3))
        %figure; plot(mean_z)
        
        fwhm_3d = zeros(3, 3);
        intens1 = zeros(3, 3);
        for n_d = 1:3

            dims2 = dims_all(dims_all ~= n_d);

            data_marg = mean(data4,n_d);
            
            if plot_deets
                figure();
                imagesc(ax3{dims2(2)}, ax3{dims2(1)}, squeeze(data_marg))
                title(sprintf('dims %d, %d', dims2(1), dims2(2)))
                axis equal tight;
                ylabel([labs{dims2(1)} ' axis'])
                xlabel([labs{dims2(2)} ' axis'])
                title(sprintf('%s; straightened', name_tag_pt));
            end

            for n_d2 = 1:2
                d2 = dims2(n_d2);
                d3 = dims2(dims2~=d2);

                x2 = squeeze(ax3{d3});
                if do_mean
                    data_marg2 = squeeze(permute(mean(data_marg, d2), [d3, d2]));
                    tag1 = 'mean';
                else
                    
                    data_marg4 = permute(data_marg, [d2, d3, n_d]);
                    
                    dims1 = size(data_marg4);
                    
                    [~, idx1] = max(data_marg4(:));
                    [idx_intens2, ~] = ind2sub(dims1, idx1);
                    
                    %data_marg3 = squeeze(mean(data_marg, d3));
                    %[~, idx2] = max(data_marg3);

                    data_marg2 = data_marg4(idx_intens2,:)';
                    tag1 = 'peak';
                end

                % fwhm = 2*sqrt(2*log(2)) * std
                % f(x) =  a1*exp(-((x-b1)/c1)^2)
                f = fit(x2, data_marg2, 'gauss1');
                fwhm1 = 2*sqrt(2*log(2)) * (f.c1/sqrt(2));
                fwhm_3d(n_d, d3) = fwhm1;

                intens1(n_d, d3) = f.a1;

                if plot_superdeets
                    figure; hold on;
                    plot(x2, data_marg2);
                    line([f.b1 - fwhm1/2, f.b1 + fwhm1/2], [f.a1/2, f.a1/2], 'color', 'k')
                    legend('data', 'fwhm');
                    plot(f);
                    title(sprintf('%s; dim %d %s; fwhm=%.2f', name_tag_pt, d3, tag1, fwhm1));
                    xlabel(labs{d3});
                    ylabel('intensity');
                end
            end
        end

        fwhm_all2(n_pt, :) = sum(fwhm_3d,1)/2;

        val1 = prctile(data2(:), 99);
        intensity_5pct2(n_pt) = mean(data2(data2>val1));
        intensity_mean_max_max2(n_pt) = sum(intens1(:))/6;
        
    end
    points_all{n_loc} = points_all2;
    fwhm_all{n_loc} = fwhm_all2;
    intensity_5pct{n_loc} = intensity_5pct2;
    intensity_mean_max_max{n_loc} = intensity_mean_max_max2;
end

%%

means = zeros(num_loc, 3);
sems = zeros(num_loc, 3);
for n_loc = 1:num_loc
    num_pts = size(fwhm_all{n_loc},1);
    means(n_loc,:) = mean(fwhm_all{n_loc},1);
    sems(n_loc,:) = std(fwhm_all{n_loc}, [], 1)/max(sqrt(num_pts-1),1);
end

colors1 = {'#0072BD' , '#D95319', '#EDB120'};
figure; hold on
for n_loc = 1:num_loc
    num_pts = size(fwhm_all{n_loc},1);
    for n_d = 1:3
        plot(z_loc2(n_loc), fwhm_all{n_loc}(:,n_d), 'o', 'color', colors1{n_d})
    end
end
for n_d = 1:3
    plot(z_loc2, means(:,n_d), '.-', 'color', colors1{n_d});
end
for n_d = 1:3
    errorbar(z_loc2, means(:,n_d), sems(:,n_d), 'color', colors1{n_d});
end
legend(labs);

title([description ' resolution; ' psf_fit], 'interpreter', 'none');
xlabel('z offset (um)');
ylabel('PSF size (um)');


%%
data_fwhm.fwhm = fwhm_all;
data_fwhm.points_all = points_all;
data_fwhm.intensity_5pct = intensity_5pct;
data_fwhm.intensity_mean_max_max = intensity_mean_max_max;
data_fwhm.axes = labs;
data_fwhm.z_loc = z_loc;
data_fwhm.z_loc_unique = z_loc2;
data_fwhm.fnames = data_path2;
data_fwhm.FOV_size = FOV_size; % in um
data_fwhm.FOV_half_size = FOV_half_size;
data_fwhm.pix = pix;
data_fwhm.zoom = zoom;
data_fwhm.dz = dz; 
data_fwhm.dxy = pix_size;
data_fwhm.description = description;

date1 = datetime;
save(sprintf('%s\\psf_data_%s_%d_%d_%d', data_path, description, date1.Year, date1.Month, date1.Day), 'data_fwhm');
