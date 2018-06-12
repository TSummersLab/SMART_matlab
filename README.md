# Sphero Matlab
The Sphero Matlab platform is developed at the University of Texas at Dallas (UTD). The sphero_matlab package, which relies on the Matlab [Sphero Connectivity Package](https://www.mathworks.com/matlabcentral/fileexchange/52481-sphero-connectivity-package), provides a platform to control a group of Sphero robots, in a centralized or distributed manner, and monitoring the robots through a webcam. The package is used to collect experimental results for novel control algorithms.

## About the Spheros
The Sphero robot is small sized spherical robot. It has two motors that roll on the internal walls of its plastic waterproof shell allowing the robot to move. When the robot starts, its current heading, is set to be its reference heading. Thus, every time the robot starts it has a new reference angle. The robots use Bluetooth technology for their wireless communications.

## Requirements
The package requirements can be divided into three categories:
* Operating System:
  * Windows:
    * The platform has been tested with Windows 7 and Windows 10. The package runs normally on either operating system
  * macOS:
    * With some modifications, the platform can run on computers running MacOS. The package was used on OS X 10.11 (El Capitan) and macOS 10.12 (Sierra) and 10.13 (High Sierra). The required changes are explained in the [Getting Started section](#getting-started)
* Software:
  * Matlab:
    * The package has been tested with Matlab R2017a and R2017b. The additional required Toolboxes are:
      * Computer Vision System Toolbox
      * Image Acquisition Toolbox
      * Image Processing Toolbox
      * Instrument Control Toolbox
      * MATLAB Support Packages for USB Webcams
      * **(check if there are any more)**
  * CVX:
    * The package uses CVX as its convex optimization tool. CVX is not provided in this repository, but should be downloaded and added to the root of the repository. See the [Getting Started section](#getting-started) for more details.
* Hardware:
  * Computer(s):
    * The package requires at least one computer to run. It has been tested with up to three computers running the same experiment session together. Tested computers include:
      * Dell (Kaveh_work) **(FILL IN DETAILS)**
      * Dell (Kaveh_) **(FILL IN DETAILS)**
      * Dell (Willy) **(FILL IN DETAILS)**
      * Dell Latitude E7470 with an Intel Core i7-6600U processor (Windows 10)
      * Macbook Pro (Mid 2014) with an Intel Core i7-4870HQ processor (macOS 10.13)
      * Microsoft Surface **(FILL IN DETAILS)** (Windows 10)
  * Camera:
    * The platform uses a camera to locate the robots. The platform was tested with the following cameras:
      * Logitech C920 Webcam
  * Tripod:
    * To fix the location of the camera and place it at a higher height, a tripod might be necessary.
  * Calibration board:
    * To calibrate the camera a non-square checkerboard patter is required
  * Sphero robots:
    * The platform uses the Matlab Sphero Connectivity Package to communicate with the Sphero robots. However, it cannot support Spheros with BLE (Bluetooth Low Energy) technology. Thus, the platform can only support the following robots:
      * Sphero SPRK robots (discontinued)
      * Sphero 2.0 robots (used to test this package)
  * Bluetooth dongle:
    * If the computer is not equipped with a Bluetooth module, a Bluetooth dongle is required. Older machines may also benefit from a new and faster Bluetooth dongle. **provide link**
  * Black cloth:
    * The platform uses color based detection to recognize the Spheros. It is preferred to have a black or dark background to avoid false positives. We chose to place a piece of black cloth in the camera's field of view to control the environment background.


## Package Operation Outline
When the package runs on a computer, it primarily operates as follows:
1. Connecting to the Spheros
2. Calibrating the Camera
3. Estimating the reference heading of the Spheros
4. Communicating with other computers and tagging the Spheros
5. Controlling the Spheros
  - tagging them
  - tracking them over time
  - estimating their heading
  - sending them control commands
More details will be explained in the [Getting Started section](#getting-started).

## Platform Capabilities
The platform is capable of controlling multiple robots at the same time. While each computer can only connect to a maximum of 7 robots because of Bluetooth limitations, we have observed that 6 robots is the practical limit and 4 robots is ideal for more powerful computers. The number of robots, the time it takes for the Sphero Connectivity Package to connect to them, and the stability of the connection are all dependent on the Bluetooth module used and the computer's capabilities. For example, a Microsoft Surface tablet can connect reliably to two robots, the Dell Latitude E7470 computer could handle 4 Spheros normally. Machines with older hardware performed better with a USB Bluetooth dongle.

The number of Spheros controlled can be increased by using multiple computers connected to the same WiFi Network. The computers would only communicate once to sync the Sphero tags. From thereon, the computers can run independently. Thus, in addition to centralized control algorithm, the platform can be used to test distributed control algorithms.

The platform uses a webcam per computer to locate the Spheros. While this works well, it does restrict the operation region of the Spheros to the field of view of the camera or the intersection of the field of views of the cameras in case multiple cameras were used.

The platform uses color based detection to locate the robots. This allows the platform to separate Spheros by color in case multiple teams are formed to test control algorithms related to game theory. However, color based detection is prone to detecting false positives. Thus, the field of view of each camera must be free of interference. This also forces the background to be dark. Color based detection also limits the separation between robots. When robots of the same colors intersect, they individual robots can no longer be identified.

## Package Organization
The folders of the repository are:
* Calibration images
  * Contains folders with the calibration data (.m data file and pictures used for calibrating the camera)
* CVX
  * While the folder does not come with the repository, it will be added in the [Getting Started section](#getting-started).
  * Contains the files necessary to use the CVX tool
* EKF
  * Contains Matlab scripts for the extended Kalman filter
* Formation Control
  * Contains Matlab scripts and functions to determine the control signal when using a distributed formation control algorithm.
  * This file is not necessary for the package. It is one application that uses the package and serves as an example to show how the package can be used.
* Helpers
  * The folder contains the Matlab functions and scripts used by the scripts that runs the package.
* Sphero
  * Contains the Matlab Sphero Connectivity Package.
  * Using a newer version of this package may be possible, but it has not been tested.
The script that runs the package is `Main_Ver_1_3.m`.

## Getting Started

## Useful Resources

## Potential Problems

## Acknowledgements








# .
