function [] = writedatatotxt(data, outputname)

%% Write data to .txt file
% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940

fileID = fopen([outputname,'.txt'],'w');


for i =1:length(data)
    fprintf(fileID,'%i,%i\n', floor(data(i)), round((data(i)-floor(data(i)))*10000));
end
fclose(fileID);