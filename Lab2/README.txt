Mathias Eriksen
mterikse
Spring 2020
Lab 2: Simple Data Path

DESCRIPTION:
In this lab, the user enters a number on the given keypad (displayed in hexadeci
mal notation numbers 0-15), and the number is then displayed on a register. The
register the number will be stored in is selected by the user out of 4.
The user can then chose two of the numbers stored in the registers, 
and do a bitwise rotation of the first number chosen by the second number 
chosen. This number will be shown in the ALU output, and stored in a selected
register.

FILES:
Lab2.lgi

This file includes the entirety of the lab

INSTRUCTIONS:  
First, hit clear to reset all values on the interface to zero. 
Then, enter a number on the keypad, and select the register you would like your
number to  be stored in. Make sure the 'Store Select is equal to 0.
The register is selected by entering a two bit numberusing the two switches 
labeled 'Write Register Address'. The number selected will enter the register 
selected after the user pushes the button labeled 'update'. Next the user can 
select a number to place in 'ALU Input 1' by entering the bit value of the 
register with the desired value using the switches under 'Read Register 1 
Address', and hitting update. Using the same process, instead under 'Read 
Register 2 Address', a value for 'ALU Input 2' can be selected. Once these two 
values are entered, and  the  user hits 'update' the system will do a bitwise 
rotation of the number entered in 'ALU Input 2' by the number in 'ALU Input 1",
and present it to the output labeled, "ALU Output". If the user wants this value
to overtake the value in one of the registers, they must enter the desired 
register under 'Write Register Address' and make the switch labeled 'Store 
Select" equal to 1.