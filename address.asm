; Addresses
; MBC1 regs
mbcBank EQU $2100

; WRAM
; OAM is copied from here
wOamCopy EQU $c000
; Full level is stored here
wLevel EQU $c600
; Level frame is copied from here
wLevelFrame EQU $cb00
; Current bank
wCurBank EQU $d02c
; Size of level frame
wFrameSize EQU $d03f
; Level frame copy counter
wCopyCount EQU $d057
; Kirby's hp
wHp EQU $d086
; Max Kirby's hp
wHpMax EQU $d087
; Kirby's lifes
wLifes EQU $d089
; Score
wScore EQU $d08e
; Boss' hp
wBossHp EQU $d093
; Hide sprites from this address
wOamOffset EQU $d095
; Hide all sprites if this = $ff
wHideAll EQU $d096
; Routine, which imitates 'ldi [de], a'
wWramRoutine equ $d099

; VRAM
; 'Sc:' text 
vSc EQU $9c02
; Score display
vScore EQU $9c06
; Score's last digit (0)
vScoreZero EQU $9c0b
; Kirby's hp bar
vHpBar EQU $9c26
; Kirby's lifes
vLifes EQU $9c30
; Level frame
vLevel EQU $9800

; IO regs
; Interrupt flags
rIF EQU $ff0f
; Channel control
rSNDCH EQU $ff24
; Sound terminal selection
rSNDSEL EQU $ff25
; Sound on/off
rSNDPOW EQU $ff26
; LCD control
rLCDC EQU $ff40
; LCD status
rSTAT EQU $ff41
; Scroll y, x
rSCY EQU $ff42
rSCX EQU $ff43
; Scanline
rLY EQU $ff44
; DMA
rDMA EQU $ff46
; BG palette
rBGP EQU $ff47
; Object palletes
rOBP0 EQU $ff48
rOBP1 EQU $ff49
; Window y/x
rWY EQU $ff4a
rWX EQU $ff4b
; Interrupt enable
rIE EQU $ffff

; HRAM
; DMA OAM routine
hDmaRoutine EQU $ff80
; Screen update flags
hDrawFlags EQU $ff8c
; HUD update flags:
; bit 7 - boss hp & indicator (instead of score and sc)
; bit 4 - Kirby's lifes
; bit 2 - Kirby's hp
; bit 1 - 'Sc:' text
; bit 0 - score
hHudFlags EQU $ff8f
; Stack start
hStack EQU $fffe

