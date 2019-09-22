include "address.asm"
include "constants.asm"

ldHigh: macro
	db $ea, \1, $ff
	endm
ldFromHigh: macro
	db $fa, \1, $ff
	endm

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
	ld a, [LY]
	cp $91
	jr C, Start
	xor a
	ld [LCDC], a
	di
	ld sp, H_STACK
	ld a, 5
	ld [W_CURBANK], a
	ld [MBC1_BANK], a ; switch to bank 5
	call MemInit
	call CopyDMARoutine
	call HideSprites
	call InitWRAMRoutine
	call Func4b30
	ld a, 5
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	call InitSound
	ld a, 1
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	call InitWindow
	ld a, $e4
	ld [OBP1], a
	ld a, 8
	ld [SCY], a
	ld [$d055], a
	xor a
	ld [SCX], a
	ld [$d053], a
	ld [INTF], a
	ld a, $40
	ld [STAT], a
	ld a, $e7
	ld [$ff8a], a
	ld [LCDC], a
	ld a, 5
	ld [INTE], a
	ei 
	xor a
	ld [H_DRAW_FLAGS], a
	ld [$d03a], a
	ld a, 6
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	ld a, 5
	ld [$d08a], a
	ld a, 6
	ld [$d088], a
	call $4000

INCBIN "baserom.gb",$1c7,$131a-$1c7

; a - offset from $c600 div 4
; copies level block to de
CopyLevelBlock:
	push bc
	push hl
	ld l, a
	ld h, 0
	add hl, hl
	add hl, hl
	ld bc, W_LEVEL
	add hl, bc
	ld a, [W_COPY_COUNT]
	ld [$d06b], a
	ld a, [W_COPY_COUNT+1]
	ld [$d06c], a
	ld [$d07f], a
	call CopyBlockHeader
	ldi a, [hl]
	ld [de], a
	inc de
	ldi a, [hl]
	ld [de], a
	inc de
	ldi a, [hl]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	inc de
	ld a, [$d06b]
	ld [W_COPY_COUNT], a
	ld a, [$d06c]
	ld [W_COPY_COUNT+1], a
	pop hl
	pop bc
	ret

CopyBlockHeader:
	push bc
	push hl
	ld hl, V_LEVEL
	ld a, [W_COPY_COUNT]
	srl a
	srl a
	srl a
	ld [$d06e], a
	ld a, [W_COPY_COUNT+1]
	srl a
	srl a
	srl a
	jr z, .copy_addr
	ld bc, $20
.get_offset:
	add hl, bc
	dec a
	jr nz, .get_offset
.copy_addr:
	ld b, 0
	ld a, [$d06e]
	ld c, a
	add hl, bc
	ld a, h
	ld [de], a
	inc de
	ld a, l
	ld [de], a
	inc de
	pop hl
	pop bc
	ret

INCBIN "baserom.gb",$1385,$193b-$1385

; d095 - begin offset
; d096 - if equals $ff, hide all
HideSprites:
	ld a, [W_HIDE_ALL]
	inc a
	jr nZ, .not_all
	ld a, $a0
	ld c, a
	ld [$d096], a
	xor a
	ld [$d095], a
	jr .set_regs
.not_all:
	ld a, [W_OAM_OFFSET]
	ld [W_HIDE_ALL], a
	ld c, $a0
.set_regs:
	ld l, a
	ld h, $c0
	ld de, 4
	ld b, 0
.hide_loop:
	ld [hl], b
	add hl, de
	ld a, l
	cp c
	jr nZ, .hide_loop
	ret

; hl - pointer to block
CopyLevelFrame:
	push bc
	push de
	xor a
	ld [W_COPY_COUNT], a
	ld [W_COPY_COUNT+1], a
	ld de, W_LEVEL_FRAME
	ld a, $a
	ld b, a
.copy_loop:
	ld a, [W_FRAME_SIZE]
	cp $a
	jr z, .last_blocks
	ld a, $b
.last_blocks:
	ld c, a
.copy_blocks:
	ldi a, [hl]
	call CopyLevelBlock
	ld a, [W_COPY_COUNT]
	add $10
	ld [W_COPY_COUNT], a
	dec c
	jr nz, .copy_blocks
	push bc
	ld b, 0
	ld a, [W_FRAME_SIZE]
	sub $a
	jr z, .last2
	sub 1
.last2:
	ld c, a
	add hl, bc
	pop bc
	xor a
	ld [W_COPY_COUNT], a
	ld a, [W_COPY_COUNT+1]
	add $10
	ld [W_COPY_COUNT+1], a
	dec b
	jr nz, .copy_loop
	xor a
	ld [de], a
	ld [W_COPY_COUNT], a
	ld [W_COPY_COUNT+1], a
	xor a
	ld [SCX], a
	ld [SCY], a
	ld a, [H_DRAW_FLAGS]
	or $60
	ld [H_DRAW_FLAGS], a
	call CopyLevelToVRAM
	ld a, [$d06b]
	xor a
	ld [H_DRAW_FLAGS], a
	pop de
	pop bc
	ret

