function [maskref, masktarg, hFH1pos, hFH2pos] = drawDoubleImageROI(I1, I2)

%% This function allows you to project drawn ROI to a 2nd image. This function uses MATLAB function drawfreehand(), and allows the user to modify both ROI's after initial drawing
% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

global waitforme
waitforme = 1;

% Find screen size and video scale and set parameters for presentation
scrsize = get(0,'screensize');
screensizex = scrsize(3)/5; 
screensizey = scrsize(4)/5;

fig1 = figure(1);


set(fig1,'WindowbuttonDownFcn',@clickcallback);
ax1 = axes;

title('ROI 1');
hold on;
imshow(I1, 'Parent', ax1);
fig1.Position = [screensizex screensizey scrsize(3)/1.5 scrsize(4)/1.5];
pause(1);
roi1 = drawfreehand();
fig1.Position = [10 screensizey (scrsize(3)-10)/2 scrsize(4)/1.5];
hold off;
%
fig2 = figure(2);

set(fig2,'WindowbuttonDownFcn',@clickcallback);
ax2 = axes;
hold on;
title('ROI 2');

fig2.Units = 'Pixels';
imshow(I2, 'Parent', ax2);
fig2.Position = [10+(scrsize(3)-10)/2 screensizey (scrsize(3)-10)/2 scrsize(4)/1.5];
roi2 = images.roi.Freehand;
hold off;
fnames = fieldnames(roi1);
for i = 1:length(fnames)
    if ~contains(fnames, 'Parent')
        roi2.(fnames{i}) = roi1.(fnames{i});
    else
        roi2.Parent = ax2;
    end
    roi2.Position = roi1.Position;
    roi2.Selected = 1;
    drawnow;
    
end


while waitforme == 1 
    % Some delay
    pause(0.00001);    
end

maskref = roi1.createMask();
masktarg = roi2.createMask();
hFH1pos = roi1.Position;
hFH2pos = roi2.Position;

close(fig1);
close(fig2);
disp('ROIs are ready');




function clickcallback(obj,~)
global waitforme
switch get(obj,'SelectionType')
    case 'normal'
    case 'open'
        waitforme = 0;
end













