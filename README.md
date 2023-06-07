# Casi Local Installation
After running these script files, the entire casi system will be installed and run on your local machine
## Description
When the script file is run, the docker software will be installed according to the OS. If it is already installed, that step will be skipped and casi system will start running on docker desktop.
## Table of contents
* [Installation](#installation)
* [Usage](#usage)
## Installation
### Linux / MacOS
1. Download and extract a ZIP file.
* [casi-setup-linux.sh](https://drive.google.com/file/d/1aWJg82h1IydjDT9zm-13rHEMnMo0939W/view)
2. Navigate to the directory where the sh file is located: Use the cd command to change to the appropriate directory.
3. Run this command
 #### chmod +x casi-setup-linux.sh 
4. Run the sh file: Execute the bash script by typing its name (including the file extension) and pressing Enter.
 #### ./casi-setup-linux.sh
### Windows
1. Download and extract a ZIP file.
* [casi-setup-windows.ps1](https://drive.google.com/file/d/19In_NotRdIwmptEMliWtnzcxTJ9E2KOG/view?usp=sharing)
2. Set Execution Policy (if required): If your system has a restricted execution policy that prevents running scripts, you may need to change the execution policy. To do so, run PowerShell as an administrator and execute the following command:
 #### Set-ExecutionPolicy RemoteSigned
3. Navigate to the directory where the ps1 file is located: Use the cd command to change to the appropriate directory.
4. Run this command
 #### .\casi-setup-windows.ps1


