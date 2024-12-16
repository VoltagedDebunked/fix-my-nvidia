#!/bin/bash

# Function to check the distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "Fix-my-nvidia can NOT detect current system"
    fi
}

# Update system packages
update_system() {

if [ -z "$1" ]; then
    echo "No arguments found."
    echo "Try running './script.sh ubuntu', or whatever distribution you have."
    exit 1
else
    case "$1" in
        ubuntu|debian)
            sudo apt update && sudo apt upgrade -y
            ;;
        fedora)
            sudo dnf upgrade -y
            ;;
        arch)
            sudo pacman -Syu
            ;;
        *)
            echo "Unsupported distribution"
            exit 1
            ;;
    esac
fi
}

# Install necessary packages for building drivers and pciutils
install_build_packages() {
if [ -z "$1" ]; then
    echo "No arguments found."
    echo "Try running './script.sh ubuntu', or whatever distribution you have."
    exit 1
else
    case "$1" in
        ubuntu|debian)
            sudo apt install build-essential linux-headers-$(uname -r) pciutils -y
            ;;
        fedora)
            sudo dnf install @development-tools kernel-devel pciutils -y
            ;;
        arch)
            sudo pacman -S base-devel linux-headers pciutils --noconfirm
            ;;
    esac
    fi
}

# Identify GPU
identify_gpu() {
    lspci | grep -i nvidia
}

# Remove old drivers
remove_old_drivers() {
if [ -z "$1" ]; then
    echo "No arguments found."
    echo "Try running './script.sh ubuntu', or whatever distribution you have."
    exit 1
else
    case "$1" in
        ubuntu|debian)
            sudo apt remove --purge '^nvidia-.*' '^libnvidia-.*' '^xserver-xorg-video-nouveau' -y
            ;;
        fedora)
            sudo dnf remove '*nvidia*' 'xorg-x11-drv-nouveau' -y
            ;;
        arch)
            sudo pacman -Rns nvidia nvidia-utils --noconfirm
            ;;
    esac
fi
}

# Install NVIDIA drivers
install_nvidia_drivers() {
if [ -z "$1" ]; then
    echo "No arguments found."
    echo "Try running './script.sh ubuntu', or whatever distribution you have."
    exit 1
else
    case "$1" in
        ubuntu|debian)
            sudo add-apt-repository ppa:graphics-drivers/ppa -y
            sudo apt update
            sudo apt install nvidia-driver-<version> -y  # Replace <version> with desired version
            ;;
        fedora)
            sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda -y
            ;;
        arch)
            sudo pacman -S nvidia nvidia-utils --noconfirm
            ;;
    esac
fi
}

# Generate Xorg configuration
configure_xorg() {
    sudo nvidia-xconfig
}

# Main script execution
echo "Updating system..."
update_system "$1"

echo "Installing build packages and pciutils..."
install_build_packages "$1"

echo "Identifying GPU..."
identify_gpu

echo "Removing old drivers..."
remove_old_drivers "$1"

echo "Installing NVIDIA drivers..."
install_nvidia_drivers "$1"

echo "Configuring Xorg..."
configure_xorg

echo "Rebooting system..."
sudo reboot
