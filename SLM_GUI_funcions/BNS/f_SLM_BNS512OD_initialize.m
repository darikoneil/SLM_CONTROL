function ops = f_SLM_BNS512OD_initialize(ops)
% regionalLUTfileName, SLMInitializationImageFileName 
% [ sdk ]
%% SLM params
if ~exist('ops', 'var')
    ops = struct;
end

%% directories
% library path
if ~isfield(ops, 'SLM_SDK_dir') % where is SDK
    ops.SLM_SDK_dir = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
end

if ~isfield(ops, 'lut_dir') % where are lut files
    ops.lut_dir = '\..\SLM_calibration\lut_calibration\'; % regionalLUTfileName goes here
end

%%
if ~isfield(ops, 'lut_dir')
    ops.lut_dir = 'lut_calibration\';
end

%% Lut global
% the 512 BNS with OD needs to upload regional lut during creation for OD
% to work, otherwise it will be disabled per Anna
% for new BNS 1920 can send null, because it has no OD technically

if isfield(ops, 'init_lut_fname')   % use linear if not specified
    init_lut_fpath = [ops.lut_dir, '\', ops.init_lut_fname];
    if ~exist(init_lut_fpath, 'file')
        fprintf('init lut file missing, using null: %s\n',init_lut_fpath);
        init_lut_fpath = libpointer('string');
    end
else
    %disp('No regional provided for BNS512OD, using null');
    init_lut_fpath = libpointer('string');
end

%% path to blank calibration image for BNS 512 OD
if ~isfield(ops, 'cal_image_path')   % use linear if not specified
    %disp('Blank calibration image was not passed for BNS512OD, using zeros');
    ops.cal_image = zeros(512, 512, 'uint8');
else
    %% load blank calibration image
    if exist(ops.cal_image_path, 'file')
        ops.cal_image = imread(ops.cal_image_path);
    else
        %disp('Blank calibration image does not exist, using zeros');
        ops.cal_image = zeros(512, 512, 'uint8');
    end
end


%% Load the DLL
% Blink_C_wrapper.dll, Blink_SDK.dll, ImageGen.dll, FreeImage.dll and wdapi1021.dll
% should all be located in the same directory as the program referencing the
% library

%ops.path_library = 'C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK';
%addpath(ops.SLM_SDK_dir);

if ~libisloaded('Blink_C_wrapper')
    loadlibrary([ops.SLM_SDK_dir, '\Blink_C_wrapper.dll'], [ops.SLM_SDK_dir, '\Blink_C_wrapper.h']);
end

%% Basic parameters for calling Create_SDK for BNS 512 with OD
ops.bit_depth = 8;
ops.num_boards_found = libpointer('uint32Ptr', 0);
ops.constructed_okay = libpointer('int32Ptr', 0);
ops.is_nematic_type = 1; %  for SLMs built with Nematic Liquid Crystal
ops.RAM_write_enable = 1;
ops.use_GPU = 1;    % this is specific to ODP slms (512) (and imagegen)
ops.max_transients = 10; % this is specific to ODP slms (512)
ops.true_frames = 3;
ops.slm_resolution = 512;
ops.wait_For_Trigger = 0; % This feature is user-settable; use 1 for 'on' or 0 for 'off'
ops.external_Pulse = 0;
ops.timeout_ms = 5000;


%%
calllib('Blink_C_wrapper', 'Create_SDK', ops.bit_depth, ops.num_boards_found, ops.constructed_okay,...
                    ops.is_nematic_type, ops.RAM_write_enable, ops.use_GPU, ops.max_transients, init_lut_fpath);
               
if ops.constructed_okay.value ~= 1
    ops.SDK_created = 0;
    disp('Blink SDK was not successfully constructed');
    disp(calllib('Blink_C_wrapper', 'Get_last_error_message'));
    calllib('Blink_C_wrapper', 'Delete_SDK');
else
    %%
    ops.board_number = 1;
    ops.SDK_created = 1;
    disp('Blink SDK was successfully constructed');
    fprintf('Found %u SLM controller(s)\n', ops.num_boards_found.value);
    disp(calllib('Blink_C_wrapper', 'Get_last_error_message'));
    
    % Set the basic SLM parameters
    calllib('Blink_C_wrapper', 'Set_true_frames', ops.true_frames);
    % A blank calibration file must be loaded to the SLM controller
    % calllib('Blink_SDK_C', 'Write_cal_buffer', ops.sdk, 1, ops.cal_image);
    % A linear LUT must be loaded to the controller for OverDrive Plus
    calllib('Blink_C_wrapper', 'Load_linear_LUT', ops.board_number);
   

    % Turn the SLM power on
    calllib('Blink_C_wrapper', 'SLM_power', 1);
    
    %allocate arrays for our images

    ops.height = calllib('Blink_C_wrapper', 'Get_image_height', ops.board_number);
    ops.width = calllib('Blink_C_wrapper', 'Get_image_width', ops.board_number);
    
    %calllib('Blink_SDK_C', 'Is_overdrive_available', ops.sdk)
    %calllib('Blink_C_wrapper', 'Get_version_info')
end

end