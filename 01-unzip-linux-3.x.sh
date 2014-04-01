#!/bin/sh

#create workspace
if [ ! -d workspace ]; then
	echo "\033[41;37m Create workspace folder ... \033[0m"
	mkdir workspace
fi

# check linux-3.x and zImage file
if [ ! -d workspace/linux-3.x ]; then
	echo "\033[41;37m Unzip linux-3.x and patch it, please wait ... \033[0m"
	tar zxf synogpl-4418-bromolow_linux-3.x.tar.gz -C ./workspace/
	cp -p ./xpenology/patches-linux-3.x/linux-3.x-xpenology-4418.patch ./workspace/
	cd workspace
	patch -p0 < ./linux-3.x-xpenology-4418.patch
	rm -f linux-3.x-xpenology-4418.patch
	cp -p ../xpenology/.config ./linux-3.x/
	cd ../
else
	echo "\033[41;37m The linux-3.x folder already exists. \033[0m"
fi

if [ ! -d workspace/x86_64-pc-linux-gnu ]; then
	echo "\033[41;37m Unzip Toolchain, please wait ... \033[0m"
	tar zxf gcc473_glibc217_x86_64_bromolow-GPL.tgz -C ./workspace/
fi

echo "\033[41;37m Linux-3.x and Toolchain is ready, Please follow this step to build modules and bzImage : \033[0m"
echo "\033[32m cd ./workspace/linux-3.x \033[0m"
echo "\033[32m make ARCH=x86_64 CROSS_COMPILE=../x86_64-pc-linux-gnu/bin/x86_64-pc-linux-gnu- menuconfig \033[0m"
echo "\033[32m make ARCH=x86_64 CROSS_COMPILE=../x86_64-pc-linux-gnu/bin/x86_64-pc-linux-gnu- modules \033[0m"
echo "\033[32m make ARCH=x86_64 CROSS_COMPILE=../x86_64-pc-linux-gnu/bin/x86_64-pc-linux-gnu- bzImage \033[0m"
