;;; %include "tniasm.inc"
;;; %include "z80r800.inc"
;;; %include "z80().inc"

	include "tniasm.inc"

LINEINT:  equ     140
TIMEFADE: equ     3

; RGB macro
RGB:	macro ?r8,?g8,?b8
	dw ?r8*256+?g8*16+?b8
	endm

; section code

ShowIntro:
	xor	a
	ld	(playingsong),a

        ld      hl,datab
        ld      de,databss
        ld      bc,datae-datab
        ldir

        ld      a,14h
        call    InitVDP

        call    ColourSFX
        push    af
        or      a
        call    nz,SelectChars

        call    RestVDP
        pop     af
        ret


PAL_NEGRO:      ds      32,0


SelectChars:
        ld      hl,gchars
        ld      de,8000h
        scf
        call    UnTCFV

        ld      hl,copyscr      ; First copy screen to page 1
        CALL    WAIT_COM
        CALL    COPYVRAM
        ld      hl,buildp2
        CALL    WAIT_COM        ; And generate player 2 gfx
        CALL    COPYVRAM

        ld      a,3
        call    VER_PAGE
        call    BuildHand       ; Load in vram hand sprite
        LD      HL,SelectPallette
        call    FADE_ON
        call    getNumbers      ; Select number of players
        call    selectP1        ; Select player 1
        ld      (0fffdh),a
	ld      b,a
        ld      a,(nplayers)
        dec     a
	ld      a,b
        call    nz,selectP2     ; and player 2 if it is necessary
        ld      (0fffeh),a
	call	stopsong
        ld    	hl,SelectPallette
	call	FADE_OFF
	ld	b,160

SelectChars.loop:
	ei
	halt
	djnz SelectChars.loop

        ld      IY,AYREGS
        ld      (IY+7),$BF
        ld      (IY+8),0
        ld      (IY+8),0
        ld      (IY+9),0
        ld      (IY+10),0
        call     PT3_ROUT
        ret


selectP2:
        ld      a,1
        ld      (copyline+3),a
        call    selectP1
        ld      (0fffeh),a
        ret


selectP1:
        call    SPD_OFF
        ld      a,96
        ld      (copyline),a
        call    showCart
        ld      b,120

selectP1.wait:  ei
        halt
        djnz    selectP1.wait

        call    hideCart
        call    SPD_ON

selectP1.loop:
        ei
        halt
        call    MoveHand
        call    PutHand
        call    TestF
        jr      z,selectP1.loop

        call    searchButton
        or      a
        jr      z,selectP1.loop
        dec     a
        out     (2fh),a
        ret


getNumbers:
        call    showCart
        call    SPD_ON
        ld      hl,rcopy1p
        ld      (copyptr),hl

getNumbers.loop:
        ei
        halt
        call    MoveHand
        call    PutHand
        call    searchButton
        or      a
        jr      nz,getNumbers.one

getNumbers.erase:
        ld      hl,(copyptr)
        call    WAIT_COM
        call    COPYVRAM
        jr      getNumbers.loop

getNumbers.one:
        dec     a
        cp      4
        jr      nz,getNumbers.two
        ld      hl,rcopy1p
        ld      (copyptr),hl
        ld      hl,copy1p
        ld      a,1
        jr      getNumbers.tfire

getNumbers.two:
        cp      5
        jr      nz,getNumbers.erase
        ld      hl,rcopy2p
        ld      (copyptr),hl
        ld      hl,copy2p
        ld      a,2

getNumbers.tfire:
        ld      (nplayers),a
        CALL    WAIT_COM
        CALL    COPYVRAM
        call    TestF
        jr      z,getNumbers.loop
        call    SPD_OFF
        call    hideCart
        ret


;;; e <-x
;;; d <- y

searchButton:
        ld      hl,coor_xy
        ld      d,(hl)
        inc     hl
        ld      e,(hl)
        ld      hl,Pos-5

searchButton.next1:
        inc     hl

searchButton.next2:
        inc     hl

searchButton.next3:
        inc     hl

searchButton.next4:
        inc     hl

        inc     hl

        ld      a,(hl)
        or      a
        ret     z

        cp      e
        jr      nc,searchButton.next1
        inc     hl
        ld      a,(hl)
        cp      d
        jr      nc,searchButton.next2

        inc     hl
        ld      a,(hl)
        cp      e
        jr      c,searchButton.next3
        inc     hl
        ld      a,(hl)
        cp      d
        jr      c,searchButton.next4
        inc     hl
        ld      a,(hl)
        ret


Pos:    db      143,90,167,99,6
        db      88,90,113,99,5
        db      1,1,127,107,1
        db      128,1,254,107,4
        db      1,108,129,208,2
        db      128,129,254,208,3
        db      0


hideCart:
        ld      e,80
        ld      d,80+44
        ld      b,46/2

