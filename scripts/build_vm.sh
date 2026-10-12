#!/bin/bash
get_net_opts() {
    # NETDEV Backends:
    #   user
    #   tap
    #   bridge
    #   socket
    #   stream
    #   dgram
    #   vde
    #   hubport
    #   passt
    #   l2tpv3
    #   vhost-user
    #   vhost-vdpa
    #   netmap
    #   af-xdp
    read -p "Specify your network mode (default is 'user'): " NET_MODE
    if [ -z "$NET_MODE" ]; then
        NET_MODE="${DEF_NET_MODE}"
    fi

    read -p "Specify the network ID (default is 'net0'): " NET_ID
    if [ -z "$NET_ID" ]; then
        NET_ID="${DEF_NET_ID}"
    fi

    echo "Updating VM .conf file...."
    {
        printf "%s\n" "VM_NET_MODE=\"${NET_MODE}\""
        printf "%s\n" "VM_NET_ID=\"${NET_ID}\""
    } >> "$VM_CONF_DIR"

    read -p "Would you like to setup port-forwarding? [y, n]: " PORT_FWD
    if [ "$PORT_FWD" = "y" ]; then
        read -p "Specify the protocol (default is TCP): " PF_PROTO
        if [ -z "$PF_PROTO" ]; then
            PF_PROTO="${DEF_PF_PROTO}"
        fi

        read -p "Specify the host port (default is 2222): " PF_HPORT
        if [ -z "$PF_HPORT" ]; then
            PF_HPORT="${DEF_PF_HPORT}"
        fi

        read -p "Specify the guest port (default is 22): " PF_GPORT
        if [ -z "$PF_GPORT" ]; then
            PF_GPORT="${DEF_PF_GPORT}"
        fi

        echo "Updating VM .conf file...."
        {
            printf "%s\n" "VM_PF_PROTO=\"${PF_PROTO}\""
            printf "%s\n" "VM_PF_HPORT=\"${PF_HPORT}\""
            printf "%s\n" "VM_PF_GPORT=\"${PF_GPORT}\""
        } >> "$VM_CONF_DIR"

    else
        PORT_FWD="0"
    fi
}

get_dev_opts() {
    # DEVICE Graphics:
    #   VGA                     Standard PCI VGA
    #   isa-vga                 ISA version of VGA
    #   secondary-vga           Legacy-free PCI VGA
    #   cirrus-vga              Cirrus VGA emulation
    #   vmware-svga             VMware-compatible graphics
    #   gxl-vga                 QXL graphics (useful with SPICE)
    #   virtio-vga              Virtio graphics w/ VGA compatibility
    #   virtio-gpu-pci          Virtio GPU w/o VGA compatibility
    #   virtio-vga-gl           Virtio GPU w/ OpenGL-capable backend (if built w/ support)
    #
    # DEVICE Network:
    #   virtio-net-pci
    #   virtio-net-device
    #   e1000
    #   e1000e
    #   rtl8139
    #   i82559er
    #   vmxnet3
    #   ne2k_pci
    #   ne2k_isa
    #   pcnet
    #   i82550
    #   i82551
    #   i82557a
    #   i82557b
    #   i82557c
    #   i82558a
    #   i82558b
    #   i82558c
    #   i82559a
    #   i82559b
    #   i82559c
    #   i82559er
    #   usb-net
    read -p "Specify the network adapter (default is 'e1000'): " NET_ADAP
    if [ -z "$NET_ADAP" ]; then
        NET_ADAP="${DEF_NET_ADAP}"
    fi

    read -p "Specify the network card (default is 'net0'): " NET_CARD
    if [ -z "$NET_CARD" ]; then
        NET_CARD="${DEF_NET_CARD}"
    fi

    echo "Updating VM .conf file...."
    {
        printf "%s\n" "VM_NET_ADAP=\"${NET_ADAP}\""
        printf "%s\n" "VM_NET_CARD=\"${NET_CARD}\""
    } >> "$VM_CONF_DIR"
}

get_disp_opts() {
    echo "Backends: "
    echo "(gtk, sdl, cocoa, vnc, curses, none, default, egl-headless, spice-app, dbus)"
    read -p "Specify display backend (default is 'default'): " DISP_BACK
    if [ -z "$DISP_BACK" ]; then
        DISP_BACK="${DEF_DISP_BACK}"
    fi

    # show-cursor                   gtk, sdl, cocoa
    # full-screen                   gtk, cocoa
    # zoom-to-fit                   gtk, cocoa
    # gl (OpenGL)                   gtk, sdl, cocoa
    # grab-on-hover                 gtk
    # window-close                  gtk, sdl
    # show-menubar                  gtk
    # clipboard                     gtk

    read -p "Would you like to show the cursor? [y, n]: " SHOW_CURSOR
    if [ "$SHOW_CURSOR" = "y" ]; then
        SHOW_CURSOR="${DEF_DISP_CURS}"
    else
        SHOW_CURSOR="0"
    fi

    # std
    # cirrus
    # vmware
    # qxl
    # virtio
    # none

    read -p "What VGA would you like to use (default is 'virtio')?: " VGA
    if [ -z "$VGA" ]; then
        VGA="${DEF_VGA_OPT}"
    fi

    echo "Updating VM .conf file...."
    {
        printf "%s\n" "VM_DISP_BACK=\"${DISP_BACK}\""
        printf "%s\n" "VM_DISP_CURS=\"${SHOW_CURSOR}\""
        printf "%s\n" "VM_VGA_OPT=\"${VGA}\""
    } >> "$VM_CONF_DIR"
}

