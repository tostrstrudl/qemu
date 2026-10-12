#!/bin/bash
CONFIG=${QEMU_HOME}/qemu.conf
SCRIPTS=${QEMU_HOME}/scripts
ACTION=$1
NAME=$2

# action [ "build", "run", "delete" ]
# name [ "arch", "ubuntu", "kali" ]
# drive [ "????" ] -- this is the raw or .qcow2 image
# disk [ "????" ] -- this is the .iso; only used for building

if [ ! -e "$CONFIG" ]; then
    echo "Configuration file doesn't exist. Creating 'qemu.conf'...."
    touch ${QEMU_HOME}/qemu.conf
    echo "Configuration file created."
else
    source ${CONFIG}
fi

for SCRIPT in "${SCRIPTS}"/*.sh; do
    source ${SCRIPT}
done

VM_DIR="${INSTALL_PATH}/${NAME}"
VM_CONF_DIR="${VM_DIR}/${NAME}.conf"

# I would like to have each drive save into the respective variables for later
#       and quicker use 

if [ "$ACTION" = "build" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Error: build expects 1 arguments, got $(($# - 1))"
        exit 1
    fi
    
    echo "Commencing build."
    setup_env
    create_disk
    build_vm

elif [ "$ACTION" = "run" ]; then
    if [ "$#" -ne 2 ]; then
        echo "Error: run expects 1 argument, got $(($# - 1))"
        exit 1
    fi

    echo "Verifying existence of VM '${NAME}'...."
    if [ ! -d "$VM_DIR" ]; then
        echo "This VM doesn't exist."
        exit 1
    else
        echo "VM '${NAME}' found."
    fi
    
    echo "Loading ${NAME}.conf...."
    source "$VM_CONF_DIR"
    run_vm


elif [ "$ACTION" = "delete" ]; then
    if [ ! "$#" -gt 1 ]; then
        echo "Error: delete expects at least 1 VM name, got 0"
        exit 1
    fi

    if [ ! -d "$VM_DIR" ]; then
        echo "VM '${NAME}' does not exist. Nothing to delete. Exiting...."
        exit 1
    else
        rm -rf "$VM_DIR"
        echo "VM '${NAME}' has been deleted."
    fi

else
    echo "${ACTION} is not a valid option"
    exit 1
fi

exit 0