INCBIN "baserom.gb",$19c9,$1c01-$19c9

InitWindow:
	ld a, $a0
	ld [WX], a
	ld a, $90
	ld [WY], a
	ret

INCBIN "baserom.gb",$1c0a,$1c6b-$1c0a

; Get digits of a 
; c - hundreds, b - tens, a - ones
GetDigits:
	ld b, $ff
	ld c, b
.count_hundreds:
	inc c
	sub 100
	jr nc, .count_hundreds
	add 100
.count_tens:
	inc b
	sub 10
	jr nc, .count_tens
	add 10
	ret

INCBIN "baserom.gb",$1c7d,$1d16-$1c7d

VBlankHandler:
	push af
	push bc
	push de
	push hl
	ld hl, H_DRAW_FLAGS
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
	call CopyLevelToVRAM
	call Func1e2e
	call H_DMA_ROUTINE
	ld a, [H_DRAW_FLAGS]
	and $9f
	ld [H_DRAW_FLAGS], a
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

INCBIN "baserom.gb",$1e48,$1ee3-$1e48

; level data is stored in blocks
; 2 bytes - address in VRAM
; 4 bytes - actual tiles
CopyLevelToVRAM:
	ld a, [H_DRAW_FLAGS]
	bit 6, a
	ret z
	bit 5, a
	ret z
	ld bc, W_LEVEL_FRAME
.copy_loop:
	ld a, [bc]
	inc bc
	ld h, a
	and a
	ret z
	ld a, [bc]
	inc bc
	ld l, a
	ld a, [bc]
	inc bc
	ldi [hl], a
	ld a, [bc]
	inc bc
	ld [hl], a
	ld a, [bc]
	inc bc
	ld de, $1f
	add hl, de
	ldi [hl], a
	ld a, [bc]
	inc bc
	ld [hl], a
	jr .copy_loop

INCBIN "baserom.gb",$1f08,$1fb2-$1f08

UpdateHUD:
	ld hl, H_DRAW_FLAGS
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
	call GetDigits
	add TILE_ZERO
	ld [V_LIFES+1], a
	ld a, b
	add TILE_ZERO
	ld [V_LIFES], a
	ret

INCBIN "baserom.gb",$2070,$20c1-$2070

; c - bank to switch to
SwitchAndDecompress:
	ld a, [W_CURBANK]
	push af
	ld a, c
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	ld [MBC1_BANK], a
	call Decompress
	pop af
	ld [W_CURBANK], a
	ld [MBC1_BANK], a
	ret

; Some kind of decompression
; hl - source
; de - destination
Decompress:
	ld a, e
	ld [$d097], a
	ld a, d
	ld [$d098], a
.read_flags:
	ld a, [hl]
	cp $ff ; end byte
	ret z
	and $e0
	cp $e0
	jr nz, .flags_ready
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
	jr .check_flags
.flags_ready:
	push af
	ldi a, [hl]
	and $1f
	ld c, a
	ld b, 0
	inc c
.check_flags:
	inc b
	inc c
	pop af
	bit 7, a
	jr nz, .flag_offset
	cp $20
	jr z, .copy_same
	cp $40
	jr z, .copy_loop_by2
	cp $60
	jr z, .copy_inc
.copy_loop_by1:
	dec c
	jr nz, .copy_byte
	dec b
	jp z, .read_flags
.copy_byte:
	ldi a, [hl]
	call $d099
	jr .copy_loop_by1
.copy_same:
	ldi a, [hl]
.copy_same_loop:
	dec c
	jr nz, .copy_same_byte
	dec b
	jp z, .read_flags
.copy_same_byte:
	call $d099
	jr .copy_same_loop
.copy_loop_by2:
	dec c
	jr nz, .copy_2bytes
	dec b
	jp z, .copy_by2_done
.copy_2bytes:
	ldi a, [hl]
	call $d099
	ldd a, [hl]
	call $d099
	jr .copy_loop_by2
.copy_by2_done:
	inc hl
	inc hl
	jr .read_flags
.copy_inc:
	ldi a, [hl]
.copy_inc_loop:
	dec c
	jr nz, .copy_inc_byte
	dec b
	jp z, .read_flags
.copy_inc_byte:
	call $d099
	inc a
	jr .copy_inc_loop
.flag_offset:
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
	jr z, .copy_by1_off
	cp $a0
	jr z, .copy_off_rot
	cp $c0
	jr z, .copy_off_reverse
