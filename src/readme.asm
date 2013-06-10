    output readme.o
    org 0x4000

    ld a, 2 : call 0xBC0E
    ld a, 0 : ld b, 4 : ld c, b : push bc : call 0xBC32 : pop bc : call 0xBC38
    ld a, 1 : ld b, 24 : ld c, b : call 0xBC32
    ld hl, TEXT1 : call display_text

    call 0xbb18
    call 0xbc14
    ld a, 0 : ld b, 13 : ld c, b : push bc : call 0xBC32 : pop bc : call 0xBC38
    ld a, 1 : ld b, 26 : ld c, b : call 0xBC32

    ld hl, TEXT2 : call display_text

    call 0xbb18

    call FDCON  
    ld hl,(&be7d)
    ld a,(hl) 
    ld b, 0
    call FDCVARS

    ld hl, filename
    ld de, 0x8000
    ld bc, de
    call LOADFILE

    call FDCOFF
    jp 0x8000


;; the filename to load
;; disc filenames are a maximum of 12 characters long
;; 8 characters for name, and 3 characters for extension
filename
 defb "4K      BND"
end_filename



 include src/READAMSD.MXM

display_text
.text_loop
    ld a, (hl)
    or a
    jr z, .text_end
    push hl
    call 0xbb5a
    pop hl
    inc hl
    jr .text_loop
.text_end

    ret


FNAME db '4k.bnd'
TEXT1
	db '                _________ __  .__.__  .__      __  .__            ' : db "\r\n"
	db '               /   _____//  |_|__|  | |  |   _/  |_|  |__   ____  ' : db "\r\n"
	db '               \_____  \\   __\  |  | |  |   \   __\  |  \_/ __ \ ' : db "\r\n"
	db '               /        \|  | |  |  |_|  |__  |  | |   Y  \  ___/ ' : db "\r\n"
	db '              /_______  /|__| |__|____/____/  |__| |___|  /\___  >' : db "\r\n"
	db '                      \/                                \/     \/ ' : db "\r\n"
	db '                  __________                 __           ._.' : db "\r\n"
	db '                  \______   \ ____   _______/  |_  ______ | |' : db "\r\n"
	db '                   |    |  _// __ \ /  ___/\   __\/  ___/ | |' : db "\r\n"
	db '                   |    |   \  ___/ \___ \  |  |  \___ \   \|' : db "\r\n"
	db '                   |______  /\___  >____  > |__| /____  >  __' : db "\r\n"
	db '                          \/     \/     \/            \/   \/' : db "\r\n"
    db "\r\n                                        by\r\n"
	db '               .--.                  .         .                ' : db "\r\n"
	db '               |   )                 |   o    _|_   o           ' : db "\r\n"
	db '               |--:  .-. .--. .-. .-.|   .  .-.|    .  .-. .--. ' : db "\r\n"
	db "               |   )(.-' |  |(.-'(   |   | (   |    | (   )|  | " : db "\r\n"
	db "               '--'  `--''  `-`--'`-'`--' `-`-'`-'-' `-`-' '  `-" : db "\r\n"
    db "\r\n"
    db "Code ........... Krusty/Benediction\r\n"
    db "Music .......... Ego Trip\r\n"
    db "Colors ......... Voxfreax/Benediction\r\n"
    db "                                       Released for the 4K compo of RST0\r\n"
    db "                                                            25 june 2011\r\n"
    db 0


TEXT2
    db "Shap\r\n"
    db "----\r\n"
    db "Hey man, why talking so much on the internet ?\r\n"
    db "If you code as fast as you claim (cf. cpcrulez post), I expect a\r\n"
    db "response (not hard to do better ;) )to this 4K in far less than two weeks!\r\n"
    db "\r\n"

    db "Rhino\r\n"
    db "-----\r\n"
    db "                   HEY! RHINO!\r\n"
    db "                PROBLEMS FOR DOING\r\n"
    db "                 ROTOZOOM ON ALL\r\n"
    db "                  SCREEN WIDTH?\r\n"
    db "                \r\n"
    db "                  WATCH AND LEARN\r\n"
    db "                  BEFORE TALKING\r\n"
    db "                     SO MUCH\r\n"
    db "\r\n"

    db "Grim and Hicks\r\n"
    db "--------------\r\n"
    db "As your are my two actual references, and I want to walk on your steps,\r\n"
    db "this demo does not work on all CRTCs.\r\n"
    db "\r\n\r\n"
    db '         To everyone ---\___/---> Enjoy this proof of concept!'
    db 0

