# Who:  Meetkumar Patel
# What: numberArrayOperations.asm
# Why:  Project 3 
# When: Created: 03/24/19 Due: 04/02/19
# How:  List the uses of registers: t0, t1, s0 - quantity_prompt entry, s1 - counter

.data
array:							.space				200
array_size:						.word				50
quantity_prompt:				.asciiz				"How many integers would you like to enter: "
input_prompt:					.asciiz				"Please enter an integer: "
display_sorted_array:			.asciiz				"The sorted array containing entered values is: "
value_search_prompt:			.asciiz				"\nPlease provide a value to search for in the array: "
found_value:					.asciiz				"The entered value is found in the array."
not_found_value:				.asciiz				"The entered value is not located in the array."


.text
.globl main


main:									# program entry

# prompt for quantity of signed integers	
la $a0, quantity_prompt					# loading the address of quantity_prompt into a0.				
li $v0, 4								
syscall									# print the quantity_prompt
li $v0, 5
syscall									# read the input integer
add $s0, $v0, $0						# s0 stores quantity_prompt entry.


addu $s1, $0, $0						# counter = 0, needed to keep track of how many times to ask for integer

loop:
# while counter (s1) <= quantity_prompt entry (s0)
slt $t0, $s1, $s0
beq $t0, $0, endloop					# exit when finished reading required integers
addi $s1, $s1, 1						# increment the counter
la $a0, input_prompt					# loading the address of input_prompt into a0.				
li $v0, 4								
syscall									# print the input_prompt to request for integer
li $v0, 5
syscall									# read the input integer
add $a2, $v0, $0						# store the user entered input integer in a2 for subroutine
la $a0, array							# load the address of array in a0 for subroutine
addu $a1, $s1, $0						# moving the counter variable to size variable for subroutine
jal insert_Begining						# calls subroutine
j loop
endloop:



#display_sorted_array												
la $a0, display_sorted_array
li $v0, 4								
syscall									# print the input_prompt
	
add $s1, $0, $0							# reset the counter
	
# Print the sorted integers space-separated.
output_loop:
slt $t0, $s0, $s1						# quantity_prompt entry (s0) < counter(s1)
beq $s1, $s0, exit_output_loop			# exit when done printing all numbers

sll $t1, $s1, 2							# multiply counter by 4
lw $a0, array($t1)						# loading the vlaue from the array
li $v0, 1
syscall									# print the array number
li $v0, 11								# print a empty character line below
li $a0, 0x20							# for space
syscall									# allow separation between numbers

addi $s1, $s1, 1						# increment counter

j output_loop
exit_output_loop:						# exit the output_loop



search_loop:							# for binarySearch
# asks user for search input
la $a0, value_search_prompt				# loading the address of value_search_prompt into a0.				
li $v0, 4								
syscall									# print the input_prompt
li $v0, 5
syscall									# read the input integer form the user
# loads in variables into the subroutine
la $a0, array							# array to search on
li $a1, 0								# start of array
addi $a2, $s0, -1						# end of array
addu $a3, $v0, $0						# value to search
jal binarySearch						# calls subroutine

bne $v0, $0, success
la $a0, not_found_value
li $v0, 4
syscall									# print not_found_value in binarySearch
j search_loop							# for infinite loop
success:
la $a0, found_value
li $v0, 4
syscall									# print found_value in binarySearch
j search_loop							# for infinite loop





li $v0, 10								# terminate the program
syscall










# Subroutine to always keep the user entered numbers in sorted array
# void insert(int* array, int size, int value){
# 	int counter = 0;
# 	while(counter < size && array[counter] < value){ counter++; }
# 	if(counter >= size){ 
# 		array[size] = value; 
# 	} else {
# 		int swap = array[counter];
# 		array[counter] = value;
#		counter++;
#
#		while(counter < size){
#			value = array[counter];
#			array[counter] = swap;
#			swap = value;
#			counter++;
#		}
#	}
#}

