

p1size:  equ     p1end-p1load
p1padd:  equ     pagsize-p1size
p1sizeT: equ     p1endf-p1load

; cartridge start
        section code
        org     p1load
        db      "AB"
        dw      Init
        dw      0,0,0,0,0,0,0,0


loadmazerj:
        jp      loadmazer
ramslotpage0j:
        jp      ramslotpage0
ramslotpage1j:
        jp      ramslotpage1
ramslotpage2j:
        jp      ramslotpage2


Rg9Sav_:       equ   0ffe8h

Init:
        ld      sp,0f660h

        call    saveslotc
        call    searchramnormal
        call    initbaseports
        call    setintropages
        ld      a,7
        call    snsmat
        and     040h
        ld      a,(Rg9Sav_)
        jr      nz,Init._60Hz

        and     0fdh
        ld      (Rg9Sav_),a
        out     (99h),a
        ld      a,128+9
        out     (99h),a
        xor     a
        ld      (0FFFCh),a
        jr      Init.intro

Init._60Hz:
        or      2
        ld      (Rg9Sav_),a
        out     (99h),a
        ld      a,128+9
        out     (99h),a
        ld      (0FFFCh),a
        jr      Init.intro

Init.intro:
        call    StartLogo
        call    ShowIntro
        or      a
        jr      z,Init.intro

        call    setbloadpages
        call    loadfirstbload
        call    setbloadpages
        call    loadsecondbload
        ret

        db    "Made by TNI 2012"

        include once "sys.asm"
        include once "gaunt1.asm"
        include once "aamsx.asm"

musicpt3:
        incbin "gauntlet.pt3"


; section         code

p1end:  ds      p1padd,0
p1endf:         equ $

        ends

        if p1size > pagsize
            warning "Page 0 boundary broken"
        endif
