function SSVEP_Task()

    addpath('./utilities'); % ���C�u�������p�X�ɒǉ�
    measurementTime = 120;               % �]�g�̌v������

    try
        escKey = 'ESCAPE'; % �����I���L�[
        
        
        % PsychToolBox�Z�b�g�A�b�v
        myKeyCheck;
        ListenChar(2);
        AssertOpenGL;
        screens = Screen('Screens');
        screenNumber = max(screens);
        BackColor = [128 128 128];
%         [windowPtr, windowRect] = Screen('OpenWindow',screenNumber,BackColor, [800 800 2680 1920]);
%         [windowPtr, windowRect] = Screen('OpenWindow',screenNumber,BackColor, [1 1 2000 1000]);
        [windowPtr, windowRect] = Screen('OpenWindow',screenNumber,BackColor, [1 1 2000 800]);
        HideCursor(windowPtr);
        [cx,cy] = RectCenter(windowRect); % ��ʂ̒��S���W (px)
        [winWidth, winHeight] = Screen('WindowSize', windowPtr); % ��ʂ̏c���T�C�Y (px)
        inputKey_esc = KbName(escKey);


        % �`�F�b�J�[�{�[�h�̃C���X�^���X�𐶐�
        % stim_checker = Checkerboard(windowPtr, frequency, size, position);
        stim_checker1 = Checkerboard(windowPtr, 10, 400, [cx-600 cy]);
        stim_checker2 = Checkerboard(windowPtr, 12, 400, [cx+600 cy]);

        
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