function [myObjHandles] = manualRegistration(Iref, Itarg)
    
%% This function allows the user to manually register Itarg with Iref, where I targ is mirrored Registeration supports rotation and translation

% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

%%
    global myObjHandles
    myObjHandles = struct;
    myObjHandles.translation = [0 0];
    myObjHandles.rotation = 0;
    
    hObj = figure;
    hObj.Units = 'Normalized';
    hObj.Position = [0 0 1 1];
    hObj.Units = 'Pixels';
    title('Use mouse1 and mouse2 to translate and rotate');
    handles = guidata(hObj);
    handles.Iorig = Itarg;
    hold on;
    set(gca,'XColor', 'none','YColor','none');
    handles.translations = [0, 0];
    handles.hAx = axes;
    handles.I2 = Itarg;
    handles.I1 = Iref;
    imshowpair(handles.I1, handles.I2, 'Scaling','independent','Parent',handles.hAx);
    hold off;
     % Initial mouseclick position
    handles.mousePositiondown = [0,0];
    handles.mousePositionup = [0,0];
    guidata(hObj, handles);
    % Mouseclick event listeler for the figure handle

    set(hObj, 'WindowButtonDownFcn', @callBack);
    set(hObj, 'WindowButtonUpFcn', @callBack2);
    
    
    guidata(hObj, handles);
    % Wait until figure gets closed
    while size(findobj(hObj))>0
        pause(0.00001);
    end
    disp('Manual registration ready');
    function callBack(hObject, ~)
        handles = guidata(hObject);
        % Get the initial mouse position
        handles.mousePositiondown = get(hObject,'CurrentPoint');
        guidata(hObject,handles);


    function callBack2(hObject, ~)
        handles = guidata(hObject);
        seltype = get(gcf,'SelectionType');
        handles.mousePositionup = get(hObject,'CurrentPoint');
        global myObjHandles
        
        switch seltype
            
            case 'normal'
                % Left button released -> translate
                %getpixelposition(hObject);
                myObjHandles.translation = myObjHandles.translation + [handles.mousePositionup(1) - handles.mousePositiondown(1), handles.mousePositiondown(2) - handles.mousePositionup(2)];
                handles.I2 = imtranslate(handles.I2, [handles.mousePositionup(1) - handles.mousePositiondown(1), handles.mousePositiondown(2) - handles.mousePositionup(2)]);
            case 'alt'
                % Right button released -> rotate
                % Compute the angle
                % 1st mouseposition angle (reference)
                
                
                [~, ix] = size(handles.I2);
           
                xdiff = handles.mousePositiondown(1) - handles.mousePositionup(1);
                ratio = xdiff/ix;
                
                angle = ratio*60;
                
                handles.I2 = imrotate(handles.I2, angle, 'Crop');
                myObjHandles.rotation = myObjHandles.rotation + angle;
                
                
            case 'extend'
                % Just for testing the final transformation
                
                handles.Ilast = imtranslate(handles.Iorig, myObjHandles.translation);
                handles.Ilast = imrotate(handles.Ilast, myObjHandles.rotation, 'Crop');
                figure(2);
                imshowpair(handles.I2, handles.Ilast);
                
                
            otherwise
                disp('Use mouse1, mouse2 or mouse3');
        end
        imshowpair(handles.I1, handles.I2,'Parent', handles.hAx);
        guidata(hObject, handles);
        
  
   
            
            
            
