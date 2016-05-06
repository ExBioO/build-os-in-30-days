#include <stdio.h>
#include "bootpack.h"

void HariMain(void)
{
    struct BOOTINFO *binfo=(struct BOOTINFO*) ADR_BOOTINFO;
    char s[40], mcursor[256];
    
    init_gdtidt();
    init_pic();
    io_sti(); /* IDT/PICの初期化が終わったのでCPUの割り込み禁止を解除 */

    init_palette();
    init_screen8(binfo->vram, binfo->scrnx, binfo->scrny);
    
    putfonts8_asc(binfo->vram, binfo->scrnx, 9, 9, COL8_000000, "ToyOS.");
    putfonts8_asc(binfo->vram, binfo->scrnx, 8, 8, COL8_FFFFFF, "ToyOS.");
    init_mouse_cursor8(mcursor, COL8_008484);
    putblock8_8(binfo->vram, binfo->scrnx, 16, 16, 160, 100, mcursor, 16);
    sprintf(s, "scrnx = %d", binfo->scrnx);
    putfonts8_asc(binfo->vram, binfo->scrnx, 16, 64, COL8_FFFFFF,s);
    sprintf(s, "scrny = %d", binfo->scrny);
    putfonts8_asc(binfo->vram, binfo->scrnx, 16,80, COL8_FFFFFF, s);
    
    io_out8(PIC0_IMR, 0xf9); /* PIC1とキーボードを許可(11111001) */
    io_out8(PIC1_IMR, 0xef); /* マウスを許可(11101111) */
    
    while (1){
        io_hlt(); /* これでnaskfunc.nasの_io_hltが実行されます */
    }
}