
;;; ********************************************
;;; Name:       DisPause
;;; Author:     Roberto Vargas Caballero (k0ga)
;;; Date:       18-03-2008
;;; Assembler:  TniASM
;;; Function:   Disable Pause key in R800
;;; Modify:     A,HL
;;; *********************************************

dispause:

    ld a, (exptbl)
    ld hl, 0x002d  ;
    call rdslt
    cp 3
    ret nz


    ld a, (0xfcb1)  ; disable pause key
    res 1, a
    out (0x00a7), a
    ret






;;; Name:       InstallInt
;;; Function:   Install a new ISR
;;; Entry:
;;;     hl -> pointer to the new ISR
;;; Modify:     hl,de,bc




_installint:
    di
    push hl
    ld hl, h.keyi
    ld de, oldisr
    ld bc, 5
    ldir

    pop hl
    ld a, 0x00c3
    ld (h.keyi), a
    ld (h.keyi + 1), hl
    ret





;;; Name:       DeinstallInt
;;; Function:   Restore default ISR
;;; Entry:
;;;     hl -> Pointer to the new ISR
;;; Modify:     hl,de,bc



_deinstallint:
    di
    ld hl, oldisr
    ld de, h.keyi
    ld bc, 5
    ldir
    ret



loadmazer:
    ld de, loadmazer.mazefiles - 1


loadmazer.loop:
    push hl
    push de
    ld b, 6

loadmazer.strcmp:
    inc hl
    inc de
    ld a, (de)
    cp (hl)
    jr nz, loadmazer.next
    djnz loadmazer.strcmp
    jr loadmazer.found

loadmazer.next:    pop hl
    ld de, 9
    add hl, de
    ex de, hl
    pop hl
    jr loadmazer.loop


loadmazer.found:    pop de
    pop hl
    ld hl, 7
    add hl, de

    ld a, (hl)

    inc hl
    ld e, (hl)
    inc hl
    ld d, (hl)

    ex de, hl
    ld de, 0xd000
    ld bc, 3832
    call _8kldir
loadmazer.l:    ret






loadmazer.mazefiles:
    db "MAZE00"
    db maze00 >> 13 + 5
;dw      maze00&01fffh | 6000h
    dw maze00 & 0x1fff | 0x6000

    db "MAZE01"
    db maze01 >> 13 + 5
    dw maze01 & 0x1fff | 0x6000

    db "MAZE02"
    db maze02 >> 13 + 5
    dw maze02 & 0x1fff | 0x6000

    db "MAZE03"
    db maze03 >> 13 + 5
    dw maze03 & 0x1fff | 0x6000

    db "MAZE04"
    db maze04 >> 13 + 5
    dw maze04 & 0x1fff | 0x6000

    db "MAZE05"
    db maze05 >> 13 + 5
    dw maze05 & 0x1fff | 0x6000

    db "MAZE06"
    db maze06 >> 13 + 5
    dw maze06 & 0x1fff | 0x6000

    db "MAZE07"
    db maze07 >> 13 + 5
    dw maze07 & 0x1fff | 0x6000

    db "MAZE08"
    db maze08 >> 13 + 5
    dw maze08 & 0x1fff | 0x6000

    db "MAZE09"
    db maze09 >> 13 + 5
    dw maze09 & 0x1fff | 0x6000

    db "MAZE10"
    db maze10 >> 13 + 5
    dw maze10 & 0x1fff | 0x6000

    db "MAZE11"
    db maze11 >> 13 + 5
    dw maze11 & 0x1fff | 0x6000

    db "MAZE12"
    db maze12 >> 13 + 5
    dw maze12 & 0x1fff | 0x6000

    db "MAZE13"
    db maze13 >> 13 + 5
    dw maze13 & 0x1fff | 0x6000

    db "MAZE14"
    db maze14 >> 13 + 5
    dw maze14 & 0x1fff | 0x6000

    db "MAZE15"
    db maze15 >> 13 + 5
    dw maze15 & 0x1fff | 0x6000

    db "MAZE16"
    db maze16 >> 13 + 5
    dw maze16 & 0x1fff | 0x6000

    db "MAZE17"
    db maze17 >> 13 + 5
    dw maze17 & 0x1fff | 0x6000

    db "MAZE18"
    db maze18 >> 13 + 5
    dw maze18 & 0x1fff | 0x6000

    db "MAZE19"
    db maze19 >> 13 + 5
    dw maze19 & 0x1fff | 0x6000

    db "MAZE20"
    db maze20 >> 13 + 5
    dw maze20 & 0x1fff | 0x6000

    db "MAZE21"
    db maze21 >> 13 + 5
    dw maze21 & 0x1fff | 0x6000

    db "MAZE22"
    db maze22 >> 13 + 5
    dw maze22 & 0x1fff | 0x6000

    db "MAZE23"
    db maze23 >> 13 + 5
    dw maze23 & 0x1fff | 0x6000

    db "MAZE24"
    db maze24 >> 13 + 5
    dw maze24 & 0x1fff | 0x6000

    db "MAZE25"
    db maze25 >> 13 + 5
    dw maze25 & 0x1fff | 0x6000

    db "MAZE26"
    db maze26 >> 13 + 5
    dw maze26 & 0x1fff | 0x6000

    db "MAZE27"
    db maze27 >> 13 + 5
    dw maze27 & 0x1fff | 0x6000

    db "MAZE28"
    db maze28 >> 13 + 5
    dw maze28 & 0x1fff | 0x6000

    db "MAZE29"
    db maze29 >> 13 + 5
    dw maze29 & 0x1fff | 0x6000

    db "MAZE30"
    db maze30 >> 13 + 5
    dw maze30 & 0x1fff | 0x6000




