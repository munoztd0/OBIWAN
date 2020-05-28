function [resultFile, participantID] = createResultFile (var) %% modified on the 23.02.2015
        % Ask the participand ID
        participantID = str2double(inputdlg('Enter subject ID','Input required'));
        
        % Create the participant results file
<<<<<<< HEAD
        resultFile = (['conditioning_' num2str(participantID) '.mat']);
=======
        resultFile = (['conditioning' num2str(participantID) '.mat']);
>>>>>>> 30975edd155283d3babbc556caf4a272cff0470b
        
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