hideCart.n1:
        ei
        halt

        ld      a,e
        inc     e
        ld      (copylinei+2),a
        ld      (copylinei+6),a
        exx
        CALL    WAIT_COM
        ld      hl,copylinei
        CALL    COPYVRAM
        exx

        ld      a,d
        dec     d
        ld      (copylinei+2),a
        ld      (copylinei+6),a
        exx
        CALL    WAIT_COM
        ld      hl,copylinei
        CALL    COPYVRAM
        exx
        djnz    hideCart.n1

        ei
        halt

        ld      a,80+43/2+2
        ld      (copylinei+2),a
        ld      (copylinei+6),a
        call    WAIT_COM
        ld      hl,copylinei
        call    COPYVRAM
        ret


showCart:
        ld      e,211+44/2
        ld      d,211+44/2+1
        ld      h,80+44/2
        ld      l,80+44/2+1
        ld      b,44/2

showCart.n1:
        ei
        halt

        ld      a,e
        dec     e
        ld      (copyline+2),a
        ld      a,h
        dec     h
        ld      (copyline+6),a
        exx
        CALL    WAIT_COM
        ld      hl,copyline
        CALL    COPYVRAM
        exx

        ld      a,d
        inc     d
        ld      (copyline+2),a
        ld      a,l
        inc     l
        ld      (copyline+6),a
        exx
        CALL    WAIT_COM
        ld      hl,copyline
        CALL    COPYVRAM
        exx
        djnz    showCart.n1
        ret


MoveHand:
        call    ST_AMPL
        ld      a,(joyport1)
        ld      b,a
        ld      a,(joyport2)
        or      b

        ld      hl,offsetx
        bit     2,a
        jr      z,MoveHand.derecha
        ld      b,a
        ld      a,(coor_xy+1)
        or      a
        ld      a,b
        jr      z,MoveHand.derecha
        dec     (hl)
        dec     (hl)

MoveHand.derecha:
        bit     3,a
        jr      z,MoveHand.abajo
        ld      b,a
        ld      a,(coor_xy+1)
        cp      224
        ld      a,b
        jr      z,MoveHand.abajo
        inc     (hl)
        inc     (hl)

MoveHand.abajo: ld      hl,offsety
        bit     1,a
        jr      z,MoveHand.arriba
        ld      b,a
        ld      a,(coor_xy)
        cp      182
        ld      a,b
        jr      z,MoveHand.arriba
        inc     (hl)
        inc     (hl)

MoveHand.arriba:
        bit     0,a
        ret     z
        ld      a,(coor_xy)
        or      a
        ret     z
        dec     (hl)
        dec     (hl)
        ret


PutHand:
        ld      hl,coor_xy
        ld      b,16

PutHand.loop:
        ld      e,(hl)
        ld      a,(offsety)
        add     a,e
        ld      (hl),a
        inc     hl
        ld      e,(hl)
        ld      a,(offsetx)
        add     a,e
        ld      (hl),a
        inc     hl
        inc     hl
        inc     hl
        djnz    PutHand.loop

        ld      a,1
        ld      hl,coor_xy
        ld      de,03600h
        ld      bc,16*4
        call    wvram
        xor     a
        ld      (offsetx),a
        ld      (offsety),a
        ret


;NOMBRE: COPYVRAM
;OBJETIVO: COPIAR UN BLOQUE DE VRAM A VRAM
;            Tambien es usada para otros comandos con igual
;            numero de parametros.
;ENTRADA: HL -> PUNTERO A LOS DATOS DEL COPY.


COPYVRAM:
        DI
        LD      A,32
        OUT     (99h),A
        LD      A,128+17
        OUT     (99h),A

        LD      C,9Bh
        LD      B,15
        OTIR
        RET

;NOMBRE: TESTCOM
;AUTOR: ROBERTO VARGAS CABALLERO
;OBJETIVO: ESTA FUNCIOM COMPRUEBA SI  SE ESTA EJECUTANDO UN COMANDO DEL VDP
;SALIDA: Z: SI SE HA ACABADO EL COMANDO Z VALDAR 0, EN CASO CONTRARIO VALDRA 1
;MODIFICA: AF,AF',C


TESTCOM:
        DI
        LD      C,99h
        LD      A,2
        DI
        OUT     (C),A
        LD      A,128+15
        OUT     (C),A
        IN      A,(C)
        EX      AF,AF'
        XOR     A
        OUT     (C),A
        LD      A,128+15
        OUT     (C),A
        EX      AF,AF'
        BIT     0,A
        RET


;NOMBRE: WAIT_COM
;OBJETIVO: ESPERAR HASTA QUE SE PRODUZCA EL FINAL DE UN COMANDO DEL VDP


WAIT_COM:
        CALL    TESTCOM
        JR      NZ,WAIT_COM
        RET


;NOMBRE: SPD_OFF
;OBJETIVO: ESTA FUNCION DESHABILITA LOS SPRITES
;MODIFICA: A


