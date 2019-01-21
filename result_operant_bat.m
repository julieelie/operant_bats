function result_operant_bat(Path2ParamFile, Logger_dir)
addpath(genpath('/Users/elie/Documents/CODE/LMC'))
TranscExtract = 1;
ForceExtract = 0;
% Get the recording data
[AudioDataPath, DataFile ,~]=fileparts(Path2ParamFile);
Date = DataFile(6:11);
WavFileStruc = dir(fullfile(AudioDataPath, [DataFile(1:16) '*mic*.wav']));

% Get the sound snippets from the sounds that triggered detection
DataSnipStruc = dir(fullfile(AudioDataPath, [DataFile(1:16) '*snippets/*.wav']));

if TranscExtract && nargin<2
% Set the path to logger data
    Logger_dir = fullfile(AudioDataPath(1:(strfind(AudioDataPath, 'audio')-1)), 'logger',Date);
end

% Get the sample stamp of the detected vocalizations
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

figure(100)
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

%% This section is getting ready a plot around the time of one given detected vocalization
% first get the length of all files recorded to localize extract within the
% files
Subj= DataFile(1:4);
Time = DataFile(13:16);
[Length_Y, Sample_on_Y] = get_raw_file_length(AudioDataPath, Subj, Date, Time);
figure(30)
plot([1 ;cumsum(Length_Y(1:end-1))]-Sample_on_Y)
xlabel('file #')
ylabel('delay in recording samples')
            % % Calculate the offset of each soundfile output from the begining of the
% % task in number of samples. Offset_Y is the position of the first sample
% % of each file in the continuous recording (because we are dropping some
% % samples at each file change)
% Length_Filename = fullfile(AudioDataPath, sprintf('%s_Offset_Y.m',DataFile(1:16)));
% if ~exist(Length_Filename, 'file')
%     fprintf(1,'Calculating offset of each sound file to allign extract...\n')
%     FileChangeId = find(strcmp('ChangeFile', Events{EventsEventTypeCol}));
%     Nfiles = length(WavFileStruc);
%     Offset_Y = nan(Nfiles,1);
%     Length_Y = nan(Nfiles,1);
%     ExpDelay_Y = nan(Nfiles,1);
%     for yy=1:Nfiles
%         fprintf(1,'File %d/%d\n', yy,Nfiles)
%         % get the files in the correct order
%         Wavefile=dir(fullfile(WavFileStruc(yy).folder, sprintf('%s*_%d.wav',WavFileStruc(yy).name(1:(end-7)),yy)));
%         Wavefile_local = fullfile(WavFileStruc(yy).folder, Wavefile.name);
%         [Y,FS] = audioread(Wavefile_local);
%         if yy==1 % only calculate the length of the file, there is no offset
%             Length_Y(yy) = length(Y);
%             Offset_Y(yy) = 1;
%             ExpDelay_Y(yy) = 0;
%         else
%             % store the file length
%             Length_Y(yy) = length(Y);
%             % find the first snip of that sequence
%             for ss=1:length(DataSnipStruc)
%                 IndStamp1 = strfind(DataSnipStruc(ss).name, '_');
%                 IndStamp_last = IndStamp1(end);
%                 Sequence = str2double(DataSnipStruc(ss).name((IndStamp1(end-1)+1): (IndStamp1(end)-1)));
%                 Stamp=[];
%                 Ysnip = [];
%                 if Sequence == yy
%                     [Ysnip,~] = audioread(fullfile(DataSnipStruc(ss).folder, DataSnipStruc(ss).name));
%                     Stamp = str2double(DataSnipStruc(ss).name((IndStamp_last+1):end-3)); % Stamp is the position of the first sample of Ysnip
%                     break
%                 end
%             end
%             if Stamp<0
%                 Stamp = 2*2147483647 + Stamp;
%             end
%             
%             if isempty(Stamp)
%             % Find the delay calculated by matlab when changing of file
%             ExpDelay_sec = Events{EventsRewardCol}(FileChangeId(yy-1));
%             ExpDelay_Y(yy) = round(ExpDelay_sec*FS);
%             
%             % Align that snip with the wav of the sequence and get the stamp of the snip
%             Hyp_Stamp = Stamp-(sum(Length_Y(1:(yy-1))) + sum(Offset_Y(1:(yy-1))) + ExpDelay_Y(yy)); % This is the hypothetical position of the first sample of Ysnip in the present recording
%             Y_extract = Y((Hyp_Stamp-length(Ysnip)) : (Hyp_Stamp+2*length(Ysnip)));
%             Ncorr = length(Y_extract) - length(Ysnip);
%             Xcor = nan(Ncorr,1);
%             for cc=1:Ncorr
%                 Xcor(cc) = corr(Ysnip,Y_extract(cc:(cc+length(Ysnip)-1))); % Running a cross correlation between the raw signal centered around the hypothetize position of the snippet and the snippet of sounds
%             end
%             [~,I] = max(abs(Xcor)); % I is the first index of Y_extract that is best alligned with the first index of Ysnip
%             True_Stamp = Hyp_Stamp-length(Ysnip) + I; % This is the index of the first element of Ysnip in Y
%             Offset_Y(yy) = Stamp-True_Stamp+1; % This is the position of the first element of Y in the continuous recording
%             figure(2)
%             cla
%             subplot(1,2,1)
%             plot(1:Ncorr,Xcor)
%             hold on
%             line([I I], [min(Xcor) max(Xcor)], 'Color','r', 'LineStyle','--');
%             text(I , mean(Xcor), sprintf('%d',I))
%             xlabel('Lag')
%             ylabel('correlation coefficient')
%             hold off
%             subplot(1,2,2)
%             plot(Y((Stamp-Offset_Y(yy)) : (Stamp-Offset_Y(yy)+ length(Ysnip)-1)), 'k-', 'LineWidth',2)
%             hold on
%             plot(Ysnip, 'r-')
%             hold off
%             legend('Continuous recording','SoundSnippet')
%             title(sprintf('File %d/%d\n', yy,Nfiles))
%             pause()
%         end
%     end
%     save(Length_Filename,'Offset_Y', 'Length_Y')
% end

