#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
AUTHOR Krusty/Benediction
DATGE 6 june 2011

Convert a B&W image to a bitfield

"""

from PIL import Image
import scipy
import sys

img = Image.open(sys.argv[1])
imgscipy = scipy.misc.fromimage(img)
nb_bytes=0
for line in imgscipy:
    for nb, value in enumerate(line):
        if nb%32 == 0:
            sys.stdout.write("\n\tdb %")
        elif nb%8 ==0:
            sys.stdout.write(", %")
            nb_bytes = nb_bytes+1
        sys.stdout.write('%d' % value)
sys.stderr.write('%d bytes (%d expected) ' % (nb_bytes, 32*32/8))

