SECTION "rom0", ROM0
INCBIN "baserom.gb",0    ,$100

SECTION "header", ROM0[$100]
nop
jp Start

SECTION "game", ROM0[$150]
Start:
	ld a, [$ff44]
	cp $91
	jr C, Start
	xor a
	ld [$ff40], a
	di
	ld sp, $fffe
	ld a, $5
	ld [$d02c], a
	ld [$2100], a ; switch to bank 5
	call MemInit
	call CopyDMARoutine
	call FillSomethingWithZeroes
	call InitWRAMRoutine
	call Func4b30

INCBIN "baserom.gb",$174,$193b-$174

FillSomethingWithZeroes: ;TODO: why??
	ld a, [$d096]
	inc a
	jr nZ, .lab194d
	ld a, $a0
	ld c, a
	ld [$d096], a
	xor a
	ld [$d095], a
	jr .lab1955
.lab194d:
	ld a, [$d095]
	ld [$d096], a
	ld c, $a0
.lab1955:
	ld l, a
	ld h, $c0
	ld de, 4
	ld b, 0
.lab195d:
	ld [hl], b
	add hl, de
	ld a, l
	cp c
	jr nZ, .lab195d
	ret

INCBIN "baserom.gb",$1964,$20da-$1964

Func20da:
    	ld a, e
        ld [$d097], a
        ld a, d
        ld [$d098], a
.lab20e2:
	ld a, [hl]
	cp $ff
	ret z
	and $e0
	cp $e0
	jr nz, $20fc
	ld a, [hl]
	add a
	add a
	add a
	and $e0
	push af
	ldi a, [hl]
	and 3
	ld b, a
	ldi a, [hl]
	ld c, a
	inc bc
	jr .lab2104
	push af
	ldi a, [hl]
	and $1f
	ld c, a
	ld b, 0
	inc c
.lab2104:
	inc b
	inc c
	pop af
	bit 7, a
	jr nz, $2154
	cp $20
	jr z, $2124
	cp $40
	jr z, $2131
	cp $60
	jr z, $2146
.lab2117:
	dec c
	jr nz, .lab211e
	dec b
	jp z, .lab20e2
.lab211e:
	ldi a, [hl]
	call $d099
	jr .lab2117

INCBIN "baserom.gb", $2124, $21bb-$2124

InitWRAMRoutine:
	ld hl, $d099
	xor a
	ldi [hl], a	; nop
	ldi [hl], a	; nop
	ld a, $12	
	ldi [hl], a	; ld [de], a
	xor a
        ldi [hl], a	; nop
        ldi [hl], a	; nop
	ld a, $13
	ldi [hl], a	; inc de
	ld a, $c9
	ld [hl], a	; ret
	ret

INCBIN "baserom.gb",$21ce,$4000-$21ce

SECTION "rom1", ROMX,BANK[1]
INCBIN "baserom.gb",$4000,$4000
SECTION "rom2", ROMX,BANK[2]
INCBIN "baserom.gb",$8000,$4000
SECTION "rom3", ROMX,BANK[3]
INCBIN "baserom.gb",$c000,$4000
SECTION "rom4", ROMX,BANK[4]
INCBIN "baserom.gb",$10000,$4000
SECTION "rom5", ROMX,BANK[5]
INCBIN "baserom.gb",$14000,$abe

CopyDMARoutine:
	ld c, $80
	ld b, $a
	ld hl, DMARoutine
.copy_loop:
	ldi a, [hl]
	ld [c], a
	inc c
	dec b
	jr nz, .copy_loop
	ret

DMARoutine:
	ld a, $c0
	ld [$ff46], a
	ld a, $28
.wait_loop:
	dec a
	jr nz, .wait_loop
	ret

MemInit:
	ld hl, $c000
.clear_wram_loop:
	xor a
	ldi [hl], a
	ld a, $e0
	cp h
	jr nz, .clear_wram_loop
	ld hl, $ff8a
.clear_hram_loop:
        xor a
        ldi [hl], a
        ld a, l
        cp $97
        jr nz, .clear_hram_loop
	ld a, 1
	ld [$d051], a
	ld [$d052], a
	ld [$d074], a
	ld a, $30
	ld [$d05c], a
	ld a, 0
        ld [$d05d], a
	ld a, $ff
        ld [$d096], a
        ld [$d03d], a
	xor a
	ld [hl], a
	ld a, $e4
        ld [$d080], a
	ld a, $d0
        ld [$d081], a
	ld a, $c0
	DB $ea, $8c, $ff ;ld [$ff8c], a ;rgbasm can't assemble this properly
	ld a, 0
	DB $ea, $8d, $ff ;ld [$ff8d], a
	ld a, $c
        ld [$d050], a
	ld a, 1
        ld [$d048], a
	ld hl, $d02f
	ldi [hl], a
	inc a
	ldi [hl], a
	inc a
	ld [hl], a
	ret

Func4b30:
	ld hl, $4b3a
	ld de, $dc00
	call $20da
	ret

INCBIN "baserom.gb",$14b3a, $4000-$b3a

SECTION "rom6", ROMX,BANK[6]
INCBIN "baserom.gb",$18000,$4000
SECTION "rom7", ROMX,BANK[7]
INCBIN "baserom.gb",$1c000,$4000
SECTION "rom8", ROMX,BANK[8]
INCBIN "baserom.gb",$20000,$4000
SECTION "rom9", ROMX,BANK[9]
INCBIN "baserom.gb",$24000,$4000
SECTION "roma", ROMX,BANK[$a]
INCBIN "baserom.gb",$28000,$4000
SECTION "romb", ROMX,BANK[$b]
INCBIN "baserom.gb",$2c000,$4000
SECTION "romc", ROMX,BANK[$c]
INCBIN "baserom.gb",$30000,$4000
SECTION "romd", ROMX,BANK[$d]
INCBIN "baserom.gb",$34000,$4000
SECTION "rome", ROMX,BANK[$e]
INCBIN "baserom.gb",$38000,$4000
SECTION "romf", ROMX,BANK[$f]
INCBIN "baserom.gb",$3c000,$4000

