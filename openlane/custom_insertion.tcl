# Custom Metal Insertion Script for Miyamii-4000
# This adds visible text branding to the final GDS

# Load the design
load $::env(DESIGN_NAME)

# Select met5 for text
set layer met5

# Bottom Right: "M4K" in large text
# M letter
box 1010um 30um 1020um 100um
paint $layer
box 1020um 85um 1035um 100um
paint $layer
box 1035um 30um 1045um 100um
paint $layer

# 4 number
box 1055um 30um 1065um 100um
paint $layer
box 1055um 65um 1085um 75um
paint $layer
box 1075um 50um 1085um 100um
paint $layer

# K letter
box 1095um 30um 1105um 100um
paint $layer
box 1105um 60um 1125um 70um
paint $layer
box 1105um 55um 1125um 65um
paint $layer

# Bottom Right: "Meisei (C) 2026" in smaller text
box 1010um 10um 1015um 22um
paint $layer
box 1015um 18um 1020um 22um
paint $layer
box 1020um 10um 1025um 22um
paint $layer

box 1030um 10um 1040um 22um
paint $layer
box 1030um 10um 1035um 14um
paint $layer

box 1045um 10um 1050um 22um
paint $layer

box 1055um 10um 1065um 22um
paint $layer

box 1070um 10um 1080um 22um
paint $layer

box 1085um 10um 1090um 22um
paint $layer

box 1095um 12um 1103um 20um
paint $layer

box 1110um 10um 1120um 22um
paint $layer
box 1125um 10um 1135um 22um
paint $layer
box 1140um 10um 1150um 22um
paint $layer
box 1155um 10um 1165um 22um
paint $layer

# Top Left: "Miyamii-4000"
# M
box 25um 690um 35um 760um
paint $layer
box 35um 745um 50um 760um
paint $layer
box 50um 690um 60um 760um
paint $layer

# I
box 70um 690um 80um 760um
paint $layer

# Y
box 90um 690um 100um 725um
paint $layer
box 100um 720um 110um 760um
paint $layer
box 110um 690um 120um 725um
paint $layer

# A
box 130um 690um 140um 760um
paint $layer
box 140um 745um 155um 760um
paint $layer
box 155um 690um 165um 760um
paint $layer

# M
box 175um 690um 185um 760um
paint $layer
box 185um 745um 200um 760um
paint $layer
box 200um 690um 210um 760um
paint $layer

# I
box 220um 690um 230um 760um
paint $layer

# I
box 240um 690um 250um 760um
paint $layer

# Dash
box 260um 720um 275um 730um
paint $layer

# 4
box 285um 690um 295um 760um
paint $layer
box 285um 720um 310um 730um
paint $layer
box 305um 705um 315um 760um
paint $layer

# 0
box 325um 690um 350um 760um
paint $layer
box 325um 690um 350um 700um
paint $layer
box 325um 750um 350um 760um
paint $layer

# 0
box 360um 690um 385um 760um
paint $layer
box 360um 690um 385um 700um
paint $layer
box 360um 750um 385um 760um
paint $layer

# 0
box 395um 690um 420um 760um
paint $layer
box 395um 690um 420um 700um
paint $layer
box 395um 750um 420um 760um
paint $layer

# Save the modified design
save

# Write GDS
gds write $::env(DESIGN_NAME)_branded.gds
