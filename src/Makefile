SHELL := /bin/bash

OBJS_BOOTPACK = bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj int.obj
TOOLPATH = ../tools/
INCPATH  = ../tools/haribote/

MAKE     = make -r
ASM	 = $(TOOLPATH)nask
CC1      = $(TOOLPATH)gocc1 -I$(INCPATH) -Os -Wall -quiet
GAS2NASK = $(TOOLPATH)gas2nask -a
MAKEFONT = $(TOOLPATH)makefont
OBJ2BIM  = $(TOOLPATH)obj2bim
BIN2OBJ  = $(TOOLPATH)bin2obj
BIM2HRB  = $(TOOLPATH)bim2hrb
RULEFILE = $(TOOLPATH)haribote/haribote.rul
EDIMG    = $(TOOLPATH)edimg
#IMGTOL	 = $(TOOLPATH)imgtol.com
COPY     = cat
DEL      = rm -f

default :
	$(MAKE) img
	$(MAKE) clean

ipl.bin : ipl.s Makefile
	$(ASM) ipl.s ipl.bin ipl.lst 

asmhead.bin : asmhead.s Makefile
	$(ASM) asmhead.s asmhead.bin asmhead.lst

hankaku.bin : hankaku.txt Makefile
	$(MAKEFONT) hankaku.txt hankaku.bin

hankaku.obj : hankaku.bin Makefile
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

bootpack.bim : $(OBJS_BOOTPACK) Makefile
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
		$(OBJS_BOOTPACK)
# 3MB+64KB=3136KB

bootpack.hrb : bootpack.bim Makefile
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

toyos.sys : asmhead.bin bootpack.hrb Makefile
	$(COPY) asmhead.bin bootpack.hrb > toyos.sys

toyos.img : ipl.bin toyos.sys Makefile
	$(EDIMG)   imgin:../tools/fdimg0at.tek \
		wbinimg src:ipl.bin len:512 from:0 to:0 \
		copy from:toyos.sys to:@: \
		imgout:toyos.img
	
%.gas : %.c Makefile
	$(CC1) -o $*.gas $*.c

%.s : %.gas Makefile
	$(GAS2NASK) $*.gas $*.s

%.obj : %.s Makefile
	$(ASM) $*.s $*.obj $*.lst

img:
	$(MAKE) toyos.img

asm:
	$(MAKE) ipl.bin
	$(MAKE) toyos.sys


clean:
	-$(DEL) *.bin *.lst *.sys
	-$(DEL) bootpack.map
	-$(DEL) *.gas *.obj
	-$(DEL) bootpack.bim
	-$(DEL) bootpack.hrb

src_only :
	$(MAKE) clean
	-$(DEL) toyos.img


