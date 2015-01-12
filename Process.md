Реализации меняются, процесс остаётся.

1. Подготовить разделы: `cfdisk /dev/sdX`;
2. Создать файловые системы: `mkfs.X`, `mkswap`;
3. Смонтировать разделы в `/mnt`: `mount`, `swapon`;
4. Подключиться к интернету: `ping`, `wifi-menu`, прочее;
5. Выбрать зеркала: `/etc/pacman.d/mirrorlist`;
6. Установить базовые пакеты: `pacstrap /mnt base [base-devel]`;
7. Создать fstab: `genfstab -p /mnt >> /mnt/etc/fstab`;
8. Задать имя хоста: [chroot] `echo X > /etc/hostname`, [chroot] `hostnamectl set-hostname`;
9. Задать часовой пояс: [chroot] `ln -sf /usr/share/zoneinfo/zone/subzone /etc/localtime`;
10. Сгенерировать локали: `/etc/locale.gen`, [chroot] `locale-gen`;
11. Выбрать локаль: `echo LANG=your_locale > /etc/locale.conf`;
12. Add console keymap and font preferences in `/etc/vconsole.conf`;
13. Configure the network for the newly installed environment: see Network configuration and Wireless network configuration;
14. Configure /etc/mkinitcpio.conf if additional features are needed. Create a new initial RAM disk with `mkinitcpio -p linux`;
15. Задать пароль рута: [chroot] `passwd`;
16. Install a bootloader;
17. Создать юзера, установить sudo, разрешить доступ группе wheel;
18. dhcpd?
19. ntpd;
20. yaourt;
21. Xorg;
22. GNOME & GDM;
23. Fonts;
24. Другие пакеты;
25. Перезагрузка.
