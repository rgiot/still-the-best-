/**
 * Fullscreen rotozoom implementation 
 */

 output fullscreenrotozoom.o

LOAD equ 0x100
ROTOZOOM_HEIGHT equ 31
TEXTURE equ 0x8000


CODE_INC_L   equ #2C
CODE_DEC_L   equ #2d
CODE_INC_H   equ #24
CODE_DEC_H   equ #25

    org LOAD
    ld sp, LOAD
    jp go
MUSIC
    incbin data/EgoTrip17.bin
PLAYER
    include src/ArkosTrackerPlayer_CPC_MSX.asm

 /**
  * Displaying code of the rotozoom
  * Read texture
  * Move in texture
  * Display texture 
  * Anything else
  */
 macro MACRO_ROTOZOOM_LINE_BLOC
BLOC_POS=0
    ;dup 96/2
BLOC_POS=BLOC_POS+1
ADR_START=$
        ld e, (hl)  ; Read texture byte                            ;2
        ld d, e     ; Copy byte for displaying a word              ;1
        
ADR_MOV_HOR=$
        inc l       ; Move in texture horizontal                   ;1
ADR_MOV_VER=$
        nop         ; Move in texture veritical                    ;1

        push de     ; Copy word on screen                          ;4

 ;       push de     ; Copy other word                              ;4
ADR_END=$
    ;edup
    ;defs 96/4*5, 0
    ; => 432 nops

 endm

 /**
  * Select the screen to work on and the other to display
  */
 macro SELECT_SCREEN_TO_WORK nb
    ; Get the right things
    if nb == 0
SCREEN_ADRESS=0xc000+96
CRTC_ADRESS=0x3000 + 96/2
    else
SCREEN_ADRESS=0xc000+96+96
CRTC_ADRESS=0x3000
    endif
 
    ld sp, SCREEN_ADRESS
    ld de, CRTC_ADRESS
    ld bc, 0xbc00+12
    out (c), c : inc b : out (c), d 
    dec b : inc c
    out (c), c : inc b : out (c), e
 endm



/**
 * Move the texture
 *
 * HL' = last texture
 * BC' = last fixed point values
 * DE' = deltas
 *
 
 * TODO: need to patch the code when other rotation side
 */
 macro MOVE_TEXTURE_VERTICALLY
START_MOVE_TEXTURE_VERTICALLY=$
    exx

  ; Move in first coordinate

    ld a, c : add e : ld c, a
    jr c, .move_first
    jr .end_move_first  ; b2
.move_first     ; a3
DELTA_FIRST_COORD = $ - START_MOVE_TEXTURE_VERTICALLY
    inc l       ; a4        ; TODO replace by dec h if needed
    nop         ; a5
.end_move_first ; b5, a5
    
    

  ; Move in second coordinate
    ld a, b : add d : ld b, a
    jr c, .move_second
    jr .end_move_second  ; b2
.move_second     ; a3
DELTA_SECOND_COORD = $ - START_MOVE_TEXTURE_VERTICALLY
    inc h       ; a4        ; TODO replace by dec h if needed
    nop         ; a5
.end_move_second ; b5, a5


 ; Export Texture coordinate to main registers
    ld a, h : exx : ld h, a : exx
    ld a, l : exx : ld l, a

 endm

;;;;;;;;;;;;;;;;;;;;;;;;;;;

go
    di

    call rotozoom_init

 ei
 ;; Main loop of the demo
effect_loop
    ld b, 0xf5
    in a, (c)
    rra
    jr nc, effect_loop
	

    defs 64

     ld bc, 0xbc00 + 7 : out (c), c : ld bc, 0xbd00 + 255 : out (c), c
      ld bc, 0xbc00 + 9 : out (c), c
    ld bc, 0xbd00 + 0 : out (c), c ; ligne de 1 px 
  ld bc, 0xbc00 + 4 : out (c), c
    ld bc, 0xbd00 + 0 : out (c), c ; ligne de 1 px




    call Player+3

   ld de, (.delta+1)
