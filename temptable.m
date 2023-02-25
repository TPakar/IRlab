function [newtable, gottable] = temptable(tparams, chosenROI)

% Author Tomppa Pakarinen

% Input = IRlab params structure from the temperature analyssis

% Output = Parameters presented in a table
%%
%tparams = savedata;
newtable = table();



fnames = fieldnames(tparams.timeconstants);
fnames = chosenROI;

for i = 1:length(fnames)
   newtable.(fnames{i}) = [tparams.timeconstants.(fnames{i}).tau; tparams.timeconstants.(fnames{i}).T0; tparams.timeconstants.(fnames{i}).params{1,end};...
       tparams.timeconstants.(fnames{i}).params{1,end} - tparams.timeconstants.(fnames{i}).T0; tparams.timeconstants.(fnames{i}).params{end-1,2};...
       tparams.timeconstants.(fnames{i}).params{end,2}];

end

newtable.Properties.RowNames = {'timeconstant'; 'Tstart'; 'Tend'; 'Tend-Tstart';'Tstart-T0'; 'Tend-T0'};


%%

gottable = table();
fnames = fieldnames(tparams.timeconstants);
fnames = chosenROI
for i = 1:length(fnames)
   gottable.(fnames{i}) = [tparams.timeconstants.(fnames{i}).GOT.sse; tparams.timeconstants.(fnames{i}).GOT.rsquare; ...
       tparams.timeconstants.(fnames{i}).GOT.dfe; tparams.timeconstants.(fnames{i}).GOT.adjrsquare; tparams.timeconstants.(fnames{i}).GOT.rmse];
end

gottable.Properties.RowNames = {'sse'; 'rsquare'; 'dfe'; 'adjrsquare'; 'rmse'};







