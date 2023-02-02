% test to stimulate a grid

% Load calibration file
calibrationFile = 'JP_Aug_2019.mat';
load(['Calibration files\' calibrationFile]);


% Set spots grid to burn
grid = 8:60:256;
[X,Y] = meshgrid(grid,grid);
xy = [X(:) Y(:)];
nPoints = size(xy,1);

for i = 1:nPoints
    % Get single point
    xyz = [xy(1,:) 0];

    % Get mask
    xyzp = Get_Mask_SLM(xyz,calibration);

    % Apply weight
    weight = ones(nPoints,1);

    cell_SLM(:,:,i) = Phase_Hologram_SLM(xyzp,weight,calibration);
end


for i=1:25
    Load_Image_SLM(idSLM,cell_SLM(:,:,i))
    input('press enter to continue...')
    Load_Image_SLM(idSLM,image)
end

Load_Image_SLM(idSLM,cell_SLM(:,:,1))