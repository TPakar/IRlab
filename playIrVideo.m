function [RGBim, RGBim2, floatim, floatim2] = playIrVideo(imagedata, imagedataorig, rangev, vidspeed, scalediv, videoON, showcurve, skipnum, fwid, fhei, startf, endf, varargin)



if isempty(varargin)
   colorpal = 'simple';
   disp('No colormap chosen. Using default linear colormap with gaussian green');
else
   colorpal = varargin{1};
   disp(['Using colormap: ' colorpal]);
end

% Set temperature range here
temprange = rangev;

numberofcolors = length(temprange);
% Change playback speed
videorefreshdelay = vidspeed;

% test plot
tempplot = zeros(length(fieldnames(imagedata)));

% Find screen size and video scale and set parameters for presentation
scrsize = get(0,'screensize');
vidxpos = scrsize(3)/4; 
vidypos = scrsize(4)/4;
%
try
    close(figure(1))
catch
end
if videoON == true
    num = startf;
    figure(1);
    subplot(1,2,2)
    title('Original data');
    imshow(imagedata.(['frame',num2str(num)]).^3/scalediv);
    subplot(1,2,1)
    title('Processed data');

    try
        imshow(imagedataorig.(['frame',num2str(num)]).^3/scalediv);
    catch
        imagedataorig = imagedata;
        imshow(imagedataorig.(['frame',num2str(num)]).^3/scalediv);
        disp('Error');
    end
end
%
% set color range here (red, blue, green). Change these and/or the
% distributions below to change the color schemes
newcolmap = computeNewColorMap(rangev, colorpal);
Redrange = newcolmap(:,1);
Greenrange = newcolmap(:,2);
Bluerange = newcolmap(:,3);

% Define color scale

