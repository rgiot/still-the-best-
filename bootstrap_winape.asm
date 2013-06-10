START equ &8000

  org START
  run START	

	write direct "a:4k.bnd"

  di
  ld hl, &c9fb
  ld (&38), hl



   ld hl, COMPRESSED
  ld de, &100
  call deexo
  jp &100

  read "deexo.asm"

 db 0
COMPRESSED
  incbin "fullscreenrotozoom.exo"
UNCOMPRESSED_TEXT 
; assert $-START <= 4*1024

