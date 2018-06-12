SPHERO CONNECTIVITY PACKAGE (Ver 2.4):

This package allows us to connect a computer to a Sphero device, 
and communicate with it from within MATLAB.

-----------------------------------------------------------------------------------------------

ABOUT THE SPHERO:

Sphero is a robotic platform developed by orbotix, which can be controlled using a smartphone, 
tablet or other devices via Bluetooth. Its ball-like shape allows it to roll in any direction. 
For more information please refer to the following page: http://www.gosphero.com/

-----------------------------------------------------------------------------------------------

REQUIREMENTS:

-) A Sphero

-) MATLAB (2013a or later)
-) Instrument Control Toolbox

-) A bluetooth-capable computer running either Windows
   or a 64-bits version of Mac OS 10.7 or earlier


OPTIONAL:

-) Simulink (you can use the blocks in the included library if you have it)

-----------------------------------------------------------------------------------------------

CONTENTS:

readme.txt            : this file, which you should read before doing anything :)

install_sphero.m      : run this file to install the sphero package
sphero.m              : file that defines the sphero class

+sphero               : folder containing additional files required by the package
simulink              : folder containing files related to the simulink library
examples              : folder containing various examples

-----------------------------------------------------------------------------------------------

GETTING STARTED:

The Sphero comes with a Quick Start Guide, which describes how we can 
connect to a Sphero through an iOS or Android device. For general FAQs, 
please refer to this page: https://sphero.zendesk.com/home

-----------------------------------------------------------------------------------------------

SETUP HARDWARE:

In order to connect to the Sphero, first make sure that the Sphero is awake 
and ready for connection. The following steps to set up the Sphero for 
connection can also be found in the Quick Start Guide mentioned above.
Note that in general the following steps need to be done only the first 
time when you unpack the sphero and then once in a while (specifically 
steps 1 to 3) when the battery is low and needs to be recharged.

1. Connect the Charger to a wall socket.

2. Place the Sphero in the charger with its heavy part at the bottom.

3. Remove the Sphero from the charger after it lights up after a few seconds. 
   It will be asleep at after it is taken out from the charger.

4. Double tap (ver 2.0) or shake (ver 1.0) the Sphero to wake it up.

5. The Sphero blinks 3 unique colors until it is connected to another device. 
   Sphero's Bluetooth name will contain the initials of the 3 unique colors 
   it is blinking with:
 
   R = RED 
   B = BLUE 
   G = GREEN 
   Y = YELLOW 
   O = ORANGE 
   P = PURPLE  
   W = WHITE 

   The Sphero's bluetooth name could be useful later in case you have 
   several Spero devices and want to connect to a specific one.

6. Turn on Bluetooth on your computer, and pair the Sphero to it, following 
   the instructions provided in the following web pages: 

   Windows 7: http://windows.microsoft.com/en-us/windows7/add-a-bluetooth-enabled-device-to-your-computer
   Mac  (64-bit Mac OS 10.7 or earler): http://support.apple.com/kb/ht1153
   Linux (unsupported)

   If a prompt shows up to compare the pairing codes between your computer 
   and the Bluetooth device, click on 'Yes' to 'Accept' the pairing code.


-----------------------------------------------------------------------------------------------

PACKAGE INSTALLATION:

Run the file "install_sphero.m" to install the package (note that you 
should have the right to modify the pathdef.m file). If previous versions
of the package exist, remove the folders from the MATLAB path.


ON WINDOWS:

Run MATLAB as administrator (just one time for the purpose of installing 
the package) by right-clicking on the MATLAB icon and selecting 
"Run as Administrator". This will allow the updated path to be saved.

Then from MATLAB, launch the "install_sphero" command. 
This will add the relevant Sphero folders to the MATLAB path and save the path. 

ON LINUX:

Linux is unsupported at the moment, however, to make sure that the pathdef.m 
file is writable, issue a command like this: 
sudo chmod 777 usr/local/matlab/R2014a/toolbox/local/pathdef.m
(modify the path above according to where MATLAB is installed). 

Then from MATLAB, launch the "install_sphero" command. 
This will add the relevant Sphero folders to the MATLAB path and save the path. 

-----------------------------------------------------------------------------------------------

USAGE:

Once the sphero is charged and paired with the computer, and the package is 
installed, then as soon as the sphero is woken up (which can be done by 
double tapping it or, for previous versions, shaking it) it can be directly 
accessed from MATLAB by instantiating a sphero object with commands such as: 

>> sph = sphero(); 

or, (assuming that for example Sphero-RGR is the bluetooth name of the sphero): 

>> sph=sphero('Sphero-RGR');

If a sphero object already exists in the workspace but the sphero is 
disconnected (e.g. because the "disconnect" command was used, or because
it was put to sleep, or it run out of charge), then the sphero can be 
reconnected to its MATLAB object using:

>> connect(sph);

Note that sometimes the first connections attempts might be unsuccessful, 
and you need to try two or three times before succeeding.

Once the sphero is connected to a sphero device in MATLAB, then from the 
MATLAB command line you can perfom operations such as changing the color:

>>  sph.Color = [127 63 127];

rolling the sphero with a speed of 80 (255 is the maximum) at an angle of 10 
degrees:

>> roll(sph, 80, 10);

apply optimal braking to stop the sphero

>> brake(sph);

read the sensors:

>> [accX, accY, distX, distY] = readSensor(sph, {'accelX', 'accelY', 'distX', 'distY'});

and put the sphero to sleep:

>> sleep(sph);

-----------------------------------------------------------------------------------------------

EXAMPLES:

In order to open the examples (which are mainly located in the "examples" 
subfolder in the package) either open the files in the "examples" folder 
(e.g.sphero_getting_started.m), or run the following command at the MATLAB 
Command Prompt:

open('sphero_examples.html')

The Simulink library can be opened with the command:

>> sphero_lib

An example on how to use the blocks in the library can be opened with the command:

>> roll_sim

-----------------------------------------------------------------------------------------------

USING THE SPHERO APP AND UPDATING THE SPHERO FIRMWARE:

For the purpose of using the sphero with MATLAB, you don't need to use the app
on your phone. Unless the Sphero firmware is very old, (and unless you have 
version 3.71 and need the readLocator functionality, see below) you probably 
don't need to update it to work with this package, so you don't have to download 
and use the phone app.

The Android or iPhone apps will automatically update the firmware on the 
Sphero if a new firmware version is available. 

NOTE that the readLocator capability was temporarily removed in version 3.71 
of the Sphero firmware, so if you need this functionality you need to use 
either an older or newer version of the firmware. 

If "sph" is the name of your Sphero object in the MATLAB workspace, then 
you can use the following commands to display the firmware version:

>> hw = hardwareinfo(sph);sphver = version(hw);
>> [num2str(sphver.MainSpheroApplicationVersion) ...
>> '.' num2str(sphver.MainSpheroApplicationRev)]

In any case, after updating the firmware, disconnect the Sphero device from 
your phone by putting it to sleep and then close the Sphero app. Then access 
the phone bluetooth settings, select the sphero among the bluetooth devices, 
and select "forget this device". This will prevent the sphero from 
automatically pairing up with the phone later.

------------------------------------------------------------------------------------------------

TROUBLESHOOTING: 

See the sphero_troubleshoot_connection.html in the examples folder

------------------------------------------------------------------------------------------------
Copyright 2015, The MathWorks, Inc.