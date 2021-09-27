function [lpass] = lowpassfilterIRdata(irdata, fstop, fs)
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


%% This function aplies a lowpass filter and revoves the end ripple from a given input IR signal

% Padd the data
paddeddata = ones(1,length(irdata)+1000);
paddeddata(1:500) = irdata(1,1);
paddeddata(end-500:end) = irdata(end);
paddeddata(501:end-500) = irdata;

lpass = lowpass(paddeddata,fstop,fs, 'impulseresponse', 'iir');
lpass = lpass(501:end-501);
