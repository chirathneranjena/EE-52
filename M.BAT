asm86 52test.asm db m1 ep
asm86 key.asm db m1 ep
asm86 display.asm db m1 ep
asm86 mp3.asm db m1 ep
asm86 DMA.asm db m1 ep


link86 52test.obj, display.obj, mp3.obj, key.obj to first.lnk

link86 ffrev.obj, keyupdat.obj, mainloop.obj, playmp3.obj, simide.obj, trakutil.obj to second.lnk

link86 first.lnk, second.lnk,  ic86.lib, sclib.lib to system.lnk


loc86 system.lnk to system noic ad(sm(code(400h), const(2000h), data(2000h), stack(3500h)))
