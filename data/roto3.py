#!/usr/bin/env python
# -*- encoding: utf-8 *-*

# ############ Initialisations Python ########################
import sys, pygame, math

size = width, height = 64, 32
speed = [1, 1]
FIXED = 256



# ################ Initialisations Rotozoom ###################################
print ';ROTOZOOM'
print ';\t- precomputed table'

y_center = height/2
x_center = width/2

angle = 256
angle2 = 0


# Precalc tables
cos = [int(FIXED/2*math.cos(math.radians(i*360.0/512.0)))  for i in range(768)]
sin = [int(FIXED/2*math.sin(math.radians(i*360.0/512.0)))  for i in range(768)]


def deltaxy(step):
    x = math.sin(math.radians(step*360/512)) * x_center  + x_center
    y = math.sin(math.radians(step*360/512)) * y_center/2 + \
    math.sin(math.radians(5*step*360/512)) * y_center/2  + y_center

    return x, y

step = 0
while 1:
  if step == 512: 
    quit()
  step = step + 1


# ################## 1 frame rotozoom #################################""

  angle = (angle + 1) % 512
  angle2 = angle2 + 1

  #angle = 256/2

  zoom = int(cos[(int(angle2))%512])
#  xx = cos[angle]*2 #* zoom * 3/FIXED #/ (2*FIXED)
#  yy = sin[angle]*2 #* zoom * 3/FIXED #/ (2*FIXED)

  
  xx = cos[angle]* zoom * 4/FIXED #/ (2*FIXED)
  yy = sin[angle]* zoom * 4/FIXED #/ (2*FIXED)

  #if step > 256 :
  #  xx = cos[angle]*2
  #  yy = sin[angle]*2


  u,v = deltaxy(step)
 # u, v =   u+cos[angle-2]*float(y_center)/float(FIXED), \
 #          v+(sin[angle-2]*float(x_center)/float(FIXED))
           #int(x_center+x_center*cos[angle2%256]/256.0), int(y_center + y_center*sin[angle2%256]/256.0),#x_center*cos[angle2%256], y_center*sin[angle2%256]

  # Verification des signes pour travailler uniquement avec des entiers positifs
  # - 4 méthodes différentes sont donc generees
  if xx > 0:
    x_pos = True
    delta_x = xx
  else:
    x_pos = False
    delta_x = -xx

  if yy > 0:
    y_pos = True
    delta_y = yy
  else:
    y_pos = False
    delta_y = -yy

  #print x_pos, delta_x, y_pos, delta_y
  print " db %d, %d, %d, %d, %d " % (u, v, min(255,delta_x), min(255,delta_y), x_pos*1 + y_pos*2)

  try: 
    assert delta_x < 256 , delta_x
  except : 
    pass
  try: 
    assert delta_y < 256, delta_y 
  except : 
    pass

  tmp2_x, tmp2_y = delta_x, delta_y

  # Construction automatique
  # de la fonction d'affichage de ligne
  # => deja code en Z80
  def affiche_ligne():
    global u, v, width


    pos_u, pos_v = u, v
    tmp_x, tmp_y = delta_x, delta_y
    for i in range(width):


      tmp_x = tmp_x + delta_x
      tmp_y = tmp_y + delta_y

      # Verification de si il faut modifier le pas
      # => incrementation ou pas en z80
      if tmp_x >= FIXED:
        tmp_x = tmp_x % FIXED
        if x_pos:
          pos_u = pos_u + 1
        else:
          pos_u = pos_u - 1

      if tmp_y >= FIXED:
        tmp_y = tmp_y % FIXED
        if y_pos:
          pos_v = pos_v + 1
        else:
          pos_v = pos_v - 1

  # Fin de l'affichage
  for j in range(height): 
      old_u = u
      old_v = v
      affiche_ligne()

      # a coder en z80
      tmp2_x = tmp2_x + delta_x
      tmp2_y = tmp2_y + delta_y

      if tmp2_x >= FIXED:
        tmp2_x = tmp2_x % FIXED
        if x_pos:
          v = old_v + 1
        else:
          v = old_v - 1

      if tmp2_y >= FIXED:
        tmp2_y = tmp2_y % FIXED
        if y_pos:
          u = old_u - 1
        else:
          u = old_u + 1