;;; Name:       8KLdir
;;; Author:     Roberto Vargas Caballero
;;; Function:   Ldir from 8k rom ascii8 mapper (6000h-8000h page)
;;; Input:
;;;             hl -> source
;;;             de -> destinity
;;;             bc -> number of bytes
;;;             a -> offset in pages
;;; Modify:     de,hl,bc,af




_8kldir:
    ld (0x6800), a

_8kldir.loop:
    bit 7, h
    jr z, _8kldir.copy
    ld h, 0x60
    inc a
    ld (0x6800), a
_8kldir.copy:    ldi
    jp pe, _8kldir.loop
    ret
; *** MEMORY SUBROUTINES ***

ram8k: equ 0
ram16k: equ 1
ram32k: equ 2
ram48k: equ 3
ram64k: equ 4

; Especiales para lineal y carga de Roms

noraml: equ 0  ; No hay Ram para cargar algo de 16k
raml16k: equ 1  ; Podemos cargar algo de 16k
raml32k: equ 2  ; Podemos cargar algo de 32k linealmente
raml48k: equ 3  ; Podemos cargar algo de 48k linealmente



bottom: equ 0xfc48




; *** BUSQUEDA NORMAL DE 1 SLOT CON RAM PARA CADA PAGINA ***

; ---------------------------
; SEARCHRAMNORMAL
; Busca la 64k de Ram
; Independiente slot
; ---------------------------

searchramnormal:
    ld a, ram8k
    ld (ramtypus), a
    ld a, (exptbl)
    ld (rampage0), a
    ld (rampage1), a
    ld (rampage2), a
    ld (rampage3), a

    xor a
    ld (ramcheck0), a
    ld (ramcheck1), a
    ld (ramcheck2), a
    ld (ramcheck3), a


    call search_slotram  ; Cogemos la Ram de sistema,
;porque el sistema ya entiende que es la mejor
    ld a, (slotram)
    ld (rampage3), a

; Comprobar 8k o 16k

    ld c, 0x00c0
    call checkmemdirect
    jr c, searchramnormalend

    ld a, ram16k
    ld (ramtypus), a



searchramnormal00:
; Buscamos Ram en las otras paginas

    ld c, 0x00
    call checkmem
    jr c, searchramnormal40

    ld (rampage0), a
    ld a, 1
    ld (ramcheck0), a



searchramnormal40:

    ld c, 0x40
    call checkmem
    jr c, searchramnormal80
    ld (rampage1), a
    ld a, 1
    ld (ramcheck1), a


searchramnormal80:

    ld c, 0x80
    call checkmem
    jr c, searchramnormalend
    ld (rampage2), a
    ld a, 1
    ld (ramcheck2), a



