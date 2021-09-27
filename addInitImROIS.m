function [FinalROIpositions, masks] = addInitImROIS(I3, ROIpositions, ROInames)

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


%% This function allows you to project modify multiple ROIs to a 2nd image. This function uses MATLAB function drawfreehand()


%%

% Find screen size and video scale and set parameters for presentation
scrsize = get(0,'screensize');
screensizex = scrsize(3)/5; 
screensizey = scrsize(4)/5;

fig1 = figure(1);
roiobj =struct;
set(fig1,'WindowbuttonDownFcn',@clickcallback);
fsize = length(fieldnames(ROIpositions));
ax2 = axes;
hold on;
title('Init ROIs');

fig1.Units = 'Pixels';
imshow(I3, 'Parent', ax2);
fig1.Position = [10+(scrsize(3)-10)/2 screensizey (scrsize(3)-10)/2 scrsize(4)/1.5];

hold off;
global waitforme
    waitforme = 1;
for i = 1:fsize
    roiobj.(['ROI', num2str(i)]) = images.roi.Freehand;
    roiobj.(['ROI', num2str(i)]).Parent = ax2;
    roiobj.(['ROI', num2str(i)]).Position = ROIpositions.(ROInames(i));
    roiobj.(['ROI', num2str(i)]).Selected = 1;
    drawnow;
end

while waitforme == 1 
    % Some delay
    pause(0.00001);    
end

FinalROIpositions = struct;
masks = struct;

for i = 1:fsize
    masks.(ROInames(i)) = roiobj.(['ROI', num2str(i)]).createMask();
    FinalROIpositions.(ROInames(i)) = roiobj.(['ROI', num2str(i)]).Position;
end


close(fig1);
disp('ROIs are ready');


end
%%
function clickcallback(obj,~)
global waitforme
switch get(obj,'SelectionType')
    case 'normal'
    case 'open'
        waitforme = 0;
end
end








