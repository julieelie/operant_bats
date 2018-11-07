% Make new file for the experiment 
function [] = score_place_test(Name,Date, Exptype, Path)
Filename = fullfile(Path,sprintf('%d_%s_%s.txt', Date, Name, Exptype));
FileID = fopen(Filename);
fprintf(FileID, 'position\telapsedtime\n' );
Tstart = tic;
while 1
    Prompt = input('Boundary crossed','s');
    if strcmp(Prompt, 'r')
        fprintf(FileID,'right\t%f\n',toc(Tstart));
    elseif strcmp(Prompt, 'l')
        fprintf(FileID,'left\t%f\n',toc(Tstart));
    elseif strcmp(Prompt, 'm')
        fprintf(FileID,'middle\t%f\n',toc(Tstart));
    else
        break
    end
end
fclose(FileID);
end