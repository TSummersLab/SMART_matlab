# Sphero Multi-Agent Robotic Testbed for Matlab (SMART_matlab)
The Sphero Multi-Agent Robotic Testbed is developed at the University of Texas at Dallas (UTD). The platform uses Matlab as an environment to control Sphero robots. The platform relies on the MATLAB [Sphero Connectivity Package](https://www.mathworks.com/matlabcentral/fileexchange/52481-sphero-connectivity-package) to communicate with the Sphero robots. It provides many other files, developed at UTD, that detect and monitor the Sphero robots using a webcam, track their motion over time, estimate their states using an extended Kalman Filter, control them based on holonomic and non-holonomic models, and store the experimental data to create plots and videos. The package can be used to control the robots in a centralized or distributed manner using a single computer or multiple computers through the TCP/IP functions included.

The package contains an application on the Sphero Multi-Agent Robotic Testbed in which a high-level controller is presented to perform distributed formation control experiments as seen in [this video](https://youtu.be/AxT-fFcGQoA) (the video is also linked in the image below). The package can be used to test and collect experimental results for several novel control algorithms. A variant of the package that targets ROS (Robot Operating System) on Linux as its environment will be made available soon.

 [![Sphero demo](/Images/SRP_Video.jpg)](https://youtu.be/AxT-fFcGQoA "Sphero demo video")

## Outline of SMART_matlab README Documentation
* [About the Spheros](#about-the-spheros)
* [Requirements](#requirements)
* [Package Organization](#package-organization)
* [Package Operation Outline](#package-operation-outline)
* [Platform Capabilities](#platform-capabilities)
* [Getting Started](#getting-started)
* [Potential Problems](#potential-problems)
* [Useful Tips](#useful-tips)
* [Useful Resources](#useful-resources)
* [Acknowledgements](#acknowledgments)
* [Appendix](#appendix)
* [License](#license)

## About the Spheros
The Sphero robot is small sized spherical robot. It has two motors that roll on the internal surface of its plastic waterproof shell allowing the robot to move. When the robot starts, its current heading, is set to be its reference heading. Thus, every time the robot starts it has a new reference heading. The robots use Bluetooth technology for their wireless communications.

![Sphero screenshot](/Images/Sphero_Inside.jpg "Inside the Sphero robot")

## Requirements
The package requirements can be divided into three categories:
* Operating System:
  * Windows:
    * The platform has been tested with Windows 7 and Windows 10. The package runs normally on either operating system.
  * macOS:
    * With some modifications, the platform can run on computers running MacOS. The package was used on OS X 10.11 (El Capitan) and macOS 10.12 (Sierra) and 10.13 (High Sierra). The required changes are explained in the [Changes for Mac](#changes-for-mac) section in the [Appendix](#appendix). However, we recommend using Windows computers.
* Software:
  * MATLAB:
    * The package has been tested with MATLAB R2017a and R2017b. The additional required Toolboxes are:
      * Computer Vision System Toolbox
      * Image Acquisition Toolbox
      * Image Processing Toolbox
      * Instrument Control Toolbox
      * MATLAB Support Packages for USB Webcams
    * For more information on adding toolboxes visit the Mathworks [Manage Your Add-Ons](https://www.mathworks.com/help/matlab/matlab_env/manage-your-add-ons.html) webpage.

![Sphero Platform](/Images/Platform.jpg "Sphero robots and a webcam")
* Hardware:
  * Computer(s):
    * The package requires at least one computer to run. It has been tested with up to three computers running the same experiment session together. We have tested the platform on multiple computers:
      * Workstation-class laptops with fourth generation Intel Core i7 running Windows 7 and Windows 10
      * Business-class laptop with sixth generation Intel Core i7 running Windows 10
      * Microsoft Surface Tablet running Windows 10
      * Macbook Pro with fourth generation Intel Core i7
    * The package should work if all the MATLAB toolboxes are available for the platform.
  * Camera:
    * The platform uses a webcam to locate the robots. The platform was tested with the following cameras:
      * Logitech C920 Webcam
  * Tripod:
    * To fix the location of the camera and place it at a higher altitude, a tripod might be necessary.
  * Calibration board:
    * To calibrate the camera a non-square checkerboard patter is required.
  * Sphero robots:
    * The platform uses the MATLAB Sphero Connectivity Package to communicate with the Sphero robots. However, it cannot support Spheros with BLE (Bluetooth Low Energy) technology. Thus, the platform can only support the following robots:
      * Sphero SPRK robots (discontinued)
      * Sphero 2.0 robots (used to test this package)
  * Bluetooth dongle:
    * If the computer is not equipped with a Bluetooth module, a Bluetooth dongle is required. Older machines may also benefit from a new and faster Bluetooth dongle. An example of such Bluetooth dongles is the [SMK Nano USB Dongle with LE+EDR](https://www.frys.com/product/7299223?site=sr:SEARCH:MAIN_RSLT_PG).
  * Black cloth:
    * The platform uses color based detection to recognize the Spheros. It is preferred to have a black or dark background to avoid false positives. We chose to place a piece of black cloth in the camera's field of view to control the environment background.

## Package Organization
The folders of the repository are:
* Calibration images
  * Contains folders with the calibration data (.mat data file and pictures used for calibrating the camera).
* CVX
  * Convex optimization problem solver for MATLAB.
* EKF
  * Contains MATLAB scripts for the extended Kalman filter.
* Formation Control
  * Contains MATLAB scripts and functions to determine the control signal when using a distributed formation control algorithm.
  * This file is not necessary for the package. It is one application that uses the package and serves as an example to show how the package can be used.
* Helpers
  * The folder contains the MATLAB functions and scripts used by the scripts that runs the package.
* Sphero
  * Contains the MATLAB Sphero Connectivity Package.
  * Using a newer version of this package may be possible, but it has not been tested.
The main script of the package, and the one that runs it, is `Main.m`.

## Package Operation Outline
When the package runs on a computer, it primarily operates as follows:
1. Connecting to the Spheros
2. Calibrating the camera
3. Estimating the initial heading of the Spheros (orientation of the body frame relative to the world frame)
4. Communicating with other computers and tagging the Spheros
5. Controlling the Spheros
  - tagging them
  - tracking them over time
  - estimating their heading
  - calculating control command
  - sending them control commands
More details will be explained in the [Getting Started](#getting-started) section.

## Platform Capabilities
The platform is capable of controlling multiple robots at the same time. While each computer can only connect to a maximum of 7 robots because of Bluetooth limitations, we have observed that 6 robots is the practical limit and 4 robots is the ideal number for many computers. The number of robots, the time it takes for the Sphero Connectivity Package to connect to them, and the stability of the connection are all dependent on the Bluetooth module used and the computer's hardware. For example, a Microsoft Surface tablet can connect reliably to two robots, a Business-class laptop may be able to support 4 Spheros normally. Machines with older hardware performed better with a newer USB Bluetooth dongle.

The number of Spheros controlled can be increased by using multiple computers connected to the same WiFi Network. The computers would only communicate once to sync the Sphero tags and gain matrix. Afterwards, the computers can run independently. Thus, the package can be used for both centralized and decentralized control algorithm.

The platform uses a webcam per computer to locate the Spheros. While this works well, it does restrict the operation region of the Spheros to the field of view of the camera or the intersection of the field of views of the cameras in case multiple cameras were used.

The platform uses color based detection to locate the robots. This allows the platform to separate Spheros by color in case multiple teams are formed to test control algorithms related to game theory. However, color based detection is prone to detecting false positives. Thus, the field of view of each camera must be free of interference and the chosen colors should be easily distinguishable. This also forces the background to be dark. Color based detection also limits the separation between robots. When robots of the same colors intersect, the individual robots can no longer be identified.

Currently the package can only use a resolution of 640x480. This value is hard-coded in multiple places in the package. This means that the camera calibration should be done in 640x480 and the camera aspect ratio must be 4:3 ( if the resolution of the image delivered to functions is not 640x480, the image is resized). If the aspect ratio is not 4:3, the image, and thus the reconstructed data, will become distorted. While the package will continue to operate, formations will become somewhat distorted.

## Getting Started

### Assumptions
We will make the following assumptions when explaining how to use the package:
* Compatible Sphero robots are obtained and fully charged. We will refer to the compatible robots as Spheros (regardless of the model).
* A compatible computer is obtained and is equipped with a Bluetooth module. We will assume that only one computer is used, but we will indicate the necessary changes to use multiple computers. We will also assume that the computer is running Windows OS, but we will indicate the necessary changes when using computers running macOS.
* A MATLAB-compatible camera is obtained with a tripod or other structure that provides elevation.
* A large and empty area with a dark background is available to run the package. The size of the area may vary based on the camera placement, but a minimum area of (6' x 6') or (2m x 2m) is recommended.

### Preparing the Environment
Before running the package, you should setup the physical environment in which the experiments will be performed. Start by finding a large space where you can run the experiments. The space should have a black background and preferably a flat carpet-like surface. Tile floors work or stamped concrete, but they might affect the performance of the package if they were reflective and/or not flat. Large gaps between tiles, that cause Spheros to wobble when traversing, are considered obstacles for the Spheros.
Next, setup your camera. Try to center the camera so that it overshadows the Spheros' operation area. Try to elevate the camera and point it vertically down as much as possible. This will improve the platform's image processing. In our experiments, we placed the camera at a hight of about 6.5' or 2 meters. The camera's optical axis made an angle of about 30 degrees with the line pointing vertically downward. These values serve an informative role only. They need not be followed exactly. We will continue the camera setup step in the [Using the Package](#using-the-package) section.

![Experiment_setup](/Images/ExprSetup.jpg "Experimental setup with multiple computers")

You should also pair the Spheros to your computer. Trying to connect to unpaired Spheros may result in MATLAB crashing. You can pair the Spheros by following these steps:
1. Double tap the Sphero to wake it up. It should blink with its three identifying colors. The color sequence represents the Sphero's name; e.g. if it blink red-green-red then its name is Sphero-RGR. Note that the color sequence is not unique. If you have multiple robots with the same name, you cannot connect to them using this package.
2. Open your Bluetooth preferences or management tool on your device and refresh the list of available devices.
3. Locate your Sphero in the devices list and pair it with your computer. The Sphero might show up as an audio device.
Repeat the pairing procedure until all the Spheros that will be controlled by the computer are paired.

When using multiple computers, connect all the computers to the same WiFi network. Then, find the address of each computer on the network and take note of that address. To find the address, do the following:
* On Windows OS:
  * Open `Command Prompt` by searching for it from the start menu and clicking on it.
  * Run the following command in command prompt:
  ```
  ipconfig
  ```
  * Under `Wireless LAN adapter Wi-Fi`, you will find ` Default Gateway`. The adjacent number is the address of the computer on the wireless network. It should have the following format `XXX.XXX.X.XX` i.e. 192.168.0.1.
* On macOS or OS X:
  * Open `Terminal`. It can be found in `Applications/Utilities/Terminal`.
  * Run the following command in terminal:
  ```
  ifconfig
  ```
  * Under `en0` you will find `inet`. The number next to it is the address of the computer on the wireless network. It should have the following format `XXX.XXX.X.XX` e.g. 192.168.0.1.

Note that the addresses must be identical in the first three fields but different in the last one. i.e. 192.168.0.1 and 192.168.0.2. However, these addresses are not unique to the devices, the last (right-most) field may change. You need to check the address if you disconnect from the network.

### Preparing the Package
Now it is time to prepare the package for use on your machine. Follow these steps to prepare your package:
1. Get the SMART_matlab package
  * You can clone the package by running the following command in terminal:
  ```
  cd path
  git clone http://github.com/TSummersLab/SMART_matlab.git
  ```
  Here, `path` refers to the directory where you want to store and run the package. e.g. `path` =  `~/Documents/MATLAB`
  * Alternatively, you can go to the [Github repository](https://github.com/TSummersLab/SMART_matlab) and choose `Download Zip` under the `Clone or Download` button. You can then unzip the downloaded folder and place it wherever you want. We will call the insallation location `path`
  * Make sure you know where you store the package. The directory is required by MATLAB.
2. Install the cvx Package
  * Open a MATLAB session and navigate to the directory where SMART_matlab is placed. The "Current Folder" window should show the files inside SMART_matlab.
  * In the "Current Folder" window, click on the arrow next to cvx to show the files inside of it.
  * Double click on `cvx_setup.m` in the cvx file. It should open up in the MATLAB Editor
  * Hit the green run button to run the script. This will install CVX.
  * If CVX cannot be installed, you may try to download the redistributable CVX package from the CVX website through this link: [http://cvxr.com/cvx/download/](http://cvxr.com/cvx/download/). Once downloaded, copy the file, as is, to the SMART_matlab file. Replace the old cvx folder by the new one.
3. Edit `Main.m`
  * `Main` is the script that runs the whole package. It is divided into different sections that must be executed sequentially. We will explain each section, its role, and the required changes.
    1. Adding paths
      * The fist section adds the MATLAB paths for the project folders.
      * **Run this section without changes.**
    2. Preallocate parameters
      * This section initializes and preallocates variables related to the Spheros and the package's execution. Here are the changes that must be made:
          * SphNames:
              * The parameter contains the three color sequence of the Spheros that will be controlled by this particular computer.
              * Change the values to suitable ones, but keep the syntax. i.e.: SphNames = {'RRY', 'YPW'}
          * CameraParam.col:
              * The parameter contains the RGB color values of the color to be detected. The default color is cyan (R = 0, G = 255, B = 255). We recommend maxing out the R, G, or B channels that are being used.
              * While this value can be changed, we recommend keeping it. Other detection colors can be added, but that requires modifying the CameraParam object and other parts of the code.
                  * In case multiple colors, make sure that the colors are as distinct as possible; i.e. red and blue work, but cyan and blue would not work.
          * numItr:
            * Number of data points to keep for every parameter. This includes the images, position of the robots, and command velocity.
            * This number can be decreased to a minimum of 2, but then videos of the experiments cannot be made. Increasing this value too much consumes a lot of memory. A value of 5000 is good even if you have only 8GB of RAM.
          * SpheroState.numRob
            * Contains the total number of robots controlled by all computers.
      * **Once the necessary changes have been made, run this section.** You only need to rerun this section if the parameters are changed (more robots are added, more or less data is required, ...).
    3. Test webcam
      * Tests the camera.
      * Lines in this section must be executed individually.
      * The functions are as follows:
          * `camList = webcamlist`
            * Displays a list of all available webcams.
            * If your webcam is not detected, make sure it is compatible with the MATLAB webcam package.
            * The order of webcams in this list may change if the port the camera is connected to changes. It is recommended that this line is run the first time a webcam is connected.
          * `cam = webcam(1)``
            * Creates an object for the webcam.
            * The index is the order of the webcam in `camList`
          * `preview(cam)`
            * Creates a camera preview.
            * Use this to setup the camera so that the field of view is clear of any obstacles.
          * `clear cam`
            * Destroys the webcam object, `cam`.
            * Run this if `cam = webcam(1)` is executed.
      * **There is no need to run this section unless you want to see what the camera field of view is, which is necessary only when resetting the setup.**
    4. Connect to Spheros
      * Connects to the Spheros
      * You can run this section without any changes. You only need to run it if Spheros are replaced, added, or removed.
      * Note that the color of the Spheros might change, but once the controller starts running, the chosen color, `CameraParam.col`, is used.
      * **Run this section without changes when changes are made to the Spheros.**
    5. Record movie
      * Sets up the parameters required for recording a movie after the experiment is done.
      * To record a movie set `SpheroState.Video.Record` to `true`. If you do not want to record a movie, set `SpheroState.Video.Record` to `false`.
      * If recording a video, change the name of the video by modifying the `SpheroState.Video.VideoName` field.
      * This will not begin recording the movie.
      * **This section must be executed regardless of whether a movie is to be recorded or not.** It contains variables that must be initialized at least once.
    6. Initialize camera and detect checkerboard
      * Initializes the camera parameters and detects the checkerboard to find the extrinsic matrix which allows a single camera to reconstruct the world position of the Spheros from the pixel value.
      * Before running this section you need to have the camera calibrated and generate a `.mat` file. This camera calibration must be done once per camera. The calibration data can be stored for future use. To calibrate the camera follow these steps in the [Camera Calibration Using MATLAB App](#camera-calibration-using-matlab-app) section in the [Appendix](#appendix).
      * Set the `CameraParam.squareSize` to the value used during the calibration.
      * Set the `CameraParam.paramFile` to the name it was given when the camera parameters were exported. e.g. 'CameraParams_Logitech_640x480_Gans.mat'.
      * Set the `CameraParam.camID` to the index obtained during the "Test Webcam" section.
      * Place the checkerboard in the camera field of view.
      * **Make the changes then run the section. Execute this section only when the camera is moved or `CameraParam` object is deleted.**
      * Refer to [Detecting Checkerboard with Multiple Computers](#detecting-checkerboard-with-multiple-computers) section in the [Appendix](#appendix) to learn about how to use this section with multiple computers.
    7. Theta0 estimation
      * This section estimates the initial heading of the robots.
      * There are no changes to make. **Run the section as is**. Then follow the instructions.
      * Details about this section are provided in [Theta0 Estimation](#theta0-estimation) section in the [Appendix](#appendix).
    8. Setup TCPIP info
      * This section sets up the server-client data.
      * Changes to be made in this section are as follows:
          * SpheroTCPIP.server
              * Paramerter in the SpheroTCPIP object.
              * Set it to 1 if the computer is the only computer or the server computer. Set it to 0 if the computer is a client.
              * When using multiple computers, the user must chose a single computer to be the server computer. That computer does not have to be special. It just controls data transfer between computers in the first iteration.
          * SpheroTCPIP.ip
              * Parameter contains a list of the server or client computers.
              * Server computer must contain the ip addresses of all other clients. Use double quotes for each address and commas to separate them. e.g. `SpheroTCPIP.ip = ["192.168.1.1", "192.168.1.3"]`.
              * When using only one computer, leave the list empty. e.g. `SpheroTCPIP.ip = []`.
              * Client computers must contain the address of the server only. e.g.: `SpheroTCPIP.ip = ["192.168.1.1"]`.
      * **Make the appropriate changes then run the section.**
    9. Formation control gains
      * This section is only required when running the distributed formation control algorithm which is provided as an example of a control algorithm tested on the platform.
      * This section calculates the gain matrix for a distributed formation control algorithm.
      * **Run this section as is when using the implemented Formation Control algorithm ONLY.**
    10. Controlling Spheros
      * This section runs the control law and issues the Spheros the appropriate commands.
      * In all iterations, the following main functions are called:
          1. SpheroTCPIPDetectionTracking_Ver1_2
              * Detects the robots, tags them, and tracks them using a nearest neighbor search algorithm.
          2. SpheroHeadingSpeedEstim_Ver1_2
              * Estimates the instantaneous heading of the robots in the world frame.
          3. FormationControl_Ver3_2
              * Applies a control law to generate a desired velocity vector (heading angle and speed) represented in the world frame.
              * The results are stored in the `SpheroState.Ctrl` parameter in the form of a 2x1 element for a certain robot and a certain iteration. The element contains the x component of the velocity vector in the first row and the y component of the velocity vecotr in the second row:
              ```
              SpheroState.Ctrl(iteration_number, robot_number, [velocity_x; velocity_y])
              ```
              * This section of the code can be replaced by any other control algorithm.
          4. SpheroControl_Nonhol_Ver3_2 or SpheroControl_Ver3_1
              * Either one of the two functions can be used. They both have the same arguments and return the same output.
              * The `SpheroControl_Nonhol_Ver3_2` function sends the calculated control command to the Sphero robots based on a non-holonomic model of the Sphero.
              * The `SpheroControl_Ver3_1` function sends the calculated control command to the Sphero robots based on a holonomic model of the Sphero.
              * If a low level controller is to be tested, this function can be replaced. Make sure to update all the necessary parameters (they are typically the final few lines of the function).
          5. SpheroKalmanFilter_Ver1_2
              * Uses a extended Kalman filter to estimate the heading and the position of the robots in the world frame.
              * This part of the code is still experimental.
          6. SpheroVideoStream_Ver1_3
              * If uncommented, the function displays data about the Spheros and plots their location, control vector, and estimated heading.
              * If commented out, this does not interfere with the code.
              * We recommend commenting this function out on slower computers of it the package lags. Handling figures and plotting data is time consuming.
          7. SpheroShiftData_Ver1_1
              * Updates the data being stored. If the memory allocated for storing data is full older iterations are deleted and new data is stored. Thus, only the most recent `numItr` iterations of data are stored.
      * **Change the required functions, if any, then run the section as is.**
    11. Stop Spheros
      * Stops the Spheros and resets their heading angle to their relative initial heading.
      * **Only run the section as is if you want to kill the robots' motion.**
    12. Disconnect from Spheros
      * Disconnects from the Spheros.
      * **Only run this section as is when you are done with the experiments and want to completely disconnect from the robots.**
    13. Save variables
      * You may uncomment this section and run it to save the variables.
      * **Optional section. Run to save data in a `.mat` file.**

### Using the Package
Once the package is setup and configured, it is easier to use. Below is a summary of the steps required to run the package:
1. Adding paths
   * No changes necessary.
   * Run the section once when a new session of MATLAB starts. Make sure you are in the SMART_matlab directory.
2. Preallocate parameters
   * Changes may be made.
   * Run the section once when a new session of MATLAB starts. Run again if changes to parameters in this section are made.
3. Test webcam
   * Changes may be made.
   * Run individual lines to check the webcam ID or to fix the camera's field of view.
4. Connect to Spheros
   * No changes necessary.
   * Run the section once to connect to the Spheros.
5. Record movie
   * Changes may be made.
   * Run the section once when a new session of MATLAB starts. Run again if changes to parameters in this section are made (such as changing the name of the video).
6. Initialize camera and detect checkerboard
   * Changes may be made.
   * Run the section only when the camera is moved.
7. Theta0 estimation
   * No changes necessary.
   * Run the section when the previous section is executed. You may also run it to update the initial heading estimate.
8. Setup TCPIP info
   * Changes may be made.
   * Run the section once when a new session of MATLAB starts. Run again if changes to parameters in this section are made.
9. Formation control gains
   * No changes necessary.
   * Run the section once when a new session of MATLAB starts. Run again if changes to the Spheros are made.
10. Controlling Spheros
   * Changes may be made. Replace function by other test functions.
   * Run the section every time an experiment is to be performed.
11. Stop Spheros
   * No changes necessary.
   * Run the section if the robots do not stop moving.
12. Disconnect from Spheros
   * No changes necessary.
   * Run the section when experiments are over.
13. Save variables
   * No changes necessary.
   * Optional section. Run to save data in a `.mat` file.


## Potential Problems

### Problems with Connecting to the Spheros
Spheros use Bluetooth technology to communicate. However, their connectivity with MATLAB is not perfect. If you have problems connect to the Spheros try the following:
* Use a smartphone to connect to the Spheros using the official SpheroEDU application and check for firmware updates.
* Restart the Spheros by place them back on the charging station, removing them, then double tapping them.
* Reset the Spheros:
  * Place the robot on its charging station.
  * Press and hold the button on the station then lift the Sphero. This should turn off the Spheros (double tapping them should not start them).
  * Release the button on the charging station.
  * Place the Sphero back on the charging station and wait for it to turn on.
* Restart your Bluetooth.
* Restart MATLAB.
* Restart your computer.
* Try to use a USB Bluetooth dongle. Newer hardware might solve the problem.

If while the Spheros are connected, one of them disconnects, run the `Disconnect from Spheros` section on the corresponding computer, then try connecting to the Spheros again. If that reconnecting fails, disconnect from the Spheros and restart them. If they fail to connect, try turning off and on you Bluetooth. If that does not work, restart MATLAB and/or your computer.

### Terminating Package Sections
When running any of the sections that communicate with the Spheros continuously, do not use control-C to stop MATLAB. If this happens while the Spheros are communicating with MATLAB, they will not respond anymore and you might have to restart MATLAB and the Spheros. To terminate such sections, either close any running graphs (the lack of a figure handle will terminate the section), or hide one of the Spheros from the camera field of view. No matter what happens, **do not stop MATLAB while communicating with a Sphero robot**.

### Spheros not Converging to their Desired Goal
If, while running the control code, the Spheros fail to converge to their desired goal position by either moving in a completely different direction or wobbling around their goal positions, try repeating the `Theta0 estimation` section. If that still does not resolve the problem, try reducing the gains by decreasing the values of `SpheroState.Param.Kp` or `SpheroState.Param.Ki` in `SpheroLoadParam_Ver1_4.m`.

## Useful Tips
Below are some objects and variables that might be of interest when debugging or improving performance:
* SpheroState Object
  * The SpheroState object contains all the parameters and variables that are related to the Spheros and their control. Some of the variables and parameters that might be of use include:
    * PID gains for the Sphero controller
      * The Spheros are controlled using a PID controller. The gains for the controller are the `SpheroState.Param.Kp`, `SpheroState.Param.Ki`, and `SpheroState.Param.Kd` parameters in the SpheroState object. The parameters are initialized in the `SpheroLoadParam_Ver1_4.m` file in the `Helpers` folder.
    * Maximum speed of the Spheros
      * The maximum speed of the Spheros is the speed at which the Spheros move when the controller saturates the input. If the Spheros are constatly moving at that speed, try reducing the PID gains. If the Spheros are too fast, try reducing the maximum speed, `SpheroState.Param.vMax`, in the `SpheroLoadParam_Ver1_4.m` file in the `Helpers` folder.
* CameraParam Object
  * The CameraParam object contains the parameters and variables related to the camera.
* cam Object
  * The cam object contains the MATLAB camera object. It contains all the camera parameters, some of which can be modified. It can be passed to function to view the camera field of view (`preview` function), and acquire an image (`snapshot` function), as well as other functions. For more information refer to the [following link](https://www.mathworks.com/help/supportpkg/usbwebcams/ug/acquire-images-from-webcams.html#bt6eebl).

## Useful Resources
In addition to the paper in `SMART_matlab/Paper`, below are some resources that might be useful to better understand how the package works:
- [MATLAB single camera calibration](https://www.mathworks.com/help/vision/ug/single-camera-calibrator-app.html)
- [Camera calibration and 3D reconstruction](https://docs.opencv.org/2.4.13.4/modules/calib3d/doc/camera_calibration_and_3d_reconstruction.html#camera-calibration-and-3d-reconstruction)
- [Robust distributed formation control of agents with higher-order dynamics](https://drive.google.com/uc?export=download&id=1lEfn3IqaZaY0SapB_cI86XH1-4zMrFxR)
- [Video: Robust Distributed Planar Formation Control for Higher-Order Holonomic and Nonholonomic Agents](https://youtu.be/1pfgXESMHxE)
- [Video: Robust Distributed Formation Control of Sphero Robots with Collision Avoidance](https://youtu.be/AxT-fFcGQoA)

## Acknowledgements

The package was primarily developed by: [Kaveh Fathian](https://github.com/kavehfathian) and [Sleiman Safaoui](https://github.com/The-SS) at the University of Texas at Dallas.

We would like to thank Giampiero Campa and Danvir Sethi at Mathworks for providing us with the MATLAB Sphero Connectivity Package.

## Appendix

### Changes for Mac
Most of the package is compatible with MATLAB for MacOS. The only exception is within the MATLAB Support Packages for USB Webcams. While the Windows version of the toolbox enables the user to modify camera parameters extensively, including the resolution, exposure, contrast, and other parameters, the MacOS/OS X version is more limited. Using the Logitech C920 webcam, users cannot change any of these parameters. To use the package on a computer running MacOS/OS X make the following changes:
* Download an application to control camera parameters
  * For the Logitech C920, you may choose to download the Logitech Gaming Software from the [Logitech website](http://support.logitech.com/en_us/product/hd-pro-webcam-c920/downloads#macPnlBar).
* Use the application to modify camera parameters to make the image darker
  * Use the sliders to change the exposure, aperture, and other parameters to dim the image. When the image is darker, less objects are in the field of view which enhances the detection. We suggest changing the parameters until the Spheros in the field of view are the only objects visible.
  * Note that if the image becomes too dark, the checkerboard detection section might fail to detect the checkerboard. It is advisable to make these camera parameter modifications after the checkerboard detection section.
* Modify the `CameraParam` object by modifying the `CameraCheckerboard_Ver1_2` function in the `Initialize camera and detect checkerboard`. Comment out the following section:
```
% Set camera properties
cam.Resolution = '640x480';
cam.Focus = 0;  
cam.Exposure = -11;
```
* Note that you should not modify the camera zoom through the downloaded application.
* Regarding the resolution of the webcam, the Logitch software does not allow users to change the aspect ratio. The image is 1920x1080, which results in a 16:9 image, which is wider than the required 4:3 image. When resizing the images in MATLAB, the image becomes distorted. When running formation control, this results in shapes looking imperfect. However, the package continues to operate. We recommend using a Windows computer instead.
* If a computer running macOS/OS X must be used, we recommend calibrating the camera on a Windows machine (to set the resolution to 640x480) then importing the resulting `.m` file.

### Camera Calibration Using MATLAB App
To calibrate the camera, follow these steps:
1. In the `APPS` tab, start the `Camera Calibrator` application.
2. Under `Add Images` from the top menu, select `From Camera`.
3. Click the new `Camera` tab on the top of the application.
4. On the left side, select the correct camera under `Camera` and the resolution to used under `Camera Properties`. We use 640x480 resolution in the package. Note: on macOS, the resolution may be fixed.
5. Set the `Save Location` to path/Calibration Images/cam_name. Here cam_name is just an identifier for the camera and its resolution.
6. Set `Capture Interval` and `Number of images to capture`, then hit the `Capture` button.
7. When you are done, a pop-up window will request the square size. Measure it and set the value. Also, note the value of the square size.
8. When the calibration is over, click on `Export Camera Parameters`. Save the data as a `.mat` file. Note the name of the file. Store the file in the corresponding folder in the `Calibration Images` directory. Use the existing calibration as an example.
For more information about the camera calibration, checkout the [Matlab Single Camera Calibrator App link](https://www.mathworks.com/help/vision/ug/single-camera-calibrator-app.html).

### Detecting Checkerboard with Multiple Computers
When using multiple computers, each computer will have a camera of its own.

Each computer may require a different calibration data file `.mat` file. For that, we propose the use of similar cameras for all computers. Usually, the intrinsic matrix obtained from the `.mat` file is similar for cameras of the same model.

The extrinsic matrix, however, differs based on the camera placement, so the detect_checkerboard camera must be executed on each computer. Moreover, all the computers must have the same world frame. Thus, before running this section, make sure that all computers are ready to execute it, place the checkerboard in the camera field of view, then run the section on all computers before removing the checkerboard. This ensures that all the computers have the same world frame.

### Theta0 Estimation
As explained before, the initial heading of the robots is not known and it changes every time the robots starts. Thus, every time a robot starts up, its initial heading with respect to the world frame must be estimated.
The way the current initial heading estimation algorithm works is by sending each Sphero robot a command to move forward with zero heading angle relative to its own frame. Its motion is recorded and an estimate of the initial heading is calculated.

The current algorithm runs through the robots one by one. The LEDs on all robots are turned off, then one at a time, the LEDs are turned on, the robot moves forward, its motion is recorded and its heading is estimated. The script will inform the user about the robot whose initial heading will be estimated, and will prompt the user to press a button to start the robot's motion.

Note that any interference from similar color in the camera's field of view affects this estimate. As a result, the package might fail at controlling the robot.

## License
MIT License

Copyright (c) 2018 Kaveh Fathian, Sleiman Safaoui

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