.code_fonction
    call rotozoom_genere_code_pos_pos
 
.parameters
    exx
.delta    ld de, 255*128 + 0
    ld bc, de
    exx


.texture_start
    ld hl, TEXTURE + 128 + 5*256
.u  ld a, 0
    add l
    ld l, a
.v  ld a, 0
    add h
    ld a, h
    push hl
    exx : pop hl : exx

    halt : di
    call ROTOZOOM_LINE_BLOC
    ei
    call rotozoom_next_step

    defs 11
    defs 18
.selected_color
   
   ld hl, COULEURS_DAMIER_BN
   call COLOR 



.tempo_couleur
    ld bc, 1
    dec bc
    ld (.tempo_couleur+1), bc
    ld a, b
    or c
    jr nz, .no_color_change

.pos_table
    ld hl, COULEURS_TABLE+4
.pos_table_after
    ld e, (hl) : inc hl
    ld d, (hl) : inc hl
    ld a, e
    or d
    jr nz, .no_pb
    ld hl, COULEURS_TABLE
    jr .pos_table_after
.no_pb
    ld c, (hl) : inc hl
    ld b, (hl) : inc hl

    ld (.pos_table+1), hl
    ld (.tempo_couleur+1), de
    ld (.selected_color+1), bc

  
.no_color_change



 ld b, 2
.tempo
  defs 64-4
 djnz .tempo
    ld bc, 0xbc00 + 7 : out (c), c ; 7
    ld bc, 0xbd00 + 0 : out (c), c ; 7
    ld bc, 0xbc00 + 9 : out (c), c ; 7
    ld bc, 0xbd00 + 7 : out (c), c ; 7
    ld bc, 0xbc00 + 4 : out (c), c ; 7
    ld bc, 0xbd00 + 1 : out (c), c ; 7
 

    jp effect_loop

/**
 * Code de copie de texture
 */
copy_texture
copy_texture_begin
    MACRO_ROTOZOOM_LINE_BLOC
copy_texture_end
    defs (copy_texture_end-copy_texture_begin)* ( (96/2) - 1), 0
    jp (ix)

/**
 * Code for displaying a line in the rotozoom
 */
ROTOZOOM_LINE_BLOC
    ld (backsp+1), sp
    ld a, ROTOZOOM_HEIGHT/2
    ld (ROTOZOOM_LINE_BLOC_COUNT+1), a
     SELECT_SCREEN_TO_WORK 0
ROTOZOOM_LINE_BLOC_LOOP

;;; Code for the odd lines
first_half
    ld ix, first_half_end_copy
    jp copy_texture
first_half_end_copy
    SELECT_SCREEN_TO_WORK 1
first_half_before_move_texture
    MOVE_TEXTURE_VERTICALLY
    defs 27 - 9 - (3+2+4+1+4)
   ld bc, 0xbc00+1 : ld a, 96/2
    out (c), c : inc b : out (c), a

first_half_real_end



;;; Code for the even lines
second_half    
    ld ix, second_half_end_copy
    jp copy_texture
second_half_end_copy
    SELECT_SCREEN_TO_WORK 0
second_half_before_move_texture
    MOVE_TEXTURE_VERTICALLY
    defs 27  - (2+1+3+1+4+9)
second_half_real_end

ROTOZOOM_LINE_BLOC_COUNT
    ld a, ROTOZOOM_HEIGHT/2
    dec a
    ld (ROTOZOOM_LINE_BLOC_COUNT+1), a
    or a
    jp nz, ROTOZOOM_LINE_BLOC_LOOP

first_half2
    ld ix, first_half_end_copy2
    jp copy_texture
first_half_end_copy2
    SELECT_SCREEN_TO_WORK 1
first_half_before_move_texture2
    MOVE_TEXTURE_VERTICALLY
    defs 27 - 9 - (3+2+4+1+4)
   ld bc, 0xbc00+1 : ld a, 96/2
    out (c), c : inc b : out (c), a