SPD_OFF:
        DI
        LD      A,(rg8sav)
        SET     1,A
        LD      (rg8sav),A
        OUT     (99h),A
        LD      A,88H
        OUT     (99h),A
        RET


;NOMBRE: SPD_ON
;OBJETIVO: ESTA FUNCION HABILITA LOS SPRITES
;MODIFICA: A


SPD_ON: DI
        LD      A,(rg8sav)
        RES     1,A
        LD      (rg8sav),A
        OUT     (99h),A
        LD      A,128+8
        OUT     (99h),A
        RET


;NOMBRE: FADE_OFF
;OBJETIVO: HACER UN FADE A NEGRO DE LA PALETA ACTUAL


FADE_OFF:
        LD      DE,paletaw1
        LD      BC,32
        LDIR
        LD      HL,PAL_NEGRO
        LD      (paletad1),HL
        JR      PUT_FADET


;NOMBRE: FADE_ON
;OBJETIVO: HACER UN FADE DE NEGRO A LA PALETA ACTUAL


FADE_ON:
        EXX
        LD      HL,PAL_NEGRO
        LD      DE,paletaw1
        LD      BC,32
        LDIR
        EXX
        LD      (paletad1),HL


PUT_FADET:      LD      B,16    ;ESTA LA QUE REALMENTE SE ENCARGA DE
;                                       ;HACER LOS FADES
PFADE_OFFB:
        PUSH    BC
PFADE_OFFW:
	EI
        LD      A,(time)
        OR      A
        JR      NZ,PFADE_OFFW

        LD      DE,(paletad1)
        LD      IX,paletaw1
        LD      HL,paletaw1
        CALL    DOFADE



        LD      HL,paletaw1
        LD      DE,pal_gm
        LD      BC,32
        LDIR

        DI
        LD      A,TIMEFADE
        LD      (time),A
        EI

        POP     BC
        DJNZ    PFADE_OFFB

        RET



;NOMBRE: DOFADE
;OBJETIVO: REALIZA UN PASO DE FADE ENTRE DOS PALETAS
;ENTRADA: HL -> PALETA INICIAL
;         DE -> PALETA DESTINO
;SALIDA: (IX)-> RESULTADO DEL FADE


DOFADE: LD      B,32

DOFADE1:
        PUSH    BC
        LD      A,(HL)
        AND     7
        LD      C,A
        LD      A,(DE)
        AND     7
        CP      C
        JR      Z,DOFADEIG
        JR      C,DOFADEMAY
        INC     C
        JR      DOFADEIG
DOFADEMAY:
        DEC     C

DOFADEIG:
        LD      A,(HL)
        AND     070H
        LD      B,A
        LD      A,(DE)
        AND     070H
        CP      B
        JR      Z,DOFADEIG2
        JR      C,DOFADEMAY2
        LD      A,B
        ADD     A,16
        LD      B,A
        JR      DOFADEIG2

DOFADEMAY2:
        LD      A,B
        SUB     16
        LD      B,A

DOFADEIG2:
        LD      A,C
        ADD     A,B
        LD      (IX),A
        INC     IX
        INC     HL
        INC     DE
        POP     BC
        DJNZ    DOFADE1

        RET


XINICIAL:       equ     128
YINICIAL:       equ     96


COLOR0_ON:
        DI
        LD      A,(rg8sav)
        RES     5,A
        LD      (rg8sav),A
        OUT     (99h),A
        LD      A,128+8
        OUT     (99h),A
        RET

COLOR0_OFF:
        DI
        LD      A,(rg8sav)
        SET     5,A
        LD      (rg8sav),A
        OUT     (99h),A
        LD      A,128+8
        OUT     (99h),A
        RET


Interrupt:
        push    af
        in      a,(99h)
        add     a,a
        jp      c,oldvector1

        ld      a,1             ;PONEMOS EL REGISTRO DE ESTADO 1
        out     (99h),a         ;PARA COMPROBAR EL VALOR DEL FLAG
        ld      a,128+15        ;INTERRUPCION HORIZONTAL
        out     (99h),a

        in      a,(99h)
        rrca
        jp      nc,endint

        push    hl
        push    de
        push    bc

        ld      a,2
        out     (99h),a
        ld      a,128+15
        out     (99h),a

        ld      b,29*3
        ld      hl,PalletteSFX2
        ld      a,(pointer)
        ld      (aux),a
        inc     a
        cp      138
        jr      nz,Interrupt.n2
        xor     a

Interrupt.n2:
        ld      c,a
        ld      a,(counter)
        inc     a
        ld      (counter),a
        cp      1
        ld      a,c
        jp      nz,Interrupt.n1

        xor     a
        ld      (counter),a
        ld      a,c
        ld      (pointer),a
        ld      (aux),a

Interrupt.n1:
        add     a,a
        ld      e,a
        ld      d,0
        add     hl,de
        ld      c,9ah

Interrupt.loop:
        ld      a,1
        call    ChangeColor

        ld      hl,PalletteSFX2
        ld      a,(aux)
        inc     a
        cp      138
        jp      nz,Interrupt.n3
        xor     a

