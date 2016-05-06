; toyos-ipl
; TAB=4

CYLS	EQU		10              ;number of CYLS to read
		ORG		0x7c00
;disk format
		JMP     entry
		DB		0x90
		DB		"HELLOIPL"		;name of boot sector
		DW		512				;size of sector
		DB		1				;size of cluster
		DW		1				;initial position of FAT
		DB		2				;number of FAT
		DW		224				;size of root directory
		DW		2880			;size of the disk (sectors)
		DB		0xf0			;type of disk
		DW		9				;length of FAT
		DW		18				;number of sectors per track
		DW		2				;number of header
		DD		0				;0 if not using paritition
		DD		2880			;size of disk to be earsed when re-writen
		DB		0,0,0x29		
		DD		0xffffffff		;vol
		DB		"TOY-OS     "
		DB		"FAT12   "
        RESB	18
;
entry:
		MOV		AX,0			
		MOV		SS,AX           ;stack segment set to 0
		MOV		SP,0x7c00       ;stack pointer set to 0x7c00
		MOV		DS,AX           ;set default segment register to 0

; read disk
		MOV		AX,0x0820
		MOV		ES,AX           ;set segment register to 0x0820, then the address [ES:BX] will be ES*16+BX
		MOV		CH,0			; cyclinder 0
		MOV		DH,0			; header 0
		MOV		CL,2			; sector 2

readloop:
        MOV     SI,0            ;use SI to count the failed times
retry:
		MOV		AH,0x02			; AH=0x02 : read disk flag
		MOV		AL,1			; 1 sector
		MOV		BX,0            ; set buffer address ES*16+BX
		MOV		DL,0x00			; A driver
		INT		0x13			; call disk bios to load sectors
        JNC     next            ; jump flow control procedure if no error occer
        ADD     SI,1
        CMP     SI,5
        JAE     error           ;jump to error if SI≥5
        MOV     AH,0x00
        MOV     DL,0x00         ;select A drive
        INT     0x13            ;reset the selected drive
		JMP     retry           ;try again if error occured til SI count to 5
next:
        MOV     AX,ES
        ADD     AX,0x0020
        MOV     ES,AX       	;add 0x020 to ES, equvalent to move memoery buffer position to next 512bytes
        ADD     CL,1            ;sector number increase 1
        CMP     CL,18           ;read til sector 18 (a track)
        JBE     readloop        ;read again if CL≤18
        MOV     CL,1
        ADD     DH,1
        CMP     DH,2            ;compare DH to number of header
        JB      readloop        ;read again if not all surface of this cylinder has been read
        MOV     DH,0
        ADD     CH,1
        CMP     CH,CYLS
        JBE     readloop        ;read again if CH<CYLS
        MOV     [0x0ff0],CH     ;write CYLS into 0xff0
        JMP     0xc200          ;jump to os-code
;
;error print procedure
error:
        MOV		SI,msg          ;source index set to address of msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e         ;indicate AL is a character
		MOV		BX,15			;set character color
		INT		0x10			;call bios of video card
		JMP		putloop
;halt procedure
fin:
		HLT						
		JMP		fin
;
msg:
		DB		0x0a, 0x0a		; "\n\n"
		DB		"load error"
		DB		0x0a			; "\n"
		DB		0
;
		resb	510-($-$$)

		DB		0x55, 0xaa      ;end of first sector
