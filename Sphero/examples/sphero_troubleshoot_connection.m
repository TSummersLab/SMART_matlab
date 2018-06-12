%% Troubleshooting Connection Issues with Sphero
%
%% Sphero does not show up in the list of available devices OR Connection error: using icinterface/fopen (line 83)
% Sphero is not listed under available devices when creating the
% *sphero* object, or the following error is received:
%
sph = sphero

%% 
%
%  Error using sphero (line 498)
%  Unable to connect to device. Please check that the
%  device name is correct and the device is
%  discoverable
% 
%  Caused by:
%       Error using icinterface/fopen (line 83)
%       Unsuccessful open: Cannot connect to the device.
%       Possible reasons are another application is
%       connected or the device is not available.
%%
% This might happen after a failed attempt to either create a new sphero 
% object or connect to an existing one, and it might be due to several reasons, 
% such as the device name not being correct, or the device having a different 
% name or being undiscoverable, out of range, or not awake.
% 
% To solve this, especially when creating a new sphero object, make sure 
% that the device name is correct (for example Sphero-RGW for a sphero 
% blinking Red, Green and White). Also, make sure that the sphero is paired 
% to your computer, is awake and not currently connected to another device 
% (it must be blinking with a sequence of 3 colors, see the related section 
% in the readme.txt file for more about this, and the procedure to follow 
% the very first time you use the sphero with MATLAB. You can also refer to
% the page on <matlab:showdemo('sphero_getting_started') Getting Started with Sphero
% Connectivity Package>).
% 
% If the above conditions are verified, then trying to create the Sphero 
% object again (perhaps a couple of times) will usually result in a 
% successful connection.
% 
% If you are still unable to connect to the device, close MATLAB, 
% unpair (or remove) the device from the computer and then pair it again, 
% restart MATLAB, and try creating a new sphero object.
%
% If the problem persists,  try updating the Sphero firmware by connecting
% to the Sphero app on an Android or iOS device, and repeat the above 
% procedures.
% 
%% Connection error: Undefined function 'Bluetooth'
%   
%  Error using sphero (line 498)
%  Unable to connect to device. Please check that the device
%  name is correct and the device is discoverable
% 
%  Caused by:
%     	Undefined function 'instrhwinfo' for input arguments of type 'char'.
%   
% This error (undefined function 'instrhwinfo' or 'Bluetooth' ...) means 
% that the Instrument Control Toolbox (ICT) is not installed. This package 
% is based on the bluetooth connectivity functions provided by the
% the ICT, and so therefore you will need to get that toolbox if 
% you want to use this package.
% 
%% Sphero disconnected without any warning sign
% 
% If you notice that the sphero is disconnected but you have not received 
% any error or disconnection message, it means that MATLAB is unaware 
% that the connection got lost. This is unusual because any following command 
% would be unsuccessful, therefore causing a disconnection.
% 
% In any case you can use the "disconnect" command before reconnecting 
% (with the "connect" command).
%
%%
% <html><a id = "reset"></a></html>
%% Resetting the Sphero
% 
% Sometimes MATLAB loses the connection but the sphero is unaware of it, 
% (that is it still displays a solid color without blinking). 
% This might happen for example when the sphero variable is inadvertedly 
% cleared while the sphero was still connected.
% 
% In such cases, you need to reset the sphero, which can be done by 
% placing it on the charger. 
% 
% If the sphero is still running (rotating) then the inductive copper coil 
% under of the robotic chassis does not point straight down but at an angle 
% of approximately 45 degrees between the vertical axes and the axis opposite 
% to the direction of motion. Therefore, the charger must be placed at the 
% same angle so that it is close to the Sphero inductive coil. Alternatively
% if you move the charger around the Sphero circumference it will find the 
% coil and reset itself.
%
% Also see this: <https://sphero.zendesk.com/entries/22259484>
% 
% Once the sphero has been reset, then the connect command can be used to 
% reinstate the connection to the sphero.

%% Warning received when connecting to device
% Creating a connection to Sphero device produces the following warning,
% and the Status of the connection is 'closed':
sph = sphero('Sphero-GPG');

%% 
%  Warning: Error occured when reading Asynchronous message: Received response is not valid 
%  Warning: The BytesAvailableFcn is being disabled. To enable the callback property
%  either connect to the hardware with FOPEN or set the BytesAvailableFcn property.
%  
%  > In BluetoothApi>BluetoothApi.readResponse at 1145
%   In sphero>sphero.get.Color at 1366
%
% This might occur when the Sphero responds with an invalid response when
% trying to connect to it initially. Please try connecting to it once
% again.
%%
% <html>
% If the problem persists, reset the Sphero device by placing it on the 
% charger (see the section above on <a href = "#reset">Resetting the 
% Sphero</a>), and then try to connect to it again.
% </html>
%% Error when connection gets broken
%
% The two errors and the warning shown below might occur when the connection gets lost. 
% This can happen for a variety of reasons, such as the sphero going out 
% of range, or running out of battery, or going to sleep because of inactivity. 
% 
% In such cases, just wake up the sphero, make sure it's in range, and 
% reconnect it using the "connect" command (or recreate the sphero
% variable).
%%
%  Error using icinterface/fwrite (line 193)
%  An error occurred during writing
%  
%  Error in sphero.internal.BluetoothApi/sendCmd (line 1251)
%                  fwrite(obj.Bt, cmd);
% 
%  Error in sphero/set.Color (line 1354)
%             [responseexpected, seq] = sendCmd(obj.Api, 'setrgbled', [], [], [], uint8(rgb),
%             uint8(obj.SaveLedColor));
%
%%  
%  Error using sphero.internal.BluetoothApi/readResponse
%  (line 1133)
%  Response Timeout
% 
%  Error in sphero/heading (line 351)
%     response = readResponse(obj.Api,
%     responseexpected, seq,
%     obj.ResponseTimeout);
% 
%  Error in sphero/calibrate (line 1112)
%     result2 = heading(obj, 0);
% 
%%
%  Warning: Unable to write to device. The Sphero might already be
%  disconnected
%  > In sphero/BluetoothApi/sendCmd (line 1255)
%    In sphero/set.Color (line 1354)
%
%% Error in sphero/readLocator (line 1068)
% 
%  Error using sphero/BluetoothApi/readResponse (line 1133)
%  Unknown command ID received. Please check API definition
% 
%  Error in sphero/readLocator (line 1068)
%             response = readResponse(obj.Api,
%             responseexpected, seq, obj.ResponseTimeout);
%  
% The most likely cause of this error is that you are using a Sphero
% with firmware version 3.71, in which this functionality was temporarily
% removed. Therefore, if you need to use the readLocator function you need 
% to use either an older or newer version of the firmware. 
% 
% If "sph" is the name of your Sphero object in the MATLAB workspace, then 
% you can use the following commands to display the firmware version:
% 
hw = hardwareinfo(sph);sphver = version(hw);
firmware = [num2str(sphver.MainSpheroApplicationVersion) ...
'.' num2str(sphver.MainSpheroApplicationRev)]
%% See Also
% <matlab:showdemo('sphero_examples') Sphero Connectivity Package Examples>
%
%%
% Copyright 2015, The MathWorks, Inc.