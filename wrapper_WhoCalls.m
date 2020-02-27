% NOTE: We are focusing on VocTrigger experiments that are longer than 10
% min.
OutputDataPath = 'Z:\tobias\vocOperant\Results';
BaseDir = 'Z:\tobias\vocOperant';
BoxOfInterest = [3 4 6 8];
PriorityPairs1 = {'TaTe' 'TeTa' 'TiTo' 'ToTi' 'TuTy' 'TyTu' 'TwTr' 'TrTw'};
PriorityDates1 = [180926 190826];
PriorityPairs2 = {'ClEn' 'EnCl' 'CoEd' 'EdCo' 'EzEl' 'ElEz' 'HaHo' 'HoHa'};
PriorityDates2 = [161122 190603];
ExpLog = fullfile(OutputDataPath, 'VocOperantLogWhoCalls.txt');
WhoLog = fullfile(OutputDataPath, 'VocOperantLogWhoCallsDone.txt');
CheckAllignmentLog = fullfile(OutputDataPath, 'VocOperantLogCheckAllignement.txt');

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
else
    FidCheck = fopen(CheckAllignmentLog, 'r');
    Header2 = textscan(FidCheck,'%s\t%s\t%s\t%s\t%s',1);
    CrapList = textscan(FidCheck,'%s\t%s\t%s\t%s\t%.1f');
    fclose(FidCheck);
    FidCheck = fopen(CheckAllignmentLog, 'a');
    
end

for bb=1:length(BoxOfInterest)
    ParamFilesDir = dir(fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'bataudio','*_VocTrigger_param.txt'));
    for ff=1:length(ParamFilesDir)
        filepath = fullfile(ParamFilesDir(ff).folder, ParamFilesDir(ff).name);
        fprintf(1,'\n\n\nBox %d (%d/%d), file %d/%d:\n%s\n',BoxOfInterest(bb),bb,length(BoxOfInterest),ff,length(ParamFilesDir),filepath)
        % Check if that file is on the
        % priority list! then on the ToDo list (list of data that has
        % already been extracted by wrapper_result_operant2), if it's been
        % already done or labbeled as crappy.
        BatsID = ParamFilesDir(ff).name(1:4);
        Date = ParamFilesDir(ff).name(6:11);
        if (sum(contains(PriorityPairs1, BatsID)) && str2double(Date)>PriorityDates1(1) && str2double(Date)<PriorityDates1(2)) || (sum(contains(PriorityPairs2, BatsID)) && str2double(Date)>PriorityDates2(1) && str2double(Date)<PriorityDates2(2))
            if ~((strcmp(BatsID, 'TeTa') || strcmp(BatsID, 'TaTe')) && str2double(Date)<190618) % TeTa Bats were doing echolocation calls before June 18th 2019
                Time = ParamFilesDir(ff).name(13:16);
                ToDo = find(contains(ToDoList{1},BatsID) .* contains(ToDoList{2},Date) .* contains(ToDoList{3},Time).*logical(ToDoList{6}));
                Done = find(contains(DoneList{1},BatsID) .* contains(DoneList{2},Date) .* contains(DoneList{3},Time).*logical(DoneList{6}));
                Crap = find(contains(CrapList{1},BatsID) .* contains(CrapList{2},Date) .* contains(CrapList{3},Time));
                
                if ~isempty(ToDo) && isempty(Crap)
                    if ~isempty(Done)
                        fprintf(1, '   -> Data already processed\n')
                        continue
                    else
                        Temp = ToDoList{5}(ToDo);
                        fprintf(1,'*** Check the clock drift correction of the logger ***\n')
                        LoggerPath = fullfile(BaseDir,sprintf('box%d',BoxOfInterest(bb)),'piezo',Date,'audiologgers');
                        LoggersDir = dir(fullfile(LoggerPath, 'logger*'));
                        Check = zeros(length(LoggersDir)+1,1);
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
                        
                        if sum(Check)==length(Check)
                            WhoDataYN = result_operant_bat2_who(filepath);
                            Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                            fprintf(FidWho, '%s\t%s\t%s\t%s\t%.1f\t%d\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp,WhoDataYN);
                        else
                            Ind_ = strfind(ParamFilesDir(ff).name, '_param');
                            fprintf(FidCheck, '%s\t%s\t%s\t%s\t%.1f\n',ParamFilesDir(ff).name(1:4),ParamFilesDir(ff).name(6:11),ParamFilesDir(ff).name(13:16),ParamFilesDir(ff).name(18:(Ind_-1)),Temp);
                        end
                    end
                elseif isempty(Crap)
                    fprintf(1, '   -> No piezo Data for that file\n')
                elseif ~isempty(Crap)
                    fprintf(1, '   -> That file was already identified as crappy\n')
                end
            else
                fprintf(1, '   -> That file identified as echolocation calls only as per notes\n')
            end
        else
            fprintf(1, '   -> That file is not a priority\n')
        end
    end
end
close(FidWho)