function [raw_time, raw_eeg] = extract_lsl_data(lsl_time, lsl_eeg, sample_len)
% LSLデータから直近sample_len分のデータを抽出

    lsl_len = length(lsl_eeg);
    
    % 取り出す数よりデータ数のほうが少ない場合、全て取り出す
    if lsl_len < sample_len
        raw_time = lsl_time;
        raw_eeg = lsl_eeg;
        
    % そうでない場合、sample_len分のデータを取り出す
    else
        extract_idx = lsl_len-sample_len+1 : lsl_len;
        raw_time = lsl_time(extract_idx);
        raw_eeg = lsl_eeg(:, extract_idx);
    end
end
