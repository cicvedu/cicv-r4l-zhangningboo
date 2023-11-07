#!/bin/zsh
echo $GIT_USER_NAME
busybox_folder="../busybox-1.36.1"
kernel_image="../linux/arch/x86/boot/bzImage"
work_dir=$PWD
rootfs="rootfs"
rootfs_img=$PWD"/rootfs_img"

make LLVM=1
echo $base_path
if [ ! -d $rootfs ]; then
    mkdir $rootfs
fi
cp $busybox_folder/_install/*  $rootfs/ -rf
cp $work_dir/r4l_e1000_demo.ko $work_dir/$rootfs/
cd $rootfs
if [ ! -d proc ] && [ ! -d sys ] && [ ! -d dev ] && [ ! -d etc/init.d ]; then
    mkdir proc sys dev etc etc/init.d
fi
 
if [ -f etc/init.d/rcS ]; then
    rm etc/init.d/rcS
fi
echo "#!/bin/sh" > etc/init.d/rcS
echo "mount -t proc none /proc" >> etc/init.d/rcS
echo "mount -t sysfs none /sys" >> etc/init.d/rcS
echo "/sbin/mdev -s" >> etc/init.d/rcS
echo "mknod /dev/cicv c 248 0" >> etc/init.d/rcS
chmod +x etc/init.d/rcS
if [ -f $rootfs_img ]; then
    rm $rootfs_img
fi

cd $work_dir

cd $rootfs 
find . | cpio -o --format=newc > $rootfs_img

cd $work_dir

# 原脚本
# qemu-system-x86_64 \
# -netdev "user,id=eth0" \
# -device "e1000,netdev=eth0" \
# -object "filter-dump,id=eth0,netdev=eth0,file=dump.dat" \
# -kernel $kernel_image \
# -append "root=/dev/ram rdinit=sbin/init ip=10.0.2.15::10.0.2.1:255.255.255.0 console=ttyS0 no_timer_check" \
# -nographic \
# -initrd $rootfs_img

# 
# 参考 https://blog.arg.pub/2022/10/03/os/%E4%BD%BF%E7%94%A8Docker%E7%BC%96%E8%AF%9132%E4%BD%8DLinux%E5%86%85%E6%A0%B8%E5%B9%B6%E5%9C%A8Qemu%E4%B8%AD%E8%BF%90%E8%A1%8C/index.html
qemu-system-x86_64 \
-m 2048M \
-drive format=raw,file=/home/debian/cicv-r4l-zhangningboo/src_e1000/disk.raw \
-netdev "user,id=eth0" \
-device "e1000,netdev=eth0" \
-object "filter-dump,id=eth0,netdev=eth0,file=dump.dat" \
-kernel $kernel_image \
-append "init=/linuxrc root=/dev/sda rdinit=sbin/init ip=10.0.2.15::10.0.2.1:255.255.255.0 console=ttyS0 no_timer_check" \
-nographic \
-initrd $rootfs_img

