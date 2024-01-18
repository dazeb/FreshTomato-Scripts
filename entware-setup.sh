#!/bin/sh

# Define constants
USB_DEVICE=""
PARTITION=""
UUID=""
LOG_FILE="/tmp/entware_setup.log"

# Function to log messages
log_message() {
    echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" | tee -a $LOG_FILE
}

# Function to detect the USB device
detect_usb_device() {
    USB_DEVICE=$(ls /dev/sd[a-z] | head -n 1)
    if [ -z "$USB_DEVICE" ]; then
        log_message "No USB storage device detected. Please ensure your USB device is connected."
        return 1
    fi
    log_message "Detected USB storage device: $USB_DEVICE"
}

# Function to create partition and filesystem
create_partition_and_filesystem() {
    log_message "Creating a new partition table and partition on $USB_DEVICE..."
    (echo o; echo n; echo p; echo 1; echo; echo; echo w) | /sbin/fdisk $USB_DEVICE
    if [ $? -ne 0 ]; then
        log_message "Failed to create partition table."
        return 1
    fi

    PARTITION="${USB_DEVICE}1"
    log_message "Formatting the new partition $PARTITION..."
    /usr/sbin/mkfs.ext4 -L ENTWARE -O^metadata_csum $PARTITION
    if [ $? -ne 0 ]; then
        log_message "Failed to format partition."
        return 1
    fi
}

# Function to set up fstab and autorun scripts
setup_fstab_and_autorun() {
    UUID=$(/sbin/blkid -s UUID -o value $PARTITION)
    if [ -z "$UUID" ]; then
        log_message "Failed to retrieve UUID for $PARTITION."
        return 1
    fi
    log_message "UUID of new partition is $UUID"

    log_message "Adding mount entry to /etc/fstab..."
    echo "UUID=$UUID /opt ext4 rw,noatime 0 2" >> /etc/fstab

    log_message "Creating Entware service scripts..."
    cat > /opt/mount.autorun <<EOF
#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause
/usr/bin/logger -t Entware "Starting Entware services..."
if [ -x /opt/etc/init.d/rc.unslung ]; then
  /opt/etc/init.d/rc.unslung start
fi
exit 0
EOF
    chmod 0755 /opt/mount.autorun

    cat > /opt/unmount.autostop <<EOF
#!/bin/sh
# SPDX-License-Identifier: BSD-2-Clause
if [ -x /opt/etc/init.d/rc.unslung ]; then
  /opt/etc/init.d/rc.unslung stop
fi
/bin/umount /opt || /bin/umount -l /opt
exit 0
EOF
    chmod 0755 /opt/unmount.autostop
}

# Function to install Entware
install_entware() {
    log_message "Installing Entware..."
    /usr/bin/wget -O- http://bin.entware.net/armv7sf-k3.7/installer/generic.sh | sh
    if [ $? -ne 0 ]; then
        log_message "Failed to install Entware."
        return 1
    fi
}

# Main script execution
log_message "Starting Entware setup..."
detect_usb_device || exit 1

# Confirm with the user before proceeding
echo "This will format $USB_DEVICE and all data will be lost. Are you sure you want to proceed? (y/n)"
read -r confirm
if [ "$confirm" != "y" ]; then
    log_message "User aborted the setup."
    exit 1
fi

create_partition_and_filesystem || exit 1
setup_fstab_and_autorun || exit 1

# Prompt user to reboot and continue with installation
echo "Setup is complete. Please reboot the router now."
echo "After rebooting, connect via SSH and run the following command to complete the Entware installation:"
echo "sh /path/to/this/script --install-entware"

# Check for command line argument to continue with Entware installation
if [ "$1" = "--install-entware" ]; then
    install_entware || exit 1
    log_message "Entware installation complete. Please verify by running 'opkg list'."
fi
