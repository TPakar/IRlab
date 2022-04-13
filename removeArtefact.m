function [outputsignal, artefactlimits, repairlimits, repairlimitsTemp, offsetpoint, offsetval, method] = removeArtefact(xdat, signalin, fs, highpasslim, applytoall, artlims, replims, replimstemp, offset, offsetv, method)


%% This function removes artefact via user input.
% Artefacts are divided in two classes = recoverable and non-recoverable

% Recoverable data spares the high frequency component and interpolates a
% baseline between the two chosen points

% Non-recoverable data means data, which has lost its high frequency
% componen and should be completely interpolated over

% Find artefacts by user input

% Copyright Tomppa Pakarinen (tomppa.pakarinen@tuni.fi)
% Cite: https://doi.org/10.1016/j.imu.2022.100940
%%


if applytoall == 0
    method = inputdlg("Choose method (offset Y = 1, interpolate = 2)");
end

switch method{1}
    
    case '2'
        offsetpoint = [];
        offsetval = [];
        signalOK{1} = '0';
        round = 1;
        while signalOK{1} == '0'
        if round == 1
            outputsignal = signalin;
        end
        %tonicsignal = varagin{2};

        % Find artefacts by user input

        
        %try
            if applytoall == 0
                figure(11);
                hold on;
                title("Confine each artefact by choosing start and end points");
                plot(xdat, outputsignal);
                numberofartefacts = inputdlg("Num. of artefacts");
            else
                numberofartefacts{1} = char(length(artlims)/2) + '0';
            end
            if numberofartefacts{1} ~= '0'
                if applytoall == 0
                    numberofrepairs = inputdlg("Num. of repairable sections");
                    artefactlimits = ginput(str2double(numberofartefacts{1})*2);
                    title("Choose repairable artefacts");
                    hold on;
                    
                else
                    artefactlimits = artlims;
                end
                
                xlim = zeros(size(artefactlimits,1)/2,2);
                for j = 1:2:size(artefactlimits,1)
                    [~, xlim(j,1)] = min(abs(xdat - artefactlimits(j,1)));
                    [~, xlim(j+1,1)] = min(abs(xdat - artefactlimits(j+1,1)));
                    
                    plot(xdat(xlim(j,1):xlim(j+1,1)), outputsignal(xlim(j,1):xlim(j+1,1)), 'linewidth', 2, 'color', 'r');
                    drawnow
                end
                if applytoall == 0
                    repairlimitsTemp = ginput(str2double(numberofrepairs{1}));
                else
                    repairlimitsTemp = replimstemp;
                    
                end
                repairlimits = [];
                repcount = 1;
                for j = 1:size(repairlimitsTemp,1)
                    repairlimitsTemp(j,1)
                    [~, idx] = min(abs(xdat - repairlimitsTemp(j,1)));
                    [~, repidx] = min(abs(xlim(:,1) - idx));
                    if mod(repidx,2) == 0
                        repidx = repidx-1;
                    end
                    if applytoall == 0 
                        artefactlimits(repidx:repidx+1,1:2)
                        repairlimits(repcount:repcount+1,1:2) = artefactlimits(repidx:repidx+1,1:2);   
                    end
                    repcount = repcount + 2;
                    plot(xdat(xlim(repidx):xlim(repidx+1)), outputsignal(xlim(repidx):xlim(repidx+1)), 'linewidth', 2, 'color', 'g');
                    drawnow
                end
                artefactlimits
                repairlimits
                pause(1);
            else
                disp("No artefacts");
                artefactlimits = [];
                repairlimits = [];
                repairlimitsTemp = [];
                close(figure(11));
                break;
            end
        %catch
            %disp("Error in finding artefacts");
        %end
        if applytoall == 1
            repairlimits = replimstemp;
        end
        
        hold off;
        if applytoall == 0
            close(figure(11));
        end
        % Interpolate over the artefacts
        for i = 1:2:length(artefactlimits)-1
            if applytoall == 0
                [~, artefactlimits(i)] = min(abs(artefactlimits(i)- xdat));
                [~, artefactlimits(i+1)] = min(abs(artefactlimits(i+1)- xdat));
            end
            % interpolate over the section
            interpsignal = interp1([floor(artefactlimits(i,1)) floor(artefactlimits(i+1,1))], ...
                [outputsignal(floor(artefactlimits(i,1)),1) outputsignal(floor(artefactlimits(i+1,1)),1)],...
                floor(artefactlimits(i,1)):1:floor(artefactlimits(i+1,1)));
            % resize
            % Add the highpassfiltered data and interpolation together
            outputsignal(floor(artefactlimits(i,1)):floor(artefactlimits(i+1,1))) = interpsignal';
        end


        for i = 1:2:length(repairlimits)-1
            if applytoall == 0
                [~, repairlimits(i)] = min(abs(repairlimits(i)- xdat));
                [~, repairlimits(i+1)] = min(abs(repairlimits(i+1)- xdat));
            end
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
        artefactlimits = [];
        repairlimits = [];
        repairlimitsTemp = [];
        
        
        outputsignal = signalin;
        
        if applytoall == 0
            figure(11);
            hold on;
            xlabel('TimeAx');
            ylabel('Value');
            plot(xdat, outputsignal);
            hold off;
            offsetpoint = ginput(2);
            [~, offsetpoint(1)] = min(abs(offsetpoint(1)- xdat));
            [~, offsetpoint(2)] = min(abs(offsetpoint(2)- xdat));
            offsetval = inputdlg("Offset value (can be negative)");
            close(figure(11));
        else
            offsetpoint = offset;
            offsetval = offsetv;
        end
        
        
        
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