Interrupt.n3:
        ld      (aux),a
        ex      de,hl
        ld      l,a
        ld      h,0
        add     hl,hl
        add     hl,de

Interrupt.waitnhr:
        in      a,(99h)
        and     20h
        jp      nz,Interrupt.waitnhr

Interrupt.waithr:
        in      a,(99h)
        and     20h
        jp      z,Interrupt.waithr

        outi
        outi
        djnz    Interrupt.loop

        pop     bc
        pop     de
        pop     hl


endint:
        xor     a
        out     (99h),a
        ld      a,128+15
        out     (99h),a
        pop     af
        ei
        reti


PalletteSFX2:
        RGB     0,1,0           ; 1
        RGB     0,2,0
        RGB     0,3,0
        RGB     0,4,0
        RGB     0,5,0
        RGB     0,5,0
        RGB     0,6,0
        RGB     0,6,0
        RGB     0,6,0
        RGB     0,7,0
        RGB     0,7,0
        RGB     0,7,0
        RGB     0,7,0
        RGB     0,6,0
        RGB     0,6,0
        RGB     0,6,0
        RGB     0,5,0
        RGB     0,5,0
        RGB     0,4,0
        RGB     0,3,0
        RGB     0,2,0
        RGB     0,1,0
        RGB     0,0,0


        RGB     1,1,0           ; 2
        RGB     2,2,0
        RGB     3,3,0
        RGB     4,4,0
        RGB     5,5,0
        RGB     5,5,0
        RGB     6,6,0
        RGB     6,6,0
        RGB     6,6,0
        RGB     7,7,0
        RGB     7,7,0
        RGB     7,7,0
        RGB     7,7,0
        RGB     6,6,0
        RGB     6,6,0
        RGB     6,6,0
        RGB     5,5,0
        RGB     5,5,0
        RGB     4,4,0
        RGB     3,3,0
        RGB     2,2,0
        RGB     1,1,0
        RGB     0,0,0

        RGB     1,0,0           ; 3
        RGB     2,0,0
        RGB     3,0,0
        RGB     4,0,0
        RGB     5,0,0
        RGB     5,0,0
        RGB     6,0,0
        RGB     6,0,0
        RGB     6,0,0
        RGB     7,0,0
        RGB     7,0,0
        RGB     7,0,0
        RGB     7,0,0
        RGB     6,0,0
        RGB     6,0,0
        RGB     6,0,0
        RGB     5,0,0
        RGB     5,0,0
        RGB     4,0,0
        RGB     3,0,0
        RGB     2,0,0
        RGB     1,0,0
        RGB     0,0,0

        RGB     1,0,1           ; 4
        RGB     2,0,2
        RGB     3,0,3
        RGB     4,0,4
        RGB     5,0,5
        RGB     5,0,5
        RGB     6,0,6
        RGB     6,0,6
        RGB     6,0,6
        RGB     7,0,7
        RGB     7,0,7
        RGB     7,0,7
        RGB     7,0,7
        RGB     6,0,6
        RGB     6,0,6
        RGB     6,0,6
        RGB     5,0,5
        RGB     5,0,5
        RGB     4,0,4
        RGB     3,0,3
        RGB     2,0,2
        RGB     1,0,1
        RGB     0,0,0

        RGB     0,0,1           ; 5
        RGB     0,0,2
        RGB     0,0,3
        RGB     0,0,4
        RGB     0,0,5
        RGB     0,0,5
        RGB     0,0,6
        RGB     0,0,6
        RGB     0,0,6
        RGB     0,0,7
        RGB     0,0,7
        RGB     0,0,7
        RGB     0,0,7
        RGB     0,0,6
        RGB     0,0,6
        RGB     0,0,6
        RGB     0,0,5
        RGB     0,0,5
        RGB     0,0,4
        RGB     0,0,3
        RGB     0,0,2
        RGB     0,0,1
        RGB     0,0,0

        RGB     0,1,1           ; 6
        RGB     0,2,2
        RGB     0,3,3
        RGB     0,4,4
        RGB     0,5,5
        RGB     0,5,5
        RGB     0,6,6
        RGB     0,6,6
        RGB     0,6,6
        RGB     0,7,7
        RGB     0,7,7
        RGB     0,7,7
        RGB     0,7,7
        RGB     0,6,6
        RGB     0,6,6
        RGB     0,6,6
        RGB     0,5,5
        RGB     0,5,5
        RGB     0,4,4
        RGB     0,3,3
        RGB     0,2,2
        RGB     0,1,1
        RGB     0,0,0


oldvector1:
              ld	a,(time)
              or	a
              jp	z,oldvector1.n2
              dec	a
              ld	(time),a

oldvector1.n2:
              push  	hl
	      push  	de
              push  	bc
              push	ix
              push      iy
              ld	hl,pal_gm
              call	PutPal
	      call	isrsound
              pop       iy
              pop	ix
              pop  	bc
	      pop  	de
              pop  	hl
              pop	af
              ei
              reti


