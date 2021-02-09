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
diary(fullfile(OutputDataPath, 'StatsDiary.txt'));
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
        
        
        % check that the experiment has data!
        MicFiles = dir(fullfile(ParamFilesDir(ff).folder, [ParamFilesDir(ff).name(1:25) 'mic1*']));
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
        Logger_dir = fullfile(AudioDataPath(1:(strfind(ParamFilesDir(ff).folder, 'bataudio')-1)), 'piezo',ParamFilesDir(ff).name(6:11),'audiologgers');
        All_loggers_dir = dir(fullfile(Logger_dir, '*ogger*'));
        LogData = isempty(Logger_dir);
        
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
            keyboard
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
            low = Nan;
        end
        
        if ~isempty(IndexLineHigh)
            IndexCharHigh = strfind(data{1}{IndexLineHigh},'threshold: ');
            IndexChar2High = strfind(data{1}{IndexLineHigh},'Hz');
            % find the data (high threshold) in that line
            high = str2double(data{1}{IndexLineHigh}((IndexCharHigh + 11):(IndexChar2High-2)));
        else
            high = Nan;
        end
        
        if (numVocs >= MinVoc) && (Temp>MinDur) && ~MicData && ~LogData
            try
                % prints batIDs, date, time, low threshold, high threshold, and number of vocalizations
                fprintf(Fid, '%s\t%s%d\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name, 'box', BoxID, high, low, numVocs, Temp);
                fprintf(FidAll, '%s\t%s%d\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name, 'box', BoxID, high, low, numVocs, Temp, ~MicData, ~LogData);
            catch
                keyboard
            end
        else
            fprintf(FidAll, '%s\t%s%d\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name, 'box', BoxID, high, low, numVocs, Temp,  ~MicData, ~LogData);
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
close(Fid)
close(FidAll)
fprintf(1,'Total # of experiments: %d\n', AllExpCount)
fprintf(1, 'Experiments with missing microphone data: %d/%d, %d%%\n', ExpMissMicDataCount,AllExpCount, round(ExpMissMicDataCount*100/AllExpCount))
fprintf(1, 'Experiments with Mic data that are too short: %d/%d, %d%%\n', ExpTooShortCount, AllExpCount-ExpMissMicDataCount, round(ExpTooShortCount*100/(AllExpCount-ExpMissMicDataCount)))
fprintf(1, 'Experiments with Mic data, longer that %d min that have too few calls: %d/%d, %d%%\n',MinDur, ExpTooFewCallsCount, AllExpCount-ExpMissMicDataCount-ExpTooShortCount, round(ExpTooFewCallsCount*100/(AllExpCount-ExpMissMicDataCount-ExpTooShortCount)))
fprintf(1, 'Experiments with Mic data, longer that %d min, with >= %d calls that have no logger data: %d/%d, %d%%\n',MinDur, MinVoc,ExpMissLogDataCount, AllExpCount-ExpMissMicDataCount-ExpTooShortCount-ExpTooFewCallsCount, round(ExpMissLogDataCount*100/(AllExpCount-ExpMissMicDataCount-ExpTooShortCount-ExpTooFewCallsCount)))
diary OFF