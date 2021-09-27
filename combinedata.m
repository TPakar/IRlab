function combineddata = combinedata(folder)

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


mydir = dir(folder);

%%
combineddata = struct;
for i = 1:length(mydir)
    if mydir(i).isdir == 0
        % Order by frame numbers
        tempdata =  load([folder, '\', mydir(i).name]);
        field = fieldnames(tempdata);
        finalfields = fieldnames(tempdata.(field{1}));
        for j = 1:length(finalfields) 
            combineddata.(finalfields{j}) = tempdata.(field{1}).(finalfields{j});  
        end
    end
    
end