first_half_real_end2




ROTOZOOM_LINE_BLOC_END
    ld bc, 0xbc00+1 : xor a
    out (c), c : inc b : out (c), a

backsp ld sp, 0
    ret

rotozoom_next_step
  ld hl, ROTOZOOM_TABLE_DECALAGE+ 5*(137)

  ; Gestion u
  ld a, (hl) : inc hl
  ld (effect_loop.u+1),a

  ; Gestion v
  ld a, (hl) : inc hl
  ld (effect_loop.v+1),a

  ; Gestion X
  ld a, (hl) : inc hl
  ld (effect_loop.delta+1), a

  ; Gestion Y
  ld a, (hl) : inc hl
  ld (effect_loop.delta+2), a

  ; Gestion generation code
  ld d, 0
  ld a, (hl) : inc hl
  ld (rotozoom_next_step+1), hl
  push hl
  ld e, a
  or a

  ld hl, ROTOZOOM_GENERATEUR_FONCTIONS
  add hl, de
  add hl, de
  ld e, (hl) : inc hl : ld d, (hl)
  ld (effect_loop.code_fonction+1), de


  ; Verification de non debordement
  pop hl
  ld de, ROTOZOOM_TABLE_DECALAGE_FIN
  or a : sbc hl, de
  ld a, h
  cp l
  or a
  ret nz

  ld hl, ROTOZOOM_TABLE_DECALAGE
  ld (rotozoom_next_step+1), hl
  ret


rotozoom_init 

    di
    ld hl, 0xc9fb
    ld (0x38), hl


.copy_code
 ld hl, copy_texture_begin
 ld de, copy_texture_end
 ld bc, (copy_texture_end-copy_texture_begin)*((96/2)-1)
 ldir
       
.init_display_code
    ld de, 0
    call rotozoom_genere_code_pos_pos

.build_texture
    ld hl, 0x4000

 ld de, 0*256 + OCTET_ENCRE1
 call build_texture_line
 ld de, OCTET_ENCRE1*256 + 0
 call build_texture_line

 ld b, 16
 ld de, hl
 ld hl, 0x4000
 call duplicate_line_bis
 push de

 ld de, 0x4000
 ld hl, bndlogo_patch
 ld c, OCTET_ENCRE2
 call patch_texture
 ld de, 0x4000 + 256*16 + 16
 ld hl, bndlogo_patch
 ld c, OCTET_ENCRE2
 call patch_texture


 ld a, 16 :  ld (patch_texture.width+1), a
 ;ld a, 256/16 : ld (patch_texture+1), a
 ld de, 0x4000
 ld hl, face_patch
 ld c, OCTET_ENCRE4
 call patch_texture
 ld de, 0x4000 + 256*16 + 16
 ld hl, face_patch
 ld c, OCTET_ENCRE4
 call patch_texture


 ld b, 0x80-(8-1)*2- 16
 pop de
 ld hl, 0x4000
 call duplicate_line_bis

 ld de, MUSIC
 call Player


  ld b, 0
.vbl_loop
 push bc
.tmp_vbl
    ld b, 0xf5
    in a, (c)
    rra
    jr nc, .tmp_vbl
  pop bc
  djnz .vbl_loop

 ld bc, 0x7f8c : out (c), c

    ld bc, 0xbc00 + 1 : out (c), c
    ld bc, 0xbd00+ 96/2 : out (c), c
    ld bc, 0xbc00 + 12 : out (c), c
    ld bc, 0xbd00 + 0x30 : out (c), c
    ld bc, 0xbc00 + 13 : out (c), c
    ld bc, 0xbd00 + 0x0 : out (c), c
    ld bc, 0xbc00 + 2 : out (c), c
    ld bc, 0xbd00 + 50 : out (c), c


    ret

/**
 * Patch a texture by adding a bit
 * ixh =0
 * hl=texture to read
 * de=texture to patch
 * c=value to patch
 */
patch_texture
 ld b, 256/32
