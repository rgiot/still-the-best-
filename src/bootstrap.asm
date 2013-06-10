START equ 0x8000

  org START
	
  di
  ld hl, 0xc9fb
  ld (0x38), hl



   ld hl, COMPRESSED
  ld de, 0x100
  call deexo
  jp 0x100

  include src/deexo.asm
TEXT
 db 0
COMPRESSED
  incbin fullscreenrotozoom.exo
UNCOMPRESSED_TEXT 
 assert $-START <= 4*1024

