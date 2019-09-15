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
	call $4ad6
	call $4abe
	call Func193b
	call Func21bb
	call $4b30

INCBIN "baserom.gb",$174,$193b-$174

Func193b:
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

INCBIN "baserom.gb",$1964,$21bb-$1964

Func21bb:
	ld hl, $d099
	xor a
	ldi [hl], a
	ldi [hl], a
	ld a, $12
	ldi [hl], a
	xor a
        ldi [hl], a
        ldi [hl], a
	ld a, $13
	ldi [hl], a
	ld a, $c9
	ld [hl], a
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
INCBIN "baserom.gb",$14000,$4000
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

