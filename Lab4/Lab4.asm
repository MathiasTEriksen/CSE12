###########################################################################################################################################
#
# Created by:	Eriksen, Mathias
#		mterikse
#		24 May 2020		
#
# Assignment:	Lab 4: Sorting Integers
#		CSE 12: Computer Systems and Assembly Language
#		UC Santa Cruz Spring 2020
#
# Desription:	This program will accept up to 8 numbers in hexadecimal format. These numbers can range from 0x0 to 0xFFF. The numbers
#		will be entered into the program arguments, with exactly 1 space seperating each number. The program will then print the
#		entered numbers in the entered hexadecimal format. Then, it will convert the values into decimal and print them to the
#		screen. Next, it will put the values into ascending order and print them to the screen.
#		
# Notes:	This program is inteded to be run on MARS 4.5
#
###########################################################################################################################################
#							
# PseudoCode:							
#							
#	Printing Program Arguments:						
#		Print (Program arguments: \n)	
#			Save the value a0 , which contains number of entries, in t0			
#			Load the word at effective adress at first entry
#		Print the word as is to screen, and a space after
#			Increment the adress by 4 to get next entry
#			Subtract one from t0
#		Loop over until t0 reaches 0, and all values have been printed
#			Continue to next part of code
#
#	Printing Integer Values:
#			Print (Integer values: \n)
#		Calculating Integer Values:
#			Bigger Loop:
#				If t0 is 0, all values have been printed, continue to  Sorting
#				Sub 1 from t0
#				Add 4 to stackpointer every loop, to get address of next entry
#				Add 2 to the address to bypass the 0x at start of every entry
#			Smaller Loop
#				Load the byte at the effective address
#				Check if byte is null, if it is proceed to calculation
#				Check if byte is number or letter
#				Convert byte into decimal number
#				Save the value in a register
#				Add 1 to address to get the next byte next time loop is continued
#				Return to Smaller loop
#			Calculation:
#				Find out how many bytes long entry is
#				Multiply each decimal value by appropriate factor to get decimal value of hex entry
#				Add the value of each individual byte in decimal together
#				Print that value to the screen with a space
#				Store that value in s register for sorting
#				Return to Bigger Loop start
#
#	Printing Sorted Values:
#			Print (Sorted Values: \n)
#		Sorting:
#			All values in decimal are saved in s0-s7 from prior loop, if there is less than 8 values, rest of registers
#			have negative numbers, s0 is filled first
#			Sorting Loop:
#				Check if value in register prior is greater, if so, switch them
#				If values are switched, t1 is incremented, and t1 is reset to 0 every time loop is completed
#				Do this for all registers s1-s7
#				Return to top of Sorting Loop
#				If t1 is not incremented through the loop, order is correct, proceed to print
#			Printing:	
#				Print the values in the order they are in, skipping leftover negative numbers from unused registers
#				Print a space after
#				End the program once all values have been printed
#
###########################################################################################################################################
#
# Register Usage:
#
#	$zero -	used when adding only one register to another as 0
#	$v0 - 	used to determine type of syscall
#	$a0 - 	used to show  he number of entries into Program Argument
#	$a1 - 	used to show effective address of the first entry
#	$t0 - 	used to store the number of entries
#		used to increment in order to know how many times to go through some loops
#	$t1 - 	used to store the address of the byte to be loaded
#	$t2 -	used to store the value of the byte at t2
#	$t3 - 	used as a counter for how many bytes long each argument is
#	$t4 - 	used to store the complete decimal value of each hexadecimal argument
#	$t5 -	used to store the decimal value of the third hex symbol read from the left
#	$t6 -	used to store the decimal value of the second hex symbol read from the left
#	$t7 -	used to store the decimal value of the first hex symbol read from the left
#	$t8 -	used to store the number 58, used to determine if hex symbol is number or letter
#		also used later to temporarily hold values to be swapped
#	$t9 -	used as a counter to know which register to store a value in
#	$s0-$s7 used to hold the decimal values of the hex inputs for sorting and printing
#	$sp -   used to hold the address of the hex input we want to use
#
###########################################################################################################################################
							#
.data							#
	Space: .asciiz " "				# Space label to print a .asciiz space
	ProgArg: .asciiz "Program arguments: \n"	# Prog Arg label to print Program Arguments: and a new line
	NewLine: .asciiz "\n"				# NewLine label to print a new line
	IntVal: .asciiz "Integer values: \n"		# IntVal label to print Integer Values: and a new Line
	SortVal: .asciiz "Sorted values: \n"		# SortVal label to print Sorted Values: and a new line
							#
############################################################################################################################################
							#
