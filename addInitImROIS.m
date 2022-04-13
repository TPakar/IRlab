function [FinalROIpositions, masks] = addInitImROIS(I3, ROIpositions, ROInames)

%% This function allows you to project modify multiple ROIs to a 2nd image. This function uses MATLAB function drawfreehand()


% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

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








