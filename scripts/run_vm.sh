#!/bin/bash

run_vm() {
    echo "Running VM '${NAME}'...."
    nohup qemu-system-x86_64 "${VM_MEM[@]}" "${VM_SMP[@]}" "${VM_BOOT[@]}" "${VM_DRIVE[@]}" "${VM_NETDEV[@]}" "${VM_DEVICE[@]}" "${VM_DISPLAY[@]}" "${VM_VGA[@]}" \
        > "${VM_DIR}/${NAME}.log" 2>&1 </dev/null & 

    echo $! > "${VM_DIR}/${NAME}.pid"
}
