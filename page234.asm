p2size:  equ     p2end-p2load
p2padd:  equ     3*pagsize-p2size
p2sizeT: equ     p2endf-p2load

        section code

        org p2load

gchars: equ $
        incbin  "select.tcf",8

gtitle: equ $
        incbin  "gtitle.tcf",8

music:
        incbin  "gauntlet.mcm"

        include once "mcdrv.asm"
        include once "pt3.asm"

        ends

        section code

isrsound:
        ld      a,(playingsong)
        or      a
        ret     z
        ld      a,(fmfound)
        or      a
        jr      z,isrsound.psg
        jp      MCDRV

isrsound.psg:
        call    PT3_ROUT
        jp      PT3_PLAY


stopsong:
        ld      a,(fmfound)
        or      a
        jr      z,stopsong.psg
        ld      a,4
        jp      MCDRVC

stopsong.psg:
        jp      PT3_MUTE


initmusic:
        ld      a,4
        call    snsmat
        bit     5,a
        jr      z,initmusic.psg
        call    MCSearchFM
        ld      a,(fmfound)
        or      a
        jr      z,initmusic.psg
        ld      a,3
        call    MCDRVC
        ld      a,9
        ld      hl,music
        call    MCDRVC
        jr      initmusic.var

initmusic.psg:
        xor     a
        ld      (fmfound),a
        ld      IY,AYREGS
        ld      (IY+7),$BF
        ld      (IY+8),0
        ld      (IY+8),0
        ld      (IY+9),0
        ld      (IY+10),0
        call    PT3_ROUT
        ld      hl,PT3_SETUP
        set     0,(hl)
        ld      hl,musicpt3
        call    PT3_INIT

initmusic.var:
        ld      a,1
        ld      (playingsong),a
        ret

p2end:  ds      p2padd,0
p2endf: equ $

        if p2size > pagsize*3
            warning "Page 234 boundary broken"
        endif

        ends