.loopwidth
 push bc
 push de
 push hl

 ld ixh, 0

 ld b, 16
.loop_y
 push bc
 push de
.width
 ld b, 32
.loop_x 
 call patch_texture_read_byte
 jr nc, .no_patch
.patch
 ld a, (de)
 add c
 ld (de), a
.no_patch
 inc e
 djnz .loop_x
 pop de
 inc d
 pop bc
 djnz .loop_y

 pop hl
 pop de
 ld a, 32
 add e
 ld e, a
 pop bc
 djnz .loopwidth
 ret

patch_texture_read_byte

		ld	a,ixh		;get one bit
		sla	a
		ld	ixh,a
		ret nz

		ld	a,(hl)
		inc	hl
		scf
		rla
		ld	ixh,a

  ret

bndlogo_patch
 include src/bndlogo.asm
face_patch
 include src/face.asm


/**
 * Build one line of texture
 */
build_texture_line
 ld a, d : ld (.first_line_loop1+1), a
 ld a, e : ld (.first_line_loop2+1), a

.first_line
  push hl
  ld b, 8
.first_line_loop1
  ld (hl), OCTET_ENCRE1 : inc hl
  djnz .first_line_loop1
  ld b, 8
.first_line_loop2
  ld (hl), 0 : inc hl
  djnz .first_line_loop2
  ld de, hl
  pop hl
  push hl  
  ld bc, 256-8-8
  ldir
  pop hl
  ld b, 8-1
  call duplicate_line
  ret


/**
 * Copy one line several times
 */
duplicate_line
.loop
 ld de, hl
 inc d
 push hl
 push bc

 ld bc, 256
 ldir
	
 pop bc
 pop hl
 inc h
 djnz .loop

 ret


duplicate_line_bis
.loop
 push hl
 push de
 push bc

 ld bc, 256
 ldir
	
 pop bc
 pop de
 pop hl
 inc h
 inc d
 djnz .loop

 ret

 

 include src/donneesEncre.asm
CORRES_COUL_BYTE
 db 0
 db OCTET_ENCRE1
 db OCTET_ENCRE2
 db OCTET_ENCRE1 + OCTET_ENCRE2
 db OCTET_ENCRE4
 db OCTET_ENCRE4 + OCTET_ENCRE1
 db OCTET_ENCRE4 + OCTET_ENCRE2
 db OCTET_ENCRE4 + OCTET_ENCRE2+OCTET_ENCRE1
 db OCTET_ENCRE8
 db OCTET_ENCRE8 + OCTET_ENCRE1
 db OCTET_ENCRE8 + OCTET_ENCRE2
 db OCTET_ENCRE8 + OCTET_ENCRE1 + OCTET_ENCRE2
 db OCTET_ENCRE8 + OCTET_ENCRE4
 db OCTET_ENCRE8 + OCTET_ENCRE4 + OCTET_ENCRE1
 db OCTET_ENCRE8 + OCTET_ENCRE4 + OCTET_ENCRE2
 db OCTET_ENCRE8 + OCTET_ENCRE4 + OCTET_ENCRE2 + OCTET_ENCRE1

COLOR  
       ld bc,&7f00
BOUCOLOR
       out (c),c
       ld a,(hl)
       or a
       ret z
       out (c),a
       inc hl
       inc c
       jp BOUCOLOR


COULEURS_DAMIER_BN
 db 0x5c, 0x45
 db 0x5c,0x45
 db 0x5c, 0x45, 0x5c, 0x45
 defs 16-4-4, 0x5c
 db 0

COULEURS_LOGO_BND
 db 0x5d, 0x5d, 0x5f, 0x5f
 db 0x5d, 0x5d, 0x5f, 0x5f
 defs 16-4-4, 0x5d
 db 0

COULEURS_LOGO_FACE
 db 0x46, 0x46, 0x46, 0x46
 db 0x51, 0x51, 0x51, 0x51
 defs 16-4-4, 0x46
 db 0


