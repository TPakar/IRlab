function [imdata] = readcsvdata(directory, readall, skipcondition, delimiter, skipnumber, stopcondition, fs, framesiz, structcount)

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


direct = dir(directory);
tic

if readall == 0
    for i = 1:length(direct)
        h = waitbar(0, ['Importing partition ', num2str(i),'/',num2str(length(direct))]);
        drawnow;
        if direct(i).bytes > 0
            
            % 2x slower implementation but partitions correctly
            temp = fastread([direct(1).folder,'\'], direct(i).name, delimiter, lower(skipcondition), skipnumber, stopcondition);
            
            tempname = fieldnames(temp);
            if length(tempname) == 1
                imdata.(['frame',num2str(structcount)]) = str2double(strrep(temp.([tempname{1}]),',','.'));
            else
                for j = 0:length(tempname)-1
                    imdata.(['frame',num2str(j+structcount)]) = str2double(strrep(temp.([tempname{j+1}]),',','.'));
                    if mod(j,50) || j == length(tempname)-1
                        waitbar(structcount/length(tempname),h);
                        drawnow;
                    end
                end
                structcount = structcount + j;
                
            end
           % structcount = structcount + 1;
        end
        toc
        disp(['file number: ', num2str(structcount)]);
        
    end
    delete(h);
    
else
    h = waitbar(0, "Importing data...");
    for i = 1:length(direct)
    
    if direct(i).bytes > 0
        
        % Fastest code for partitioned FLIR E8 CSV data
        temp = fasterread([direct(1).folder,'\'], direct(i).name, delimiter, skipcondition, fs, framesiz, structcount);
        tempname = fieldnames(temp);
        
        if length(tempname) == 1
            imdata.(['frame',num2str(structcount)]) = temp.(tempname(1));
        else
            for j = 0:length(tempname)-1
                imdata.(['frame',num2str(j+structcount)]) = temp.([tempname{j+1}]);
                %if mod(j,50) || j == length(tempname)-1
                     waitbar(j/length(tempname),h, ['Importing partition ', num2str(i),'/',num2str(length(direct))]);
                %end
            end
            structcount = structcount + j;
        end
       % structcount = structcount + 1;
    end
    toc
    disp(['Frame number: ', num2str(structcount), 'read']);
    end
end

delete(h);