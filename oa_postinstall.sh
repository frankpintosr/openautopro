#!/bin/bash
# This script is designed to perform all the post OS install configuration steps for an OpenAuto Pro install
# It was developed and tested on a Raspberry Pi 4 Model B with Raspbian Buster OS
# For more information visit https://github.com/frankpintosr

#--------Check and install updates
sudo sh -c "apt-get -y update && apt-get -y dist-upgrade && apt-get -y autoremove"

#--------Enable NTFS and exFat
sudo apt-get install exfat-fuse exfat-utils
sudo apt-get install ntfs-3g

#--------The Next section is for the GPS Install
#Installs gpsd clients
sudo apt-get -y install gpsd gpsd-clients python-gps
#Disable the gpsd systemd service
sudo systemctl stop -q gpsd.socket
sudo systemctl disable -q gpsd.socket
#Now the gpsd needs to be started and pointed at the UART
sudo killall gpsd
sudo gpsd /dev/ttyS0 -F /var/run/gpsd.sock
#Disable the serial getty service
sudo systemctl stop -q serial-getty@ttyS0.service
sudo systemctl disable -q serial-getty@ttyS0.service

#--------Enable UART
sudo cp /boot/config.txt /boot/config.txt.backup
sudo wget -O /boot/config.txt https://raw.githubusercontent.com/frankpintosr/openautopro/master/config.txt
sudo cp /boot/cmdline.txt /boot/cmdline.txt.backup
sudo wget -O /boot/cmdline.txt https://raw.githubusercontent.com/frankpintosr/openautopro/master/cmdline.txt
#Connect uart with gpsd
sudo killall gpsd
sudo gpsd /dev/ttyS0 -F /var/run/gpsd.sock
#Start at boot
sudo cp /etc/default/gpsd /etc/default/gpsd.backup
sudo wget -O /etc/default/gpsd https://raw.githubusercontent.com/frankpintosr/openautopro/master/gpsd
sudo systemctl enable -q gpsd.socket
sudo systemctl start -q gpsd.socket

#--------Enable the Real Time Clock
#Replace your /lib/udev/hwclock-set
sudo cp /lib/udev/hwclock-set /lib/udev/hwclock-set.backup
sudo wget -O /lib/udev/hwclock-set https://raw.githubusercontent.com/frankpintosr/openautopro/master/hwclock-set
#Remove fake-hwclock
sudo apt-get -y remove fake-hwclock
sudo update-rc.d -f fake-hwclock remove
sudo systemctl disable -q fake-hwclock
#Write the system time to the RTC
sudo hwclock -w
#Set the system time from the RTC
sudo hwclock -s

#--------Install desktop performance widget Conky
sudo apt-get -y install conky
sudo wget -O /home/pi/.conkyrc https://raw.githubusercontent.com/frankpintosr/openautopro/master/rpi3_conkyrc
sudo wget -O /usr/bin/conky.sh https://raw.githubusercontent.com/frankpintosr/openautopro/master/conky.sh
sudo wget -O /etc/xdg/autostart/conky.desktop https://raw.githubusercontent.com/frankpintosr/openautopro/master/conky.desktop
#Create Start Menu Item
sudo wget -O /usr/share/applications/conky.desktop https://raw.githubusercontent.com/frankpintosr/openautopro/master/conky.desktop

#--------Install PulseAudio EQ
sudo apt-get -y install pulseaudio-equalizer
#Config file
sudo cp /etc/pulse/default.pa /etc/pulse/default.pa.backup
sudo wget -O /etc/pulse/default.pa https://raw.githubusercontent.com/frankpintosr/openautopro/master/default.pa
pulseaudio -k && pulseaudio -D
#Create Start Menu Item with icon
sudo wget -O /usr/share/doc/pulseaudio-equalizer/pulseaudio.png https://raw.githubusercontent.com/frankpintosr/openautopro/master/pulseaudioeq.png 
sudo wget -O /usr/share/applications/paeq.desktop https://raw.githubusercontent.com/frankpintosr/openautopro/master/paeq.desktop

#--------Install Bluetooth Manager GUI
sudo apt-get -y install bluetooth bluez blueman

#--------Install and Configure ZRAM
#Download ZRAM script
sudo wget -O /usr/bin/zram.sh https://raw.githubusercontent.com/frankpintosr/openautopro/master/zram.sh
#Set user executable permissions
sudo chmod +x /usr/bin/zram.sh
#Download the rc.local file
sudo cp /etc/rc.local /etc/rc.local.backup
sudo wget -O /etc/rc.local https://raw.githubusercontent.com/frankpintosr/openautopro/master/rc.local

#--------Install and Configure Navit
#Install Navit and prepare folders for map file
#sudo apt-get -y install navit espeak
#mkdir ~/.navit
#mkdir ~/maps
#sudo wget -O ~/.navit/navit.xml https://raw.githubusercontent.com/frankpintosr/openautopro/master/navit.xml
#read -sp "Press Enter to continue after going to http://maps9.navit-project.org and saving your mapfile to /home/pi/maps" 
#mv /home/pi/maps/*.bin /home/pi/maps/mapfile.bin
#sudo wget -O /usr/share/applications/navit.desktop https://raw.githubusercontent.com/frankpintosr/openautopro/master/navit.desktop

#--------Completion of script
read -sp "The OpenAuto Pro post-install script is complete. Press Enter to reboot the Raspberry Pi. "
sudo reboot now
