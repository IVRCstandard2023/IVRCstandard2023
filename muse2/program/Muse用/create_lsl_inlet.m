function inlet = create_lsl_inlet(streamName)

    lib = lsl_loadlib();

    % resolve a stream...
    disp('Resolving an EEG stream...');
    result = {};
    while isempty(result)
        result = lsl_resolve_byprop(lib, 'name', [streamName '_eeg']);
    end

    % create a new inlet
    disp('Opening an inlet...');
    inlet = lsl_inlet(result{1}, 10000);

end

