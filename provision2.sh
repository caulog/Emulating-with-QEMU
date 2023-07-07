# install qemu
#   sudo apt install libslirp-dev -y
#   wget https://download.qemu.org/qemu-8.0.0-rc4.tar.xz
#   tar xvJf qemu-8.0.0-rc4.tar.xz
    cd qemu-8.0.0-rc4
#   ./configure --enable-slirp
#   make -j$(nproc)
#   sudo make install  

# Create and partition a disk
    cd .. 
    cd /home/vagrant/linux-envs
    wget https://raspi.debian.net/tested/20230612_raspi_4_bookworm.img.xz
    dd if=/dev/null of=disk.img bs=1M seek=10240
    xzcat 20230612_raspi_4_bookworm.img.xz | dd of=disk.img conv=notrunc status=progress
    # Find the loop device name
    loop_device=$(losetup -f --show disk.img)
    sudo partx -a -v "$loop_device"
    mkdir host-mount
    sudo systemctl daemon-reload
    sudo mount "${loop_device}p1" host-mount
    cp host-mount/initrd.img* .
    cp host-mount/vmlinuz* .
    sudo umount "${loop_device}p1"

    sudo fdisk "$loop_device" <<EOF
	d 
	2
	n
	p
	2
	8192
	
	
	p 
	w
EOF

    sudo partprobe "$loop_device"
    sudo e2fsck -f "${loop_device}p2"
    sudo resize2fs "${loop_device}p2"

# Mount partition 1 on host-mount
    sudo mount "${loop_device}p1" host-mount

# Boot qemu
    # Configure enp0s1 network file 
    expect qemu-init1.exp
    # Install Apache 
    expect qemu-init2.exp

    sudo umount host-mount

# Build and compile kernel modules for ARM-64
    sudo mount "${loop_device}p2" host-mount
    pushd /home/vagrant/linux-6.3.8
    sudo make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- LLVM=1 CC=clang HOSTCC=clang INSTALL_MOD_PATH=/home/vagrant/linux-envs/host-mount modules_install
    popd
    sudo umount host-mount

    sudo mount "${loop_device}p1" host-mount

# Boot qemu
    # Create initramfs image and install gcc  
    expect qemu-init3.exp
