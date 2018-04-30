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

#Note: After installation it is recommended to harden SSH. The first step would be to remove PermitRootLogin yes from /etc/ssh/sshd_config.
vi /etc/ssh/sshd_config
systemctl start sshd.socket
systemctl enable sshd.socket
"@

function Install-AURPackageWithoutHelper {
    param(
        [Parameter(Mandatory,ValueFromPipeline)]$Node,
        $SnapshotURL
    )
    $PackageName = "aura-bin"
    $Node | Add-SSHSessionCustomProperty -UseIPAddress
$Command = @"
cd /tmp
curl -L -O $SnapshotURL
tar -xvf aura-bin.tar.gz
cd aura-bin
makepkg -si --noconfirm --needed --noprogressbar
"@
    Invoke-SSHCommand -Command "curl -L -O $SnapshotURL"

    Invoke-SSHCommand -Command "makepkg -si"
}

function Install-AURAURA {
    Install-AURPackageWithoutHelper -SnapshotURL https://aur.archlinux.org/cgit/aur.git/snapshot/aura-bin.tar.gz
}