#include <stdio.h>
#include "floppy.h"
int main(void) {
    Floppy * img = createFloppy();

    writeFloppy(img, read_file("/home/luedi/CLionProjects/luedi-os/build/boot/boot.o"), 0,0,1);
    writeFloppy(img, read_file("/home/luedi/CLionProjects/luedi-os/build/boot/setup.o"), 0,0,2);
    exportFloppy(img, "/home/luedi/CLionProjects/luedi-os/a.img");

    return 0;
}
