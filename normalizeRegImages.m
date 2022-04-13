function [normdata] = normalizeRegImages(inputdata, screensizex, screensizey, scrsize)

%% Normalize to ref area

% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

% Save the original data
imdataorig = inputdata;
maxtemp1 = max(max(inputdata.frame1));

normdata = struct;
[~, areanorm] = imcrop(uint8(inputdata.frame1./maxtemp1*255));
set(gcf, 'Position', [screensizex screensizey scrsize(4) scrsize(3)]);
close(figure(1));

% Rectangle coordinates
x22 = floor(areanorm(1)):(floor((areanorm(3))+floor(areanorm(1))));
y22 = floor(areanorm(2)):(floor((areanorm(4))+floor(areanorm(2))));
refmean = mean(inputdata.frame1(y22,x22));
normdata.frame1 = inputdata.frame1;
for i = 2:length(fieldnames(inputdata))
   % Find the normalization constant of the current frame and normalize whole image to
   % reference background value
    framemean = mean(inputdata.(['frame',num2str(i)])(y22,x22));
    normconst = refmean/framemean;
    % Normalize
    normdata.(['frame', num2str(i)]) = inputdata.(['frame',num2str(i)])*normconst;
end   