tscale = {(temprange)', [Redrange, Greenrange, Bluerange]};
%figure(1);
if videoON == true
    set(gcf, 'Position', [vidxpos vidypos scrsize(4) scrsize(3)]);
    %title('Your video');
    hold on;

% Plot color scale bar
    h2 = subplot(2,2,2);
    colorbar;
    subplot(2,2,1);
    colorbar;
    caxis([temprange(1), temprange(end)]);
    cscale = tscale{1,2}/255;
    cb = colormap(cscale);


    % Initial plot point position
    handles.mousePosition = [round(fhei), round(fwid)];
    % Mouseclick event listeler for the figure handle
    set(gcf, 'WindowButtonDownFcn',@callBack)
    % Change axes units to get position
    set(h2, 'Units', 'Pixels');
    handles.h2boundaries = get(h2, 'Position');
    set(h2, 'Units', 'Normalized');
    figureboundaries = get(gcf, 'Position');
end


% Transform the temperature image matrix to RBG image
RGBim = struct;
RGBim2 = struct;
rgbcount = 1;


for i = startf:endf
    % Processed
    tempim = floor(imagedata.(['frame', num2str(rgbcount)]));
    floatim.(['frame', num2str(rgbcount)]) = imagedata.(['frame', num2str(rgbcount)]);
    
    % Original
    tempim2 = floor(imagedataorig.(['frame', num2str(i)]));
    floatim2.(['frame', num2str(rgbcount)]) = imagedataorig.(['frame', num2str(i)]);
    
    if videoON == true && mod(rgbcount,skipnum) == 0
        RGBim.(['frame', num2str(rgbcount)])(:,:,1) = tempim;
        RGBim.(['frame', num2str(rgbcount)])(:,:,2) = tempim;
        RGBim.(['frame', num2str(rgbcount)])(:,:,3) = tempim;
        RGBim2.(['frame', num2str(rgbcount)])(:,:,1) = tempim2;
        RGBim2.(['frame', num2str(rgbcount)])(:,:,2) = tempim2;
        RGBim2.(['frame', num2str(rgbcount)])(:,:,3) = tempim2;
        for j = 1:length(tscale{1,1})
            % Processed
            RGBim.(['frame', num2str(rgbcount)])(:,:,1) = changem(RGBim.(['frame', num2str(rgbcount)])(:,:,1), tscale{1,2}(j,1),tscale{1,1}(j));      % red channel
            RGBim.(['frame', num2str(rgbcount)])(:,:,2) = changem(RGBim.(['frame', num2str(rgbcount)])(:,:,2), tscale{1,2}(j,2),tscale{1,1}(j));      % green channel
            RGBim.(['frame', num2str(rgbcount)])(:,:,3) = changem(RGBim.(['frame', num2str(rgbcount)])(:,:,3), tscale{1,2}(j,3),tscale{1,1}(j));      % blue channel
            % Original
            RGBim2.(['frame', num2str(rgbcount)])(:,:,1) = changem(RGBim2.(['frame', num2str(rgbcount)])(:,:,1), tscale{1,2}(j,1),tscale{1,1}(j));      % red channel
            RGBim2.(['frame', num2str(rgbcount)])(:,:,2) = changem(RGBim2.(['frame', num2str(rgbcount)])(:,:,2), tscale{1,2}(j,2),tscale{1,1}(j));      % green channel
            RGBim2.(['frame', num2str(rgbcount)])(:,:,3) = changem(RGBim2.(['frame', num2str(rgbcount)])(:,:,3), tscale{1,2}(j,3),tscale{1,1}(j));      % blue channel
        end
        RGBim.(['frame', num2str(rgbcount)]) = uint8(RGBim.(['frame', num2str(rgbcount)]));
        RGBim2.(['frame', num2str(rgbcount)]) = uint8(RGBim2.(['frame', num2str(rgbcount)]));
        
        
        % Show processed
        if rgbcount == 1 || (rgbcount > 1 && rgbcount == skipnum)
           subplot(2,2,2);
           %if strcmp(colorpal, 'simple')
                hImage = imshow(RGBim.(['frame', num2str(rgbcount)])); 
%            else 
%                dispim = rescale(floatim.(['frame', num2str(rgbcount)]),rangev(1), rangev(end));
%                hImage = imshow(uint8(dispim)); 
%                colormap(colormap(gca, jet(50)));
%                colorbar(gca);
%            end
        else
            %if strcmp(colorpal, 'simple')
                set(hImage, 'CData', RGBim.(['frame', num2str(rgbcount)]));
                set(gcf, 'Position', [vidxpos vidypos scrsize(3)/2 scrsize(4)/2]);
%             else
%                 dispim = rescale(floatim.(['frame', num2str(rgbcount)]),rangev(1), rangev(end));
%                 set(hImage, 'CData', uint8(dispim));
%                 set(gcf, 'Position', [vidxpos vidypos scrsize(3)/2 scrsize(4)/2]);
%             end
        end
        % Show original
        if rgbcount == 1 || (rgbcount > 1 && rgbcount == skipnum)
           subplot(2,2,1);
           hImage2 = imshow(RGBim2.(['frame', num2str(rgbcount)])); 
        else
            set(hImage2, 'CData', RGBim2.(['frame', num2str(rgbcount)]));
            set(gcf, 'Position', [vidxpos vidypos scrsize(3)/2 scrsize(4)/2]);
            title(num2str(i));
        end
        
        subplot(2,2,3);
        drawnow

        if showcurve == 1
            tempplot(i) = imagedata.(['frame', num2str(i)])(handles.mousePosition(2), handles.mousePosition(1));
            if rgbcount ==1
                hplot = plot(tempplot);
            elseif mod(i,2) == 0
                set(hplot, 'YData', tempplot(1:i));
            end
        end
        pause(videorefreshdelay);
    % Do not play the video, just get the first rgb frame for later
    else
        if i == startf
           RGBim.(['frame', num2str(rgbcount)])(:,:,1) = tempim;
            RGBim.(['frame', num2str(rgbcount)])(:,:,2) = tempim;
            RGBim.(['frame', num2str(rgbcount)])(:,:,3) = tempim;
            RGBim2.(['frame', num2str(rgbcount)])(:,:,1) = tempim2;
            RGBim2.(['frame', num2str(rgbcount)])(:,:,2) = tempim2;
            RGBim2.(['frame', num2str(rgbcount)])(:,:,3) = tempim2;
           for j = 1:length(tscale{1,1})
                % Processed
                RGBim.(['frame', num2str(rgbcount)])(:,:,1) = changem(RGBim.(['frame', num2str(rgbcount)])(:,:,1), tscale{1,2}(j,1),tscale{1,1}(j));      % red channel
                RGBim.(['frame', num2str(rgbcount)])(:,:,2) = changem(RGBim.(['frame', num2str(rgbcount)])(:,:,2), tscale{1,2}(j,2),tscale{1,1}(j));      % green channel
                RGBim.(['frame', num2str(rgbcount)])(:,:,3) = changem(RGBim.(['frame', num2str(rgbcount)])(:,:,3), tscale{1,2}(j,3),tscale{1,1}(j));      % blue channel
                % Original
                RGBim2.(['frame', num2str(rgbcount)])(:,:,1) = changem(RGBim2.(['frame', num2str(rgbcount)])(:,:,1), tscale{1,2}(j,1),tscale{1,1}(j));      % red channel
                RGBim2.(['frame', num2str(rgbcount)])(:,:,2) = changem(RGBim2.(['frame', num2str(rgbcount)])(:,:,2), tscale{1,2}(j,2),tscale{1,1}(j));      % green channel
                RGBim2.(['frame', num2str(rgbcount)])(:,:,3) = changem(RGBim2.(['frame', num2str(rgbcount)])(:,:,3), tscale{1,2}(j,3),tscale{1,1}(j));      % blue channel
            end
            RGBim.(['frame', num2str(rgbcount)]) = uint8(RGBim.(['frame', num2str(rgbcount)]));
            RGBim2.(['frame', num2str(rgbcount)]) = uint8(RGBim2.(['frame', num2str(rgbcount)]));
            
        end
    end
    rgbcount = rgbcount+1;
end

if videoON == true
    hold off;
    pause(0.1);
    close(figure(1));
end




 function callBack(hObject,~)
    handles.mousePosition = get(hObject,'CurrentPoint');
  
    handles.mousePosition = round((handles.mousePosition - [handles.h2boundaries(1), handles.h2boundaries(3)]));
    handles.mousePosition(2) = fhei - handles.mousePosition(2);
    if handles.mousePosition(1) < 0
        handles.mousePosition(1) = 1;
    elseif handles.mousePosition(1) > fwid
        handles.mousePosition(1) = fwid;
    end
    if handles.mousePosition(2) < 0
        handles.mousePosition(2) = 1;
    elseif handles.mousePosition(2) > fhei
        handles.mousePosition(2) = fhei;
    end
    
    disp(['You clicked (mouse - pos) X:',num2str(handles.mousePosition(1)),',  Y:',num2str(handles.mousePosition(2))]);
    hold on;
    try 
        delete(point)
        point = loglog(handles.mousePosition(1),handles.mousePosition(2),'ko','markerfacecolor','w','markersize',4);
    catch
        point = loglog(handles.mousePosition(1),handles.mousePosition(2),'ko','markerfacecolor','w','markersize',4);
        disp('Error while deleting point');
    end
    hold off;
 end

end
