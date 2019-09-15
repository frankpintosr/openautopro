# Customizations for my OpenAuto Pro based Carputer
This repository holds all customization, files and scripts for my OpenAuto Pro based Carputer. I am currently running and testing this code on a Raspberry Pi 4 Model B with Raspbian Buster OS.  If your not sure what version your running, please refer to the Additional Information section below.  

## How to use the script
* Download the script to your RPI
```
sudo wget -O /home/pi/Downloads/oa_postinstall.sh https://github.com/frankpintosr/openautopro/raw/master/oa_postinstall.sh
```
* Change to the directory where you downloaded the script
```
cd /home/pi/Downloads
```
* Run the script from the CLI
```
sudo ./oa_postinstall.sh
```
**_Note: Do not use "sh oa_postinstall.sh" because is breaks the script_**

## Additional Information
### What hardware and OS versions are you Running? <br>
To determine what OS version you are running execute the following at the command line interface (CLI)
```
lsb_release -a
```
At the bottom of the result from running the lsb_release command you will find something like what is shown below.
>No LSB modules are available. <br>
>Distributor ID:	Raspbian <br>
>Description:	Raspbian GNU/Linux 10 (buster) <br>
>Release:	10 <br>
>Codename:	buster <br>

To determine what hardware version you are running execute the following at the command line interface (CLI)
```
cat /proc/cpuinfo
```
At the bottom of the result from running the cpuinfo command you will find something likse what is shown below.  We are only interested in the Hardware and Revision fields.  Copy and paste both into a search engine and find what RPi you are using.
>Hardware	: BCM2835 <br>
>Revision	: c03111 <br>
>Serial		: 100000000000****  (My actual number is obfuscated) <br>

## Mentions
**Thank you to all the various contributors and blogs which added to this project!** <br>
Please find my Github repository here: https://github.com/frankpintosr <br>
Bluewave Studio (OpenAuto Pro) http://bluewavestudio.io <br>
Novaspirit.com https://www.novaspirit.com/2017/02/23/desktop-widget-raspberry-pi-using-conky/ <br>
Brenden Matthews https://github.com/brndnmtthws/conky <br>
Sahaj Sarup https://github.com/ric96/zram <br>
Björn Biesenbach https://github.com/elmo2k3/dabpi_ctl <br>
Vinny https://www.kubuntuforums.net/showthread.php/73166-Pulse-audio-problem?p=411532&viewfull=1#post411532 <br>
Doug Hadfield https://www.raspberrypi.org/forums/viewtopic.php?t=161133#p1043263 <br>
Gary Dalton http://www.intellamech.com/RaspberryPi-projects/rpi3_gps.html <br>
