SUB $0, $0, $0; hard zero
ADDI $2, $0, 3; temp register
SHL $1, $16, $2; warpID * 8
ADD $1, $8, $1; global thrID stored in $1

ADDI $2, $0, 4; canvas size: 16 x 16
SHR $2, $1, $2; y = thrID / 16
ADDI $2, $2, -7; y-7
MULT $2, $2, $2; (y-7)^2

ADDI $3, $0, 15; 4b1111
AND $3, $1, $3; x = thrID mod 16
ADDI $3, $3, -7; (x-7)
MULT $3, $3, $3; (x-7)^2

ADD $2, $2, $3; (x-7)^2 + (y-7)^2
ADDI $2, $2, -49; (x-7)^2 + (y-7)^2 - r^2
ADDI $3, $0, 0; data reset to 0
BLT.S $0, $2, MERGE; 0 < (x-7)^2 + (y-7)^2 - r^2 (outside the circle)
ADDI $3, $0, 1; Inside the circle

MERGE:
ADDI.S $2, $0, 2 ; if we combine the two lines into ADDI.S, there will be a bug in PAM for ADDI
SHL $1, $1, $2; mem location = thrID * 4
SW $3, 0($1); store into corresponding location
EXIT
