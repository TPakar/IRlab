function [bloodflow, bandpassflow, flowrange, timevect] = spectralflow(inputdata, bandpassrange, ROI, ROInames, fs, varargin)

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


%% This function estimates blood flow using spectral modulation of thermal data.

% High frequency temprature changes(0.005-0.02 Hz, 0.02-0.05 Hz, 0.05-0.15
%Hz, 0.15-0.4 Hz, and 0.4-2.0 Hz), corresponding to endothelial (metabolic),
%neurogenic, myogenic, respiratory, and cardiac origins (Geyer et�al 2004). 
% Based on paper: Thermography-based blood flow imaging in human skin of the hands and feet A spectral filtering approach
% By Sagaidachnyi, et al. blood flow could be derived from the temperature
% signal by modulading the T-data (amplitude and frequency dependent phase
% modulation). The method used in this section an implementation of the FFT
% method described in:

%Sagaidachnyi, Andrey & Fomin, A. & Usanov, D. & Skripal, Anatoly. (2017). 
%Thermography-based blood flow imaging in human skin of the hands and feet: A spectral filtering approach. 
%Physiological measurement. 38. 272-288. 10.1088/1361-6579/aa4eaf. 

%% Inputs
% Inputdata: Structure with fields 'frameN', where N is the frame index

% bandpassrange: 2 dimensional vector [lower limit, higher limit]. High frequency temprature changes(0.005-0.02 Hz, 0.02-0.05 Hz, 0.05-0.15
%Hz, 0.15-0.4 Hz, and 0.4-2.0 Hz), corresponding to endothelial (metabolic),
%neurogenic, myogenic, respiratory, and cardiac origins.

% ROI: array of binary matrices. Used as masks for input data.

% ROInames contains the ROI names

% fs is the sampling frequency of the input video


%% Outputs

% Output 1: Estimated bloodflow as structure with fields [frame1, frame2, ...,
% frameN].

% Output 2: Bandpass filtered flow according to bandpassrange

%%

bandpassflow = [];

if ~isempty(varargin)
   % Target dataset existing
   inputdata2 = varargin{1};
   roundlen = 2;
   disp('Bilateral analysis');
else
    roundlen = 1;
    disp('Unilateral analysis');
end
% Create a waitbar

