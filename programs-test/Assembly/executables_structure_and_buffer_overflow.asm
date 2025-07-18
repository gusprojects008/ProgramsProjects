; x86-64

; NASM (the NASM assembler converts assembly source code (which follows a specific archtecture: x86 or x86_64), into machine code for the specific x86 or x86_64 architecture). These architectures follow the CISC architecture model.

section .data	; used to store data and variables.
	prompt db "Type it data entry: ", 0 ; "0" is null byte
        len_prompt equ $ - prompt ; calculates the length of the string in "prompt". Subtracts the current memory position from the starting address of the string .
	; "equ" is "equate", defines a constant based on a fixed expression, such as ($ - msg). This way it can capture the exect value of "$", and define a constant based on the expression (operation performed with the value "$") "$" - msg, used to obtain the length of the string.symbolic constant.
        ; "$" is an intern NASM counter/offset, it is used by the assembler during the assembly of the assembly code to the machine code. It is called "location counter", it basically represents the current memory position address in the program, according to the assembler, exemple:
	; current position address of ".data" = 0x00000000
	; start address of: prompt db "Type it data entry: " =  0x00000000
	; after storing: "Type it data entry: " = 0x00000020 which is equal 32 bytes.
	; Now the assembler reservs 32 bytes for string  ("T","y","p","e"," ","i","t", ....) and so the value of the counter is equal to the amount of bytes that the string has, since its value increases according to the amount of bytes that are stored and counted by the assembler, which in this case are 32 bytes, the size of the string. And so it continues offset.
	; But when we use "equ" to define a constant based on a fixed expression, which uses the value of the current memory position "$" - initial memory position of the string, it becomes possible to obtain the size of the string, since the counter at the moment has exctaly 32 bytes registered, according to the value of the current memory position address.
	; These addresses are not physical memory addresses that the program will use, they are only created and used by the assembler, during the analysis of the sections and assembly of the real machine code.
	; The linker defines the virtual memory addresses that will be used by the program.
	; The value of the counter "$" is always reset for each new section.

        msg db "You typed: ", 0 
        len_msg equ $ - msg 

section .bss ; used to store uninitialized data and variables.      
	buffer resb 16 ; Small buffer on purpose to demonstrate overflow
        len_buffer equ $ - buffer
        ; Allocates 16 bytes for the input buffer. When typing more than that, the buffer overflow, meaning that the data goes beyond this buffer and starts to overwrite data in other register and other memory areas.
        ; This can eventually be exploited and allow an attcker, through malicious code, to insert data on purpose until it reaches the memory area of the instruction pointer register with a memory address that corresponds to malicious instructions, which can cause the program to execute arbitrary code on the system.

section .text	; section that organize the program instructions to be executed.
	global _start ; define "_start" as a global token for the linker. "_start" is the default entry point for the intial execution of the program, equivalent to the "main()" function.
		; The assembler is responsible for receiving the assembly source code and generating the object file or files the machine code corresponding to the processor architecture. In the end, a linker is needed to combine the object files (.o/.obj) into a final executable in the format that the operating system understands (ELF linux or PE windows.
		; The assembler basically converts instructions and register mnemonics into binary opcodes corresponding to the processor registers of the specific architecture.
		; When a program doesn't depend on external dependencies (like this one in assembly), the linker can receive a single object file generated by the assembler/compiler and turn it into an executable program.

_start:
	; writes the "prompt" string to the program's standard output.
	mov rax, 1 ; sys_write
        mov rdi, 1 ; fd stdout
        mov rsi, prompt
        mov rdx, len_prompt
        syscall

        ; Reads the kernel buffer related to keyboard input, througha fd to "/dev/tty". The fd is associated with an open charecter device file: "/dev/tty", it is a virtual device, managed by a virtual driver, created by the kernel's tty subssytem, it manages the kernel buffer, related to keyboard input.
	; The kernel creates creates and uses it to provide a basic initial terminal interface, and also an interface for terminals and programs to read keyboard input data.
	mov rax, 0 ; sys_read
	mov rdi, 0 ; fd stdin
	mov rsi, buffer
	mov rdx, 256 ; allow you to read much more data than the buffer is capable of storing 
	syscall

	mov rax, 1 ; sys_write
	mov rdi, 1 ; fd stdout
	mov rsi, msg
	mov rdx, len_msg 
	syscall

	mov rax, 1 ; sys_write
	mov rdi, 1 ; fd stdout
	mov rsi, buffer
	mov rdx, len_buffer
	syscall

	mov rax, 60 ; sys_exit
	mov rdi, 0 ; 0 status, the program as executed successfully until the end
	syscall
