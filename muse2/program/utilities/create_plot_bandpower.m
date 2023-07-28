function plot_bandpower = create_plot_bandpower()
% �o���h�p���[�v���b�g�̍쐬

    figure();
    plot_alpha = animatedline('Color', 'r');
    plot_left  = animatedline('Color', 'g');
    plot_right = animatedline('Color', 'b');
    title('Band Power');
    legend('alpha','SSVEP left','SSVEP right')
    xlabel('Time(s)');
    ylabel('Power(dB)');
    set(gca,'FontSize',12);
    ylim(gca, [0 1000]); % �c���͈̔͂�0����1000�ɐݒ�
    drawnow;

    plot_bandpower = [plot_alpha plot_left plot_right];
end
