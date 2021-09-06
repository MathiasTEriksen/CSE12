###########################################################################################################################################
#
# Created by:	Eriksen, Mathias
#		mterikse
#		24 May 2020		
#
# Assignment:	Lab 5: Functions and Graphics
#		CSE 12: Computer Systems and Assembly Language
#		UC Santa Cruz Spring 2020
#
# Desription:	This program will print patterns to the bitmap display using various subroutines
#		
# Notes:	This program is inteded to be run on MARS 4.5
#
###########################################################################################################################################
#Spring20 Lab5 Template File

# Macro that stores the value in %reg on the stack 
#  and moves the stack pointer.

.macro push(%reg)

	subi $sp $sp 4
	sw %reg 0($sp)
	
.end_macro 

# Macro takes the value on the top of the stack and 
#  loads it into %reg then moves the stack pointer.

.macro pop(%reg)

	lw %reg 0($sp)
	addi $sp $sp 4
	
.end_macro

# Macro that takes as input coordinates in the format
# (0x00XX00YY) and returns 0x000000XX in %x and 
# returns 0x000000YY in %y

.macro getCoordinates(%input %x %y)

	ori %y %input 0x00FF0000
	sub %y %y 0x00FF0000
	addi %x %input 0
	srl %x %x 16
	
.end_macro

# Macro that takes Coordinates in (%x,%y) where
# %x = 0x000000XX and %y= 0x000000YY and
# returns %output = (0x00XX00YY)

.macro formatCoordinates(%output %x %y)

	sll %output %x 16
	add %output %output %y
	
.end_macro 

#Macro that takes in XX and YY
#And returns MMIO address for that point

.macro coordtoMMIO(%MMIO %x %y)
	mul %MMIO %x 128
	add %MMIO %MMIO %y
	mul %MMIO %MMIO 4
	addi %MMIO %MMIO 0xFFFF0000	
.end_macro
.text	

.data
originAddress: .word 0xFFFF0000

.text
j done
    
    done: nop
    li $v0 10 
    syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
#Clear_bitmap: Given a color, will fill the bitmap display with that color.
#   Inputs:
#    $a0 = Color in format (0x00RRGGBB) 
#   Outputs:
#    No register outputs
#    Side-Effects: 
#    Colors the Bitmap display all the same color
#*****************************************************
clear_bitmap: nop

	push $t0
	push $t1
		move $t0 $a0
		la $t1 0xFFFF0000
	colorloop:
		sw $t0 ($t1)
		addi $t1 $t1 4
		bgt $t1 0xFFFFFFFC exit1
		j colorloop
	exit1:
	
	pop $t1
	pop $t0
	jr $ra
	
#*****************************************************
# draw_pixel:
#  Given a coordinate in $a0, sets corresponding value
#  in memory to the color given by $a1	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#*****************************************************
draw_pixel: nop
#------------------------------------------------------------------------------------------------------#
							#
	push $t0					#
	push $t1					#
	push $t2					#
	push $t3					#
							#
		getCoordinates($a0 $t1 $t2)		#
							#
		mul $t1 $t1 128				#Find MMIO for coord
		add $t0 $t1 $t2				#
		mul $t0 $t0 4				#
		addi $t0 $t0 0xFFFF0000			#
							#
		move $t3 $a1				#
		sw $t3 ($t0)				#
							#
	pop $t3						#
	pop $t2						#
	pop $t1						#
	pop $t0						#
							#
#------------------------------------------------------------------------------------------------------#
	jr $ra					
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of pixel in format (0x00XX00YY)
#   Outputs:
#    Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
get_pixel: nop
#------------------------------------------------------------------------------------------------------#
							#
	push $t0					#
	push $t1					#
	push $t2
					#
							#
		getCoordinates($a0 $t1 $t2)		#
							#
		mul $t1 $t1 128				#Find MMIO for coord
		add $t0 $t1 $t2				#
		mul $t0 $t0 4				#
		addi $t0 $t0 0xFFFF0000			#
							#
		lw $v0 ($t0)				#
							#
	pop $t2						#
	pop $t1						#
	pop $t0						#
							#
