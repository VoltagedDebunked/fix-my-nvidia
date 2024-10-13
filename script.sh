#!/bin/bash

# Function to check the distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    else
        echo "unknown"
    fi
}

# Update system packages
update_system() {
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
}

# Install necessary packages for building drivers and pciutils
install_build_packages() {
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
}

# Identify GPU
identify_gpu() {
    lspci | grep -i nvidia
}

# Remove old drivers
remove_old_drivers() {
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
}

# Install NVIDIA drivers
install_nvidia_drivers() {
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
}

# Generate Xorg configuration
configure_xorg() {
    sudo nvidia-xconfig
}

# Main script execution
distro=$(detect_distro)

echo "Updating system..."
update_system "$distro"

echo "Installing build packages and pciutils..."
install_build_packages "$distro"

echo "Identifying GPU..."
identify_gpu

echo "Removing old drivers..."
remove_old_drivers "$distro"

echo "Installing NVIDIA drivers..."
install_nvidia_drivers "$distro"

echo "Configuring Xorg..."
configure_xorg

echo "Rebooting system..."
sudo reboot
