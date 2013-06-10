######################################################
# Common Makefile instruction for building CPC demos #
######################################################

#TODO write function to put and remove files from dsk

COMPILE=sjasmplus2
COMPRESS=exomizer
iDSK=iDSK
HIDEUR=hideur
SHELL=/bin/sh

.SUFFIXES: .asm, .o, .exo
VPATH= src

# Compile a file
%.o: %.asm
	@echo -e '\033[0;34m\033[1mCompile \033[4m$<\033[0m\033[1m\033[0;34m\033[1m to \033[4m$@\033[0m \033[0m'
	$(COMPILE) --inc=src --sym=$(notdir $(<:.asm=.sym)) --lst=$(notdir $(<:.asm=.lst)) --raw=$@ $<  > compilation.log && exit 0; \
	cat compilation.log ; \
       	rm $@; \
	exit 255

# Compress a file
%.exo: %.o
	$(call COMPRESS_FILE,$<,$@)

%.exo: %.bin
	$(call COMPRESS_FILE,$<,$@)

COMPRESS_FILE = echo "\033[0;32m\033[1mCompress \033[4m$(1)\033[0m\033[1m\033[0;32m\033[1m to \033[4m$(2)\033[0m"; \
		$(COMPRESS) raw -o $(2) $(1)  > /dev/null;


#
# AMsdos file types
AMSDOS_BASIC=0
AMSDOS_ENCRYPTED_BASIC=1
AMSDOS_BINARY=2

# Macro to extract a file from a DSK
# Usage $(call GET_FILE_FROM_DSK, dsk, file)
GET_FILE_FROM_DSK = echo '\033[1mExtract $(2) from $(1)\033[0m'; \
		    $(iDSK) $(1) -g $(2) 2> /dev/null > /dev/null;

# Macro to create a new DSK
# Usage $(call CREATE_DSK, dsk)
CREATE_DSK = echo "\033[1mBuild DSK $(1)\033[0m"; \
	     $(iDSK) $(1) -n > /dev/null 2>/dev/null;

# Macro to put a file into a DSK
# header must be set
# Usage $(call PUT_FILE_INTO_DSK, dsk, file)
PUT_FILE_INTO_DSK = echo "\033[0;35m\033[1mAdd $(2) to $(1)\033[0m" ; \
		    $(iDSK) $(1) -i $(2) -f 2> /dev/null > /dev/null;

# Macro set a header to a file
# Usage: $(call SET_HEADER, source, destination, type, load, exec)
# TODO test for other type of files !
SET_HEADER = echo '\033[0;31m\033[1mSet header to \033[4m$(1)\033[0m'; \
	     $(HIDEUR) $(1) -o $(2) -t $(3) -l $(4) -x $(5) 2> /dev/null  > /dev/null;
