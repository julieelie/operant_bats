% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
OutputDataPath = 'Z:\users\tobias\vocOperant\Exp_Stats';
BaseDir = 'Z:\users\tobias\vocOperant';
BoxOfInterest = [1 2 3 4 5 6 7 8];
ExpLog = fullfile(OutputDataPath, 'VocOperantData.txt');
DataTable = [];

if ~exist(ExpLog, 'file')
    Fid = fopen(ExpLog, 'a');
    fprintf(Fid, 'File Name (BatID, Date, Time)\tBoxNum\tHigh-Pass(Hz)\tLow-Pass(Hz)\tNumVocs\n');
    DoneList = [[], [], [], []];
else
    Fid = fopen(ExpLog, 'r');
    Header = textscan(Fid,'%s\t%s\t%s\t%s\t%s\n');
    DoneList = textscan(Fid,'%s\t%s\t%s\t%.1f\t%d');
    fclose(Fid);
    Fid = fopen(ExpLog, 'a');
    
end

for bb=1:length(BoxOfInterest) % for each box
    ParamFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_param.txt'));
    EventFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_events.txt'));
    
    for ff=1:length(ParamFilesDir)
        
        filepath = fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        fprintf(1,'\n\n\nBox %d (%d/%d), file %d/%d:\n%s\n',BoxOfInterest(bb),bb,length(BoxOfInterest),ff,length(ParamFilesDir),filepath)
        % Check that the file was not already treated
        BatsID = ParamFilesDir(ff).name(1:4);
        Date = ParamFilesDir(ff).name(6:11);
        Time = ParamFilesDir(ff).name(13:16);
        Done = sum(contains(DoneList{1},BatsID) .* contains(DoneList{2},Date) .* contains(DoneList{3},Time));
        % boxDates = DatesOfInterest{bb};
        toDo = 1;
        if Done
            fprintf(1, '   -> Data already processed\n')
            toDo = 0;
            continue
        end
        
        if toDo ~= 0
            % check that the experiment has data!
            fid = fopen(filepath);
            data = textscan(fid,'%s','Delimiter', '\t');
            fclose(fid);

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
        end
            % FIND THE LINE of your data
            IndexLineHigh = find(contains(data{1}, 'high-pass'));
            IndexLineLow = find(contains(data{1}, 'low-pass'));
            if ~isempty(IndexLineLow) && ~isempty(IndexLineHigh) && numVocs >= 5
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
                    fprintf(Fid, '%s\t%s%d\t%f\t%f\t%d\n',ParamFilesDir(ff).name, 'box', boxID, high, low, numVocs);
                catch ME
                    LoggerDataYN = NaN; % Signal error in the processing
                    Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                    fprintf(Fid, '%s\t%s\t%s\t%s\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),high,low,numVocs,LoggerDataYN);
                    fprintf(1, '%s\t%s\t%s\t%s\t%f\t%f\t%d\t%d\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),high,low,numVocs,LoggerDataYN);
                    ME
                    for ii=1:length(ME.stack)
                        ME.stack(ii)
                    end
                end
            end
        end
    end
end
if ishandle(Fid)
    close(Fid)
end