#------------------------------------------------------------------------------------------------------#							
	jr $ra
#***********************************************
# draw_solid_circle:
#  Considering a square arround the circle to be drawn  
#  iterate through the square points and if the point 
#  lies inside the circle (x - xc)^2 + (y - yc)^2 = r^2
#  then plot it.
#-----------------------------------------------------
# draw_solid_circle(int xc, int yc, int r) 
#    xmin = xc-r
#    xmax = xc+r
#    ymin = yc-r
#    ymax = yc+r
#    for (i = xmin; i <= xmax; i++) 
#        for (j = ymin; j <= ymax; j++) 
#            a = (i - xc)*(i - xc) + (j - yc)*(j - yc)	 
#            if (a < r*r ) 
#                draw_pixel(x,y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_solid_circle: nop
#-------------------------------------------------------------------------------------------------------#
							#						
							#################################################
							#		--REGISTER USAGE----		#
	push $t0					#	$t0 - 	RADIUS				#
	push $t1					#	$t1 - 	ADDRESS				#
	push $t2					#	$t2 -	X IN SQUARE			#
	push $t3					#	$t3 - 	Y IN SQUARE			#
	push $t4					#	$t4 - 	(X*X)+(Y*Y)			#
	push $t5					#	$t5 - 	(R*R)+1				#
	push $t6					#	$t6 - 	FORMATTED NEW COORD		#
	push $t7					#	$t7 - 	XX OF COORD			#
	push $t8					#	$t8 -	YY OF COORD			#
	push $t9					#	$t9 -	COLOR				# 					
	push $s0					#	$s0 - 	DIAMETER			#
	push $s1					#	$s1 -	X*X				#		
	push $s2					#	$s2-	Y*Y				#
	push $s3					#	$s3 -	COUNTER FOR X			#
	push $s4					#	$s4 -	COUNTER FOR Y			#					
	push $s5					#	$s5 - 	OVERALL COUNTER			#	
							#################################################
							#
		move $t9 $a2				#
		move $t0 $a1				#
							#Store radius in t0
		mul $t5 $t0 $t0				#RxR
							#
		add $s4 $t0 $t0				#Counter
							#
		getCoordinates($a0 $t1 $t2)		#Get Coords of center
							#
		add $t7 $t1 0				#
		add $t8 $t2 0				#
							#
		sub $t7 $t7 $t0				#Store the leftmost coordinates
		sub $t8 $t8 $t0				#
							#
		mul $s0 $t0 2				#Diameter
		add $s5 $t7 $s0				#Counter to end
							#
		sub $t1 $t1 $t0				#Sub radius from both coords
		sub $t2 $t2 $t0				#Sub radius
							#
		coordtoMMIO($t1 $t1 $t2)		#Find coordinates of upper left corner of square
							#
		addi $t2 $t0 0				#Serve as Coordinates within  our square
		addi $t3 $t0 0				#    T2 is X, T3 is Y
							#
		j XInc					#
							#
		DrawCircleLoop:				#
							#
			YInc:				#
				subi $t3 $t3 1		#Subtract one from Y value
				add $s3 $t0 $t0		#Counter for X
				addi $s3 $s3 2		#
							#
				addi $t7 $t7 1		#Add 1 to Row
							#
				bgt $t7 $s5 exit2	#
							#
				addi $t2 $t0 0		#					
							#						
				coordtoMMIO($t1 $t7 $t8)#
							#
				j XInc			#
							#				
			XInc:				#
				subi $s3 $s3 1		#Counter for X
				blez $s3 YInc		#
							#
				mul $s1 $t2 $t2		#Find (x*x)
				mul $s2 $t3 $t3		#Find (y*y)
				add $t4 $s1 $s2		#Add (x*x)+(y*y)
							#
				subi $t2 $t2 1		#
							#
				blt $t4 $t5 Print	#If less than r*r+1 print a pixel
							#
				addi $t1 $t1 4		#
							#
				j XInc			#					
							#
			Print:				#
				move $t9 $a2		#Printing mechanism
				sw $t9 ($t1)		#
							#
				addi $t1 $t1 4		#
							#
				j XInc			#
							#						
	exit2:						#
							#
	pop $s5						#
	pop $s4						#
	pop $s3						#			
	pop $s2						#
	pop $s1						#
	pop $s0						#
	pop $t9						#
	pop $t8						#
	pop $t7						#
	pop $t6						#
	pop $t5						#
	pop $t4						#
	pop $t3						#
	pop $t2						#
	pop $t1						#
	pop $t0						#
							#						
