#!/bin/sh

# unzip files
if [ ! -d workspace/DSM_DS3612xs_4458 ]; then
	echo "\033[41;37m Unzip DSM pat file ... \033[0m"
	mkdir ./workspace/DSM_DS3612xs_4458
	tar xvf DSM_DS3612xs_4458.pat -C ./workspace/DSM_DS3612xs_4458
fi

#check modules and bzImage
kofile=`find ./workspace/linux-3.x/ -iname "*.ko" -type f`
if [ x"$kofile" = x"" ] || [ ! -f workspace/linux-3.x/arch/x86_64/boot/bzImage ]; then
	echo "\033[41;37m Can not find modules and bzImage, Please follow this step to build modules and bzImage first ... \033[0m"
	echo "\033[32m cd ./workspace/linux-3.x \033[0m"
	echo "\033[32m make ARCH=x86_64 CROSS_COMPILE=../x86_64-pc-linux-gnu/bin/x86_64-pc-linux-gnu- menuconfig \033[0m"
	echo "\033[32m make ARCH=x86_64 CROSS_COMPILE=../x86_64-pc-linux-gnu/bin/x86_64-pc-linux-gnu- modules \033[0m"
	echo "\033[32m make ARCH=x86_64 CROSS_COMPILE=../x86_64-pc-linux-gnu/bin/x86_64-pc-linux-gnu- bzImage \033[0m"
	exit
fi

# modify rd.gz file
echo "\033[41;37m Patch rd.gz and Crack synobios.ko ... \033[0m"
cd workspace
cp -p ./DSM_DS3612xs_4458/rd.gz ./
mv rd.gz rd.lzma
unlzma rd.lzma
mkdir rd-orig
cd rd-orig
cpio -i -F ../rd
cd ../
find ./linux-3.x/ -iname "*.ko" -type f -exec cp -p {} ./rd-orig/lib/modules/ \;
cp -p ../xpenology/synobios/synobios-cracked-4.3-3827.ko ./rd-orig/lib/modules/synobios.ko
chmod 755 ../xpenology/patches-rd-gz-alpha9/.gnoboot/rc.d/xpenology
cp -rp ../xpenology/patches-rd-gz-alpha9/.gnoboot ./rd-orig/
tar zxvf ../xpenology/patches-rd-gz-alpha9/gnord.tar.gz -C ./rd-orig/
cp -p ../xpenology/patches-rd-gz-alpha9/rd-with-gnoboot-4458.patch ./
patch -p0 < ./rd-with-gnoboot-4458.patch
rm -f ./rd-with-gnoboot-4458.patch
mknod -m 644 ./rd-orig/dev/mem c 1 1
mknod -m 644 ./rd-orig/dev/tty5 c 4 5
rm -f ./rd-orig/dev/synobios
rm -f rd
cd rd-orig
find . | cpio -o -H newc > /tmp/rd
mv /tmp/rd ../
cd ../
lzma rd
mv rd.lzma rd.gz
rm -rf rd-orig
cd ../

# mount img file
echo "\033[41;37m Copy rd.gz and zImage to the img package ... \033[0m"
if [ ! -d /mnt/img ]; then
	mkdir /mnt/img
fi
mount -o loop,offset=32256 Synoboot_5.0-4458_x64_3612xs.img /mnt/img
cp -p ./workspace/linux-3.x/arch/x86_64/boot/bzImage /mnt/img/zImage
cp -p ./workspace/rd.gz /mnt/img/
rm -f ./workspace/rd.gz
umount /mnt/img

# finished
echo "\033[41;37m Everything is ok, burn the img file to you USB storage. \033[0m"
