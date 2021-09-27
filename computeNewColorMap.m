function [clrmap] = computeNewColorMap(imrange, cmapname)
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

%% Computes a new colormap scaled for the given IR data

% imrange is a vector holding the minimum and maximum values
% cmapname is the colormap name (only matlab colormaps or gaussianGreen)

numberofcolors = length(imrange);

if strcmp(cmapname, 'simple') || strcmp(cmapname, 'gaussianGreen')
    RR = (0:255)';
    BR = (0:235)';
    GR = (0:165)';
    % Green as normally distributed
    pd = fitdist(GR,'Normal');
    gr = pdf(pd,GR);
    gr = gr-min(gr);
    gr = gr/max(gr)*GR(end);
    gr = resample(gr,numberofcolors-1,(GR(end)-GR(1)));
    
    Greenrange = gr';
    % Red linear
    Redrange = RR(1):(RR(end)-RR(1))/(numberofcolors-1):RR(end);
    % Blue linear
    Bluerange = sort(range(BR(1)):(BR(end)-BR(1))/(numberofcolors-1):BR(end),'descend');
else
    fig5 = figure(5);
    clmap = colormap(cmapname);
    close(fig5);
    RR = round(clmap(:,1)*255);
    GR = round(clmap(:,2)*255);
    BR = round(clmap(:,3)*255);
    counter = 1;
    for i = 1:floor(length(RR)/numberofcolors):length(RR)
        
        Redrange(counter) = RR(i);
        Bluerange(counter) = BR(i);
        Greenrange(counter) = GR(i);
        counter = counter + 1;
    end
    
end

clrmap(:,1) = Redrange;
clrmap(:,2) = Greenrange;
clrmap(:,3) = Bluerange;

