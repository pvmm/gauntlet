

;;; bios entry
;;; msx1
chkram: equ #0000
synchr: equ #0008
rdslt: equ #000c
chrgtr: equ #0010
wrslt: equ #0014
outdo: equ #0018
calslt: equ #001c
dcompr: equ #0020
enaslt: equ #0024
getypr: equ #0028
callf: equ #0030
keyint: equ #0038
initio: equ #003b
inifnk: equ #003e
disscr: equ #0041
enascr: equ #0044
wrtvdp: equ #0047
rdvrm: equ #0047
wrtvrm: equ #004d
setrd: equ #0050
setwrt: equ #0053
filvrm: equ #0056
ldirmv: equ #0059
ldirvm: equ #005c
chgmod: equ #005f
chgclr: equ #0062
nmi: equ #0066
clrspr: equ #0069
initxt: equ #006c
init32: equ #006f
inigrp: equ #0072
inimlt: equ #0075
settxt: equ #0078
sett32: equ #007b
setgrp: equ #007e
setmlt: equ #0081
calpat: equ #0084
calatr: equ #0087
gspsiz: equ #008a
grpprt: equ #008d
gicini: equ #0090
wrtpsg: equ #0093
rdpsg: equ #0096
srttms: equ #0099
chsns: equ #009c
chget: equ #009f
chput: equ #00a2
lpout: equ #00a5
lptstt: equ #00a8
cnvchr: equ #00ab
pinlin: equ #00ae
qinlin: equ #00b4
breakx: equ #00b7
beep: equ #00c0
cls: equ #00c3
posit: equ #00c6
fnksb: equ #00c9
erafnk: equ #00cc
dspfnk: equ #00cf
totex: equ #00d2
gtstck: equ #00d5
gttrig: equ #00d8
gtpad: equ #00db
gtpdl: equ #00de
tapion: equ #00e1
tapin: equ #00e4
tapiof: equ #00e7
tapoon: equ #00ea
tapout: equ #00ed
tapoof: equ #00f0
stmotr: equ #00f3
chgcap: equ #0132
chgsnd: equ #0135
rslreg: equ #0138
wslreg: equ #013b
rdvdp: equ #013e
snsmat: equ #0141
phydio: equ #0144
isflio: equ #014a
outdlp: equ #014d
kilbuf: equ #0156
calbas: equ #0159


;;; msx2 added

subrom: equ #015c
extrom: equ #015f
eol: equ #0168
bigfill: equ #016b
nsetrd: equ #016e
nstwrt: equ #0171
nrdvrm: equ #0174
nwrvrm: equ #0177

;;; sub-rom

grprt_s: equ #0089
nvbxln_s: equ #00c9
nvbxfl_s: equ #00cd
chgmod_s: equ #00d1
initxt_s: equ #00d5
init32_s: equ #00d9
inigrp_s: equ #00dd
inimlt_s: equ #00e1
settxt_s: equ #00e5
sett32_s: equ #00e9
setgrp_s: equ #00ed
setmlt_s: equ #00f1
clrspr_s: equ #00f5
calpat_s: equ #00f9
calatr_s: equ #00fd
gspsiz_s: equ #0101
getpat_s: equ #0105
wrtvrm_s: equ #0109
rdvrm_s: equ #010d
chgclr_s: equ #0111
clssub_s: equ #0115
dspfnk_s: equ #011d
wrtvdp_s: equ #012d
vdpsta__s: equ #0131
setpag_s: equ #013d
iniplt_s: equ #0141
rstplt_s: equ #0145
getplt_s: equ #0149
setplt_s: equ #014d
beep_s: equ #017d
prompt_s: equ #0181

bltvv_s: equ #0191
bltvm_s: equ #0195
bltmv_s: equ #0199
bltvd_s: equ #019d
bltdv_s: equ #01a1
bltmd_s: equ #01a5
bltdm_s: equ #01a9

newpad_s: equ #01ad
chgmdp_s: equ #01b5
knjprt_s: equ #01bd
redclk_s: equ #01f5
wrtclk_s: equ #01f9



;;; work area

rdprim: equ #f380
wrprim: equ #f385
clprim: equ #f38c
usrtab: equ #f39a
linl40: equ #f3ae
linl32: equ #f3af
linlen: equ #f3b0
crtcnt: equ #f3b1
clmlst: equ #f3b2
txtnam: equ #f3b3
txtcol: equ #f3b5
txtcgp: equ #f3b7
txtatr: equ #f3b9
txtpat: equ #f3bb
t32nam: equ #f3bf
t32col: equ #f3bf
t32cgp: equ #f3c1

rg0sav: equ #f3df
rg1sav: equ #f3e0
rg2sav: equ #f3e1
rg3sav: equ #f3e2
rg4sav: equ #f3e3
forclr: equ #f3e9
bakclr: equ #f3ea
bdrclr: equ #f3eb

exbrsa: equ #faf8
exptbl: equ #fcc1
h.keyi: equ #fd9a
h.timi: equ #fd9f

rg8sav: equ #ffe7
rg9sav: equ #ffe8

csrsw: equ #fca9
cliksw: equ #f3db
