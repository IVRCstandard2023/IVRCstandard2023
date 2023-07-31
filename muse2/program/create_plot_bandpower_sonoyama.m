function plot_bandpower_sonoyama = create_plot_bandpower_sonoyama()
% バンドパワープロットの作成

    figure();
    plot_delta = animatedline('Color', 'r');
    plot_theta = animatedline('Color', 'g');
    plot_alpha = animatedline('Color', 'b');
    plot_beta  = animatedline('Color', 'c');
    plot_gamma = animatedline('Color', 'm');
    title('Band Power');
    legend('Delta','Theta','Alpha', 'Beta', 'Gamma')
    xlabel('Time(s)');
    ylabel('Power(dB)');
    set(gca,'FontSize',12);
    ylim(gca, [0 1000]); % 縦軸の範囲を0から1000に設定
    drawnow;

    plot_bandpower_sonoyama = [plot_delta plot_theta plot_alpha plot_beta plot_gamma];
end
