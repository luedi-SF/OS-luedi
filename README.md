# OS-luedi 
This project is for learning OS.
So the README file will like a tutorial.
And the README will be submitted to my blog respectively.
# Section 1 : Bootloader
This section is corresponding to boot.asm .
This file is automatically loaded to the first sector of the primary HD by BIOS.
So we can use it to load following System into memory.
Consequently, the first problem is how to load data from disk to memory manually?
## LBA
LBA is a method to access disks.
We will use `in` and `out` instruction to manipulate port of disk.
> PS: In this tutorial, I will only tell you the concept but detail. If you want to know more, you have to google it ,or read my code and comment.
> Moreover, I will mainly talk about the mistakes that haunt me.

When I was writing this part, I found I can only read zero from disk.
That is because I didn't read the correct sector of my disk.
It seems like a stupid mistake, but it really will trouble you because it is difficult to figure out the motion of disk at first time.

So there is a way to check it out easily .

```shell
 dd if=${BUILD}/boot/boot.o of=hd.img bs=512 seek=0 count=1 conv=notrunc
```
`seek` is the sector number of disk. When you want to read data, take it as the sector that you want to read.


# Section 2 : Setup
This section is corresponding to setup.asm .
This file might be one of the most important files in this project because in this file we will not only enter protected mode but also have other function such as detect device, check memory etc.


To be continue...


# Links
You can find some useful documents in here. \
[wiki](https://wiki.osdev.org/)