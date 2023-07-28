function update_plot_bandpower(plot_bandpower, timeStamp, power_alpha, power_left, power_right)
% �o���h�p���[�v���b�g�̍X�V
% �v���b�g�ɍŐV�̃f�[�^�_��ǉ�����

    plot_alpha = plot_bandpower(1);
    plot_left  = plot_bandpower(2);
    plot_right = plot_bandpower(3);

    addpoints(plot_alpha, timeStamp, power_alpha)
    addpoints(plot_left,  timeStamp, power_left)
    addpoints(plot_right, timeStamp, power_right)
    xlim([timeStamp-30 timeStamp+1]);
    %ylim([0 20])
    ylim([0 1000])%1000�ɕύX
    drawnow;
end
