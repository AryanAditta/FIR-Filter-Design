function main_filter_design()
    % Clear workspace
    clc;
    close all;
    clear;

    % Welcome Message
    disp('-------------------------------------------');
    disp('MATLAB Filter Design and Analysis Toolbox');
    disp('-------------------------------------------');

    % Audio File Input
    [audioSignal, fs] = get_audio_input();

    % Filter Types Menu
    filter_types = {
        'Low-Pass Filter (LPF)', 
        'High-Pass Filter (HPF)', 
        'Band-Pass Filter (BPF)', 
        'Band-Stop Filter (BSF)'
    };

    % Display Filter Type Menu
    disp('Select Filter Type:');
    for i = 1:length(filter_types)
        disp([num2str(i), '. ', filter_types{i}]);
    end

    % Get User Filter Type Selection
    while true
        filter_choice = input('Enter filter type (1-4): ');
        if filter_choice >= 1 && filter_choice <= 4
            break;
        else
            disp('Invalid selection. Please try again.');
        end
    end

    % Specifications Input
    disp('Enter Filter Specifications:');
    passband_ripple = input('Maximum Passband Ripple (dB): ');
    stopband_attenuation = input('Minimum Stopband Attenuation (dB): ');

    % Select Window Type Based on Specifications
    win_type = select_window_type(passband_ripple, stopband_attenuation);
    disp(['Selected Window Type: ', win_type]);

    % Filter Order Input
    while true
        n = input('Enter filter order (recommended odd number, e.g., 51): ');
        if n > 0 && mod(n, 2) == 1
            break;
        else
            disp('Please enter a positive odd number.');
        end
    end

    % Frequency Parameter Input Based on Filter Type
    switch filter_choice
        case 1  % Low-Pass Filter
            disp(['Nyquist Frequency: ', num2str(fs/2), ' Hz']);
            while true
                fc_low = input('Enter Low-Pass Cutoff Frequency (Hz): ');
                if fc_low > 0 && fc_low <= fs/2
                    h = filter_coefficient('lpf', fs, fc_low, 0, 0, 0, 0, 0, n);
                    break;
                else
                    disp('Invalid frequency. Must be between 0 and Nyquist Frequency.');
                end
            end

        case 2  % High-Pass Filter
            disp(['Nyquist Frequency: ', num2str(fs/2), ' Hz']);
            while true
                fc_up = input('Enter High-Pass Cutoff Frequency (Hz): ');
                if fc_up > 0 && fc_up <= fs/2
                    h = filter_coefficient('hpf', fs, 0, fc_up, 0, 0, 0, 0, n);
                    break;
                else
                    disp('Invalid frequency. Must be between 0 and Nyquist Frequency.');
                end
            end

        case 3  % Band-Pass Filter
            disp(['Nyquist Frequency: ', num2str(fs/2), ' Hz']);
            while true
                % Frequency inputs for Band-Pass
                disp('Enter Band-Pass Filter Frequencies:');
                f_stop1 = input('Lower Stopband Frequency (Hz): ');
                f_pass1 = input('Lower Passband Frequency (Hz): ');
                f_pass2 = input('Upper Passband Frequency (Hz): ');
                f_stop2 = input('Upper Stopband Frequency (Hz): ');

                % Validate frequencies
                if f_stop1 < f_pass1 && f_pass1 < f_pass2 && f_pass2 < f_stop2 && f_stop2 <= fs/2
                    h = filter_coefficient('bpf', fs, 0, 0, f_stop1, f_stop2, f_pass1, f_pass2, n);
                    break;
                else
                    disp('Invalid frequency configuration. Please check the following:');
                    disp('1. f_stop1 < f_pass1');
                    disp('2. f_pass1 < f_pass2');
                    disp('3. f_pass2 < f_stop2');
                    disp('4. f_stop2 <= Nyquist Frequency');
                end
            end

        case 4  % Band-Stop Filter
            disp(['Nyquist Frequency: ', num2str(fs/2), ' Hz']);
            while true
                % Frequency inputs for Band-Stop
                fc_low = input('Enter Lower Cutoff Frequency (Hz): ');
                fc_up = input('Enter Upper Cutoff Frequency (Hz): ');

                % Validate frequencies
                if fc_low > 0 && fc_up > fc_low && fc_up <= fs/2
                    h = filter_coefficient('bsf', fs, fc_low, fc_up, 0, 0, 0, 0, n);
                    break;
                else
                    disp('Invalid frequency configuration. Please check the following:');
                    disp('1. fc_low > 0');
                    disp('2. fc_up > fc_low');
                    disp('3. fc_up <= Nyquist Frequency');
                end
            end
    end


