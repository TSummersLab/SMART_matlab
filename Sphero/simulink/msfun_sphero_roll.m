function msfun_sphero_roll(block)
% Level-2 M-File S-Functions, Copyright 2015, The MathWorks, Inc.

% instance variables 
mySphero = [];

setup(block)

%%
    function setup(block)
        % Register the number of ports.
        block.NumInputPorts  = 1;
        block.NumOutputPorts = 0;
        
        block.SetPreCompInpPortInfoToDynamic;
        block.InputPort(1).Dimensions        = 2;
        block.InputPort(1).DirectFeedthrough = false;
        
        % Set up the states
        block.NumContStates = 0;
        block.NumDworks = 0;
        
        % Register the parameters.
        block.NumDialogPrms     = 2; % sphero var
        block.DialogPrmsTunable = {'Nontunable', 'Nontunable'};
        
        % Set the sample time
        block.SampleTimes = [block.DialogPrm(2).Data 0];
        
        block.SetAccelRunOnTLC(false); % run block in interpreted mode even w/ Acceleration
        block.SimStateCompliance = 'DefaultSimState';
        
        % the Sphero Setup block uses the Start method to initialize the sphero
        % connection; by using InitConditions, we ensure that we don't access
        % the variable before it is created
        
        block.RegBlockMethod('CheckParameters', @CheckPrms); % called during update diagram
        % block.RegBlockMethod('Start', @Start); % called first
        block.RegBlockMethod('PostPropagationSetup', @PostPropSetup); 
        block.RegBlockMethod('InitializeConditions', @InitConditions); % called second
        block.RegBlockMethod('Outputs', @Output); % called first in sim loop
        % block.RegBlockMethod('Update', @Update); % called second in sim loop
        block.RegBlockMethod('Terminate', @Terminate);
    end

%%
    function CheckPrms(block)        
        try
            validateattributes(block.DialogPrm(1).Data, {'char'}, {'nonempty'});  % Name of sphero instance
            validateattributes(block.DialogPrm(2).Data, {'numeric'}, {'real', 'scalar', 'nonzero'}); % sample time
        catch %#ok<CTCH>
            error('Simulink:Sphero:invalidParameter', 'Invalid value for a mask parameter');
        end        
    end                
        
%%
    function PostPropSetup(block)
        st = block.SampleTimes;
        if st(1) == 0
            error('The Sphero library blocks can only handle discrete sample times');
        end        
    end
%%
    function InitConditions(block) 
        % fprintf('%s: InitConditions\n', getfullname(block.BlockHandle));
        customData = getSpheroSetupBlockUserData(bdroot(block.BlockHandle), block.DialogPrm(1).Data);
        mySphero = customData('spheroHandle');
    end

%%
    function Output(block)
        % fprintf('%s: Output\n', getfullname(block.BlockHandle));
        roll(mySphero,block.InputPort(1).Data(1),block.InputPort(1).Data(2));
    end

%%
    function Terminate(block)  %#ok<INUSD>
        % stop mySphero
        brake(mySphero);
    end
end

