% Open and send an image to the SLM

%% Open SLM
tic
disp('Open SLM...')

idSLM = Open_SLM(1); % 3 by default

% Load a LUT file
%LUTfileName='linear.lut';               % default
LUTfileName='gamma_cal_1040nm_BNS.lut';   % spirit   
calllib('interfaceSLM', 'LoadLUTFile', 1, LUTfileName);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])


%% Turn on the power
tic
disp('Turning ON the SLM...')
calllib('interfaceSLM', 'SLMPower', true);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Load images
tic
disp('Loading blank image...')
inicializationImage='blank.bmp';
image = double(imread(['Images\' inicializationImage]));
Load_Image_SLM(idSLM,image)

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Load calibration file
tic
disp('Load calibration file...')

%calibrationFile = '20171210_Prairie_25X_2X_256X256_Galvo_full.mat';
calibrationFile = 'JP_Aug_2019.mat';
load(['Calibration files\' calibrationFile]);

t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Creat a mask of coordinates
tic
disp('Create a mask...')

% test coordinates
xy = [256 256]; % pixels
%xy = [1 1]; % pixels
% x=8:60:256;
% [X,Y] = meshgrid(x,x);
% xy = [X(:) Y(:)];

nPoints = size(xy,1);
z = zeros(nPoints,1);                    % [um]

z = z*1e-6;         % um -> m
xyz = [];
xyz(:,1:2) = xy;
xyz(:,3) = z;

% Get mask
xyzp = Get_Mask_SLM(xyz,calibration);

% Apply weight
correctWeight = false;
if correctWeight
    weight = Correct_XYZ_Weights(xyzp,calibration);
else
    weight = ones(nPoints,1);
end

phase = Phase_Hologram_SLM(xyzp,weight,calibration);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])


%% Load the mask
tic
disp('Load the mask...')
% JP correctedPhase = BNS_SLM_RegisterBMP(phase);
Load_Image_SLM(idSLM,phase)
% SLMLoadTime=0.05;    % SLM load time
% pause(SLMLoadTime);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Close SLM
tic
disp('Closing SLM...')
Close_SLM()
t=toc; disp(['   Done (' num2str(t) ' seconds)'])

%% Save phase mask
imwrite(uint8(phase),"C:\Users\rylab\Desktop\test.bmp")
%% initialize SLM
% when initializing the BNS SLM, the current directory should be this one
%JP BNSSLMInitializationPath='C:\Users\yustelab\Documents\MATLAB\SLMGUI_v2_0';    % for Prairie  
%SLMInitializationImageMat=[]; % 'PhasefrontCorrectionZonal.mat'
%SLMWavefrontCorrectionZonalDeflect=[100 100 0; -100 -100 0; 100 -100 0; -100 100 0];
% SLM to PMT calibration
%SLM2PMTtransformMatrixFileName='new_SLM_PMT_TransformMatrix_25X.mat';
%SLM_handles = BNS_SLM_Initialize(calibratedLUTfileName);

% f_SLMActivation_Calibration( SLM_handles, [SLMPreset 0], weight, objectiveNA );  
%{
tic
disp('SLM activation without calibration...')
xyzp = [0 -9 0];
weight = 1;

% -------Create SLM phase pattern-------    
% SLM phase pattern, which can be directly applied to SLM
phase = f_SLM_PhaseHologram( xyzp, SLMm, SLMn,  weight, objectiveNA, objectiveRI, illuminationWavelength );

% -------Add adaptive optics system correction
if ~isempty(SLMInitializationImageMat)
    load(SLMInitializationImageMat);
    phase=phase+correctedWavefront;
end
phase=mod(phase,2*pi);

% -------SLM activation-------     
phase = 255.*( phase )./(2*pi);            % BNS phase range 0~255
correctedPhase = phase;

% output to SLM and take image
%%LOAD IMAGE (BNS_SLM_LoadImage( correctedPhase, SLM_handles );)
correctedPhase = mod(correctedPhase + wavefront, 256);
pImage = libpointer('uint8Ptr', correctedPhase); 
calllib('SLMlib', 'WriteImage', 1, pImage, 512);
pause(SLMLoadTime);
t=toc; disp(['   Done (' num2str(t) ' seconds)'])
%}
