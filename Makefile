BUILD:=./build


asm: ${BUILD}/boot/boot.o ${BUILD}/boot/setup.o generate_HDimg



${BUILD}/boot/%.o: asm/boot/%.asm
	$(shell mkdir -p ${BUILD}/boot)
	nasm $< -o $@


#generate_Floppyimg:
#	./luedi_os

generate_HDimg:
	bximage -q -hd=16 -func=create -sectsize=512 -imgmode=flat hd.img
	dd if=${BUILD}/boot/boot.o of=hd.img bs=512 seek=0 count=1 conv=notrunc
	dd if=${BUILD}/boot/setup.o of=hd.img bs=512 seek=1 count=2 conv=notrunc
#	dd if=${BUILD}/boot/boot.o  of=b.img bs=512 seek=0 count=1 conv=notrunc
#	dd if=${BUILD}/boot/setup.o of=b.img bs=512 seek=1 count=1 conv=notrunc


clean:
	$(shell rm -rf ${BUILD})

bochs:
	bochs -q -f bochsrc