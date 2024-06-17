clear; close all; clc;
%addpath('C:\Users\mail\OneDrive - Aalborg Universitet\8. Semester\P8\AudioData\Done') % Laptop
addpath('C:\Users\Bjørn\OneDrive - Aalborg Universitet\8. Semester\P8\AudioData\Done') % Desktop

files = dir('AudioData\Done');

i = 25; % Select which file
tic
% load files
load(files(i+2).name, "-mat");
k = erase(files(i+2).name,'block');
len = length(segment.amplitude);
sec = len/44100;
t = linspace(0,sec,len); % Time vector
thresh = 0.12; % Threshhold


% Convert to binary via thresholding 
bin = abs(segment.amplitude) >= thresh;

win1 = 5000;
win2 = 5000;

% Dilation
buf = movmax(bin, [win1 win1]);
% Erosion: 
buf1 = movmin(buf, [win2 win2]);
toc

%% Find start & stop index
idx1 = zeros(length(buf1),1); % Initiate idx array
idx2 = zeros(length(buf1),1); % Initiate idx array
win3 = 50; % Window size. Used to check before startpoint and after stoppoint
win4 = 44100; % Window size. Used to check after startpoint and before stoppoint
v = 1;

% Find start index
for n = win3+1:length(buf1)-win4
    if buf1(n) == 1 && buf1(n-1) == 0 % Locate point where value is 1 and prior value is 0
        idx_win1start = n-win3:n-1; % Index array for points before current index
        idx_win2start = n+1:100:n+win4; % Index array for points after current index
        logic1_start = buf1(idx_win1start) == 0; % Logic array 
        logic2_start = buf1(idx_win2start) == 1; % Logic array 
        if sum(logic1_start) == length(logic1_start) && sum(logic2_start) == length(logic2_start) % Check the logic arrays 
            idx1(v) = n; % Save start index
            v = v+1;
        end
    end
end
startidx = t(nonzeros(idx1));
v = 1;

%Find stop index
for c = win4:length(buf1)
    if buf1(c) == 1 && buf1(c+1) == 0 % Locate point where value is 1 and next value is 0
        idx_win1stop = c-win4:100:c; % Index array for points before current index
        idx_win2stop = c+1:c+win3; % Index array for points after current index
        logic1_stop = buf1(idx_win1stop) == 1; % Logic array
        logic2_stop = buf1(idx_win2stop) == 0; % Logic array
        if sum(logic1_stop) == length(logic1_stop) && sum(logic2_stop) == length(logic2_stop) % Check logic arrays
            idx2(v) = c; % Save stop index
            v = v+1;
        end
    end
end
stopidx = t(nonzeros(idx2));
disp(['Number of tool engagement found: ',num2str(length(startidx))])

% Find Fixture rotatation
idx_rotstart = stopidx(1,3:3:end-1);
idx_rotstop = startidx(1,4:3:end-1);

%% Plot
color = sscanf('#77AC30', '#%2x%2x%2x', 3) / 255;

figure
plot(t,segment.amplitude,'-b')
grid on
title('Acoustic Data ',k)
xlabel('Time [sec]')
ylabel('Amplitude')
xline(startidx,'-','Color',color,'LineWidth',1.5)
xline(stopidx,'-r','LineWidth',1.5)
xline(idx_rotstart,'--k','LineWidth',2)
xline(idx_rotstop,'--k','LineWidth',2)


%%
figure
plot(t,buf1,'-b')
ylim([-0.2,1.2])
xlabel('Time [sec]')
title('Acoustic Data ', k)
grid on
hold on
plot(startidx,buf1(nonzeros(idx1)),'og')
plot(stopidx,buf1(nonzeros(idx2)),'or')

%%
figure
plot(t,bin,'-b')
ylim([-0.2,1.2])
xlabel('Time [sec]')
title('Acoustic Data ', k)
grid on
xlim([10.15,10.4])

%%
figure
plot(t,segment.amplitude,'b')
title('Acoustic Data ',k)
xlabel('Time [sec]')
ylabel('Amplitude')
grid on
yline(0.12,'r')
yline(-0.12,'r')