COULEURS_TABLE
 dw 50*5, COULEURS_DAMIER_BN
 dw 50*5, COULEURS_LOGO_BND
 dw 50*5, COULEURS_LOGO_FACE
 dw 0

DELTA_MOV_HOR equ ADR_MOV_HOR - ADR_START
DELTA_MOV_VER equ ADR_MOV_VER - ADR_START
DELTA_END equ ADR_END - ADR_START


 /**
  * Macro qui patche le code existant
  */
 macro ROTOZOOM_GENERE_GENERATEUR_CODE OPCODE_HORIZ_X, OPCODE_HORIZ_Y
    ld hl, copy_texture + DELTA_MOV_HOR
    ld b, d: ld c, e ; BC = backup deltas
                     ; DE => adresse stockant la somme

    dup 96/2
    
 ;  ld a, 96/2
4
   ex af, af'


    ;; Delta horizontal
      ld a, e ; Recuperation ancienne valeur
      add c   ; Ajout du decalage
      ld e, a ; stocke nouvelle valeur
      jr nc, 2f ;test si overflow et necessite de changer le pixel
;.overflowx
1
      ; besoin de modifier la pente X
      ld a, OPCODE_HORIZ_X
      jr 3f
;.pasoverflowx ; pas besoin de modifier la pente X
2
      xor a
      nop
;.store
3
      ld (hl), a
      inc hl ; Decalage a l'operation suivante


 ;; Delta vertical
      ld a, d ; Recuperation ancienne valeur
      add b   ; Ajout du decalage
      ld d, a ; stocke nouvelle valeur
      jr nc, 2f ;test si overflow et necessite de changer le pixel
;.overflowx
1
      ; besoin de modifier la pente X
      ld a, OPCODE_HORIZ_Y
      jr 3f
;.pasoverflowx ; pas besoin de modifier la pente X
2
      xor a
      nop
;.store
3
      ld (hl), a

      dup DELTA_END - DELTA_MOV_VER + DELTA_MOV_HOR
       inc hl
      edup


  ; ex af, af'
 ;  dec a
 ;  jr nz, 4b
 edup
 endm

 /**
  * Code de substitutation des opcodes de decalage vertical de la texture
  */
 macro PATCH_DELTA_VERTICAL CODE_X, CODE_Y
    ld a, CODE_X
    ld (first_half_before_move_texture + DELTA_FIRST_COORD), a
    ld (second_half_before_move_texture + DELTA_FIRST_COORD), a

    ld a, CODE_Y
    ld (first_half_before_move_texture + DELTA_SECOND_COORD), a
    ld (second_half_before_move_texture + DELTA_SECOND_COORD), a
 endm

rotozoom_genere_code_pos_pos
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_INC_L, CODE_INC_H
.end
    PATCH_DELTA_VERTICAL            CODE_INC_H, CODE_DEC_L
    ret

rotozoom_genere_code_neg_pos
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_DEC_L, CODE_INC_H
.end
    PATCH_DELTA_VERTICAL            CODE_DEC_H, CODE_DEC_L
    ret

rotozoom_genere_code_pos_neg
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_INC_L, CODE_DEC_H
.end
    PATCH_DELTA_VERTICAL            CODE_INC_H, CODE_INC_L
    ret

rotozoom_genere_code_neg_neg
.begin
    ROTOZOOM_GENERE_GENERATEUR_CODE CODE_DEC_L, CODE_DEC_H
.end
    PATCH_DELTA_VERTICAL            CODE_DEC_H, CODE_INC_L
    ret


ROTOZOOM_GENERATEUR_FONCTIONS
 dw rotozoom_genere_code_pos_neg   ; 01
 dw rotozoom_genere_code_neg_pos   ; 10
 dw rotozoom_genere_code_pos_pos   ; 11

ROTOZOOM_TABLE_DECALAGE
    include data/full.txt
ROTOZOOM_TABLE_DECALAGE_FIN
    assert $ < 0x4000
    assert $ < TEXTURE


