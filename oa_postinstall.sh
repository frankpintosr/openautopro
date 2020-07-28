#!/bin/bash
# This script is designed to perform all the post OS install configuration steps for an OpenAuto Pro install
# It was developed and tested on a Raspberry Pi 4 Model B with Raspbian Buster OS
# For more information visit https://github.com/frankpintosr

#--------Gather updated Configuration Files
sudo cp /boot/config.txt /boot/config.txt.backup
sudo wget -O /boot/config.txt https://github.com/frankpintosr/openautopro/raw/master/config.txt
sudo cp /boot/cmdline.txt /boot/cmdline.txt.backup
sudo wget -O /boot/cmdline.txt https://github.com/frankpintosr/openautopro/raw/master/cmdline.txt

#--------Enable NTFS and exFat
sudo apt-get install exfat-fuse exfat-utils
sudo apt-get install ntfs-3g

#--------Check and install updates
sudo sh -c "apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove"

#--------The Next section is for the GPS Install [RPi4b]
#Installs gpsd clients
sudo apt-get -y install gpsd gpsd-clients python-gps
#Disable the gpsd systemd service
sudo systemctl stop -q gpsd.socket
sudo systemctl disable -q gpsd.socket
#Now the gpsd needs to be started and pointed at the UART
sudo killall gpsd
sudo gpsd /dev/ttyAMA0 -F /var/run/gpsd.sock
#Disable the serial getty service
sudo systemctl stop -q serial-getty@ttyAMA0.service
sudo systemctl disable -q serial-getty@ttyAMA0.service

#--------Enable UART [RPi4b]
#Connect uart with gpsd
sudo killall gpsd
sudo gpsd /dev/ttyAMA0 -F /var/run/gpsd.sock
#Start at boot
sudo cp /etc/default/gpsd /etc/default/gpsd.backup
sudo wget -O /etc/default/gpsd https://github.com/frankpintosr/openautopro/raw/master/gpsd
sudo systemctl enable -q gpsd.socket
sudo systemctl start -q gpsd.socket

#--------Enable the Real Time Clock
#Replace your /lib/udev/hwclock-set
sudo cp /lib/udev/hwclock-set /lib/udev/hwclock-set.backup
sudo wget -O /lib/udev/hwclock-set https://github.com/frankpintosr/openautopro/raw/master/hwclock-set
#Remove fake-hwclock
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo systemctl disable -q fake-hwclock
#Write the system time to the RTC
sudo hwclock -w
#Set the system time from the RTC
sudo hwclock -s

#--------Install Bluetooth Manager GUI
sudo apt-get -y install bluetooth bluez blueman

#--------Completion of script
read -sp "The OpenAuto Pro post-install script is complete. Press Enter to reboot the Raspberry Pi. "
sudo reboot now
