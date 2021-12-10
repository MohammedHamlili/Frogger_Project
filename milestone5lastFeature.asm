# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
#####################################################################
#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Mohammed Hamlili, 1006967631
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3/4/5 (choose the one the applies)
# 5
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display the number of lives remaining. 
# 2. Make a second level that starts after the player completes the first level.
# 3. After final player death, display game over/retry screen. Restart the game if the “retry” option is chosen.
# 4. Dynamic increase in difficulty (speed, obstacles, etc.) as game progresses
# 5. Have objects in different rows move at different speeds.
# 6. Display a death/respawn animation each time the player loses a frog.
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
displayAddress: .word 0x10008000
frogX: .word 56
frogY: .word 28
arrayCarRow1: .space 512
arrayCarRow2: .space 512
arrayLogRow1: .space 512
arrayLogRow2: .space 512
frogLives: .word 3
successes: .word 0
level: .word 1
.text
main: lw $s0, displayAddress
      la $t1, arrayCarRow1
      lw $t0, 0($t1)
      addi $t0, $s0, 2560
      sw $t0, 0($t1)
      la $t1, arrayCarRow2
      lw $t0, 0($t1)
      addi $t0, $s0, 3072
      sw $t0, 0($t1)
      la $t1, arrayLogRow1
      lw $t0, 0($t1)
      addi $t0, $s0, 1024
      sw $t0, 0($t1)
      la $t1, arrayLogRow2
      lw $t0, 0($t1)
      addi $t0, $s0, 1536
      sw $t0, 0($t1)
      lw $t0, frogX
      addi $t0, $zero, 56
      sw $t0, frogY
      addi $t0, $zero, 28
      lw $t0, frogY
      sw $t0, frogLives
      addi $t0, $zero, 4
      sw $t0, frogLives
      lw $t0, level
      addi $t0, $zero, 1
      sw $t0, level
      lw $t0, successes
      add $t0, $zero, $zero
      sw $t0, successes

j mainLoop
mainLoop: 
	  li $s1, 0xff0000 # $t1 stores the red colour code
	  li $s2, 0x00ff00 # $t2 stores the green colour code
	  li $s3, 0x0000ff # $t3 stores the blue colour code
	  li $s4, 0xffff00 # $t5 stores the yellow colour code
	  li $s5, 0x8b4513 # $t6 stores the brown color code
	  li $s6, 0x00000 # $s6 stores the black color code
	  lw $t8, 0xffff0000
	  beq $t8, 1, keyboard_input
	  j start_drawing
keyboard_input: lw, $t2, 0xffff0004
	  beq $t2, 0x61, respond_to_A
	  beq $t2, 0x77, respond_to_W
	  beq $t2, 0x73, respond_to_S
	  beq $t2, 0x64, respond_to_D
	  j start_drawing
respond_to_A: lw $t1, frogX
          ble $t1, 0, start_drawing
          addi $t1, $t1, -12
          sw $t1, frogX
          j start_drawing
respond_to_D: lw $t1, frogX
          bge $t1, 128, start_drawing
          addi $t1, $t1, 12
          sw $t1, frogX
          j start_drawing
respond_to_W: lw $t1, frogY
          ble $t1, 4, start_drawing
          addi $t1, $t1, -4
          sw $t1, frogY
          j start_drawing
respond_to_S: lw $t1, frogY
          bge $t1, 28, start_drawing
          addi $t1, $t1, 4
          sw $t1, frogY
          j start_drawing
          
start_drawing: 
          jal Draw
	  addi $a1, $s0, 3072
	  add $a2, $zero, $zero
	  jal Cars
	  addi $a1, $s0, 3072
	  jal CarsBackwards
	  li $s5, 0x0000ff
	  li $s6, 0xffc800 
	  addi $a1, $s0, 1536
	  addi $a2, $zero, 1
	  jal Cars
	  addi $a1, $s0, 1536
	  jal CarsBackwards
	  jal Frog
	  jal Draw_lives
	  jal check_if_win
	  
	  
	  
	  
	  li $v0, 32
	  lw $t1, level
	  bge $t1, 3, Upperlevel
	  beq $t1, 2, Level2
