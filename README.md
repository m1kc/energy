Energy Linux
============

«Batteries included.»

I'd call this an Arch-based distribution, but that would be not true. I would not change anything in Arch Linux because I believe it's perfect. So, I just added a curses-based installer to make initial setup easier.

Right now it's a bit incomplete and a bit outdated, so use it at your own risk, but still nice and usable. And PRs are always welcome!


Building an ISO
---------------

#### Requirements

* Arch Linux running on x86_64;
* archiso package.

Got no Arch and you don't know how to install it? Try building Energy in a Docker container.


#### Instructions

1. Run `make`.
2. Done. You will get a dual-architecture ISO in the `out/` folder.


Installing
----------

1. Write this ISO to a CD or USB stick.
2. Boot it up.
3. Run `./install.sh` and follow the instructions.
4. Something seems to be wrong? Check out the [Arch installation guide](https://wiki.archlinux.org/index.php/Installation_guide).
