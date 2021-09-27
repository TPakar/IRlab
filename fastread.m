function [outputdata] = fastread(fpath, fname, delimiter, skipcond, skipnum, stopcond)

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


% Not really that fast
% Reads text and tabula files fast
% inputs:
% 1. path to the file (char)
% 2. name of the file (char)
% 3. delimiting character (char)
% 4. skip condition delimiter (character or character vector = read from this to the next chunk) 
% 5. number of skips (how many met skip conditions will be ignored before saving the next)  (int) 
% 6. stop reading for the specific file after N number of conditions are met (int or -1/12 = until the end)

% output = structure with wanter frames/fields

% File info
fid = fopen([fpath, fname]);

outputdata = struct;
% Use fgetl to quickly read through lines reparated by newline characters. Use fgets to read line with the newline char

% Set initial values
line = string;
skipcount = 0;
childcount = 1;
sizefound = 0;
if stopcond  == inf
   stopcond = 100;
end




% Read array size between conditions
tempcount = 1;
while ~contains(lower(line), lower(skipcond)) || sizefound < 5
    line = fgetl(fid);
    tempcount = tempcount + 1;
    if contains(lower(line), lower(skipcond))
        sizefound = sizefound + 1;
        if sizefound == 4
           tempcount = 1; 
        end
    end
end
ysize = tempcount-1;
xsize = length(split(line,delimiter))-1;
% Size found -> rewind to start
frewind(fid)
% Re-init
%fopen([fpath, fname]);
line = string;
skip1 = 0;



while skipcount < stopcond
    % Read lines unltil the stop condition is found
    if skip1 == 0
        line = fgetl(fid);
        skip1 = 0;
    end
    if line == -1
       break;
    end
    if contains(lower(line),lower(skipcond))
        skipcount = skipcount + 1;
    end
    % Read and save until the skip condition is met again (or the file ends)
    if (mod(skipcount,skipnum) == 0 && skipcount > 0) || skipnum == 0
        % fill up until the stop condition
        %skipcount = 0;
        if stopcond > 0
            % Initialize new characterarray
            outputdata.([skipcond, num2str(childcount)]) = string(ones(ysize,xsize));
            % save values until next skipcondition is met
            tempcount = 1;

            while tempcount < ysize

                % Save delimiter separated line to the output structure
                try
                    temp = split(line, delimiter)';
                    outputdata.([skipcond, num2str(childcount)])(tempcount,1:end) = temp(2:end);
                    tempcount = tempcount + 1;
                catch
                   disp('Dimension missmatch'); 
                end
                % Read new line
                line = fgetl(fid);
                if contains(lower(line), lower(skipcond))
                   skip1 = 1;
                   break; 
                end
            end
        end
        childcount = childcount + 1;
    end
end


fclose(fid);














