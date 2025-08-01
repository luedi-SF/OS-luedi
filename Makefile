BUILD:=./build

CFLAGS:= -m32 # 32 位的程序
CFLAGS+= -masm=intel
CFLAGS+= -fno-builtin	# 不需要 gcc 内置函数
CFLAGS+= -nostdinc		# 不需要标准头文件
CFLAGS+= -fno-pic		# 不需要位置无关的代码  position independent code
CFLAGS+= -fno-pie		# 不需要位置无关的可执行程序 position independent executable
CFLAGS+= -nostdlib		# 不需要标准库
CFLAGS+= -fno-stack-protector	# 不需要栈保护
CFLAGS+= -z noexecstack #  .note.GNU-stack section
CFLAGS:=$(strip ${CFLAGS})
DEBUG:= -g



all: ${BUILD}/boot/setup.o ${BUILD}/boot/boot.o ${BUILD}/kernel/kernel.bin
	$(shell rm -rf hd.img)
	$(shell rm -rf hd.img.lock)
	bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat hd.img
	dd if=${BUILD}/boot/boot.o of=hd.img bs=512 seek=0 count=1 conv=notrunc
	dd if=${BUILD}/boot/setup.o of=hd.img bs=512 seek=1 count=2 conv=notrunc
	dd if=${BUILD}/kernel/kernel.bin of=hd.img bs=512 seek=3 count=50 conv=notrunc


${BUILD}/boot/%.o: asm/boot/%.asm
	$(shell mkdir -p ${BUILD}/boot)
	nasm $< -o $@

${BUILD}/kernel/asm/%.o: asm/kernel/head.asm
	$(shell mkdir -p ${BUILD}/kernel/asm)
	nasm -f elf32 -g $< -o $@

${BUILD}/kernel/%.o: src/kernel/main.c
	gcc ${CFLAGS} ${DEBUG} -c $< -o $@

${BUILD}/kernel/kernel.bin: ${BUILD}/kernel/kernelDBG.bin
	objcopy -O binary ${BUILD}/kernel/kernelDBG.bin ${BUILD}/kernel/kernel.bin
	nm ${BUILD}/kernel/kernelDBG.bin | sort > ${BUILD}/kernel/kernelDBG.map
${BUILD}/kernel/kernelDBG.bin: ${BUILD}/kernel/asm/head.o ${BUILD}/kernel/main.o
	$(shell mkdir -p ${BUILD}/kernel)
	#-m elf_i386: produce a 32-bit ELF object.
	#-Ttext 0x1000: set the load address of the .text section to 0x1000; the kernel will be loaded at this physical address by the bootloader.
	ld -m elf_i386 $^ -o $@ -Ttext 0x1000   #GNU linker


qemudbg: all
	qemu-system-x86_64 -m 32M -hda hd.img -S -s
	#qemu-system-i386 -m 32M -hda hd.img -S -s
clean:
	$(shell rm -rf ${BUILD})
qemu: all
	qemu-system-i386 \
	-m 32M \
	-boot c \
	-hda hd.img
bochs: all
	bochs -q -f bochsrc