$CommandsRunToBuildTemplate = @"
#https://wiki.archlinux.org/index.php/installation_guide
#From Arch linux ISO
parted /dev/sda mklabel gpt
parted /dev/sda mkpart ESP fat32 1MiB 513MiB
parted /dev/sda set 1 boot on
parted /dev/sda mkpart primary ext4 513MiB 100%
mkfs.fat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt boot
mount /dev/sda1 /mnt/boot
sed -i 's/^Server/#Server/' /etc/pacman.d/mirrorlist
#Uncomment the first 6 United states mirrors listed
vi /etc/pacman.d/mirrorlist
rankmirrors -n 6 /etc/pacman.d/mirrorlist > /etc/pacman.d/mirrorlist
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

#From new root
vi /etc/locale.gen
locale-gen
vi /etc/locale.conf
mkinitcpio -p linux
passwd
bootctl --path=/boot install
vi /boot/loader/loader.conf
vi /boot/loader/entries/arch.conf
systemctl start systemd-networkd
systemctl enable systemd-networkd
vi /etc/resolv.conf
pacman -S openssh
systemctl start sshd.socket
systemctl enable sshd.socket
"@