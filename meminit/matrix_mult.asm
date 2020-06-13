XOR $0, $0, $0; hard zero
ADDI $1, $0, 3; temp register
SHL $2, $16, $1; warpID * 8
ADD $2, $8, $2; global thrID

ADDI $1, $0, 4;
SHR $3, $2, $1; row number = thrID/16
ADDI $1, $0, 6;
SHL $5, $3, $1; $5 = A[i][0] = row * 16 * 4

ADDI $1, $0, 15;
AND $3, $2, $1; column number = thrID mod 16
ADDI $1, $0, 2;
SHL $6, $3, $1; $6 = B[0][j] = column * 4
ADDI $6, $6, 1024; offset for B[0][0] (16*16*4)

ADDI $1, $0, -16; loop counter
ADDI $7, $0, 0; result

LOOP:
BEQ.S $1, $0, OUT
LW $3, 0($5); ($5) A[i][0]
LW $4, 0($6); ($6) B[0][j]
MULT $3, $3, $4; A[i][0] * B[0][j]
ADD $7, $7, $3; SUM
ADDI $5, $5, 4; 1 * 4
ADDI $6, $6, 64; 16 * 4
ADDI.S $1, $1, 1;
J LOOP

OUT:
NOOP.S; # this is necessary, otherwise there will be one entry (SYNC) left in SIMT.
ADDI $1, $0, 2;
SHL $3, $2, $1; mem location = thrID * 4
ADDI $3, $3, 2048; offset for mat C[0][0]
SW $7, 0($3); store result into corresponding location
EXIT
