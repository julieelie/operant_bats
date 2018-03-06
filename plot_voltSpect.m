function plot_voltSpect(micType,audioVarName)
%filePath names, make sure to change your file paths
filePath= pwd; %change your workspace path to this folder
fileList = dir([filePath '\' '*.mat']);
callPath= [filePath '\call\'];
noisePath= [filePath '\noise\'];
fs = 192000;

%check if the call/noise folders already exist, make them if not
if exist(callPath, 'dir')
    ;
else
    mkdir(callPath);
end
if exist(noisePath, 'dir')
    ;
else
    mkdir(noisePath);
end
%load compensation file depending on mic used
compPath = 'C:\Users\tobias\Desktop\bataudio\COMPENSATION FILES\';
    if strcmp(micType, 'K1')
        compFile = 'Comp_IR_knowles_k1_wzRoom_20170626T165536.mat';
    elseif strcmp(micType,'K5')
        compFile = 'Comp_IR_knowles_k5_wzRoom_20170626T165914.mat';
    elseif strcmp(micType,'K7')
        compFile = 'Comp_IR_knowles_k7_wzRoom_20170626T171431.mat';
    elseif strcmp(micType,'K2')
        compFile = 'Comp_IR_knowles_k2_wzRoom_20170626T170438.mat';
    elseif strcmp(micType,'EW1')
        compFile = 'Comp_IR_knowles_ew1_wzRoom_20170626T164454.mat';
    elseif strcmp(micType,'EW5')
        compFile = 'Comp_IR_knowles_ew5_wzRoom_20170626T164945.mat';
    elseif strcmp(micType,'EW7')
        compFile = 'Comp_IR_knowles_ew7_wzRoom_20170626T165126.mat';
    elseif strcmp(micType,'EW2')
        compFile = 'Comp_IR_knowles_ew2_wzRoom_20170626T164716.mat';
    end
    %load compensation file data
    compStruct = load([compPath compFile],'irc');
    irc = compStruct.irc;




%These variables for making the spectrogram, should not have to mess with
spectrog_window_factor_1s=1000; % the window length is this factor times the length of the wav file
spectrog_window_overlap_factor_1s=0.95; % the overlap is this factor times the window length
spectrog_evaluated_freq_1s=1000*(0:0.1:45); % the frequencies at whichthe spectrogram is evaluated
spectrog_thresh_1s=-95; % spectrogram threshold

% option to start at a different position in folder
prompt = 'What file number do you want to start at?';
fileNum = input(prompt, 's');
fileNum=str2num(fileNum)
set(figure, 'Position', [100, 100, 1049, 895]);

prompt = 'Do you want to categorize call/no call? (y/n)';
catOption = input(prompt,'s');

%make the plots
for mat_i=fileNum:length(fileList)
    load(fullfile(filePath,fileList(mat_i).name));
    %audiovar = recbuf; %change this depending on the data variable (recbuf, audio, etc...)
    dataStruct = load(fullfile(filePath,fileList(mat_i).name),audioVarName);
    rawData = recbuf(:,1);
    %convData = conv(irc,rawData);
    convData = rawData;
    %high pass filter at 800 Hz to filter out low freq. noise
    [bhi,ahi] = butter(8,2*1000/fs,'high');
    data_hpConv = filter(bhi,ahi,convData);
    sound(data_hpConv,60000); %you can change playback speed if you want different sound
    x = [1:length(data_hpConv)]/fs;
    subplot(2,1,1)
    plot(x,data_hpConv) %note this is audio or recbuf depending on file
    title(fullfile(filePath,fileList(mat_i).name),'interpreter', 'none')
    %set(gca,'xlim',[0.2 0.6], 'box','off', 'XTick', [0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6], 'XTickLabel',[],...
        %'YTick',[0 10 20 30 40],'YTickLabel',[]);
    xlabel('Time (ms)')
    ylabel('Signal (v)')
%     try
%         subplot(2,1,2)
%         colormap(hot)
%         [~,~,spec_time,power]=spectrogram(data_hpFilter,spectrog_window_factor_1s,round(spectrog_window_factor_1s*spectrog_window_overlap_factor_1s),spectrog_evaluated_freq_1s,fs,'yaxis','MinThreshold',spectrog_thresh_1s);
%         imagesc(1000*spec_time([1 end]),spectrog_evaluated_freq_1s([1 end])/1000,log(power))
%         axis xy
%         colorbar
%         %set(gca,'xlim',[0.2 0.6], 'box','off', 'XTick', [0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6], 'XTickLabel',[],...
%         %'YTick',[0 10 20 30 40],'YTickLabel',[]);
%         title(fullfile(filePath,fileList(mat_i).name),'interpreter', 'none')
%         xlabel('Time (ms)')
%         ylabel('Frequency (kHz)')
%     catch exception
%         fprintf('Could not plot spectrogram\n')
    %end
    
    % option to copy file into new folder
    if strcmp(catOption,'y')
        recbuf = recbuf(:,1);
        prompt = 'Is it a call? (y/n)';
        s = input(prompt, 's');
        if strcmp(s,'')
            call = fullfile(callPath,fileList(mat_i).name);
            save(call,'audioVarName','convData','data_hpConv','micType','irc','fs','xrun','ampThresh','batName','callNum',...
                'callTrigger','channel','comments','dunceCap','durThresh','EventStartSession','ledCue','ledTimeOut',...
                'maxDelay','maxInt','maxTimeOut','micType','minInt','minWait','motorS','motorT','motuGain','recbuf',...
                'recDur','rmsThresh','sessionID','sessionType'); %call is new folder
        else
            noise = fullfile(noisePath,fileList(mat_i).name);
            save(noise,'audioVarName','convData','data_hpConv','micType','irc','fs','xrun','ampThresh','batName','callNum',...
                'callTrigger','channel','comments','dunceCap','durThresh','EventStartSession','ledCue','ledTimeOut',...
                'maxDelay','maxInt','maxTimeOut','micType','minInt','minWait','motorS','motorT','motuGain','recbuf',...
                'recDur','rmsThresh','sessionID','sessionType'); %noise is new folder
            %else
            %prompt = 'Choose y or n';
        end
    end
    clf
end