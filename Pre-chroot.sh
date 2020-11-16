#!/bin/sh


echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nEnter username to be created:\n"

read user

echo -e "\nEnter root password:\n"

read rtpw

echo -e "\nEnter user password:\n"

read uspw

echo -e "\nEnter device name:\n"

read host

echo -e "$user $rtpw $uspw $host" > ./passwords

echo -e "\nDone.\n\n"



echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nFormatting Partitions...\n"

wipefs --all /dev/sda

fdisk --wipe always --wipe-partitions always /dev/sda << EOL
g
n
1

+512M
n
2


t
1
1
t
2
24
w
EOL

mkfs.fat -F 32 -n "ESP" /dev/sda1

mkfs.ext4 -L "ROOT" -F /dev/sda2

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nStarting NTP Daemon...\n"

sleep 2

timedatectl set-ntp true

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nAdding Fastest Mirror in Pacman Mirrorlist...\n"

sleep 2

reflector --protocol http --score 50 --sort rate --save /etc/pacman.d/mirrorlist --verbose

sleep 2

sed -i '1s/^/Server = http\:\/\/mirrors.dotsrc.org\/archlinux\/\$repo\/os\/\$arch\nServer = http\:\/\/mirror.osbeck.com\/archlinux\/\$repo\/os\/\$arch\n/' /etc/pacman.d/mirrorlist

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nModifying Pacman Configuration...\n"

sleep 2

sed -i 's/#Color/Color/; s/#TotalDownload/TotalDownload/; s/#\[multilib\]/\[multilib\]/; /\[multilib\]/{N;s/#Include/Include/}' /etc/pacman.conf

echo -e "\n[repo-ck]\nServer = http://repo-ck.com/\$arch\n" >> /etc/pacman.conf

pacman -Syy --noconfirm

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nPerforming Initialization of Pacman Keyring...\n"

sleep 2

echo -e "keyserver hkp://pool.sks-keyservers.net" >> /etc/pacman.d/gnupg/gpg.conf

pacman-key --init

pacman-key --populate archlinux

pacman-key --refresh-keys

pacman-key -r 5EE46C4C && pacman-key --lsign-key 5EE46C4C

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nMounting Partitions...\n"

sleep 2

mount /dev/sda2 /mnt

rm -rf /mnt/lost*

mkdir /mnt/efi

mount /dev/sda1 /mnt/efi

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nPerforming Pacstrap Operation...\n"

sleep 2

pacstrap /mnt base base-devel linux linux-headers linux-docs linux-firmware linux-tools-meta btrfs-progs dosfstools fatresize exfat-utils exfat-utils f2fs-tools e2fsprogs ntfs-3g jfsutils nilfs-utils reiserfsprogs udftools xfsprogs squashfs-tools fuse2 fuse3 squashfuse btfs fuseiso kio-fuse mtpfs sshfs p7zip unrar unarchiver lzop lrzip unzip zip nano man-db man-pages texinfo dialog dhcpcd dnsmasq wpa_supplicant grub efibootmgr intel-ucode pacman-contrib pkgstats pkgfile neofetch htop git make xorg mesa lib32-mesa intel-media-driver libva-intel-driver lib32-libva-intel-driver libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau xf86-video-amdgpu vulkan-icd-loader lib32-vulkan-icd-loader vulkan-intel lib32-vulkan-intel vulkan-radeon lib32-vulkan-radeon amdvlk lib32-amdvlk plasma kde-applications kdepim-addons telepathy telepathy-kde-meta packagekit-qt5 fwupd ffmpeg gst-libav gst-plugins-base lib32-gst-plugins-base gst-plugins-good lib32-gst-plugins-good gst-plugins-bad gst-plugins-ugly libde265 gstreamer-vaapi ttf-dejavu ttf-liberation ttf-droid gnu-free-fonts noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-roboto ttf-ubuntu-font-family ttf-opensans cantarell-fonts inter-font wqy-microhei wqy-zenhei wqy-bitmapfont otf-ipafont cpupower haveged android-tools hunspell hunspell-en_US xdg-user-dirs xdg-desktop-portal xdg-desktop-portal-kde libappindicator-gtk2 libappindicator-gtk3 lib32-libappindicator-gtk2 lib32-libappindicator-gtk3 zsh zsh-doc grml-zsh-config zsh-autosuggestions zsh-completions zsh-history-substring-search zsh-syntax-highlighting zsh-lovers zsh-theme-powerlevel10k powerline firefox

echo -e "\nDone.\n\n"




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nGenerating FSTab...\n"

sleep 2

genfstab -U /mnt >> /mnt/etc/fstab

echo -e "\nDone.\n\nPre-chroot step is now complete.\n\n"

sleep 2




echo "------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
echo -e "\nStarting Post-chroot step...\n"

sleep 2

cp ./passwords /mnt/root/

cp ./Post-chroot.sh /mnt/root/

chmod a+x /mnt/root/Post-chroot.sh

arch-chroot /mnt /root/Post-chroot.sh

umount -a

sleep 2

echo -e "\nInstallation Complete.\n\n"

sleep 10

reboot
