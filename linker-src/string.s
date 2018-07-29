# CS 61C Spring 2015 Project 1-2 
# string.s

#==============================================================================
#                              Project 1-2 Part 1
#                               String README
#==============================================================================
# In this file you will be implementing some utilities for manipulating strings.
# The functions you need to implement are:
#  - strlen()
#  - strncpy()
#  - copy_of_str()
# Test cases are in linker-tests/test_string.s
#==============================================================================

.data
newline:	.asciiz "\n"
tab:	.asciiz "\t"

.text
#------------------------------------------------------------------------------
# function strlen()
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = string input
#
# Returns: the length of the string
#------------------------------------------------------------------------------
strlen:
	li $v0, 0	# Begin strlen()
	lb $t2, 0($a0)	# Load the first char
	beq $t2, $0, strlen_end	# String empty, return 0
strlen_loop:
	addiu $v0, $v0, 1	# Counter++;
	addiu $a0, $a0, 1	# Load the next char
	lb $t2, 0($a0)
	bne $t2, $0, strlen_loop	# Not '\0', keep going
strlen_end:
	jr $ra	# End strlen()

#------------------------------------------------------------------------------
# function strncpy()
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = pointer to destination array
#  $a1 = source string
#  $a2 = number of characters to copy
#
# Returns: the destination array
#------------------------------------------------------------------------------
strncpy:
	move $v0, $a0	# Begin strncpy()
	lb $t2, 0($a1)	# Load first char
	beq $t2, $0, strncpy_end	# Return if source string empty
	beq $a2, $0, strncpy_end	# Return if n == 0
strncpy_loop:
	sb $t2, 0($a0)	# Write the char
	addiu $a0, $a0, 1	# Two char* pointers++;
	addiu $a1, $a1, 1
	subiu $a2, $a2, 1	# n--;
	beq $a2, $0, strncpy_end	# Return if source string ends
	lb $t2, 0($a1)
	beq $t2, $0, strncpy_end	# Return if n chars written
	j strncpy_loop
strncpy_end:
	sb $0, 0($a0)	# Writen '\0' at end
	jr $ra	# End strncpy()

#------------------------------------------------------------------------------
# function copy_of_str()
#------------------------------------------------------------------------------
# Creates a copy of a string. You will need to use sbrk (syscall 9) to allocate
# space for the string. strlen() and strncpy() will be helpful for this function.
# In MARS, to malloc memory use the sbrk syscall (syscall 9). See help for details.
#
# Arguments:
#   $a0 = string to copy
#
# Returns: pointer to the copy of the string
#------------------------------------------------------------------------------
copy_of_str:
	addiu $sp, $sp, -12	# Begin copy_of_str()
	sw $s6, 8($sp)	# Make stack
	sw $s7, 4($sp)
	sw $ra, 0($sp)
	
	move $s6, $a0	# Save address of source string in $s6
	
	jal strlen	# Get length of string
	move $a0, $v0
	
	addiu $a0, $a0, 1	# Bytes to allocate = length + 1 ('\0')
	li $v0, 9	# Allocate memory for that length
	syscall
	move $s7, $v0	# Address of allocated string stored in $s7
	
	subiu $a0, $a0, 1	# Restore bytes to copy
	move $a2, $a0	# Call strncpy() on $s6, $s7
	move $a0, $s7
	move $a1, $s6
	jal strncpy
	
	lw $ra, 0($sp)	# Recycle stack
	lw $s7, 4($sp)
	lw $s6, 8($sp)
	addiu $sp, $sp, 12
	jr $ra	# End copy_of_str()

###############################################################################
#                 DO NOT MODIFY ANYTHING BELOW THIS POINT                       
###############################################################################

#------------------------------------------------------------------------------
# function streq() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Arguments:
#  $a0 = string 1
#  $a1 = string 2
#
# Returns: 0 if string 1 and string 2 are equal, -1 if they are not equal
#------------------------------------------------------------------------------
streq:
	beq $a0, $0, streq_false	# Begin streq()
	beq $a1, $0, streq_false
streq_loop:
	lb $t0, 0($a0)
	lb $t1, 0($a1)
	addiu $a0, $a0, 1
	addiu $a1, $a1, 1
	bne $t0, $t1, streq_false
	beq $t0, $0, streq_true
	j streq_loop
streq_true:
	li $v0, 0
	jr $ra
streq_false:
	li $v0, -1
	jr $ra			# End streq()

#------------------------------------------------------------------------------
# function dec_to_str() - DO NOT MODIFY THIS FUNCTION
#------------------------------------------------------------------------------
# Convert a number to its unsigned decimal integer string representation, eg.
# 35 => "35", 1024 => "1024". 
#
# Arguments:
#  $a0 = int to write
#  $a1 = character buffer to write into
#
# Returns: the number of digits written
#------------------------------------------------------------------------------
dec_to_str:
	li $t0, 10			# Begin dec_to_str()
	li $v0, 0
dec_to_str_largest_divisor:
	div $a0, $t0
	mflo $t1		# Quotient
	beq $t1, $0, dec_to_str_next
	mul $t0, $t0, 10
	j dec_to_str_largest_divisor
dec_to_str_next:
	mfhi $t2		# Remainder
dec_to_str_write:
	div $t0, $t0, 10	# Largest divisible amount
	div $t2, $t0
	mflo $t3		# extract digit to write
	addiu $t3, $t3, 48	# convert num -> ASCII
	sb $t3, 0($a1)
	addiu $a1, $a1, 1
	addiu $v0, $v0, 1
	mfhi $t2		# setup for next round
	bne $t2, $0, dec_to_str_write
	jr $ra			# End dec_to_str()