newvector:
        jp      Interrupt


ColourSFX:
        call    vis_off
        ld      hl,gtitle
        ld      de,0
        scf
        call    UnTCFV

        ld      a,2
        call    VER_PAGE

        di
        ld      a,LINEINT
        call    SETVDP_LI
        call    vis_on
	call	initmusic
        ld      hl,TitlePallette
        CALL    FADE_ON

        call    waitKB
        call    waitnKB
        CALL    RESVDP_LI
        LD      HL,TitlePallette
        call    FADE_OFF

	ld      hl,(waittime)
        ld      a,l
	or      h
        ret


waitKB:
        ld      hl,60*60
        ld      (waittime),hl

waitKB.loop:
	ld      hl,(waittime)
	dec     hl
        ld      (waittime),hl
        ld      a,l
	or      h
        jr      nz,waitKB.wait
        xor     a
	ret

waitKB.wait:
	ei
        halt
        call    ST_AMPL
        ld      a,(joyport1)
        ld      b,a
        ld      a,(joyport2)
        or      b
        ret     nz
        jr      waitKB.loop


waitnKB:
	ld    hl,(waittime)
	ld    a,h
        or    l
        ret   z

waitnKB.loop:
        call    ST_AMPL
        ld      a,(joyport1)
        ld      b,a
        ld      a,(joyport2)
        or      b
        ret     z
        jr      waitnKB.loop


TestF:
        call    ST_AMPL
        ld      a,(joyport1)
        bit     4,a
        ret     nz
        ld      a,(joyport2)
        bit     4,a
        ret


RestVDP:
        ld      hl,oldvector
        ld      de,0fd9ah
        ld      bc,5
        di
        ldir
        ei
        ret


InitVDP:
        ld      a,5
        call    chgmod
        call    SET_SPD16
        call    COLOR0_OFF
        xor     a
        call    SET_CFONDO
        ld      hl,PAL_NEGRO
        ld      de,pal_gm
        ld      bc,32
        ldir
        call    SPD_OFF

        ld      hl,PAL_NEGRO
        call    PutPal

        ld	l,0
        ld	de,0
        ld	bc,4000h
        ld	a,7
        call	svram

        ld      hl,0fd9ah
        ld      de,oldvector
        ld      bc,5
        di
        ldir
        ei

        ld      hl,newvector
        ld      de,0fd9ah
        ld      bc,5
        di
        ldir
        ei

        ret


BuildHand:
        ld      l,230
        ld      a,1
        ld      de,3600h
        ld      bc,4*32
        call    svram

        ld      a,1
        ld      hl,hand
        ld      de,03800h
        ld      bc,100h
        call    wvram

        ld      l,0
        ld      a,1
        ld      bc,16*4
        ld      de,3400h
        call    svram

        ld      l,10
        ld      a,1
        ld      bc,16*4
        ld      de,3400h+16*4
        call    svram

        ld      l,11
        ld      a,1
        ld      bc,16*4
        ld      de,3400h+32*4
        call    svram

        ld      l,13
        ld      a,1
        ld      bc,16*4
        ld      de,3400h+48*4
        call    svram


        ld      a,1
        ld      hl,coor_xy
        ld      de,03600h
        ld      bc,32
        call    wvram
        ret


vis_on: DI
        LD      A,(rg1sav)
        SET     6,A
        LD      (rg1sav),A
        OUT     (99h),A
        LD      A,128+1
        OUT     (99h),A
        RET


vis_off:
        DI
        LD      A,(rg1sav)
        RES     6,A
        LD      (rg1sav),A
        OUT     (99h),A
        LD      A,128+1
        OUT     (99h),A
        RET


;NOMBRE: SET_CFONDO
;OBJETIVO: COLOCAR UN COLOR DE FONDO.
;ENTRADA: A -> COLOR
;MODIFICA: A


SET_CFONDO:
        DI
        OUT     (99h),A
        LD      A,128+7
        OUT     (99h),A
        RET


ChangeColor:
        di
        out     (99h),a
        ld      a,128+16
        out     (99h),a

        ret


PutPal: di
        xor     a
        out     (99h),a
        ld      a,128+16
        out     (99h),a
        ld      b,32
        ld      c,9Ah
        otir
        ret

Pallette:
        db 11h,1, 73h,4, 70h,0, 44h,4, 00h,5, 50h,3, 27h,2, 70h,6
        db 70h,4, 77h,7, 40h,1, 00h,0, 37h,5, 57h,0, 65h,0, 76h,4

ColorChange:    db      0

TitlePallette:
        db  00h,0, 00h,6, 02h,0, 40h,2, 14h,0, 27h,0, 50h,0, 37h,4
        db  70h,0, 73h,4, 70h,6, 74h,7, 03h,4, 62h,3, 50h,2, 77h,7

