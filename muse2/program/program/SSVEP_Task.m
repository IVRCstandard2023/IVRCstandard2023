function SSVEP_Task()

    addpath('./utilities'); % ライブラリをパスに追加
    measurementTime = 120;               % 脳波の計測時間

    try
        escKey = 'ESCAPE'; % 強制終了キー
        
        
        % PsychToolBoxセットアップ
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
        [cx,cy] = RectCenter(windowRect); % 画面の中心座標 (px)
        [winWidth, winHeight] = Screen('WindowSize', windowPtr); % 画面の縦横サイズ (px)
        inputKey_esc = KbName(escKey);


        % チェッカーボードのインスタンスを生成
        % stim_checker = Checkerboard(windowPtr, frequency, size, position);
        stim_checker1 = Checkerboard(windowPtr, 10, 400, [cx-600 cy]);
        stim_checker2 = Checkerboard(windowPtr, 12, 400, [cx+600 cy]);

        
        % measurementTime 秒間チェッカーボード刺激を描画する
        tic;
        while toc < measurementTime

            % チェッカーボードの描画
            stim_checker1.Draw(windowPtr);
            stim_checker2.Draw(windowPtr);
            
            % 画面の更新
            Screen('Flip', windowPtr);

            % Escキーが押されたら強制終了する
            [keyIsDown, ~, keyStates] = KbCheck;
            if keyIsDown && keyStates(inputKey_esc) == 1
                break;
            end
        end

        % 終了処理
        Finalize();


    % エラーが発生したときの処理
    catch
        % 終了処理
        Finalize();

        psychrethrow(psychlasterror);
    end
end


% PsychToolBoxの終了処理
function Finalize()
    if exist('windowPtr', 'var')
        ShowCursor(windowPtr);
    end
    fclose('all');
    Screen('CloseAll');
    ListenChar(0);
end