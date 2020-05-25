function [resultFile, participantID] = createResultFile (var) %% modified on the 23.02.2015
        % Ask the participand ID
        participantID = str2double(inputdlg('Enter subject ID','Input required'));
        
        % Create the participant results file
        resultFile = (['conditioning' num2str(participantID) '.mat']);
        
        % Check that the file does not already exist to avoid overwriting
        cd(var.filepath.data); %go and check in the data file
        if exist(resultFile,'file')
            resp=questdlg({['The file ' resultFile ' already exists.']; 'Do you want to overwrite it?'},...
                'File exists warning','Cancel','Ok','Ok');
            
            if strcmp(resp,'Cancel') % Abort experiment if overwriting was not confirmed
                error('Overwriting was not confirmed: experiment aborted!');
            end
            
        end
        cd(var.filepath.scripts); %come back to the scripts folder
    end