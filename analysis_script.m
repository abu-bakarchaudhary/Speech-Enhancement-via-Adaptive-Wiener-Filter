clc; clear; close all;

fprintf('Please select your "Clean" folder...\n');
cleanDir = uigetdir(pwd, 'Select the CLEAN folder');
fprintf('Please select your "Noisy" folder...\n');
noisyDir = uigetdir(pwd, 'Select the NOISY folder');

if isequal(cleanDir,0) || isequal(noisyDir,0)
    error('Folder selection cancelled. Please run again and select folders.');
end

cFiles = [dir(fullfile(cleanDir, '*.wav')); dir(fullfile(cleanDir, '*.WAV'))];
nFiles = [dir(fullfile(noisyDir, '*.wav')); dir(fullfile(noisyDir, '*.WAV'))];

numFiles = min(length(cFiles), length(nFiles));
if numFiles == 0
    error('Still no files found! Ensure files end in .wav or .WAV');
end

results = table('Size',[numFiles 4], ...
    'VariableTypes',{'string','double','double','double'}, ...
    'VariableNames',{'FileName','Baseline_SNR','Baseline_MSE','Baseline_PESQ'});

fprintf('--- Processing %d Pairs ---\n', numFiles);

for i = 1:numFiles
    % Load Files
    [cleanSig, fs] = audioread(fullfile(cleanDir, cFiles(i).name));
    [noisySig, ~]  = audioread(fullfile(noisyDir, nFiles(i).name));
    
    len = min(length(cleanSig), length(noisySig));
    cleanSig = cleanSig(1:len);
    noisySig = noisySig(1:len);
    
    results.Baseline_SNR(i) = snr(cleanSig, noisySig - cleanSig); 
    results.Baseline_MSE(i) = mean((cleanSig - noisySig).^2);
    results.FileName(i) = string(cFiles(i).name);
    
    if i == 1 || i == 15 || i == 30
        figure('Name', ['Baseline: ', cFiles(i).name]);
        subplot(2,1,1); 
        [p_n, f] = periodogram(noisySig, [], len, fs);
        plot(f, 10*log10(p_n), 'r'); 
        title(['Power Spectral Density: ', nFiles(i).name]);
        grid on; ylabel('dB/Hz'); xlabel('Frequency (Hz)');
        
        subplot(2,1,2); 
        spectrogram(noisySig, hamming(256), 128, 256, fs, 'yaxis');
        title('Spectrogram (Noise Analysis)');
    end
    
    fprintf('Processed [%d/%d]: %s\n', i, numFiles, cFiles(i).name);
end

disp(results);
writetable(results, 'Baseline_Metrics.csv');