#------------------------------------------------------------------------------------------------------#					
	jr $ra	
#***********************************************
# draw_circle:
#  Given the coordinates of the center of the circle
#  plot the circle using the Bresenham's circle 
#  drawing algorithm 	
#-----------------------------------------------------
# draw_circle(xc, yc, r) 
#    x = 0 
#    y = r 
#    d = 3 - 2 * r 
#    draw_circle_pixels(xc, yc, x, y) 
#    while (y >= x) 
#        x=x+1 
#        if (d > 0) 
#            y=y-1  
#            d = d + 4 * (x - y) + 10 
#        else
#            d = d + 4 * x + 6 
#        draw_circle_pixels(xc, yc, x, y) 	
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of the circle center in format (0x00XX00YY)
#    $a1 = radius of the circle
#    $a2 = color of line in format (0x00RRGGBB)
#   Outputs:
#    No register outputs
#***************************************************
draw_circle: nop
#-------------------------------------------------------------------------------------------------------#
							#
							#################################################
							#		-REGISTER USAGE-		#
	push $t0					#	$t0 - X, START 0			#
	push $t1					#	$t1 - Y, START R			#
	push $t2					#	$t2 - D Value				#
	push $t3					#	$t3 - X-Y				#
	push $t4					#	$t4 - X-Y				#
	push $t5					#	$t5 - 					#
	push $t6					#	$t6 - 					#
	push $t7					#	$t7 - 					#
	push $t8					#	$t8 - 					#
	push $t9					#	$t9 - 					# 					
	push $s0					#	$s0 - X-Y				#
	push $s1					#	$s1 -					#		
	push $s2					#	$s2-					#
	push $s3					#	$s3 -					#
	push $s4					#	$s4 -					#					
	push ($ra)					#	$ra - 					#	
							#################################################
							#		
		addi $t0 $zero 0			#X value starting at 0								
		addi $t1 $a1 0				#Y value starting at R
							#
		addi $t6 $a0 0				#
							#
		move $t9 $a2				#
							#
		addi $t4 $zero 3			#
		mul $t2 $t1 2				#Value of D
		sub $t2 $t4 $t2				#
							#
		add $a2 $t0 0				#
		add $a3 $t1 0				#
							#
							#
		jal draw_circle_pixels			#
							#
		BresLoop:				#
			ble $t1 $t0 Exit3		#
			addi $t0 $t0 1			#	
							#
			bgtz $t2 IfHam			#
							#
			mul $t3 $t0 4			#
			add $t2 $t3 $t2			#
			add $t2 $t2 6			#
							#
			add $a2 $t0 0			#
			add $a3 $t1 0			#
							#
			jal draw_circle_pixels		#
							#
			j BresLoop			#
							#
		IfHam:					#
			sub $t1 $t1 1			#
							#
			sub $t3 $t0 $t1			#
			mul $t3 $t3 4			#
			add $t2 $t3 $t2			#
			addi $t2 $t2 10			#
							#
			add $a2 $t0 0			#
			add $a3 $t1 0			#
							#
			jal draw_circle_pixels		#
							#
			j BresLoop			#
							#
	Exit3:						#
							#
	pop ($ra)					#
	pop $s4						#
	pop $s3						#
	pop $s2						#
	pop $s1						#
	pop $s0						#
	pop $t9						#
	pop $t8						#
	pop $t7						#
	pop $t6						#
	pop $t5						#
	pop $t4						#
	pop $t3						#
	pop $t2						#
	pop $t1						#
	pop $t0						#
							#
