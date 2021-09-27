function [filteredbands, powerSpectrum] = bandpassfilterIRdata(ROIs, ROInames, fs, varargin)

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


%% This function bandpass filters videodata to given bands and returns a structure, containing the filtered data and the fft powerspectrum

% Inputs: Inputdata should be a vector, holding the temperature values
% ROIs should hold binary image masks
% varargin should hold the band range vectors


%% Band pass filtering of angiosomes
% ROI = angiosome ROIs (from ang. params: (mean, std, min, max))




% create bandpass filter for each frequency and filter the data
for i = 1:length(ROInames)
    dmldata = cell2mat(ROIs{i}(1,2:end));
    paddeddata = ones(1,length(dmldata)+1000);
    paddeddata(1:500) = dmldata(1,1);
    paddeddata(end-500:end) = dmldata(end);
    paddeddata(501:end-500) = dmldata;
    t = 0:length(dmldata)-1;
    filteredbands.timev = t./fs;

    % Endothelic (metabolic) 0.005-0.02 Hz
    tempdata = bandpass(paddeddata, varargin{1}, fs, 'impulseresponse', 'iir');
    filteredbands.(ROInames{i}).metabolic = tempdata(501:end-500);
    % Neurogenic 0.02-0.05 Hz
    tempdata = bandpass(paddeddata, varargin{2}, fs, 'impulseresponse', 'iir');
    filteredbands.(ROInames{i}).neurogenic = tempdata(501:end-500);
    % Myogenic 0.15 - 0.4 Hz
    tempdata = bandpass(paddeddata, varargin{3}, fs, 'impulseresponse', 'iir');
    filteredbands.(ROInames{i}).myogenic = tempdata(501:end-500);
    % Resporatory 
    tempdata = bandpass(paddeddata, varargin{4}, fs, 'impulseresponse', 'iir');
    filteredbands.(ROInames{i}).respiratory = tempdata(501:end-500);
    % Cardiac 0.4 - 2 Hz
    tempdata = bandpass(paddeddata, varargin{5}, fs, 'impulseresponse', 'iir');
    filteredbands.(ROInames{i}).cardiac = tempdata(501:end-500);
    
    filteredbands.(ROInames{i}).dmldata = dmldata;
    % Check that freq range is within bandlimits
    %[0, fs/2] if x is real-valued and N is even
    %[0, (N – 1)fs/(2N)] if x is real-valued and N is odd
    for j = 1:5
        if mod(length(dmldata), 2) == 0 && varargin{j}(2) < fs/2
            filteredbands.(ROInames{i}).bandpower = bandpower(dmldata, fs, varargin{j});
        elseif varargin{j} < ((length(dmldata) - 1)*fs/(2*length(dmldata)))
            filteredbands.(ROInames{i}).bandpower = bandpower(dmldata, fs, varargin{j});
        else
            disp('Not enough datapoints to compute frequency range: ', num2str(varargin{j}(1), '-', num2str(varargin{j}(2))), 'Hz');
        end
    end
    
    
    % FFT
    fdmldata = fft(dmldata);
    powerSpectrum.(ROInames{i}).fdmldata = fdmldata((1:length(dmldata)/2+1));
    powerSpectrum.(ROInames{i}).f = 0:fs/length(dmldata):fs/2;
    %f = 1./t;
    cdmldata = fft(filteredbands.(ROInames{i}).cardiac);
    powerSpectrum.(ROInames{i}).cdmldata = cdmldata((1:length(filteredbands.(ROInames{i}).cardiac)/2+1));
    
end
