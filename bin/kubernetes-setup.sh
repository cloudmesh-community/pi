#!/usr/bin/env bash
# Install requirements for Kubernetes on Raspberry Pi
# usage:
# kubernetes-setup.sh
# Examples:
#   sudo kubernetes-setup.sh

# Install Docker
# This is currently installing a version of docker that is not supported by
# kubernetes on the Pi
#curl -sSL get.docker.com \
  #| sh \
  #&& usermod pi -aG docker

# sudo apt-get update
# sudo apt-get install -y software-properties-common

# echo "deb https://apt.dockerproject.org/repo debian-jessie main" > /etc/apt/sources.list.d/docker.list
# apt-get update

# sudo apt-get install -y docker-ce=17.12.1~ce-0~debian

# This might have worked
# sudo apt-get install docker.io
# docker -v 1.8.3

# curl -fsSL https://apt.dockerproject.org/gpg | sudo apt-key add -
# sudo apt-get install docker-engine=1.13.1-0~debian-jessie

# This is test 10
# This installs add-apt-repository
# sudo apt-get install -y software-properties-common
# curl -fsSL https://download.docker.com/linux/raspbian/gpg | sudo apt-key add -
# sudo add-apt-repository \
   # "deb [arch=armhf] https://download.docker.com/linux/raspbian \
   # $(lsb_release -cs) \
   # stable"

# Test 11
# /etc/apt/sources.list.d/docker.list with deb https://apt.dockerproject.org/repo/ raspbian-jessie main

# This works but gets a warning
# sudo apt-get install docker-ce=18.03.0~ce-0~raspbian
# This one still gets a warning
# sudo apt-get install docker-ce=17.12.1~ce-0~raspbian


# This works but how do we get back to the point of having these repos...?
# sudo apt-get install docker-ce=18.06.0~ce~3-0~raspbian

echo "deb [arch=armhf] https://download.docker.com/linux/raspbian stretch stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get install -y --allow-unauthenticated docker-ce=18.06.1~ce~3-0~raspbian



# Disable Swap
sudo dphys-swapfile swapoff && \
  sudo dphys-swapfile uninstall -qy && \
  sudo update-rc.d dphys-swapfile remove
echo Adding " cgroup_enable=cpuset cgroup_enable=1 cgroup_enable=memory" to /boot/cmdline.txt
cp /boot/cmdline.txt /boot/cmdline_backup.txt

orig="$(head -n1 /boot/cmdline.txt) cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory"
echo "$orig" | tee /boot/cmdline.txt

# Add repo list and install kubeadm
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
  echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update -q && \
  sudo apt-get install -qy kubeadm

echo "You must now reboot. This can be done with the command:"
echo "sudo reboot"
