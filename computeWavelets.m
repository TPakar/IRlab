function [wt, f, coi] = computeWavelets(inputdata, fs, fignum, handle, roilen, inputname)

%% This function creates wavelet subplot figure for a given number of inputs
% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

subplotcols = 3;
if roilen < subplotcols
    subplotcols = roilen;
end
matsize = [ceil(roilen/subplotcols), subplotcols];
[wt,f,coi] = cwt(inputdata, fs);
figure(handle);
set(handle,'Units','Normalized');
set(handle, 'Position', [0 0 1 1]);
set(handle, 'Units', 'Pixels');
% Plot to subplot
subplot(matsize(1), matsize(2), fignum, 'Parent', handle);
pcolor(1:numel(inputdata),f,abs(wt));
shading interp
hcb = colorbar;
xlabel('Time [s]', 'fontsize', 10);
ylabel('Frequency [Hz]', 'fontsize', 10);
colorTitleHandle = get(hcb,'Title');
titleString = 'Magnitude';
set(colorTitleHandle ,'String',titleString);
title(regexprep(inputname, '_', ' '), 'fontsize', 15);





