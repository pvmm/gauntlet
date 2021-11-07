    section code

MSXPalet:
    db #00, 0, #00, 0, #11, 6, #33, 7, #17, 1, #27, 3, #51, 1, #27, 6
    db #71, 1, #73, 3, #61, 6, #64, 6, #11, 4, #65, 2, #55, 5, #77, 7

StartLogo:
    xor a
    ld (cliksw), a
    ld (csrsw), a
    xor a
    ld (forclr), a
    ld (bakclr), a
    ld (bdrclr), a

    call vis_off
    xor a
    call VER_PAGE
    ld hl, MSXPalet
    call PutPal

    ld a, 2
    call chgmod

; Logo!!
    ld hl, AAMSX_PAT + 8
    ld de, #c000
    call UnTCF
    ld hl, #c000
    ld de, 0
    ld bc, 3 * #0800
    call ldirvm

    ld hl, AAMSX_COL + 8
    ld de, #c000
    call UnTCF
    ld hl, #c000
    ld de, #2000
    ld bc, 3 * #0800
    call ldirvm

    ld bc, 260

StartLogo.loop:
    push bc
    ld a, 8
    call snsmat
    pop bc
    and 1
    ret z
    ei
    halt
    dec bc
    ld a, c
    or b
    jr nz, StartLogo.loop

    ret

AAMSX_COL:
    incbin "AAMSX.COL"

AAMSX_PAT:
    incbin "AAMSX.PAT"

    ends
