;toyos
;tab=4

;boot_info
CYLS    EQU     0x0ff0      ;set launch area
LEDS    EQU     0x0ff1
VMODE   EQU     0x0ff2      ;bit length of color
SCRNX   EQU     0x0ff4      ;resolution x
SCRNY   EQU     0x0ff6      ;resolution y
VRAM    EQU     0x0ff8      ;start address of video buffer

		ORG		0xc200
        MOV     AL,0x13     ;VGA card, 320*200*8
        MOV     AH,0x00
        INT     0x10
        MOV     BYTE [VMODE], 8
        MOV     WORD [SCRNX], 320
        MOV     WORD [SCRNX], 200
        MOV     DWORD [VRAM], 0x000a000
;show state of led on keyboard by calling bios
        MOV     AH, 0x02
        INT     0x16
        MOV     [LEDS], AL

;now halt
fin:
		HLT
		JMP		fin
