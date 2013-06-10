# Automatic building of the demo
# Krusty/Benediction 2011

include CPC.mk

.SILENT:

#############
# Constants #
#############
# DSK
DSK = rst0_4k_still_the_bests_by_benediction.dsk

# Adresses of bootstrap
BOOTSTRAP_LOAD=x8000
BOOTSTRAP_EXEC=x8000

vpath %.asm 	src/ 

.SUFFIXES: .asm, .o, .exo, .cre

vpath %.o .
vpath %.exo .
vpath %.cre .

.PHONY: all
ALL: 
	$(MAKE) $(DSK) || $(MAKE) $(DSK)


src/bndlogo.asm: data/png_to_bitfielad.py data/bnlogo.png 
	python data/png_to_bitfielad.py data/bnlogo.png > src/bndlogo.asm

src/face.asm: data/png_to_bitfielad.py data/face.png 
	python data/png_to_bitfielad.py data/face.png > src/face.asm


data/full.txt: data/roto3.py
	python $^ > $@

fullscreenrotozoom.o: data/full.txt src/bndlogo.asm src/face.asm
bootstrap.o: fullscreenrotozoom.exo text.exo
#######
# DSK #
#######
4k.bnd: bootstrap.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), $(BOOTSTRAP_LOAD), $(BOOTSTRAP_EXEC))

read.me: readme.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x4000, x4000)

plain: fullscreenrotozoom.o
	@$(call SET_HEADER, $<, $@, $(AMSDOS_BINARY), x100, x100)

FILES_TO_PUT=4k.bnd read.me 
$(DSK): $(FILES_TO_PUT)
	@$(MAKE) check
	@test -e $@ || $(call CREATE_DSK, $@)
	@$(foreach file, $(FILES_TO_PUT), \
		$(call PUT_FILE_INTO_DSK, $@, $(file)) )

#############
# Utilities #
# ###########
.PHONY: clean distclean check
check:
	#bash ./tools/check_source_validity.sh || ($(MAKE) clean ; exit 1)
clean:
	-rm *.o 
	-rm *.bin
	-rm *.exo
	-rm *.lst
	-find . -name "*.sym" -delete

distclean: clean
	-rm $(DSK)

