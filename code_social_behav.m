% Make new file for the experiment 
function [] = code_social_behav(Name, Exptype, Path)
if nargin<1
    Name = 'HoHa';
end
if nargin<2
    Exptype = 'RecOnly';
end
if nargin<3
    Path = 'C:\Users\Batman\Desktop\bataudio\autoTrain\box_9';
end
    
Filename = fullfile(Path,sprintf('%s_%s_%s_behav.txt', datestr(now, 'yymmdd_HHMM'), Name, Exptype));
FileID = fopen(Filename,'wt');
fprintf(FileID, 'Behavior\tStamp\telapsedtime(s)\n' );
Tstart = tic;
while 1
    Prompt = input('Behavior? (food in:f; licking:l; chewing:c; teeth cleaning:t; quiet:q; echolocation:e; eating:a; vocalization:v; any other key:stop)\n','s');
    if strcmp(Prompt, 'f1')
        fprintf(FileID,'food-in_start\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'f0')
        fprintf(FileID,'food-in_stop\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'l1')
        fprintf(FileID,'licking_start\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'l0')
        fprintf(FileID,'licking_stop\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'c1')
        fprintf(FileID,'chewing_start\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'c0')
        fprintf(FileID,'chewing_stop\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 't1')
        fprintf(FileID,'teeth-cleaning_start\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 't0')
        fprintf(FileID,'teeth-cleaning_stop\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'q1')
        fprintf(FileID,'quiet_start\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'q0')
        fprintf(FileID,'quiet_stop\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'e')
        fprintf(FileID,'echolocation\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'v')
        fprintf(FileID,'vocalization\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt(1), 'L')
        fprintf(FileID,'LED%s\t%s\t%f\n', Prompt(2:end),datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    elseif strcmp(Prompt, 'm')
        fprintf(FileID,'food-in-mouth\t%s\t%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
    else
    
        Prompt2 = input('Do you really want to stop? (Yes:y; No:n)\n','s');
        if strcmp(Prompt2, 'n')
        elseif strcmp(Prompt2, 'y')
            fprintf(FileID,'stop\t%s\%f\n',datestr(now, 'yyyymmddTHHMMSSFFF'),toc(Tstart));
            break
        end
    end
end
fclose(FileID);
fprintf(1,'*** The test is over! ***\n*** Run for %.2f min ***\n', toc(Tstart)/60);
end