.copy_by1_off:
	dec c
	jr nz, .copy_by1_off_byte
	dec b
	jr z, .off_complete
.copy_by1_off_byte:
	ldi a, [hl]
	ld [de], a
	inc de
	jr .copy_by1_off
.copy_off_rot:
	dec c
	jr nz, .copy_off_rot_load
	dec b
	jp z, .off_complete
.copy_off_rot_load:
	ldi a, [hl]
	push bc
	ld bc, 8
.copy_off_rot_loop:
	rra
	rl b
	dec c
	jr nz, .copy_off_rot_loop
	ld a, b
	pop bc
	ld [de], a
	inc de
	jr .copy_off_rot
.copy_off_reverse:
	dec c
	jr nz, .copy_reverse
	dec b
	jp z, .off_complete
.copy_reverse:
	ldd a, [hl]
	ld [de], a
	inc de
	jr .copy_off_reverse
.off_complete:
	pop hl
	inc hl
	inc hl
	jp .read_flags

INCBIN "baserom.gb", $21a5, $21bb-$21a5

; Some sort of 'ldi [de], a'
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
MainTiles:
INCBIN "baserom.gb",$8000,$37e9
Font:
INCBIN "baserom.gb",$b7e9,$4000-$37e9
SECTION "rom3", ROMX,BANK[3]
TitleMap:
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
	ld [DMA], a
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
	ldHigh $8c ;ld [$ff8c], a
	ld a, 0
	ldHigh $8d ;ld [$ff8d], a
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
	call Decompress
	ret

INCBIN "baserom.gb",$14b3a, $c4a-$b3a

InitSound:
	ld a, $80
	ld [SND_POW], a
	ld a, $77
	ld [SND_CH], a
	ld a, $ff
	ld [SND_SEL], a
	ld a, $ff
	ld [$de01], a
	ld [$de02], a
	ld [$ded2], a
	ld hl, $de06
	ld b, $14
	ld a, $aa
.copy_loop:
	ldi [hl], a
	dec b
	jr nz, .copy_loop
	ld hl, $7aa9
	call $5305
	ld a, $ff
	call $4dc5
	ld a, $ff
	call $4c9e
	call $4e76
	ld hl, $ff14
	set 7, [hl]
	ld hl, $ff19
	set 7, [hl]
	ld hl, $ff1e
	set 7, [hl]
	ld hl, $ff23
	set 7, [hl]
	ld a, $13
	ld [$ded3], a
	ld a, $24
	ld [$ded4], a
	ret

INCBIN "baserom.gb", $14c9e, $4000-$c9e

SECTION "rom6", ROMX,BANK[6]

LoadTitleScreen:
	ld a, $ff
	ld [$d096], a
	call HideSprites
	call $1e74
	xor a
	ld [$d095], a
	ld [$d053], a
	ld [$d081], a
	ld [$d080], a
	ld a, 0
	ld [$d055], a
	ld hl, MainTiles
	ld de, $8000
	ld c, bank(MainTiles)
	call SwitchAndDecompress
	ld hl, TitleKirby
	ld de, $8800
	ld c, bank(TitleKirby)
	call SwitchAndDecompress
        ld hl, GameLogo
        ld de, $9000
        ld c, bank(GameLogo)
        call SwitchAndDecompress
        ld hl, Font
        ld de, $8e00
        ld c, bank(Font)
        call SwitchAndDecompress
        ld hl, TitleMap
        ld de, $9800
        ld c, bank(TitleMap)
        call SwitchAndDecompress
	ld a, 5
	call $1eb4
	ld a, 1
	call $21fb
	call $1e67
	xor a
	ldHigh $90
	ld a, 4
	ldHigh $8f
	call $40a0
	ld a, 1
	call $1dc3
	call $670
	ld a, 8
	ld [$d050], a
.lab407a:
	ld a, 1
	call $1dc3
	ldFromHigh $8b
	cp $86
	jp z, $6386
	cp $45
	jr nz, .lab4093
	ld a, 1
	ld [$d03a], a
	call $40a0
.lab4093:
	ldFromHigh $8b
	and 8
	jr z, .lab407a
	ld a, $1b
	call $1e96
	ret

INCBIN "baserom.gb",$180a0,$4000-$a0

SECTION "rom7", ROMX,BANK[7]
INCBIN "baserom.gb",$1c000,$4000
SECTION "rom8", ROMX,BANK[8]
INCBIN "baserom.gb",$20000,$4000
SECTION "rom9", ROMX,BANK[9]
INCBIN "baserom.gb",$24000,$4000
SECTION "roma", ROMX,BANK[$a]
TitleKirby:
INCBIN "baserom.gb",$28000,$2ac
GameLogo:
INCBIN "baserom.gb",$282ac,$4000-$2ac
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