searchramnormalend:
; Examinar la cantidad y apuntarla

    ld a, (ramtypus)
    cp ram8k
    ret z

    ld a, (ramcheck2)
    or a
    ret z

    ld a, ram32k
    ld (ramtypus), a

    ld a, (ramcheck1)
    or a
    ret z


    ld a, ram48k
    ld (ramtypus), a

    ld a, (ramcheck0)
    or a
    ret z

    ld a, ram64k
    ld (ramtypus), a
    ret



; *** BUSQUEDA DE TODOS LOS SLOT CON RAM PARA CADA PAGINA ***






; *** RUTINAS GENERICAS ****


; ---------------------
; CHECKMEM
; C : Page
; Cy : NotFound
; ----------------------

checkmem:

    ld a, 0x00ff
    ld (thisslt), a
checkmem0:
    push bc
    call sigslot
    pop bc
    cp 0x00ff
    jr z, checkmemend

    push bc
    call checkmemgen
    pop bc
    ld a, (thisslt)
    ret nc
    jr checkmem0



checkmemend:
    scf
    ret



; --------------------------
; CHECKMEMGEN
; C : Page
; A : Slot FxxxSSPP
; 00 : 0
; 40:  1
; 80 : 2
; Returns :
; Cy = 1 Not found
; -------------------------------


checkmemgen:
    push bc
    push hl
    ld h, c
    ld l, 0x0010

checkmemgen1:

    push af
    call rdslt
    cpl
    ld e, a
    pop af

    push de
    push af
    call wrslt
    pop af
    pop de

    push af
    push de
    call rdslt
    pop bc
    ld b, a
    ld a, c
    cpl
    ld e, a
    pop af

    push af
    push bc
    call wrslt
    pop bc
    ld a, c
    cp b
    jr nz, checkmemgen2
    pop af
    dec l
    jr nz, checkmemgen1
    pop hl
    pop bc
    or a
    ret
checkmemgen2:
    pop af
    pop hl
    pop bc
    scf
    ret


; --------------------------
; CHECKMEMDIRECT
; Chequea si hay memoria
; En pagina C
; Y 16 posiciones por arriba
; ---------------------------

checkmemdirect:

    ld h, c
    ld l, 0x0010


checkmemdirect0:
    ld a, (hl)
    cpl
    ld c, a
    ld (hl), a
    ld a, (hl)
    ld b, a
    cpl
    ld (hl), a
    ld a, b
    cp c
    jr nz, checkmemdirectno
    dec l
    jr nz, checkmemdirect0
    or a
    ret
checkmemdirectno:
    scf
    ret


; ---------------------
; SEARCH_SLOTRAM
; Busca el slot de la ram
; Y almacena
; ----------------------

search_slotram:
    call 0x0138
    rlca
    rlca
    and 3
    ld c, a
    ld b, 0
    ld hl, 0xfcc1
    add hl, bc
    ld a, (hl)
    and 0x0080
    or c
    ld c, a
    inc hl
    inc hl
    inc hl
    inc hl
    ld a, (hl)
    rlca
    rlca
    rlca
    rlca
    and 0x0c
    or c
    ld (slotram), a
    ret


; -------------------------------------------------------
; SIGSLOT
; Returns in A the next slot every time it is called.
; For initializing purposes, THISSLT has to be #FF.
; If no more slots, it returns A=#FF.
; --------------------------------------------------------

;       ; this code is programmed by Nestor Soriano aka Konamiman

sigslot:
    ld a, (thisslt)  ; Returns the next slot, starting by
    cp 0x00ff  ; slot 0. Returns #FF when there are not more slots
    jr nz, sigslt1  ; Modifies AF, BC, HL.
    ld a, (exptbl)
    and 0000000010000000B
    ld (thisslt), a
    ret

sigslt1:
    ld a, (thisslt)
    cp 0000000010001111B
    jr z, nomaslt
    cp 0000000000000011B
    jr z, nomaslt
    bit 7, a
    jr nz, sltexp
sltsimp:
    and 0000000000000011B
    inc a
    ld c, a
    ld b, 0
    ld hl, exptbl
    add hl, bc
    ld a, (hl)
    and 0000000010000000B
    or c
    ld (thisslt), a
    ret

sltexp:
    ld c, a
    and 0000000000001100B
    cp 0000000000001100B
    ld a, c
    jr z, sltsimp
    add a, 0000000000000100B
    ld (thisslt), a
    ret

