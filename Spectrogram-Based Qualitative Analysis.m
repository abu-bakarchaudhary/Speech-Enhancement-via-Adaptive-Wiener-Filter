clc;

fileIdx = 1; 
[s_clean, fs] = audioread(fullfile(cleanDir, cFiles(fileIdx).name));
[s_noisy, ~]  = audioread(fullfile(noisyDir, [cFiles(fileIdx).name(1:4), '_airport_sn5.wav']));
[s_enhanced, ~] = audioread(fullfile(enhancedDir, ['wiener_', cFiles(i).name]));

len = min([length(s_clean), length(s_noisy), length(s_enhanced)]);
s_clean = s_clean(1:len); s_noisy = s_noisy(1:len); s_enhanced = s_enhanced(1:len);

figure('Name', 'Task 4: Comparative Spectrogram Analysis', 'Color', 'w', 'Position', [100, 100, 900, 800]);

subplot(3,1,1);
spectrogram(s_clean, hamming(256), 128, 512, fs, 'yaxis');
title('A: Clean Speech (Reference Signal)');
colorbar; colormap jet;
subplot(3,1,2);
spectrogram(s_noisy, hamming(256), 128, 512, fs, 'yaxis');
title('B: Noisy Speech (Input - Airport Noise @ 5dB)');
colorbar; colormap jet;
subplot(3,1,3);
spectrogram(s_enhanced, hamming(256), 128, 512, fs, 'yaxis');
title(['C: Enhanced Speech (Adaptive Wiener Filter - SNR Imp: 1.0137 dB)']);
colorbar; colormap jet;

saveas(gcf, 'Task4_Spectrogram_Comparison.fig');
saveas(gcf, 'Task4_Spectrogram_Comparison.png');

fprintf('Task 4 complete. Visual proof saved as .fig and .png for the report.\n');