% Plot the results
% List of all the detected calls
% Chose a vocalization to center the vizualization tool
fprintf(1,'Now plot the results around a given call\n') 
if ~exist('FS', 'var')
    [~,FS] = audioread(fullfile(WavFileStruc(1).folder, WavFileStruc(1).name));
end
Buffer = 1*FS;% We choose to have one second of recording before and after sound detection onset
IndCenterVoc=1;
while ~isempty(IndCenterVoc)
    FullStamps = Events{EventsStampCol}(VocId);
    
    SoundtimeMinSec = cell(length(FullStamps),1);
    fprintf(1,'The following vocalizations where automatically detected by voc operant.\n Chose the index of the vocalization you want to look at:\n')
    for ss=1:length(FullStamps)
        Ind_ = strfind(FullStamps{ss}, '_');
        Stamp = str2double(FullStamps{ss}((Ind_+1):end));
        if Stamp<0
            Stamp = 2*2147483647 + Stamp; % Correcion of soundmexpro bug that coded numbers in 32 bits instead of 64bits
        end
        MinStamp = floor(Stamp/(60*FS));
        SecStamp = (Stamp - (MinStamp*60*FS))/FS;
        SoundtimeMinSec{ss} = sprintf('%dmin %.1fs', MinStamp, SecStamp);
        fprintf(1, '%d. %s\n', ss,SoundtimeMinSec{ss})
    end
    IndCenterVoc = input('Index of your choice (leave empty to quit):\n');
    if isempty(IndCenterVoc)
        break
    end
    
    Ind_ = strfind(FullStamps{IndCenterVoc}, '_');
    Seq = str2double(FullStamps{IndCenterVoc}(1:(Ind_-1)));
    Stamp = str2double(FullStamps{IndCenterVoc}((Ind_+1):end));
    if Stamp<0
        Stamp = 2*2147483647 + Stamp; % Correcion of soundmexpro bug that coded numbers in 32 bits instead of 64bits
    end
    
    % Get the recording data for the corresponding sequence
    WavFileStruc_local = dir(fullfile(AudioDataPath, sprintf('%s*mic*_%d.wav',DataFile(1:16), Seq)));
    try
        Wavefile_local = fullfile(WavFileStruc_local.folder, WavFileStruc_local.name);
        [Y,FS] = audioread(Wavefile_local);
    catch
        fprintf(1,'Warning: the audiofile %s cannot be read properly and will not be plotted\n', Wavefile_local);
        Y = 0;
    end
    Y_section_beg = max(1,Stamp - Sample_on_Y(Seq) - Buffer+1); % Make sure we don't request before the beginning of the raw wave file
    Pre_stamp = min(Buffer, Stamp - Sample_on_Y(Seq)+1); % Length of the sound section before sound detection onset
    Y_section_end = min(length(Y), Stamp - Sample_on_Y(Seq) +1 + Buffer); % Make sure we don't request after the end of the aw wave file
    Post_stamp = min(Buffer, length(Y)- (Stamp - Sample_on_Y(Seq)+1));% Length of the sound section after sound detection onset
    Y_section = Y(Y_section_beg:Y_section_end);
    
    % Plot the waveforms of the recording around the stamp of the vocalization
    figure(2)
    cla
    plot(Y_section, 'Color', 'k')
    
    
    % plot the sound snippets in red on top
    % Get the sound snippets from the sounds that triggered detection
    DataSnipStruc = dir(fullfile(AudioDataPath, sprintf('%s*snippets/*snipfile_%d_*.wav', DataFile(1:16), Seq)));
    NbSnip_local = length(DataSnipStruc);
    SnipDur = nan(NbSnip_local,1);
    Stamp_all = nan(NbSnip_local,1);
    VocId_all = nan(NbSnip_local,1);
    Voc_event_nb = 0;
    for ss=1:NbSnip_local
        IndStamp1 = strfind(DataSnipStruc(ss).name, '_');
        IndStamp_last = IndStamp1(end);
        Stamp_local = str2double(DataSnipStruc(ss).name((IndStamp_last+1):end-4));
        
        if (Stamp_local < (Stamp + Post_stamp)) && (Stamp_local > (Stamp - Pre_stamp))
            [Ysnip,FS] = audioread(fullfile(DataSnipStruc(ss).folder, DataSnipStruc(ss).name));
            Stamp_local_context = Stamp_local - (Stamp - Pre_stamp);
            % There are often lay-off between the sample value and the
            % actual position within the recording, estimating that lay-off
            % using cross correlation
            DiffY = length(Y_section)-length(Ysnip);
            XcorrY=nan(1,DiffY);
            for cc=1:DiffY
                XcorrY(cc) = corr(Y_section(cc+(1:length(Ysnip))-1),Ysnip);
            end
            [~,Stamp_local_context2] = max(abs(XcorrY));
            Stamp_local_context2=Stamp_local_context2-1;
            Sequence = str2double(DataSnipStruc(ss).name((IndStamp1(end-1)+1):(IndStamp1(end)-1)));
            Voc_event_nb = Voc_event_nb + 1;
            figure(2)
            hold on
            plot(Stamp_local_context:(Stamp_local_context+length(Ysnip)-1), Ysnip, 'Color', 'r')
            hold on
            plot(Stamp_local_context2:(Stamp_local_context2+length(Ysnip)-1), Ysnip, 'Color', 'g')
            % Search for the corresponding datapoint in the event log
            Index =[];
            for ii=1:length(VocId)
                if strcmp(Events{EventsStampCol}{VocId(ii)}, sprintf('%d_%d', Sequence, Stamp_local))
                    Index = ii;
                    break
                end
            end
            if isempty(Index)
                error('event %d_%d cannot be found in the eventlog file\n', Sequence, Stamp_local);
            else
                Stamp_all(Voc_event_nb) = Stamp_local;
                SnipDur(Voc_event_nb) = length(Ysnip);
                VocId_all(Voc_event_nb) = VocId(Index);
            end
        end
    end
    
    % plot the time stamp when sound was detected (last time point of each sound snippet)
    % color code the point given the reward status
    % Get the VocId should be plotted, from the log
    VocId_log = nan(1,length(VocId));
    Stamp_all_log = nan(1,length(VocId));
    SnipDur_log = nan(1,length(VocId));
    Voc_event_nb_log = 0;
    for ii=1:length(VocId)
        FullStamp = Events{EventsStampCol}{VocId(ii)};
        IndStamp = strfind(FullStamp, '_');
        Seq_local = str2double(FullStamp(1:(IndStamp-1)));
        Stamp_local = str2double(FullStamp((IndStamp+1):end));
        if (Seq_local == Seq) && (Stamp_local >= (Stamp-Pre_stamp)) && (Stamp_local <= (Stamp+Post_stamp)) % This is a vocalization from the same section
            Voc_event_nb_log = Voc_event_nb_log+1;
            VocId_log(Voc_event_nb_log) = VocId(ii);
            Stamp_all_log(Voc_event_nb_log) = Stamp_local;
            try
                SnipDur_log(Voc_event_nb_log) = SnipDur(find(VocId_all==VocId(ii)));
            catch
                warning('This sound detection event does not have a corresponding sound snippet %s',FullStamp);
                SnipDur_log(Voc_event_nb_log) = NaN;
            end
        end
    end
    VocId_log = VocId_log(1:Voc_event_nb_log);
    Stamp_all_log = Stamp_all_log(1:Voc_event_nb_log);
    SnipDur_log = SnipDur_log(1:Voc_event_nb_log);
    
    ReFront = Events{EventsFoodPortFrontCol}(VocId_log);
    ReBack = Events{EventsFoodPortBackCol}(VocId_log);
    Colorcode = get(groot,'DefaultAxesColorOrder');
    ColorFront= nan(size(ReFront,1),3);
    ColorBack= ColorFront;
    ColorFront(find(ReFront==1),:) = repmat(Colorcode(3,:),sum(ReFront==1),1);
    ColorBack(find(ReBack==1),:) = repmat(Colorcode(3,:), sum(ReBack==1),1);
    ColorFront(find(ReFront==0),:) = repmat([0 0 0],sum(ReFront==0),1);
    ColorBack(find(ReBack==0),:) = repmat([0 0 0], sum(ReBack==0),1);
    ColorFront(find(isnan(ReFront)),:) = repmat([1 0 0],sum(isnan(ReFront)),1);
    ColorBack(find(isnan(ReBack)),:) = repmat([1 0 0], sum(isnan(ReBack)),1);
    figure(2)
    hold on
    sc=scatter(Stamp_all_log+SnipDur_log-1 - (Stamp - Pre_stamp), 1.2*ones(length(VocId_log),1), 10, ColorFront, 'filled');
    hold on
    sc=scatter(Stamp_all_log+SnipDur_log-1 - (Stamp - Pre_stamp), 1.6*ones(length(VocId_log),1), 10, ColorBack, 'filled');
    
    XaxisRes=20;
    LengthY = length(Y_section);
    set(gca, 'XLim',[0;LengthY]);
    
    if (LengthY/FS)>XaxisRes
        XaxisStep = round(LengthY/(FS*XaxisRes));
    else
        XaxisStep = round(LengthY/(FS*XaxisRes),2);
    end
    set(gca,'XTick', 0:(XaxisStep*FS):LengthY, 'XTickLabel', 0:XaxisStep:round(LengthY/FS), 'YLim',[-1 2]);
    xlabel('Time (s)');
    ylabel('Sound pressure')
