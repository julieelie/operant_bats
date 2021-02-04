% This script gather all the VocTrigger experiments longer than 10min
% NOTE: We are focusing on VocTrigger experiments that are longer than 5
% min.
MinVoc = 5;
OutputDataPath = 'Z:\users\tobias\vocOperant\Exp_Stats';
BaseDir = 'Z:\users\tobias\vocOperant';
BoxOfInterest = [1 2 3 4 5 6 7 8];
ExpLog = fullfile(OutputDataPath, 'VocOperantData.txt');

Fid = fopen(ExpLog, 'w');
fprintf(Fid, 'FileName\tBoxNum\tHigh-Pass(Hz)\tLow-Pass(Hz)\tNumVocs\tDuration(min)\n');


for bb=1:length(BoxOfInterest) % for each box
    ParamFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_param.txt'));
    
    for ff=1:length(ParamFilesDir)
        
        Filepath = fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        fprintf(1,'\n\n\nBox %d (%d/%d), file %d/%d:\n%s\n',BoxOfInterest(bb),bb,length(BoxOfInterest),ff,length(ParamFilesDir),Filepath)
        
        
        % check that the experiment has data!
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
            MicFiles = dir(fullfile(ParamFilesDir(ff).folder, [ParamFilesDir(ff).name(1:25) 'mic1*']));
            Temp = (length(MicFiles)-1)*10;
        end
        if Temp<10
            fprintf(1, '   -> Data too short\n')
            continue
        end
        
        % Find corresponding event file and get number of vocalizations
        DataFileStruc = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)), 'bataudio', [ParamFilesDir(ff).name(1:16), '*_VocTrigger_events.txt']));
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
        if ~isempty(IndexLineLow) && ~isempty(IndexLineHigh) && numVocs >= MinVoc
            IndexCharHigh = strfind(data{1}{IndexLineHigh},'threshold: ');
            IndexChar2High = strfind(data{1}{IndexLineHigh},'Hz');
            % find the data (high threshold) in that line
            high = str2double(data{1}{IndexLineHigh}((IndexCharHigh + 11):(IndexChar2High-2)));
            
            IndexChar = strfind(data{1}{IndexLineLow},'threshold: ');
            IndexChar2 = strfind(data{1}{IndexLineLow},'Hz');
            % find the data (low threshold) in that line
            low = str2double(data{1}{IndexLineLow}((IndexChar + 11):(IndexChar2-2)));
            
            boxID = BoxOfInterest(bb);
            try
                % prints batIDs, date, time, low threshold, high threshold, and number of vocalizations
                fprintf(Fid, '%s\t%s%d\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name, 'box', boxID, high, low, numVocs, Temp);
            catch
                keyboard
            end
        end
    end
end
if ishandle(Fid)
    close(Fid)
end