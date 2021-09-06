##################################################################################################################
# Created By:   Eriksen, Mathias
#		mterikse		
#		13 May 2020
#
# Assignment:   Lab 3: ASCII-Risks (Asterisks)
#		CSE 12: Computor Systems and Assembly Language
#		UC Santa Cruz Spring 2020
#
# Description:  This code prints variable sized ASCII diamonds and a sequence of embedded numbers
#
# Notes:        This program is intended to be run on MARS 4.5
#
##################################################################################################################
# Pseudocode
#
# Print to Screen (Enter the height of the pattern (must be greater than 0):
# If (value>0), proceed to store the value in system
# else (value<=0), jump to bottom and print "Invalid Entry!", and prompt user for a new value
# 
# (will be calling height value x)
#
# enter number into formula ((x+1)(x))/2 to get the value of the last number in the pattern
# Store the number in a register
#
# Values for big loop (Numbers that determine when each loop will stop),
# one value for x-1, (becomes one lower each time through), will call this y
# one value for x-y, (will call this z)
# one value for 2y
#
# Numbers on left loop:
# increment register by 1
# print register to screen
# print tab after number to screen
# subtract 1 from the value of z every loop, till it reaches 0, then it will proceed to the next loop
# unless you have reached the value of the last number in the pattern, then skip to second Numbers Loop
# 
# Stars loop
# print * then tab each time through
# subtract one from 2y each time through to find number of stars in each row
# once the value of what was first 2y reaches 0, proceed to next loop
#
# Second Numbers Loop
# find value of  leftmost number in the row by going through function, 
# x'+(y'+1) --> x', y' and x' starting at 1, and y' incrementing by one every big loop
# subtract one from value of x' 
# print number to the screen
# subtract one from value of z, till it reaches zero, then proceed to next loop
# print tab after number, (after branch so last number has no tab)
#
# Newline
# Checks if you have reached the largest number,  if so, proceed to Exit
# Otherwise, jump back to start of the big loop
#
# Exit
# Ends the program if you have reached the largest number
#
##################################################################################################################

.data
	prompt: .asciiz "Enter the height of the pattern (must be  greater than 0): "
	LessThan0: .asciiz "Invalid Entry!\n"

.text

Start:

	li $v0, 4				#Prompt user for height of pattern
	la $a0, prompt				#loads $a0 with value in prompt
	syscall
	
	li $v0, 5				#Get height of pattern
	syscall
	
	move $t0, $v0				#Store the result in $t0
	
	blez $t0, Invalid			#Branch to Invalid value label
					
.text
						#Formula to find max value of integers in given height pattern
	addi $t1, $t0, 1			#adds 1 to value in $t0 and stores in $t1
	
	mul $t1, $t1, 10			#Multiply factors by 10 so I don't have to deal with .5
	mul $t4, $t0, 10
	
	div  $t2, $t4, 2			#divides value in $t0 by 2 and stores in $t2
	multu $t2, $t1				#multiplies $t2 by $t1
	
	mflo $t4				#moves lo to $t1
	
	div $t4, $t4, 100			#return to desired #
	
						#Pattern Loop	
.data

	Tab: .asciiz "\t"			#Labels for Tab and Newline
	NewLine: .asciiz "\n"
	Star: .asciiz "*"
	
.text
	li $v0, 4				#puts a new line under prompt for pattern to start
	la $a0, NewLine
	syscall
	
	addi $s1, $zero, 0
	addi $s2, $zero, 1
	add $t1, $zero, $t0			#Put Prompted # in $t1
Top:
	subi $t1, $t1, 1			#Subtract $t1 by 1
	sub $t2, $t0, $t1			#subtract $t0 by $t1
	
	add $t5, $zero, $t1			#Put $t1 in $t5
	
	mul $t7, $t5, 2				#Multiply $t5 by 2 and put in $t7
	
	add $t6, $zero, $t2			#Put $t2 in  $t6
							
NumberFunct:
	
	addi $t3, $t3, 1			#Add 1 to $t3
	
	li $v0, 1				#Print value in $t3
	add $a0, $zero, $t3
	syscall
	
	li $v0, 4				#Tab after print
	la $a0, Tab
	syscall
	
	subi $t6, $t6, 1			#Sub number in #t2 by one
	
	bge $t3, $t4, NumberNumber
	
	blez  $t6, StarFunct			#if $t6 is less than 1, branch to Star
		
	j NumberFunct				#Otherwise, repeat
									
StarFunct:	
	
	subi $t7, $t7, 1			#Sub one from height
	
	li $v0, 4				#Print Star
	la $a0, Star
	syscall
	
	li $v0, 4				#Print Tab
	la $a0, Tab
	syscall
	
	blez $t7, NumberNumber			#Branch to Newline if  $t5 is less than 1
	
	j StarFunct				#Repeat Star printing
	
NumberNumber:
	
	add $t6, $zero, $t2			#adds value in $t2 to$t6
	
	addi $s1, $s1, 1			#Formula to find value of leftmost number on Left side
	add $s2, $s2, $s1
	add $s3, $zero, $s2
	
	j NumberFunct2				#Jumps to NumberFunct2
	
NumberFunct2:
	
	sub $s3, $s3, 1				#Subtracts one from value in $s3
	
	li $v0, 1				#Prints Value in $s3
	add $a0, $zero, $s3
	syscall
						
	subi $t6, $t6, 1			#Sub number in #t2 by one
	
	blez $t6, NewLineFunct			#if $t6 is less than 1, branch to NewLine
	
	li $v0, 4				#Prints the tab
	la $a0, Tab
	syscall
		
	j NumberFunct2				#Otherwise, repeat
															
NewLineFunct:

	bge $t3, $t4, Exit			#Exits program once max height is reached
	
	li $v0, 4
	la $a0, NewLine				#Print  Newline
	syscall
		
	j Top					#Jump to Top

Exit:
	
	li $v0, 4				#puts new line at bottom of pattern
	la $a0, NewLine
	syscall
	
	li $v0, 10				#Program Exit
	syscall
	
Invalid:
		
	li $v0, 4				#Links to invalid entry if emtry is below or equal to 0
	la $a0, LessThan0
	syscall
	
	j Start					#jumps back to start