Level1:	  li $a0, 1500
	  j Sleep
Level2:   li $a0, 750
	  j Sleep
Upperlevel: li $a0, 150
Sleep:	  syscall
	  j mainLoop

Cars:
#we're drawing on t3
#we get the first pixel by getting the variable: arraycarrow 1 or 2
# we check what $a2 is, if it's 0 then we're drawing first row of cars, 1 then second.
# a1 determines the maximum pixel in that row , to wrap around. we increment the variable until it finishes then 
#we bring it back around.
beq $a2, 1, Second
lw $t7, arrayCarRow1
la $t8, arrayCarRow1
j increment_variable
Second: lw $t7, arrayLogRow1
        la $t8, arrayLogRow1
increment_variable: addi $t7, $t7, 4
ble $t7, $a1, store_in_variable
addi $t7, $a1, -512
store_in_variable: sw $t7, 0($t8)

row_init: add $t9, $zero, $zero #represents the rows. Since a car is 4 rows of pixels, we iterate til t9 is 4.
INIT: add $t0, $zero, $zero
      add $t1, $zero, $zero

LOOPbg1init: addi $t1, $t1, 32
LOOPbg1: bge $t0, $t1, LOOPcar1init
		add $t3, $t7, $t0
		bge $t3, $a1, wrap_handle1 
paint1: 	sw $s5, 0($t3)
UPDATE1:	addi $t0, $t0, 4
		j LOOPbg1
wrap_handle1:	add $t3, $t3, -512
		j paint1

LOOPcar1init: addi $t1, $t1, 32
LOOPcar1: bge $t0, $t1, LOOPbg2init
	  	add $t3, $t7, $t0
	  	bge $t3, $a1, wrap_handle2 
paint2:	  	sw $s6, 0($t3)
UPDATE2:	addi $t0, $t0, 4
		j LOOPcar1
wrap_handle2:	add $t3, $t3, -512
		j paint2

LOOPbg2init: addi $t1, $t1, 32
LOOPbg2: bge $t0, $t1, LOOPcar2init
	 	add $t3, $t7, $t0
	 	bge $t3, $a1, wrap_handle3
paint3:	 	sw $s5, 0($t3)
UPDATE3:	addi $t0, $t0, 4
		j LOOPbg2
wrap_handle3:	add $t3, $t3, -512
		j paint3

LOOPcar2init: addi $t1, $t1, 32
LOOPcar2: bge $t0, $t1, rowLoop
	 	add $t3, $t7, $t0
	 	bge $t3, $a1, wrap_handle4
paint4:	 	sw $s6, 0($t3)
UPDATE4:	addi, $t0, $t0, 4
		j LOOPcar2
wrap_handle4:	add $t3, $t3, -512
		j paint4
	 
rowLoop: addi $t9, $t9, 1
	beq $t9, 4, END
	j LOOPbg1init

END: jr $ra


CarsBackwards:
#we're drawing on t3
#we get the first pixel by getting the variable: arraycarrow 1 or 2
# we check what $a2 is, if it's 0 then we're drawing first row of cars, 1 then second.
# a1 now determines the minimum pixel in that row , to wrap around. we increment the variable until it finishes then 
#we bring it back around.
beq $a2, 1, Secondé
lw $t7, arrayCarRow2
la $t8, arrayCarRow2
j increment_variableé
Secondé: lw $t7, arrayLogRow2
         la $t8, arrayLogRow2
increment_variableé: addi $t7, $t7, -8
add $t6, $a1, -512
add $t5, $a1, -4
bge $t7, $t6, store_in_variableé
#bge $t7, $t6, store_in_variable
add $t7, $a1, $zero
store_in_variableé: sw $t7, 0($t8)

