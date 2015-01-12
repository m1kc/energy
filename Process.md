Реализации меняются, процесс остаётся.

* Подготовить разделы: `cfdisk /dev/sdX`;
* Создать файловые системы: `mkfs.X`, `mkswap`;
* Смонтировать разделы в `/mnt`: `mount`, `swapon`;
* Подключиться к интернету: `ping`, `wifi-menu`, прочее;
* Выбрать зеркала: `/etc/pacman.d/mirrorlist`;
* Установить базовые пакеты: `pacstrap /mnt base [base-devel]`;
* Создать fstab: `genfstab -p /mnt >> /mnt/etc/fstab`;
* Задать имя хоста: [chroot] `echo X > /etc/hostname`, [chroot] `hostnamectl set-hostname`;
* Задать часовой пояс: [chroot] `ln -sf /usr/share/zoneinfo/zone/subzone /etc/localtime`;
```sh
timezones1=`timedatectl --no-pager list-timezones`
timezones=""
for i in $timezones1; do timezones="${timezones} ${i} -"; done
dialog --no-cancel --menu "Select a timezone." 0 0 0 $timezones 2> $TMP
timezone=`cat $TMP`
echo == arch-chroot /mnt ln -s /usr/share/zoneinfo/${timezone} /etc/localtime
```
* Выбрать из UTC/localtime.
```sh
# To change the hardware clock time standard to localtime use:
timedatectl set-local-rtc 1
# And to set it to UTC use:
timedatectl set-local-rtc 0
dialog --no-cancel --menu "Select your hardware clock mode. It is recommended to use UTC, but if you have Windows installed, you should you localtime." 0 0 0  0 UTC 1 localtime  2> $TMP
rtc=`cat $TMP`
echo == timedatectl --root=/mnt set-local-rtc $rtc
```
* Сгенерировать локали: `/etc/locale.gen`, [chroot] `locale-gen`;
* Выбрать локаль: `echo LANG=your_locale > /etc/locale.conf`;
* Add console keymap and font preferences in `/etc/vconsole.conf`;
* Configure the network for the newly installed environment: see Network configuration and Wireless network configuration;
* Configure /etc/mkinitcpio.conf if additional features are needed. Create a new initial RAM disk with `mkinitcpio -p linux`;
* Задать пароль рута: [chroot] `passwd`;
* Install a bootloader;
* Создать юзера, установить sudo, разрешить доступ группе wheel;
* dhcpd?
* ntpd;
* yaourt;
* Xorg;
* Display drivers;
* GNOME & GDM;
* Fonts;
* Другие пакеты;
* Codecs;
* DNS caching?
* mlocate?
* cups?
* zsh?
* Перезагрузка.
