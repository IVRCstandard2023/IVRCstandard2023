function plot_bandpower = create_plot_raweeg()
% バンドパワープロットの作成

    figure();
    plot_ch1 = animatedline('Color', 'r');
    plot_ch2  = animatedline('Color', 'g');
    plot_ch3 = animatedline('Color', 'b');
    plot_ch4 = animatedline('Color', 'k');
    title('Raw EEG');
    legend('Ch1','Ch2','Ch3','Ch4')
    xlabel('Time(s)');
    ylabel('');
    set(gca,'FontSize',12);
    drawnow;

    plot_bandpower = [plot_ch1 plot_ch2 plot_ch3 plot_ch4];
end
