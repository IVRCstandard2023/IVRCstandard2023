% LSLのストリーム名
% PetalStreamのNameを設定する
streamName = 'PetalStream';

% EEGデータ格納用変数
lsl_eeg = []; % raw EEGデータ
lsl_time = []; % タイムスタンプ

% LSL通信のレシーバーを作成
inlet = create_lsl_inlet(streamName);

% LSL通信開始
inlet.open_stream();

% プロット作成
figure;
hold on;

tic;
while true
    % Muse2からEEGデータ取得
    [samples,~] = inlet.pull_chunk();

    % データに付け足す
    lsl_eeg = horzcat(lsl_eeg, samples);
    lsl_time = (0:length(lsl_eeg)-1)/256;  % Muse2のサンプリングレートは256Hzです。

    % 受信したデータをプロット
    plot(lsl_time, lsl_eeg);
    drawnow;

    % ここで時間を制限することもできます。
    % 例えば、10秒間だけデータを収集したい場合は以下のようにします。
    if toc > 1000
        break;
    end
end

% プロットの設定
xlabel('Time (s)');
ylabel('EEG (μV)');
title('Real-time EEG data');
hold off;