SelectPallette:
        dw 0000h,0333h,0630h,0574h,0026h,0237h,0040h,0547h
        dw 0060h,0463h,0570h,0774h,0420h,0251h,0555h,0777h

VER_PAGE:
        DI
        LD HL,PAGE0
        LD C,A
        LD B,0
        ADD HL,BC
        LD A,(HL)

        OUT     (99h),A
        LD      A,128+2
        OUT     (99h),A
        RET

PAGE0:          DB 00011111B
PAGE1:          DB 00111111B
PAGE2:          DB 01011111B
PAGE3:          DB 01111111B


SET_SPD16:      DI
        LD      A,(rg1sav)
        SET     1,A
        LD      (rg1sav),A
        OUT     (99h),A
        LD      A,128+1
        OUT     (99h),A
        RET


SETVDP_LI:
        DI
        OUT     (99h),A
        LD      A,128+19
        OUT     (99h),A

        LD      A,(rg0sav)
        SET     4,A
        OUT     (99h),A
        LD      A,128+0
        OUT     (99h),A
        RET


;NOMBRE: RESVDP_LI
;OBJETIVO: DESACTIVAR LAS INTERRUPCIONES HORIZONTALES


RESVDP_LI:
		DI
        LD      A,(rg0sav)
        RES     4,A
        OUT     (99h),A
        LD      A,128+0
        OUT     (99h),A
        RET


;;; Parametros de entrada
;;; hl -> Direccion RAM
;;; de -> Direccion VRAM
;;; bc -> contador;
;;; a -> Pagina


wvram:  call    setvram
        call    WriteVRAM
        ret


svram:  call    setvram
        call    FillVRAM
        ret


FillVRAM:
        ld      a,b
        or      c
        ret     z

        ld      a,l
_FillVRAM1:
        out     (98h),a
        dec     bc
        jp      nz,FillVRAM


WriteVRAM:
        ld      d,b
        ld      e,c
        ld      c,98h

        xor     a
        or      d
        ld      b,0
        jr      z,WriteVRAM.end

WriteVRAM.loop:
        otir
        dec     d
        jr      nz,WriteVRAM.loop

WriteVRAM.end:
        ld      b,e
        otir
        ret


setvram:
        DI
        PUSH    AF
        LD      A,E     ;Y ENVIRLA COMO PUNTERO RAM
        OUT     (99h),A ;AL VDP
        LD      A,D
        AND     3Fh
        OR      40h
        OUT     (99h),A

        POP     AF              ; AHORA ESCRIBO LA PAGINA
        OUT     (99h),A
        LD      A,128+14
        OUT     (99h),A
        RET


ST_AMPL:
        ld      e,8Fh           ;'~O'
        call    LEE_JOY         ;[88DEh]
        ld      (joyport1),a    ;[9439h]
        ld      e,0CFh
        call    LEE_JOY         ;[88DEh]
        ld      (joyport2),a    ;[943AH]

        push    bc
        push    af

        ld      b,0
        ld      a,8
        call    snsmat
        bit     0,a
        jr      nz,nojoy
        set     4,b


nojoy:
        and     0f0h
        bit     7,a     ;leeR
        jr      nz,LEE_JOY_D
        set     3,a

LEE_JOY_D:
        bit     6,a
        jr      nz,LEE_JOY_U
        set     1,a
LEE_JOY_U:
        bit     5,a
        jr      nz,LEE_JOY_L
        set     0,a
LEE_JOY_L:
        bit     4,a
        jr      nz,LEE_JOY_2
        set     2,a

LEE_JOY_2:
        and     0fh
        or      b

        ld      b,a

        ld      hl,joyport1
        or      (hl)
        ld      (hl),a

        ld      a,b

        ld      hl,joyport2
        or      (hl)
        ld      (hl),a

        pop     af
        pop     bc
        ret


LEE_JOY:
        ld      a,0Fh
        call    wrtpsg
        ld      a,0Eh
        call    rdpsg
        cpl
        and     1Fh
        ret






; in: hl = source
;     de = destination
; changes: af,af',bc,de,hl,ix

UnTCF:  ld      ix,-1           ; last_m_off

        ld      a,(hl)          ; read first byte
        inc     hl
        scf
        adc     a,a
        jr      nc,UnTCF.endlit

UnTCF.litlp: ldi
UnTCF.loop: call    GetBit
        jp      c,UnTCF.litlp

UnTCF.endlit:
        push    de              ; save dst
        ld      de,1

UnTCF.moff:
        call    GetBit
        rl      e
        rl      d
        call    GetBit
        jr      c,UnTCF.gotmoff
        dec     de
        call    GetBit
        rl      e
        rl      d
        jp      nc,UnTCF.moff
        pop     de              ; end of compression
        ret

