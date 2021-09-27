function [outputsignal] = removeArtefact(xdat, signalin, fs, highpasslim)

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


%% This function removes artefact via user input.
% Artefacts are divided in two classes = recoverable and non-recoverable

% Recoverable data spares the high frequency component and interpolates a
% baseline between the two chosen points

% Non-recoverable data means data, which has lost its high frequency
% componen and should be completely interpolated over

% Find artefacts by user input

%%

method = inputdlg("Choose method (offset Y = 1, interpolate = 2)");
length(xdat)
length(signalin)

switch method{1}
    
    case '2'
        signalOK{1} = '0';
        round = 1;
        while signalOK{1} == '0'
        if round == 1
            outputsignal = signalin;
        end
        %tonicsignal = varagin{2};

        % Find artefacts by user input

        figure(11);
        hold on;
        title("Confine each artefact by choosing start and end points");
        plot(xdat, outputsignal);
        %try
            numberofartefacts = inputdlg("Num. of artefacts");
            if numberofartefacts{1} ~= '0'
                numberofrepairs = inputdlg("Num. of repairable sections");
                artefactlimits = ginput(str2double(numberofartefacts{1})*2);
                
                title("Choose repairable artefacts");
                hold on;
                xlim = zeros(size(artefactlimits,1)/2,2);
                for j = 1:2:size(artefactlimits,1)
                    [~, xlim(j,1)] = min(abs(xdat - artefactlimits(j,1)));
                    [~, xlim(j+1,1)] = min(abs(xdat - artefactlimits(j+1,1)));
                    
                    plot(xdat(xlim(j,1):xlim(j+1,1)), outputsignal(xlim(j,1):xlim(j+1,1)), 'linewidth', 2, 'color', 'r');
                    drawnow
                end
                repairlimitsTemp = ginput(str2double(numberofrepairs{1}));
                repairlimits = [];
                repcount = 1;
                for j = 1:size(repairlimitsTemp,1)
                    repairlimitsTemp(j,1)
                    [~, idx] = min(abs(xdat - repairlimitsTemp(j,1)));
                    [~, repidx] = min(abs(xlim(:,1) - idx));
                    if mod(repidx,2) == 0
                        repidx = repidx-1;
                    end
                    artefactlimits(repidx:repidx+1,1:2)
                    repairlimits(repcount:repcount+1,1:2) = artefactlimits(repidx:repidx+1,1:2);
                    repcount = repcount + 2;
                    plot(xdat(xlim(repidx):xlim(repidx+1)), outputsignal(xlim(repidx):xlim(repidx+1)), 'linewidth', 2, 'color', 'g');
                    drawnow
                end
                pause(1);
            else
                disp("No artefacts");
                close(figure(11));
                break;
            end
        %catch
            %disp("Error in finding artefacts");
        %end
        hold off;
        close(figure(11));
        % Interpolate over the artefacts
        for i = 1:2:length(artefactlimits)-1
            [~, artefactlimits(i)] = min(abs(artefactlimits(i)- xdat));
            [~, artefactlimits(i+1)] = min(abs(artefactlimits(i+1)- xdat));
            % interpolate over the section
            interpsignal = interp1([floor(artefactlimits(i,1)) floor(artefactlimits(i+1,1))], ...
                [outputsignal(floor(artefactlimits(i,1)),1) outputsignal(floor(artefactlimits(i+1,1)),1)],...
                floor(artefactlimits(i,1)):1:floor(artefactlimits(i+1,1)));
            % resize
            % Add the highpassfiltered data and interpolation together
            outputsignal(floor(artefactlimits(i,1)):floor(artefactlimits(i+1,1))) = interpsignal';
        end


        for i = 1:2:length(repairlimits)-1
            [~, repairlimits(i)] = min(abs(repairlimits(i)- xdat));
            [~, repairlimits(i+1)] = min(abs(repairlimits(i+1)- xdat));
            % Highpass filter the atrefact section
            sectionhighpass = highpass(signalin(floor(repairlimits(i,1)):floor(repairlimits(i+1,1)),1), highpasslim, fs, 'impulseresponse', 'iir');
            % Use medfilt for the section (remove sharp artefacts)
            %sectionsmoother = medfilt1(sectionhighpass,50);

            % interpolate over the section
            interpsignal = interp1([floor(repairlimits(i,1)) floor(repairlimits(i+1,1))], ...
                [outputsignal(floor(repairlimits(i,1)),1) outputsignal(floor(repairlimits(i+1,1)),1)],...
                floor(repairlimits(i,1)):1:floor(repairlimits(i+1,1)), 'linear');
            % resize
            % Add the highpassfiltered data and interpolation together
            outputsignal(floor(repairlimits(i,1)):floor(repairlimits(i+1,1))) = interpsignal' + sectionhighpass;
        end



        round = round + 1;

        figure(88);
        title("Output signal");
        plot(xdat, outputsignal);
        signalOK = inputdlg("Is the signal ok? (1=yes, 0 = no)");
        close(figure(88));
        end
    
    case '1'
        figure(11);
        hold on;
        xlabel('TimeAx');
        ylabel('Value');
        outputsignal = signalin;
        plot(xdat, outputsignal);
        hold off;
        offsetpoint = ginput(2);
        
        [~, offsetpoint(1)] = min(abs(offsetpoint(1)- xdat));
        [~, offsetpoint(2)] = min(abs(offsetpoint(2)- xdat));
        offsetval = inputdlg("Offset value (can be negative)");
        close(figure(11));
        figure(80);
        hold on;
        outputsignal(offsetpoint(1):offsetpoint(2)) = outputsignal(offsetpoint(1):offsetpoint(2)) + str2double(offsetval{1});
        plot(xdat, outputsignal);
        xlabel('TimeAx');
        ylabel('Value');
        hold off;
    otherwise
        disp('No valid method chosen! Choose either 1 or 2');
end





