        org     8400h

LEE_JOY equ     88DEh

joyport1:       equ     9439h
joyport2:       equ     943Ah

ST_AMPL:

        ld      e,8Fh           ;'�'
        call    LEE_JOY           ;[88DEh]
        ld      (joyport1),a       ;[9439h]
	ld	e,0CFh		;'�'
        call    LEE_JOY           ;[88DEh]
        ld      (joyport2),a       ;[943AH]

        push    bc
        push    af

        ld      b,0
        ld      a,8
        call    141h
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


        ;0001 RLDU  -> Joystick
        ;RDUL 0000  -> Teclado