nomaslt:
    ld a, 0x00ff
    ret
sigslotend:




; *** VARS ***


; section rdata

ramcheck0:
    org $ + 1
ramcheck1:
    org $ + 1
ramcheck2:
    org $ + 1
ramcheck3:
    org $ + 1
ramtypus:
    org $ + 1
slotram:
    org $ + 1
thisslt:
    org $ + 1


; section code



setintropages:

    call romslotpage2
    xor a
    ld (0x6000), a
    inc a
    ld (0x6800), a
    inc a
    ld (0x7000), a
    inc a
    ld (0x7800), a
    ret



setbloadpages:
    call romslotpage2
    ld a, 4
    ld (0x6800), a
    inc a
    ld (0x7000), a
    inc a
    ld (0x7800), a
    ret



loadfirstbload:
    ld a, 5
    call chgmod
    call vis_off
    call romslotpage2
    ld hl, gaunt.n2
    xor a
    ld de, 0x4000
; i:    call untcfv
    call ramslotpage2
    ld hl, 0x4000
    ld de, 0x87d0
    ld bc, 16433
    call ldirmv
    jp 0x87d0



loadsecondbload:
    call putsafeint
    ld hl, gaunt.n3
    xor a
    ld de, 0x4000
;    call untcfv
    call ramslotpage2
    ld hl, 0x4000
    ld de, 0x8000
    ld bc, 18977
    call ldirmv

    xor a
    ld hl, 0
    ld bc, 0xffff
    call filvrm
    call vis_on
    jp 0x8000


putsafeint:
    di
    ld b, putsafeint.code_end - putsafeint.code
    ld de, 0x38
    ld hl, putsafeint.code
putsafeint.loop:
    push bc
    push de
    push hl
    ld l, (hl)
    ex de, hl
    ld a, (rampage0)
    call wrslt
    pop hl
    pop de
    pop bc
    inc de
    inc hl
    djnz putsafeint.loop
    ret

putsafeint.code:
    push af
    in a, (0x0099)
    pop af
    ei
    ret
putsafeint.code_end:

;;; Name:       SaveSlotC
;;; Function:   Save Slot in which cartridge is inserted
;;; Modify:     A,HL,DE


saveslotc:
    call rslreg
    rrca
    rrca
    and 00000011B
    ld e, a
    ld d, 0
    ld hl, exptbl
    add hl, de
    ld e, a
    ld a, (hl)
    and 0x80
    or e
    ld e, a

    inc hl
    inc hl
    inc hl
    inc hl
    ld a, (hl)

    and 00001100B
    or e
    ld (romslt), a
    ret


;;; Name:       RamSlotPageX
;;; Function:   Select Slot Cartridge for the page X


ramslotpage0:
    ld hl, 0
    ld a, (rampage0)
    jr slotchg

ramslotpage1:
    ld hl, 1 << 14
    ld a, (rampage1)
    jr slotchg

ramslotpage2:
    ld hl, 2 << 14
    ld a, (rampage2)
    jr slotchg

ramslotpage3:
    ld hl, 3 << 14
    ld a, (rampage3)
    jr slotchg


;;; Name:       RomSlotPageX
;;; Function:   Select Slot Cartridge for the page X


romslotpage0:
    ld hl, 0
    ld a, (romslt)
    jr slotchg
romslotpage1:
    ld hl, 1 << 14
    ld a, (romslt)
    jr slotchg

romslotpage2:
    ld hl, 2 << 14
    ld a, (romslt)
    jr slotchg

romslotpage3:
    ld hl, 3 << 14
    ld a, (romslt)

slotchg:
    jp enaslt


initbaseports:
    ld a, 0x10
    ld (baseport.psg), a

    ld de, baseport.ppi
    ld hl, (wslreg + 1)

initbaseports.scan:    ld a, 0xd3
    ld bc, 16
    cpir
    ldi
    ret


romslt: equ 0xf37f
rampage0: equ 0xf37e
rampage1: equ 0xf37d
rampage2: equ 0xf37c
rampage3: equ 0xf37b


; section rdata
oldisr:
    org $ + 5
fmfound:
    org $ + 1
baseport:
baseport.psg:
    org $ + 1
baseport.ppi:
    org $ + 1
playingsong:
    org $ + 1
