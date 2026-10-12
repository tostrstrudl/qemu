#!/bin/bash

get_info() {
    while true; do
        read -p "What kind of disk image would you like (default is qcow2)? [raw, qcow2]: " FILE_FMT
        if [[ "$FILE_FMT" = "raw" || "$FILE_FMT" = "qcow2" ]]; then
            break
        elif [ -z "$FILE_FMT" ]; then
            FILE_FMT="${DEF_FILE_FMT}"
            break
        fi
        
        echo "Invalid disk type. Choose raw or qcow2."
    done

    read -p "What would you like to name your disk (default is 'disk')?: " FILE_NAME
    if [ -z "$FILE_NAME" ]; then
        FILE_NAME=${DEF_FILE_NAME}
    fi

    read -p "What size should the disk be (default is 10G)?: " FILE_SIZE
    if [ -z "$FILE_SIZE" ]; then
        FILE_SIZE=${DEF_FILE_SIZE}
    fi
}

cd_confirm_info() {
    while true; do
        echo "Does this information look correct? Pick a key to change or confirm."
        echo "1. Disk Type: ${FILE_FMT}"
        echo "2. Disk Name: ${FILE_NAME}"
        echo "3. Disk Size: ${FILE_SIZE}"
        echo "4. Confirm and continue"
        read -p "Please choose an option [1, 2, 3, 4]: " ANS
        case "$ANS" in
            1)
                read -p "Change disk type [raw, qcow2]: " TYPE_TMP
                if [[ "$TYPE_TMP" == "raw" || "$TYPE_TMP" == "qcow2" ]]; then
                    FILE_FMT=${TYPE_TMP}
                    echo "Disk Type changed to '${DISK_TYPE}'."
                else
                    echo "Disk Type remains '${FILE_FMT}'."
                fi
                ;;

            2)
                read -p "Change disk name: " NAME_TMP
                if [ -n "$NAME_TMP" ]; then
                    FILE_NAME=${NAME_TMP}
                    echo "Disk Name changed to '${FILE_NAME}'."
                else
                    echo "Disk Name remains '${FILE_NAME}'."
                fi
                ;;

            3)
                read -p "Change disk size: " SIZE_TMP
                if [ -n "$SIZE_TMP" ]; then
                    FILE_SIZE=${SIZE_TMP}
                    echo "Disk Size changed to ${FILE_SIZE}."
                else
                    echo "Disk Size remains ${FILE_SIZE}."
                fi
                ;;
            4)
                break
                ;;
            *)
                echo "Invalid option. Choose: 1, 2, 3, or 4."
                ;;
        esac 
    done

    # Make the appropriate var for the DRIVE option
    if [ "$FILE_FMT" = "raw" ]; then
        DISK_FILE="${VM_DIR}/${FILE_NAME}"
    else
        DISK_FILE="${VM_DIR}/${FILE_NAME}.${FILE_FMT}"
    fi

    # Fill the DRIVE options
    DRIVE_OPTS="file=${DISK_FILE},format=${FILE_FMT}"
    DRIVE=(-drive "${DRIVE_OPTS}")
    
    echo "Updating VM .conf file...."
    {
        printf "%s\n" "VM_FILE_FMT=\"${FILE_FMT}\""
        printf "%s\n" "VM_FILE_NAME=\"${FILE_NAME}\""
        printf "%s\n" "VM_FILE_SIZE=\"${FILE_SIZE}\""
        printf "%s\n" "VM_FILE=\"${DISK_FILE}\""
        printf 'VM_DRIVE=(-drive %q)\n' "${DRIVE_OPTS}"
    } >> $VM_CONF_DIR
}

create_disk() {
    get_info
    cd_confirm_info

    echo "Creating disk...."
    qemu-img create -f "$FILE_FMT" "${DISK_FILE}" "$FILE_SIZE"
}