h = waitbar(0, 'Computing...');
waitbarcount = 1;
for kk = 1:roundlen
    if kk == 2
       inputdata = inputdata2; 
    end
    

    pixeldata = struct;
    % Get temprotal temperature data for each pixel from the whole
    % feet or angisome
    serieslen = length(fieldnames(inputdata));
    ydimsize = size(inputdata.frame1,1);
    xdimsize = size(inputdata.frame1,2);
    
    temporal = zeros(ydimsize, xdimsize, serieslen);
    % Collect the image data as 3D matrix (X,Y,ImIndex)
    skinthickness = 0.002; %m
    k = 0.33; % W/(m*K)
    c = 3780; % J/(kg*K)
    p = 1085; % kg/m^3
    thermaldiffusivity = k/(c*p);
    for i = 1:serieslen
        temporal(:,:,i) = inputdata.(['frame', num2str(i)]);
    end
    
    % Bandpass limits
   
    freqstart = bandpassrange(1);
    freqend = bandpassrange(2);
    
    
    % FFT temporal temperature data for each pixel
    %pixeldata.bloodflow = zeros(ydimsize, xdimsize, serieslen);
    pixeldata.freqax = (fs*(0:(serieslen-1))/serieslen)';
    tic
    dt = 1/fs;
    pixeldata.timevector = (0:serieslen-1)*dt;                % Time vector
    timevect = pixeldata.timevector;
    % zero padded power of 2 signal length
    NFFT = 2^nextpow2(serieslen); % Next power of 2 from length of y
    %NFFT = serieslen*2-1;
    %pixeldata.freqax = fs/2*linspace(0,1, serieslen);
    
    [~, spos] = min(abs(pixeldata.freqax - freqstart));
    [~, epos] = min(abs(pixeldata.freqax - freqend));
    PAcor1 = zeros(1,NFFT);
    PAphase = PAcor1;
    PAamp = PAphase;
    
    % Compute the modulation vector
    PAcor1(spos:epos) = exp((1 + 1i)*skinthickness.*sqrt(pi*pixeldata.freqax(spos:epos)/thermaldiffusivity));
    PAphase(spos:epos) = exp(1i*skinthickness.*sqrt(pi.*pixeldata.freqax(spos:epos)./thermaldiffusivity));
    PAamp(spos:epos) = exp(-skinthickness.*sqrt(pi.*pixeldata.freqax(spos:epos)./thermaldiffusivity));
    
    pixeldata.bloodflow2 = zeros(ydimsize, xdimsize, serieslen);
    %filtereddata = zeros(ydimsize, xdimsize, serieslen);
    % Complex conjugate symmetry
    %PAcor(end - length(PAcor1)+1:end) = conj(flip(PAcor1));

    pixeldata.fourier = zeros(NFFT,1);
    pixeldata.bloodflowFT = zeros(NFFT,1);

    waitbarproduct = length(ROInames)*ydimsize*xdimsize;
    
    maxval = 0;
    minval = -1000;
    for k = 1:length(ROInames)
        if (kk == 1 && contains(ROInames{k}, 'ref')) || (kk == 2 && contains(ROInames{k}, 'targ')) || (~contains(ROInames{k}, 'ref') && ~contains(ROInames{k}, 'targ'))
            ROIy = size(ROI{k}, 1);
            ROIx = size(ROI{k}, 2);
            for i = 1:ROIx
               waitbar(waitbarcount/waitbarproduct, h);
                for j = 1:ROIy
                    waitbarcount = waitbarcount + 1;
                    if ROI{k}(j,i) == 1
                        % Fourier transform
                        tempS = squeeze(temporal(j,i,:));
                        
                        % Filter the signal 
                        % Add sufficient padding
                        padding = 100/freqstart;
                        paddeddata = ones(1,length(tempS)+padding*2);
                        paddeddata(1:padding) = tempS(1,1);
                        paddeddata(end-padding:end) = tempS(end);
                        paddeddata(padding+1:end-padding) = tempS;
                        if freqstart < 0.001 
                            % Bandpass if the lower frequency is high
                            % enough
                            temp = bandpass(paddeddata, [freqstart, freqend], fs, 'impulseresponse', 'iir');
                        else
                            % Lowpass for lower frequencies
                            temp = lowpass(paddeddata, freqend, fs,'impulseResponse' ,'iir');   
                        end
                        % Truncate padding after filtering
                        signal = temp(padding+1:end-padding);
                        
                        % Fourier transform
                        fsignal = fft(signal, NFFT);
                       

                        % Phase shift and amplitude correction useing convolution (in freq space)
                        % Filter the signal
                        length(PAcor1)
                        length(fsignal)
                        filtsignal = PAcor1.*fsignal;
                        % Inverse transform with fft symmetry assumption
                        tempflow2 = ifft(filtsignal, 'symmetric');
                        % Save the final bloodflow
                        pixeldata.bloodflow2(j,i,:) = tempflow2(1:serieslen);
                       

                    else
                        %pixeldata.bloodflow(j,i,1:serieslen) = 0;
                        pixeldata.bloodflow2(j,i,1:serieslen) = 0;
                    end
                end
            end
            if freqstart >= 0.001
                disp('Signal succesfully band pass filtered');
            else
                disp('Lower succesfully frequency limit under the threshold (0.001Hz) -> Signal low pass filtered');
            end
            % Collect new data as struct for video display
            for i = 1:serieslen
               %pixelvideo.(['frame', num2str(i)]) = pixeldata.bloodflow(:,:,i); 
               bloodflow.(ROInames{k}).(['frame', num2str(i)]) = pixeldata.bloodflow2(:,:,i); 
               %bandpassflow.(ROInames{k}).(['frame', num2str(i)]) = filtereddata(:,:,i);
               tempmax = max(max(pixeldata.bloodflow2(:,:,i)));
               tempmin = min(min(pixeldata.bloodflow2(:,:,i)));
               if tempmax > maxval
                  maxval =  tempmax;
               end
               if tempmin < minval
                  minval =  tempmin;
               end
            end
        end
    end
end
    %clear temporal
delete(h);
flowrange = [minval, maxval];
toc