.text							#									#
	li $v0 4					# Print out the Program Arguments: and New Line at top
	la $a0 ProgArg					# Loading 4 into v0 allows me to print strings using syscall throughout
	syscall						#
	lw $t1 ($a1)					# Load address at $a1 to $t1						
	lw $t0 0($sp)					# Load the value in a0, which holds the amount of program arguments, into
PrintLoop:						# t0, to use as counter for my loop
	lw $a0 ($a1)					# Print out the string found at the address a1
	syscall						#
	la $a0, Space					# Print a space after printing the string
	syscall						#
							#
	addi $a1 $a1 4					# Increment the address by 4 in order to find the next string entered by 
							# the  user
	sub $t0 $t0, 1					# Subtract one from my counter value, to print correct amount of strings
	blez $t0 Exit1					# When counter reaches 0, proceed to next part of the program using a branch
							#
	j PrintLoop					# If counter has not reached 0, return to the top of loop and print the next 					
Exit1:							# string							
	la $a0 NewLine					# When loop is exited, print a New Line before going to the next part of 
	syscall						# the program
	syscall						# Print another New line
	la $a0 IntVal					# Print IntVal label
	syscall						#
							#
	addi $t8, $zero, 58				# Adds 58 to $s0, which will be used to determine if hex value is number or letter
	lw $t0 0($sp)					# Load # of entries into $t0
							#
	addi $s0 $zero -100				# Storing negative values in all  of my registers I will later be using
	addi $s1 $zero -100				# to hold the values for sorting.
	addi $s2 $zero -100				# Will be useful later to know which values are to be skipped and not printed after
	addi $s3 $zero -100				# sorting
	addi $s4 $zero -100				# For example, if I only have 4 values, 4 will still hold the negative values
	addi $s5 $zero -100				# and will thus not print due to a condition that I  have set
	addi $s6 $zero -100				# Allows me to print less than eight while still being able to use 0s
	addi $s7 $zero -100				#
							#
	j NextVal					# Jump to beginning of loop
							#
NextVal:						#
	sub $t0 $t0 1					# Subtract 1 from value in t0, will be used to know when all values have been 
	bltz $t0 Exit2					# translated. When the number reaches 0, proceeds to exit2 label
							#
	add $sp $sp 4					# Add 4 to the Stack Pointer to get next entry
	lw $t1 ($sp)					# Load the address at the stack pointer to t1
							#
	add $t3 $zero $zero				# Reset all values that will be used while translating
	add $t4 $zero $zero				#
	add $t5 $zero $zero				#
	add $t6 $zero $zero				#
	add $t7 $zero $zero				#
							#
	add $t1 $t1 2					# Add two to the address in order to bypass the '0x' of the hex entry
							#
	j Byte1						# Jump to reading of first byte
							#
Byte1:							#
	lb $t2 ($t1)					# Loads the first byte after the 0x
	blez $t2 Num1					# If it is a null character, skip to calculation, number is finished
							#
	add $t3 $t3 1					# Add 1 to value in t3, will be used a counter to know how many bytes long the value is
	add $t1 $t1 1					# Add 1 to address, so next time we load a byte, it will be the next value in hex
							#
	ble $t2 $t8 Number				# If value of byte is less than 58, it is a number, proceed to number
	bge $t2 $t8 Letter				# If value is greater than 58, proceed to Letter
							#
Byte2:							#
	lb $t2 ($t1)					# Load the second Byte
	blez $t2 Num1					# If it is null, proceed to calculation
							#
	add $t1 $t1 1					# Add one more to address
	add $t3 $t3 1					# Add 1  more to counter of number of bytes
							#
	ble $t2 $t8 Number1				# Checks if it is a number
	bge $t2 $t8 Letter1				# Chacks if it is a Letter
							#
