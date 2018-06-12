classdef (Hidden = true) BluetoothApi<sphero.Communication
    %BLUETOOTHAPI API for sending commands to Sphero over Bluetooth
    %
    %   OBJ = BLUETOOTHAPI creates an object for the communication API for 
    %   communicating with Sphero over Bluetooth. 
    %
    % Copyright 2015, The MathWorks, Inc.
    
    properties(Constant, Access = ?sphero)
        Uint8Max = double(intmax('uint8')); % Max value that can be stored with uint8 data type
        SpheroDeviceNameBeg = 'Sphero'; % Beginning of Bluetooth name of Sphero device
        MaxSensorSampleRate = 400; % Maximum sample rate for sensor polling
        ResponseError = NaN; % Value used to indicate error in response from Sphero 
        ResponseInitialValue = Inf; % Initialization value for the response, before actual response is received
        ResponseEmpty = []; % Value used to indicate successful 'simple' response received from Sphero
    end
    
    properties(SetObservable)%, Access = {?BluetoothApi, ?sphero})
        PowerNotification % Asynchronous response for Power Notification
        SensorData % Asynchronous response for Sensor Polling
        PreSleepWarning % Asynchronous warning message before going to sleep due to inactivity
        CollisionDetected % Collision detected by Sphero
        GyroAxisLimitExceed % Asynchronous message for the limit of Gyro being exceeded
        ErrorSynchronous % Error caught when receiving synchronous message
        ErrorAsynchronous % Error caught when receiving asynchronous message
    end
  
    properties (Access = ?sphero)
        %Sequencelist Structure containing the sequence number, action, response
        % This is used to keep track of the seqeuence numbers for the 
        % commands which expect a response, as the response mentions the
        % sequence number to which the response pertains to. This is also
        % used to return the response value to the user, when the
        % ReadResponse method is used
        SequenceList
        
        Rev = '1_50'; % Revision number of Sphero API
        
        DeviceName % Bluetooth name of Sphero
        Sequence = uint8(1); % Sequence number for next message
        Handshake = 0; % Toggle handshaking between machine and Sphero
        ApiInfo; % Constants and other parameters for communication API
        Bt; % Bluetooth object for communication
        Response; % Received response
        BytesToRead  =  Inf; % Number of bytes to be read for current message
        Sensors; % Sensors being polled 
        SamplesPerPacket; % Number of samples being polled per packet
        
        %SensorDataPropertySet Whether SensorData property has been set or not
        % Used in the readSensor method of sphero class, because the 
        % callback to SensorData listener cannot be used for 'readSensor' method
        SensorDataPropertySet = 0; 
        
        RejectSensorDataResponsePacket = 1; % Whether the response from Sphero for the Sensor data has to be rejected. 
        % This is set when the sensor polling command is being sent, 
        % such that any response received between the time the command is 
        % sent and the properties of the class are changed are rejected
    end
    
    methods(Access = private, Static = true)
        function cmd = cmdToByte(cmdIn)
        %CMDTOBYTE Convert multiple byte data to array of uint8
        %
        %   CMD = CMDTOBYTE(H, CMDIN) converts CMDIN to an array of uint8
        %   data. It checks whether the machine is big endian or little
        %   endian, and arranges the uint8 data based on that
            
             [~,~,endian] = computer;
               
             if strcmp(endian, 'L')
                   cmd = typecast(swapbytes(cmdIn), 'uint8');
             else
                   cmd = typecast(cmdIn, 'uint8');
             end
        end
        
        function cmd = cmdFromByte(bytedata, varargin)
        %CMDFROMBYTE Convert multi-byte data to specified format (default = uint16) 
        %
        %   CMDTOBYTE(H, BYTEDATA) converts the data represented by the 
        %   BYTEDATA vector (containing Most Significant Bit and Least 
        %   Significant Bit) to an uint16 variable. 
        %   It checks whether the machine is big endian or little
        %   endian, and arranges the data based on that
        %
        %   CMDTOBYTE(H, BYTEDATA, DATATYPE) converts the BYTEDATA to 
        %   the desired DATATYPE
            if nargin>1
                    type = varargin{1};
            else
                type = 'uint16';
            end

            [~,~,endian] = computer;

            if strcmp(endian, 'L')
                   cmd = swapbytes(typecast(bytedata, type));
            else
                   cmd = typecast(bytedata, type);
            end
        end
               
    end
    
    %% Private Methods
    methods(Access = private)
        function devicename = selectDevice(obj)
        %SELECTDEVICE Search for paired Sphero devices and prompt user to select one for connection
        %
        %   DEVICENAME = SELECTDEVICE(OBJ) searches for the paired Sphero
        %   devices, prompts the user to select one and to confirm the
        %   selection
                spherodevices = obj.findDevices;
            
                if isempty(spherodevices)
                    throwAsCaller(MException('Sphero:Api:DeviceNotAvailable', 'No Sphero device available. Please make sure your Sphero device is switched on and is in vicinity'));
                else
                    choose = 'Choose one of the available Sphero devices: \n '; 
                    for idx=1:length(spherodevices)
                        choose = [choose num2str(idx) '. ' spherodevices{idx} '\n']; %#ok<AGROW>
                    end

                    response = 'n';

                    while(~strcmp(response, 'y'))
                        chosen = input(sprintf(choose));
                        if chosen<=length(spherodevices)
                           recheck = ['Are you sure you would like to connect to ' spherodevices{chosen} ' [y/n] : '];
                            response = input(recheck, 's');
                        else
                            throwAsCaller(MException('Sphero:Api:SelectValidDevice','Please select one of the available devices'));
                        end
                    end

                    devicename = spherodevices{chosen};
                end
        end
        
        function chk = computeCheckSum(obj, cmd)
        %COMPUTECHECKSUM Compute the checksum for last bit of the message being sent
            chk = bitcmp(mod(sum(cmd(obj.ApiInfo.SpheroResponse.mrsp:end)), obj.Uint8Max+1), 'uint8');
        end
        
        function [did, cid, dlen] = obtainId(obj, action, data)
        %OBTAINID Get the Device ID, Command ID and Data Length of the action to be performed
        %
        %   [DID, CID, DLEN] = OBTAINID(OBJ, ACTION, DATA) returns the
        %   Device ID, Command ID and the length of Data that should be
        %   sent to Sphero for the ACTION that should be performed. These
        %   IDs are obtained from the information contained in the ApiInfo
        %   property
            err = MException('Sphero:Api:InvalidParameter', 'Please enter a valid command');

            switch action
                case 'ping'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdPing; dlen = obj.ApiInfo.CmdPingDlen;
                case 'version'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdVersion; dlen = obj.ApiInfo.CmdVersionDlen;
                case 'setbtname'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdSetBtName; dlen = uint8(length(data)+1);
                case 'getbtname'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdGetBtName; dlen = obj.ApiInfo.CmdGetBtNameDlen;
                case 'setautoreconnect'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdSetAutoReconnect; dlen = obj.ApiInfo.CmdSetAutoReconnectDlen;
                case 'getautoreconnect'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdGetAutoReconnect; dlen = obj.ApiInfo.CmdGetAutoReconnectDlen;
                case 'getpwrstate'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdGetPwrState; dlen = obj.ApiInfo.CmdGetPwrStateDlen;
                case 'setpwrnotify'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdSetPwrNotify; dlen = obj.ApiInfo.CmdSetPwrNotifyDlen;
                case 'sleep'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdSleep; dlen = obj.ApiInfo.CmdSleepDlen;
                case 'getpowertrips'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.GetPowerTrips; dlen = obj.ApiInfo.GetPowerTripsDlen;
                case 'setpowertrips'
                    did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.SetPowerTrips; dlen = obj.ApiInfo.SetPowerTripsDlen;
                case 'setinactivetimer'
                     did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.SetInactiveTimer; dlen = obj.ApiInfo.SetInactiveTimerDlen;
                case 'gotobl'
                     did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.GotoBl; dlen = obj.ApiInfo.GotoBlDlen;
                case 'runl2diags'
                     did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdRunL2Diags; dlen = obj.ApiInfo.CmdRunL2DiagsDlen;
                case 'clearcounters'
                     did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdClearCounters; dlen = obj.ApiInfo.CmdClearCountersDlen;
                case 'assigntime'
                     did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.CmdAssignTime; dlen = obj.ApiInfo.CmdAssignTimeDlen;
                case 'polltimes'
                     did = obj.ApiInfo.DidCore; cid = obj.ApiInfo.cmdPollTimes; dlen = obj.ApiInfo.cmdPollTimesDlen;
                case 'setcal'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetCal; dlen = obj.ApiInfo.CmdSetCalDlen;
                case 'setstabiliz'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetStabiliz; dlen = obj.ApiInfo.CmdSetStabilizDlen;
                case 'setrotationrate'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetRotationRate; dlen = obj.ApiInfo.CmdSetRotationRateDlen;
                case 'getchassisid'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdGetChassisId; dlen = obj.ApiInfo.CmdGetChassisIdDlen;
                case 'selflevel'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSelfLevel; dlen = obj.ApiInfo.CmdSelfLevelDlen;
                case 'setdatastreaming'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetDataStreaming; dlen = obj.ApiInfo.CmdSetDataStreamingDlen;
                case 'setcollisiondet'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetCollisionDet; dlen = obj.ApiInfo.CmdSetCollisionDetDlen;
                case 'locator'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdLocator; dlen = obj.ApiInfo.CmdLocatorDlen;
                 case 'setaccelero'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetAccelero; dlen = obj.ApiInfo.CmdSetAcceleroDlen;
                case 'readlocator'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdReadLocator; dlen = obj.ApiInfo.CmdReadLocatorDlen;
                case 'setrgbled'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetRgbLed; dlen = obj.ApiInfo.CmdSetRgbLedDlen;
                case 'setbackled'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetBackLed; dlen = obj.ApiInfo.CmdSetBackLedDlen;
                case 'getrgbled'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdGetRgbLed; dlen = obj.ApiInfo.CmdGetRgbLedDlen;
                case 'roll'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdRoll; dlen = obj.ApiInfo.CmdRollDlen;
                case 'boost'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdBoost; dlen = obj.ApiInfo.CmdBoostDlen;
                case 'setrawmotors'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetRawMotors; dlen = obj.ApiInfo.CmdSetRawMotorsDlen;
                case 'setmotionto'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetMotionTo; dlen = obj.ApiInfo.CmdSetMotionToDlen;
                case 'setoptionsflag'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetOptionsFlag; dlen = obj.ApiInfo.CmdSetOptionsFlagDlen;
                case 'getoptionsflag'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdGetOptionsFlag ; dlen = obj.ApiInfo.CmdGetOptionsFlagDlen;
                case 'setdevicemode'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdSetDeviceMode; dlen = obj.ApiInfo.CmdSetDeviceModeDlen;
                case 'getdevicemode'
                    did = obj.ApiInfo.DidSphero; cid = obj.ApiInfo.CmdGetDeviceMode; dlen = obj.ApiInfo.CmdGetDeviceModeDlen;
                
                otherwise
                    throw(err);
            end
        end
        
        function validAction = validateAction(~,action)
        %VALIDATEACTION Check whether indicated action string is a valid string for the action that can be performed by Sphero
        %
        %   VALIDACTION = VALIDATEACTION(OBJ, ACTION) checks whether ACTION
        %   is a valid string for the actions that can be performed by
        %   Sphero
            validActions = {'ping', 'version', 'controluarttx', 'setbtname',...
                'getbtname', 'setautoreconnect', 'getautoreconnect', ...
                'getpwrstate', 'setpwrnotify', 'sleep', 'getpowertrips', ...
                'setpowertrips', 'setinactivetimer', 'gotobl', ...
                'runl1diags', 'runl2diags', 'clearcounters', 'assigntime', ...
                'polltimes', ...
                'beginreflash', 'hereispage', 'leavebootloader', ...
                'ispageblank', 'eraseuserconfig', ...
                'setcal', 'setstabiliz', 'setrotationrate', ...
                'setcreationdate', 'reenabledemo', 'getchassisid', ...
                'setchassisid', 'selflevel', 'setdatastreaming', ...
                'setcollisiondet', 'locator', 'setaccelero', ...
                'readlocator', 'setrgbled', 'getrgbled', ...
                'setbackled', 'roll', 'boost', 'move', 'setrawmotors', ...
                'setmotionto', 'setoptionsflag', 'getoptionsflag', ...
                'settempoptionsflag', 'gettempoptionsflag', ...
                'getconfigblk', 'setssbparams', 'setdevicemode', ...
                'getssb', 'getdevicemode', 'setssb', 'ssbrefill', 'ssbbuy', ...
                'ssbuseconsumeable', 'ssbgrantcores', 'ssbaddxp', ...
                'ssblevelupattr', 'getpwseed', 'ssbenableasync', ...
                'runmacro', 'savetempmacro', 'savemacro', ...
                'initmacroexecutive', 'abortmacro', 'macrostatus', ...
                'setmacroparam', 'appendtempmacrochunk', ...
                'eraseorbbas', 'appendfrag', 'execorbbas', 'answerinput',...
                'committoflash'};
            
            validAction = validatestring(action, validActions);             
        end
        
        function data = formatCommandData(obj, action, varargin)
        %FORMATCOMMANDDATA Mold the data to apppropriate format, that can be sent to Sphero for current message
        %
        %   DATA = FORMATCOMMANDDATA(OBJ, ACTION, DATAVAL{1}, DATAVAL{2},..., DATAVAL{N})
        %   returns the modified DATA that can be sent to Sphero as an appropriate
        %   message for the ACTION that is to be performed
            switch action
                case 'controluarttx'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setbtname'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setpwrnotify'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                    
                case 'sleep'
                    origdata = cell2mat(varargin);
                    data(1:2) = obj.cmdToByte(uint16(origdata(1)));
                    data(3) = uint8(origdata(2));
                     data(4:5) = obj.cmdToByte(uint16(origdata(3)));
                case 'setpowertrips'
                    origdata = cell2mat(varargin);
                    data(1:2) = obj.cmdToByte(uint16(origdata(1)));
                    data(3:4) = obj.cmdToByte(uint16(origdata(2)));
                case 'setinactivetimer'
                    origdata = cell2mat(varargin);
                    data(1:2) = obj.cmdToByte(uint16(origdata(1)));
                case 'setrgbled'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'roll'
                    origdata = cell2mat(varargin);
                    data(1) = uint8(origdata(1));
                    data(2:3) = obj.cmdToByte(uint16(origdata(2)));
                    data(4) = uint8(origdata(3));
                case 'setcal'
                    origdata = cell2mat(varargin);
                    data = obj.cmdToByte(uint16(origdata));
                case 'setstabiliz'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setrotationrate'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setaccelero'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setbackled'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setdatastreaming'
                    data(1:2) = obj.cmdToByte(uint16(varargin{1}));
                    data(3:4) = obj.cmdToByte(uint16(varargin{2}));
                    data(5:8) = obj.cmdToByte(uint32(varargin{3}));
                    data(9) = obj.cmdToByte(uint8(varargin{4}));
                    data(10:13) = obj.cmdToByte(uint32(varargin{5}));
                case 'setcollisiondet'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'locator'
                    origdata = cell2mat(varargin);
                    data(1) = uint8(origdata(1));
                    data(2:3) = obj.cmdToByte(int16(origdata(2)));
                    data(4:5) = obj.cmdToByte(int16(origdata(3)));
                    data(6:7) = obj.cmdToByte(int16(origdata(3)));
                case 'boost'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setrawmotors'
                    origdata = cell2mat(varargin);
                    data = uint8(origdata);
                case 'setmotionto'
                    origdata = cell2mat(varargin);
                    data(1:2) = obj.cmdToByte(uint16(origdata(1)));
                case 'setoptionsflag'
                    origdata = cell2mat(varargin);
                    data(4) = uint8(bin2dec(origdata)); %Send command in Big Endian format
                    data(1:3) = uint8([0 0 0]);
                otherwise
                    data = [];
            end
        end
            
        function valid = checkValidityResponse(obj, sop1, sop2, msrp, code, dlen, data, chk, response)
        %CHECKVALIDITYRESPONSE Check whether received response is a valid message or not
        %
        %   VALID = CHECKVALIDITYRESPONSE(OBJ, SOP1, SOP2, MSRP, CODE,
        %   DLEN, DATA, CHK, RESPONSE) checks whether the received RESPONSE
        %   is valid or not. It checks the 'Start of packet' bytes (SOP1,
        %   SOP2); Message Response Code (MSRP) for synchronous messages,
        %   or ID code for asynchronous messages (CODE); and whether the Data
        %   Length byte (DLEN) matches the actual length of the DATA
        
           expectedChk = computeCheckSum(obj, response(1:end-1));

           if sop1~=obj.ApiInfo.expectedSop1||...
                   (sop2~=obj.ApiInfo.sop2Acknowledgement && sop2~=obj.ApiInfo.sop2Asynchronous)||...
                   dlen~=length(data)+1||chk~=expectedChk
                valid=0;
           elseif sop2 == obj.ApiInfo.sop2Asynchronous
               if code>length(obj.ApiInfo.RspAsync)
                   valid = 0;
               else
                   valid=1;
               end
           else
               valid = checkMsrp(obj, msrp);
           end
        end
        
        function valid = checkMsrp(obj, msrp)
        %CHECKMSRP Check whether the Message Response Code (MSPR) is valid or not
            
            valid = 0; % Initialize to 0, to indicate invalid message
            switch msrp
                case obj.ApiInfo.RspCodeOk
                    valid = 1;
                
                case obj.ApiInfo.RspCodeEgen
                    err = MException('Sphero:Api:InvalidCommand:GeneralError',...
                        'Unrecognized Message Reponse received. Please check API definition');
                case obj.ApiInfo.RspCodeEchksum
                    err = MException('Sphero:Api:InvalidCommand:ChecksumFailure',...
                        'Command with incorrect checksum value sent. Please check API definition');
                case obj.ApiInfo.RspCodeEfrag
                    err = MException('Sphero:Api:InvalidCommand:CommandFragment',...
                        'Complete command not received. Please check API definition');
                case obj.ApiInfo.RspCodeEbadCmd
                    err = MException('Sphero:Api:InvalidCommand:CommandID',...
                        'Unknown command ID received. Please check API definition');
                case obj.ApiInfo.RspCodeEunsupp
                    err = MException('Sphero:Api:InvalidCommand:CommandUnsupported',...
                        'Command currently unsupported. Please check API definition for current revision');
                case obj.ApiInfo.RspCodeEbadMsg
                    err = MException('Sphero:Api:InvalidCommand:BadMessage',...
                        'Incorrect message format received. Please check API definition');
                case obj.ApiInfo.RspCodeEparam
                    err = MException('Sphero:Api:InvalidCommand:InvalidParameterValues',...
                        'Invalid Parameter Values. Please check API definition');
                case obj.ApiInfo.RspCodeEexec
                    err = MException('Sphero:Api:InvalidCommand:FailedExecution',...
                        'Failed to execute command. Please retry');
                case obj.ApiInfo.RspCodeEbadDid
                     err = MException('Sphero:Api:InvalidCommand:UnknownDeviceID',...
                        'Invalid Device ID. Please check API definition');
                case obj.ApiInfo.RspCodeMemBusy
                     err = MException('Sphero:Api:InvalidCommand:MemBusy',...
                        'RAM is busy. Please retry');
                case obj.ApiInfo.RspCodeBadPassword
                     err = MException('Sphero:Api:InvalidCommand:IncorrectPassword',...
                        'Incorrect Password supplied');
                case obj.ApiInfo.RspCodePowerNogood
                     err = MException('Sphero:Api:InvalidCommand:LowVoltage',...
                        'Voltage too low for reflash operation. Recharge Sphero and try again.');
                case obj.ApiInfo.RspCodePageIllegal
                      err = MException('Sphero:Api:InvalidCommand:IllegalPageNumber',...
                        'Illegal page number provided.');
                case obj.ApiInfo.RspCodeFlashFail
                      err = MException('Sphero:Api:InvalidCommand:FlashFail',...
                        'Page did not reprogram correctly.');
                case obj.ApiInfo.RspCodeMaCorrupt
                     err = MException('Sphero:Api:InvalidCommand:MainApplicationCorrupt',...
                        'Main Application corrupted');
                case obj.ApiInfo.RspCodeMsgTimeout
                      err = MException('Sphero:Api:InvalidCommand:MessageTimeout',...
                        'Message timed out. Please try again.');
                    
                otherwise
                    err = MException('Sphero:Api:InvalidCommand:GeneralError','Unrecognized Message Reponse received. Please check API definition');
                 
            end
            
            if exist('err', 'var')
                obj.ErrorSynchronous = err;
            end
        end
        
        function [result, out] = decodeResponseData(obj, data, action)
        %DECODERESPONSEDATA Decode the data that is received as part of the
        %Response from Sphero
        %
        %   [RESULT, OUT] = DECODERESPONSEDATA(OBJ, DATA, ACTION) decodes
        %   the data based on the action that the Sphero responded to. It
        %   returns the result of the decoded response in OUT, and the
        %   RESULT as 1 if the data is a part of a valid response
            
           switch action
                case 'version'
                    if length(data)~= obj.ApiInfo.RspVersionDlen-1
                        result = 0;
                        out = [];
                    else
                        result = 1;
                        
                        recv = data(1); mdl = data(2); hw = data(3); 
                        msaver = data(4); msarev = data(5); 
                        bl = packedNibble2Dec(obj, data(6));
                        bas = packedNibble2Dec(obj, data(7));
                        macro = packedNibble2Dec(obj, data(8));
