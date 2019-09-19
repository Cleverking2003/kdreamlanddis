;Addresses
MBC1_BANK EQU $2100
W_CURBANK EQU $d02c
W_HP EQU $d086
W_HP_MAX EQU $d087
W_LIFES EQU $d089
W_SCORE EQU $d08e
W_BOSS_HP EQU $d093
V_SC EQU $9c02
V_SCORE EQU $9c06
V_SCORE_ZERO EQU $9c0b
V_HP_BAR EQU $9c26
V_LIFES EQU $9c30
LCDC EQU $ff40
SCY EQU $ff42
SCX EQU $ff43
LY EQU $ff44
H_DMA_ROUTINE EQU $ff80
;HUD flags:
;bit 7 - boss hp & indicator (instead of score and sc)
;bit 4 - Kirby;s lifes
;bit 2 - Kirby's hp
;bit 1 - 'Sc:' text
;bit 0 - score
H_HUD_FLAGS EQU $ff8f
H_STACK EQU $fffe

;Constants
TILE_HP_SQUARE EQU $68
TILE_BOSS_HP EQU $69
TILE_BOSS EQU $6a
TILE_SC EQU $6c
TILE_HP_DOT EQU $6e
TILE_ZERO EQU $72
TILE_EMPTY EQU $7f

SECTION "rom0", ROM0
INCBIN "baserom.gb",0,$40

SECTION "vblankint", ROM0[$40]
	jp $1d16
SECTION "lcdcint", ROM0[$48]
	jp $1e0f
SECTION "timerint", ROM0[$50]
        jp $1e48
INCBIN "baserom.gb",$53, $100-$53

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
	ld sp, H_STACK
	ld a, 5
	ld [W_CURBANK], a
	ld [MBC1_BANK], a ; switch to bank 5
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

INCBIN "baserom.gb",$1964,$1d16-$1964

VBlankHandler:
	push af
	push bc
	push de
	push hl
	ld hl, $ff8c
	bit 6, [hl]
	jp z, .lab1d9d
	ld hl, $ff91
	bit 2, [hl]
	jp nz, .lab1da4
	ld hl, $d035
	inc [hl]
	ld hl, $d034
	inc [hl]
	ld hl, $d032
	inc [hl]
	call UpdateHUD
	call $1ee3
	call $1e2e
	call H_DMA_ROUTINE
	ld a, [$ff8c]
	and $9f
	ld [$ff8c], a
	call $1dfb
	call $1f08
	call $68e
	jr .lab1d56
.lab1d53:
	call $1dfb
.lab1d56:
	ld hl, $ff91
	res 3, [hl]
	ld hl, $d037
	dec [hl]
	jr nz, .lab1d6f
	ld d, 2
	ld a, [$d036]
	xor 1
	ld [$d036], a
	jr z, .lab1d6e
	inc d
.lab1d6e:
	ld [hl], d
.lab1d6f:
	inc hl
	dec [hl]
	jr nz, .lab1d82
	ld d, 4
	ld a, [$d036]
	xor 2
	ld [$d036], a
	jr z, .lab1d81
	ld d, 6
.lab1d81:
	ld [hl], d
.lab1d82:
	ld a, [W_CURBANK]
	push af
	ld a, 5
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	call $4e0b
	pop af
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	pop hl
	pop de
	pop bc
	pop af
	reti
.lab1d9d:
	ld b, $50
.lab1d9f:
	dec b
	jr nz, .lab1d9f
	jr .lab1d53
.lab1da4:
	ld a, [$d053]
	ld [SCX], a
	ld a, [$d055]
	ld [SCY], a
	ld hl, $cb00
.lab1db1:
	ldi a, [hl]
	and a
	jr z, .lab1dbc
	ld b, a
	ldi a, [hl]
	ld c, a
	ldi a, [hl]
	ld [bc], a
	jr .lab1db1
.lab1dbc:
	ld hl, $ff91
	res 2, [hl]
	jr .lab1d53

INCBIN "baserom.gb",$1dc3,$1e2e-$1dc3

Func1e2e:
	ld hl, $ff96
	bit 7, [hl]
	ret z
	res 7, [hl]
	ld hl, $d029
	ldi a, [hl]
	ld e, a
	ldi a, [hl]
	ld d, a
	ldi a, [hl]
	ld [de], a
	inc e
	ld [de], a
	ld hl, $20
	add hl, de
	ldd [hl], a
	ld [hl], a
	ret

INCBIN "baserom.gb",$1e48,$1fb2-$1e48

UpdateHUD:
	ld hl, $ff8c
	bit 5, [hl]
	ret nz
	ld hl, $ff90
	bit 6, [hl]
	ret nz
	ld a, [H_HUD_FLAGS]
	bit 0, a
	jr z, .draw_sc
	ld hl, V_SCORE
	ld c, 12
.clear_score:
	ld a, TILE_EMPTY
	ldi [hl], a
	dec c
	jr nz, .clear_score
	ld a, [H_HUD_FLAGS]
	bit 7, a
	jr nz, .draw_boss_hp
	ld hl, W_SCORE
	ld bc, V_SCORE
	ld d, 5