Byte3:							#
	lb $t2 ($t1)					# Loads the third byte
	blez $t2 Num1					# If null, go to calculation
							#
	add $t3 $t3 1					# Add 1 to byte counter
	add $t1 $t1 1					# Add 1 to the address
							#
	ble  $t2 $t8 Number2				# Checks for Number
	bge $t2 $t8 Letter2				# Checks for Letter
							#
	Number:						#
		sub $t2 $t2 48				# Fist number value read, switched to integer value, and stored in t7
		move $t7 $t2				#
		j Byte2					# Jump to read next byte						
	Letter:						#
		sub $t2 $t2 55				# First Letter value read, switched to integer and stored in t7
		move $t7 $t2				#
		j Byte2					# Jump to read next byte							
	Number1:					#
		sub $t2 $t2 48				# Second number value read and switched to integer stored in t6
		move $t6 $t2				#
		j Byte3					# Jump to next byte							
	Letter1:					#
		sub $t2 $t2 55				# Second letter value read, and switched to integer stored in t6
		move $t6 $t2				#
		j Byte3					# Jump to next byte
	Number2:					#
		sub $t2 $t2 48				# Third number value read, switched and stored in t5
		move $t5 $t2				#
		j Num1					# Jump to calc, max is 3 bytes
	Letter2:					#
		sub $t2 $t2 55				# Third letter value read, switched and stored in t5
		move $t5 $t2				#
		j Num1					# Jump to calc, max is 3
							#
		Num1:					#
			bgt $t3 1 Num2			# If the counter value is larger than 1, go to next calculation(for 2 bytes)
							#
			Mul $t7 $t7 1			# Calculates the value if it is 1 byte long, multiplies integer value by 1
							# Translates hex to decimal for 1 byte
			j Print				# Jumps to print the value
		Num2:					#
			bgt $t3 2 Num3			# If the counter value is larger than 2, it is 3 bytes long, go to that  calc
							#
			Mul $t7 $t7 16			# Multiply the  first  byte read by 16
			Mul $t6 $t6 1			# Multiple the second byte read by 1
							# Translates to decimal from hex for 2 bytes
			j Print				# Jumps to print the value						
		Num3:					#
			Mul $t7 $t7 256			# Multiply first byte read by 256
			Mul $t6 $t6 16			# Multiply the second byte read by 16
			Mul $t5 $t5 1			# Multiply the first byte read by 1
							# Translates the 3 byte value into decimal
	j Print						# Jumps to print the value
Print:							#
	add $t4 $t7 $t6					# Adds all three of the registers holding the decimal values of the different hex
	add $t4 $t4 $t5					# symbols together, and saves them in $t4
							#
	li $v0 1					# Syscall for printing integer
	add $a0 $zero $t4				# Add the value of the hex in decimal to $a0 and print
	syscall						# Excecute
	li $v0 4					# Load syscall for printing a string
	la $a0 Space					# Load label for a Space
	syscall						# Excecute	
							#
	add $t9 $t9 1					# Add 1 to t9 to ensure first value is stored, t9 will be used to indicate which
	j Store1					# s register my value will be stored in
							#
	Store1:						#
		bgt $t9 1 Store2			# If something has  already been stored here, continue
		move $s0 $t4				# Store the first value entered into s0
		j NextVal				# Jump back to calculate next
	Store2:						#
		bgt $t9 2 Store3			# If already used, continue
		move $s1 $t4				# Store the second value entered into s1
		j NextVal				# Jump back to calculate next
	Store3:						#
		bgt $t9 3 Store4			# If already used, continue
		move $s2 $t4				# Store the third value entered into s2
		j NextVal				# Jump back to calculate next
	Store4:						#
		bgt $t9 4 Store5			# If already used, continue
		move  $s3 $t4				# Store the fourth value entered into s3
		j NextVal				# Jump back to calculate next
	Store5:						#
		bgt $t9	5 Store6			# If already used, continue
		move $s4 $t4				#  Store the fifth value entered into s4
		j NextVal				# Jump back to calculate next
	Store6:						#
		bgt $t9 6 Store7			# If already used, continue
		move $s5 $t4				# Store the sixth value entered into s5
		j NextVal				# Jump back to calculate next
	Store7:						#
		bgt $t9 7 Store8			# If already used, continue
		move $s6 $t4				# Store the seventh value entered into s6
		j NextVal				# Jump back to calculate next
	Store8:						#
		move $s7 $t4				# Store the eighth value entered into s1
		j Exit2					# Jump to Exit, cannot have more than 8 values
							#																			#
							#
Exit2:							#
	li $v0 4					# Print the label Newline twice, to get the proper spaceing
	la $a0 NewLine					#
	syscall						#
	la $a0 NewLine					#
	syscall						#
	la $a0 SortVal					# Print "Sorted Values: "
	syscall						#
							#
	add $t1 $zero 1					# Add 1 to t1, counter for when all values are sorted, to ensure that the 
	j SortLoop					# print will not be triggered on the first run
							#			