row_inité: add $t9, $zero, $zero #represents the rows. Since a car is 4 rows of pixels, we iterate til t9 is 4.
INITé: add $t0, $zero, $zero
      add $t1, $zero, $zero

LOOPbg1inité: addi $t1, $t1, 32
LOOPbg1é: bge $t0, $t1, LOOPcar1inité
		add $t3, $t7, $t0
		ble $t3, $t5, wrap_handle1é
paint1é: 	sw $s5, 0($t3)
UPDATE1é:	addi $t0, $t0, 4
		j LOOPbg1é
wrap_handle1é:	add $t3, $t3, 512
		j paint1é

LOOPcar1inité: addi $t1, $t1, 32
LOOPcar1é: bge $t0, $t1, LOOPbg2inité
	  	add $t3, $t7, $t0
	  	ble $t3, $t5, wrap_handle2é
paint2é:	sw $s6, 0($t3)
UPDATE2é:	addi $t0, $t0, 4
		j LOOPcar1é
wrap_handle2é:	add $t3, $t3, 512
		j paint2é

LOOPbg2inité: addi $t1, $t1, 32
LOOPbg2é: bge $t0, $t1, LOOPcar2inité
	 	add $t3, $t7, $t0
	 	ble $t3, $t5, wrap_handle3é
paint3é:	sw $s5, 0($t3)
UPDATE3é:	addi $t0, $t0, 4
		j LOOPbg2é
wrap_handle3é:	add $t3, $t3, 512
		j paint3é

LOOPcar2inité: addi $t1, $t1, 32
LOOPcar2é: bge $t0, $t1, rowLoopé
	 	add $t3, $t7, $t0
	 	ble $t3, $t5, wrap_handle4é
paint4é:	sw $s6, 0($t3)
UPDATE4é:	addi, $t0, $t0, 4
		j LOOPcar2é
wrap_handle4é:	add $t3, $t3, 512
		j paint4é
	 
rowLoopé: addi $t9, $t9, 1
	beq $t9, 4, ENDé
	j LOOPbg1inité

ENDé: jr $ra

Draw:
add $t0, $zero, $zero
add $t1, $s0, $zero #t1 is where we're drawing
LOOPGOAL: beq $t0, 1024, LOOP2ND
		sw $s2, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 4
		j LOOPGOAL
LOOP2ND: beq $t0, 2048, LOOP3RD
		#sw $s3, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 4
		j LOOP2ND

LOOP3RD: beq $t0, 2560, LOOP4TH
		sw $s4, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 4
		j LOOP3RD

LOOP4TH: beq $t0, 3584, LOOP5TH
		#sw $s5, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 4
		j LOOP4TH

LOOP5TH: beq $t0, 4096, ENDLOOP
		sw $s2, 0($t1)
		addi $t1, $t1, 4
		addi $t0, $t0, 4
		j LOOP5TH

ENDLOOP: jr $ra

Frog: 
li $s6, 0x00000 # $t5 stores black color code
li $s3, 0x000ff
# blue color code is in $s3
lw $t7, frogY
lw $t8, frogX
# getting the variables to locate frog
#address = y * (width) + x
addi $t9, $zero, 128
mult $t7, $t9 #multiply displayAddress value by frogY to get row
mflo $t5 #16 lower bits of multiplication
add $t0, $s0, $t5 # t0 will be the position of where to draw
mfhi $t6 #16 higher bits of multiplication
add $t0, $t0, $t8
add $t0, $t0, $t6
# now we have the location where to draw top left pixel of frog in $t0
# we check for collision
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 8 
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 120
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 4
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 4
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 124
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 124
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 4
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
addi $t0, $t0, 4
lw $t1, 0($t0) # since i designed the code to draw frog last, the pixel here will be the one already drawn for bg and cars and logs
beq $t1, $s6, collision_handler # if it collides with black then it hit a car
beq $t1, $s3, collision_handler # if it collides with blue then it fell from it log.
sw $s1, 0($t0)
j END_FROG

