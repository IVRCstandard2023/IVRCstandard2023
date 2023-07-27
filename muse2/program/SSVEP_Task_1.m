function SSVEP_Task()


   %%%%%%%%%%%%%%%%%%%%%%%%%% EDIT HERE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    measurementTime = 200;               % 脳波の計測時間
    
    full_screen = 0;                    % フルスクリーン = 1，スクリーンサイズを自分で設定 = 0
%     screen_size = [800 800 2680 1920];  % 自身のPCの画面サイズにあわせて設定 [スクリーンの左上の座標x，スクリーンの左上の座標y，スクリーンの右下の座標x，スクリーンの右下の座標x]
    screen_size = [1 1 1920 1080];  % 自身のPCの画面サイズにあわせて設定 [スクリーンの左上の座標x，スクリーンの左上の座標y，スクリーンの右下の座標x，スクリーンの右下の座標x]
%     screen_size = [1 1 1920*0.9 1080*0.9];  % 自身のPCの画面サイズにあわせて設定 [スクリーンの左上の座標x，スクリーンの左上の座標y，スクリーンの右下の座標x，スクリーンの右下の座標x]

    checkerboard_frequency_left = 8;   % 左に提示されるチェッカーボードの周波数
    checkerboard_frequency_right = 10;   % →に提示されるチェッカーボードの周波数
    
    checkerboard_size_left = 500;   % 左に提示されるチェッカーボードの大きさ
    checkerboard_size_right = 500;   % →に提示されるチェッカーボードの大きさ
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    addpath('./utilities'); % ライブラリをパスに追加
    Screen('Preference', 'SkipSyncTests', 1);
    try
        escKey = 'ESCAPE'; % 強制終了キー
        
        
        % PsychToolBoxセットアップ
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
        [cx,cy] = RectCenter(windowRect); % 画面の中心座標 (px)
        [winWidth, winHeight] = Screen('WindowSize', windowPtr); % 画面の縦横サイズ (px)
        inputKey_esc = KbName(escKey);


        % チェッカーボードのインスタンスを生成
        % stim_checker = Checkerboard(windowPtr, frequency, size, position);
%         stim_checker1 = Checkerboard(windowPtr, checkerboard_frequency_left, checkerboard_size_left, [cx-800 cy]);
%         stim_checker2 = Checkerboard(windowPtr, checkerboard_frequency_right, checkerboard_size_right, [cx+800 cy]);

        stim_checker1 = Checkerboard(windowPtr, checkerboard_frequency_left, checkerboard_size_left, [cx-600 cy]);
        stim_checker2 = Checkerboard(windowPtr, checkerboard_frequency_right, checkerboard_size_right, [cx+600 cy]);

        
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