%                         apimaj = data(9); apimin = data(10);
                        
                        version.RecordVersion = recv;
                        version.ModelNumber = mdl;
                        version.HardwareVersion = hw;
                        version.MainSpheroApplicationVersion = msaver;
                        version.MainSpheroApplicationRev = msarev;
                        version.BootloaderVersion = bl;
                        version.OrbBasicVersion = bas;
                        version.MacroExecutiveVersion = macro;
%                         version.ApiMajorRev = apimaj;
%                         version.ApiMinorRev = apimin;
%                         
                        out = version;
                    end
                    
               case 'getbtname'
                   if length(data)~= obj.ApiInfo.RspGetBtNameDlen-1
                         result = 0;
                        out = [];
                   else
                       result = 1;
                       
                      name = char(data(1:16));
                      address = char(data(17:28));
                      colors = char(data(30:32));
                      
                      out = strvcat(name, address, colors); %#ok<DSTRVCT>
                   end
               case 'getautoreconnect' % Not being used in hwinfo now
                   if length(data)~= obj.ApiInfo.RspGetAutoReconnectDlen-1
                       result = 0;
                        out = [];
                   else
                       result = 1;
                       out = data;
                   end
                   
               case 'getpwrstate'
                   if length(data)~=obj.ApiInfo.RspGetPwrStateDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                       
                       recver       = data(1);
                       powerstate   = data(2);
                       voltage      = obj.cmdFromByte(data(3:4), 'uint16');
                       charges      = obj.cmdFromByte(data(5:6), 'uint16');
                       timeawake    = obj.cmdFromByte(data(7:8), 'uint16');
                       
                       out = {recver powerstate voltage charges timeawake};
                       
                   end
               case 'getpowertrips'
                   if length(data)~=obj.ApiInfo.RspGetPowerTripsDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                       out(1) = obj.cmdFromByte(data(1:2), 'uint16');
                       out(2) = obj.cmdFromByte(data(3:4), 'uint16');
                   end
                   
               case 'runl2diags'
                   if length(data)~=obj.ApiInfo.RspRunL2DiagsDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                                              
                       out{1} = obj.cmdFromByte(data(1:2), 'uint16');
                       out{2} = obj.cmdFromByte(data(4:7), 'uint32');
                       out{3} = obj.cmdFromByte(data(8:11), 'uint32');
                       out{4} = obj.cmdFromByte(data(12:15), 'uint32');
                       out{5} = obj.cmdFromByte(data(16:19), 'uint32');
                       out{6} = obj.cmdFromByte(data(20:23), 'uint32');
                       out{7} = obj.cmdFromByte(data(24:27), 'uint32');
                       out{8} = obj.cmdFromByte(data(28:31), 'uint32');
                       out{9} = obj.cmdFromByte(data(32:35), 'uint32');
                       out{12} = obj.cmdFromByte(data(71:72), 'uint16');
                       out{13} = obj.cmdFromByte(data(73:74), 'uint16');
                       out{14} = obj.cmdFromByte(data(75:78), 'uint32');
                       out{15} = obj.cmdFromByte(data(79:82), 'uint32');
                       out{16} = obj.cmdFromByte(data(83:84), 'uint16');
                       out{17} = obj.cmdFromByte(data(85:88), 'uint32');
                       
                   end
                   
               case 'getrgbled'
                    if length(data)~= obj.ApiInfo.RspGetRgbLedDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                       out = data;
                       
                    end
             
               case 'readlocator'
                   if length(data)~= obj.ApiInfo.RspReadLocatorDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                       xpos = obj.cmdFromByte(data(1:2), 'int16');
                       ypos = obj.cmdFromByte(data(3:4), 'int16');
                       xvel = obj.cmdFromByte(data(5:6), 'int16');
                       yvel = obj.cmdFromByte(data(7:8), 'int16');
                       sog = obj.cmdFromByte(data(9:10), 'uint16');
                       
                       out = {xpos ypos xvel yvel sog};
                   end
                   
               case 'getdevicemode'
                  if length(data)~= obj.ApiInfo.RspGetDeviceModeDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                       out = data;
                  end
                  
               case 'power'
                   out = [];
                   if length(data)~=obj.ApiInfo.RspPowerDlen-1
                       result = 0;
                   else
                       result = 1;
                       switch data
                            case 1
                                obj.PowerNotification = 'Charging';
                            case 2
                                obj.PowerNotification = 'Battery OK';
                            case 3
                                obj.PowerNotification = 'Battery Low';
                            case 4
                                obj.PowerNotification = 'Battery Critical';
                           otherwise
                                result = 0;
                        end
                   end
                   
               case 'presleep'
                   out= [];
                   if length(data)~=obj.ApiInfo.RspPreSleepDlen-1
                       result = 0;
                   else
                       obj.PreSleepWarning = 1;
                       result = 1;
                   end
                   
               case 'collision'
                   out= [];
                   if length(data)~=obj.ApiInfo.RspCollisionDlen-1
                       result = 0;
                   else
                       x = obj.cmdFromByte(data(1:2), 'int16'); %#ok<NASGU>
                       y = obj.cmdFromByte(data(3:4), 'int16'); %#ok<NASGU>
                       z = obj.cmdFromByte(data(5:6), 'int16'); %#ok<NASGU>
                       axis = uint8(data(7));
                       xMag = obj.cmdFromByte(data(8:9), 'int16'); %#ok<NASGU>
                       yMag = obj.cmdFromByte(data(10:11), 'int16'); %#ok<NASGU>
                       speed = uint8(data(12)); %#ok<NASGU>
                       timestamp = obj.cmdFromByte(data(13:16), 'uint32'); %#ok<NASGU>
                       
                       if bitget(axis, 1)
                           obj.CollisionDetected = 'x';
                       elseif bitget(axis, 2)
                           obj.CollisionDetected = 'y';
                       end
                       result = 1;
                   end
                   
               case 'gyroaxislimit'
                   out = [];
                   if length(data)~=obj.ApiInfo.RspGyroAxisLimitDlen-1
                       result = 0;
                   else
                       result = 1;
                       obj.GyroAxisLimitExceed = 1;
                   end
                   
                case 'sensor'
                    out = [];
                    result=1;
                    
                    if obj.RejectSensorDataResponsePacket
                        %Reject the received message and move on
                        return;
                    end
                    
                    % Check if the number of elements in the received response
                    % are equal to the samples per packet per sensor * number of sensors
                    if length(data)== obj.SamplesPerPacket * length(obj.Sensors)*2;
                      data = reshape(data, length(obj.Sensors)*2, obj.SamplesPerPacket)';  
                    else
                      result=0;
                      return
                    end

                    % Initialilze the 'sensordata' variable, which is a
                    % structure containing the present data received from the
                    % sensors.
                    for i=1:length(obj.Sensors)
                      sensordata.(obj.Sensors{i}) = [];
                    end

                    for i=1:size(data,1)
                      for j=1:size(data,2)/2
                            sensordata.(obj.Sensors{j})(end+1) =  obj.cmdFromByte(data(i,2*j-1:2*j), 'int16');
                      end
                    end

                    obj.SensorData = sensordata;
                    obj.SensorDataPropertySet = 1;

               case 'getoptionsflag'
                   if length(data)~= obj.ApiInfo.RspGetTempOptionsFlagDlen-1
                       result = 0;
                       out = [];
                   else
                       result = 1;
                       out = data;
                   end
                   
               %%% Following cases have not been complately considered yet. 
               %%% Just putting placeholders so that doesn't error out
               case 'level1diag'
                   result = 1;
                   out = [];
               case 'configblk'
                   result = 1;
                   out = [];
               case 'macro'
                   result = 1;
                   out = [];
               case 'orbbasicprint'
                   result = 1;
                   out = [];
               case 'orbbasicerrorascii'
                   result = 1;
                   out = [];
               case 'orbbasicerrorbinary'
                   result = 1;
                   out = [];
               case 'selflevel'
                  result = 1;
                   out = []; 
               case 'ssb'
                  result = 1;
                   out = []; 
               case 'levelup'
                  result = 1;
                   out = []; 
               case 'shielddamage'
                   result = 1;
                   out = [];
               case 'xpupdate'
                  result = 1;
                   out = []; 
               case 'boostupdate'
                   result = 1;
                   out = [];

               otherwise
                    % Check if valid 'Simple Response' received for other
                    % actions
                     if length(data)~= obj.ApiInfo.RspSimpleDlen-1
                          result = 0;
                          out = obj.ResponseError;
                     else
                         result = 1;
                         out = [];
                     end
            end
        end
      
        function action = decodeAction(obj, ack, idx)
        %DECODEACTION Check which 'action' does the response correspond to
           switch ack
               case 1 % Synchronous response
                   
                   if ~isempty(idx)
                       action = obj.SequenceList.action{idx(1)};
                   else
                       action = 'notfound';
                   end
                   
               case 0
                   if idx>0 && idx<=length(obj.ApiInfo.RspAsync)
                       action = obj.ApiInfo.RspAsync{idx};
                   else
                       action = 'notfound';
                   end
               otherwise
                   action = 'notfound';
           end
        end
        
        function dec = packedNibble2Dec(~, in)
        %PACKEDNIBBLE2DEC Convert Packed Nibble format to Decimal
        
            bin = dec2bin(in, 8);
                        
            dec = bin2dec(bin(1:4));
            
            nibble2 = bin2dec(bin(5:8));
            
            if nibble2<10
                dec = dec+nibble2/10;
            else
                dec = dec+nibble2/100;
            end
            
        end
        
        function  saveSeq(obj, respond, seq, action)
        %SAVESEQ Save the sequence number in the SequenceList
        %
        %   SAVESEQ(OBJ, RESPOND, SEQ, ACTION) saves the sequence number to
        %   the SequenceList if RESPOND is true. It saves the sequence
        %   number (SEQ), action that is going to be performed (ACTION) and
        %   the Initial value of the response.
            if respond
                idx = indexOfResponseAction(obj, action);
                
                if isempty(idx)
                    obj.SequenceList.seq(end+1) = seq;
                    obj.SequenceList.action{end+1} = action;
                    obj.SequenceList.response{end+1} = obj.ResponseInitialValue;
                else
                    obj.SequenceList.seq(idx) = seq;
                    obj.SequenceList.response{idx} = obj.ResponseInitialValue;
                end
            end
        end
                    
        function assembleResponse(obj)
        %ASSEMBLERESPONSE Assemble the response that is received from the Sphero
        %
        %   ASSEMBLERESPONSE(OBJ) reads the bytes from the Bluetooth
        %   module and assembles the response into one complete message
        %   that is then processed. If an error occurs on assembling a 
        %   response, it is saved to the ErrorSynchronous or 
        %   ErrorAsynchronous property
            
           processing = 1;
           responseEnd = length(obj.Response);
                
           try
                while processing
                    sop1 = obj.Response(obj.ApiInfo.SpheroResponse.sop1);
                    sop2 = obj.Response(obj.ApiInfo.SpheroResponse.sop2);
            
                   if sop1~=obj.ApiInfo.expectedSop1 ||...
                   (sop2~=obj.ApiInfo.sop2Acknowledgement && sop2~=obj.ApiInfo.sop2Asynchronous)
                       % If the beginning of response does not match the expected
                       % signature, then disregard the first element of the
                       % response (as the Sphero might have sent an incorrect
                       % response)
               
                        obj.Response(1) = [];
                        
                        if length(obj.Response)<=0
                            processing=0;
                        end
                        
                        continue
                   end
                   
                    dlen = obj.Response(obj.ApiInfo.SpheroResponse.dlen);
                    responseEnd = obj.ApiInfo.SpheroResponse.dlen+dlen;
                    
                    availableDataBytes = length(obj.Response)-obj.ApiInfo.SpheroResponse.dlen;
                
                    obj.BytesToRead = dlen-availableDataBytes;
                
                    if obj.BytesToRead<=0
                        response = obj.Response(1:responseEnd);
                        [valid, ack, data, code] = decodeResponse(obj, response);
                        processResponse(obj, valid, ack, data, code);
                        obj.Response(1:responseEnd) = [];
                        
                        if length(obj.Response)<obj.ApiInfo.SpheroResponse.dlen
                            processing = 0;
                           obj.BytesToRead =  Inf;
                        end
                    else
                        processing = 0;
                    end
                end
          catch exception
              flushinput(obj.Bt); 
              obj.Response(1:responseEnd) = [];
              
              obj.disconnect();
              
              if exist('ack', 'var') && ack
                  obj.ErrorSynchronous = exception;
              else
                  obj.ErrorAsynchronous = exception;
              end
              
