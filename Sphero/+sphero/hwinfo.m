classdef hwinfo < handle
    %HWINFO Hardware related information of the connected Sphero
    %   OBJ = SPHERO.HWINFO(SPHEROOBJ) creates a object which provides hardware
    %   information of connected Sphero
    %
    %   hwinfo properties:
    %       Address                 - Bluetooth address of Sphero
    %       ConnectionColor         - Colors with which Sphero blinks when not connected to any device
    %       InternalBluetoothName   - Name that is set for the Sphero internally
    %
    %   hwinfo methods:
    %       getVoltageTripPoints    - Get the voltage points for what Sphero considers Low Battery and Critical battery 
    %       powerNotification       - Set whether the Sphero should send asynchronous message with the power state periodically 
    %       readPowerState          - Retrieve the power state of the sphero 
    %       setVoltageTripPoints    - Set the voltage points for what Sphero considers Low Battery and Critical battery 
    %       version                 - Hardware and software version of connected Sphero 
    %
    %   Examples:
    %       hw = sphero.hwinfo(sph);
    %       conncol = hw.ConnectionColor
    %       
    %       power = readPowerState(hw)
    %
    %   See also:
    %       SPHERO
    %       SPHERO.HARDWAREINFO
    %       <a href="matlab:showdemo('sphero_examples')">Sphero Connectivity Package Examples</a>
    %
    %   Copyright 2015, The MathWorks, Inc.
    
    
    
    
    properties(SetAccess = private, GetAccess = public)
        %Address - Bluetooth address of Sphero
        Address
        %ConnectionColor - The 3 colors with which Sphero blinks when not connected to any device
        % For example: PRB denotes Purple Red Blue
        ConnectionColor

    end
    
    properties
        %InternalBluetoothName - Name that is set for the Sphero internally 
        % This name can be different from the standard 'Sphero-colors' 
        % pattern that is used as the name of the Bluetooth device when 
        % connecting over Bluetooth, where 'colors' are the shortnames of 
        % the 3 colors with which the Sphero blinks when not connected to 
        % any device (ConnectionColor). This name is internally held by the
        % Sphero.
        InternalBluetoothName
    end
    
    properties (Access = private)
        %SpheroObj - Object of Sphero class, which is the device to which currently connected 
        SpheroObj
    end
    
    methods (Access = private)
        function [internalname, btaddress, idcolors] = btInfo(obj)
        %BTINFO Retrieve the Bluetooth information from the Sphero. 
        % This includes internal name, Bluetooth address and the colors
        % with which Sphero blinks when not connected to any device
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'getbtname', [], 1);
            out = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            if length(out)<3
                error('btInfo:InvalidResponse', 'Invalid response received');
            else
                internalname = deblank(out(1, :));
                btaddress = deblank(out(2, :));
                idcolors = deblank(out(3, :));
            end
         
        end
        
        function varargout = deviceName(obj, name)
        %DEVICENAME Set the internal name of Sphero
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'setbtname', [], [], [], name);
            response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            [varargout{1:nargout}] = sphero.simpleResponse(response);
        end
        
        function powerstate = decodePowerState(obj, stateID) %#ok<INUSL>
        %DECODEPOWERSTATE Decode the Power state from the ID
            err = MException('Hwinfo:DecodePowerState:InvalidResponse', 'Invalid response received.');
            
             switch stateID
                    case 1
                        powerstate = 'Charging';
                    case 2
                        powerstate = 'Battery OK';
                    case 3
                        powerstate = 'Battery Low';
                    case 4
                        powerstate = 'Battery Critical';
                    otherwise
                        throwAsCaller(err);
             end
        end
         
    end
    
    methods
        function obj = hwinfo(spheroObj)
        %HWINFO Hardware related information of the connected Sphero
        %   OBJ = HWINFO(SPHEROOBJ) creates a object which provides hardware
        %   information of connected Sphero
            obj.SpheroObj = spheroObj;
            [internalname, btaddress, idcolors] = btInfo(obj);
            
            obj.InternalBluetoothName = internalname;
            obj.Address = btaddress;
            obj.ConnectionColor = idcolors;
            
        end
            
        function ver = version(obj) %%NOTE: Not working at present!
        %VERSION Hardware and software version of connected Sphero
        %   VER = VERSION(HW) returns the various hardware and software
        %   versions of the Sphero as a struct with the following fields:
        %       RecordVersion 
        %       ModelNumber
        %       HardwareVersion 
        %       MainSpheroApplicationVersion
        %       MainSpheroApplicationRev
        %       BootloaderVersion
        %       OrbBasicVersion
        %       MacroExecutiveVersion
        %       ApiMajorRev
        %       ApiMinorRev
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'version', [], 1);
            ver = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
        end
        
        function [powerstate, varargout] = readPowerState(obj)
        %READPOWERSTATE Retrieve the power state of the sphero
        %   POWERSTATE = READPOWERSTATE(HWINFOOBJECT) returns the current 
        %   power state of the sphero as a string
        %   
        %   [POWERSTATE, VOLTAGE] = READPOWERSTATE(HWINFOOBJECT) 
        %   returns the current battery voltage along with the power state
        %   
        %   [POWERSTATE, VOLTAGE, CHARGES] = READPOWERSTATE(HWINFOOBJECT)
        %   returns the Number of battery recharges in the life of the
        %   Sphero, besides the power state and voltage
        %   
        %   [POWERSTATE, VOLTAGE, CHARGES, TIMEAWAKE]  = READPOWERSTATE(HWINFOOBJECT)
        %   returns the time (in seconds) since last recharge as well

            nargoutchk(0, 4);
            
            err = MException('Hwinfo:ReadPowerState:InvalidResponse', 'Invalid response received.');
            
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'getpwrstate', [], 1);
            out = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            try
                state  = out{2};
               
                powerstate = decodePowerState(obj, state);
           
                voltage     = out{3}/100; % The returned value is in 100ths of a volt

                if nargout>1
                    varargout{1} = voltage;
                    if nargout>2
                        varargout(2:nargout-1) = out(4:nargout+1);
                    end
                end
                
            catch exception
                if strncmp('Sphero', exception.identifier, 6)||strncmp('Hwinfo', exception.identifier, 6)
                    rethrow(exception)
                else
                    exception2 = addCause(err, exception);
                    throw(exception2);
                end
                
            end
                
            
        end
        
        function varargout = powerNotification(obj, flag)
        %POWERNOTIFICATION Set whether the Sphero should send asynchronous message with the power state periodically and when the power state changes
        %   POWERNOTIFICATION(HWINFOOBJECT, FLAG) enables the
        %   periodic power state notification when FLAG is 1, and
        %   disables it when FLAG is 0
        %
        %   RESULT = POWERNOTIFICATION(HWINFOOBJECT, FLAG) returns 1 if the command 
        %   succeeds, otherwise it returns 0
            
            nargoutchk(0,1);
            
            p = inputParser;
            addRequired(p, 'flag',  @(x) isnumeric(x) && (x==0 || x==1));
            parse(p, flag);
            
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'setpwrnotify', [], [], [], flag);
            response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            [varargout{1:nargout}] = sphero.simpleResponse(response);
            
        end
        
        function [vlow, vcrit] = getVoltageTripPoints(obj)
        %GETVOLTAGETRIPPOINTS Get the voltage points for what Sphero considers Low Battery and Critical battery
        %   [VLOW, VCRITICAL] = GETVOLTAGETRIPPOINTS(HWINFOOBJECT)
        %   returns the voltage points for low battery and critical
        %   battery
            
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'getpowertrips', [], 1);
            response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            vlow = double(response(1))/100; % The returned value is in 100ths of a volt
            vcrit = double(response(2))/100; % The returned value is in 100ths of a volt
 
        end
        
        function varargout = setVoltageTripPoints(obj, vlow, vcrit)
        % SETVOLTAGETRIPPOINTS Set the voltage points for what Sphero considers Low Battery and Critical battery
        %   SETVOLTAGETRIPPOINTS(HWINFOOBJECT, VLOW, VCRITICAL)
        %   sets the low and critical battery voltage levels for the 
        %   Sphero. The low battery voltage should be in the range 6.5V
        %   to 7.5V. The critical battery voltage should be in the range
        %   6.0V to 7.0V, and there must be a minimum separation of 0.25V
        %   between the two values.
        %
        %   RESULT = SETVOLTAGETRIPPOINTS(HWINFOOBJECT, VLOW, VCRITICAL)
        %   returns 1 if the command succeeds, otherwise it returns 0
            
            p = inputParser;
            addRequired(p, 'objectname');
            addRequired(p, 'vlow',  @(x) isnumeric(x) && (x>=6.5&&x<=7.5));
            addRequired(p, 'vcrit',  @(x) isnumeric(x) && (x>=6&&x<=7));
            parse(p, obj, vlow, vcrit);
            
            if vlow-vcrit<0.25
                error(['There must be a minimum separation of 0.25V '...
                    'between the low and critical battery voltage values']);
            end
            
            
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'setpowertrips', [], [], [], vlow*100, vcrit*100);
            response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            [varargout{1:nargout}] = sphero.simpleResponse(response);
            
        end
        
       
    end
    
    methods
        %GET / SET Methods
        function  set.InternalBluetoothName(obj, value)
        %set.InternalBluetoothName Custom setter for InternalBluetoothName property
            if ~strcmp(value, obj.InternalBluetoothName)
                result = deviceName(obj, value);
                
                if ~result
                    error('InternalBluetoothName:InvalidResponse', ...
                        'Unable to set internal bluetooth name.');
                end
                
            end
            
            obj.InternalBluetoothName = value;
        end
        
        function name = get.InternalBluetoothName(obj)
        %get.InternalBluetoothName Custom getter for InternalBluetoothName property
            name = obj.InternalBluetoothName;
        end
        
        
    end
    
    methods (Hidden = true)
    % Advanced commands
        function devicemode = deviceMode(obj)
        %DEVICEMODE The current device mode of the Sphero (Normal or User Hack)
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'getdevicemode', [], 1);
            response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            switch response
                case 0
                    devicemode='Normal';
                case 1
                    devicemode = 'User Hack';
                otherwise
                    devicemode = 'error';
            end
        end 
        
        function diag = diagnostics(obj)
        %DIAGNOSTICS Diagnostics information of the Sphero, to help diagnose aerrant behavior
        %   DIAG = DIAGNOSTICS(HW) returns the diagnostic information as a
        %   struct with the following fields:
        %       RecordVersion
        %       GoodPacketsReceived
        %       BadDeviceIDPackets
        %       BadDataLengthPackets
        %       BadCommandIDPackets
        %       BadChecksumPackets
        %       ReceiveBufferOverruns
        %       MessagesTransmitted
        %       TransmitBufferOverruns
        %       ChargeCycles
        %       SecondsSinceCharge
        %       SecondsOn
        %       DistanceRolled
        %       SensorFailures
        %       GyroAdjustCount
        
            err = MException('Hwinfo:Diagnostics:InvalidResponse', 'Invalid response received.');
            
            try
                [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'runl2diags', [], 1);
                response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);

                diag.RecordVersion = response{1};
                diag.GoodPacketsReceived = response{2};
                diag.BadDeviceIDPackets = response{3};
                diag.BadDataLengthPackets = response{4};
                diag.BadCommandIDPackets = response{5};
                diag.BadChecksumPackets = response{6};
                diag.ReceiveBufferOverruns = response{7};
                diag.MessagesTransmitted = response{8};
                diag.TransmitBufferOverruns = response{9};
                diag.ChargeCycles = response{12};
                diag.SecondsSinceCharge = response{13};
                diag.SecondsOn = response{14};
                diag.DistanceRolled = response{15};
                diag.SensorFailures = response{16};
                diag.GyroAdjustCount = response{17};
                
            catch exception
                
                if strncmp('Sphero', exception.identifier, 6)||strncmp('Hwinfo', exception.identifier, 6)||isnan(response)
                    rethrow(exception)
                else
                    exception2 = addCause(err, exception);
                    throw(exception2);
                end
                
            end
        end
        
        function varargout = clearCounters(obj)
        %CLEARCOUNTERS Clear the counters that are used in the Diagnostic information
        %   CLEARCOUNTERS(HW) clears the counters such as the
        %   GoodPacketReceived, BadDeviceIDPackets, BadCommandIDPackets etc
        %
        %   RESULT = CLEARCOUNTERS(HW) returns 1 if the command succeeds, 
        %   otherwise it returns 0
            [responseexpected, seq] = sendCmd(obj.SpheroObj.Api, 'clearcounters', [], [], []);
            response = readResponse(obj.SpheroObj.Api, responseexpected, seq, obj.SpheroObj.ResponseTimeout);
            
            [varargout{1:nargout}] = sphero.simpleResponse(response);
        end
        
        function delete(obj)
        %DELETE Delete the Hardware Information object
        
            if strcmp(obj.SpheroObj.Status, 'open')
               powerNotification(obj, 0) % Turn off power notification, so that sphero does not keep responding with its power state
            end
        end
    end
end

