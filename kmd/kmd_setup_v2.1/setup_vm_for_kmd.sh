#!/bin/bash

# setup the VM and komodo

# print commands and stop script on errors
set -ex

# == update ==
sudo apt update -y
sudo apt install -y libgtk2.0-dev
#sudo apt upgrade


# == install glib1.2 ==
wget https://download.gnome.org/sources/glib/1.2/glib-1.2.10.tar.gz
tar xzf glib-1.2.10.tar.gz
cd glib-1.2.10

# blindly steal patches from arch user repo
wget https://aur.archlinux.org/cgit/aur.git/plain/aclocal-fixes.patch?h=glib -O aclocal-fixes.patch
patch -Np0 -i aclocal-fixes.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/gcc340.patch?h=glib -O gcc340.patch
patch -Np1 -i gcc340.patch
wget https://aur.archlinux.org/cgit/aur.git/plain/glib1-autotools.patch?h=glib -O glib1-autotools.patch
patch -Np1 -i glib1-autotools.patch
sed -i -e 's/ifdef[[:space:]]*__OPTIMIZE__/if 0/' glib.h
rm acinclude.m4

# make
CONFIGFLAG='--host=x86_64-unknown-linux-gnu --target=x86_64-unknown-linux-gnu'
DIRFLAG='--prefix=/usr --mandir=/usr/share/man --infodir=/usr/share/info'
#autoreconf --force --install
./configure $DIRFLAG $CONFIGFLAG
make -j8
sudo make install
cd ..

# == install gtk1.2 ==
#sudo apt install libxmu-dev
wget https://download.gnome.org/sources/gtk+/1.2/gtk+-1.2.10.tar.gz
tar xzf gtk+-1.2.10.tar.gz
cd gtk+-1.2.10

# more patch stealing from the aur
cp /usr/share/libtool/build-aux/config.guess .
cp /usr/share/libtool/build-aux/config.sub .
wget https://aur.archlinux.org/cgit/aur.git/plain/aclocal-fixes.patch?h=gtk -O aclocal-fixes.patch
patch -Np0 -i aclocal-fixes.patch
sed -i "/ac_cpp=/s/\$CPPFLAGS/\$CPPFLAGS -O2/" configure

./configure $DIRFLAG --sysconfdir=/etc
make -j8
sudo make install
cd ..

# == install kmd & jimulator==
#wget https://studentnet.cs.manchester.ac.uk/resources/software/komodo/kmd.tar.gz
#tar xzf kmd.tar.gz
#cd KMD-1.5.0

git clone https://github.com/UoMCS/komodo.git
cd komodo
sed -i "s|parse.pl < sample.komodo > dotkomodo.string|./parse.pl < sample.komodo > dotkomodo.string|" src/Makefile.am
echo -e "\njimulator_LDFLAGS = -export-dynamic" >> src/Makefile.am
patch -Np0 -i ../kmd_termfix.patch
patch -Np0 -i ../kmd_vscreenfix.patch
patch -Np0 -i ../jimulator_int_support.patch

# copied from the gtk1.2 build
cp /usr/share/libtool/build-aux/config.guess .
cp /usr/share/libtool/build-aux/config.sub .
autoreconf --force --install
./configure $DIRFLAG
make -j8
sudo make install
cd ..

# == install vscreen ==
mkdir leds-patch
unzip leds-patch.zip -d leds-patch
cp -r leds-patch/pngs-stamped ~/.vscreen

unzip vscreen.zip
cd vscreen
patch -Np0 -i ../vscreen_bgr2rgb.patch
git apply ../leds-patch/0001-Add-support-for-LED-images.patch
./configure $DIRFLAG
make -j8
sudo make install

cd ..

# == install aasm ==
wget https://studentnet.cs.manchester.ac.uk/resources/software/komodo/assembler/aasm.tar.gz
mkdir -p aasm/
tar xzf aasm.tar.gz -C aasm/
cd aasm/
gcc -g aasm.c -o aasm
sudo cp aasm mnemonics /usr/bin/
cd ..

# == install jimulator plugins ==
tar xzf jimulator_plugins.tar.gz
cd jimulator_plugins
make -j4
sudo cp *.so /usr/lib/
cd ..

# == install keypad gui app ==
tar xzf kmd_keypad.tar.gz
cd kmd_keypad
sudo cp * /usr/bin/
cd ..

# == install config files and scripts ==
sudo cp jimulator.conf jimulator_disk.data /etc/
sudo cp kmd_227 kmd_compile /usr/bin/

# run komodo!
kmd_227
