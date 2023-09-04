addpath('./utilities');              % ライブラリをパスに追加
addpath(genpath('./liblsl-Matlab')); % LSL通信ライブラリをパスに追加


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSLのストリーム名
% PetalStreamのNameを設定する
streamName = 'PetalStream';

% FFT解析パラメータ
T               = 7;                % 時間窓長(s)
intarval        = 0.3;                % FFT解析間隔(s)
measurementTime = 10000;              % 脳波の計測時間

% ゲーム制御パラメータ
controlMode      = 2;              % controlModeが1の場合:ジャンプ操作、2の場合:横移動操作
remote_ip        = 'localhost'; % ゲーム実行PCのIPアドレス
isEnabled        = true;           % ゲームに操作データを送信するか

ssvep_freq_left  = 10;              % 左側SSVEPの周波数
ssvep_freq_right = 12;              % 右側SSVEPの周波数

threshold_alpha  = 15;              % アルファバンドパワーのしきい値
threshold_left   = 5;               % 左側SSVEPのパワーのしきい値
threshold_right  = 8;               % 右側SSVEPのパワーのしきい値
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% FFT解析パラメータ
Fs              = 256;              % Muse2のサンプリングレート(Hz) 256から変更しない

% ゲーム制御パラメータ
udp_send         = udpport;         % UDPソケット

% 脳波データ格納用変数
lsl_eeg             = []; % raw EEGデータ
lsl_time            = []; % タイムスタンプ


% バンドパワープロットの設定
plot_bandpower = create_plot_bandpower();

% LSL通信のレシーバーを作成
inlet = create_lsl_inlet(streamName);


% LSL通信開始
inlet.open_stream();

tic;
timestep = T;
while true

    % 一定間隔ごとにEEGデータを取得し解析を行う
    timeStamp = toc;
    if timeStamp > timestep

        % ==== Muse2からEEGデータ取得 ==== %
        % LSLバッファからデータ取得
        [samples,~] = inlet.pull_chunk();

        % データに付け足す
        lsl_eeg = horzcat(lsl_eeg, samples);
        lsl_time = (0:length(lsl_eeg)-1)/Fs;
        
        % 受信したデータから直近の時間窓長分のデータを抽出
        [raw_time, raw_eeg] = extract_lsl_data(lsl_time, lsl_eeg, T*Fs);
        
        
        
        % ==== スペクトル解析 ==== %
        % デトレンド
        detrended_eeg = detrend(mean(raw_eeg([1 4], :)), 2);
        
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
        
        
        
        % ==== バンドパワーの計算 ==== %
        power_delta = bandpower(psdx, freq, [0.1 4.0], 'psd');   % デルタバンド(0.1~4Hz)のパワー
        power_theta = bandpower(psdx, freq, [4.0 8.0], 'psd');   % テータバンド(4~8Hz)のパワー
        power_alpha = bandpower(psdx, freq, [8.0 13.0], 'psd');  % アルファバンド(8~13Hz)のパワー
        power_beta  = bandpower(psdx, freq, [13.0 30.0], 'psd'); % ベータバンド(13~30Hz)のパワー
        power_gamma = bandpower(psdx, freq, [30.0 100.0], 'psd');% ガンマバンド(30~100Hz)のパワー
        
        
        % 各バンドのパワーをコマンドラインに出力
        fprintf('Delta Band Power: %f\n', power_delta);
        fprintf('Theta Band Power: %f\n', power_theta);
        fprintf('Alpha Band Power: %f\n', power_alpha);
        fprintf('Beta Band Power: %f\n', power_beta);
        fprintf('Gamma Band Power: %f\n', power_gamma);
        % ==== スペクトルプロット更新 ==== %
        update_plot_bandpower(plot_bandpower, timeStamp, power_delta, power_theta, power_alpha, power_beta, power_gamma);
        
        
        
        % ==== 操作データをゲームに送信 ==== %
        %alpha波のデータをゲーム実行PCに送信
        if isEnabled
            write(udp_send, power_alpha, 'double', remote_ip, 55555);
        end
        
        
        
        % ==== 次の解析タイミングを更新 ==== %
        timestep = timestep + intarval;
        
        % 計測時間が経過したら終了する
        if timeStamp > measurementTime
            break;
        end
    end
    
end
