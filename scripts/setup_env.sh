#!/bin/bash

# 1. Checks to see if the VM directory exists; creates it if not
# 2. Finds the .iso image and moves it into the corresponding VM dir
# 3. Creates the VM .conf file

dir_check() {
    echo "Checking to see if directory for VM exists...."
    if [ -d "$VM_DIR" ]; then
        echo "Directory for '${NAME}' exits. Nothing to do here. Continuing."
        return 1
    else
        echo "VM does not exist. Continuing."
    fi
}

get_cdrom() {
    while true; do
        read -p "What is the .iso being used for this VM?: " ISO
        if [ -n "$ISO" ]; then
            ISO="${ISO/#\~/$HOME}"
            if [ ! -f "$ISO" ]; then
                echo "${ISO} does not exist."
                continue
            fi

            break
        fi
    done
}

mk_pop_dir() {
    echo "Making directory for '${NAME}'...."
    mkdir "$VM_DIR"
    if [ "$?" -ne "0" ]; then
        echo "Failed to make directory for '${NAME}'."
        return 1
    else
        echo "Directory created."
    fi

    echo "Moving .iso to VM folder...."
    mv "$ISO" "$VM_DIR"
    ISO="${VM_DIR}/$(basename ${ISO})"

    echo "Creating '${NAME}.conf'...."
    touch "$VM_CONF_DIR"

    echo "Updating VM .conf file...."
    {
        printf "%s\n" "VM_NAME=\"${NAME}\""
        printf "%s\n" "VM_CDROM=\"${ISO}\""
    } >> "$VM_CONF_DIR"
}

se_confirm_info() {
    while true; do
        echo "Pleae confirm your choices:"
        echo "1. VM Name: ${NAME}"
        echo "2. ISO Image: ${ISO}"
        echo "3. Confirm and continue."
        read -p "Please choose an option [1, 2, 3]: " OPT
        case "$OPT" in
            1)
                read -p "What would you like to name your VM (no spaces/special characters)?: " RENAME
                if [ -n "$RENAME" ]; then
                    NAME="${RENAME}"
                else
                    echo "VM Name remains '${NAME}'"
                fi
                ;;
            2)
                get_cdrom
                ;;
            3)
                break
                ;;
            *)
                echo "Please choose a valid option."
                ;;
        esac
    done
}
    
setup_env() {
    dir_check
    if [ ! "$?" = "0" ]; then
        return 1
    fi

    get_cdrom
    if [ ! "$?" = "0" ]; then
        return 1
    fi

    se_confirm_info
    mk_pop_dir
}
