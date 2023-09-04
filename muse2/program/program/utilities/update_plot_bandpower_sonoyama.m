function update_plot_bandpower_sonoyama(plot_bandpower, timeStamp, power_delta, power_theta, power_alpha, power_beta, power_gamma)
% バンドパワープロットの更新
% プロットに最新のデータ点を追加する

    plot_delta = plot_bandpower(1);
    plot_theta = plot_bandpower(2);
    plot_alpha = plot_bandpower(3);
    plot_beta  = plot_bandpower(4);
    plot_gamma = plot_bandpower(5);

    addpoints(plot_delta, timeStamp, power_delta);
    addpoints(plot_theta, timeStamp, power_theta);
    addpoints(plot_alpha, timeStamp, power_alpha);
    addpoints(plot_beta,  timeStamp, power_beta);
    addpoints(plot_gamma, timeStamp, power_gamma);
    xlim([timeStamp-30 timeStamp+1]);
    ylim([0 1000])%1000に変更
    drawnow;
end