function win_type = select_window_type(passband_ripple, stopband_attenuation)
if (passband_ripple >= 0.7416) && (stopband_attenuation > 0 && stopband_attenuation <= 21) % Rectangular window
    win_type = 'rect';
elseif (passband_ripple >= 0.0546) && (stopband_attenuation > 21 && stopband_attenuation <= 44) % Hanning window
    win_type = 'hann';
elseif (passband_ripple >= 0.0194) && (stopband_attenuation > 44 && stopband_attenuation <= 53) % Hamming window
    win_type = 'hamm';
elseif (passband_ripple >= 0.0017) && (stopband_attenuation > 53 && stopband_attenuation <= 74) % Blackman window
    win_type = 'black';
else
    disp('Invalid parameters');
end
end


    % Apply Window Function
    M = length(h);
    [num, h_win, w_win] = window_function(h, win_type, M);
    disp(h)
    function [num, h_win, w_win] = window_function(h, win_type, M)

M=length(h)
    w = ones(1, M);  % Assuming M is the length of h

    switch win_type
        case 'rect'
            % Rectangular window
            % No changes needed for rectangular window
        case 'hann'
            % Hanning window
            for n = 0:M-1
                w(n + 1) = 0.5 + 0.5 * (1 - cos(2 * pi * n / M));
            end
        case 'hamm'
            % Hamming window
            for n = 0:M-1
                w(n + 1) = 0.54 + 0.46 * cos(2 * pi * n / M);
            end
        case 'black'
            % Blackman window
            for n = 0:M-1
                w(n + 1) = 0.42 + 0.5 * cos(2 * pi * n / M) + 0.08 * cos(4 * pi * n / M);
            end
        otherwise
            error('Unsupported window type');
    end

    num = h .* w;
    [h_win, w_win] = freqz(num, [1], 512, fs);
end


    % Visualization and Signal Processing
    visualize_filter_response(w_win, h_win, num, audioSignal, fs, filter_types{filter_choice}, win_type);
end

function [audioSignal, fs] = get_audio_input()
    % Audio File Input
    while true
        inputFile = input('Enter audio filename (including .wav): ', 's');
        
        % Check if file exists
        if exist(inputFile, 'file')
            [audioSignal, fs] = audioread(inputFile);
            
            % Convert to mono if stereo
            if size(audioSignal, 2) > 1
                audioSignal = mean(audioSignal, 2);
                disp('Converted stereo to mono');
            end
            break;
        else
            disp(['File "', inputFile, '" not found. Please try again.']);
        end
    end
end

function visualize_filter_response(w_win, h_win, num, audioSignal, fs, filter_type, win_type)
    % Frequency Response Visualization
    figure('Name', [filter_type, ' with ', upper(win_type), ' Window']);
    
    % Magnitude Response
    subplot(3,1,1);
    hold on;
    plot(w_win, 20*log10(abs(h_win)));
    title(['Magnitude Response - ', filter_type]);
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    grid on;
    
    % Phase Response
    subplot(3,1,2);
    hold on;
    plot(w_win, unwrap(angle(h_win)) * 180/pi);
    title('Unwrapped Phase Response');
    xlabel('Frequency (Hz)');
    ylabel('Phase (degrees)');
    grid on;
    
    % Pole-Zero Plot
    subplot(3,1,3);
    hold on;
    zplane(num, 1);
    title('Pole-Zero Plot');
    
    % Noise Addition and Filtering
    noise_level = 0.1;
    noisy_signal = audioSignal + noise_level * randn(size(audioSignal));
    filtered_signal = filter(num, 1, noisy_signal);
    
    % Time Domain Comparison
    figure('Name', 'Signal Comparison');
    t = (0:length(audioSignal)-1) / fs;
    
    subplot(3,1,1);
    hold on;
    plot(t, audioSignal);
    title('Original Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    subplot(3,1,2);
    hold on;
    plot(t, noisy_signal);
    title('Noisy Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    subplot(3,1,3);
    hold on;
    plot(t, filtered_signal);
    title('Filtered Signal');
    xlabel('Time (s)');
    ylabel('Amplitude');
    
    % Signal Playback
    disp('Playing signals...');
    soundsc(audioSignal, fs);
    pause(length(audioSignal)/fs + 1);
    
    soundsc(noisy_signal, fs);
    pause(length(noisy_signal)/fs + 1);
    
    soundsc(filtered_signal, fs);
end
