% Make new file for the experiment 
function [] = score_place_test(Name, Exptype, Path)
Filename = fullfile(Path,sprintf('%s_%s_%s.txt', datestr(now, 'yymmdd_HHMM'), Name, Exptype));
FileID = fopen(Filename,'wt');
fprintf(FileID, 'position\telapsedtime(s)\n' );
Test_duration = 15*60;
Tstart = tic;
while toc(Tstart)<Test_duration
    Prompt = input('Moving to which area? (Middle:m; Left:l; Right:r; any other key:stop)\n','s');
    if strcmp(Prompt, 'r')
        fprintf(FileID,'right\t%f\n',toc(Tstart));
    elseif strcmp(Prompt, 'l')
        fprintf(FileID,'left\t%f\n',toc(Tstart));
    elseif strcmp(Prompt, 'm')
        fprintf(FileID,'middle\t%f\n',toc(Tstart));
    else
        Prompt2 = input('Do you really want to stop? (Yes:y; No:n)\n','s');
        if strcmp(Prompt2, 'n')
        elseif strcmp(Prompt2, 'y')
            fprintf(FileID,'stop\t%f\n',toc(Tstart));
            break
        end
    end
end
fclose(FileID);
fprintf(1,'*** The test is over! ***\n*** Run for %.2f min ***\n', toc(Tstart)/60);
end