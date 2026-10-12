	.file	"kernel.c"
	.text
	.p2align 4
	.globl	strlen
	.type	strlen, @function
strlen:
	pushl	%ebp
	xorl	%eax, %eax
	movl	%esp, %ebp
	movl	8(%ebp), %edx
	cmpb	$0, (%edx)
	je	.L1
	.p2align 4
	.p2align 4
	.p2align 3
.L3:
	addl	$1, %eax
	cmpb	$0, (%edx,%eax)
	jne	.L3
.L1:
	popl	%ebp
	ret
	.size	strlen, .-strlen
	.p2align 4
	.globl	terminal_initialize
	.type	terminal_initialize, @function
terminal_initialize:
	movl	terminal_buffer, %ecx
	movb	$7, terminal_color
	movl	$0, terminal_row
	movl	$0, terminal_column
	leal	160(%ecx), %edx
	addl	$4160, %ecx
	.p2align 4
	.p2align 3
.L9:
	leal	-160(%edx), %eax
	.p2align 5
	.p2align 4
	.p2align 3
.L10:
	movw	$1824, (%eax)
	addl	$4, %eax
	movw	$1824, -2(%eax)
	cmpl	%edx, %eax
	jne	.L10
	leal	160(%eax), %edx
	cmpl	%ecx, %edx
	jne	.L9
	ret
	.size	terminal_initialize, .-terminal_initialize
	.p2align 4
	.globl	terminal_setcolor
	.type	terminal_setcolor, @function
terminal_setcolor:
	pushl	%ebp
	movl	%esp, %ebp
	movzbl	8(%ebp), %eax
	popl	%ebp
	movb	%al, terminal_color
	ret
	.size	terminal_setcolor, .-terminal_setcolor
	.p2align 4
	.globl	terminal_putentryat
	.type	terminal_putentryat, @function
terminal_putentryat:
	pushl	%ebp
	movl	%esp, %ebp
	movzbl	12(%ebp), %edx
	movzbl	8(%ebp), %ecx
	movl	20(%ebp), %eax
	sall	$8, %edx
	orl	%ecx, %edx
	leal	(%eax,%eax,4), %eax
	movl	terminal_buffer, %ecx
	sall	$4, %eax
	addl	16(%ebp), %eax
	movw	%dx, (%ecx,%eax,2)
	popl	%ebp
	ret
	.size	terminal_putentryat, .-terminal_putentryat
	.p2align 4
	.globl	terminal_putchar
	.type	terminal_putchar, @function
terminal_putchar:
	movzbl	terminal_color, %edx
	movl	terminal_column, %ecx
	pushl	%ebp
	sall	$8, %edx
	movl	%esp, %ebp
	pushl	%esi
	pushl	%ebx
	movl	terminal_row, %ebx
	movzbl	8(%ebp), %esi
	leal	(%ebx,%ebx,4), %eax
	orl	%esi, %edx
	sall	$4, %eax
	movl	terminal_buffer, %esi
	addl	%ecx, %eax
	movw	%dx, (%esi,%eax,2)
	cmpl	$79, %ecx
	je	.L19
	leal	1(%ecx), %eax
	popl	%ebx
	popl	%esi
	movl	%eax, terminal_column
	popl	%ebp
	ret
	.p2align 4,,10
	.p2align 3
.L19:
	movl	$0, terminal_column
	leal	1(%ebx), %eax
	xorl	%edx, %edx
	cmpl	$24, %ebx
	cmove	%edx, %eax
	popl	%ebx
	popl	%esi
	popl	%ebp
	movl	%eax, terminal_row
	ret
	.size	terminal_putchar, .-terminal_putchar
	.p2align 4
	.globl	terminal_write
	.type	terminal_write, @function
terminal_write:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$20, %esp
	movl	12(%ebp), %eax
	testl	%eax, %eax
	je	.L23
	movzbl	terminal_color, %edx
	movl	%edi, -4(%ebp)
	movl	%ebx, -12(%ebp)
	movl	terminal_buffer, %edi
	sall	$8, %edx
	movl	%esi, -8(%ebp)
	movw	%dx, -18(%ebp)
	movl	8(%ebp), %edx
	addl	%edx, %eax
	movl	%eax, -16(%ebp)
	jmp	.L28
	.p2align 6
	.p2align 4,,10
	.p2align 3
.L25:
	movl	%eax, terminal_column
	addl	$1, %edx
	cmpl	%edx, -16(%ebp)
	je	.L34
.L28:
	movl	terminal_row, %esi
	movl	terminal_column, %ecx
	movzbl	(%edx), %ebx
	orw	-18(%ebp), %bx
	leal	(%esi,%esi,4), %eax
	sall	$4, %eax
	addl	%ecx, %eax
	movw	%bx, (%edi,%eax,2)
	leal	1(%ecx), %eax
	cmpl	$79, %ecx
	jne	.L25
	movl	$0, terminal_column
	xorl	%ecx, %ecx
	leal	1(%esi), %eax
	cmpl	$24, %esi
	cmove	%ecx, %eax
	addl	$1, %edx
	movl	%eax, terminal_row
	cmpl	%edx, -16(%ebp)
	jne	.L28