insert_Begining:					# void insert (int* array [a0], int size [a1], int value [a2])

addiu $t0, $0, 0					# int counter = 0

whileLoop:
slt $t1, $t0, $a1					# if (counter < size)
beq $t1, $0, whileLoopEnd			# exit first while loop. short-circuit evaluation
sll $t1, $t0, 2						# Multiply counter by 4
addu $t1, $t1, $a0					# add start of aray to counter * 4
lw $t1, 0($t1)						# load from that address
slt $t1, $t1, $a2					# if (array[counter] < value)
beq $t1, $0, whileLoopEnd			# exit first while loop. short-circuit evaluation
addiu $t0, $t0, 1					# counter++. Outcome of the loop
j whileLoop
whileLoopEnd:


slt $t1, $t0, $a1					# if(!(counter < size)) same as if(counter >= size)
bne $t1, $0, elseLoop				# if t1 is 0 then we do the elseloop
# array[size] = value
sll $t0, $a1, 2
addu $t0, $t0, $a0
sw $a2, -4($t0)
j insert_return


elseLoop:
# int swap = array[counter]
sll $t1, $t0, 2						# Multiply counter by 4
addu $t1, $t1, $a0					# add start of aray to counter * 4
lw $a3, 0($t1)						# load from that address. swap is in a3
# array[counter] = value
sw $a2, 0($t1)
addiu $t0, $t0, 1					# counter++

whileInner:
slt $t1, $t0, $a1					# if (counter < size) 
beq $t1, $0, whileInnerEnd			# exit the loop
# value = array[counter]
sll $t1, $t0, 2						# Multiply vounter by 4
addu $t1, $t1, $a0					# add start of aray to counter * 4
lw $a2, 0($t1)
# array[counter] = swap
sw $a3, 0($t1)
# swap = value
addu $a3, $a2, $0
addiu $t0, $t0, 1					# counter++
j whileInner
whileInnerEnd:
elseLoopEnd:



insert_return:
jr $ra










# Subroutine for binary search
#	binarySearch(&array, start, end, searchVal){
#		if (start > end)
#			return false
# 
#		mid = start + (end - start)/2;
# 
#		if (array[mid] == searchVal)
#			return true;
# 
#		if (array[mid] > searchVal)
#			return binarySearch(array, start, mid-1, searchVal);
# 
#		return binarySearch(array, mid+1, end, searchVal);
#	}



binarySearch:
# arguments: binarySearch(&array[a0], start[a1], end[a2], searchVal[a3])
# return: v0 returns 1 if found or 0 if not found
									
								
slt $t0, $a2, $a1					# if (start > end) {return false;}	
beq $t0, $0, valid_bound

add $v0, $0, $0						# value not found
jr $ra								# exit the subroutine

valid_bound:
sub $t0, $a2, $a1					# (end - start)
sra $t0, $t0, 1						# (end - start)/2
add $t1, $a1, $t0					# start + (end - start)/2 = mid in t1

#add $t1, $a1, $a2		
#sra $t1, $t1, 1					# divide by 2, mid is in t1

# if statement
sll $t0, $t1, 2						# multiply by 4
addu $t0, $t0, $a0 					# form a pointer
lw $t0, 0($t0)						# load the value of array into t0
# array[mid] is in $t0

bne $t0, $a3, recursion				# if (array[mid] == searchVal)
addi $v0, $0, 1						# value found
jr $ra

recursion:
addiu $sp, $sp, -4
sw $ra, 0($sp)

slt $t0, $a3, $t0					# if (array[mid] > searchVal)
bne $t0, $0, left_recursion			# go to left_recursion if not true

addi $a1, $t1, 1					# start = mid + 1
jal binarySearch
j search_return

left_recursion:
addi $a2, $t1, -1					# end = mid - 1
jal binarySearch

search_return:
lw $ra, 0($sp)
addiu $sp, $sp, 4
jr $ra


