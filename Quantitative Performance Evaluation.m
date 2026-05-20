T3_Results = table('Size',[numFiles 4], ...
    'VariableTypes',{'string','double','double','double'}, ...
    'VariableNames',{'FileName','Noisy_SNR_dB','Enhanced_SNR_dB','Improvement_dB'});

fprintf('\n--- Generating Quantitative Evaluation Table ---\n');

for i = 1:numFiles
    s_clean = audioread(fullfile(cleanDir, cFiles(i).name));
    s_noisy = audioread(fullfile(noisyDir, [cFiles(i).name(1:4), '_airport_sn5.wav']));
    s_enhanced = audioread(fullfile(enhancedDir, ['wiener_', cFiles(i).name]));
    
    len = min([length(s_clean), length(s_noisy), length(s_enhanced)]);
    c = s_clean(1:len); 
    n = s_noisy(1:len);
    e = s_enhanced(1:len);
    
    snr_n = snr(c, n - c);
    snr_e = snr(c, e - c);
    
    T3_Results.FileName(i) = string(cFiles(i).name);
    T3_Results.Noisy_SNR_dB(i) = snr_n;
    T3_Results.Enhanced_SNR_dB(i) = snr_e;
    T3_Results.Improvement_dB(i) = snr_e - snr_n;
end

disp('========================================================');
disp('            CEP TASK 3: PERFORMANCE SUMMARY             ');
disp('========================================================');
disp(T3_Results);

avg_imp = mean(T3_Results.Improvement_dB);
fprintf('--------------------------------------------------------\n');
fprintf('  FINAL AVERAGE SNR IMPROVEMENT: %.4f dB  \n', avg_imp);
fprintf('--------------------------------------------------------\n');

writetable(T3_Results, 'CEP_Task3_Results.csv');