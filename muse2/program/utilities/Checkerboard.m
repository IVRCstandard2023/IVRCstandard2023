classdef Checkerboard < handle

    
    properties
        path_checker1 = './images/checkerborad01.png';
        path_checker2 = './images/checkerborad02.png';
        
        frequency;
        size;
        position;
        
        img_checker1;
        img_checker2;
        tex_checker1;
        tex_checker2;
        
        period;
        rect;
        frame;
    end
    
    methods
        function self = Checkerboard(windowPtr, frequency, size, position)
        % windowPtr : ウィンドウポインター
        % frequency : チェッカーボードの周波数 (Hz)
        % size      : チェッカーボードのサイズ (px)
        % position  : チェッカーボードの描画座標 ([px px])
        
            self.frequency = frequency;
            self.size = size;
            self.position = position;
            
            self.img_checker1 = imread(self.path_checker1, 'png');
            self.img_checker2 = imread(self.path_checker2, 'png');
            self.tex_checker1 = Screen('MakeTexture', windowPtr, self.img_checker1);
            self.tex_checker2 = Screen('MakeTexture', windowPtr, self.img_checker2);
            
            self.period = 60/frequency;
            hs = self.size/2;
            self.rect = [self.position(1)-hs self.position(2)-hs self.position(1)+hs self.position(2)+hs];
            self.frame = 0;
        end
        
        % 刺激の描画
        function Draw(self, windowPtr)

            % 経過フレーム数に対応したチェッカーボードを表示する
            quotient = int32(fix(self.frame/self.period));
            if quotient == 0
                Screen('DrawTexture', windowPtr, self.tex_checker1, [], self.rect);
                
            elseif quotient == 1
                Screen('DrawTexture', windowPtr, self.tex_checker2, [], self.rect);
            end
            
            % フレーム数をインクリメント
            self.frame = self.frame+1;
            
            % 1周期分経過したらフレーム数を0に戻す
            if self.frame == self.period*2
                self.frame = 0;
            end
        end
    end
end


