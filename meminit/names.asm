; This program is associated with "TM_names.txt" which stores the bitmaps of the developers's initials
; Ray Liu, Jiaming Li
; Spandan Kachhadia, Chang Xu
; Dipayan Karmakar, Tridash Stiwala
; Eda Yan, Geng Yang
; and Prof. Gandhi Puvvada
SUB $0, $0, $0; hard zero
ADDI $1, $0, 3; temp register
SHL $2, $16, $1; warpID * 8
ADD $2, $8, $2; global thrID
ADDI $3, $0, -1
ADDI $1, $0, 2
SHL $2, $2, $1; mem location = thrID * 4
SW $3, 0($2); store thrID to corresponding location
EXIT