%               The following automatic reconnection capability was commented 
%               out after solving the issue of unrecognized bytes and
%               realizing that it is not needed anymore and indeed this 
%               sometimes leads to an ininite loop
%
%               obj.connect(); %Reconnect to the current Sphero device after error is encountered
%               warning('Reconnecting with Sphero');
%               lastwarn(''); %Added so that instrcb.m does not display the warning again

          end
        end
        
        function readBytes(obj, eventSrc, ~)
        %READBYTES Listener callback to read appropriate number of bytes from Bluetooth
        %
        % If on reading the additional number of bytes, the length of
        % the Reponse is more than the number of bytes till 'dlen'
        % byte, then assemble the Response.
        % Or if the length of response at present is more than the num
        % of bytes till 'dlen', then check if the additional number of
        % bytes that can be read will be more than the number of bytes
        % that should be read to complete the message
            
            lenRsp = length(obj.Response);
            numDlen = obj.ApiInfo.SpheroResponse.dlen;
            
            if (lenRsp<numDlen && lenRsp+eventSrc.BytesAvailable>=numDlen) || ...
                (lenRsp>=numDlen && eventSrc.BytesAvailable>=obj.BytesToRead)
                
                bytesRead = eventSrc.BytesAvailable;
                
                obj.Response(end+1:end+bytesRead) = fread(eventSrc, bytesRead);

                assembleResponse(obj);
            end
        end
        
        function processResponse(obj, valid, ack, data, code)
        %PROCESSRESPONSE Process the response that is received and save the result in an appropriate property 
        %   The result is saved in the SequenceList property for synchronous
        %   messages, or the corresponding property for asynchronous messages 
            err = MException('Sphero:Api:InvalidResponse',...
               'Received response is not valid');

                if ack==1
                    idx = indexOfResponseSequence(obj, code);
                else
                    idx = code;
                end

                action = decodeAction(obj, ack, idx);

                if (~valid || strcmp(action , 'notfound'))
                    if ack && ~isempty(idx)
                        obj.SequenceList.response{idx(1)} = obj.ResponseError;
                        return
                    else
                        throw(err);
                    end
                end

                [result2, out] = decodeResponseData(obj, data, action);

                if result2 && ack
                    obj.SequenceList.response{idx(1)} = out;
                elseif ack
                    obj.SequenceList.response{idx(1)} = obj.ResponseError;
                elseif ~result2 %When response is asynchronous & result is 0
                    throw(err)
                end
        end
        
        function throwAsyncError(obj, ~, ~)
        %THROWASYNCERROR Callback to Listener for throwing an error when it is encountered when reading Asynchronous response
            if ~isempty(obj.ErrorAsynchronous)
                warning(['Error occured when reading Asynchronous message: ' obj.ErrorAsynchronous.message , ...
                    '. Disconnecting from Sphero due to the error. Please reconnect with the Sphero and try again.']);
                lastwarn(''); %Added so that instrcb.m does not display the warning again
                obj.ErrorAsynchronous = [];
            end
        end
        
         function idx = indexOfResponseSequence(obj, seq)
         %INDEXOFRESPONSESEQUENCE returns the index number of the sequence number in the SequenceList
            idx = find(obj.SequenceList.seq==seq); %Index of the sequence 
            %number which was achnowledged in the response
         end
        
         function idx = indexOfResponseAction(obj, action)
         %INDEXOFRESPONSEACTION returns the index number for the indicated action, if it is present in the SequenceList
             idx = find(cellfun(@(x) strcmp(x, action), obj.SequenceList.action));
         end
         
         function incrSequence(obj)
         %INCRSEQUENCE increments the sequence number
                obj.Sequence=mod(obj.Sequence, obj.Uint8Max)+1;
                
                % NOTE: To be considered in future. Break this loop if not a
                % single sequence number is available for the next command
                while any(obj.SequenceList.seq==obj.Sequence)
                    obj.Sequence=mod(obj.Sequence, obj.Uint8Max)+1;
                end
         end
         
    end
    
    methods (Access = public, Hidden)
        function delete(obj)
        %DELETE Delete the BluetoothApi object
        
            disconnect(obj);
            
            % Delete the Bluetooth object
            if ~isempty(obj.Bt) && isvalid(obj.Bt)
                delete(obj.Bt);
            end
        end
    end
    
    %% Public Methods
    methods
        function obj = BluetoothApi
        %BLUETOOTHAPI API for sending commands to Sphero over Bluetooth
        %
        %   OBJ = BLUETOOTHAPI creates an object for the communication API for 
        %   communicating with Sphero over Bluetooth. 
        %   Read the Api information (constants, parameters etc. from the 
        %   associated function, and add listeners for specific properties
            hInfo = sphero.ApiInfo(obj.Rev);
            obj.ApiInfo = hInfo.Constants;
            obj.ApiInfo.SpheroResponse = hInfo.SpheroResponse;
            
            obj.SequenceList.seq = [];
            obj.SequenceList.action = {};
            obj.SequenceList.response = {};
            
            addlistener(obj, 'ErrorAsynchronous',  'PostSet',  @obj.throwAsyncError);  
        end
        
        function [cmd, respond, seq] = createCommand(obj, action, varargin)
        %CREATECOMMAND Assemble the command that can be sent to Sphero for a particular action
        % 
        %   [CMD, RESPOND, SEQ} = CREATECOMMAND(OBJ, ACTION) uses the
        %   default values for creating the command for particular action.
        %   The Command is returned in CMD, and the sequence number used
        %   to send the command is returned in SEQ. RESPOND is 1 if a 
        %   response is expected from the Sphero for the particular
        %   command.
        % 
        %   [CMD, RESPOND, SEQ] = CREATECOMMAND(OBJ, ACTION, SEQNUM,
        %   RESPONDTOCMD, RESET) specifies the following additional parameters:
        %       SEQNUM: Sequence number for the command (default = prev
        %       sequence number+1)
        %       RESPONDTOCMD: Whether the Sphero should respond to the
        %       command or not (default = Based on Handshake property)
        %       RESET: Reset the inactivity timeout after sending the
        %       command (default = 1)
        %   
        %   [CMD, RESPOND, SEQ] = CREATECOMMAND(OBJ, ACTION, SEQNUM,
        %   RESPONDTOCMD, RESET, DATA{1}, DATA{2}, ..., DATA{N}) specifies
        %   the data for the particular command as well.
           
            action = validateAction(obj, action);
                        
            if nargin>2
               seq = varargin{1};
            else
                seq = [];
            end
            
            if nargin>3 && ~isempty(varargin{2})
               respond = varargin{2}; 
            elseif obj.Handshake
               respond = 1;
            else
                respond = 0;
            end
            
            if nargin>4 && ~isempty(varargin{3})
                reset = varargin{3};
            else
                reset = 1;
            end
            
            if nargin>5
                data = formatCommandData(obj, action, varargin{4:end});
            else
                data = [];
            end
            
            % Create the command to be sent
            
            % SOP1 - FFh
            % SOP2 - bit1 is reset timeout, and bit0 is whether send a
            % reply to the command or not
            
            sop1 = obj.ApiInfo.expectedSop1;
            sop2 = bin2dec(['111111' dec2bin(reset) dec2bin(respond)]);
              
            
            [did, cid, dlen] = obtainId(obj,action, data);
            data = uint8(data);
            
            if isempty(seq)
                seq = obj.Sequence;
                obj.incrSequence();
                
            end
            
            if dlen ~= numel(data)+1;
               throwAsCaller(MException('Sphero:Api:IncorrectCommand', ...
                   ['Data being sent through the Client Command Packet is ',...
                   'of incorrect size according to the Bluetooth API']));
            end
            
              cmd = [sop1 sop2 did cid seq dlen data];
          
              chk = obj.computeCheckSum(cmd);
            
              cmd = [cmd chk];
              
              %Save the sequence number in the SequenceList
              saveSeq(obj, respond, seq, action);     
        end
        
        function response = readResponse(obj, responseexpected, seq, responseTimeout)
        %READRESPONSE Read the response from Sphero
        %
        %   RESPONSE = READRESPONSE(OBJ, RESPONSEEXPECTED, SEQ,
        %   RESPONSETIMEOUT) reads the response for SEQ sequence number 
        %   from the SequenceList structure. If timeout occurs when the 
        %   response is not received within RESPONSETIMEOUT seconds, then 
        %   this would error out. If timeout doesnt occur, but the 
        %   received response is invalid, then ResponseError would be
        %   returned
        
            err = MException('Sphero:Api:ResponseTimeout', 'Response Timeout');
            
            if responseexpected
                idx = indexOfResponseSequence(obj, seq);
                
                if isempty(idx)
                    error('Sphero:Api:ResponseNotExpected', 'Response not expected for this command');
                end
                       
                t0 = tic;
                
                try    
                     curResponse = obj.SequenceList.response{idx};
                     while ~isstruct(curResponse) && ~iscell(curResponse) && any(any(isinf(curResponse)))   
                         if ~isempty(obj.ErrorSynchronous)
                            throw(obj.ErrorSynchronous);
                        elseif toc(t0)>responseTimeout
                            throw(err);
                        end

                        idx = indexOfResponseSequence(obj, seq);
                        
                        curResponse = obj.SequenceList.response{idx};
                    end
                
                    if idx(1)<=length(obj.SequenceList.seq)
                        response = obj.SequenceList.response{idx(1)};

                        if ~isempty(obj.ErrorSynchronous)
                            throw(obj.ErrorSynchronous);
                        end
                        
                        %Remove the action from the SequenceList
                        obj.SequenceList.response{idx(1)} = [];
                        obj.SequenceList.action{idx(1)} = [];
                        obj.SequenceList.seq(idx(1)) = [];

                        % remove empty arrays in cell arrays
                        obj.SequenceList.action = obj.SequenceList.action(~cellfun(@isempty, obj.SequenceList.action));
                        obj.SequenceList.response = obj.SequenceList.response(~cellfun(@isempty, obj.SequenceList.response));
                    else
                        response = obj.ResponseError;
                    end
                catch exception

                       idx = indexOfResponseSequence(obj, seq);
                        if ~isempty(idx)
                            %Remove the action from the SequenceList
                            obj.SequenceList.response{idx(1)} = [];
                            obj.SequenceList.action{idx(1)} = [];
                            obj.SequenceList.seq(idx(1)) = [];

                            % remove empty arrays in cell arrays
                            obj.SequenceList.action = obj.SequenceList.action(~cellfun(@isempty, obj.SequenceList.action));
                            obj.SequenceList.response = obj.SequenceList.response(~cellfun(@isempty, obj.SequenceList.response));
                        end

                    obj.ErrorSynchronous = [];
                    rethrow(exception);
                end
                    
            else
                response = obj.ResponseEmpty;
            end
        end
        
        function [valid, ack, data, code] = decodeResponse(obj, response)
        %DECODERESPONSE Decode the response that is read from the Sphero
        %
        %   [VALID, ACK, DATA, CODE] = DECODERESPONSE(OBJ, RESPONSE)
        %   decodes the response, RESPONSE that is received from the
        %   Sphero. The output VALID indicates whether the received
        %   response was valid or not. ACK indicates whether it is an
        %   acknowledgement or synchronous response to a previously received 
        %   command (1), or instead an asynchronous response (0). CODE
        %   indicates the ID Code for asynchronous commands, or the
        %   sequence number of the command to which this is a synchronous
        %   response.

            response = uint8(response);
           
            sop1 = response(obj.ApiInfo.SpheroResponse.sop1);
            sop2 = response(obj.ApiInfo.SpheroResponse.sop2);
            if sop2==obj.ApiInfo.sop2Acknowledgement
                mrsp = response(obj.ApiInfo.SpheroResponse.mrsp);
                code  = response(obj.ApiInfo.SpheroResponse.seq);
                dlen = response(obj.ApiInfo.SpheroResponse.dlen);

                ack = 1;

            elseif sop2==obj.ApiInfo.sop2Asynchronous
                code  = response(obj.ApiInfo.SpheroResponse.idcode);
                dlenmsb = response(obj.ApiInfo.SpheroResponse.dlenmsb);
                dlenlsb = response(obj.ApiInfo.SpheroResponse.dlenlsb);
                dlen = obj.cmdFromByte([dlenmsb, dlenlsb]);

                mrsp = 0;
                ack = 0;
            else
                valid = 0;
                data = [];
                ack = 0;
                code = 0;
                return
            end
                
            data = response(obj.ApiInfo.SpheroResponse.data:end-1);
            chk  = response(end);

            valid = checkValidityResponse(obj, sop1, sop2, mrsp, code, dlen, data, chk, response);
        end
       
        function [responseexpected, seq] = sendCmd(obj, action, varargin)
        %SENDCMD Send a command to the Sphero
        %
        %   [RESPONSEEXPECTED, SEQ} = SENDCMD(OBJ, ACTION) sends a command
        %   to the Sphero for a particular action, ACTION. The command is 
        %   sent over Bluetooth if the Bluetooth connection is open. 
        %
        %   [RESPONSEEXPECTED, SEQ} = SENDCMD(OBJ, ACTION, SEQNUM,
        %   RESPONDTOCMD, RESET) specifies the following additional parameters:
        %       SEQNUM: Sequence number for the command (default = prev
        %       sequence number+1)
        %       RESPONDTOCMD: Whether the Sphero should respond to the
        %       command or not (default = Based on Handshake property)
        %       RESET: Reset the inactivity timeout after sending the
        %       command (default = 1)
        %   
        %   [RESPONSEEXPECTED, SEQ} = SENDCMD(OBJ, ACTION, SEQNUM,
        %   RESPONDTOCMD, RESET, DATA{1}, DATA{2}, ..., DATA{N}) specifies
        %   the data for the particular command as well.
            
            if strcmp(obj.Bt.status, 'open')
                [cmd, responseexpected, seq] = createCommand(obj, action, varargin{:});
                try
                    fwrite(obj.Bt, cmd);
                catch e
                    obj.Bt = []; %Clear the Bluetooth object if an error occurs
                    if (strcmp(e.identifier,'instrument:fwrite:opfailed'))
                        warning('Unable to write to device. The Sphero might already be disconnected')
                    else
                        rethrow(e);
                    end
                end
            else
                err = MException('Sphero:Api:NotConnected', 'Connection with sphero is not active. Please recheck the connection');
                throwAsCaller(err) ;
            end
        end
        
        function spherodevices = findDevices(obj)
        %FINDDEVICES Search for paired Sphero devices
        %
        %   DEVICENAME = FINDDEVICES(OBJ) searches for the paired Sphero
        %   devices
                devices = instrhwinfo('Bluetooth');
                checksphero = strncmp(devices.RemoteNames, obj.SpheroDeviceNameBeg, length(obj.SpheroDeviceNameBeg));
                
                spherodevices = devices.RemoteNames(checksphero);
        end
        
        function connect(obj, varargin)
        %CONNECT Connect to a Sphero device over Bluetooth
        %
        %   CONNECT(OBJ) searches for the paired Sphero devices, asks user
        %   to select one of them to connect to, and connects to it over
        %   Bluetooth. If the connection with a previously connected 
        %   sphero was broken, it connects to the previous device again. 
        %
        %   CONNECT(OBJ, DEVICENAME) connects to the indicated device
        
            try
                channel = 1;

                if (nargin>1 && ~isempty(varargin{1}))
                    if iscell(varargin{1})
                        devicename = varargin{1}{1};
                    else
                        devicename = varargin{1};
                    end
                elseif ~isempty(obj.DeviceName)
                    devicename = obj.DeviceName;
                else
                   devicename = obj.selectDevice;
                end
                
                %If an object of the Bluetooth for the Sphero already
                %exists, then reset the Bluetooth object
                BtObjs      = instrfind;
                for idx=1:length(BtObjs)
                    if strcmp(BtObjs(idx).type, 'bluetooth') && strcmp(BtObjs(idx).Remotename, devicename)
                        fclose(BtObjs(idx));
                        delete(BtObjs(idx));
                    end
                end
                
                obj.Bt = Bluetooth(devicename, channel);
                
                %Open the bluetooth channel
               
                flushinput(obj.Bt);
                flushoutput(obj.Bt); 
                
                obj.Bt.BytesAvailableFcnCount = 1;
                obj.Bt.BytesAvailableFcnMode = 'byte';
                obj.Bt.BytesAvailableFcn = @obj.readBytes;
                
                fopen(obj.Bt);
                flushinput(obj.Bt);
                flushoutput(obj.Bt); 
                
                obj.DeviceName = devicename;

            catch exception
                if strncmp('Sphero', exception.identifier, 6)
                    throwAsCaller(exception)
                else
                    err = MException('Sphero:Api:InvalildDevice', ...
                    'Unable to connect to device. Please check that the device name is correct and the device is discoverable');
                    exception2 = addCause(err, exception);
                    throwAsCaller(exception2);
                end
                
            end
        end
        
        function disconnect(obj)
        %DISCONNECT Disconnect from Sphero
        %
        %   DISCONNECT(OBJ) disconnects from the connected Sphero device
        
            if ~isempty(obj.Bt) && isvalid(obj.Bt) && strcmp(obj.Bt.Status, 'open')
                fclose(obj.Bt);
            end
        end       
    end
end