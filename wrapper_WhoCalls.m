% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
OutputDataPath = 'Z:\users\tobias\vocOperant\Results';
BaseDir = 'Z:\users\tobias\vocOperant';
% BoxOfInterest = [3 4 6 8];
% PriorityPairs1 = {'TaTe' 'TeTa' 'TiTo' 'ToTi' 'TuTy' 'TyTu' 'TwTr' 'TrTw'};
% PriorityDates1 = [180926 190826];
% PriorityPairs2 = {'ClEn' 'EnCl' 'CoEd' 'EdCo' 'EzEl' 'ElEz' 'HaHo' 'HoHa'};
% PriorityDates2 = [161122 190603];
ExpLog = fullfile(OutputDataPath, 'VocOperantLogWhoCalls.txt');
WhoLog = fullfile(OutputDataPath, 'VocOperantLogWhoCallsDone.txt');
CheckAllignmentLog = fullfile(OutputDataPath, 'VocOperantLogCheckAllignement.txt');
TrashEcholocationCalls = fullfile(OutputDataPath, 'VocOperantLogEcholocation.txt');

FidExp = fopen(ExpLog, 'r');
Header = textscan(FidExp,'%s\t%s\t%s\t%s\t%s\t%s\n');
ToDoList = textscan(FidExp,'%s\t%s\t%s\t%s\t%.1f\t%d');
fclose(FidExp);


if ~exist(WhoLog, 'file')
    FidWho = fopen(WhoLog, 'a');
    fprintf(FidWho, 'Subject\tDate\tTime\tType\tDuration(s)\tLoggerID\n');
    DoneList = [];
else
    FidWho = fopen(WhoLog, 'r');
    Header2 = textscan(FidWho,'%s\t%s\t%s\t%s\t%s\t%s\n');
    DoneList = textscan(FidWho,'%s\t%s\t%s\t%s\t%.1f\t%d');
    fclose(FidWho);
    FidWho = fopen(WhoLog, 'a');
end

if ~exist(CheckAllignmentLog, 'file')
    FidCheck = fopen(CheckAllignmentLog, 'a');
    fprintf(FidCheck, 'Subject\tDate\tTime\tType\tDuration(s)\n');
    CrapList = [];
else
    FidCheck = fopen(CheckAllignmentLog, 'r');
    Header2 = textscan(FidCheck,'%s\t%s\t%s\t%s\t%s',1);
    CrapList = textscan(FidCheck,'%s\t%s\t%s\t%s\t%.1f');
    fclose(FidCheck);
    FidCheck = fopen(CheckAllignmentLog, 'a');
    
end

if ~exist(TrashEcholocationCalls, 'file')
    FidEcho = fopen(TrashEcholocationCalls, 'a');
    fprintf(FidEcho, 'Subject\tDate\tTime\tType\tDuration(s)\n');
    EchoList = [];
else
    FidEcho = fopen(TrashEcholocationCalls, 'r');
    Header2 = textscan(FidEcho,'%s\t%s\t%s\t%s\t%s',1);
    EchoList = textscan(FidEcho,'%s\t%s\t%s\t%s\t%.1f');
    fclose(FidEcho);
    FidEcho = fopen(TrashEcholocationCalls, 'a');
end

% Retrieve names of files with good quality data
fid = fopen('Z:\users\tobias\vocOperant\Exp_Stats\VocOperantData.txt');
data = textscan(fid,'%s','Delimiter', '\t');
fclose(fid);
name_line = find(contains(data{1}, 'VocTrigger'));

for ff=1:length(name_line)
    f_name = data{1}{name_line(ff)};
    ParamFilesDir = dir(fullfile(BaseDir, 'Exp_Stats', f_name));
    filepath = fullfile(BaseDir, 'Exp_Stats', f_name);
    fprintf(1,'file %d/%d:\n%s\n', ff, length(name_line),filepath)
    % Check if that file is on the
    % priority list! then on the ToDo list (list of data that has
    % already been extracted by wrapper_result_operant2), if it's been
    % already done or labbeled as crappy.
    BatsID = f_name(1:4);
    Date = f_name(6:11);
