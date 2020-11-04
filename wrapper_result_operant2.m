% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
OutputDataPath = 'Z:\users\tobias\vocOperant\Results';
BaseDir = 'Z:\users\tobias\vocOperant';
BoxOfInterest = ['3' '4' '6' '8']; % these are the only boxes with piezo recordings
ExpLog = fullfile(OutputDataPath, 'VocOperantLogWhoCalls.txt');

if ~exist(ExpLog, 'file')
    Fid = fopen(ExpLog, 'a');
    fprintf(Fid, 'Subject\tDate\tTime\tType\tDuration(s)\tLoggerData\n');
    DoneList = [];
else
    Fid = fopen(ExpLog, 'r');
    Header = textscan(Fid,'%s\t%s\t%s\t%s\t%s\t%s\n');
    DoneList = textscan(Fid,'%s\t%s\t%s\t%s\t%s\t%s\n'); % formerly '%s\t%s\t%s\t%s\t%.1f\t%d\n'
    fclose(Fid);
    Fid = fopen(ExpLog, 'a');
    
end

% Retrieve names of files with good quality data
fid = fopen('Z:\users\tobias\vocOperant\Exp_Stats\VocOperantData.txt');
good_data = textscan(fid,'%s','Delimiter', '\t');
fclose(fid);
name_line = find(contains(good_data{1}, 'VocTrigger'));
box_line = find(contains(good_data{1}, 'box'));

if ~isempty(name_line)
    for ff=1:length(name_line)
        f_name = good_data{1}{name_line(ff)};
        boxID = good_data{1}{box_line(ff)};
        % ParamFilesDir = dir(fullfile(BaseDir, boxID, 'bataudio', f_name));
        filepath = fullfile(BaseDir, boxID, 'bataudio', f_name); %fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        fprintf(1,'\n\n\n%s, file %d/%d:\n%s\n',boxID,ff,length(name_line),filepath)
        BatsID = f_name(1:4);
        Date = f_name(6:11);
        Time = f_name(13:16);
        % Check that the file was not already treated
        Done = sum(contains(DoneList{1},BatsID) .* contains(DoneList{2},Date) .* contains(DoneList{3},Time));
        toDo = 0;
        
        if Done
            fprintf(1, '   -> Data already processed\n')
            continue
        end
        if ismember(boxID(4),BoxOfInterest)
            toDo = 1;
        end
        % Use when looking at speciic dates/boxes rather than a pre-selected
        % set of files:
        %         boxDates = DatesOfInterest{bb};
        %         for ddRow=1:size(boxDates,1)
        %             startDate = boxDates(ddRow,1);
        %             endDate = boxDates(ddRow ,2);
        %             if (str2double(Date) >= startDate) && (str2double(Date) <= endDate)
        %                 toDo = 1;
        %             end
        %         end
        
        if toDo ~= 0
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
            try
                LoggerDataYN = result_operant_bat2(filepath);
                fprintf(Fid, '%s\t%s\t%s\t%s\t%s\t%s\n',f_name(1:4),f_name(6:11),f_name(13:16),f_name(18:length(f_name)-4),Temp,LoggerDataYN);
                % ^ formerly '%s\t%s\t%s\t%s\t%.1f\t%d\n'
            catch ME
                LoggerDataYN = NaN; % Signal error in the processing
                %Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                fprintf(Fid, '%s\t%s\t%s\t%s\t%s\t%s\n',f_name(1:4),f_name(6:11),f_name(13:16),f_name(18:length(f_name)-4),Temp,LoggerDataYN);
                fprintf(1, '%s\t%s\t%s\t%s\t%s\t%s\n',f_name(1:4),f_name(6:11),f_name(13:16),f_name(18:length(f_name)-4),Temp,LoggerDataYN);
                ME
                for ii=1:length(ME.stack)
                    ME.stack(ii)
                end
            end
        else
            fprintf(1,'   -> This date is not a priority\n')
        end
    end
end
if ishandle(Fid)
    close(Fid)
end