build_opts() {
    read -p "How much RAM would you like to allocate (default is 4G)?: " RAM
    if [ -z "$RAM" ]; then
        RAM="${DEF_RAM_SIZE}"
    fi

    read -p "How many CPU cores would you like to allocate (default is 2)?: " CPU_CORES
    if [ -z "$CPU_CORES" ]; then
        CPU_CORES="${DEF_CPU_CORES}"
    fi

    echo "Updating VM .conf file...."
    {
        printf "%s\n" "VM_RAM_SIZE=\"${RAM}\""
        printf "%s\n" "VM_CPU_CORES=\"${CPU_CORES}\""
    } >> "$VM_CONF_DIR"   

    read -p "Would you like to configure netdev options? [y, n]: " SET_NETDEV
    if [ "$SET_NETDEV" = "y" ]; then
        get_net_opts
    else
        SET_NETDEV="0"
    fi

    read -p "Would you like to configure device options? [y, n]: " SET_DEVICE
    if [ "$SET_DEVICE" = "y" ]; then
        get_dev_opts
    else
        SET_DEVICE="0"
    fi

    read -p "Would you like to configure display options? [y, n]: " SET_DISPLAY
    if [ "$SET_DISPLAY" = "y" ]; then
        get_disp_opts
    else
        SET_DISPLAY="0"
    fi
}

# bd_confirm_info() {
#
# }

build_command() {
    MEM=(-m "${RAM}")
    SMP=(-smp "${CPU_CORES}")
    BOOT=(-boot "${DEF_BOOT_OPTS}")
    CDROM=(-cdrom "${ISO}")
    
    # Setting this for later booting
    BOOT_OPT="order=${HDISK}${DISK}"

    # Fill NETDEV option line
    if [ "$SET_NETDEV" = "y" ]; then
        if [ ! "$PORT_FWD" = "0" ]; then
            NETDEV_OPT="${NET_MODE},id=${NET_ID},hostfwd=${PF_PROTO}::${PF_HPORT}-:${PF_GPORT}"
        else
            NETDEV_OPT="${NET_MODE},id=${NET_ID}"
        fi

        NETDEV=(-netdev "${NETDEV_OPT}")
    else
        NETDEV_OPT=""
    fi

    # Fill DEVICE option line
    if [ "$SET_DEVICE" = "y" ]; then
        DEVICE_OPT="${NET_ADAP},netdev=${NET_CARD}"
        DEVICE=(-device "${DEVICE_OPT}")
    else
        DEVICE_OPT=""
    fi

    # Fill DISPLAY option line
    if [ "$SET_DISPLAY" = "y" ]; then
        if [ ! "$SHOW_CURSOR" = "0" ]; then
            DISPLAY_OPT="${DISP_BACK},${SHOW_CURSOR}"
        else
            DISPLAY_OPT="${DISP_BACK}"
        fi
        
        DISPLAY=(-display "${DISPLAY_OPT}")
    else
        DISPLAY_OPT=""
    fi

    # Update the .conf file
    echo "Updating VM .conf file...."
    {
        printf 'VM_MEM=(-m %q)\n' "$RAM"
        printf 'VM_SMP=(-smp %q)\n' "$CPU_CORES"
        printf 'VM_BOOT=(-boot %q)\n' "$BOOT_OPT"
        printf 'VM_NETDEV=(-netdev %q)\n' "$NETDEV_OPT"
        printf 'VM_DEVICE=(-device %q)\n' "$DEVICE_OPT"
        printf 'VM_DISPLAY=(-display %q)\n' "$DISPLAY_OPT"
        printf 'VM_VGA=(-vga %q)\n' "$VGA"
    } >> "$VM_CONF_DIR"
}

build_vm() { 
    build_opts
    build_command

    echo "Running VM...."
    qemu-system-x86_64 "${MEM[@]}" "${SMP[@]}" "${BOOT[@]}" "${CDROM[@]}" "${DRIVE[@]}" "${NETDEV[@]}" "${DEVICE[@]}" "${DISPLAY[@]}" \
        > "${VM_DIR}/${NAME}.log" 2>&1 </dev/null & 

    echo $! > "${VM_DIR}/${NAME}.pid"
}
