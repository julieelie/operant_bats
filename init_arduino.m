function [Box] = init_arduino(Box)
%% input arduino port connection params given by Windows and the borad name
if Box.ID == 5
    port = 'COM6';
elseif Box.ID == 7
    port = 'COM3';
elseif Box.ID == 1
    port = 'COM4';
elseif Box.ID == 2
    port = 'COM4';
elseif Box.ID == 9
    port = 'COM5';
elseif Box.ID == 3
    port = 'COM3';
end
%port = '/dev/cu.usbmodem1421'; %for macs

% Setting the board name
board = 'uno';

%% Initializing the Arduino and configure pins
Box.Arduino = arduino(port, board, 'Libraries', 'Adafruit\MotorShieldV2');
shield = addon(Box.Arduino, 'Adafruit\MotorShieldV2'); 

% Setting the pin of LEDs and Beam breakers on the Arduino
Box.LEDPin1 = 'D13'; %timeout LED pin
Box.LEDPin2 = 'D10'; %cue LED pin
Box.LEDPin3 = 'D12'; %reward LED pin
Box.BeamPin1 = 'D2'; %trial start beam break input pin for front bat
Box.BeamPin2 = 'D4'; %food port beam break input pin for front bat
Box.BeamPin3= 'D6'; %trial beam break input pin for back bat
Box.BeamPin4 = 'D8'; %food port beam break input pin for back bat

configurePin(Box.Arduino, Box.BeamPin1, 'pullup');
configurePin(Box.Arduino, Box.BeamPin2, 'pullup');
configurePin(Box.Arduino,Box.BeamPin3, 'pullup');
configurePin(Box.Arduino, Box.BeamPin4, 'pullup');
configurePin(Box.Arduino, Box.LEDPin1, 'DigitalOutput');
configurePin(Box.Arduino, Box.LEDPin2, 'DigitalOutput');
configurePin(Box.Arduino, Box.LEDPin3, 'DigitalOutput');

% Test the LEDs
% first light them up
writeDigitalPin(Box.Arduino, Box.LEDPin1, 1); % this line light up the LED
writeDigitalPin(Box.Arduino, Box.LEDPin2, 1);
writeDigitalPin(Box.Arduino, Box.LEDPin3, 1);
pause(1); % pause for a sec
% switch off LEDs
writeDigitalPin(Box.Arduino, Box.LEDPin1, 0); %start LEDpin at low
writeDigitalPin(Box.Arduino, Box.LEDPin2, 0); %start LEDpin at low
writeDigitalPin(Box.Arduino, Box.LEDPin3, 0); %start LEDpin at low



%% Initializing the motor and checking that syringe motor move forward and
% backward
Box.dcm = dcmotor(shield, 1); % Defining the syringe motor
Box.dcm.Speed = 1; % Defining the speed of the syringe motor forward
start(Box.dcm); % initiate the forward movement of the motor
pause(1); %amount of time to push servo back to 0 position
stop(Box.dcm); % stop the forward movement of the motor
Box.dcm.Speed = -1; % Defining the speed of the syringe motor backward
start(Box.dcm); % initiate the backward movement of the motor
pause(1); %amount of time to push servo back to full syringe position
stop(Box.dcm); % stop the backward movement of the motor

end

