function update_plot_raweeg(plot_raweeg, timeStamp, eeg_ch1, eeg_ch2, eeg_ch3,eeg_ch4)
% バンドパワープロットの更新
% プロットに最新のデータ点を追加する

    plot_ch1 = plot_raweeg(1);
    plot_ch2  = plot_raweeg(2);
    plot_ch3 = plot_raweeg(3);
    plot_ch4 = plot_raweeg(3);

    addpoints(plot_ch1, timeStamp, eeg_ch1)
    addpoints(plot_ch2,  timeStamp, eeg_ch2)
    addpoints(plot_ch3, timeStamp, eeg_ch3)
    addpoints(plot_ch4, timeStamp, eeg_ch4)
    xlim([timeStamp-30 timeStamp+1]);
    %ylim([0 5])
    drawnow;
end
