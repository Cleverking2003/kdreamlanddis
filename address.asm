; Addresses
; MBC1 regs
MBC1_BANK EQU $2100

; WRAM
; OAM is copied from here
W_OAM_COPY EQU $c000
; Full level is stored here
W_LEVEL EQU $c600
; Level frame is copied from here
W_LEVEL_FRAME EQU $cb00
; Current bank
W_CURBANK EQU $d02c
; Size of level frame
W_FRAME_SIZE EQU $d03f
; Level frame copy counter
W_COPY_COUNT EQU $d057
; Kirby's hp
W_HP EQU $d086
; Max Kirby's hp
W_HP_MAX EQU $d087
; Kirby's lifes
W_LIFES EQU $d089
; Score
W_SCORE EQU $d08e
; Boss' hp
W_BOSS_HP EQU $d093
; Hide sprites from this address
W_OAM_OFFSET EQU $d095
; Hide all sprites if this = $ff
W_HIDE_ALL EQU $d096

; VRAM
; 'Sc:' text 
V_SC EQU $9c02
; Score display
V_SCORE EQU $9c06
; Score's last digit (0)
V_SCORE_ZERO EQU $9c0b
; Kirby's hp bar
V_HP_BAR EQU $9c26
; Kirby's lifes
V_LIFES EQU $9c30
; Level frame
V_LEVEL EQU $9800

; IO regs
; LCD control
LCDC EQU $ff40
; Scroll y, x
SCY EQU $ff42
SCX EQU $ff43
; Scanline
LY EQU $ff44
; DMA
DMA EQU $ff46

; HRAM
; DMA OAM routine
H_DMA_ROUTINE EQU $ff80
; Screen update flags
H_DRAW_FLAGS EQU $ff8c
; HUD update flags:
; bit 7 - boss hp & indicator (instead of score and sc)
; bit 4 - Kirby's lifes
; bit 2 - Kirby's hp
; bit 1 - 'Sc:' text
; bit 0 - score
H_HUD_FLAGS EQU $ff8f
; Stack start
H_STACK EQU $fffe

