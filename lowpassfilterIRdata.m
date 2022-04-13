function [lpass] = lowpassfilterIRdata(irdata, fstop, fs)


%% This function aplies a lowpass filter and revoves the end ripple from a given input IR signal

% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

paddeddata = ones(1,length(irdata)+1000);
paddeddata(1:500) = irdata(1,1);
paddeddata(end-500:end) = irdata(end);
paddeddata(501:end-500) = irdata;
%t = 0:1/fs:(length(irdata)-2)/fs;

lpass = lowpass(paddeddata,fstop,fs, 'impulseresponse', 'iir');
lpass = lpass(501:end-501);
