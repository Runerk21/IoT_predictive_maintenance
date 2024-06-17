%% Load data
clear, clc, close all,

addpath("C:\Users\mail\OneDrive - Aalborg Universitet\8. Semester\P8\IMU_Data")
n = length(dir('IMU_Data'))-2;

% Load files into arrays
for i = 1:n
    file = ['data' num2str(i) '.csv'];
    tempdata = readmatrix(file); % Load file number i
    clear acc t
    acc(:,1) = tempdata(:,2); % read acceleration in x direction into array
    acc(:,2) = tempdata(:,3); % read acceleration in y direction into array
    acc(:,3) = tempdata(:,4); % read acceleration in z direction into array
    t(:,1) = tempdata(:,5); % read timestamps into array

    
    if i == 1 % for the first file
        data = acc;
        timestamp = t;
    else % for the rest of the files consolidate data into array
        data = cat(1,data,acc);
        timestamp = cat(1,timestamp,t);
    end
end

% convert timestamp from milliseconds to datetime
timestamp_sec = timestamp/1000;
dt = datetime(timestamp_sec,'convertFrom','posixtime','Format','yyyy-MM-dd HH:mm:ss.SSS');

%% Segment data
% Start and stop times
Ref_start = {'2024-04-25 11:41:25.439'; '2024-04-25 12:18:24.874'; '2024-04-25 12:46:48.466'; '2024-04-25 13:23:47.691'; '2024-04-25 13:52:11.799'; '2024-04-25 14:29:10.637'; '2024-04-25 14:57:37.417'; '2024-04-25 15:34:36.339'};
Ref_stop = {'2024-04-25 11:44:00.218';'2024-04-25 12:20:19.874'; '2024-04-25 12:49:23.215'; '2024-04-25 13:25:42.905'; '2024-04-25 13:54:46.458'; '2024-04-25 14:31:05.539'; '2024-04-25 15:00:12.334'; '2024-04-25 15:36:30.615'};

for j = 1:length(Ref_start)
    % Find start timestamp
    diff_start = abs(dt-Ref_start(j));
    [min_diff_start,idx_start] = min(diff_start);
    % Find stop timestamp
    diff_stop = abs(dt-Ref_stop(j));
    [min_diff_stop,idx_stop] = min(diff_stop);
    
    % Create time vector
    len = idx_stop-idx_start+1; 
    sec = len/100;
    t = linspace(0,sec,len);

    % Extract data frames into struct
    segment(j).timestamp = dt(idx_start:idx_stop);
    segment(j).time = t;
    segment(j).accelx = data(idx_start:idx_stop,1);
    segment(j).accely = data(idx_start:idx_stop,2);
    segment(j).accelz = data(idx_start:idx_stop,3);
end