%     if (sum(contains(PriorityPairs1, BatsID)) && (str2double(Date)>PriorityDates1(1)) && (str2double(Date)<PriorityDates1(2))) || (sum(contains(PriorityPairs2, BatsID)) && (str2double(Date)>PriorityDates2(1)) && (str2double(Date)<PriorityDates2(2)))
%         if ~((strcmp(BatsID, 'TeTa') || strcmp(BatsID, 'TaTe')) && str2double(Date)<190618) % TeTa Bats were doing echolocation calls before June 18th 2019
            Time = f_name(13:16);
            boxID = data{1}{name_line(ff) + 1};
            ToDo = find(contains(ToDoList{1},BatsID) .* contains(ToDoList{2},Date) .* contains(ToDoList{3},Time).*logical(ToDoList{6}));
            Done = find(contains(DoneList{1},BatsID) .* contains(DoneList{2},Date) .* contains(DoneList{3},Time).*logical(DoneList{6}));
            Crap = find(contains(CrapList{1},BatsID) .* contains(CrapList{2},Date) .* contains(CrapList{3},Time));
            Echo = find(contains(EchoList{1},BatsID) .* contains(EchoList{2},Date) .* contains(EchoList{3},Time));
            
            % if ~isempty(ToDo) && isempty(Crap) && isempty(Echo)
            if isempty(Crap) && isempty(Echo)
                if ~isempty(Done)
                    fprintf(1, '   -> Data already processed\n')
                    continue
                else
                    % Temp = ToDoList{5}(ToDo);
                    fprintf(1,'*** Check the clock drift correction of the logger ***\n')
                    LoggerPath = fullfile(BaseDir,sprintf('box%d',boxID),'piezo',Date,'audiologgers');
                    LoggersDir = dir(fullfile(LoggerPath, 'logger*'));
                    Check = zeros(length(LoggersDir)+1,1);
                    if ~isempty(LoggersDir)
                        for ll=length(LoggersDir)
                            FigCD = open(fullfile(LoggersDir(ll).folder, LoggersDir(ll).name,'extracted_data','CD_correction0.fig'));
                            %                 fprintf(1, 'Go in %s\n',fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'piezo',Date,'audiologgers','loggerxx','extracted_data'))
                            %                 fprintf(1,'Open CD_correction0\n')
                            Check(ll) = input('Is everything ok? (yes ->1, No -> 0): ');
                            fprintf('\n')
                            close(FigCD)
                        end

                fprintf(1,'*** Check the allignement of the TTL pulses ***\n')
                AllignmentPath = fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio',sprintf('%s_%s_CD_correction_audio_piezo.fig', Date, Time));
                FigAP = open(AllignmentPath);
                %                 fprintf(1, 'Go in %s\n',fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio'))
                %                 fprintf(1,'Search for %s_%s_CD_correction_audio_piezo\n', Date, Time)
                Check(length(LoggersDir)+1) = input('Is everything ok? (yes ->1, No -> 0): ');
                fprintf('\n')
                close(FigAP)

                if sum(Check)~=length(Check)
                    Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                    fprintf(FidCheck, '%s\t%s\t%s\t%s\t%.1f\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp);
                else
                    EchoYes = input('Did you identify that file as at least having the first 10 sequences being echolocation calls? (yes ->1, No -> 0): ');
                    if  ~EchoYes
                        WhoDataYN = result_operant_bat2_who(filepath);
                        Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                        fprintf(FidWho, '%s\t%s\t%s\t%s\t%.1f\t%d\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp,WhoDataYN);
                    else
                        Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                        fprintf(FidEcho, '%s\t%s\t%s\t%s\t%.1f\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp);
                    end
                end
                    end
                end
            elseif isempty(Crap)
                fprintf(1, '   -> No piezo Data for that file\n')
            elseif ~isempty(Crap)
                fprintf(1, '   -> That file was already identified as crappy\n')
            end
%         else
%             fprintf(1, '   -> That file identified as echolocation calls only as per notes\n')
%         end
%     else
%         fprintf(1, '   -> That file is not a priority\n')
%     end
end
fclose(FidWho);
fclose(FidEcho);
fclose(FidCheck);

