classdef (Hidden = true, Abstract) Communication < handle
    % COMMUNICATION API for communication between Sphero and machine
    %   Abstract class for Communication between Sphero and the
    %   connectivity package. Classes for specific communication protocol
    %   (eg. Bluetooth) inherit from this class.
    %
    % Copyright 2015, The MathWorks, Inc.

    properties (Abstract, Access = ?sphero)
        ApiInfo
        Handshake
        Sensors
        SamplesPerPacket
        SensorDataPropertySet 
    end
    
    properties (Abstract, Constant, Access = ?sphero)
        Uint8Max
        SpheroDeviceNameBeg
        MaxSensorSampleRate
        ResponseError
        ResponseInitialValue
        ResponseEmpty
    end
    
    methods (Abstract)
        connect(obj, varargin)
        disconnect(obj)
        [cmd, respond, seq] = createCommand(obj, action, varargin);
        [responseexpected, seq] = sendCmd(obj, action, varargin)
        [valid, ack, data, code] = decodeResponse(obj, response);
        response = readResponse(obj, responseexpected, seq, responseTimeout);
    end
   
end

