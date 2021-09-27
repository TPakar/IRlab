function outputdata  = fasterread(fpath, fname, delimiter, skipcond, fs, framesize, filecounter)
%%

% Copyright (C) 2020 Tomppa Pakarinen, tomppa.pakarinen@tuni.fi


% This program is free software: you can redistribute it and/or modify it 
% under the terms of the GNU General Public License as published by the  
% Free Software Foundation, either version 3 of the License, or (at your 
% option) any later version.
%
% This program is distributed in the hope that it will be useful, but 
% WITHOUT ANY WARRANTY; without even the implied warranty of 
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General 
% Public License for more details.
% 
% You should have received a copy of the GNU General Public License along 
% with this program. If not, see http://www.gnu.org/licenses/


%% Import CSV file here (Contains the temperature map for each frame)
% CSV order is so that 1st column and ith row includes the frame numbers ('Frame n')
% and the data for each frame is arranged [row, col] = [i:i+imheight, 2:imwidth]
%% If you split the pieces before hand (necessary for large files if using this code), then name them with 001, 002, 003, 004, ... 011, 012, 013, ... and so on
% This ensures that the directory is in right order (max number of files == 999)
% Ohterwise you will need to resort the directory...


% Reads text and tabula files fast
% Inputs:
% 1 pathname
% 2 filename
% 3 delimiter between values
% 4 delimiter between frames
% 5 sampling frequency
% 6 Framesize as vector [vertical, horizontal]
% 7 Directory filecounter (parsed data)

% output = structure with wanted frames/fields

% File info
fid = fopen([fpath, fname]);

% Use fgetl to quickly read through lines reparated by newline characters. Use fgets to read line with the newline char

% read data as cell

readdata = textscan(fid, '%s');

if filecounter == 1
   firstline = 4;
else
   firstline = 2; 
end
% Find first framenumber
probecount = 1;
while ~strcmp(readdata{1}{firstline}(probecount), delimiter)
    probecount = probecount + 1;
end
% Save framenumber and incerement it to delete following framenumbers
% attached to the temperaturevalue
framecount = str2double(readdata{1}{firstline}(1:probecount-1));
% Delete header
if filecounter == 1
    readdata{1}([1,2]) = [];
end
% Find frame indices
frameidx = find(contains(readdata{1},skipcond));
% Delete frame strings
readdata{1}(frameidx) = [];
% Split data and save to output structure
outputdata = struct;
framelinecount = 1;
tempmat = zeros(framesize(1), framesize(2));
tempfile = strrep(readdata{1},',','.');
formatS = repmat('%f', 1, framesize(2));

for i = 1:size(tempfile,1)
    if framelinecount == 1
        tempmat(framelinecount,:) = cell2mat(textscan(tempfile{i,1}(length(num2str(framecount))+2:end),formatS,'delimiter', ';'));
    else
        tempmat(framelinecount,:) = cell2mat(textscan(tempfile{i,1}(2:end),formatS,'delimiter', ';')); 
    end
    %tempmat(framelinecount,:) = cellfun(tempfile(1:framesize(2));
    if framelinecount >= framesize(1)
        outputdata.(['frame', num2str(framecount)]) = tempmat;
        framecount = framecount + 1; 
        framelinecount = 1;
    else
        framelinecount = framelinecount + 1;
    end
    
end







