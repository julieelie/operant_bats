% This script gather all the VocTrigger experiments longer than 10min with
% aminimum of 5 calls
% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
MinVoc = 5;
MinDur = 10;%(in min)
OutputDataPath = 'Z:\users\tobias\vocOperant\Exp_Stats';
BaseDir = 'Z:\users\tobias\vocOperant';
BoxOfInterest = [1 2 3 4 5 6 7 8];
ExpLog = fullfile(OutputDataPath, 'VocOperantData.txt');
AllLog = fullfile(OutputDataPath, 'VocOperantAllData.txt');
delete(fullfile(OutputDataPath, 'StatsDiary.txt'));
diary(fullfile(OutputDataPath, sprintf('StatsDiary_%s.txt', date)));
AllExpCount = 0;
ExpMissMicDataCount = 0;
ExpTooShortCount = 0;
ExpTooFewCallsCount = 0;
ExpMissLogDataCount = 0;


Fid = fopen(ExpLog, 'w');
FidAll = fopen(AllLog, 'w');
fprintf(Fid, 'FileName\tBoxNum\tHigh-Pass(Hz)\tLow-Pass(Hz)\tNumVocs\tDuration(min)\n');
fprintf(FidAll, 'FileName\tBoxNum\tHigh-Pass(Hz)\tLow-Pass(Hz)\tNumVocs\tDuration(min)\tMicData\tLoggerData\n');