#------------------------------------------------------------------------------------------------------#
	jr $ra	
#*****************************************************
# draw_circle_pixels:
#  Function to draw the circle pixels 
#  using the octans' symmetry
#-----------------------------------------------------
# draw_circle_pixels(xc, yc, x, y)  
#    draw_pixel(xc+x, yc+y) 
#    draw_pixel(xc-x, yc+y)
#    draw_pixel(xc+x, yc-y)
#    draw_pixel(xc-x, yc-y)
#    draw_pixel(xc+y, yc+x)
#    draw_pixel(xc-y, yc+x)
#    draw_pixel(xc+y, yc-x)
#    draw_pixel(xc-y, yc-x)
#-----------------------------------------------------
#   Inputs:
#    $a0 = coordinates of circle center in format (0x00XX00YY)
#    $a1 = color of pixel in format (0x00RRGGBB)
#    $a2 = current x value from the Bresenham's circle algorithm
#    $a3 = current y value from the Bresenham's circle algorithm
#   Outputs:
#    No register outputs	
#*****************************************************
draw_circle_pixels: nop	
#------------------------------------------------------------------------------------------------------#		
							#
							#
push $t0						#
push $t1						#
push $t2						#
push $t3						#
push $t4						#
push $t5						#
push $t6						#
push $t7						#
push $t8						#
push ($ra)						#
							#$t7 = X
	addi $t7 $a2 0					#$t8 = Y
	addi $t8 $a3 0					#
							#
	getCoordinates($t6 $s2 $s3)			#
							#Color in $t9
	
		addi $s0 $s2 0
		addi $s1 $s3 0
		
	xcPxycPy:
		add $s0 $s0 $t7
		add $s1 $s1 $t8
		
		formatCoordinates($a0 $s0 $s1)
		
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0
		
	xcMxycPy:
		sub $s0 $s0 $t7
		add $s1 $s1 $t8
		
		formatCoordinates($a0 $s0 $s1)
	
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0
	
	xcPxycMy:
		add $s0 $s0 $t7
		sub $s1 $s1 $t8
		
		formatCoordinates($a0 $s0 $s1)
		
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0
	
	xcMxycMy:
		sub $s0 $s0 $t7
		sub $s1 $s1 $t8
		
		formatCoordinates($a0 $s0 $s1)
		
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0
		
	xcPyycPx:
		add $s0 $s0 $t8
		add $s1 $s1 $t7
		
		formatCoordinates($a0 $s0 $s1)
		
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0
	
	xcMyycPx:
		sub $s0 $s0 $t8
		add $s1 $s1 $t7
		
		formatCoordinates($a0 $s0 $s1)
		
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0	
		
	xcPyycMx:
		add $s0 $s0 $t8
		sub $s1 $s1 $t7
		
		formatCoordinates($a0 $s0 $s1)
	
		addi $a1 $t9 0
		jal draw_pixel
		
		addi $s0 $s2 0
		addi $s1 $s3 0
	
	xcMyycMx:
		sub $s0 $s0 $t8
		sub $s1 $s1 $t7
		
		formatCoordinates($a0 $s0 $s1)
		
		addi $a1 $t9 0
		jal draw_pixel
		
pop ($ra)	
pop $t8
pop $t7
pop $t6
pop $t5
pop $t4
pop $t3
pop $t2
pop $t1
pop $t0

#------------------------------------------------------------------------------------------------------#
jr $ra
