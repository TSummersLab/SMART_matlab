function msfun_sphero_setup(block)
% Help for Writing Level-2 M-File S-Functions:

%   Copyright 2015 The MathWorks, Inc.

% define instance variables
mySphero = [];

setup(block);

%% ---------------------------------------------------------

    function setup(block)
        % Register the number of ports.
        block.NumInputPorts  = 0;
        block.NumOutputPorts = 0;
        
        % Set up the states
        block.NumContStates = 0;
        block.NumDworks = 0;
        
        % Register the parameters.
        block.NumDialogPrms     = 2; % Sphero var number, workspace var name
        block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};
        
        % Block is fixed in minor time step, i.e., it is only executed on major
        % time steps. With a fixed-step solver, the block runs at the fastest
        % discrete rate.
        block.SampleTimes = [0 1];
        
        block.SetAccelRunOnTLC(false); % run block in interpreted mode even w/ Acceleration
        block.SimStateCompliance = 'DefaultSimState';
        
        % If the creation of a new variable is requested, (i.e. no
        % previously instantiated workspace Sphero variable is used)
        % then the Sphero block uses the Start method to initialize the
        % Sphero connection before the variable is actually accessed
        
        block.RegBlockMethod('CheckParameters', @CheckPrms); % called during update diagram
        block.RegBlockMethod('Start', @Start); % called first
        % block.RegBlockMethod('InitializeConditions', @InitConditions); % called second
        block.RegBlockMethod('Terminate', @Terminate);
    end

%%
    function CheckPrms(block)
        try
            validateattributes(block.DialogPrm(1).Data, {'char'}, {'nonempty'}); % sphero variable number
            validateattributes(block.DialogPrm(2).Data, {'char'}, {'nonempty'}); % name of existing workspace variable
        catch %#ok<CTCH>
            error('Simulink:Sphero:invalidParameter', 'Invalid parameter for Sphero Identification block');
        end
        
        try
            mySphero = evalin('base', block.DialogPrm(2).Data);
            assert(isa(mySphero, 'sphero'));
            assert(isvalid(mySphero));
            assert(strcmpi(mySphero.Status,'Open'));
        catch
            error('Simulink:Sphero:invalidParameter', 'Either the workspace variable ''%s'' is not defined, or it is not a valid and connected Sphero object', block.DialogPrm(2).Data);
        end
        
    end

%%
    function Start(block)
        
        % copy the Sphero object
        mySphero = evalin('base', block.DialogPrm(2).Data);
        
        % store info in custom data;
        customData = containers.Map('UniformValues', false);
        customData('spheroHandle') = mySphero;
        set(block.BlockHandle, 'UserData', customData, 'UserDataPersistent', 'off');
        
    end

%%
    function Terminate(block)      
        customData = get(block.BlockHandle, 'UserData');
        if isvalid(customData)
            delete(customData);
        end
    end


end

