function [wt, f, coi] = computeWavelets(inputdata, fs, fignum, handle, roilen, inputname)
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





