function power = analyze_powerspectrum(data_eeg, Fs, freqBand)

        % デトレンド
        detrended_eeg = detrend(data_eeg, 2);
        
        % ローパス
        filtered_eeg = lowpass(detrended_eeg, 30, Fs);
        
        % ハミング窓
        hw = hamming(length(filtered_eeg))';
        filtered_eeg = filtered_eeg .* hw;
 
        % ピリオドグラム パワースペクトル密度解析
        N = length(filtered_eeg);
        xdft = fft(filtered_eeg);
        xdft = xdft(1:N/2+1);
        psdx = (1/(Fs*N)) * abs(xdft).^2;
        psdx(2:end-1) = 2*psdx(2:end-1);
        freq = 0:Fs/N:Fs/2;
        acf = 1/(sum(hw)/N);
        psdx = psdx .* acf;
        pow_fft = pow2db(psdx);
        
        % バンドパワー計算
        power = bandpower(psdx, freq, freqBand, 'psd'); % アルファ波 8 ~ 13Hz
end

