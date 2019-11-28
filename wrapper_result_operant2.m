% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
OutputDataPath = 'Z:\users\tobias\vocOperant\Results';
BaseDir = 'Z:\users\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];
ExpLog = fullfile(OutputDataPath, 'VocOperantLogWhoCalls.txt');
Fid = fopen(ExpLog, 'a');
if ~exist(ExpLog, 'file')
    fprintf(Fid, 'Subject\tDate\tTime\tType\tDuration(s)\tLoggerData\n');
end

for bb=1:length(BoxOfInterest)
    ParamFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_param.txt'));
    for ff=3:length(ParamFilesDir)
        filepath = fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        % check that the experiment has data!~
        fid = fopen(filepath);
        data = textscan(fid,'%s','Delimiter', '\t');
        fclose(fid);

        % FIND THE LINE of your data
        IndexLine = find(contains(data{1}, 'Task stops at'));
        IndexChar = strfind(data{1}{IndexLine},'after');
        IndexChar2 = strfind(data{1}{IndexLine},'seconds');

        % find the data into that line
        Temp = str2double(data{1}{IndexLine}((IndexChar + 6):(IndexChar2-2)));
        if Temp<600
            continue
        end
        LoggerDataYN = result_operant_bat2(filepath);
        Ind_ = strfind(ParamFilesDir(ff).name, '_param');
        fprintf(Fid, '%s\t%s\t%s\t%s\t%.1f\t%d\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp,LoggerDataYN);
    end
end
close(Fid)