SortLoop:						#
	blez $t1 PrintingTime				# If t1 is not incremented while sorting, sorting is done, and can proceed to print
	add $t1 $zero $zero				# Put zero in t1
							# t1 will be incremented every time a value has to be moved, so if no value is 
	j Check12					# moved, it will stay at 0 and the blez will be triggered bc it is ready to print
							# Jump to first check
	Check12:					#																		#
		bgt $s0 $s1 Switch12			# Checks if value in s0 is greater than that in s1
		j Check23				# If not, correctly ordered, so you can continue to next check
	Switch12:					#
		move $t8 $s0				# Save the value in s0 to t8
		move $s0 $s1				# move the value in s1 to s0
		move $s1 $t8				# move value that was originally in s0 to s1
		add $t1 $t1 1				# Effectively 'swaps' the values in the registers
		j Check23				# Triggers the counter
							# Jump to next check
	Check23:					#
		bgt $s1 $s2 Switch23			# Checks if s1 is greater than s2
		j Check34				# If not, continue
	Switch23:					#
		add $t8 $zero $s1			# Effectively swaps the values in s1 and s2
		move $s1 $s2				#
		move $s2 $t8				#
		add $t1 $t1 1				# Increment counter
		j Check34				# Jump to next check
							#
	Check34:					#
		bgt $s2 $s3 Switch34			# Checks if value in s2 is greater than s3
		j Check45				#
	Switch34:					#
		add $t8 $zero $s2			# Effectively switches the values in s2 and s3
		move $s2 $s3				#
		move $s3 $t8				#
		add $t1 $t1 1				# Triggers counter
		j Check45				# Jump to next check
							#
	Check45:					#
		bgt $s3 $s4 Switch45			# Checks if value in s3 is greater than s4
		j Check56				# If not, continue
	Switch45:					#
		add $t8 $zero $s3			# Effectively swaps the values in s3 and s4
		move $s3 $s4				#
		move $s4 $t8				#
		add $t1 $t1 1				# Triggers counter
		j Check56				# Jump to next check
							#
	Check56:					#
		bgt $s4 $s5 Switch56			# Check if s4 is greater than s5
		j Check67				# If not continue
	Switch56:					#
		add $t8 $zero $s4			# Effectively swaps values in s4 and s5
		move $s4 $s5				#
		move $s5 $t8				#
		add $t1 $t1 1				# Triggers counter
		j Check67				# Jump to next check
							#
	Check67:					#
		bgt $s5 $s6 Switch67			# Check if value in s5 is greater than s6
		j Check78				# If not continue
	Switch67:					#
		add $t8 $zero $s5			# Swaps the values in s5 and s6
		move $s5 $s6				#
		move $s6 $t8				#
		add $t1 $t1 1				# Triggers counter
		j Check78 				# Jump to next check
							#
	Check78:					#
		bgt $s6 $s7 Switch78			# Check if s6 is greater than s7
		j SortLoop				# Jump back to top of loop
	Switch78:					#
		add $t8 $zero $s6			# Swap values in s6  and s7
		move $s6 $s7				#
		move $s7 $t8				#
		add $t1 $t1 1				# Triggers counter
		j SortLoop				# Jump back to top of loop
							# Loop will continue until no values have to be moved, and then the numbers will
PrintingTime:						# be correctly ordered from s0-s7 in ascending order
	j Print0					# Extra label
							#
	Print0:						#
		bltz $s0 Print1				# If the value is negative, dont print
		li $v0 1				# Print the value in s0 to the screen
		add $a0 $s0 $zero			#
		syscall					#
		li $v0 4				# Print a space after the value
		la $a0 Space				#
		syscall					#
	Print1:						#
		bltz $s1 Print2				# If the value is negative, dont print
		li $v0 1				# Print the value in s1 to the screen
		add $a0 $s1 $zero			#
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
	Print2:						#
		bltz $s2 Print3				# If the value is negative, dont print
		li $v0 1				# Print the value in s2 to the screen
		add $a0 $s2 $zero			#
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
	Print3:						#
		bltz $s3 Print4				# If the value is negative, dont print
		li $v0 1				# Print the value in s3 to the screen
		add $a0 $s3 $zero			#
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
	Print4:						#
		bltz $s4 Print5				# If the value is negative, dont print
		li $v0 1				# Print the value in s4 to the screen
		add $a0 $s4 $zero			#
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
	Print5:						#
		bltz $s5 Print6				# If the value is negative, dont print
		li $v0 1				# Print the value in s5 to the screen
		add $a0 $s5 $zero			#
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
	Print6:						#
		bltz $s6 Print7				# If the value is negative, dont print
		li $v0 1				# Print the value in s6 to the screen
		add $a0 $s6 $zero			#
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
	Print7:						#
		li $v0 1				#
		add $a0 $s7 $zero			# Print the value in s7 to the screen
		syscall					#
		li $v0 4				#
		la $a0 Space				# Print a space after the value
		syscall					#
		la $a0 NewLine				# Print a new line
		syscall					#
		li $v0 10				# End the program
		syscall					#
							#
###########################################################################################################################################
