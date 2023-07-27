
addpath('./utilities');              % ライブラリをパスに追加
addpath(genpath('./liblsl-Matlab')); % LSL通信ライブラリをパスに追加


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% EDIT HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% LSLのストリーム名
% PetalStreamのNameを設定する
streamName = 'PetalStream';

% FFT解析パラメータ
T               = 7;                % 時間窓長(s)
intarval        = 1;                % FFT解析間隔(s)
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
        power_alpha = bandpower(psdx, freq, [8.0 13.0], 'psd');                                  % アルファバンド(8~13Hz)のパワー
        power_left  = bandpower(psdx, freq, [ssvep_freq_left-0.5 ssvep_freq_left+0.5], 'psd');   % 左側SSVEPの周波数のバンドパワー
        power_right = bandpower(psdx, freq, [ssvep_freq_right-0.5 ssvep_freq_right+0.5], 'psd'); % 右側SSVEPの周波数のバンドパワー
        
        
        % アルファバンドのパワーをコマンドラインに出力
        fprintf('Alpha Band Power: %f\n', power_alpha);
        % ==== スペクトルプロット更新 ==== %
        update_plot_bandpower(plot_bandpower, timeStamp, power_alpha, power_left, power_right)
        
        
        
        % ==== 操作データをゲームに送信 ==== %+
        % jump_state:ジャンプに使用
        % - しきい値を超えていれば1(ジャンプ)
        % - その他は0(何もしない)
        if power_alpha > threshold_alpha
            jump_state = 1;
        else
            jump_state = 0;
        end
        
        % move_state:横移動に使用
        % - 左側SSVEPのパワーがしきい値を超えていれば1(左移動)
        % - 右側SSVEPが超えていれば2(右移動)
        % - その他は3(停止)
        if power_right > threshold_right
            move_state = 2;
        elseif power_left > threshold_left
            move_state = 1;
        else
            move_state = 3;
        end
        
        % ジャンプと横移動の操作データをゲーム実行PCに送信
        % controlMode
        % - 1の場合:ジャンプの操作を送信する
        % - 2の場合:横移動の操作を送信する
        if isEnabled
            
            if controlMode == 1
                write(udp_send, [jump_state power_alpha ], 'double', remote_ip, 55555);
            elseif controlMode == 2
                write(udp_send, [move_state power_left power_right], 'double', remote_ip, 55555);
            end
        end
        
        
        
        % ==== 次の解析タイミングを更新 ==== %
        timestep = timestep + intarval;
        
        % 計測時間が経過したら終了する
        if timeStamp > measurementTime
            break;
        end
    end
    
end



