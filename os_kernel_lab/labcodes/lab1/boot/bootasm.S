#include <asm.h>

# Start the CPU: switch to 32-bit protected mode, jump into C.
# The BIOS loads this code from the first sector of the hard disk into
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs=0 %ip=7c00.

# 80386CPU为了兼容8086程序，最开始启动时是以16位的实模式进行工作的
# 生成img磁盘映像时，bootasm.S中的引导代码将会被放在引导扇区
# 80386CPU加电启动后，会执行BIOS中的默认引导程序，BIOS引导程序会将引导扇区中(第一个磁盘块)的内容读入内存，并放置在0x7C00(16位)/0x00007c00(32位)处
# 随后CPU会跳转到0x7c00处开始第一条指令的执行，即bootasm.S的第一条指令(start:)

.set PROT_MODE_CSEG,        0x8                     # kernel code segment selector
.set PROT_MODE_DSEG,        0x10                    # kernel data segment selector
.set CR0_PE_ON,             0x1                     # protected mode enable flag

# start address should be 0:7c00, in real mode, the beginning address of the running bootloader
.globl start
start:
.code16                                             # Assemble for 16-bit mode
    cli                                             # Disable interrupts
    cld                                             # String operations increment

    # Set up the important data segment registers (DS, ES, SS).
    xorw %ax, %ax                                   # Segment number zero
    movw %ax, %ds                                   # -> Data Segment
    movw %ax, %es                                   # -> Extra Segment
    movw %ax, %ss                                   # -> Stack Segment

    # Enable A20:
    #  For backwards compatibility with the earliest PCs, physical
    #  address line 20 is tied low, so that addresses higher than
    #  1MB wrap around to zero by default. This code undoes this.

    # 为了进入32位保护模式，必须先开启A20(第21位内存访问线)，否则在32位寻址模式下给出的内存地址第21位始终为0，造成错误
    # 为什么需要特意开启A20总线?
    # 在早期的8086CPU中，内存总线是20位的，由高16位的段基址和低16位的段内偏移共同构成一个20位的内存地址
    # 但事实上在段基址和段内偏移比较大的情况下，其实际得出的结果是超过了20位的(例如0xFFFF段基址 <<< 4 + 0xFFFF段内偏移 > 0xFFFFF)，出现了溢出
    # 而8086中对这种溢出是兼容的，这种溢出在8086上会体现为绕回0x00000低端
    # “程序员，你是知道的，他们喜欢钻研，更喜欢利用硬件的某些特性来展示自己的技术，很难说在当年有多少程序在依赖这个回绕特性工作着”
    # 摘自《X86汇编语言 从实模式到保护模式》 11.5 关于第21条地址线A20的问题
    # 到了更新版的80286时代，24位的内存总线，如果不默认关闭A20总线，那么就无法兼容使用回绕特性的8086程序了
    # 而80386作为80286的后一代，也继承了80286这一特性
seta20.1:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al                                 # 0xd1 -> port 0x64
    outb %al, $0x64                                 # 0xd1 means: write data to 8042’s P2 port

seta20.2:
    inb $0x64, %al                                  # Wait for not busy(8042 input buffer empty).
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al                                 # 0xdf -> port 0x60
    outb %al, $0x60                                 # 0xdf = 11011111, means set P2’s A20 bit(the 1 bit) to 1

    # Switch from real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual addresses
    # identical to physical addresses, so that the
    # effective memory map does not change during the switch.
    # 设置GDT，修改CRO寄存器中的保护模式允许位，进入保护模式
    lgdt gdtdesc
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    # Jump to next instruction, but in 32-bit code segment.
    # Switches processor into 32-bit mode.
    # 通过一个远跳转指令指向protcseg处的指令，令CPU清空之前在实模式下保存在流水线中的指令(当前处于保护模式下执行实模式的指令会出现各种问题)
    ljmp $PROT_MODE_CSEG, $protcseg

# 下面的都是X86-32的汇编程序
.code32                                             # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    # 跳转至保护模式后，需要刷新数据段寄存器(因为引入了特权级保护，避免数据段寄存器之前的值不对而出现漏洞)
    movw $PROT_MODE_DSEG, %ax                       # Our data segment selector
    movw %ax, %ds                                   # -> DS: Data Segment
    movw %ax, %es                                   # -> ES: Extra Segment
    movw %ax, %fs                                   # -> FS
    movw %ax, %gs                                   # -> GS
    movw %ax, %ss                                   # -> SS: Stack Segment

    # Set up the stack pointer and call into C. The stack region is from 0--start(0x7c00)
    # 设置栈段寄存器 栈基址0x0，栈顶指针指向start段所在位置(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp
    # 调用跳转至bootmain.c中的bootmain函数，完成内核的引导
    call bootmain

    # If bootmain returns (it shouldn’t), loop.
    # 自旋死循环(但如果引导程序和内核实现正确，bootmain函数将永远不会返回并执行至此。因为操作系统内核本身就是通过自旋循环常驻内存的)
spin:
    jmp spin

# Bootstrap GDT
.p2align 2                                          # force 4 byte alignment
# SEG_ASM是位于asm.h中的宏，用于构造GDT中的段描述符
# 按照GDT的约定，第一个为NULL段。ucore采用的是平坦内存模型，所以代码段和数据段在内核中均只存在一个。
gdt:
    SEG_NULLASM                                     # null seg
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)           # code seg for bootloader and kernel
    SEG_ASM(STA_W, 0x0, 0xffffffff)                 # data seg for bootloader and kernel

gdtdesc:
    .word 0x17                                      # sizeof(gdt) - 1
    .long gdt                                       # address gdt