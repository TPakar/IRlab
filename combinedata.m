function combineddata = combinedata(folder)

%% This function combines parsed thermal data imports
% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

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