UnTCF.gotmoff:
        ex      af,af'
        ld      bc,0            ; m_len
        dec     de
        dec     de
        ld      a,e
        or      d
        jr      z,UnTCF.prevdist
        ld      a,e
        dec     a
        cpl
        ld      d,a
        ld      e,(hl)
        inc     hl
        ex      af,af'
        ; scf - carry is already set!
        rr      d
        rr      e
        ld      ixl,e
        ld      ixh,d
        jp      UnTCF.newdist

UnTCF.prevdist:
        ex      af,af'
        ld      e,ixl
        ld      d,ixh
        call    GetBit

UnTCF.newdist:
        jr      c,UnTCF.mlenx
        inc     bc
        call    GetBit
        jr      c,UnTCF.mlenx

UnTCF.mlen:
        call    GetBit
        rl      c
        rl      b
        call    GetBit
        jp      nc,UnTCF.mlen
        inc     bc
        inc     bc

UnTCF.gotmlen:
        ex      af,af'
        ld      a,d
        cp      -5
        jp      nc,UnTCF.nc
        inc     bc

UnTCF.nc:
        inc     bc
        inc     bc
        ex      af,af'

        ex      (sp),hl         ; save src, and get dst in hl, de = offset
        ex      de,hl           ; de = dst, hl = offset
        add     hl,de           ; new src = dst+offset
        ldir
        pop     hl              ; get src back
        jp      UnTCF.loop

UnTCF.mlenx:
        call    GetBit
        rl      c
        rl      b
        jp      UnTCF.gotmlen


; decompresses to VRAM
; in: hl = source
;     de = destination
;     cf = carry 0 for low 64K, 1 for high 64K
; changes: af,af',bc,de,hl,ix
; note: does NOT check for CE. destination must be 80h aligned.

UnTCFV:
        push    af
        push    de
        push    hl
        push    bc
        ld      hl,hmmc_sh
        ld      de,hmmc
        ld      bc,11
        ldir
        pop     bc
        pop     hl
        pop     de
        pop     af

        ld      ix,-1           ; last_m_off

        ld      a,d
        rla
        rla
        and     00000011b
        ld      (hmmc+3),a
        and     00000010b
        ld      iyl,a

        ld      a,e
        add     a,a
        ld      a,d
        adc     a,a
        ld      (hmmc+2),a

        ld      a,(hl)          ; read first byte
        inc     hl
        scf
        adc     a,a
        ;jr      nc,UnTCFV.endlit

        ex      af,af'
        ld      a,(hl)
        inc     hl
        ld      (hmmc+8),a
        inc     de

        ld      a,36                    ; start HMMC

UnTCFV.di1:
        di
        out     (99h),a
        ld      a,17+128
        out     (99h),a
        ei
        push    hl
        ld      hl,hmmc
        ld      bc,0B9Bh
        otir
        pop     hl
        ld      a,44+128                ; continue HMMC

UnTCFV.di2:
        di
        out     (99h),a
        ld      a,17+128
        out     (99h),a
        ei
        ex      af,af'
        jp      UnTCFV.loop

UnTCFV.litlp: outi
        inc     de

UnTCFV.loop:
        call    GetBit
        jp      c,UnTCFV.litlp

UnTCFV.endlit:
        push    de              ; save dst
        ld      de,1

UnTCFV.moff:
        call    GetBit
        rl      e
        rl      d
        call    GetBit
        jr      c,UnTCFV.gotmoff
        dec     de
        call    GetBit
        rl      e
        rl      d
        jp      nc,UnTCFV.moff

        xor     a               ; stop HMMC
UnTCFV.di3:
        di
        out     (99h),a
        ld      a,46+128
        out     (99h),a
        ei

        pop     de              ; end of compression
        ret

UnTCFV.gotmoff:
        ex      af,af'
        ld      bc,0            ; m_len
        dec     de
        dec     de
        ld      a,e
        or      d
        jr      z,UnTCFV.prevdist
        ld      a,e
        dec     a
        cpl
        ld      d,a
        ld      e,(hl)
        inc     hl
        ex      af,af'
        ; scf - carry is already set!
        rr      d
        rr      e
        ld      ixl,e
        ld      ixh,d
        jp      UnTCFV.newdist

UnTCFV.mlenx:
        call    GetBit
        rl      c
        rl      b
        jp      UnTCFV.gotmlen

UnTCFV.prevdist:
        ex      af,af'
        ld      e,ixl
        ld      d,ixh
        call    GetBit

UnTCFV.newdist:
        jr      c,UnTCFV.mlenx
        inc     bc
        call    GetBit
        jr      c,UnTCFV.mlenx

UnTCFV.mlen:
        call    GetBit
        rl      c
        rl      b
        call    GetBit
        jp      nc,UnTCFV.mlen
        inc     bc
        inc     bc

UnTCFV.gotmlen:
        ex      af,af'
        ld      a,d
        cp      -5
        jp      nc,UnTCFV.nc
        inc     bc

UnTCFV.nc:
        inc     bc
        inc     bc

        ex      (sp),hl         ; save src, and get dst in hl, de = offset
        ex      de,hl           ; de = dst, hl = offset
        add     hl,de           ; new src = dst+offset

        ld      a,h
        and     11000000b
        rlca
        or      iyl
        rlca