.L34:
	movl	-12(%ebp), %ebx
	movl	-8(%ebp), %esi
	movl	-4(%ebp), %edi
.L23:
	leave
	ret
	.size	terminal_write, .-terminal_write
	.p2align 4
	.globl	terminal_writestring
	.type	terminal_writestring, @function
terminal_writestring:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$20, %esp
	movl	8(%ebp), %edx
	cmpb	$0, (%edx)
	je	.L35
	movl	%ebx, -12(%ebp)
	xorl	%eax, %eax
	movl	%esi, -8(%ebp)
	movl	%edi, -4(%ebp)
	.p2align 4
	.p2align 4
	.p2align 3
.L37:
	addl	$1, %eax
	cmpb	$0, (%edx,%eax)
	jne	.L37
	movzbl	terminal_color, %ecx
	addl	%edx, %eax
	movl	terminal_buffer, %edi
	movl	%eax, -16(%ebp)
	sall	$8, %ecx
	movw	%cx, -18(%ebp)
	jmp	.L41
	.p2align 6
	.p2align 4,,10
	.p2align 3
.L38:
	movl	%eax, terminal_column
	addl	$1, %edx
	cmpl	%edx, -16(%ebp)
	je	.L45
.L41:
	movl	terminal_row, %esi
	movl	terminal_column, %ecx
	movzbl	(%edx), %ebx
	orw	-18(%ebp), %bx
	leal	(%esi,%esi,4), %eax
	sall	$4, %eax
	addl	%ecx, %eax
	movw	%bx, (%edi,%eax,2)
	leal	1(%ecx), %eax
	cmpl	$79, %ecx
	jne	.L38
	movl	$0, terminal_column
	xorl	%ecx, %ecx
	leal	1(%esi), %eax
	cmpl	$24, %esi
	cmove	%ecx, %eax
	addl	$1, %edx
	movl	%eax, terminal_row
	cmpl	%edx, -16(%ebp)
	jne	.L41
.L45:
	movl	-12(%ebp), %ebx
	movl	-8(%ebp), %esi
	movl	-4(%ebp), %edi
.L35:
	leave
	ret
	.size	terminal_writestring, .-terminal_writestring
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Hello, kernel World!\n"
	.text
	.p2align 4
	.globl	kernel_main
	.type	kernel_main, @function
kernel_main:
	pushl	%ebp
	movl	%esp, %ebp
	pushl	%edi
	movl	terminal_buffer, %edi
	pushl	%esi
	pushl	%ebx
	leal	160(%edi), %edx
	leal	4160(%edi), %ecx
	movl	$0, terminal_row
	movb	$7, terminal_color
	.p2align 4
	.p2align 3
.L47:
	leal	-160(%edx), %eax
	.p2align 5
	.p2align 4
	.p2align 3
.L48:
	movl	$1824, %ebx
	movl	$1824, %esi
	addl	$4, %eax
	movw	%bx, -4(%eax)
	movw	%si, -2(%eax)
	cmpl	%edx, %eax
	jne	.L48
	leal	160(%eax), %edx
	cmpl	%ecx, %edx
	jne	.L47
	movl	$.LC0, %edx
	xorl	%ecx, %ecx
	xorl	%esi, %esi
	jmp	.L54
.L58:
	movl	%eax, terminal_column
	addl	$1, %edx
	movl	$.LC0+21, %eax
	cmpl	%edx, %eax
	je	.L46
.L59:
	movl	terminal_row, %esi
	movl	terminal_column, %ecx
.L54:
	movzbl	(%edx), %ebx
	leal	(%esi,%esi,4), %eax
	sall	$4, %eax
	addl	%ecx, %eax
	orb	$7, %bh
	movw	%bx, (%edi,%eax,2)
	leal	1(%ecx), %eax
	cmpl	$79, %ecx
	jne	.L58
	movl	$0, terminal_column
	xorl	%ecx, %ecx
	leal	1(%esi), %eax
	cmpl	$24, %esi
	cmove	%ecx, %eax
	addl	$1, %edx
	movl	%eax, terminal_row
	movl	$.LC0+21, %eax
	cmpl	%edx, %eax
	jne	.L59
.L46:
	popl	%ebx
	popl	%esi
	popl	%edi
	popl	%ebp
	ret
	.size	kernel_main, .-kernel_main
	.globl	terminal_buffer
	.data
	.align 4
	.type	terminal_buffer, @object
	.size	terminal_buffer, 4
terminal_buffer:
	.long	753664
	.globl	terminal_color
	.section	.bss
	.type	terminal_color, @object
	.size	terminal_color, 1
terminal_color:
	.zero	1
	.globl	terminal_column
	.align 4
	.type	terminal_column, @object
	.size	terminal_column, 4
terminal_column:
	.zero	4
	.globl	terminal_row
	.align 4
	.type	terminal_row, @object
	.size	terminal_row, 4
terminal_row:
	.zero	4
	.ident	"GCC: (GNU) 16.2.0"
