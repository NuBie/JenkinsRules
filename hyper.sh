#!/bin/bash

readonly red=$(tput setaf 1) #  red
readonly grn=$(tput setaf 2) #  green
readonly ylw=$(tput setaf 3) #  yellow
readonly blu=$(tput setaf 4) #  blue
readonly cya=$(tput setaf 6) #  cyan
readonly txtbld=$(tput bold) # Bold
readonly bldred=$txtbld$red  #  red
readonly bldgrn=$txtbld$grn  #  green
readonly bldylw=$txtbld$ylw  #  yellow
readonly bldblu=$txtbld$blu  #  blue
readonly bldcya=$txtbld$cya  #  cyan
readonly txtrst=$(tput sgr0) # Reset

err() {
	echo "$txtrst${red}$*$txtrst" >&2
}

warn() {
	echo "$txtrst${ylw}$*$txtrst" >&2
}

info() {
	echo "$txtrst${grn}$*$txtrst"
}

setbuildjobs() {
	# Set build jobs
	JOBS=$(expr 0 + $(grep -c ^processor /proc/cpuinfo))
	info "Set build jobs to $JOBS"
}

WAKTUMULAI=$(date +"%s")

SAUCE=~/android/kernelcompile
PVRSAUCE=~/android_hardware_ti_omap4/pvr-source/eurasiacon
KERNELSOURCE=~/android_kernel_ti_omap4
WORKINGOUTDIR=~/android/kernelcompile/espresso-bin
WORKINGOUTDIR_M=~/android/kernelcompile/espresso-bin/modules #new variable

#perintah hapus ------------------------------------------->>>>>
cd $WORKINGOUTDIR_M
rm -f *.ko

echo "sukses hapus *.ko"

cd $WORKINGOUTDIR
rm -f *.zip
echo "sukses hapus zip"

cd $WORKINGOUTDIR
rm -f zImage

echo "sukses hapus zImage"
#akhir perintah hapus ---------------------------------------->>>>>

info "Letak Kernel source : $KERNELSOURCE"
info "Letak PVR Source : $PVRSAUCE"
info "directory kerja : $SAUCE"
info "Hasil zImage dan modules tersimpan di : $WORKINGOUTDIR"

setbuildjobs

info "Pindah Ke Direktori kernel source"
cd $KERNELSOURCE

info "Import toolchain environment setup..."
export CROSS_COMPILE=/home/cemplug/hypertc/bin/arm-eabi-
export LDFLAGS=''
export CFLAGS=''
export SUBARCH=arm
export ARCH=arm
export STRIP=/home/cemplug/hypertc/bin/arm-eabi-strip

alias 'stm'='$STRIP --strip-unneeded *.ko'
info "sukses di import...."

warn "Bersihkan kernel sources lama"
#make O=$SAUCE/espresso clobber
make O=$SAUCE/espresso mrproper
make O=$SAUCE/espresso clean

info "sukses dibersihkan"

warn "Reset counter kernel kompilasi "
echo 0 > $SAUCE/espresso/.version
info "sukses di reset"

info "Import kernel config file untuk : Lolipop(5.x.x), Marsmallow(6.x.x), dan Nougat(7.x.x)"

make O=$SAUCE/espresso espresso_defconfig
info "sukses espresso_defconfig"

info "Konfigurasi kernel:"
make O=$SAUCE/espresso oldconfig

info "Kompile kernel..."
info "Silahakan Nyeduh kopi.."
make -j4 O=$SAUCE/espresso

info "Copy File zImage dan modules di tempat yang sudah ditentukan"
cp $SAUCE/espresso/arch/arm/boot/zImage $SAUCE/espresso-bin/
find $SAUCE/espresso/ -type f -name *.ko -exec cp {} $SAUCE/espresso-bin/modules/ \;

info "zImage dan modules berhasil di pindahkan, You are MASTAH CIIIIINNNN..... :)"

info "inisialisasi KERNEL_OUT directory"
export KERNELDIR=$SAUCE/espresso

warn "Pastikan PVR source bersih !"
make clean -C $PVRSAUCE/build/linux2/omap4430_android

info "kompile PVR module"
make -j4 -C $PVRSAUCE/build/linux2/omap4430_android TARGET_PRODUCT="blaze_tablet" BUILD=release TARGET_SGX=540 PLATFORM_VERSION=4.1

info "Copy PVR module ke: $WORKINGOUTDIR"
	cp -fr $PVRSAUCE/binary2_omap4430_android_release/target/pvrsrvkm.ko $WORKINGOUTDIR/modules/pvrsrvkm_sgx540_120.ko
	mv $PVRSAUCE/binary2_omap4430_android_release/target/pvrsrvkm.ko $WORKINGOUTDIR/modules/

warn "Hapus PVR source"
make clean -C $PVRSAUCE/build/linux2/omap4430_android
warn "sukses dihapus"

info "oplas modules jadi sexy"
cd $SAUCE/espresso-bin/modules
stm

info "Woooow fuck.. modulmu sexy, Hot, Montok dan bikin Horny . . . :)"

cd $WORKINGOUTDIR

WAKTUSAIKI=$(date +"%d-%m-%y-(%X)")

zip -r Espresso_Kernel_Kopi_Luwak_$WAKTUSAIKI.zip META-INF modules tools anykernel.sh cemplug zImage

	info "####################"
	info "#       Done!      #"
	info "####################"

WAKTUSELESAI=$(date +"%s")
ESTIMASIWAKTU=$(($WAKTUSELESAI - $WAKTUMULAI))

#echo -e "${blink_red}"
echo "Waktu Estimasi : $(($ESTIMASIWAKTU / 60)) menit dan $(($ESTIMASIWAKTU % 60)) detik."
echo

date
echo "Generated Script by : $USER"

