function SSVEP_Task()


   %%%%%%%%%%%%%%%%%%%%%%%%%% EDIT HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    measurementTime = 200;               % �]�g�̌v������
    
    full_screen = 0;                    % �t���X�N���[�� = 1�C�X�N���[���T�C�Y�������Őݒ� = 0
%     screen_size = [800 800 2680 1920];  % ���g��PC�̉�ʃT�C�Y�ɂ��킹�Đݒ� [�X�N���[���̍���̍��Wx�C�X�N���[���̍���̍��Wy�C�X�N���[���̉E���̍��Wx�C�X�N���[���̉E���̍��Wx]
    screen_size = [1 1 1920 1080];  % ���g��PC�̉�ʃT�C�Y�ɂ��킹�Đݒ� [�X�N���[���̍���̍��Wx�C�X�N���[���̍���̍��Wy�C�X�N���[���̉E���̍��Wx�C�X�N���[���̉E���̍��Wx]
%     screen_size = [1 1 1920*0.9 1080*0.9];  % ���g��PC�̉�ʃT�C�Y�ɂ��킹�Đݒ� [�X�N���[���̍���̍��Wx�C�X�N���[���̍���̍��Wy�C�X�N���[���̉E���̍��Wx�C�X�N���[���̉E���̍��Wx]

    checkerboard_frequency_left = 8;   % ���ɒ񎦂����`�F�b�J�[�{�[�h�̎��g��
    checkerboard_frequency_right = 10;   % ���ɒ񎦂����`�F�b�J�[�{�[�h�̎��g��
    
    checkerboard_size_left = 500;   % ���ɒ񎦂����`�F�b�J�[�{�[�h�̑傫��
    checkerboard_size_right = 500;   % ���ɒ񎦂����`�F�b�J�[�{�[�h�̑傫��
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    addpath('./utilities'); % ���C�u�������p�X�ɒǉ�
    Screen('Preference', 'SkipSyncTests', 1);
    try
        escKey = 'ESCAPE'; % �����I���L�[
        
        
        % PsychToolBox�Z�b�g�A�b�v
        myKeyCheck;
        ListenChar(2);
        AssertOpenGL;
        screens = Screen('Screens');
        screenNumber = max(screens);
        BackColor = [128 128 128];
        if full_screen
            [windowPtr, windowRect] = Screen('OpenWindow',screenNumber,BackColor);
        else
            [windowPtr, windowRect] = Screen('OpenWindow',screenNumber,BackColor, screen_size);
        end
        HideCursor(windowPtr);
        [cx,cy] = RectCenter(windowRect); % ��ʂ̒��S���W (px)
        [winWidth, winHeight] = Screen('WindowSize', windowPtr); % ��ʂ̏c���T�C�Y (px)
        inputKey_esc = KbName(escKey);


        % �`�F�b�J�[�{�[�h�̃C���X�^���X�𐶐�
        % stim_checker = Checkerboard(windowPtr, frequency, size, position);
%         stim_checker1 = Checkerboard(windowPtr, checkerboard_frequency_left, checkerboard_size_left, [cx-800 cy]);
%         stim_checker2 = Checkerboard(windowPtr, checkerboard_frequency_right, checkerboard_size_right, [cx+800 cy]);

        stim_checker1 = Checkerboard(windowPtr, checkerboard_frequency_left, checkerboard_size_left, [cx-600 cy]);
        stim_checker2 = Checkerboard(windowPtr, checkerboard_frequency_right, checkerboard_size_right, [cx+600 cy]);

        
        % measurementTime �b�ԃ`�F�b�J�[�{�[�h�h����`�悷��
        tic;
        while toc < measurementTime

            % �`�F�b�J�[�{�[�h�̕`��
            stim_checker1.Draw(windowPtr);
            stim_checker2.Draw(windowPtr);
            
            % ��ʂ̍X�V
            Screen('Flip', windowPtr);

            % Esc�L�[�������ꂽ�狭���I������
            [keyIsDown, ~, keyStates] = KbCheck;
            if keyIsDown && keyStates(inputKey_esc) == 1
                break;
            end
        end

        % �I������
        Finalize();


    % �G���[�����������Ƃ��̏���
    catch
        % �I������
        Finalize();

        psychrethrow(psychlasterror);
    end
end


% PsychToolBox�̏I������
function Finalize()
    if exist('windowPtr', 'var')
        ShowCursor(windowPtr);
    end
    fclose('all');
    Screen('CloseAll');
    ListenChar(0);
end