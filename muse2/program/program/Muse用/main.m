
% LSL通信ライブラリをパスに追加
addpath(genpath('./liblsl-Matlab'));


% LSLのストリーム名
% PetalStreamのNameを設定する
streamName = 'PetalStream';


% FFT解析パラメータ
T = 4;          % 時間窓長(s)
intarval = 0.5;	% FFT解析間隔(s)
Fs = 256;       % Muse2のサンプリングレート(Hz) 256から変更しない


% ロボット制御パラメータ
remote_ip = '192.168.1.90';	% ロボット制御PCのIPアドレス
udp_send=udpport;           % UDPソケット
linearVelocity = 0;         % ロボットの前後移動速度
angularVelocity = 0;        % ロボットの回転速度
threshold_alpha = 10;       % アルファバンドパワーのしきい値


% 脳波データ格納用変数
lsl_eeg = [];   % raw EEGデータ
lsl_time = [];  % タイムスタンプ
bandPower = []; % バンドパワーデータ


% バンドパワープロットの設定
figure();
anim_power = animatedline;
ylim([0 30]);
title('Alpha Band Power');
xlabel('Time(s)');
ylabel('Power(dB)');
set(gca,'FontSize',12);
drawnow;


% LSL通信のレシーバーを作成
inlet = create_lsl_inlet(streamName);


% LSL通信開始
inlet.open_stream();


try
    
    tic;
    timestep = T;
    while toc < 60

        % 一定間隔ごとにEEGデータを取得し解析を行う
        timeStamp = toc;
        if timeStamp > timestep

            % ==== Muse2からEEGデータ取得 ==== %
            % LSLバッファからEEGデータ取得
            [samples,~] = inlet.pull_chunk();

            % データに付け足す
            lsl_eeg = horzcat(lsl_eeg, samples);
            lsl_time = (0:length(lsl_eeg)-1)/Fs;

            % 受信したデータから直近の時間窓長分のデータを抽出
            [raw_time, raw_eeg] = extract_lsl_data(lsl_time, lsl_eeg, T*Fs);

            
            
            % ==== バンドパワー解析 ==== %
            % バンドパワー計算
            alphaPower = analyze_powerspectrum(mean(raw_eeg([1 4], :)), Fs, [8 13]);
            betaPower = analyze_powerspectrum(mean(raw_eeg([2 3], :)), Fs, [13 30]);
            % thetaPower = analyze_powerspectrum(mean(raw_eeg([1 4], :)), Fs, [4 8]);
            % deltaPower = analyze_powerspectrum(mean(raw_eeg([1 4], :)), Fs, [0.5 4]);
            % gammaPower = analyze_powerspectrum(mean(raw_eeg([2 3], :)), Fs, [30 45]);
            bandPower = horzcat(bandPower, [timeStamp; alphaPower; betaPower]);

            % プロット更新
            addpoints(anim_power, bandPower(1, end), bandPower(2, end));
            xlim([bandPower(1, end)-30 bandPower(1, end)+1]);
            drawnow;

            
            
            % ==== ロボットへ指令値を送信 ==== %
            % アルファバンドパワーがしきい値以上であれば回転、そうでなければ停止
            if alphaPower > threshold_alpha
                angularVelocity = 1.0;
            else
                angularVelocity = 0.0;
            end
            % ロボット制御PCにデータ送信
            oscsend_udpport(udp_send, remote_ip, 5005, '/brainI','ff', [angularVelocity linearVelocity]);

            
            
            % 次の解析タイミングを更新
            timestep = timestep + intarval;
        end
    end
    
    % ロボットを停止させる
    stop_turtlebot(udp_send, remote_ip, 50);
    
    
catch ME
    % ロボットを停止させる
    stop_turtlebot(udp_send, remote_ip, 50);
    
    rethrow(ME);    
end
