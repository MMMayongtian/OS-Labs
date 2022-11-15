#include <defs.h>
#include <x86.h>
#include <elf.h>

/* *********************************************************************
 * This a dirt simple boot loader, whose sole job is to boot
 * an ELF kernel image from the first IDE hard disk.
 *
 * DISK LAYOUT
 *  * This program(bootasm.S and bootmain.c) is the bootloader.
 *    It should be stored in the first sector of the disk.
 *         这个程序(bootasm.S and bootmain.c)是引导加载器程序，应该被保存在磁盘的第一个扇区
 *
 *  * The 2nd sector onward holds the kernel image.
 *         第二个扇区往后保存着内核映像
 *
 *  * The kernel image must be in ELF format.
 *         内核映像必须必须是ELF格式的
 *
 * BOOT UP STEPS
 *  * when the CPU boots it loads the BIOS into memory and executes it
 *
 *  * the BIOS intializes devices, sets of the interrupt routines, and
 *    reads the first sector of the boot device(e.g., hard-drive)
 *    into memory and jumps to it.
 *
 *  * Assuming this boot loader is stored in the first sector of the
 *    hard-drive, this code takes over...
 *
 *  * control starts in bootasm.S -- which sets up protected mode,
 *    and a stack so C code then run, then calls bootmain()
 *
 *  * bootmain() in this file takes over, reads in the kernel and jumps to it.
 * */
unsigned int    SECTSIZE  =      512 ;  // 一个磁盘扇区的大小为512字节
struct elfhdr * ELFHDR    =      ((struct elfhdr *)0x10000) ;     // scratch space

/* waitdisk - wait for disk ready */
static void
waitdisk(void) {
    // 读数据，当0x1f7不为忙状态时，可以读
    while ((inb(0x1F7) & 0xC0) != 0x40)
        /* do nothing */;
}

/* readsect - read a single sector at @secno into @dst */
// 读取一个单独的扇区(由@secno指定)到@dst指针指向的内存中
static void
readsect(void *dst, uint32_t secno) {
    // https://chyyuu.gitbooks.io/ucore_os_docs/content/lab1/lab1_3_2_3_dist_accessing.html
    // 实验指导书lab1中的对ide硬盘的访问中有详细介绍

    // wait for disk to be ready
    waitdisk();

    // 磁盘读取参数设置
    outb(0x1F2, 1);                         // count = 1
    outb(0x1F3, secno & 0xFF);
    outb(0x1F4, (secno >> 8) & 0xFF);
    outb(0x1F5, (secno >> 16) & 0xFF);
    outb(0x1F6, ((secno >> 24) & 0xF) | 0xE0);
    outb(0x1F7, 0x20);                      // cmd 0x20 - read sectors

    // wait for disk to be ready
    waitdisk();

    // read a sector
    insl(0x1F0, dst, SECTSIZE / 4);
}

/* *
 * readseg - read @count bytes at @offset from kernel into virtual address @va,
 * might copy more than asked.
 * */
static void
readseg(uintptr_t va, uint32_t count, uint32_t offset) {
    uintptr_t end_va = va + count;

    // round down to sector boundary
    va -= offset % SECTSIZE;

    // translate from bytes to sectors; kernel starts at sector 1
    // 计算出需要读取的磁盘扇区号，由于第1个扇区被bootloader占据，kernel内核从第二个扇区开始(下标为1)，所以扇区号需要增加1
    uint32_t secno = (offset / SECTSIZE) + 1;

    // If this is too slow, we could read lots of sectors at a time.
    // We'd write more to memory than asked, but it doesn't matter --
    // we load in increasing order.
    // 循环往复，通过va指针的自增，一个一个扇区的循环读取数据写入va指向的内存区域
    for (; va < end_va; va += SECTSIZE, secno ++) {
        readsect((void *)va, secno);
    }
}

/* bootmain - the entry of bootloader */
void
bootmain(void) {
    // read the 1st page off disk
    // 从硬盘中读取出内核文件ELF文件头数据，存入ELFHDR指针指向的内存区域 (大小为8个扇区)
    readseg((uintptr_t)ELFHDR, SECTSIZE * 8, 0);

    // is this a valid ELF? 校验读取出来的ELF文件头的魔数值是否正确
    if (ELFHDR->e_magic != ELF_MAGIC) {
        goto bad;
    }

    struct proghdr *ph, *eph;

    // load each program segment (ignores ph flags)
    ph = (struct proghdr *)((uintptr_t)ELFHDR + ELFHDR->e_phoff); // 根据elf文件头，获得程序段的起始
    eph = ph + ELFHDR->e_phnum; // 程序段起始指针(*ph)指针偏移程序段数目(ELFHDR->e_phnum) = 最后一段程序的头部
    for (; ph < eph; ph ++) {
        // 循环往复，将各个程序段的内容读取至指定的内存位置(ph->p_va)
        readseg(ph->p_va & 0xFFFFFF, ph->p_memsz, ph->p_offset);
    }

    // call the entry point from the ELF header
    // note: does not return
    // 通过函数指针的方式，跳转至ELFHDR->e_entry指定的程序初始执行入口(即内核入口)
    // 在makefile的配置中，ELFHDR->e_entry指向的是kern/init/init.c中的kern_init函数 (kernel.ld中的ENTRY(kern_init))
    ((void (*)(void))(ELFHDR->e_entry & 0xFFFFFF))();

bad:
    // 跳转至内核之后，不应该返回
    outw(0x8A00, 0x8A00);
    outw(0x8A00, 0x8E00);

    /* do nothing */
    while (1);
}