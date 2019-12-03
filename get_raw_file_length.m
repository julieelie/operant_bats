function [Length_Y] = get_raw_file_length(AudioDataPath, Subj, Date, Time,Force)
% This function gets the length of all raw audio recordings obtained
% with vocOperant and find the best estimate of the sample onset of each file
if nargin<5
    Force=0;
end
WavFileStruc = dir(fullfile(AudioDataPath, sprintf('%s_%s_%s*mic*.wav', Subj, Date, Time)));
Length_Filename = fullfile(AudioDataPath, sprintf('%s_%s_%s_Length_Y.mat',Subj, Date, Time));
if ~exist(Length_Filename, 'file') || Force
    fprintf(1,'Calculating length of each sound file to allign extract...\n')
    Nfiles = length(WavFileStruc);
    Length_Y = nan(Nfiles,1);
%     Sample_on_Y = nan(Nfiles,1);
    for yy=1:Nfiles
        fprintf(1,'File %d/%d\n', yy,Nfiles)
        % get the files in the correct order
        Wavefile=dir(fullfile(WavFileStruc(yy).folder, sprintf('%s*_%d.wav',WavFileStruc(yy).name(1:(end-7)),yy)));
        if isempty(Wavefile)
            warning('The following raw file is not in the folder:\n%s\nNo data are extracted for these 10 min chunck\n',fullfile(WavFileStruc(yy).folder, sprintf('%s*_%d.wav',WavFileStruc(yy).name(1:(end-7)),yy)));
            continue
        end
            
        Wavefile_local = fullfile(WavFileStruc(yy).folder, Wavefile.name);
        [Y,FS] = audioread(Wavefile_local);
        Length_Y(yy) = length(Y);
        
%         % find if there has been any sound detection for that file (snip in
%         % the snip folder)
%         DataSnipStruc = dir(fullfile(AudioDataPath, sprintf('%s_%s_%s*snippets/*snipfile_%d_*.wav', Subj, Date, Time, yy)));
%         NbSnip_local = length(DataSnipStruc);
%         if NbSnip_local
%             IndStamp1 = strfind(DataSnipStruc(1).name, '_');
%             IndStamp_last = IndStamp1(end);
%             Stamp_local = str2double(DataSnipStruc(1).name((IndStamp_last+1):end-4));
%             Buffer = FS;
%             if Stamp_local<0
%                 Stamp_local = 2*2147483647 + Stamp_local; % Correcion of soundmexpro bug that coded numbers in 32 bits instead of 64bits
%             end
%            
%             if yy==1
%                 Hyp_sample_Before = 0;
%             else
%                  Hyp_sample_Before = Sample_on_Y(yy-1) + Length_Y(yy-1) -1;
%             end
%             Y_section_beg = max(1,Stamp_local - Hyp_sample_Before - Buffer); % Make sure we don't request before the beginning of the raw wave file
%             Y_section_end = min(length(Y), Stamp_local - Hyp_sample_Before + Buffer); % Make sure we don't request after the end of the aw wave file
%             Y_section = Y(Y_section_beg:Y_section_end);
%             [Ysnip,~] = audioread(fullfile(DataSnipStruc(1).folder, DataSnipStruc(1).name));
%             % There are often lay-off between the sample value and the
%             % actual position within the recording, estimating that lay-off
%             % using cross correlation
%             DiffY = length(Y_section)-length(Ysnip);
%             XcorrY=nan(1,DiffY+1);
%             for cc=0:DiffY
%                 XcorrY(cc+1) = transpose(Y_section(cc+(1:length(Ysnip)))) * Ysnip;
%             end
%             [~,Lag] = max(abs(XcorrY));
%             % This is the delay between the first sample 
%             Lay_off = Lag-1-Buffer;
%             Sample_on_Y(yy) = Hyp_sample_Before + Lay_off +1;
%         else
%             Sample_on_Y(yy) = Sample_on_Y(yy-1) + Length_Y(yy-1);
%         end
%         figure(20)
%         cla
%         plot(Y_section,'k')
%         hold on
%         plot(Buffer+Lay_off+(1:length(Ysnip)), Ysnip, 'r--')
%         hold off
%         title(sprintf('Lay-off file %d',yy))
    end
    % Best estimate of the file length is the mean of the others for the
    % non ones
    Length_Y(isnan(Length_Y)) = round(nanmean(Length_Y));
    save(Length_Filename,'Length_Y')
else
    fprintf('Files length have already been calculated, loading the values from\n%s\nSet Force =1 to overwrite previous calculations\n', Length_Filename);
    load(Length_Filename, 'Length_Y');
end
end