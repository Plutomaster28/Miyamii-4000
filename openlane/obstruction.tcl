# Custom metal shapes for Miyamii-4000
# Creates visible branding on met5 layer

# Bottom Right Corner: "M4K" signature (coordinates: 1000-1180, 20-120)
# M - letter
create_obstruction -type metal -layer met5 -bbox {1010 30 1020 100}
create_obstruction -type metal -layer met5 -bbox {1020 85 1035 100}
create_obstruction -type metal -layer met5 -bbox {1035 30 1045 100}

# 4 - number  
create_obstruction -type metal -layer met5 -bbox {1055 30 1065 100}
create_obstruction -type metal -layer met5 -bbox {1055 65 1085 75}
create_obstruction -type metal -layer met5 -bbox {1075 50 1085 100}

# K - letter
create_obstruction -type metal -layer met5 -bbox {1095 30 1105 100}
create_obstruction -type metal -layer met5 -bbox {1105 60 1125 70}
create_obstruction -type metal -layer met5 -bbox {1105 55 1125 65}

# Bottom Right: "Meisei (C) 2026" (smaller text)
create_obstruction -type metal -layer met5 -bbox {1010 10 1015 22}
create_obstruction -type metal -layer met5 -bbox {1015 18 1020 22}
create_obstruction -type metal -layer met5 -bbox {1020 10 1025 22}
create_obstruction -type metal -layer met5 -bbox {1030 10 1040 22}
create_obstruction -type metal -layer met5 -bbox {1030 10 1035 14}
create_obstruction -type metal -layer met5 -bbox {1030 17 1035 22}
create_obstruction -type metal -layer met5 -bbox {1045 10 1050 22}
create_obstruction -type metal -layer met5 -bbox {1055 10 1065 14}
create_obstruction -type metal -layer met5 -bbox {1055 17 1065 22}
create_obstruction -type metal -layer met5 -bbox {1055 15 1060 17}
create_obstruction -type metal -layer met5 -bbox {1070 10 1080 22}
create_obstruction -type metal -layer met5 -bbox {1070 10 1075 14}
create_obstruction -type metal -layer met5 -bbox {1070 17 1075 22}
create_obstruction -type metal -layer met5 -bbox {1085 10 1090 22}
create_obstruction -type metal -layer met5 -bbox {1095 12 1098 20}
create_obstruction -type metal -layer met5 -bbox {1098 12 1103 14}
create_obstruction -type metal -layer met5 -bbox {1098 18 1103 20}
create_obstruction -type metal -layer met5 -bbox {1110 10 1120 22}
create_obstruction -type metal -layer met5 -bbox {1110 10 1115 14}
create_obstruction -type metal -layer met5 -bbox {1110 17 1115 22}
create_obstruction -type metal -layer met5 -bbox {1125 10 1135 22}
create_obstruction -type metal -layer met5 -bbox {1125 10 1135 14}
create_obstruction -type metal -layer met5 -bbox {1140 10 1145 22}
create_obstruction -type metal -layer met5 -bbox {1145 15 1155 22}
create_obstruction -type metal -layer met5 -bbox {1155 10 1165 14}
create_obstruction -type metal -layer met5 -bbox {1155 17 1165 22}

# Top Left Corner: "Miyamii-4000"
create_obstruction -type metal -layer met5 -bbox {25 690 35 760}
create_obstruction -type metal -layer met5 -bbox {35 745 50 760}
create_obstruction -type metal -layer met5 -bbox {50 690 60 760}
create_obstruction -type metal -layer met5 -bbox {70 690 80 760}
create_obstruction -type metal -layer met5 -bbox {90 690 100 725}
create_obstruction -type metal -layer met5 -bbox {100 720 110 760}
create_obstruction -type metal -layer met5 -bbox {110 690 120 725}
create_obstruction -type metal -layer met5 -bbox {130 690 140 760}
create_obstruction -type metal -layer met5 -bbox {140 745 155 760}
create_obstruction -type metal -layer met5 -bbox {155 690 165 760}
create_obstruction -type metal -layer met5 -bbox {175 690 185 760}
create_obstruction -type metal -layer met5 -bbox {185 745 200 760}
create_obstruction -type metal -layer met5 -bbox {200 690 210 760}
create_obstruction -type metal -layer met5 -bbox {220 690 230 760}
create_obstruction -type metal -layer met5 -bbox {240 690 250 760}
create_obstruction -type metal -layer met5 -bbox {260 720 275 730}
create_obstruction -type metal -layer met5 -bbox {285 690 295 760}
create_obstruction -type metal -layer met5 -bbox {285 720 310 730}
create_obstruction -type metal -layer met5 -bbox {305 705 315 760}
create_obstruction -type metal -layer met5 -bbox {325 690 350 760}
create_obstruction -type metal -layer met5 -bbox {325 690 350 700}
create_obstruction -type metal -layer met5 -bbox {325 750 350 760}
create_obstruction -type metal -layer met5 -bbox {360 690 385 760}
create_obstruction -type metal -layer met5 -bbox {360 690 385 700}
create_obstruction -type metal -layer met5 -bbox {360 750 385 760}
create_obstruction -type metal -layer met5 -bbox {395 690 420 760}
create_obstruction -type metal -layer met5 -bbox {395 690 420 700}
create_obstruction -type metal -layer met5 -bbox {395 750 420 760}

# Functional Unit Separation - visible metal channels
create_obstruction -type metal -layer met4 -bbox {295 150 305 650}
create_obstruction -type metal -layer met4 -bbox {595 150 605 650}
create_obstruction -type metal -layer met4 -bbox {895 150 905 650}
create_obstruction -type metal -layer met4 -bbox {310 395 890 405}