UnTCFV.di4:
        di
        out     (99h),a
        ld      a,14+128
        ei
        out     (99h),a
        ld      a,l
        di
UnTCFV.di5:
        out     (99h),a
        ld      a,h
        and     00111111b
        out     (99h),a
        ei

        inc     hl
        sbc     hl,de
        jp      z,UnTCFV.unbuffer

        ex      de,hl
        add     hl,bc
        ex      de,hl

UnTCFV.matchlp:
        in      a,(98h)                 ; read byte
        dec     bc
        out     (9Bh),a                 ; write byte
        ld      a,c
        or      b
        jp      nz,UnTCFV.matchlp
        ex      af,af'

        pop     hl                      ; get src back
        ld      c,9Bh
        jp      UnTCFV.loop

UnTCFV.unbuffer:
        ex      de,hl
        add     hl,bc
        ex      de,hl

        in      a,(98h)                 ; read byte
        ld      iyh,a

UnTCFV.bufmatch:
        ld      a,iyh
        out     (9Bh),a                 ; write byte
        dec     bc
        ld      a,c
        or      b
        jp      nz,UnTCFV.bufmatch
        ex      af,af'

        pop     hl                      ; get src back
        ld      c,9Bh
        jp      UnTCFV.loop


GetBit: add     a,a
        ret     nz
        ld      a,(hl)          ; read new byte
        inc     hl
        adc     a,a             ; cf = 1, last bit shifted is always 1
        ret


hand:   incbin "hand.spr"


datab:  equ     $


hmmc_sh: db     0,0,0,0
         db     0,1,0,3
         db     0,0,0F0h


coor_xy_sh:
         db YINICIAL,XINICIAL
         db 0,0
         db YINICIAL,XINICIAL+16
         db 4*4,0
         db YINICIAL+16,XINICIAL
         db 8*4,0
         db YINICIAL+16,XINICIAL+16
         db 12*4,0

         db YINICIAL,XINICIAL
         db 1*4,0
         db YINICIAL,XINICIAL+16
         db 5*4,0
         db YINICIAL+16,XINICIAL
         db 9*4,0
         db YINICIAL+16,XINICIAL+16
         db 13*4,0

         db YINICIAL,XINICIAL
         db 2*4,0
         db YINICIAL,XINICIAL+16
         db 6*4,0
         db YINICIAL+16,XINICIAL
         db 10*4,0
         db YINICIAL+16,XINICIAL+16
         db 14*4,0

         db YINICIAL,XINICIAL
         db 3*4,0
         db YINICIAL,XINICIAL+16
         db 7*4,0
         db YINICIAL+16,XINICIAL
         db 11*4,0
         db YINICIAL+16,XINICIAL+16
         db 15*4,0


rcopy1p_sh:     db      1,0,   213,3, 80,0,  82,3, 32,0, 18,0, 0,0, 0d0h
rcopy2p_sh:     db      56,0,  213,3, 136,0, 82,3, 32,0, 18,0, 0,0, 0d0h
copy1p_sh:      db      224,0, 213,3, 87,0,  82,3, 32,0, 18,0, 0,0, 0d0h
copy2p_sh:      db      224,0, 237,3, 136,0, 82,3, 32,0, 18,0, 0,0, 0d0h
copyptr_sh:     dw      0
nplayers_sh:    db      0
copyscr_sh:     db      0,0,   0,3,   0,0,   0,1,   255,0, 0,1,  0,0, 0d0h
buildp2_sh:     db      192,0, 211,1, 161,0, 211,1, 32,0,  45,0, 0,0, 0d0h
copyline_sh:    db      0,0,   212,3, 80,0,  80,3,  96,0,  1,0,  0,0, 0d0h
copylinei_sh:   db      80,0,  0,1,   80,0,  0,3,   96,0,  1,0,  0,0, 0d0h
pointer_sh:     db      0
counter_sh:     db      0
TIME_sh:        db      0
offsetx_sh:     db      0
offsety_sh:     db      0


datae:          equ $


end_:           equ     $


; section rdata


databss:        equ     $
hmmc:           rb      11
coor_xy:        rw      32
rcopy1p:        rb      15
rcopy2p:        rb      15
copy1p:         rb      15
copy2p:         rb      15
copyptr:        rw      1
nplayers:       rb      1
copyscr:        rb      15
buildp2:        rb      15
copyline:       rb      15
copylinei:      rb      15
pointer:        rb      1
counter:        rb      1
time:           rb      1
offsetx:        rb      1
offsety:        rb      1
waittime:       rb      1

bufmatch_v:     rb      1
hmod:           rb      1
aux:            rb      1
oldvector:      rb      5
joyport1:       rb      1
joyport2:       rb      1
paletad1:       rw      1
paletaw1:       rb      32
pal_gm:         rb      32
