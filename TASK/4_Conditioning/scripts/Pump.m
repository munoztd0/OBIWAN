classdef Pump < handle
    
    properties (Constant, SetAccess = private, GetAccess = private)
        maxPort = 64;
    end
    properties (SetAccess = private, GetAccess = public)
        connected = false;
        minVolume = nan;
        maxVolume = nan;
        minRate = nan;
        maxRate = nan;
    end
    properties (SetAccess = private, GetAccess = private)
        connexion = [];
        portName = '';
        private_simulationMode = false;
        private_diameter = nan;
        private_volume = nan;
        private_rate = nan;
    end
    properties (Dependent = true)
        simulationMode;
        diameter;
        volume;
        rate;
        time;
    end
    methods
        function value = get.simulationMode(self)
            value = self.private_simulationMode;
        end
        function self = set.simulationMode(self,value)
            self.private_simulationMode = value;
            self.disconnect();
        end
        function value = get.diameter(self)
            value = self.private_diameter;
        end
        function self = set.diameter(self,value)
            self.private_diameter = value;
            setDiameter(self,value);
        end
        function value = get.volume(self)
            value = self.private_volume;
        end
        function self = set.volume(self,value)
            if isnan(self.minVolume)
                fprintf('limits not initialized\n');
            elseif abs(value) > self.maxVolume || abs(value) < self.minVolume
                fprintf('value out of limits\n');
            else
                self.private_volume = value;
                setVolume(self,value);
                getMinMaxParams(self);
            end
        end
        function value = get.rate(self)
            value = self.private_rate;
        end
        function self = set.rate(self,value)
            if isnan(self.minRate)
                fprintf('limits not initialized\n');
            elseif value > self.maxRate || value < self.minRate
                fprintf('value out of limits\n');
            else
                self.private_rate = value;
                setRate(self,self.private_rate);
            end
        end
        function value = get.time(self)
            if isnam(self.private_volume)
                fprintf('Cannot calculate rate. Volume not initialized\n');
            else
                value = self.private_volume/self.private_rate;
            end
        end
        function self = set.time(self,value)
            value = self.private_volume/(value);
            if isnan(self.minRate)
                fprintf('limits not initialized\n');
            elseif value > self.maxRate || value < self.minRate
                fprintf('value out of limits\n');
            else
                self.private_rate = value;
                self.setRate(value);
            end
        end
    end
    methods (Access = private)
        
        function getMinMaxParams(self)
            if self.private_simulationMode
                self.maxVolume = 10000;
                self.minVolume = 0;
                self.maxRate   = 10000;
                self.minRate   = 0;
            else
                if self.isOpened()
                    line = self.transaction('read limit parameter');
                    limits = sscanf(line,'%f');
                    self.maxVolume = limits(1);
                    self.minVolume = limits(2);
                    self.maxRate   = limits(3);
                    self.minRate   = limits(4);
                end
            end
        end
        
        function setUnits(self)
            if self.private_simulationMode
                fprintf('invoking setUnits on port %s\n',self.portName);
            else
                self.transaction('set units 0');
            end
        end
        
        function setVolume(self,value)
            if self.private_simulationMode
                fprintf('invoking setVolume(%f) on port %s\n',value,self.portName);
            else
                command = sprintf('set volume %f',value);
                self.transaction(command);
            end
        end
        
        function setDiameter(self,value)
            if self.private_simulationMode
                fprintf('invoking setDiameter(%f) on port %s\n',value,self.portName);
            else
                command = sprintf('set diameter %f',value);
                self.transaction(command);
            end
        end
        
        function setRate(self,value)
            if self.private_simulationMode
                fprintf('invoking setRate(%f) on port %s\n',value,self.portName);
            else
                command = sprintf('set rate %f',value);
                self.transaction(command);
            end
        end
    end
    
    methods (Access = public)
        function ok = connect(self,port)
            name = self.getPortName(port);
            self.portName = name;
            if self.private_simulationMode
                fprintf('Connecting to pumps (simulation mode) on port %s\n',self.portName);
                self.setUnits();
                self.getMinMaxParams();
                self.connected = true;
                self.connexion = 0;
            else
                if ~isempty(self.connexion)
                    self.disconnect();
                end
                if ~self.portExistsAndConnected(port)
                    ok = false;
                    fprintf(['Serial port ',name,' not connected.\n']);
                else
                    self.connexion = self.initSerial(port);
                    fopen(self.connexion);
                    self.setUnits();
                    self.getMinMaxParams();
                    self.connected = true;
                end
            end
        end
        
        function disconnect(self)
            if self.private_simulationMode
                fprintf('Disconnecting from port %s\n',self.portName);
                self.connexion = [];
            else
                if ~isempty(self.connexion)
                    fclose(self.connexion);
                    delete(self.connexion);
                    self.connexion = [];
                end
            end
            self.connected = false;
        end
        
        function start(self)
            if self.private_simulationMode
                fprintf('invoking start() on port %s\n',self.portName);
            else
                self.transaction('start');
            end
        end
        
        function stop(self)
            if self.private_simulationMode
                fprintf('invoking stop() on port %s\n',self.portName);
            else
                self.transaction('stop');
            end
        end
        
        function pause(self)
            if self.private_simulationMode
                fprintf('invoking pause() on port %s\n',self.portName);
            else
                self.transaction('pause');
            end
        end
        
        function restart(self)
            if self.private_simulationMode
                fprintf('invoking restart() on port %s\n',self.portName);
            else
                self.transaction('restart');
            end
        end
        
        function delete(self)
            self.disconnect();
        end
        function s = test(self)
            if self.isOpened()
                fprintf(self.connexion,'hexr2\n');
                s = fgetl(self.connexion);
            else
                fprintf('Serial port not opened\n');
            end
        end
    end
    
