
	.text
	.globl	main
#
# StringLenByte:
#
# Input Parameters:
#         $a0: pointer to null-terminated string (byte_pointer)
# Return Value:
#         $v0: number of characters in string (counter)
#
# Algorithm:
#	counter <-- 0
#   temp    <-- *byte_pointer
#	if(temp == 0)
#     return counter
#   do{
#      counter <-- counter + 1
#      byte_pointer <-- byte_pointer + 1
#      temp    <-- *byte_pointer
#     } while(temp != 0)
#   return counter
#
# Register Usage:
#   $a0: byte_pointer
#   $v0: counter
#   $t0: temp
#

StringLenByte:
			move	$v0, $zero			 # counter <-- 0
            lb      $t0, 0($a0)			 # temp <-- *byte_pointer
			beq		$t0, $zero, Return	 # if(temp == 0) goto Return
NextChar:
			addi	$v0, $v0, 1			 # counter <-- counter + 1
			addi	$a0, $a0, 1			 # byte_pointer <-- byte_pointer + 1
			lb		$t0, 0($a0)          # temp <-- *byte_pointer
			bne		$t0, $zero, NextChar # if(temp != 0) goto NextChair
Return:
			jr		$ra
	
#
# StringLenWord:
#
# Input Parameters:
#         $a0: pointer to null-terminated string (word_pointer)
# Return Value:
#         $v0: number of characters in string (counter)
#
# Assume little endian. Thus if the 4-byte word "YES\0" is loaded into $t4, 
# then $t4 will contain the value 0x '\0' 'S' 'E' 'Y' = 0x 0053 4559 
#
# Algorithm:
#	char_counter <-- 0
#   while(true){
#        mask <-- 0x0000 00FF
#        word_temp <-- *word_pointer
#        do {
#            byte = mask & word_temp
#            if(byte == 0)
#              return char_counter
#            char_counter <-- char_counter + 1
#            mask <-- mask << 8
#           } while(mask != 0)
#        word_pointer <-- word_pointer + 4
#       }
#
# Register Usage:
#   $a0: word_pointer
#   $v0: counter
#   $t0: word_temp
#   $t1: mask
#   $t2: temp
#

StringLenWord:
			move	$v0, $zero			# char_counter <-- 0
NextWord:
			li		$t1, 0xFF			 # mask <-- 0x0000 00FF
			lw		$t0, 0($a0)			 # word_temp <-- *word_pointer
NextByte:
			and		$t2, $t1, $t0	     # byte <-- mask & word_temp
			beq     $t2, $zero, Done     # if(byte == 0) goto Done
            addi	$v0, $v0, 1			 # char_counter <-- char_counter + 1
			sll		$t1, $t1, 8			 # mask <-- mask << 8
			bne		$t1, $zero, NextByte # if(mask != 0) goto NextByte
			addi	$a0, $a0, 4			 # word_pointer <-- word_pointer + 4
			j		NextWord
Done:
			jr		$ra

#
# main:
#
# Call TextString on several strings
#
main:
			addi	$sp, $sp, -4		# save $ra
			sw		$ra, 4($sp)
			la		$a0, StringA		# call StringLenByte on StringA
			jal		TestString
			la		$a0, StringB		# call StringLenWord on StringA
			jal		TestString
			la		$a0, StringC		# call StringLenByte on StringB
			jal		TestString
			lw		$ra, 4($sp)			# restore $ra and $s0
			addi	$sp, $sp, 4
			jr		$ra
#
# TestString:
#
# Input Parameters:
#		$a0: (StringAddress) address of a null-terminated string 
#
# Return Value:
#		None
#
# Algorithm:
#		Print a message
#		Print(StringAddress)
#       ByteValue <-- StringLenByte(StringAddress)
#       WordValue <-- StringLenWord(StringAddress)
#		if(ByteValue == WordValue)
#          Print(ByteValue)
#		else
#		   Print String Length Byte Message
#		   Print(ByteValue)
#		   Print String Lenght Word Message
#		   Print(WordValue)
#		Print(NewLine)
#
TestString:
			addi	$sp, $sp, -16	# save $ra, $s0, $s1, $s2
			sw		$ra, 0($sp)
			sw		$s0, 4($sp)
			sw		$s1, 8($sp)
			sw		$s2, 12($sp)
			move	$s0, $a0		# $s0 <-- StringAddress
			li		$v0, 4			# Print StringMsg
			la		$a0, StringMsg
			syscall
			li		$v0, 4			# Print the string
			move	$a0, $s0		# $a0 <-- StringAddress
			syscall
			move	$a0, $s0		# $a0 <-- StringAddress
			jal		StringLenByte	# StringLenByte(StringAddress)
			move	$s1, $v0		# $s1 <-- ByteValue
			move	$a0, $s0		# $a0 <-- StringAddress
			jal		StringLenWord   # StringLenWord(StringAddress)
		    bne		$v0, $s1, Error # if(ByteValue != WordValue) goto Error 
			li		$v0, 4			# Print LengthMsg
			la		$a0, LengthMsg
			syscall
			li		$v0, 1			# Print ByteValue
			move	$a0, $s1		# $a0 <-- ByteValue
			syscall
			j		DoneTestString
Error:
			move	$s2, $v0		# $s2 <-- StringLenWord value
			li		$v0, 4			# Print ErrorByteMsg
			la		$a0, ErrorByteMsg	
			syscall
			li		$v0, 1			# Print ByteValue
			move	$a0, $s1
			syscall						
			li		$v0, 4			# Print ErrorWordMsg
			la		$a0, ErrorWordMsg
			syscall
			li		$v0, 1			# Print WordValue
			move	$a0, $s2
			syscall
DoneTestString:
			li		$v0, 4			# Print New Line
			la		$a0, NewLine
			syscall
			lw		$ra, 0($sp)		# restore $ra, $s0, $s1, $s2
			lw		$s0, 4($sp)
			lw		$s1, 8($sp)
			lw		$s2, 12($sp)
			addi	$sp, $sp, 16		
			jr		$ra
.data
StringA:	
			.asciiz	"class"
			.byte	0           # leave 2 bytes empty to align next word
			.byte   0
StringB:
			.asciiz "classes"   # occupies exactly two 4-byte words
StringC:	
			.asciiz "0123456789012345678901234567890123456789"
StringMsg:
			.asciiz "String: "
LengthMsg: 
			.asciiz "   Length: "
ErrorByteMsg:
			.asciiz "   Byte Length: "
ErrorWordMsg:
			.asciiz "   Word Length: "
NewLine:
			.asciiz "\n"
			