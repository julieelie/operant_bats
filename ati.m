function ati(boxNum)
%clear all;
close all;

global Gui Box

%boxNum = boxNum;
startup % Sending a message when syring are low

% Initiate a structure for the box
Box.ID = boxNum;

%% initiate arduino
[Box]=init_arduino(Box);

%% initiate SoundMex
[Box]=init_soundmex(Box);

%% initiate gui
Gui.MainHandle=autoTraingui(Box.ID);
%set(fh,'Position',[ 0.6000   37.5385  103.4000   39.7692]);
end