%     methods (Static = true, Access = private)
%         function varargout = connexion(varargin)
%             persistent private_connexion;
%             if nargin > 0
%                 private_connexion = varargin{1};
%             else
%                 varargout{1} = private_connexion;
%             end
%         end
%     end
    
    methods (Access = public)
        function name = getPortName(self,portNum)
            name = ['COM',num2str(int16(portNum))];
        end

        function s = initSerial(self,port)
            name = self.getPortName(port);
            % tic;
            s = serial(name,...
                'BaudRate',38400,...
                'DataBits',8,...
                'FlowControl','none',...
                'Parity','none',...
                'StopBits',1,...
                'Timeout',0.3,...
                'Terminator','CR/LF');
            % fprintf('Initializing serial port %f\n',toc);
        end
        
        function portOK = portExistsAndConnected(self,portNum)
            portOK = true;
            self.connexion = self.initSerial(portNum);
            pause(0.1);
            try
%                 tic;
                fopen(self.connexion);
%                 fprintf('Opening serial port %f\n',toc);
            catch e
                fprintf('Failed to Open serial port %d\n',portNum);
                portOK = false;
            end
            if portOK
%                 tic;
                if isempty(self.transaction('read limit parameters'))
                    portOK = false;
                end
%                 fprintf('Talking through serial port %f\n',toc);
                tic;
                fclose(self.connexion);
%                 fprintf('Closing serial port %f\n',toc);
            end
            tic;
            delete(self.connexion);
%             fprintf('Deleting serial port %f\n',toc);

            self.connexion = [];
        end
        
        function ok = isOpened(self)
            if isempty(self.connexion)
%                 fprintf('Port not opened\n');
                ok = false;
            else
                ok = true;
            end
        end
        
        function result = transaction(self,command)
            if self.isOpened()
                fprintf(self.connexion,'%s\n',command);
                result = fgetl(self.connexion);
                if ~isempty(result)
                    result = fgetl(self.connexion);
                end
%             else
%                 fprintf('Port not opened\n');
            end
        end
        
        function portAvailables = scan(self)
            portAvailables = nan(self.maxPort,1);
            ind = 1;
            for port = 1:self.maxPort
%                 fprintf('Scanning port %d\n',port);
                if self.portExistsAndConnected(port)
                    fprintf('Port %d OK\n',port);
                    portAvailables(ind,1) = port;
                    ind = ind + 1;
                end
            end
            portAvailables = portAvailables(~isnan(portAvailables));
        end
    end
end