.draw_score:
	ldi a, [hl]
	ld [bc], a
	inc bc
	dec d
	jr nz, .draw_score
	ld a, TILE_ZERO
	ld [V_SCORE_ZERO], a
	jr .score_done
.draw_boss_hp:
	ld hl, V_SCORE
	ld a, [W_BOSS_HP]
	and a
	jr z, .score_done
	ld c, a
	ld a, TILE_BOSS_HP
.draw_boss_hp_loop:
	ldi [hl], a
	dec c
	jr nz, .draw_boss_hp_loop
.score_done:
	ld a, [H_HUD_FLAGS]
	res 0, a
	ld [H_HUD_FLAGS], a
.draw_sc:
	ld a, [H_HUD_FLAGS]
	bit 1, a
	jr z, .draw_hp
	res 1, a
	ld [H_HUD_FLAGS], a
	bit 7, a
	jr nz, .draw_mode_boss
	ld a, TILE_EMPTY
	ld [V_SC], a
	ld a, TILE_SC
	ld [V_SC+1], a
	inc a
	ld [V_SC+2], a
	jr .draw_hp
.draw_mode_boss:
	ld a, TILE_EMPTY
	ld [V_SC], a
        ld a, TILE_BOSS
        ld [V_SC+1], a
        ld a, TILE_EMPTY
        ld [V_SC+2], a
.draw_hp:
	ld a, [H_HUD_FLAGS]
	bit 2, a
	jr nz, .draw_lifes
	ld a, [W_HP]
	ld c, a
	ld b, a
	ld hl, V_HP_BAR
	and a
	jr z, .draw_hp_dot
	ld a, TILE_HP_SQUARE
.draw_hp_square_loop:
	ldi [hl], a
	dec c
	jr nz, .draw_hp_square_loop
.draw_hp_dot:
	ld a, [W_HP_MAX]
	sub b
	ld b, a
	jr z, .draw_empty
	ld a, TILE_HP_DOT
.draw_hp_dot_loop:
	ldi [hl], a
	dec b
	jr nz, .draw_hp_dot_loop
.draw_empty:
	ld a, TILE_EMPTY
	ldi [hl], a
.draw_lifes:
	ld a, [H_HUD_FLAGS]
	bit 4, a
	ret z
	res 4, a
	ld [H_HUD_FLAGS], a
	ld a, [W_LIFES]
	dec a
	call $1c6b ;convert lifes to dec
	add TILE_ZERO
	ld [V_LIFES+1], a
	ld a, b
	add TILE_ZERO
	ld [V_LIFES], a
	ret

INCBIN "baserom.gb",$2070,$20da-$2070

;TODO: what's this?
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
	jr nz, .lab20fc
.lab20ec:
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
.lab20fc:
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
	jr nz, .lab2154
.lab210b:
	cp $20
	jr z, .lab2124
.lab210f:
	cp $40
	jr z, .lab2131
.lab2113:
	cp $60
	jr z, .lab2146
.lab2117:
	dec c
	jr nz, .lab211e
.lab211a:
	dec b
	jp z, .lab20e2
.lab211e:
	ldi a, [hl]
	call $d099
	jr .lab2117
.lab2124:
	ldi a, [hl]
.lab2125:
	dec c
	jr nz, .lab212c
.lab2128:
	dec b
	jp z, .lab20e2
.lab212c:
	call $d099
	jr .lab2125
.lab2131:
	dec c
	jr nz, .lab2138
.lab2134:
	dec b
	jp z, .lab2142
.lab2138:
	ldi a, [hl]
	call $d099
	ldd a, [hl]
	call $d099
	jr .lab2131
.lab2142:
	inc hl
	inc hl
	jr .lab20e2
.lab2146:
	ldi a, [hl]
.lab2147:
	dec c
	jr nz, .lab214e
.lab214a:
	dec b
	jp z, .lab20e2
.lab214e:
	call $d099
	inc a
	jr .lab2147
.lab2154:
	push hl
	push af
	ldi a, [hl]
	ld l, [hl]
	ld h, a
	ld a, [$d097]
	add l
	ld l, a
	ld a, [$d098]
	adc h
	ld h, a
	pop af
	cp $80
	jr z, .lab2170
.lab2168:
	cp $a0
	jr z, .lab217b
.lab216c:
	cp $c0
	jr z, .lab2193
.lab2170:
	dec c
	jr nz, .lab2176
.lab2173:
	dec b
	jr z, .lab219f
.lab2176:
	ldi a, [hl]
	ld [de], a
	inc de
	jr .lab2170
.lab217b:
	dec c
	jr nz, .lab2182
.lab217e:
	dec b
	jp z, .lab219f
.lab2182:
	ldi a, [hl]
	push bc
	ld bc, 8
.lab2187:
	rra
	rl b
	dec c
	jr nz, .lab2187
.lab218d:
	ld a, b
	pop bc
	ld [de], a
	inc de
	jr .lab217b
.lab2193:
	dec c
	jr nz, .lab219a
.lab2196:
	dec b
	jp z, .lab219f
.lab219a:
	ldd a, [hl]
	ld [de], a
	inc de
	jr .lab2193
.lab219f:
	pop hl
	inc hl
	inc hl
	jp .lab20e2

INCBIN "baserom.gb", $21a5, $21bb-$21a5

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