collision_handler: # Handles collision
sw $s1, 0($t0)
addi $t0, $t0, 12
sw $s1, 0($t0)
addi $t0, $t0, 120
sw $s1, 0($t0)
addi $t0, $t0, 4
sw $s1, 0($t0)
addi $t0, $t0, 124
sw $s1, 0($t0)
addi $t0, $t0, 4
sw $s1, 0($t0)
addi $t0, $t0, 120
sw $s1, 0($t0)
addi $t0, $t0, 12
sw $s1, 0($t0)
li $v0, 32
li $a0, 1500
syscall
lw $t0, frogX
addi $t0, $zero, 56
sw $t0, frogX
lw $t0, frogY
addi $t0, $zero, 28
sw $t0, frogY
lw $t0, frogLives
addi $t0, $t0, -1
sw $t0, frogLives
beq $t0, 0, Retry
END_FROG: jr $ra

check_if_win:
lw $t7, frogY
bne $t7, 4, end_win
lw $t8, frogX
# getting the variables to locate frog
#address = y * (width) + x
addi $t9, $zero, 128
mult $t7, $t9 #multiply displayAddress value by frogY to get row
mflo $t5 #16 lower bits of multiplication
add $t0, $s0, $t5 # t0 will be the position of where to draw
mfhi $t6 #16 higher bits of multiplication
add $t0, $t0, $t8
add $t0, $t0, $t6
# now we have to location where to draw top left pixel of frog in $t0
sw $s1, 0($t0)
addi $t0, $t0, 4
sw $s2, 0($t0)
addi $t0, $t0, 4
sw $s2, 0($t0)
addi $t0, $t0, 4
sw $s1, 0($t0)
addi $t0, $t0, 116
sw $s2, 0($t0)
addi $t0, $t0, 4
sw $s2, 0($t0)
addi $t0, $t0, 4
sw $s2, 0($t0)
addi $t0, $t0, 248
sw $s1, 0($t0)
addi $t0, $t0, 4
sw $s2, 0($t0)
addi $t0, $t0, 4
sw $s2, 0($t0)
addi $t0, $t0, 4
sw $s1, 0($t0)
lw $t5, successes
addi $t5, $t5, 1
sw $t5, successes
lw $t0, frogX
addi $t0, $zero, 56
sw $t0, frogX
lw $t0, frogY
addi $t0, $zero, 28
sw $t0, frogY
bne $t5, 3, end_win
lw $t5, level
addi $t5, $t5, 1
sw $t5, level
lw $t5, successes
add $t5, $zero, $zero
sw $t5, successes
li $v0, 32
li $a0, 1500
syscall
end_win: jr $ra


Draw_lives:
	li $s6, 0x00000 # $s6 stores the black color code
	add $t3, $s0, $zero # $t3 is where we're drawing
	addi $t3, $t3, 236
	lw $t0, frogLives
	beq $t0, 3, Draw_3
	beq $t0, 2, Draw_2
	beq $t0, 1, Draw_1
Draw_0:	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 12
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 12
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 12
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	j END_Draw_lives
Draw_3: sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	j END_Draw_lives
Draw_2: sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 116
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	addi $t3, $t3, 4
	sw $s6, 0($t3)
	j END_Draw_lives

Draw_1: sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	addi $t3, $t3, 128
	sw $s6, 0($t3)
	j END_Draw_lives	




END_Draw_lives: jr $ra


Retry:
add $t0, $zero, $zero
add $t1, $s0, $zero #t1 is where we're drawing
loop_retry: beq $t0, 4096, Retry_input
	    sw $s2, 0($t1)
	    addi $t1, $t1, 4
	    addi $t0, $t0, 4
	    j loop_retry
Retry_input:
lw $t8, 0xffff0000
bne $t8, 1, Retry_input
lw, $t2, 0xffff0004
bne $t2, 0x72, Retry_input
j main




Exit:
li $v0, 10 # terminate the program gracefully
syscall

