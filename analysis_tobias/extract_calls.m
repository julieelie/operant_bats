function extract_calls 

%open the wave file and extract triggered calls
    Ind_ = strfind(app.SoundtimeDropDown.Value, '_');
    Seq = str2double(app.SoundtimeDropDown.Value(1:(Ind_-1)));
    Stamp = str2double(app.SoundtimeDropDown.Value((Ind_+1):end));
       
    try
        Wavefile_local = fullfile(WavFileStruc.folder, WavFileStruc.name);
        [Y,FS] = audioread(Wavefile_local);
    catch
        fprintf(1,'Warning: the audiofile %s cannot be read properly and will not be plotted\n', Wavefile_local);
        Y = 0;
        FS=Box.SoundCard.fs;
    end
    Y_section_beg = max(1,Stamp - behavData.Offset_Y(Seq) - 60*FS); % Make sure we don't request before the beginning of the section
    Pre_stamp = min(60*FS, Stamp - behavData.Offset_Y(Seq));
    Y_section_end = min(length(Y), Stamp - behavData.Offset_Y(Seq) + 60*FS); % Make sure we don't request after the beginning of the section
    Post_stamp = min(60*FS, length(Y)- (Stamp - behavData.Offset_Y(Seq)));
    Y_section = Y(Y_section_beg:Y_section_end);
    
    % Plot the waveforms of the recording around the stamp of the vocalization
    cla(app.UIAxes)
    if ~ishold(app.UIAxes)
        hold(app.UIAxes)
    end
    plot(app.UIAxes, Y_section, 'Color', 'k')
    end