function Length_Y = get_raw_file_length(AudioDataPath, Subj, Date, Time,Force)
% This function gets the length of all raw audio recordings obtained
% with vocOperant
if nargin<5
    Force=0;
end
WavFileStruc = dir(fullfile(AudioDataPath, sprintf('%s_%s_%s*mic*.wav', Subj, Date, Time)));
Length_Filename = fullfile(AudioDataPath, sprintf('%s_%s_%s_Length_Y.m',Subj, Date, Time));
if ~exist(Length_Filename, 'file') || Force
    fprintf(1,'Calculating length of each sound file to allign extract...\n')
    Nfiles = length(WavFileStruc);
    Length_Y = nan(Nfiles,1);
    for yy=1:Nfiles
        fprintf(1,'File %d/%d\n', yy,Nfiles)
        % get the files in the correct order
        Wavefile=dir(fullfile(WavFileStruc(yy).folder, sprintf('%s*_%d.wav',WavFileStruc(yy).name(1:(end-7)),yy)));
        Wavefile_local = fullfile(WavFileStruc(yy).folder, Wavefile.name);
        [Y,~] = audioread(Wavefile_local);
        Length_Y(yy) = length(Y);
    end
    save(Length_Filename,'Length_Y')
else
    fprintf('This file already exists, loading the values from\n%s\nSet Force =1 to overwrite previous calculations\n', Length_Filename);
    load(Length_Filename, 'Length_Y');
end
end