function data = PrairieLink_ReadRawFile(varargin)
% Read binary file generated by PrairieLinkRawDataStream
% Lloyd Russell 2017
% Varargin:
% 1: full path to file
% 2: first frame to read
% 3: number of frames to read

% To do:
% * allow direct resaving to tiff?


% Open the file
if nargin
    filePath = varargin{1};
else
    [fileName, pathName] = uigetfile('*.bin');
    filePath = [pathName filesep fileName];
end

fileID = fopen(filePath);

% Read 'header' to get dimensions
pixelsPerLine = fread(fileID, 1, 'uint16');
linesPerFrame = fread(fileID, 1, 'uint16');
samplesPerFrame = pixelsPerLine*linesPerFrame;

% Find number of frames in file
fileInfo = dir(filePath);
numBytes = fileInfo.bytes;
totalNumFrames = ((numBytes/2) - 2) / samplesPerFrame;          % divide by 2 because format is uint16; subtract 2 because file header
% Parameters for frame range
startOnFrame = 1;
numFramesToRead = totalNumFrames;
if nargin > 1
    startOnFrame = varargin{2};
    if nargin > 2
        numFramesToRead = varargin{3};
    end
end

% Do check for NumFramesToRead vs totalNumFrames here
endOnFrame = startOnFrame + numFramesToRead;
if endOnFrame > totalNumFrames
    numFramesToRead = totalNumFrames - startOnFrame + 1;
end

% Read data
startOnByte = (((startOnFrame-1) * samplesPerFrame) +2) *2;  % plus 2 because header size, x2 because 1 uint16 is 2 bytes
numCharsToRead = (numFramesToRead*samplesPerFrame);          % note size in bytes of char defined by fread function argument

fseek(fileID, startOnByte, 'bof');
data = fread(fileID, numCharsToRead, '*uint16');

% Close the file
fclose(fileID);

% Reshape data into frame array
numSamples = numel(data);
numFrames = numSamples / (pixelsPerLine*linesPerFrame);
data = reshape(data, pixelsPerLine, linesPerFrame, numFrames);
data = permute(data, [2 1 3]);
