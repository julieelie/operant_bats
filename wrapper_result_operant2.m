% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
OutputDataPath = 'Z:\users\tobias\vocOperant\Results';
BaseDir = 'Z:\users\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];
ExpLog = fullfile(OutputDataPath, 'VocOperantLogWhoCalls.txt');

if ~exist(ExpLog, 'file')
    Fid = fopen(ExpLog, 'a');
    fprintf(Fid, 'Subject\tDate\tTime\tType\tDuration(s)\tLoggerData\n');
    DoneList = [];
else
    Fid = fopen(ExpLog, 'r');
    Header = textscan(Fid,'%s\t%s\t%s\t%s\t%s\t%s\n');
    DoneList = textscan(Fid,'%s\t%s\t%s\t%s\t%.1f\t%d');
    fclose(Fid);
    Fid = fopen(ExpLog, 'a');
    
end

for bb=1:length(BoxOfInterest)
    ParamFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_param.txt'));
    for ff=1:length(ParamFilesDir)
        filepath = fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        fprintf(1,'\n\n\nBox %d (%d/%d), file %d/%d:\n%s\n',BoxOfInterest(bb),bb,length(BoxOfInterest),ff,length(ParamFilesDir),filepath)
        % Check that the file was not already treated
        BatsID = ParamFilesDir(ff).name(1:4);
        Date = ParamFilesDir(ff).name(6:11);
        Time = ParamFilesDir(ff).name(13:16);
        Done = sum(contains(DoneList{1},BatsID) .* contains(DoneList{2},Date) .* contains(DoneList{3},Time));
        if Done
            fprintf(1, '   -> Data already processed\n')
            continue
        end
        % check that the experiment has data!~
        fid = fopen(filepath);
        data = textscan(fid,'%s','Delimiter', '\t');
        fclose(fid);

        % FIND THE LINE of your data
        IndexLine = find(contains(data{1}, 'Task stops at'));
        if ~isempty(IndexLine)
            IndexChar = strfind(data{1}{IndexLine},'after');
            IndexChar2 = strfind(data{1}{IndexLine},'seconds');

            % find the data into that line
            Temp = str2double(data{1}{IndexLine}((IndexChar + 6):(IndexChar2-2)));
            if Temp<600
                continue
            end
        end
        LoggerDataYN = result_operant_bat2(filepath);
        Ind_ = strfind(ParamFilesDir(ff).name, '_param');
        fprintf(Fid, '%s\t%s\t%s\t%s\t%.1f\t%d\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp,LoggerDataYN);
    end
end
close(Fid)