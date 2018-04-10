#!/bin/bash

if [ $# -ne 1 ]; then
  echo "You have to input one parameter, either 200 or 331"
  exit 0
fi

if [ $1 == 200 ]; then
  if [ -z "$(lspci -v | grep 'Subsystem: ESD Electronic System Design GmbH Device 0009')" ]; then
    if [ -z "$(lspci -v | grep 'Subsystem: ESD Electronic System Design GmbH Device 0004')" ]; then
      echo "PCI 200/266 series board can't be found in PC"
      exit 0
    fi
  fi

# To disable SocketCan driver for PCI200 series boards, add "blacklist plx_pci" in /etc/modprobe.d/blacklist.conf
  if [ -z "$(cat /etc/modprobe.d/blacklist.conf | grep 'blacklist plx_pci')" ]; then
    echo "start to add an line of 'blacklist plx_pci' in /etc/modprobe.d/blacklist.conf"
    sudo sh -c "echo 'blacklist plx_pci' >> /etc/modprobe.d/blacklist.conf"
    echo "'blacklist plx_pci' has been added into /etc/modprobe.d/blacklist.conf, please reboot linux first, and then run this script again."
    sudo reboot
    exit 0
  fi

  if [ ! -L "/usr/local/sbin/cantest" ]; then
    if [ -f "$HOME/esdcan-pci200-linux-2.6.x-x86-3.10.1/bin32/cantest" ]; then
      echo "start to creat a soft link file for cantest"
      sudo ln -s ~/esdcan-pci200-linux-2.6.x-x86-3.10.1/bin32/cantest /usr/local/sbin/cantest
    fi
  fi

  if [ -z "$(ldconfig -p | grep esdcan-pci200)" ]; then
    echo "start to add the path of ~/esdcan-pci200-linux-2.6.x-x86-3.10.1/lib32/ into /etc/ld.so.conf "
    sudo sh -c "echo $HOME/esdcan-pci200-linux-2.6.x-x86-3.10.1/lib32/ >> /etc/ld.so.conf"
    echo "start to add the path of ~/esdcan-pci200-linux-2.6.x-x86-3.10.1/lib32/ into /etc/ld.so.cache"
    sudo ldconfig
  fi


  if [ -f "$HOME/esdcan-pci200-linux-2.6.x-x86-3.10.1/src/esdcan-pci200.ko" ]; then
    if [ -z "$(lsmod | grep esdcan_pci200)" ]; then 
      echo "start to insmod esdcan-pci200.ko"
      sudo insmod $HOME/esdcan-pci200-linux-2.6.x-x86-3.10.1/src/esdcan-pci200.ko
    fi
  fi

  if [ ! -c "/dev/can0" ]; then
    echo "start to mknod /dev/can0 with major=54 and minor=0"
    sudo mknod --mode=a+rw /dev/can0 c 54 0
  fi

  echo "PCI200 setup complete." && exit 0

elif [ $1 == 331 ]; then

  if [ -z "$(lspci -v | grep 'Subsystem: ESD Electronic System Design GmbH Device 0001')" ]; then
    echo "PCI 331 series board can't be found in PC"
    exit 0
  fi

  if [ ! -L "/usr/local/sbin/cantest" ]; then
    if [ -f "$HOME/esdcan-pci331-linux-2.6.x-x86-3.10.1/bin32/cantest" ]; then
      echo "start to creat a soft link file for cantest"
      sudo ln -s ~/esdcan-pci331-linux-2.6.x-x86-3.10.1/bin32/cantest /usr/local/sbin/cantest
    fi
  fi

  if [ -z "$(ldconfig -p | grep esdcan-pci331)" ]; then
    echo "start to add the path of ~/esdcan-pci331-linux-2.6.x-x86-3.10.1/lib32/ into /etc/ld.so.conf "
    sudo sh -c "echo $HOME/esdcan-pci331-linux-2.6.x-x86-3.10.1/lib32/ >> /etc/ld.so.conf"
    echo "start to add the path of ~/esdcan-pci331-linux-2.6.x-x86-3.10.1/lib32/ into /etc/ld.so.cache"
    sudo ldconfig
  fi


  if [ -f "$HOME/esdcan-pci331-linux-2.6.x-x86-3.10.1/src/esdcan-pci331.ko" ]; then
    if [ -z "$(lsmod | grep esdcan_pci331)" ]; then
      echo "start to insmod esdcan-pci331.ko" 
      sudo insmod $HOME/esdcan-pci331-linux-2.6.x-x86-3.10.1/src/esdcan-pci331.ko
    fi
  fi

  if [ ! -c "/dev/can1" ]; then
    echo "start to mknod /dev/can1 with major=50 and minor=0"
    sudo mknod --mode=a+rw /dev/can1 c 50 0
  fi

  echo "PCI331 setup complete." && exit 0

else

  echo "You have to input one parameter, either 200 or 331"
fi