end



%% Extracting sound events
if TranscExtract
    % extract logger data if not already done
    All_loggers_dir = dir(fullfile(Logger_dir, '*ogger*'));
    for ll=1:length(All_loggers_dir)
        Logger_local = fullfile(Logger_dir,All_loggers_dir(ll).name);
        EvFiles = dir(fullfile(Logger_local,'*EVENTS*mat'));
        if isempty(EvFiles) || ForceExtract
            extract_logger_data(Logger_local)
        end
    end
    % Alligning TTL pulses between soundmexpro and Deuteron
    align_soundmexAudio_2_logger(AudioDataPath, Logger_dir, ExpStartTime,'TTL_pulse_generator','Avisoft','Method','RiseFall', 'Session_strings', {'all voc reward start', 'all voc reward stop'});
    voc_localize_operant(DataSnipStruc(1).folder, DataPath, DataFile(6:11), DataFile(13:16))
else
    voc_localize_operant(DataSnipStruc(1).folder, DataPath, DataFile(6:11), DataFile(13:16),'TransceiverTime',0)
end
% Get the list of sound triggers
FullStamps = Events{EventsStampCol}(VocId);
NSoundE = length(FullStamps);
SeqStamps = nan(NSoundE,1);
IndStamps = nan(NSoundE,1);
for ss=1:NSoundE
    Ind_ = strfind(FullStamps{ss}, '_');
    IndStamps(ss) = str2double(FullStamps{ss}((Ind_+1):end));
    SeqStamps(ss) = str2double(FullStamps{ss}(1:(Ind_-1)));
end
