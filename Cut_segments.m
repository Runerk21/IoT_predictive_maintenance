clear all; close all; clc;

addpath("C:\TempData")
files = dir('C:\TempData'); % Directory with audio segment files

% Start and stop reference timestamps
Ref_start = {'2024-04-24 12:11:38','2024-04-24 12:48:36','2024-04-24 13:16:59','2024-04-24 13:54:14','2024-04-24 14:22:38','2024-04-24 14:59:37','2024-04-24 15:31:01','2024-04-24 16:08:01','2024-04-24 16:36:28', '2024-04-24 21:34:16','2024-04-24 22:43:39','2024-04-24 23:11:53', '2024-04-24 23:49:07', '2024-04-25 00:17:45','2024-04-25 00:54:45','2024-04-25 01:23:23','2024-04-25 02:00:23', '2024-04-25 02:29:02','2024-04-25 03:06:03','2024-04-25 03:34:43' ,'2024-04-25 04:11:43','2024-04-25 07:55:43','2024-04-25 08:35:15','2024-04-25 09:07:53','2024-04-25 09:56:34','2024-04-25 10:25:04','2024-04-25 11:02:03','2024-04-25 11:30:28','2024-04-25 12:07:37','2024-04-25 12:36:03','2024-04-25 13:13:02','2024-04-25 13:41:25','2024-04-25 14:18:24','2024-04-25 14:46:48','2024-04-25 15:23:47','2024-04-25 15:52:11','2024-04-25 16:29:10','2024-04-25 16:57:37','2024-04-25 17:34:36','2024-04-25 23:51:42','2024-04-26 00:30:02','2024-04-26 01:02:49','2024-04-26 01:39:47','2024-04-26 02:08:20','2024-04-26 02:45:21','2024-04-26 03:13:49','2024-04-26 07:52:22','2024-04-26 08:26:04','2024-04-26 09:03:05','2024-04-26 09:31:34','2024-04-26 10:08:33','2024-04-26 10:37:01'};
Ref_stop = {'2024-04-24 12:14:10','2024-04-24 12:50:29','2024-04-24 13:19:32','2024-04-24 13:56:07','2024-04-24 14:23:29','2024-04-24 15:01:32','2024-04-24 15:33:37','2024-04-24 16:09:55','2024-04-24 16:39:02','2024-04-24 21:36:10','2024-04-24 22:45:32','2024-04-24 23:12:08','2024-04-24 23:51:00','2024-04-25 00:20:21', '2024-04-25 00:56:40', '2024-04-25 01:25:59','2024-04-25 02:02:18', '2024-04-25 02:31:38','2024-04-25 03:07:58','2024-04-25 03:37:19','2024-04-25 04:13:38','2024-04-25 07:58:19','2024-04-25 08:37:11','2024-04-25 09:10:29','2024-04-25 09:58:30','2024-04-25 10:27:39','2024-04-25 11:03:58','2024-04-25 11:33:02','2024-04-25 12:09:33','2024-04-25 12:38:38','2024-04-25 13:14:57','2024-04-25 13:44:00','2024-04-25 14:20:19','2024-04-25 14:49:23','2024-04-25 15:25:42','2024-04-25 15:54:46','2024-04-25 16:31:05','2024-04-25 17:00:12','2024-04-25 17:36:30','2024-04-25 23:54:17','2024-04-26 00:31:58','2024-04-26 01:05:22','2024-04-26 01:41:40','2024-04-26 02:10:56','2024-04-26 02:47:15','2024-04-26 03:16:25','2024-04-26 07:54:19','2024-04-26 08:28:41','2024-04-26 09:04:59','2024-04-26 09:34:10','2024-04-26 10:10:28','2024-04-26 10:39:37'};

i = 1;

for j = 1:length(Ref_start)
    disp(['loading file ', files(i+2).name]);
    T = readtable(files(i+2).name); % Load file number j in the directory
    timestamp = T.Timestamp; % Read data from table into array
    time = T.Time_s_; % Read data from table into array
    amplitude = T.Amplitude; % Read data from table into array
    
    % Find start timestamp
    diff_start = abs(timestamp-Ref_start(j));
    [min_diff_start, idx_start] = min(diff_start);

    if min_diff_start ~= 0
        disp(['Start time ', Ref_start(j), 'not found']);
    else
        disp('Start time found')
    end

    % Find stop timestamp
    Diff_stop = abs(timestamp-Ref_stop(j));
    [min_diff_stop, idx_stop] = min(Diff_stop);

    if min_diff_stop ~= 0 % If stop time is not found
        disp('End time not found in same file as start time');
        % Save data from start time to end of file
        segment.timestamp = timestamp(idx_start:end);
        segment.time = time(idx_start:end);
        segment.amplitude = amplitude(idx_start:end);

        % Clear data and load next file
        clear T timestamp time amplitude
        i = i+1;
        T = readtable(files(i+2).name);
        timestamp = T.Timestamp; % Read data from table into array
        time = T.Time_s_; % Read data from table into array
        amplitude = T.Amplitude; % Read data from table into array
        
        % Find stop timestamp
        Diff_stop = abs(timestamp-Ref_stop(j));
        [min_diff_stop, idx_stop] = min(Diff_stop);
        if min_diff_stop ~= 0
            disp(['failed to find idx_slut ', num2str(idx_stop)]);
        end
        % Consolidate data from the first and second file
        segment.timestamp = cat(1,segment.timestamp,timestamp(1:idx_stop));
        segment.time = cat(1,segment.time,time(1:idx_stop));
        segment.amplitude = cat(1,segment.amplitude,amplitude(1:idx_stop));
        i = i+1;
    else % If stop timestamp found in same file as start timestamp
        disp('End time found in same file as start')
        segment.timestamp = timestamp(idx_start:idx_stop);
        segment.time = time(idx_start:idx_stop);
        segment.amplitude = amplitude(idx_start:idx_stop);
        i = i+1;
    end
    
    % Save the segment struct containing data frame
    str1 = datestr(Ref_start(j));
    str2 = strrep(str1,':','-');
    filename = append("C:\Done\block",str2);
    save(filename, "segment",'-mat');
    disp(['File number ', num2str(j), 'named ', filename, 'was saved']);
    clearvars -except files i j Ref_start Ref_slut; 
end 


