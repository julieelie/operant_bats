function result_operant_bat2(Path2ParamFile, Path2RecordingTable, Logger_dir)
addpath(genpath('/Users/elie/Documents/CODE/LMC'))
addpath(genpath('/Users/elie/Documents/CODE/LoggerDataProcessing'))
addpath(genpath('/Users/elie/Documents/CODE/SoundAnalysisBats'))
TranscExtract = 1; % set to 1 to extract logger data and transceiver time
ForceExtract = 0; % set to 1 to redo the extraction of loggers otherwise the calculations will use the previous extraction data
ForceAllign = 0; % In case the TTL pulses allignment was already done but you want to do it again, set to 1
ForceVocExt1 = 0; % In case the extraction of vocalizations that triggered rewarding system was already done but you want to do it again set to 1
ForceVocExt2 = 0; % In case the extraction of vocalizations that triggered rewarding system was already done but you want to do it again set to 1
ForceWhoID = 0; % In case the identification of bats was already done but you want to re-do it again
ForceWhat = 1; % In case running biosound was already done but you want to re-do it
PlotIndivFile = 0; % Set to 1 to plot the sound pressure waveforms of individual detected vocalizations
close all
% Get the recording data
[AudioDataPath, DataFile ,~]=fileparts(Path2ParamFile);
Date = DataFile(6:11);
WavFileStruc = dir(fullfile(AudioDataPath, [DataFile(1:16) '*mic*.wav']));

% Get the sound snippets from the sounds that triggered detection
DataSnipStruc = dir(fullfile(AudioDataPath, [DataFile(1:16) '*snippets/*.wav']));

if TranscExtract && nargin<2
    Path2RecordingTable = '/Users/elie/Google Drive/BatmanData/RecordingLogs/recording_logs.xlsx';
end
if TranscExtract && nargin<3
    % Set the path to logger data
    Logger_dir = fullfile(AudioDataPath(1:(strfind(AudioDataPath, 'audio')-1)), 'logger',['20' Date]);
end

% Set the path to a working directory on the computer so logger data are
% transfered there and directly accessible for calculations
if TranscExtract
    WorkDir = ['~' filesep 'WorkingDirectory'];
end

%% Get the sample stamp of the detected vocalizations
fprintf(1,'*** Getting events for that day ***\n');
DataFileStruc = dir(fullfile(AudioDataPath, [DataFile(1:16) '*events.txt']));
Fid_Data = fopen(fullfile(DataFileStruc.folder,DataFileStruc.name));
EventsHeader = textscan(Fid_Data, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
for hh=1:length(EventsHeader)
    if strfind(EventsHeader{hh}{1}, 'SampleStamp')
        EventsStampCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'Type')
        EventsEventTypeCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'FoodPortFront')
        EventsFoodPortFrontCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'FoodPortBack')
        EventsFoodPortBackCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'TimeStamp(s)')
        EventsTimeCol = hh;
    elseif strfind(EventsHeader{hh}{1}, 'Delay2Reward')
        EventsRewardCol = hh;
    end
end
Events = textscan(Fid_Data, '%s\t%f\t%s\t%s\t%f\t%f\t%f');
fclose(Fid_Data);
VocId = find(strcmp('Vocalization', Events{EventsEventTypeCol}));

%% Plot the cumulative number of triggers along time
fprintf(1,'*** Plotting cumulative events for that day ***\n');
ColorCode = get(groot,'DefaultAxesColorOrder');
ReTriggerVocId = find(~isnan(Events{EventsRewardCol}));
ReVocId = find(~(isnan(Events{EventsRewardCol}) + isinf(Events{EventsRewardCol})));

F=figure(100);
plot(Events{EventsTimeCol}(VocId)/60,1:length(VocId), 'k-', 'Linewidth',2)
hold on
plot(Events{EventsTimeCol}(ReTriggerVocId)/60, 1:length(ReTriggerVocId), '-','Color',ColorCode(1,:),'Linewidth',2)
hold on
plot(Events{EventsTimeCol}(ReVocId)/60, 1:length(ReVocId), '-','Color',ColorCode(3,:),'Linewidth',2)
legend('Sound detection events', 'Sound trigger events', 'Rewarded sound events','Location','NorthWest')
xlabel('Time (min)')
ylabel('Cumulative sum of events')
hold off
title(sprintf('Subjects: %s  Date: %s  Time: %s', DataFile(1:4), DataFile(6:11), DataFile(13:16)))
hold off
saveas(F,fullfile(AudioDataPath,sprintf('%s_CumTrigger.fig', DataFile(1:16))))
saveas(F,fullfile(AudioDataPath,sprintf('%s_CumTrigger.jpeg', DataFile(1:16))))



%% Extracting sound events
% The samplestamp given by sound mex is not really reliable, so for each
% sound snippet, you want to find its exact location in the continuous
% recording files, then using TTL pulses, retrieve the time it correspond
% to in Deuteron, if requested.

% Checking what we have in terms of vocalization localization/extraction
ExpStartTime = DataFile(13:16);
VocExt_dir = dir(fullfile(AudioDataPath,sprintf('%s_%s_VocExtractTimes.mat', Date, ExpStartTime)));

