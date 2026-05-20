clc; clear; close all;

cleanDir = 'Clean/';   
noisyDir = 'Noisy/';   
enhancedDir = 'Enhanced/';
if ~exist(enhancedDir, 'dir'), mkdir(enhancedDir); end

cFiles = [dir(fullfile(cleanDir, '*.wav')); dir(fullfile(cleanDir, '*.WAV'))];
numFiles = length(cFiles);

if numFiles == 0
    error('No files found! Check your "Clean" folder.');
end

fprintf('--- Applying Adaptive Wiener Filter to %d files ---\n', numFiles);

for i = 1:numFiles
    [s_noisy, fs] = audioread(fullfile(noisyDir, [cFiles(i).name(1:4), '_airport_sn5.wav']));
    
    N = 240; 
    localMean = movmean(s_noisy, N);
    localVar  = movvar(s_noisy, N);
    
    noiseVariance = mean(localVar(1:min(800, length(localVar)))); 
    
    gain = max(0, (localVar - noiseVariance) ./ (localVar + eps));
    enhancedSig = localMean + gain .* (s_noisy - localMean);
    
    [b, a] = butter(6, 400/(fs/2), 'high');
    enhancedSig = filtfilt(b, a, enhancedSig);
    
    savePath = fullfile(enhancedDir, ['wiener_', cFiles(i).name]);
    audiowrite(savePath, enhancedSig, fs);
    
    if mod(i, 5) == 0, fprintf('Processed %d/%d files...\n', i, numFiles); end
end
fprintf('Task 2 Complete! Enhanced files saved in /Enhanced folder.\n');