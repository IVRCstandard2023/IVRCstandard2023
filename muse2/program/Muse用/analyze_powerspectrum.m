function power = analyze_powerspectrum(data_eeg, Fs, freqBand)

        % �f�g�����h
        detrended_eeg = detrend(data_eeg, 2);
        
        % ���[�p�X
        filtered_eeg = lowpass(detrended_eeg, 30, Fs);
        
        % �n�~���O��
        hw = hamming(length(filtered_eeg))';
        filtered_eeg = filtered_eeg .* hw;
 
        % �s���I�h�O���� �p���[�X�y�N�g�����x���
        N = length(filtered_eeg);
        xdft = fft(filtered_eeg);
        xdft = xdft(1:N/2+1);
        psdx = (1/(Fs*N)) * abs(xdft).^2;
        psdx(2:end-1) = 2*psdx(2:end-1);
        freq = 0:Fs/N:Fs/2;
        acf = 1/(sum(hw)/N);
        psdx = psdx .* acf;
        pow_fft = pow2db(psdx);
        
        % �o���h�p���[�v�Z
        power = bandpower(psdx, freq, freqBand, 'psd'); % �A���t�@�g 8 ~ 13Hz
end