for bb=1:length(BoxOfInterest) % for each box
    ParamFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_param.txt'));
    
    for ff=1:length(ParamFilesDir)
        
        Filepath = fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        BoxID = BoxOfInterest(bb);
        fprintf(1,'\n\n\nBox %d (%d/%d), file %d/%d:\n%s\n',BoxID,bb,length(BoxOfInterest),ff,length(ParamFilesDir),Filepath)
        if strcmp(ParamFilesDir(ff).name(1:4), 'tete')
            fprintf(1, 'Test of the system not true dataset\n')
            continue
        end
        
        % check that the experiment has data!
        MicFiles = dir(fullfile(ParamFilesDir(ff).folder, [ParamFilesDir(ff).name(1:27) '_mic1*']));
        fid = fopen(Filepath);
        data = textscan(fid,'%s','Delimiter', '\t');
        fclose(fid);
        IndexLine = find(contains(data{1}, 'Task stops at'));
        if ~isempty(IndexLine)
            IndexChar = strfind(data{1}{IndexLine},'after');
            IndexChar2 = strfind(data{1}{IndexLine},'seconds');
            
            % find the data into that line
            Temp = round(str2double(data{1}{IndexLine}((IndexChar + 6):(IndexChar2-2)))/60);% duration in min
        else %No stop line, estimate the duration of the experiment by looking at the number of microphone files
            Temp = (length(MicFiles)-1)*10;
        end
        MicData = isempty(MicFiles);
        
        % Check that the experiment has logger data
        Logger_dir = fullfile(ParamFilesDir(ff).folder(1:(strfind(ParamFilesDir(ff).folder, 'bataudio')-1)), 'piezo',ParamFilesDir(ff).name(6:11),'audiologgers');
        All_loggers_dir = dir(fullfile(Logger_dir, '*ogger*'));
        LogData = isempty(All_loggers_dir);
        
        % Find corresponding event file and get number of vocalizations
        DataFileStruc = dir(fullfile(BaseDir,sprintf('box%d',BoxID), 'bataudio', [ParamFilesDir(ff).name(1:16), '*_VocTrigger_events.txt']));
        numVocs = -1; % set numVocs to < 0 if no data
        if ~isempty(DataFileStruc) > 0
            Fid_Data = fopen(fullfile(DataFileStruc.folder,DataFileStruc.name));
            EventsHeader = textscan(Fid_Data, '%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
            Events = textscan(Fid_Data, '%s\t%f\t%s\t%s\t%f\t%f\t%f');
            fclose(Fid_Data);
            vocID = find(strcmp('Vocalization', Events{4})); % Type column, hard-coded
            numVocs = length(vocID);
        else
            fprintf(1, 'No EventFile! MicData =%d and LoggerData=%d\n', MicData, LogData)
        end
        % FIND the low pass and high pass filters applied
        IndexLineHigh = find(contains(data{1}, 'high-pass'));
        IndexLineLow = find(contains(data{1}, 'low-pass'));
        if ~isempty(IndexLineLow)
            IndexChar = strfind(data{1}{IndexLineLow},'threshold: ');
            IndexChar2 = strfind(data{1}{IndexLineLow},'Hz');
            % find the data (low threshold) in that line
            low = str2double(data{1}{IndexLineLow}((IndexChar + 11):(IndexChar2-2)));
        else
            low = nan;
        end
        
        if ~isempty(IndexLineHigh)
            IndexCharHigh = strfind(data{1}{IndexLineHigh},'threshold: ');
            IndexChar2High = strfind(data{1}{IndexLineHigh},'Hz');
            % find the data (high threshold) in that line
            high = str2double(data{1}{IndexLineHigh}((IndexCharHigh + 11):(IndexChar2High-2)));
        else
            high = nan;
        end
        
        if (numVocs >= MinVoc) && (Temp>MinDur) && ~MicData && ~LogData
            try
                % prints batIDs, date, time, low threshold, high threshold, and number of vocalizations
                fprintf(Fid, '%s\t%s%d\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name, 'box', BoxID, high, low, numVocs, Temp);
                fprintf(FidAll, '%s\t%s%d\t%f\t%f\t%d\t%d\t%d\t%d\n',ParamFilesDir(ff).name, 'box', BoxID, high, low, numVocs, Temp, ~MicData, ~LogData);
            catch
                keyboard
            end
        else
            fprintf(FidAll, '%s\t%s%d\t%f\t%f\t%d\t%d\t%d\t%d\n',ParamFilesDir(ff).name, 'box', BoxID, high, low, numVocs, Temp,  ~MicData, ~LogData);
        end
        
        AllExpCount = AllExpCount +1;
        ExpMissMicDataCount = ExpMissMicDataCount + MicData;
        if ~MicData % There are mic data
            ExpTooShortCount = ExpTooShortCount + (Temp<=MinDur) ; % count if too short
            if Temp>MinDur % There are mic data and long enough
                ExpTooFewCallsCount = ExpTooFewCallsCount + (numVocs < MinVoc); % count if note enough calls
                if numVocs >= MinVoc% There are mic data and long enough and enough calls
                    ExpMissLogDataCount = ExpMissLogDataCount + LogData; % count if no Logger data
                end
            end
        end
        
    end
end
fclose(Fid);
fclose(FidAll);
fprintf(1,'Total # of experiments: %d\n', AllExpCount)
fprintf(1, 'Experiments with missing microphone data: %d/%d, %d%%\n', ExpMissMicDataCount,AllExpCount, round(ExpMissMicDataCount*100/AllExpCount))
fprintf(1, 'Experiments with Mic data that are too short: %d/%d, %d%%\n', ExpTooShortCount, AllExpCount-ExpMissMicDataCount, round(ExpTooShortCount*100/(AllExpCount-ExpMissMicDataCount)))
fprintf(1, 'Experiments with Mic data, longer that %d min that have too few calls: %d/%d, %d%%\n',MinDur, ExpTooFewCallsCount, AllExpCount-ExpMissMicDataCount-ExpTooShortCount, round(ExpTooFewCallsCount*100/(AllExpCount-ExpMissMicDataCount-ExpTooShortCount)))
fprintf(1, 'Experiments with Mic data, longer that %d min, with >= %d calls that have no logger data: %d/%d, %d%%\n',MinDur, MinVoc,ExpMissLogDataCount, AllExpCount-ExpMissMicDataCount-ExpTooShortCount-ExpTooFewCallsCount, round(ExpMissLogDataCount*100/(AllExpCount-ExpMissMicDataCount-ExpTooShortCount-ExpTooFewCallsCount)))
TotCleanExp = AllExpCount-ExpMissMicDataCount-ExpTooShortCount-ExpTooFewCallsCount-ExpMissLogDataCount;
fprintf(1, 'total number of clean experiments to process: %d\n', TotCleanExp)
diary OFF

%% Stats of number fo experiments that went through vocalization detection
BaseDataDir = 'Z:\users\tobias\vocOperant';
BaseCodeDir = 'C:\Users\tobias\Documents\GitHub\operant_bats';
OutputDataPath = 'Z:\users\tobias\vocOperant\Exp_Stats';
ExpLog = fullfile(BaseDataDir, 'Results', 'VocOperantLogWhoCalls.txt'); % in results (process one done/no)
WhoLogOld = fullfile(BaseDataDir, 'Results', 'VocOperantLogWhoCallsDoneOld.txt'); % points to files in which manual curation has been done with older wrapper_WhoCalls.m (note that wrapper_WhoCalls has been changed by NW Fall 2020 after it's been used and never used after NW changes...)
WhoLog = fullfile(BaseDataDir, 'Results', 'VocOperantLogWhoCallsDone.txt'); % points to files in which manual curation has been done
AllLog = fullfile(OutputDataPath, 'VocOperantAllData.txt');

% Files that have their trigger sequences extracted by
% wrapper_result_operant2
FidExp = fopen(ExpLog, 'r');
Header = textscan(FidExp,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
DoneListDetect = textscan(FidExp,'%s\t%s\t%s\t%s\t%s\t%s\t%s\n'); % formerly '%s\t%s\t%s\t%s\t%.1f\t%d'
fclose(FidExp);

% Extract list of files that have been manually cured using older
% wrapper_WhoCalls
FidWhoOld = fopen(WhoLogOld, 'r');
HeaderWhoOld = textscan(FidWhoOld,'%s\t%s\t%s\t%s\t%s\t%s\n',1);
DoneListWhoOld = textscan(FidWhoOld,'%s\t%s\t%s\t%s\t%.1f\t%d');
fclose(FidWhoOld);

% Extract list of files that have been manually cured using CallCura
FidWho = fopen(WhoLog, 'r');
HeaderWho = textscan(FidWho,'%s\t%s\t%s\t%s\n',1);
DoneListWho = textscan(FidWho,'%s\t%s\t%s\t%d');
fclose(FidWho);

% Get the original List of all experiments
FidAll = fopen(AllLog, 'r');
HeaderAll = textscan(FidAll,'%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n',1);
ListAll = textscan(FidAll,'%s\t%s\t%f\t%f\t%d\t%d\t%d\t%d');
fclose(FidAll);



% Files that belong to the list of DoneListDetect and DoneListWhoOld have
% their sequences extracted
ExtractedExp.Subject = [DoneListDetect{1}; DoneListWhoOld{1}; DoneListWho{1}];
ExtractedExp.Date = [DoneListDetect{2}; DoneListWhoOld{2}; DoneListWho{2}];
ExtractedExp.Time = [DoneListDetect{3}; DoneListWhoOld{3}; DoneListWho{3}];
% eliminate data duplicates
Dup = zeros(1,length(ExtractedExp.Subject));
for ee=1:length(ExtractedExp.Subject)
    Duplicate = find(contains(ExtractedExp.Subject((ee+1):end), ExtractedExp.Subject{ee}) .* contains(ExtractedExp.Date((ee+1):end), ExtractedExp.Date{ee}) .* contains(ExtractedExp.Time((ee+1):end), ExtractedExp.Time{ee}));
    if ~isempty(Duplicate)
        Dup(ee+Duplicate) = 1;
        Duplicate = [];
    end
end
ExtractedExp.Subject(logical(Dup)) = [];
ExtractedExp.Date(logical(Dup)) = [];
ExtractedExp.Time(logical(Dup)) = [];
fprintf(1, 'Experiments with extracted trigger sequences: %d/%d, %d%%\n', length(ExtractedExp.Subject), TotCleanExp, round(length(ExtractedExp.Subject)/TotCleanExp*100))

% Experiments that have been manually curated
CuratedExp.Subject = [DoneListWhoOld{1}; DoneListWho{1}];
CuratedExp.Date = [DoneListWhoOld{2}; DoneListWho{2}];
CuratedExp.Time = [DoneListWhoOld{3}; DoneListWho{3}];
% eliminate data duplicates
Dup = zeros(1,length(CuratedExp.Subject));
for ee=1:length(CuratedExp.Subject)
    Duplicate = find(contains(CuratedExp.Subject((ee+1):end), CuratedExp.Subject{ee}) .* contains(CuratedExp.Date((ee+1):end), CuratedExp.Date{ee}) .* contains(CuratedExp.Time((ee+1):end), CuratedExp.Time{ee}));
    if ~isempty(Duplicate)
        Dup(ee+Duplicate) = 1;
        Duplicate = [];
    end
end
CuratedExp.Subject(logical(Dup)) = [];
CuratedExp.Date(logical(Dup)) = [];
CuratedExp.Time(logical(Dup)) = [];
fprintf(1, 'Experiments with manually curated vocalizations: %d/%d, %d%%\n', length(CuratedExp.Subject), TotCleanExp, round(length(CuratedExp.Subject)/TotCleanExp*100))

% Gather the number of vocalizations manually curated for each experiment
CuratedExp.NumVoc = zeros(length(CuratedExp.Subject),1);
CuratedExp.Box = nan(length(CuratedExp.Subject),1);
CuratedExp.High = nan(length(CuratedExp.Subject),1);
CuratedExp.Low = nan(length(CuratedExp.Subject),1);
CuratedExp.HighLow = cell(length(CuratedExp.Subject),1);
CuratedExp.NumSeq = zeros(length(CuratedExp.Subject),1);
CuratedExp.NumFullSeq = zeros(length(CuratedExp.Subject),1); % Sequences with vocalizations

for ee=1:length(CuratedExp.Subject)
    Ind = find(contains(ListAll{1}, [CuratedExp.Subject{ee} '_' CuratedExp.Date{ee} '_' CuratedExp.Time{ee}]));
    CuratedExp.Box(ee) = str2double(ListAll{2}{Ind}(4:end));
    CuratedExp.High(ee) = ListAll{3}(Ind);
    CuratedExp.Low(ee) = ListAll{4}(Ind);
    CuratedExp.HighLow{ee} = [num2str(ListAll{3}(Ind)) '-' num2str(ListAll{4}(Ind))];
    ManuFiles = dir(fullfile(BaseDataDir,ListAll{2}{Ind},'piezo', CuratedExp.Date{ee}, 'audiologgers', sprintf('%s_%s_VocExtractData_*', CuratedExp.Date{ee}, CuratedExp.Time{ee})));
    for ff=1:length(ManuFiles)
        load(fullfile(ManuFiles(ff).folder, ManuFiles(ff).name), 'IndVocStartRaw_merged')
        CuratedExp.NumSeq(ee) = length(IndVocStartRaw_merged)+CuratedExp.NumSeq(ee);
        NumCall = nan(length(IndVocStartRaw_merged),1);
        for cc=1:length(IndVocStartRaw_merged)
            if ~isempty(IndVocStartRaw_merged{cc})
                NumCall(cc)=length([IndVocStartRaw_merged{cc}{:}]);
            else
                NumCall(cc) = 0;
            end
        end
        CuratedExp.NumFullSeq(ee) = sum(NumCall>0)+CuratedExp.NumFullSeq(ee);
        CuratedExp.NumVoc(ee) = sum(NumCall)+ CuratedExp.NumVoc(ee);
        clear IndVocStartRaw_merged
    end
end
fprintf(1, 'Total number of sequences with vocalizations %d/%d, %d%%\n', sum(CuratedExp.NumFullSeq),sum(CuratedExp.NumSeq),round(sum(CuratedExp.NumFullSeq)*100/sum(CuratedExp.NumSeq)))
fprintf(1, 'Total number of vocalizations %d\n', sum(CuratedExp.NumVoc))

%% Some figures
SubjectsID = unique(CuratedExp.Subject);
HighLowID = unique(CuratedExp.HighLow);
SubjectsNExp = nan(length(SubjectsID),1);
SubjectsNCall = nan(length(SubjectsID),1);
SubjectsNFullSeq = nan(length(SubjectsID),1);
SubjectsNEmptySeq = nan(length(SubjectsID),1);
SubjectsNFullSeqHighLow = nan(length(SubjectsID), length(HighLowID));
for ss=1:length(SubjectsID)
    SubjectsNExp(ss) = sum(contains(CuratedExp.Subject, SubjectsID(ss)));
    SubjectsNFullSeq(ss) = sum(CuratedExp.NumFullSeq(contains(CuratedExp.Subject, SubjectsID(ss))));
    SubjectsNEmptySeq(ss) = sum(CuratedExp.NumSeq(contains(CuratedExp.Subject, SubjectsID(ss))))-SubjectsNFullSeq(ss);
    SubjectsNCall(ss) = sum(CuratedExp.NumVoc(contains(CuratedExp.Subject, SubjectsID(ss))));
    for ll=1:length(HighLowID)
        Indices = contains(CuratedExp.Subject, SubjectsID(ss)) .* contains(CuratedExp.HighLow, HighLowID(ll));
        SubjectsNFullSeqHighLow(ss,ll) = sum(CuratedExp.NumFullSeq(logical(Indices)));
    end
end
figure()
subplot(1,3,1)
BAR = bar(SubjectsNExp);
ylabel('# Experiments')
xlabel('Subjects ID')
BAR.Parent.XTickLabel = SubjectsID;
subplot(1,3,2)
BAR = bar([SubjectsNFullSeq SubjectsNEmptySeq], 'Stacked');
legend({'Voc' 'NoVoc'})
ylabel('# Sequence Triggers')
xlabel('Subjects ID')
BAR(1).Parent.XTickLabel = SubjectsID;
subplot(1,3,3)
BAR = bar(SubjectsNCall);
ylabel('# Calls')
xlabel('Subjects ID')
BAR.Parent.XTickLabel = SubjectsID;

figure()
BAR = bar(SubjectsNFullSeqHighLow);
legend(HighLowID)
ylabel('# Sequence Triggers')
xlabel('Subjects ID')
BAR(1).Parent.XTickLabel = SubjectsID;







