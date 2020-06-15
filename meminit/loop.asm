XOR $0, $0, $0; hard zero
ADDI $1, $0, 3; temp register
SHL $2, $16, $1; warpID * 8
ADD $2, $8, $2; global thrID

ADDI $1, $0, 0; loop counter
ADDI $3, $0, 0; result register
ADDI $4, $2, 0; termination value (thrID)

LOOP:
BEQ.S $1, $4, OUT; while (i < 16) sum = sum + $2
ADD $3, $2, $3;
ADDI $1, $1, 1;
NOOP.S; # These two lines (ADD and NOOP) can be merged into ADD.S only if there is no thread divergence
J LOOP

OUT:
NOOP.S; # this is necessary, otherwise there will be one entry (SYNC) left in SIMT.

ADDI $1, $0, 2
SHL $5, $2, $1; mem location = thrID * 4
SW $3, 0($5); store result into corresponding location
EXIT
