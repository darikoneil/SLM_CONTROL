path1 = '\\PRAIRIE2000\p2f\Yuriy\AO\12_6_20\test-001';


exist(path1, 'dir')


files1 = dir([path1 '\' '*RAWDATA*']);

fnames = [files1.name];

load()


fileID = fopen([path1 '\' fnames],'r');

I=fread(fileID); 

Ir = reshape(I, 256, 256, []); # this is probably image dimensions

figure; imagesc(mean(Ir,3))

32*5 # this is probably frame averaging