% Then run the logger extraction, allignment, and vocalization extraction
if TranscExtract
    fprintf(1,'*** Extract Logger data if not already done ***\n');
    % Find the ID of the recorded bats
    [~,~,RecTableData]=xlsread(Path2RecordingTable,1,'A1:P200','basic');
    RowData = find((cell2mat(RecTableData(2:end,1))== str2double(Date))) +1;
    DataInfo = RecTableData(RowData,:);
    Header = RecTableData(1,:);
    BatIDCol = find(contains(Header, 'Bat'));
    
    % extract logger data if not already done
    All_loggers_dir = dir(fullfile(Logger_dir, '*ogger*'));
    DirFlags = [All_loggers_dir.isdir];
    % Extract only those that are directories.
    All_loggers_dir = All_loggers_dir(DirFlags);
    TransceiverReset = struct(); % These are possible parameters for dealing with change of transceiver or sudden transceiver clock change. Set to empty before the first extraction
    LoggerName = cell(length(All_loggers_dir),1);
    BatID = cell(length(All_loggers_dir),1);
    for ll=1:length(All_loggers_dir)
        Logger_i = fullfile(Logger_dir,All_loggers_dir(ll).name);
        Ind = strfind(All_loggers_dir(ll).name, 'r');
        Logger_num = str2double(All_loggers_dir(ll).name((Ind+1):end));
        NLogCol = find(contains(Header, 'NL'));% Columns of the neural loggers
        ALogCol = find(contains(Header, 'AL'));% Columns of the audio loggers
        LogCol = NLogCol(find(cell2mat(DataInfo(NLogCol))==Logger_num));
        if isempty(LogCol) % This is an audiologger and not a neural logger
            LogCol = ALogCol(find(cell2mat(DataInfo(ALogCol))==Logger_num));
            LoggerName{ll} = ['AL' num2str(Logger_num)];
        else
            LoggerName{ll} = ['NL' num2str(Logger_num)];
        end
        BatID{ll} = DataInfo{BatIDCol(find(BatIDCol<LogCol,1,'last'))};
        ParamFiles = dir(fullfile(Logger_i,'extracted_data','*extract_logger_data_parameters*mat'));
        if isempty(ParamFiles) || ForceExtract
            fprintf(1,'-> Extracting %s\n',All_loggers_dir(ll).name);
            
            % Bring data back on the computer
            Logger_local = fullfile(WorkDir, All_loggers_dir(ll).name);
            fprintf(1,'Transferring data from the server %s\n on the local computer %s\n', Logger_i, Logger_local);
            mkdir(Logger_local)
            [s,m,e]=copyfile(Logger_i, Logger_local, 'f');
            if ~s
                m %#ok<NOPRT>
                e %#ok<NOPRT>
                error('File transfer did not occur correctly for %s\n', Logger_i);
            end
            
            % run extraction
            if Logger_num==16 && str2double(Date)<190501
                % extract_logger_data(Logger_local, 'BatID', num2str(BatID), 'ActiveChannels', [0 1 2 3 4 5 6 7 8 9 10 12 13 14 15], 'AutoSpikeThreshFactor',5,'TransceiverReset',TransceiverReset)
                extract_logger_data(Logger_local, 'BatID', num2str(BatID{ll}), 'ActiveChannels', [0 1 2 3 4 5 6 7 8 9 10 12 13 14 15],'TransceiverReset',TransceiverReset,'AutoSpikeThreshFactor',4)
            else
                %extract_logger_data(Logger_local, 'BatID', num2str(BatID),'TransceiverReset',TransceiverReset)
                extract_logger_data(Logger_local, 'BatID', num2str(BatID{ll}),'TransceiverReset',TransceiverReset,'AutoSpikeThreshFactor',4)
            end
            
            % Keeps value of eventual clock reset
            Filename=fullfile(Logger_local, 'extracted_data', sprintf('%s_20%s_EVENTS.mat', num2str(BatID{ll}),Date));
            NewTR = load(Filename, 'TransceiverReset');
            if ~isempty(fieldnames(NewTR.TransceiverReset))% this will be used in the next loop!
                TransceiverReset = NewTR.TransceiverReset;
            end
            
            % Bring back data on the server
            fprintf(1,'Transferring data from the local computer %s\n back on the server %s\n', Logger_i, Logger_local);
            Remote_dir = fullfile(Logger_i, 'extracted_data');
            mkdir(Remote_dir)
            [s,m,e]=copyfile(fullfile(Logger_local, 'extracted_data'), Remote_dir, 'f');
            if ~s
                TicTransfer = tic;
                while toc(TicTransfer)<30*60
                    [s,m,e]=copyfile(fullfile(Logger_local, 'extracted_data'), Remote_dir, 'f');
                    if s
                        return
                    end
                end
                if ~s
                    s %#ok<NOPRT>
                    m %#ok<NOPRT>
                    e %#ok<NOPRT>
                    error('File transfer did not occur correctly for %s\n Although we tried for 30min\n', Remote_dir);
                else
                    fprintf('Extracted data transfered back on server in:\n%s\n',  Remote_dir);
                end
            else
                fprintf('Extracted data transfered back on server in:\n%s\n',  Remote_dir);
            end
            if s  %erase local data
                [sdel,mdel,edel]=rmdir(WorkDir, 's');
                if ~sdel
                    TicErase = tic;
                    while toc(TicErase)<30*60
                        [sdel,mdel,edel]=rmdir(WorkDir, 's');
                        if sdel
                            return
                        end
                    end
                end
                if ~sdel
                    sdel %#ok<NOPRT>
                    mdel %#ok<NOPRT>
                    edel %#ok<NOPRT>
                    error('File erase did not occur correctly for %s\n Although we tried for 30min\n', WorkDir);
                end
            end
            
        else
            fprintf(1,'-> Already done for %s\n',All_loggers_dir(ll).name);
        end
    end
    
    % Get the serial numbers of the audiologgers that the two implanted
    % bats wear
    NLCol = find(contains(Header, 'NL'));
    ALThroatCol = find(contains(Header, 'AL-throat'));
    SerialNumberAL = nan(length(NLCol),1);
    SerialNumberNL = nan(length(NLCol),1);
    for dd=1:length(NLCol)
        SerialNumberAL(dd) = DataInfo{ALThroatCol(find(ALThroatCol<NLCol(dd),1,'last'))};
        SerialNumberNL(dd) = DataInfo{NLCol(dd)};
    end
    
    % Alligning TTL pulses between soundmexpro and Deuteron
    % for the Operant session
    
    TTL_dir = dir(fullfile(AudioDataPath,sprintf( '%s_%s_TTLPulseTimes.mat', Date, ExpStartTime)));
    if isempty(TTL_dir) || ForceAllign
        fprintf(1,'*** Alligning TTL pulses for the operant session ***\n');
        align_soundmexAudio_2_logger(AudioDataPath, Logger_dir, ExpStartTime,'TTL_pulse_generator','Avisoft','Method','risefall', 'Session_strings', {'all voc reward start', 'all voc reward stop'}, 'Logger_list', [SerialNumberAL; SerialNumberNL]);
    else
        fprintf(1,'*** ALREADY DONE: Alligning TTL pulses for the operant session ***\n');
    end
    if isempty(VocExt_dir) || ForceVocExt1
        fprintf(1,'*** Localizing and extracting vocalizations that triggered the sound detection ***\n');
        voc_localize_operant(AudioDataPath, DataFile(1:4),Date, ExpStartTime, 'UseSnip',0)
    else
        fprintf(1,'*** ALREADY DONE: Localizing and extracting vocalizations that triggered the sound detection ***\n');
    end
    
    %% Identify the same vocalizations on the piezos and save sound extracts, onset and offset times
    fprintf(' LOCALIZING VOCALIZATIONS ON PIEZO RECORDINGS\n')
    LogVoc_dir = dir(fullfile(Logger_dir, sprintf('%s_%s_VocExtractData.mat', Date, ExpStartTime)));
    if isempty(LogVoc_dir) || ForceVocExt1 || ForceVocExt2
        get_logger_data_voc(AudioDataPath, Logger_dir,Date, ExpStartTime, 'SerialNumber',SerialNumberAL);
    else
        fprintf(1,'Using already processed data\n')
        
    end
    
    %% Identify who is calling
    fprintf(' IDENTIFY WHO IS CALLING\n')
    WhoCall_dir = dir(fullfile(Logger_dir, sprintf('*%s_%s*whocalls*', Date, ExpStartTime)));
    if isempty(WhoCall_dir) || ForceVocExt1 || ForceWhoID || ForceVocExt2
        who_calls(AudioDataPath, Logger_dir,Date, ExpStartTime,200,1);
    else
        fprintf(1,'Using already processed data\n')
    end
    % Save the ID of the bat for each logger
    save(fullfile(Logger_dir, sprintf('%s_%s_VocExtractData_%d.mat', Date, ExpStartTime, 200)), 'BatID','LoggerName','-append')

     %% Explore what is said
    fprintf('\n*** Identify what is said ***\n')
    WhatCall_dir = dir(fullfile(Logger_dir, sprintf('*%s_%s*whatcalls*', Date, ExpStartTime)));
    if isempty(WhatCall_dir) || ForceVocExt1 || ForceWhoID || ForceVocExt2 || ForceWhat
        what_calls(Logger_dir,Date, ExpStartTime);
    else
        fprintf('\n*** ALREADY DONE: Identify what is said ***\n')
    end
    
elseif isempty(VocExt_dir) || ForceVocExt1
    fprintf(1,'*** Localizing and extracting vocalizations that triggered the sound detection ***\n');
    fprintf(1,'NOTE: no transceiver time extraction\n')
    voc_localize_operant(AudioDataPath, DataFile(1:4),Date, ExpStartTime, 'UseSnip',0,'TransceiverTime',0)
else
    fprintf(1,'*** ALREADY DONE: Localizing and extracting vocalizations that triggered the sound detection ***\n');
end





end
