	;; boot.s -- Kernel start location. Also defines multiboot header.
	;; Based on Bran's kernel development tutorial start.asm file.

	;; Load kernel and modules on a page boundary
	MBOOT_PAGE_ALIGN	equ 1<<0

	;; Provide kernel with memory info
	MBOOT_MEM_INFO		equ 1<<1

	;; Multiboot Magic value
	MBOOT_HEADER_MAGIC	equ 0x1BADB002 

	;; Note: we don't use MBOOT_AOUT_KLUDGE. It means that GRUB does not
	;; pass us a symbol table

	MBOOT_HEADER_FLAGS	equ MBOOT_PAGE_ALIGN | MBOOT_MEM_INFO
	MBOOT_CHECKSUM		equ -(MBOOT_HEADER_MAGIC + MBOOT_HEADER_FLAGS)

	[BITS 32]		; all instructions as 32 bit

	[GLOBAL mboot]		; Make 'mboot' accessible from C
	[EXTERN code]		; Start of the .text section
	[EXTERN bss]		; Start of the .bss section
	[EXTERN end]		; End of the last loadable section

mboot:
	dd MBOOT_HEADER_MAGIC	; GRUB will search for this value on each
				; 4-byte boundary in your kernel file
	dd MBOOT_HEADER_FLAGS	; How GRUB should load your file / settings
	dd MBOOT_CHECKSUM	; To ensure that the above values are correct

	dd mboot		; Location of this descriptor
	dd code			; Start of kernel .text (code) section
	dd bss			; End of kernel .data section
	dd end			; End of kernel.
	dd start		; Kernel entry point (initial %eip)

	[GLOBAL start]		; Kernel entry point.
	[EXTERN main]		; This is the entry point of our C code

start:
	push	ebx		; Load multiboot header location
	
	;; execute the kernel:
	cli			; Disable interrupts
	call	main		; Call our main() function
	jmp	$		; Enter an infinite loop, to stop the processor
				; from executing whatever is in the memory
				; after our kernel
