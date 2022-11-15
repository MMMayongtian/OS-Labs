
bin/kernel：     文件格式 elf32-i386


Disassembly of section .text:

c0100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
c0100000:	b8 00 a0 11 00       	mov    $0x11a000,%eax
    movl %eax, %cr3
c0100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
c0100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
c010000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
c0100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
c0100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
c0100016:	8d 05 1e 00 10 c0    	lea    0xc010001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
c010001c:	ff e0                	jmp    *%eax

c010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
c010001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
c0100020:	a3 00 a0 11 c0       	mov    %eax,0xc011a000

    # set ebp, esp
    movl $0x0, %ebp
c0100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
c010002a:	bc 00 90 11 c0       	mov    $0xc0119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
c010002f:	e8 02 00 00 00       	call   c0100036 <kern_init>

c0100034 <spin>:

# should never get here
spin:
    jmp spin
c0100034:	eb fe                	jmp    c0100034 <spin>

c0100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
c0100036:	55                   	push   %ebp
c0100037:	89 e5                	mov    %esp,%ebp
c0100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
c010003c:	b8 8c cf 11 c0       	mov    $0xc011cf8c,%eax
c0100041:	2d 00 c0 11 c0       	sub    $0xc011c000,%eax
c0100046:	89 44 24 08          	mov    %eax,0x8(%esp)
c010004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0100051:	00 
c0100052:	c7 04 24 00 c0 11 c0 	movl   $0xc011c000,(%esp)
c0100059:	e8 13 60 00 00       	call   c0106071 <memset>

    cons_init();                // init the console
c010005e:	e8 f6 15 00 00       	call   c0101659 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
c0100063:	c7 45 f4 00 62 10 c0 	movl   $0xc0106200,-0xc(%ebp)
    cprintf("%s\n\n", message);
c010006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010006d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100071:	c7 04 24 1c 62 10 c0 	movl   $0xc010621c,(%esp)
c0100078:	e8 d9 02 00 00       	call   c0100356 <cprintf>

    print_kerninfo();
c010007d:	e8 f7 07 00 00       	call   c0100879 <print_kerninfo>

    grade_backtrace();
c0100082:	e8 90 00 00 00       	call   c0100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
c0100087:	e8 5c 45 00 00       	call   c01045e8 <pmm_init>

    pic_init();                 // init interrupt controller
c010008c:	e8 49 17 00 00       	call   c01017da <pic_init>
    idt_init();                 // init interrupt descriptor table
c0100091:	e8 d0 18 00 00       	call   c0101966 <idt_init>

    clock_init();               // init clock interrupt
c0100096:	e8 1d 0d 00 00       	call   c0100db8 <clock_init>
    intr_enable();              // enable irq interrupt
c010009b:	e8 98 16 00 00       	call   c0101738 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
c01000a0:	eb fe                	jmp    c01000a0 <kern_init+0x6a>

c01000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
c01000a2:	55                   	push   %ebp
c01000a3:	89 e5                	mov    %esp,%ebp
c01000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
c01000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01000af:	00 
c01000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c01000b7:	00 
c01000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01000bf:	e8 0f 0c 00 00       	call   c0100cd3 <mon_backtrace>
}
c01000c4:	90                   	nop
c01000c5:	89 ec                	mov    %ebp,%esp
c01000c7:	5d                   	pop    %ebp
c01000c8:	c3                   	ret    

c01000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
c01000c9:	55                   	push   %ebp
c01000ca:	89 e5                	mov    %esp,%ebp
c01000cc:	83 ec 18             	sub    $0x18,%esp
c01000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
c01000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
c01000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
c01000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
c01000db:	8b 45 08             	mov    0x8(%ebp),%eax
c01000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c01000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
c01000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c01000ea:	89 04 24             	mov    %eax,(%esp)
c01000ed:	e8 b0 ff ff ff       	call   c01000a2 <grade_backtrace2>
}
c01000f2:	90                   	nop
c01000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c01000f6:	89 ec                	mov    %ebp,%esp
c01000f8:	5d                   	pop    %ebp
c01000f9:	c3                   	ret    

c01000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
c01000fa:	55                   	push   %ebp
c01000fb:	89 e5                	mov    %esp,%ebp
c01000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
c0100100:	8b 45 10             	mov    0x10(%ebp),%eax
c0100103:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100107:	8b 45 08             	mov    0x8(%ebp),%eax
c010010a:	89 04 24             	mov    %eax,(%esp)
c010010d:	e8 b7 ff ff ff       	call   c01000c9 <grade_backtrace1>
}
c0100112:	90                   	nop
c0100113:	89 ec                	mov    %ebp,%esp
c0100115:	5d                   	pop    %ebp
c0100116:	c3                   	ret    

c0100117 <grade_backtrace>:

void
grade_backtrace(void) {
c0100117:	55                   	push   %ebp
c0100118:	89 e5                	mov    %esp,%ebp
c010011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
c010011d:	b8 36 00 10 c0       	mov    $0xc0100036,%eax
c0100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
c0100129:	ff 
c010012a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100135:	e8 c0 ff ff ff       	call   c01000fa <grade_backtrace0>
}
c010013a:	90                   	nop
c010013b:	89 ec                	mov    %ebp,%esp
c010013d:	5d                   	pop    %ebp
c010013e:	c3                   	ret    

c010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
c010013f:	55                   	push   %ebp
c0100140:	89 e5                	mov    %esp,%ebp
c0100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
c0100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
c0100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
c010014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
c010014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
c0100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100155:	83 e0 03             	and    $0x3,%eax
c0100158:	89 c2                	mov    %eax,%edx
c010015a:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010015f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100163:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100167:	c7 04 24 21 62 10 c0 	movl   $0xc0106221,(%esp)
c010016e:	e8 e3 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
c0100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100177:	89 c2                	mov    %eax,%edx
c0100179:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010017e:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100182:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100186:	c7 04 24 2f 62 10 c0 	movl   $0xc010622f,(%esp)
c010018d:	e8 c4 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
c0100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
c0100196:	89 c2                	mov    %eax,%edx
c0100198:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c010019d:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001a5:	c7 04 24 3d 62 10 c0 	movl   $0xc010623d,(%esp)
c01001ac:	e8 a5 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
c01001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c01001b5:	89 c2                	mov    %eax,%edx
c01001b7:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001c4:	c7 04 24 4b 62 10 c0 	movl   $0xc010624b,(%esp)
c01001cb:	e8 86 01 00 00       	call   c0100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
c01001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
c01001d4:	89 c2                	mov    %eax,%edx
c01001d6:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001db:	89 54 24 08          	mov    %edx,0x8(%esp)
c01001df:	89 44 24 04          	mov    %eax,0x4(%esp)
c01001e3:	c7 04 24 59 62 10 c0 	movl   $0xc0106259,(%esp)
c01001ea:	e8 67 01 00 00       	call   c0100356 <cprintf>
    round ++;
c01001ef:	a1 00 c0 11 c0       	mov    0xc011c000,%eax
c01001f4:	40                   	inc    %eax
c01001f5:	a3 00 c0 11 c0       	mov    %eax,0xc011c000
}
c01001fa:	90                   	nop
c01001fb:	89 ec                	mov    %ebp,%esp
c01001fd:	5d                   	pop    %ebp
c01001fe:	c3                   	ret    

c01001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
c01001ff:	55                   	push   %ebp
c0100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
c0100202:	90                   	nop
c0100203:	5d                   	pop    %ebp
c0100204:	c3                   	ret    

c0100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
c0100205:	55                   	push   %ebp
c0100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
c0100208:	90                   	nop
c0100209:	5d                   	pop    %ebp
c010020a:	c3                   	ret    

c010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
c010020b:	55                   	push   %ebp
c010020c:	89 e5                	mov    %esp,%ebp
c010020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
c0100211:	e8 29 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
c0100216:	c7 04 24 68 62 10 c0 	movl   $0xc0106268,(%esp)
c010021d:	e8 34 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_user();
c0100222:	e8 d8 ff ff ff       	call   c01001ff <lab1_switch_to_user>
    lab1_print_cur_status();
c0100227:	e8 13 ff ff ff       	call   c010013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
c010022c:	c7 04 24 88 62 10 c0 	movl   $0xc0106288,(%esp)
c0100233:	e8 1e 01 00 00       	call   c0100356 <cprintf>
    lab1_switch_to_kernel();
c0100238:	e8 c8 ff ff ff       	call   c0100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
c010023d:	e8 fd fe ff ff       	call   c010013f <lab1_print_cur_status>
}
c0100242:	90                   	nop
c0100243:	89 ec                	mov    %ebp,%esp
c0100245:	5d                   	pop    %ebp
c0100246:	c3                   	ret    

c0100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
c0100247:	55                   	push   %ebp
c0100248:	89 e5                	mov    %esp,%ebp
c010024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
c010024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100251:	74 13                	je     c0100266 <readline+0x1f>
        cprintf("%s", prompt);
c0100253:	8b 45 08             	mov    0x8(%ebp),%eax
c0100256:	89 44 24 04          	mov    %eax,0x4(%esp)
c010025a:	c7 04 24 a7 62 10 c0 	movl   $0xc01062a7,(%esp)
c0100261:	e8 f0 00 00 00       	call   c0100356 <cprintf>
    }
    int i = 0, c;
c0100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
c010026d:	e8 73 01 00 00       	call   c01003e5 <getchar>
c0100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
c0100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100279:	79 07                	jns    c0100282 <readline+0x3b>
            return NULL;
c010027b:	b8 00 00 00 00       	mov    $0x0,%eax
c0100280:	eb 78                	jmp    c01002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
c0100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
c0100286:	7e 28                	jle    c01002b0 <readline+0x69>
c0100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
c010028f:	7f 1f                	jg     c01002b0 <readline+0x69>
            cputchar(c);
c0100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100294:	89 04 24             	mov    %eax,(%esp)
c0100297:	e8 e2 00 00 00       	call   c010037e <cputchar>
            buf[i ++] = c;
c010029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010029f:	8d 50 01             	lea    0x1(%eax),%edx
c01002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
c01002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01002a8:	88 90 20 c0 11 c0    	mov    %dl,-0x3fee3fe0(%eax)
c01002ae:	eb 45                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
c01002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
c01002b4:	75 16                	jne    c01002cc <readline+0x85>
c01002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01002ba:	7e 10                	jle    c01002cc <readline+0x85>
            cputchar(c);
c01002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002bf:	89 04 24             	mov    %eax,(%esp)
c01002c2:	e8 b7 00 00 00       	call   c010037e <cputchar>
            i --;
c01002c7:	ff 4d f4             	decl   -0xc(%ebp)
c01002ca:	eb 29                	jmp    c01002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
c01002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
c01002d0:	74 06                	je     c01002d8 <readline+0x91>
c01002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
c01002d6:	75 95                	jne    c010026d <readline+0x26>
            cputchar(c);
c01002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01002db:	89 04 24             	mov    %eax,(%esp)
c01002de:	e8 9b 00 00 00       	call   c010037e <cputchar>
            buf[i] = '\0';
c01002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01002e6:	05 20 c0 11 c0       	add    $0xc011c020,%eax
c01002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
c01002ee:	b8 20 c0 11 c0       	mov    $0xc011c020,%eax
c01002f3:	eb 05                	jmp    c01002fa <readline+0xb3>
        c = getchar();
c01002f5:	e9 73 ff ff ff       	jmp    c010026d <readline+0x26>
        }
    }
}
c01002fa:	89 ec                	mov    %ebp,%esp
c01002fc:	5d                   	pop    %ebp
c01002fd:	c3                   	ret    

c01002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
c01002fe:	55                   	push   %ebp
c01002ff:	89 e5                	mov    %esp,%ebp
c0100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100304:	8b 45 08             	mov    0x8(%ebp),%eax
c0100307:	89 04 24             	mov    %eax,(%esp)
c010030a:	e8 79 13 00 00       	call   c0101688 <cons_putc>
    (*cnt) ++;
c010030f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100312:	8b 00                	mov    (%eax),%eax
c0100314:	8d 50 01             	lea    0x1(%eax),%edx
c0100317:	8b 45 0c             	mov    0xc(%ebp),%eax
c010031a:	89 10                	mov    %edx,(%eax)
}
c010031c:	90                   	nop
c010031d:	89 ec                	mov    %ebp,%esp
c010031f:	5d                   	pop    %ebp
c0100320:	c3                   	ret    

c0100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
c0100321:	55                   	push   %ebp
c0100322:	89 e5                	mov    %esp,%ebp
c0100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c0100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
c010032e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0100335:	8b 45 08             	mov    0x8(%ebp),%eax
c0100338:	89 44 24 08          	mov    %eax,0x8(%esp)
c010033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
c010033f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100343:	c7 04 24 fe 02 10 c0 	movl   $0xc01002fe,(%esp)
c010034a:	e8 4d 55 00 00       	call   c010589c <vprintfmt>
    return cnt;
c010034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100352:	89 ec                	mov    %ebp,%esp
c0100354:	5d                   	pop    %ebp
c0100355:	c3                   	ret    

c0100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
c0100356:	55                   	push   %ebp
c0100357:	89 e5                	mov    %esp,%ebp
c0100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c010035c:	8d 45 0c             	lea    0xc(%ebp),%eax
c010035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
c0100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100365:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100369:	8b 45 08             	mov    0x8(%ebp),%eax
c010036c:	89 04 24             	mov    %eax,(%esp)
c010036f:	e8 ad ff ff ff       	call   c0100321 <vcprintf>
c0100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c010037a:	89 ec                	mov    %ebp,%esp
c010037c:	5d                   	pop    %ebp
c010037d:	c3                   	ret    

c010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
c010037e:	55                   	push   %ebp
c010037f:	89 e5                	mov    %esp,%ebp
c0100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
c0100384:	8b 45 08             	mov    0x8(%ebp),%eax
c0100387:	89 04 24             	mov    %eax,(%esp)
c010038a:	e8 f9 12 00 00       	call   c0101688 <cons_putc>
}
c010038f:	90                   	nop
c0100390:	89 ec                	mov    %ebp,%esp
c0100392:	5d                   	pop    %ebp
c0100393:	c3                   	ret    

c0100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
c0100394:	55                   	push   %ebp
c0100395:	89 e5                	mov    %esp,%ebp
c0100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
c010039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
c01003a1:	eb 13                	jmp    c01003b6 <cputs+0x22>
        cputch(c, &cnt);
c01003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c01003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
c01003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
c01003ae:	89 04 24             	mov    %eax,(%esp)
c01003b1:	e8 48 ff ff ff       	call   c01002fe <cputch>
    while ((c = *str ++) != '\0') {
c01003b6:	8b 45 08             	mov    0x8(%ebp),%eax
c01003b9:	8d 50 01             	lea    0x1(%eax),%edx
c01003bc:	89 55 08             	mov    %edx,0x8(%ebp)
c01003bf:	0f b6 00             	movzbl (%eax),%eax
c01003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
c01003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
c01003c9:	75 d8                	jne    c01003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
c01003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
c01003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
c01003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
c01003d9:	e8 20 ff ff ff       	call   c01002fe <cputch>
    return cnt;
c01003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01003e1:	89 ec                	mov    %ebp,%esp
c01003e3:	5d                   	pop    %ebp
c01003e4:	c3                   	ret    

c01003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
c01003e5:	55                   	push   %ebp
c01003e6:	89 e5                	mov    %esp,%ebp
c01003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
c01003eb:	90                   	nop
c01003ec:	e8 d6 12 00 00       	call   c01016c7 <cons_getc>
c01003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01003f8:	74 f2                	je     c01003ec <getchar+0x7>
        /* do nothing */;
    return c;
c01003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c01003fd:	89 ec                	mov    %ebp,%esp
c01003ff:	5d                   	pop    %ebp
c0100400:	c3                   	ret    

c0100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
c0100401:	55                   	push   %ebp
c0100402:	89 e5                	mov    %esp,%ebp
c0100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
c0100407:	8b 45 0c             	mov    0xc(%ebp),%eax
c010040a:	8b 00                	mov    (%eax),%eax
c010040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
c010040f:	8b 45 10             	mov    0x10(%ebp),%eax
c0100412:	8b 00                	mov    (%eax),%eax
c0100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
c0100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
c010041e:	e9 ca 00 00 00       	jmp    c01004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
c0100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0100429:	01 d0                	add    %edx,%eax
c010042b:	89 c2                	mov    %eax,%edx
c010042d:	c1 ea 1f             	shr    $0x1f,%edx
c0100430:	01 d0                	add    %edx,%eax
c0100432:	d1 f8                	sar    %eax
c0100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
c010043d:	eb 03                	jmp    c0100442 <stab_binsearch+0x41>
            m --;
c010043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
c0100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c0100448:	7c 1f                	jl     c0100469 <stab_binsearch+0x68>
c010044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010044d:	89 d0                	mov    %edx,%eax
c010044f:	01 c0                	add    %eax,%eax
c0100451:	01 d0                	add    %edx,%eax
c0100453:	c1 e0 02             	shl    $0x2,%eax
c0100456:	89 c2                	mov    %eax,%edx
c0100458:	8b 45 08             	mov    0x8(%ebp),%eax
c010045b:	01 d0                	add    %edx,%eax
c010045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100461:	0f b6 c0             	movzbl %al,%eax
c0100464:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100467:	75 d6                	jne    c010043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
c0100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
c010046f:	7d 09                	jge    c010047a <stab_binsearch+0x79>
            l = true_m + 1;
c0100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100474:	40                   	inc    %eax
c0100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
c0100478:	eb 73                	jmp    c01004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
c010047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
c0100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0100484:	89 d0                	mov    %edx,%eax
c0100486:	01 c0                	add    %eax,%eax
c0100488:	01 d0                	add    %edx,%eax
c010048a:	c1 e0 02             	shl    $0x2,%eax
c010048d:	89 c2                	mov    %eax,%edx
c010048f:	8b 45 08             	mov    0x8(%ebp),%eax
c0100492:	01 d0                	add    %edx,%eax
c0100494:	8b 40 08             	mov    0x8(%eax),%eax
c0100497:	39 45 18             	cmp    %eax,0x18(%ebp)
c010049a:	76 11                	jbe    c01004ad <stab_binsearch+0xac>
            *region_left = m;
c010049c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
c01004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01004a7:	40                   	inc    %eax
c01004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
c01004ab:	eb 40                	jmp    c01004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
c01004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004b0:	89 d0                	mov    %edx,%eax
c01004b2:	01 c0                	add    %eax,%eax
c01004b4:	01 d0                	add    %edx,%eax
c01004b6:	c1 e0 02             	shl    $0x2,%eax
c01004b9:	89 c2                	mov    %eax,%edx
c01004bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01004be:	01 d0                	add    %edx,%eax
c01004c0:	8b 40 08             	mov    0x8(%eax),%eax
c01004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
c01004c6:	73 14                	jae    c01004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
c01004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
c01004ce:	8b 45 10             	mov    0x10(%ebp),%eax
c01004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
c01004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004d6:	48                   	dec    %eax
c01004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
c01004da:	eb 11                	jmp    c01004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
c01004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
c01004e2:	89 10                	mov    %edx,(%eax)
            l = m;
c01004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
c01004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
c01004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
c01004f3:	0f 8e 2a ff ff ff    	jle    c0100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
c01004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01004fd:	75 0f                	jne    c010050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
c01004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100502:	8b 00                	mov    (%eax),%eax
c0100504:	8d 50 ff             	lea    -0x1(%eax),%edx
c0100507:	8b 45 10             	mov    0x10(%ebp),%eax
c010050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
c010050c:	eb 3e                	jmp    c010054c <stab_binsearch+0x14b>
        l = *region_right;
c010050e:	8b 45 10             	mov    0x10(%ebp),%eax
c0100511:	8b 00                	mov    (%eax),%eax
c0100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
c0100516:	eb 03                	jmp    c010051b <stab_binsearch+0x11a>
c0100518:	ff 4d fc             	decl   -0x4(%ebp)
c010051b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010051e:	8b 00                	mov    (%eax),%eax
c0100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
c0100523:	7e 1f                	jle    c0100544 <stab_binsearch+0x143>
c0100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0100528:	89 d0                	mov    %edx,%eax
c010052a:	01 c0                	add    %eax,%eax
c010052c:	01 d0                	add    %edx,%eax
c010052e:	c1 e0 02             	shl    $0x2,%eax
c0100531:	89 c2                	mov    %eax,%edx
c0100533:	8b 45 08             	mov    0x8(%ebp),%eax
c0100536:	01 d0                	add    %edx,%eax
c0100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010053c:	0f b6 c0             	movzbl %al,%eax
c010053f:	39 45 14             	cmp    %eax,0x14(%ebp)
c0100542:	75 d4                	jne    c0100518 <stab_binsearch+0x117>
        *region_left = l;
c0100544:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
c010054a:	89 10                	mov    %edx,(%eax)
}
c010054c:	90                   	nop
c010054d:	89 ec                	mov    %ebp,%esp
c010054f:	5d                   	pop    %ebp
c0100550:	c3                   	ret    

c0100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
c0100551:	55                   	push   %ebp
c0100552:	89 e5                	mov    %esp,%ebp
c0100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
c0100557:	8b 45 0c             	mov    0xc(%ebp),%eax
c010055a:	c7 00 ac 62 10 c0    	movl   $0xc01062ac,(%eax)
    info->eip_line = 0;
c0100560:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
c010056a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010056d:	c7 40 08 ac 62 10 c0 	movl   $0xc01062ac,0x8(%eax)
    info->eip_fn_namelen = 9;
c0100574:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
c010057e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100581:	8b 55 08             	mov    0x8(%ebp),%edx
c0100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
c0100587:	8b 45 0c             	mov    0xc(%ebp),%eax
c010058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
c0100591:	c7 45 f4 90 75 10 c0 	movl   $0xc0107590,-0xc(%ebp)
    stab_end = __STAB_END__;
c0100598:	c7 45 f0 f4 2e 11 c0 	movl   $0xc0112ef4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
c010059f:	c7 45 ec f5 2e 11 c0 	movl   $0xc0112ef5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
c01005a6:	c7 45 e8 b0 64 11 c0 	movl   $0xc01164b0,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
c01005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01005b3:	76 0b                	jbe    c01005c0 <debuginfo_eip+0x6f>
c01005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01005b8:	48                   	dec    %eax
c01005b9:	0f b6 00             	movzbl (%eax),%eax
c01005bc:	84 c0                	test   %al,%al
c01005be:	74 0a                	je     c01005ca <debuginfo_eip+0x79>
        return -1;
c01005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01005c5:	e9 ab 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
c01005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
c01005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
c01005d7:	c1 f8 02             	sar    $0x2,%eax
c01005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
c01005e0:	48                   	dec    %eax
c01005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
c01005e4:	8b 45 08             	mov    0x8(%ebp),%eax
c01005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
c01005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
c01005f2:	00 
c01005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
c01005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
c01005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100604:	89 04 24             	mov    %eax,(%esp)
c0100607:	e8 f5 fd ff ff       	call   c0100401 <stab_binsearch>
    if (lfile == 0)
c010060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010060f:	85 c0                	test   %eax,%eax
c0100611:	75 0a                	jne    c010061d <debuginfo_eip+0xcc>
        return -1;
c0100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100618:	e9 58 02 00 00       	jmp    c0100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
c010061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
c0100629:	8b 45 08             	mov    0x8(%ebp),%eax
c010062c:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
c0100637:	00 
c0100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
c010063b:	89 44 24 08          	mov    %eax,0x8(%esp)
c010063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100642:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100649:	89 04 24             	mov    %eax,(%esp)
c010064c:	e8 b0 fd ff ff       	call   c0100401 <stab_binsearch>

    if (lfun <= rfun) {
c0100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100657:	39 c2                	cmp    %eax,%edx
c0100659:	7f 78                	jg     c01006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
c010065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010065e:	89 c2                	mov    %eax,%edx
c0100660:	89 d0                	mov    %edx,%eax
c0100662:	01 c0                	add    %eax,%eax
c0100664:	01 d0                	add    %edx,%eax
c0100666:	c1 e0 02             	shl    $0x2,%eax
c0100669:	89 c2                	mov    %eax,%edx
c010066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010066e:	01 d0                	add    %edx,%eax
c0100670:	8b 10                	mov    (%eax),%edx
c0100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
c0100678:	39 c2                	cmp    %eax,%edx
c010067a:	73 22                	jae    c010069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
c010067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010067f:	89 c2                	mov    %eax,%edx
c0100681:	89 d0                	mov    %edx,%eax
c0100683:	01 c0                	add    %eax,%eax
c0100685:	01 d0                	add    %edx,%eax
c0100687:	c1 e0 02             	shl    $0x2,%eax
c010068a:	89 c2                	mov    %eax,%edx
c010068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010068f:	01 d0                	add    %edx,%eax
c0100691:	8b 10                	mov    (%eax),%edx
c0100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100696:	01 c2                	add    %eax,%edx
c0100698:	8b 45 0c             	mov    0xc(%ebp),%eax
c010069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
c010069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006a1:	89 c2                	mov    %eax,%edx
c01006a3:	89 d0                	mov    %edx,%eax
c01006a5:	01 c0                	add    %eax,%eax
c01006a7:	01 d0                	add    %edx,%eax
c01006a9:	c1 e0 02             	shl    $0x2,%eax
c01006ac:	89 c2                	mov    %eax,%edx
c01006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01006b1:	01 d0                	add    %edx,%eax
c01006b3:	8b 50 08             	mov    0x8(%eax),%edx
c01006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
c01006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006bf:	8b 40 10             	mov    0x10(%eax),%eax
c01006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
c01006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
c01006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01006d1:	eb 15                	jmp    c01006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
c01006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006d6:	8b 55 08             	mov    0x8(%ebp),%edx
c01006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
c01006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
c01006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
c01006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01006eb:	8b 40 08             	mov    0x8(%eax),%eax
c01006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
c01006f5:	00 
c01006f6:	89 04 24             	mov    %eax,(%esp)
c01006f9:	e8 eb 57 00 00       	call   c0105ee9 <strfind>
c01006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
c0100701:	8b 4a 08             	mov    0x8(%edx),%ecx
c0100704:	29 c8                	sub    %ecx,%eax
c0100706:	89 c2                	mov    %eax,%edx
c0100708:	8b 45 0c             	mov    0xc(%ebp),%eax
c010070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
c010070e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100711:	89 44 24 10          	mov    %eax,0x10(%esp)
c0100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
c010071c:	00 
c010071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
c0100720:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
c0100727:	89 44 24 04          	mov    %eax,0x4(%esp)
c010072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010072e:	89 04 24             	mov    %eax,(%esp)
c0100731:	e8 cb fc ff ff       	call   c0100401 <stab_binsearch>
    if (lline <= rline) {
c0100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010073c:	39 c2                	cmp    %eax,%edx
c010073e:	7f 23                	jg     c0100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
c0100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0100743:	89 c2                	mov    %eax,%edx
c0100745:	89 d0                	mov    %edx,%eax
c0100747:	01 c0                	add    %eax,%eax
c0100749:	01 d0                	add    %edx,%eax
c010074b:	c1 e0 02             	shl    $0x2,%eax
c010074e:	89 c2                	mov    %eax,%edx
c0100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100753:	01 d0                	add    %edx,%eax
c0100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
c0100759:	89 c2                	mov    %eax,%edx
c010075b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
c0100761:	eb 11                	jmp    c0100774 <debuginfo_eip+0x223>
        return -1;
c0100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c0100768:	e9 08 01 00 00       	jmp    c0100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
c010076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100770:	48                   	dec    %eax
c0100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
c0100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010077a:	39 c2                	cmp    %eax,%edx
c010077c:	7c 56                	jl     c01007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
c010077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100781:	89 c2                	mov    %eax,%edx
c0100783:	89 d0                	mov    %edx,%eax
c0100785:	01 c0                	add    %eax,%eax
c0100787:	01 d0                	add    %edx,%eax
c0100789:	c1 e0 02             	shl    $0x2,%eax
c010078c:	89 c2                	mov    %eax,%edx
c010078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100791:	01 d0                	add    %edx,%eax
c0100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c0100797:	3c 84                	cmp    $0x84,%al
c0100799:	74 39                	je     c01007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
c010079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c010079e:	89 c2                	mov    %eax,%edx
c01007a0:	89 d0                	mov    %edx,%eax
c01007a2:	01 c0                	add    %eax,%eax
c01007a4:	01 d0                	add    %edx,%eax
c01007a6:	c1 e0 02             	shl    $0x2,%eax
c01007a9:	89 c2                	mov    %eax,%edx
c01007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007ae:	01 d0                	add    %edx,%eax
c01007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c01007b4:	3c 64                	cmp    $0x64,%al
c01007b6:	75 b5                	jne    c010076d <debuginfo_eip+0x21c>
c01007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007bb:	89 c2                	mov    %eax,%edx
c01007bd:	89 d0                	mov    %edx,%eax
c01007bf:	01 c0                	add    %eax,%eax
c01007c1:	01 d0                	add    %edx,%eax
c01007c3:	c1 e0 02             	shl    $0x2,%eax
c01007c6:	89 c2                	mov    %eax,%edx
c01007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007cb:	01 d0                	add    %edx,%eax
c01007cd:	8b 40 08             	mov    0x8(%eax),%eax
c01007d0:	85 c0                	test   %eax,%eax
c01007d2:	74 99                	je     c010076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
c01007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01007da:	39 c2                	cmp    %eax,%edx
c01007dc:	7c 42                	jl     c0100820 <debuginfo_eip+0x2cf>
c01007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01007e1:	89 c2                	mov    %eax,%edx
c01007e3:	89 d0                	mov    %edx,%eax
c01007e5:	01 c0                	add    %eax,%eax
c01007e7:	01 d0                	add    %edx,%eax
c01007e9:	c1 e0 02             	shl    $0x2,%eax
c01007ec:	89 c2                	mov    %eax,%edx
c01007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01007f1:	01 d0                	add    %edx,%eax
c01007f3:	8b 10                	mov    (%eax),%edx
c01007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
c01007fb:	39 c2                	cmp    %eax,%edx
c01007fd:	73 21                	jae    c0100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
c01007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100802:	89 c2                	mov    %eax,%edx
c0100804:	89 d0                	mov    %edx,%eax
c0100806:	01 c0                	add    %eax,%eax
c0100808:	01 d0                	add    %edx,%eax
c010080a:	c1 e0 02             	shl    $0x2,%eax
c010080d:	89 c2                	mov    %eax,%edx
c010080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100812:	01 d0                	add    %edx,%eax
c0100814:	8b 10                	mov    (%eax),%edx
c0100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0100819:	01 c2                	add    %eax,%edx
c010081b:	8b 45 0c             	mov    0xc(%ebp),%eax
c010081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
c0100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0100826:	39 c2                	cmp    %eax,%edx
c0100828:	7d 46                	jge    c0100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
c010082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010082d:	40                   	inc    %eax
c010082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
c0100831:	eb 16                	jmp    c0100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
c0100833:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100836:	8b 40 14             	mov    0x14(%eax),%eax
c0100839:	8d 50 01             	lea    0x1(%eax),%edx
c010083c:	8b 45 0c             	mov    0xc(%ebp),%eax
c010083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
c0100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100845:	40                   	inc    %eax
c0100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
c0100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
c010084f:	39 c2                	cmp    %eax,%edx
c0100851:	7d 1d                	jge    c0100870 <debuginfo_eip+0x31f>
c0100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0100856:	89 c2                	mov    %eax,%edx
c0100858:	89 d0                	mov    %edx,%eax
c010085a:	01 c0                	add    %eax,%eax
c010085c:	01 d0                	add    %edx,%eax
c010085e:	c1 e0 02             	shl    $0x2,%eax
c0100861:	89 c2                	mov    %eax,%edx
c0100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100866:	01 d0                	add    %edx,%eax
c0100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
c010086c:	3c a0                	cmp    $0xa0,%al
c010086e:	74 c3                	je     c0100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
c0100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100875:	89 ec                	mov    %ebp,%esp
c0100877:	5d                   	pop    %ebp
c0100878:	c3                   	ret    

c0100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
c0100879:	55                   	push   %ebp
c010087a:	89 e5                	mov    %esp,%ebp
c010087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
c010087f:	c7 04 24 b6 62 10 c0 	movl   $0xc01062b6,(%esp)
c0100886:	e8 cb fa ff ff       	call   c0100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
c010088b:	c7 44 24 04 36 00 10 	movl   $0xc0100036,0x4(%esp)
c0100892:	c0 
c0100893:	c7 04 24 cf 62 10 c0 	movl   $0xc01062cf,(%esp)
c010089a:	e8 b7 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
c010089f:	c7 44 24 04 fd 61 10 	movl   $0xc01061fd,0x4(%esp)
c01008a6:	c0 
c01008a7:	c7 04 24 e7 62 10 c0 	movl   $0xc01062e7,(%esp)
c01008ae:	e8 a3 fa ff ff       	call   c0100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
c01008b3:	c7 44 24 04 00 c0 11 	movl   $0xc011c000,0x4(%esp)
c01008ba:	c0 
c01008bb:	c7 04 24 ff 62 10 c0 	movl   $0xc01062ff,(%esp)
c01008c2:	e8 8f fa ff ff       	call   c0100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
c01008c7:	c7 44 24 04 8c cf 11 	movl   $0xc011cf8c,0x4(%esp)
c01008ce:	c0 
c01008cf:	c7 04 24 17 63 10 c0 	movl   $0xc0106317,(%esp)
c01008d6:	e8 7b fa ff ff       	call   c0100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
c01008db:	b8 8c cf 11 c0       	mov    $0xc011cf8c,%eax
c01008e0:	2d 36 00 10 c0       	sub    $0xc0100036,%eax
c01008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
c01008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
c01008f0:	85 c0                	test   %eax,%eax
c01008f2:	0f 48 c2             	cmovs  %edx,%eax
c01008f5:	c1 f8 0a             	sar    $0xa,%eax
c01008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
c01008fc:	c7 04 24 30 63 10 c0 	movl   $0xc0106330,(%esp)
c0100903:	e8 4e fa ff ff       	call   c0100356 <cprintf>
}
c0100908:	90                   	nop
c0100909:	89 ec                	mov    %ebp,%esp
c010090b:	5d                   	pop    %ebp
c010090c:	c3                   	ret    

c010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
c010090d:	55                   	push   %ebp
c010090e:	89 e5                	mov    %esp,%ebp
c0100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
c0100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
c0100919:	89 44 24 04          	mov    %eax,0x4(%esp)
c010091d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100920:	89 04 24             	mov    %eax,(%esp)
c0100923:	e8 29 fc ff ff       	call   c0100551 <debuginfo_eip>
c0100928:	85 c0                	test   %eax,%eax
c010092a:	74 15                	je     c0100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
c010092c:	8b 45 08             	mov    0x8(%ebp),%eax
c010092f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100933:	c7 04 24 5a 63 10 c0 	movl   $0xc010635a,(%esp)
c010093a:	e8 17 fa ff ff       	call   c0100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
c010093f:	eb 6c                	jmp    c01009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100948:	eb 1b                	jmp    c0100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
c010094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c010094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100950:	01 d0                	add    %edx,%eax
c0100952:	0f b6 10             	movzbl (%eax),%edx
c0100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c010095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010095e:	01 c8                	add    %ecx,%eax
c0100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
c0100962:	ff 45 f4             	incl   -0xc(%ebp)
c0100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c010096b:	7c dd                	jl     c010094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
c010096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
c0100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100976:	01 d0                	add    %edx,%eax
c0100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
c010097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
c010097e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100981:	29 d0                	sub    %edx,%eax
c0100983:	89 c1                	mov    %eax,%ecx
c0100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
c010098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
c0100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100999:	89 54 24 08          	mov    %edx,0x8(%esp)
c010099d:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009a1:	c7 04 24 76 63 10 c0 	movl   $0xc0106376,(%esp)
c01009a8:	e8 a9 f9 ff ff       	call   c0100356 <cprintf>
}
c01009ad:	90                   	nop
c01009ae:	89 ec                	mov    %ebp,%esp
c01009b0:	5d                   	pop    %ebp
c01009b1:	c3                   	ret    

c01009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
c01009b2:	55                   	push   %ebp
c01009b3:	89 e5                	mov    %esp,%ebp
c01009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
c01009b8:	8b 45 04             	mov    0x4(%ebp),%eax
c01009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
c01009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c01009c1:	89 ec                	mov    %ebp,%esp
c01009c3:	5d                   	pop    %ebp
c01009c4:	c3                   	ret    

c01009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
c01009c5:	55                   	push   %ebp
c01009c6:	89 e5                	mov    %esp,%ebp
c01009c8:	83 ec 48             	sub    $0x48,%esp
c01009cb:	89 5d fc             	mov    %ebx,-0x4(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
c01009ce:	89 e8                	mov    %ebp,%eax
c01009d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
c01009d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
 
    uint32_t ebp=read_ebp();
c01009d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip=read_eip();
c01009d9:	e8 d4 ff ff ff       	call   c01009b2 <read_eip>
c01009de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c01009e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c01009e8:	e9 8a 00 00 00       	jmp    c0100a77 <print_stackframe+0xb2>
          cprintf("ebp:0x%08x   eip:0x%08x ",ebp,eip);
c01009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01009f0:	89 44 24 08          	mov    %eax,0x8(%esp)
c01009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
c01009fb:	c7 04 24 88 63 10 c0 	movl   $0xc0106388,(%esp)
c0100a02:	e8 4f f9 ff ff       	call   c0100356 <cprintf>
          uint32_t *tmp=(uint32_t *)ebp+2;
c0100a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a0a:	83 c0 08             	add    $0x8,%eax
c0100a0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
          cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x",*(tmp+0),*(tmp+1),*(tmp+2),*(tmp+3));
c0100a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a13:	83 c0 0c             	add    $0xc,%eax
c0100a16:	8b 18                	mov    (%eax),%ebx
c0100a18:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a1b:	83 c0 08             	add    $0x8,%eax
c0100a1e:	8b 08                	mov    (%eax),%ecx
c0100a20:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a23:	83 c0 04             	add    $0x4,%eax
c0100a26:	8b 10                	mov    (%eax),%edx
c0100a28:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0100a2b:	8b 00                	mov    (%eax),%eax
c0100a2d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
c0100a31:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0100a35:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100a3d:	c7 04 24 a4 63 10 c0 	movl   $0xc01063a4,(%esp)
c0100a44:	e8 0d f9 ff ff       	call   c0100356 <cprintf>
          cprintf("\n");
c0100a49:	c7 04 24 c5 63 10 c0 	movl   $0xc01063c5,(%esp)
c0100a50:	e8 01 f9 ff ff       	call   c0100356 <cprintf>
          print_debuginfo(eip-1);
c0100a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0100a58:	48                   	dec    %eax
c0100a59:	89 04 24             	mov    %eax,(%esp)
c0100a5c:	e8 ac fe ff ff       	call   c010090d <print_debuginfo>
          eip=((uint32_t *)ebp)[1];
c0100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a64:	83 c0 04             	add    $0x4,%eax
c0100a67:	8b 00                	mov    (%eax),%eax
c0100a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
          ebp=((uint32_t *)ebp)[0];
c0100a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100a6f:	8b 00                	mov    (%eax),%eax
c0100a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
c0100a74:	ff 45 ec             	incl   -0x14(%ebp)
c0100a77:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
c0100a7b:	7f 0a                	jg     c0100a87 <print_stackframe+0xc2>
c0100a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100a81:	0f 85 66 ff ff ff    	jne    c01009ed <print_stackframe+0x28>
    }

}
c0100a87:	90                   	nop
c0100a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100a8b:	89 ec                	mov    %ebp,%esp
c0100a8d:	5d                   	pop    %ebp
c0100a8e:	c3                   	ret    

c0100a8f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
c0100a8f:	55                   	push   %ebp
c0100a90:	89 e5                	mov    %esp,%ebp
c0100a92:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
c0100a95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100a9c:	eb 0c                	jmp    c0100aaa <parse+0x1b>
            *buf ++ = '\0';
c0100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aa1:	8d 50 01             	lea    0x1(%eax),%edx
c0100aa4:	89 55 08             	mov    %edx,0x8(%ebp)
c0100aa7:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
c0100aad:	0f b6 00             	movzbl (%eax),%eax
c0100ab0:	84 c0                	test   %al,%al
c0100ab2:	74 1d                	je     c0100ad1 <parse+0x42>
c0100ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ab7:	0f b6 00             	movzbl (%eax),%eax
c0100aba:	0f be c0             	movsbl %al,%eax
c0100abd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100ac1:	c7 04 24 48 64 10 c0 	movl   $0xc0106448,(%esp)
c0100ac8:	e8 e8 53 00 00       	call   c0105eb5 <strchr>
c0100acd:	85 c0                	test   %eax,%eax
c0100acf:	75 cd                	jne    c0100a9e <parse+0xf>
        }
        if (*buf == '\0') {
c0100ad1:	8b 45 08             	mov    0x8(%ebp),%eax
c0100ad4:	0f b6 00             	movzbl (%eax),%eax
c0100ad7:	84 c0                	test   %al,%al
c0100ad9:	74 65                	je     c0100b40 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
c0100adb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
c0100adf:	75 14                	jne    c0100af5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
c0100ae1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
c0100ae8:	00 
c0100ae9:	c7 04 24 4d 64 10 c0 	movl   $0xc010644d,(%esp)
c0100af0:	e8 61 f8 ff ff       	call   c0100356 <cprintf>
        }
        argv[argc ++] = buf;
c0100af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100af8:	8d 50 01             	lea    0x1(%eax),%edx
c0100afb:	89 55 f4             	mov    %edx,-0xc(%ebp)
c0100afe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0100b05:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100b08:	01 c2                	add    %eax,%edx
c0100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b0d:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b0f:	eb 03                	jmp    c0100b14 <parse+0x85>
            buf ++;
c0100b11:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
c0100b14:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b17:	0f b6 00             	movzbl (%eax),%eax
c0100b1a:	84 c0                	test   %al,%al
c0100b1c:	74 8c                	je     c0100aaa <parse+0x1b>
c0100b1e:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b21:	0f b6 00             	movzbl (%eax),%eax
c0100b24:	0f be c0             	movsbl %al,%eax
c0100b27:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b2b:	c7 04 24 48 64 10 c0 	movl   $0xc0106448,(%esp)
c0100b32:	e8 7e 53 00 00       	call   c0105eb5 <strchr>
c0100b37:	85 c0                	test   %eax,%eax
c0100b39:	74 d6                	je     c0100b11 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
c0100b3b:	e9 6a ff ff ff       	jmp    c0100aaa <parse+0x1b>
            break;
c0100b40:	90                   	nop
        }
    }
    return argc;
c0100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0100b44:	89 ec                	mov    %ebp,%esp
c0100b46:	5d                   	pop    %ebp
c0100b47:	c3                   	ret    

c0100b48 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
c0100b48:	55                   	push   %ebp
c0100b49:	89 e5                	mov    %esp,%ebp
c0100b4b:	83 ec 68             	sub    $0x68,%esp
c0100b4e:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
c0100b51:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100b58:	8b 45 08             	mov    0x8(%ebp),%eax
c0100b5b:	89 04 24             	mov    %eax,(%esp)
c0100b5e:	e8 2c ff ff ff       	call   c0100a8f <parse>
c0100b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
c0100b66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0100b6a:	75 0a                	jne    c0100b76 <runcmd+0x2e>
        return 0;
c0100b6c:	b8 00 00 00 00       	mov    $0x0,%eax
c0100b71:	e9 83 00 00 00       	jmp    c0100bf9 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100b7d:	eb 5a                	jmp    c0100bd9 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
c0100b7f:	8b 55 b0             	mov    -0x50(%ebp),%edx
c0100b82:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100b85:	89 c8                	mov    %ecx,%eax
c0100b87:	01 c0                	add    %eax,%eax
c0100b89:	01 c8                	add    %ecx,%eax
c0100b8b:	c1 e0 02             	shl    $0x2,%eax
c0100b8e:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100b93:	8b 00                	mov    (%eax),%eax
c0100b95:	89 54 24 04          	mov    %edx,0x4(%esp)
c0100b99:	89 04 24             	mov    %eax,(%esp)
c0100b9c:	e8 78 52 00 00       	call   c0105e19 <strcmp>
c0100ba1:	85 c0                	test   %eax,%eax
c0100ba3:	75 31                	jne    c0100bd6 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
c0100ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100ba8:	89 d0                	mov    %edx,%eax
c0100baa:	01 c0                	add    %eax,%eax
c0100bac:	01 d0                	add    %edx,%eax
c0100bae:	c1 e0 02             	shl    $0x2,%eax
c0100bb1:	05 08 90 11 c0       	add    $0xc0119008,%eax
c0100bb6:	8b 10                	mov    (%eax),%edx
c0100bb8:	8d 45 b0             	lea    -0x50(%ebp),%eax
c0100bbb:	83 c0 04             	add    $0x4,%eax
c0100bbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0100bc1:	8d 59 ff             	lea    -0x1(%ecx),%ebx
c0100bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
c0100bc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0100bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100bcf:	89 1c 24             	mov    %ebx,(%esp)
c0100bd2:	ff d2                	call   *%edx
c0100bd4:	eb 23                	jmp    c0100bf9 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100bd6:	ff 45 f4             	incl   -0xc(%ebp)
c0100bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100bdc:	83 f8 02             	cmp    $0x2,%eax
c0100bdf:	76 9e                	jbe    c0100b7f <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
c0100be1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0100be4:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100be8:	c7 04 24 6b 64 10 c0 	movl   $0xc010646b,(%esp)
c0100bef:	e8 62 f7 ff ff       	call   c0100356 <cprintf>
    return 0;
c0100bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0100bfc:	89 ec                	mov    %ebp,%esp
c0100bfe:	5d                   	pop    %ebp
c0100bff:	c3                   	ret    

c0100c00 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
c0100c00:	55                   	push   %ebp
c0100c01:	89 e5                	mov    %esp,%ebp
c0100c03:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
c0100c06:	c7 04 24 84 64 10 c0 	movl   $0xc0106484,(%esp)
c0100c0d:	e8 44 f7 ff ff       	call   c0100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
c0100c12:	c7 04 24 ac 64 10 c0 	movl   $0xc01064ac,(%esp)
c0100c19:	e8 38 f7 ff ff       	call   c0100356 <cprintf>

    if (tf != NULL) {
c0100c1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100c22:	74 0b                	je     c0100c2f <kmonitor+0x2f>
        print_trapframe(tf);
c0100c24:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c27:	89 04 24             	mov    %eax,(%esp)
c0100c2a:	e8 f2 0e 00 00       	call   c0101b21 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
c0100c2f:	c7 04 24 d1 64 10 c0 	movl   $0xc01064d1,(%esp)
c0100c36:	e8 0c f6 ff ff       	call   c0100247 <readline>
c0100c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0100c3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0100c42:	74 eb                	je     c0100c2f <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
c0100c44:	8b 45 08             	mov    0x8(%ebp),%eax
c0100c47:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100c4e:	89 04 24             	mov    %eax,(%esp)
c0100c51:	e8 f2 fe ff ff       	call   c0100b48 <runcmd>
c0100c56:	85 c0                	test   %eax,%eax
c0100c58:	78 02                	js     c0100c5c <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
c0100c5a:	eb d3                	jmp    c0100c2f <kmonitor+0x2f>
                break;
c0100c5c:	90                   	nop
            }
        }
    }
}
c0100c5d:	90                   	nop
c0100c5e:	89 ec                	mov    %ebp,%esp
c0100c60:	5d                   	pop    %ebp
c0100c61:	c3                   	ret    

c0100c62 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
c0100c62:	55                   	push   %ebp
c0100c63:	89 e5                	mov    %esp,%ebp
c0100c65:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
c0100c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0100c6f:	eb 3d                	jmp    c0100cae <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
c0100c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0100c74:	89 d0                	mov    %edx,%eax
c0100c76:	01 c0                	add    %eax,%eax
c0100c78:	01 d0                	add    %edx,%eax
c0100c7a:	c1 e0 02             	shl    $0x2,%eax
c0100c7d:	05 04 90 11 c0       	add    $0xc0119004,%eax
c0100c82:	8b 10                	mov    (%eax),%edx
c0100c84:	8b 4d f4             	mov    -0xc(%ebp),%ecx
c0100c87:	89 c8                	mov    %ecx,%eax
c0100c89:	01 c0                	add    %eax,%eax
c0100c8b:	01 c8                	add    %ecx,%eax
c0100c8d:	c1 e0 02             	shl    $0x2,%eax
c0100c90:	05 00 90 11 c0       	add    $0xc0119000,%eax
c0100c95:	8b 00                	mov    (%eax),%eax
c0100c97:	89 54 24 08          	mov    %edx,0x8(%esp)
c0100c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100c9f:	c7 04 24 d5 64 10 c0 	movl   $0xc01064d5,(%esp)
c0100ca6:	e8 ab f6 ff ff       	call   c0100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
c0100cab:	ff 45 f4             	incl   -0xc(%ebp)
c0100cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100cb1:	83 f8 02             	cmp    $0x2,%eax
c0100cb4:	76 bb                	jbe    c0100c71 <mon_help+0xf>
    }
    return 0;
c0100cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100cbb:	89 ec                	mov    %ebp,%esp
c0100cbd:	5d                   	pop    %ebp
c0100cbe:	c3                   	ret    

c0100cbf <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
c0100cbf:	55                   	push   %ebp
c0100cc0:	89 e5                	mov    %esp,%ebp
c0100cc2:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
c0100cc5:	e8 af fb ff ff       	call   c0100879 <print_kerninfo>
    return 0;
c0100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ccf:	89 ec                	mov    %ebp,%esp
c0100cd1:	5d                   	pop    %ebp
c0100cd2:	c3                   	ret    

c0100cd3 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
c0100cd3:	55                   	push   %ebp
c0100cd4:	89 e5                	mov    %esp,%ebp
c0100cd6:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
c0100cd9:	e8 e7 fc ff ff       	call   c01009c5 <print_stackframe>
    return 0;
c0100cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100ce3:	89 ec                	mov    %ebp,%esp
c0100ce5:	5d                   	pop    %ebp
c0100ce6:	c3                   	ret    

c0100ce7 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
c0100ce7:	55                   	push   %ebp
c0100ce8:	89 e5                	mov    %esp,%ebp
c0100cea:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
c0100ced:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
c0100cf2:	85 c0                	test   %eax,%eax
c0100cf4:	75 5b                	jne    c0100d51 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
c0100cf6:	c7 05 20 c4 11 c0 01 	movl   $0x1,0xc011c420
c0100cfd:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
c0100d00:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
c0100d06:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d09:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d0d:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d14:	c7 04 24 de 64 10 c0 	movl   $0xc01064de,(%esp)
c0100d1b:	e8 36 f6 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d23:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d27:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d2a:	89 04 24             	mov    %eax,(%esp)
c0100d2d:	e8 ef f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d32:	c7 04 24 fa 64 10 c0 	movl   $0xc01064fa,(%esp)
c0100d39:	e8 18 f6 ff ff       	call   c0100356 <cprintf>
    
    cprintf("stack trackback:\n");
c0100d3e:	c7 04 24 fc 64 10 c0 	movl   $0xc01064fc,(%esp)
c0100d45:	e8 0c f6 ff ff       	call   c0100356 <cprintf>
    print_stackframe();
c0100d4a:	e8 76 fc ff ff       	call   c01009c5 <print_stackframe>
c0100d4f:	eb 01                	jmp    c0100d52 <__panic+0x6b>
        goto panic_dead;
c0100d51:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
c0100d52:	e8 e9 09 00 00       	call   c0101740 <intr_disable>
    while (1) {
        kmonitor(NULL);
c0100d57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100d5e:	e8 9d fe ff ff       	call   c0100c00 <kmonitor>
c0100d63:	eb f2                	jmp    c0100d57 <__panic+0x70>

c0100d65 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
c0100d65:	55                   	push   %ebp
c0100d66:	89 e5                	mov    %esp,%ebp
c0100d68:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
c0100d6b:	8d 45 14             	lea    0x14(%ebp),%eax
c0100d6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
c0100d71:	8b 45 0c             	mov    0xc(%ebp),%eax
c0100d74:	89 44 24 08          	mov    %eax,0x8(%esp)
c0100d78:	8b 45 08             	mov    0x8(%ebp),%eax
c0100d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d7f:	c7 04 24 0e 65 10 c0 	movl   $0xc010650e,(%esp)
c0100d86:	e8 cb f5 ff ff       	call   c0100356 <cprintf>
    vcprintf(fmt, ap);
c0100d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0100d92:	8b 45 10             	mov    0x10(%ebp),%eax
c0100d95:	89 04 24             	mov    %eax,(%esp)
c0100d98:	e8 84 f5 ff ff       	call   c0100321 <vcprintf>
    cprintf("\n");
c0100d9d:	c7 04 24 fa 64 10 c0 	movl   $0xc01064fa,(%esp)
c0100da4:	e8 ad f5 ff ff       	call   c0100356 <cprintf>
    va_end(ap);
}
c0100da9:	90                   	nop
c0100daa:	89 ec                	mov    %ebp,%esp
c0100dac:	5d                   	pop    %ebp
c0100dad:	c3                   	ret    

c0100dae <is_kernel_panic>:

bool
is_kernel_panic(void) {
c0100dae:	55                   	push   %ebp
c0100daf:	89 e5                	mov    %esp,%ebp
    return is_panic;
c0100db1:	a1 20 c4 11 c0       	mov    0xc011c420,%eax
}
c0100db6:	5d                   	pop    %ebp
c0100db7:	c3                   	ret    

c0100db8 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
c0100db8:	55                   	push   %ebp
c0100db9:	89 e5                	mov    %esp,%ebp
c0100dbb:	83 ec 28             	sub    $0x28,%esp
c0100dbe:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
c0100dc4:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100dc8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100dcc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100dd0:	ee                   	out    %al,(%dx)
}
c0100dd1:	90                   	nop
c0100dd2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
c0100dd8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ddc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100de0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c0100de4:	ee                   	out    %al,(%dx)
}
c0100de5:	90                   	nop
c0100de6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
c0100dec:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100df0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c0100df4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c0100df8:	ee                   	out    %al,(%dx)
}
c0100df9:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
c0100dfa:	c7 05 24 c4 11 c0 00 	movl   $0x0,0xc011c424
c0100e01:	00 00 00 

    cprintf("++ setup timer interrupts\n");
c0100e04:	c7 04 24 2c 65 10 c0 	movl   $0xc010652c,(%esp)
c0100e0b:	e8 46 f5 ff ff       	call   c0100356 <cprintf>
    pic_enable(IRQ_TIMER);
c0100e10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c0100e17:	e8 89 09 00 00       	call   c01017a5 <pic_enable>
}
c0100e1c:	90                   	nop
c0100e1d:	89 ec                	mov    %ebp,%esp
c0100e1f:	5d                   	pop    %ebp
c0100e20:	c3                   	ret    

c0100e21 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
c0100e21:	55                   	push   %ebp
c0100e22:	89 e5                	mov    %esp,%ebp
c0100e24:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0100e27:	9c                   	pushf  
c0100e28:	58                   	pop    %eax
c0100e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0100e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0100e2f:	25 00 02 00 00       	and    $0x200,%eax
c0100e34:	85 c0                	test   %eax,%eax
c0100e36:	74 0c                	je     c0100e44 <__intr_save+0x23>
        intr_disable();
c0100e38:	e8 03 09 00 00       	call   c0101740 <intr_disable>
        return 1;
c0100e3d:	b8 01 00 00 00       	mov    $0x1,%eax
c0100e42:	eb 05                	jmp    c0100e49 <__intr_save+0x28>
    }
    return 0;
c0100e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0100e49:	89 ec                	mov    %ebp,%esp
c0100e4b:	5d                   	pop    %ebp
c0100e4c:	c3                   	ret    

c0100e4d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
c0100e4d:	55                   	push   %ebp
c0100e4e:	89 e5                	mov    %esp,%ebp
c0100e50:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0100e53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0100e57:	74 05                	je     c0100e5e <__intr_restore+0x11>
        intr_enable();
c0100e59:	e8 da 08 00 00       	call   c0101738 <intr_enable>
    }
}
c0100e5e:	90                   	nop
c0100e5f:	89 ec                	mov    %ebp,%esp
c0100e61:	5d                   	pop    %ebp
c0100e62:	c3                   	ret    

c0100e63 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
c0100e63:	55                   	push   %ebp
c0100e64:	89 e5                	mov    %esp,%ebp
c0100e66:	83 ec 10             	sub    $0x10,%esp
c0100e69:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100e6f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100e73:	89 c2                	mov    %eax,%edx
c0100e75:	ec                   	in     (%dx),%al
c0100e76:	88 45 f1             	mov    %al,-0xf(%ebp)
c0100e79:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
c0100e7f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0100e83:	89 c2                	mov    %eax,%edx
c0100e85:	ec                   	in     (%dx),%al
c0100e86:	88 45 f5             	mov    %al,-0xb(%ebp)
c0100e89:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
c0100e8f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0100e93:	89 c2                	mov    %eax,%edx
c0100e95:	ec                   	in     (%dx),%al
c0100e96:	88 45 f9             	mov    %al,-0x7(%ebp)
c0100e99:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
c0100e9f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0100ea3:	89 c2                	mov    %eax,%edx
c0100ea5:	ec                   	in     (%dx),%al
c0100ea6:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
c0100ea9:	90                   	nop
c0100eaa:	89 ec                	mov    %ebp,%esp
c0100eac:	5d                   	pop    %ebp
c0100ead:	c3                   	ret    

c0100eae <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
c0100eae:	55                   	push   %ebp
c0100eaf:	89 e5                	mov    %esp,%ebp
c0100eb1:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
c0100eb4:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
c0100ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ebe:	0f b7 00             	movzwl (%eax),%eax
c0100ec1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
c0100ec5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ec8:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
c0100ecd:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ed0:	0f b7 00             	movzwl (%eax),%eax
c0100ed3:	0f b7 c0             	movzwl %ax,%eax
c0100ed6:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
c0100edb:	74 12                	je     c0100eef <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
c0100edd:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
c0100ee4:	66 c7 05 46 c4 11 c0 	movw   $0x3b4,0xc011c446
c0100eeb:	b4 03 
c0100eed:	eb 13                	jmp    c0100f02 <cga_init+0x54>
    } else {
        *cp = was;
c0100eef:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100ef2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c0100ef6:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
c0100ef9:	66 c7 05 46 c4 11 c0 	movw   $0x3d4,0xc011c446
c0100f00:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
c0100f02:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f09:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c0100f0d:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f11:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0100f15:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0100f19:	ee                   	out    %al,(%dx)
}
c0100f1a:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
c0100f1b:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f22:	40                   	inc    %eax
c0100f23:	0f b7 c0             	movzwl %ax,%eax
c0100f26:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f2a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
c0100f2e:	89 c2                	mov    %eax,%edx
c0100f30:	ec                   	in     (%dx),%al
c0100f31:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
c0100f34:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0100f38:	0f b6 c0             	movzbl %al,%eax
c0100f3b:	c1 e0 08             	shl    $0x8,%eax
c0100f3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
c0100f41:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f48:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c0100f4c:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100f50:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0100f54:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0100f58:	ee                   	out    %al,(%dx)
}
c0100f59:	90                   	nop
    pos |= inb(addr_6845 + 1);
c0100f5a:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c0100f61:	40                   	inc    %eax
c0100f62:	0f b7 c0             	movzwl %ax,%eax
c0100f65:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0100f69:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0100f6d:	89 c2                	mov    %eax,%edx
c0100f6f:	ec                   	in     (%dx),%al
c0100f70:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
c0100f73:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c0100f77:	0f b6 c0             	movzbl %al,%eax
c0100f7a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
c0100f7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0100f80:	a3 40 c4 11 c0       	mov    %eax,0xc011c440
    crt_pos = pos;
c0100f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0100f88:	0f b7 c0             	movzwl %ax,%eax
c0100f8b:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
}
c0100f91:	90                   	nop
c0100f92:	89 ec                	mov    %ebp,%esp
c0100f94:	5d                   	pop    %ebp
c0100f95:	c3                   	ret    

c0100f96 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
c0100f96:	55                   	push   %ebp
c0100f97:	89 e5                	mov    %esp,%ebp
c0100f99:	83 ec 48             	sub    $0x48,%esp
c0100f9c:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
c0100fa2:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fa6:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0100faa:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0100fae:	ee                   	out    %al,(%dx)
}
c0100faf:	90                   	nop
c0100fb0:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
c0100fb6:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fba:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0100fbe:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0100fc2:	ee                   	out    %al,(%dx)
}
c0100fc3:	90                   	nop
c0100fc4:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
c0100fca:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fce:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0100fd2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c0100fd6:	ee                   	out    %al,(%dx)
}
c0100fd7:	90                   	nop
c0100fd8:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
c0100fde:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100fe2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c0100fe6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0100fea:	ee                   	out    %al,(%dx)
}
c0100feb:	90                   	nop
c0100fec:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
c0100ff2:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0100ff6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0100ffa:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0100ffe:	ee                   	out    %al,(%dx)
}
c0100fff:	90                   	nop
c0101000:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
c0101006:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010100a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c010100e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101012:	ee                   	out    %al,(%dx)
}
c0101013:	90                   	nop
c0101014:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
c010101a:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010101e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101022:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c0101026:	ee                   	out    %al,(%dx)
}
c0101027:	90                   	nop
c0101028:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010102e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
c0101032:	89 c2                	mov    %eax,%edx
c0101034:	ec                   	in     (%dx),%al
c0101035:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
c0101038:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
c010103c:	3c ff                	cmp    $0xff,%al
c010103e:	0f 95 c0             	setne  %al
c0101041:	0f b6 c0             	movzbl %al,%eax
c0101044:	a3 48 c4 11 c0       	mov    %eax,0xc011c448
c0101049:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c010104f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
c0101053:	89 c2                	mov    %eax,%edx
c0101055:	ec                   	in     (%dx),%al
c0101056:	88 45 f1             	mov    %al,-0xf(%ebp)
c0101059:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c010105f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c0101063:	89 c2                	mov    %eax,%edx
c0101065:	ec                   	in     (%dx),%al
c0101066:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
c0101069:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c010106e:	85 c0                	test   %eax,%eax
c0101070:	74 0c                	je     c010107e <serial_init+0xe8>
        pic_enable(IRQ_COM1);
c0101072:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c0101079:	e8 27 07 00 00       	call   c01017a5 <pic_enable>
    }
}
c010107e:	90                   	nop
c010107f:	89 ec                	mov    %ebp,%esp
c0101081:	5d                   	pop    %ebp
c0101082:	c3                   	ret    

c0101083 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
c0101083:	55                   	push   %ebp
c0101084:	89 e5                	mov    %esp,%ebp
c0101086:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101089:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101090:	eb 08                	jmp    c010109a <lpt_putc_sub+0x17>
        delay();
c0101092:	e8 cc fd ff ff       	call   c0100e63 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
c0101097:	ff 45 fc             	incl   -0x4(%ebp)
c010109a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
c01010a0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c01010a4:	89 c2                	mov    %eax,%edx
c01010a6:	ec                   	in     (%dx),%al
c01010a7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c01010aa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01010ae:	84 c0                	test   %al,%al
c01010b0:	78 09                	js     c01010bb <lpt_putc_sub+0x38>
c01010b2:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c01010b9:	7e d7                	jle    c0101092 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
c01010bb:	8b 45 08             	mov    0x8(%ebp),%eax
c01010be:	0f b6 c0             	movzbl %al,%eax
c01010c1:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
c01010c7:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010ca:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01010ce:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01010d2:	ee                   	out    %al,(%dx)
}
c01010d3:	90                   	nop
c01010d4:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
c01010da:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010de:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01010e2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01010e6:	ee                   	out    %al,(%dx)
}
c01010e7:	90                   	nop
c01010e8:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
c01010ee:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01010f2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01010f6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01010fa:	ee                   	out    %al,(%dx)
}
c01010fb:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
c01010fc:	90                   	nop
c01010fd:	89 ec                	mov    %ebp,%esp
c01010ff:	5d                   	pop    %ebp
c0101100:	c3                   	ret    

c0101101 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
c0101101:	55                   	push   %ebp
c0101102:	89 e5                	mov    %esp,%ebp
c0101104:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c0101107:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010110b:	74 0d                	je     c010111a <lpt_putc+0x19>
        lpt_putc_sub(c);
c010110d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101110:	89 04 24             	mov    %eax,(%esp)
c0101113:	e8 6b ff ff ff       	call   c0101083 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
c0101118:	eb 24                	jmp    c010113e <lpt_putc+0x3d>
        lpt_putc_sub('\b');
c010111a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101121:	e8 5d ff ff ff       	call   c0101083 <lpt_putc_sub>
        lpt_putc_sub(' ');
c0101126:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c010112d:	e8 51 ff ff ff       	call   c0101083 <lpt_putc_sub>
        lpt_putc_sub('\b');
c0101132:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c0101139:	e8 45 ff ff ff       	call   c0101083 <lpt_putc_sub>
}
c010113e:	90                   	nop
c010113f:	89 ec                	mov    %ebp,%esp
c0101141:	5d                   	pop    %ebp
c0101142:	c3                   	ret    

c0101143 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
c0101143:	55                   	push   %ebp
c0101144:	89 e5                	mov    %esp,%ebp
c0101146:	83 ec 38             	sub    $0x38,%esp
c0101149:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
c010114c:	8b 45 08             	mov    0x8(%ebp),%eax
c010114f:	25 00 ff ff ff       	and    $0xffffff00,%eax
c0101154:	85 c0                	test   %eax,%eax
c0101156:	75 07                	jne    c010115f <cga_putc+0x1c>
        c |= 0x0700;
c0101158:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
c010115f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101162:	0f b6 c0             	movzbl %al,%eax
c0101165:	83 f8 0d             	cmp    $0xd,%eax
c0101168:	74 72                	je     c01011dc <cga_putc+0x99>
c010116a:	83 f8 0d             	cmp    $0xd,%eax
c010116d:	0f 8f a3 00 00 00    	jg     c0101216 <cga_putc+0xd3>
c0101173:	83 f8 08             	cmp    $0x8,%eax
c0101176:	74 0a                	je     c0101182 <cga_putc+0x3f>
c0101178:	83 f8 0a             	cmp    $0xa,%eax
c010117b:	74 4c                	je     c01011c9 <cga_putc+0x86>
c010117d:	e9 94 00 00 00       	jmp    c0101216 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
c0101182:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101189:	85 c0                	test   %eax,%eax
c010118b:	0f 84 af 00 00 00    	je     c0101240 <cga_putc+0xfd>
            crt_pos --;
c0101191:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101198:	48                   	dec    %eax
c0101199:	0f b7 c0             	movzwl %ax,%eax
c010119c:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
c01011a2:	8b 45 08             	mov    0x8(%ebp),%eax
c01011a5:	98                   	cwtl   
c01011a6:	25 00 ff ff ff       	and    $0xffffff00,%eax
c01011ab:	98                   	cwtl   
c01011ac:	83 c8 20             	or     $0x20,%eax
c01011af:	98                   	cwtl   
c01011b0:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c01011b6:	0f b7 15 44 c4 11 c0 	movzwl 0xc011c444,%edx
c01011bd:	01 d2                	add    %edx,%edx
c01011bf:	01 ca                	add    %ecx,%edx
c01011c1:	0f b7 c0             	movzwl %ax,%eax
c01011c4:	66 89 02             	mov    %ax,(%edx)
        }
        break;
c01011c7:	eb 77                	jmp    c0101240 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
c01011c9:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01011d0:	83 c0 50             	add    $0x50,%eax
c01011d3:	0f b7 c0             	movzwl %ax,%eax
c01011d6:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
c01011dc:	0f b7 1d 44 c4 11 c0 	movzwl 0xc011c444,%ebx
c01011e3:	0f b7 0d 44 c4 11 c0 	movzwl 0xc011c444,%ecx
c01011ea:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
c01011ef:	89 c8                	mov    %ecx,%eax
c01011f1:	f7 e2                	mul    %edx
c01011f3:	c1 ea 06             	shr    $0x6,%edx
c01011f6:	89 d0                	mov    %edx,%eax
c01011f8:	c1 e0 02             	shl    $0x2,%eax
c01011fb:	01 d0                	add    %edx,%eax
c01011fd:	c1 e0 04             	shl    $0x4,%eax
c0101200:	29 c1                	sub    %eax,%ecx
c0101202:	89 ca                	mov    %ecx,%edx
c0101204:	0f b7 d2             	movzwl %dx,%edx
c0101207:	89 d8                	mov    %ebx,%eax
c0101209:	29 d0                	sub    %edx,%eax
c010120b:	0f b7 c0             	movzwl %ax,%eax
c010120e:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
        break;
c0101214:	eb 2b                	jmp    c0101241 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
c0101216:	8b 0d 40 c4 11 c0    	mov    0xc011c440,%ecx
c010121c:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101223:	8d 50 01             	lea    0x1(%eax),%edx
c0101226:	0f b7 d2             	movzwl %dx,%edx
c0101229:	66 89 15 44 c4 11 c0 	mov    %dx,0xc011c444
c0101230:	01 c0                	add    %eax,%eax
c0101232:	8d 14 01             	lea    (%ecx,%eax,1),%edx
c0101235:	8b 45 08             	mov    0x8(%ebp),%eax
c0101238:	0f b7 c0             	movzwl %ax,%eax
c010123b:	66 89 02             	mov    %ax,(%edx)
        break;
c010123e:	eb 01                	jmp    c0101241 <cga_putc+0xfe>
        break;
c0101240:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
c0101241:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101248:	3d cf 07 00 00       	cmp    $0x7cf,%eax
c010124d:	76 5e                	jbe    c01012ad <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
c010124f:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c0101254:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
c010125a:	a1 40 c4 11 c0       	mov    0xc011c440,%eax
c010125f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
c0101266:	00 
c0101267:	89 54 24 04          	mov    %edx,0x4(%esp)
c010126b:	89 04 24             	mov    %eax,(%esp)
c010126e:	e8 40 4e 00 00       	call   c01060b3 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c0101273:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
c010127a:	eb 15                	jmp    c0101291 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
c010127c:	8b 15 40 c4 11 c0    	mov    0xc011c440,%edx
c0101282:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101285:	01 c0                	add    %eax,%eax
c0101287:	01 d0                	add    %edx,%eax
c0101289:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
c010128e:	ff 45 f4             	incl   -0xc(%ebp)
c0101291:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
c0101298:	7e e2                	jle    c010127c <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
c010129a:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012a1:	83 e8 50             	sub    $0x50,%eax
c01012a4:	0f b7 c0             	movzwl %ax,%eax
c01012a7:	66 a3 44 c4 11 c0    	mov    %ax,0xc011c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
c01012ad:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c01012b4:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
c01012b8:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012bc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c01012c0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c01012c4:	ee                   	out    %al,(%dx)
}
c01012c5:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
c01012c6:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c01012cd:	c1 e8 08             	shr    $0x8,%eax
c01012d0:	0f b7 c0             	movzwl %ax,%eax
c01012d3:	0f b6 c0             	movzbl %al,%eax
c01012d6:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c01012dd:	42                   	inc    %edx
c01012de:	0f b7 d2             	movzwl %dx,%edx
c01012e1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
c01012e5:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01012e8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c01012ec:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c01012f0:	ee                   	out    %al,(%dx)
}
c01012f1:	90                   	nop
    outb(addr_6845, 15);
c01012f2:	0f b7 05 46 c4 11 c0 	movzwl 0xc011c446,%eax
c01012f9:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
c01012fd:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101301:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c0101305:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c0101309:	ee                   	out    %al,(%dx)
}
c010130a:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
c010130b:	0f b7 05 44 c4 11 c0 	movzwl 0xc011c444,%eax
c0101312:	0f b6 c0             	movzbl %al,%eax
c0101315:	0f b7 15 46 c4 11 c0 	movzwl 0xc011c446,%edx
c010131c:	42                   	inc    %edx
c010131d:	0f b7 d2             	movzwl %dx,%edx
c0101320:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
c0101324:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101327:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c010132b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c010132f:	ee                   	out    %al,(%dx)
}
c0101330:	90                   	nop
}
c0101331:	90                   	nop
c0101332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101335:	89 ec                	mov    %ebp,%esp
c0101337:	5d                   	pop    %ebp
c0101338:	c3                   	ret    

c0101339 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
c0101339:	55                   	push   %ebp
c010133a:	89 e5                	mov    %esp,%ebp
c010133c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010133f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101346:	eb 08                	jmp    c0101350 <serial_putc_sub+0x17>
        delay();
c0101348:	e8 16 fb ff ff       	call   c0100e63 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
c010134d:	ff 45 fc             	incl   -0x4(%ebp)
c0101350:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101356:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c010135a:	89 c2                	mov    %eax,%edx
c010135c:	ec                   	in     (%dx),%al
c010135d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c0101360:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c0101364:	0f b6 c0             	movzbl %al,%eax
c0101367:	83 e0 20             	and    $0x20,%eax
c010136a:	85 c0                	test   %eax,%eax
c010136c:	75 09                	jne    c0101377 <serial_putc_sub+0x3e>
c010136e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
c0101375:	7e d1                	jle    c0101348 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
c0101377:	8b 45 08             	mov    0x8(%ebp),%eax
c010137a:	0f b6 c0             	movzbl %al,%eax
c010137d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
c0101383:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101386:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c010138a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c010138e:	ee                   	out    %al,(%dx)
}
c010138f:	90                   	nop
}
c0101390:	90                   	nop
c0101391:	89 ec                	mov    %ebp,%esp
c0101393:	5d                   	pop    %ebp
c0101394:	c3                   	ret    

c0101395 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
c0101395:	55                   	push   %ebp
c0101396:	89 e5                	mov    %esp,%ebp
c0101398:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
c010139b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
c010139f:	74 0d                	je     c01013ae <serial_putc+0x19>
        serial_putc_sub(c);
c01013a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01013a4:	89 04 24             	mov    %eax,(%esp)
c01013a7:	e8 8d ff ff ff       	call   c0101339 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
c01013ac:	eb 24                	jmp    c01013d2 <serial_putc+0x3d>
        serial_putc_sub('\b');
c01013ae:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013b5:	e8 7f ff ff ff       	call   c0101339 <serial_putc_sub>
        serial_putc_sub(' ');
c01013ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c01013c1:	e8 73 ff ff ff       	call   c0101339 <serial_putc_sub>
        serial_putc_sub('\b');
c01013c6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
c01013cd:	e8 67 ff ff ff       	call   c0101339 <serial_putc_sub>
}
c01013d2:	90                   	nop
c01013d3:	89 ec                	mov    %ebp,%esp
c01013d5:	5d                   	pop    %ebp
c01013d6:	c3                   	ret    

c01013d7 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
c01013d7:	55                   	push   %ebp
c01013d8:	89 e5                	mov    %esp,%ebp
c01013da:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
c01013dd:	eb 33                	jmp    c0101412 <cons_intr+0x3b>
        if (c != 0) {
c01013df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01013e3:	74 2d                	je     c0101412 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
c01013e5:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c01013ea:	8d 50 01             	lea    0x1(%eax),%edx
c01013ed:	89 15 64 c6 11 c0    	mov    %edx,0xc011c664
c01013f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01013f6:	88 90 60 c4 11 c0    	mov    %dl,-0x3fee3ba0(%eax)
            if (cons.wpos == CONSBUFSIZE) {
c01013fc:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c0101401:	3d 00 02 00 00       	cmp    $0x200,%eax
c0101406:	75 0a                	jne    c0101412 <cons_intr+0x3b>
                cons.wpos = 0;
c0101408:	c7 05 64 c6 11 c0 00 	movl   $0x0,0xc011c664
c010140f:	00 00 00 
    while ((c = (*proc)()) != -1) {
c0101412:	8b 45 08             	mov    0x8(%ebp),%eax
c0101415:	ff d0                	call   *%eax
c0101417:	89 45 f4             	mov    %eax,-0xc(%ebp)
c010141a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
c010141e:	75 bf                	jne    c01013df <cons_intr+0x8>
            }
        }
    }
}
c0101420:	90                   	nop
c0101421:	90                   	nop
c0101422:	89 ec                	mov    %ebp,%esp
c0101424:	5d                   	pop    %ebp
c0101425:	c3                   	ret    

c0101426 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
c0101426:	55                   	push   %ebp
c0101427:	89 e5                	mov    %esp,%ebp
c0101429:	83 ec 10             	sub    $0x10,%esp
c010142c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101432:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
c0101436:	89 c2                	mov    %eax,%edx
c0101438:	ec                   	in     (%dx),%al
c0101439:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
c010143c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
c0101440:	0f b6 c0             	movzbl %al,%eax
c0101443:	83 e0 01             	and    $0x1,%eax
c0101446:	85 c0                	test   %eax,%eax
c0101448:	75 07                	jne    c0101451 <serial_proc_data+0x2b>
        return -1;
c010144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c010144f:	eb 2a                	jmp    c010147b <serial_proc_data+0x55>
c0101451:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c0101457:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
c010145b:	89 c2                	mov    %eax,%edx
c010145d:	ec                   	in     (%dx),%al
c010145e:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
c0101461:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
c0101465:	0f b6 c0             	movzbl %al,%eax
c0101468:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
c010146b:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
c010146f:	75 07                	jne    c0101478 <serial_proc_data+0x52>
        c = '\b';
c0101471:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
c0101478:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c010147b:	89 ec                	mov    %ebp,%esp
c010147d:	5d                   	pop    %ebp
c010147e:	c3                   	ret    

c010147f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
c010147f:	55                   	push   %ebp
c0101480:	89 e5                	mov    %esp,%ebp
c0101482:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
c0101485:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c010148a:	85 c0                	test   %eax,%eax
c010148c:	74 0c                	je     c010149a <serial_intr+0x1b>
        cons_intr(serial_proc_data);
c010148e:	c7 04 24 26 14 10 c0 	movl   $0xc0101426,(%esp)
c0101495:	e8 3d ff ff ff       	call   c01013d7 <cons_intr>
    }
}
c010149a:	90                   	nop
c010149b:	89 ec                	mov    %ebp,%esp
c010149d:	5d                   	pop    %ebp
c010149e:	c3                   	ret    

c010149f <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
c010149f:	55                   	push   %ebp
c01014a0:	89 e5                	mov    %esp,%ebp
c01014a2:	83 ec 38             	sub    $0x38,%esp
c01014a5:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01014ae:	89 c2                	mov    %eax,%edx
c01014b0:	ec                   	in     (%dx),%al
c01014b1:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
c01014b4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
c01014b8:	0f b6 c0             	movzbl %al,%eax
c01014bb:	83 e0 01             	and    $0x1,%eax
c01014be:	85 c0                	test   %eax,%eax
c01014c0:	75 0a                	jne    c01014cc <kbd_proc_data+0x2d>
        return -1;
c01014c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
c01014c7:	e9 56 01 00 00       	jmp    c0101622 <kbd_proc_data+0x183>
c01014cc:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
c01014d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01014d5:	89 c2                	mov    %eax,%edx
c01014d7:	ec                   	in     (%dx),%al
c01014d8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
c01014db:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
c01014df:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
c01014e2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
c01014e6:	75 17                	jne    c01014ff <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
c01014e8:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01014ed:	83 c8 40             	or     $0x40,%eax
c01014f0:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c01014f5:	b8 00 00 00 00       	mov    $0x0,%eax
c01014fa:	e9 23 01 00 00       	jmp    c0101622 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
c01014ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101503:	84 c0                	test   %al,%al
c0101505:	79 45                	jns    c010154c <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
c0101507:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010150c:	83 e0 40             	and    $0x40,%eax
c010150f:	85 c0                	test   %eax,%eax
c0101511:	75 08                	jne    c010151b <kbd_proc_data+0x7c>
c0101513:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101517:	24 7f                	and    $0x7f,%al
c0101519:	eb 04                	jmp    c010151f <kbd_proc_data+0x80>
c010151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010151f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
c0101522:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101526:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c010152d:	0c 40                	or     $0x40,%al
c010152f:	0f b6 c0             	movzbl %al,%eax
c0101532:	f7 d0                	not    %eax
c0101534:	89 c2                	mov    %eax,%edx
c0101536:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010153b:	21 d0                	and    %edx,%eax
c010153d:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
        return 0;
c0101542:	b8 00 00 00 00       	mov    $0x0,%eax
c0101547:	e9 d6 00 00 00       	jmp    c0101622 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
c010154c:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101551:	83 e0 40             	and    $0x40,%eax
c0101554:	85 c0                	test   %eax,%eax
c0101556:	74 11                	je     c0101569 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
c0101558:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
c010155c:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101561:	83 e0 bf             	and    $0xffffffbf,%eax
c0101564:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    }

    shift |= shiftcode[data];
c0101569:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c010156d:	0f b6 80 40 90 11 c0 	movzbl -0x3fee6fc0(%eax),%eax
c0101574:	0f b6 d0             	movzbl %al,%edx
c0101577:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c010157c:	09 d0                	or     %edx,%eax
c010157e:	a3 68 c6 11 c0       	mov    %eax,0xc011c668
    shift ^= togglecode[data];
c0101583:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c0101587:	0f b6 80 40 91 11 c0 	movzbl -0x3fee6ec0(%eax),%eax
c010158e:	0f b6 d0             	movzbl %al,%edx
c0101591:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c0101596:	31 d0                	xor    %edx,%eax
c0101598:	a3 68 c6 11 c0       	mov    %eax,0xc011c668

    c = charcode[shift & (CTL | SHIFT)][data];
c010159d:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015a2:	83 e0 03             	and    $0x3,%eax
c01015a5:	8b 14 85 40 95 11 c0 	mov    -0x3fee6ac0(,%eax,4),%edx
c01015ac:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
c01015b0:	01 d0                	add    %edx,%eax
c01015b2:	0f b6 00             	movzbl (%eax),%eax
c01015b5:	0f b6 c0             	movzbl %al,%eax
c01015b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
c01015bb:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015c0:	83 e0 08             	and    $0x8,%eax
c01015c3:	85 c0                	test   %eax,%eax
c01015c5:	74 22                	je     c01015e9 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
c01015c7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
c01015cb:	7e 0c                	jle    c01015d9 <kbd_proc_data+0x13a>
c01015cd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
c01015d1:	7f 06                	jg     c01015d9 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
c01015d3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
c01015d7:	eb 10                	jmp    c01015e9 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
c01015d9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
c01015dd:	7e 0a                	jle    c01015e9 <kbd_proc_data+0x14a>
c01015df:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
c01015e3:	7f 04                	jg     c01015e9 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
c01015e5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
c01015e9:	a1 68 c6 11 c0       	mov    0xc011c668,%eax
c01015ee:	f7 d0                	not    %eax
c01015f0:	83 e0 06             	and    $0x6,%eax
c01015f3:	85 c0                	test   %eax,%eax
c01015f5:	75 28                	jne    c010161f <kbd_proc_data+0x180>
c01015f7:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
c01015fe:	75 1f                	jne    c010161f <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
c0101600:	c7 04 24 47 65 10 c0 	movl   $0xc0106547,(%esp)
c0101607:	e8 4a ed ff ff       	call   c0100356 <cprintf>
c010160c:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
c0101612:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101616:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
c010161a:	8b 55 e8             	mov    -0x18(%ebp),%edx
c010161d:	ee                   	out    %al,(%dx)
}
c010161e:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
c010161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101622:	89 ec                	mov    %ebp,%esp
c0101624:	5d                   	pop    %ebp
c0101625:	c3                   	ret    

c0101626 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
c0101626:	55                   	push   %ebp
c0101627:	89 e5                	mov    %esp,%ebp
c0101629:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
c010162c:	c7 04 24 9f 14 10 c0 	movl   $0xc010149f,(%esp)
c0101633:	e8 9f fd ff ff       	call   c01013d7 <cons_intr>
}
c0101638:	90                   	nop
c0101639:	89 ec                	mov    %ebp,%esp
c010163b:	5d                   	pop    %ebp
c010163c:	c3                   	ret    

c010163d <kbd_init>:

static void
kbd_init(void) {
c010163d:	55                   	push   %ebp
c010163e:	89 e5                	mov    %esp,%ebp
c0101640:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
c0101643:	e8 de ff ff ff       	call   c0101626 <kbd_intr>
    pic_enable(IRQ_KBD);
c0101648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010164f:	e8 51 01 00 00       	call   c01017a5 <pic_enable>
}
c0101654:	90                   	nop
c0101655:	89 ec                	mov    %ebp,%esp
c0101657:	5d                   	pop    %ebp
c0101658:	c3                   	ret    

c0101659 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
c0101659:	55                   	push   %ebp
c010165a:	89 e5                	mov    %esp,%ebp
c010165c:	83 ec 18             	sub    $0x18,%esp
    cga_init();
c010165f:	e8 4a f8 ff ff       	call   c0100eae <cga_init>
    serial_init();
c0101664:	e8 2d f9 ff ff       	call   c0100f96 <serial_init>
    kbd_init();
c0101669:	e8 cf ff ff ff       	call   c010163d <kbd_init>
    if (!serial_exists) {
c010166e:	a1 48 c4 11 c0       	mov    0xc011c448,%eax
c0101673:	85 c0                	test   %eax,%eax
c0101675:	75 0c                	jne    c0101683 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
c0101677:	c7 04 24 53 65 10 c0 	movl   $0xc0106553,(%esp)
c010167e:	e8 d3 ec ff ff       	call   c0100356 <cprintf>
    }
}
c0101683:	90                   	nop
c0101684:	89 ec                	mov    %ebp,%esp
c0101686:	5d                   	pop    %ebp
c0101687:	c3                   	ret    

c0101688 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
c0101688:	55                   	push   %ebp
c0101689:	89 e5                	mov    %esp,%ebp
c010168b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010168e:	e8 8e f7 ff ff       	call   c0100e21 <__intr_save>
c0101693:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
c0101696:	8b 45 08             	mov    0x8(%ebp),%eax
c0101699:	89 04 24             	mov    %eax,(%esp)
c010169c:	e8 60 fa ff ff       	call   c0101101 <lpt_putc>
        cga_putc(c);
c01016a1:	8b 45 08             	mov    0x8(%ebp),%eax
c01016a4:	89 04 24             	mov    %eax,(%esp)
c01016a7:	e8 97 fa ff ff       	call   c0101143 <cga_putc>
        serial_putc(c);
c01016ac:	8b 45 08             	mov    0x8(%ebp),%eax
c01016af:	89 04 24             	mov    %eax,(%esp)
c01016b2:	e8 de fc ff ff       	call   c0101395 <serial_putc>
    }
    local_intr_restore(intr_flag);
c01016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01016ba:	89 04 24             	mov    %eax,(%esp)
c01016bd:	e8 8b f7 ff ff       	call   c0100e4d <__intr_restore>
}
c01016c2:	90                   	nop
c01016c3:	89 ec                	mov    %ebp,%esp
c01016c5:	5d                   	pop    %ebp
c01016c6:	c3                   	ret    

c01016c7 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
c01016c7:	55                   	push   %ebp
c01016c8:	89 e5                	mov    %esp,%ebp
c01016ca:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
c01016cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c01016d4:	e8 48 f7 ff ff       	call   c0100e21 <__intr_save>
c01016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
c01016dc:	e8 9e fd ff ff       	call   c010147f <serial_intr>
        kbd_intr();
c01016e1:	e8 40 ff ff ff       	call   c0101626 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
c01016e6:	8b 15 60 c6 11 c0    	mov    0xc011c660,%edx
c01016ec:	a1 64 c6 11 c0       	mov    0xc011c664,%eax
c01016f1:	39 c2                	cmp    %eax,%edx
c01016f3:	74 31                	je     c0101726 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
c01016f5:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c01016fa:	8d 50 01             	lea    0x1(%eax),%edx
c01016fd:	89 15 60 c6 11 c0    	mov    %edx,0xc011c660
c0101703:	0f b6 80 60 c4 11 c0 	movzbl -0x3fee3ba0(%eax),%eax
c010170a:	0f b6 c0             	movzbl %al,%eax
c010170d:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
c0101710:	a1 60 c6 11 c0       	mov    0xc011c660,%eax
c0101715:	3d 00 02 00 00       	cmp    $0x200,%eax
c010171a:	75 0a                	jne    c0101726 <cons_getc+0x5f>
                cons.rpos = 0;
c010171c:	c7 05 60 c6 11 c0 00 	movl   $0x0,0xc011c660
c0101723:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
c0101726:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101729:	89 04 24             	mov    %eax,(%esp)
c010172c:	e8 1c f7 ff ff       	call   c0100e4d <__intr_restore>
    return c;
c0101731:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0101734:	89 ec                	mov    %ebp,%esp
c0101736:	5d                   	pop    %ebp
c0101737:	c3                   	ret    

c0101738 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
c0101738:	55                   	push   %ebp
c0101739:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
c010173b:	fb                   	sti    
}
c010173c:	90                   	nop
    sti();
}
c010173d:	90                   	nop
c010173e:	5d                   	pop    %ebp
c010173f:	c3                   	ret    

c0101740 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
c0101740:	55                   	push   %ebp
c0101741:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
c0101743:	fa                   	cli    
}
c0101744:	90                   	nop
    cli();
}
c0101745:	90                   	nop
c0101746:	5d                   	pop    %ebp
c0101747:	c3                   	ret    

c0101748 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
c0101748:	55                   	push   %ebp
c0101749:	89 e5                	mov    %esp,%ebp
c010174b:	83 ec 14             	sub    $0x14,%esp
c010174e:	8b 45 08             	mov    0x8(%ebp),%eax
c0101751:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
c0101755:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0101758:	66 a3 50 95 11 c0    	mov    %ax,0xc0119550
    if (did_init) {
c010175e:	a1 6c c6 11 c0       	mov    0xc011c66c,%eax
c0101763:	85 c0                	test   %eax,%eax
c0101765:	74 39                	je     c01017a0 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
c0101767:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010176a:	0f b6 c0             	movzbl %al,%eax
c010176d:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
c0101773:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101776:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c010177a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c010177e:	ee                   	out    %al,(%dx)
}
c010177f:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
c0101780:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
c0101784:	c1 e8 08             	shr    $0x8,%eax
c0101787:	0f b7 c0             	movzwl %ax,%eax
c010178a:	0f b6 c0             	movzbl %al,%eax
c010178d:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
c0101793:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101796:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c010179a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c010179e:	ee                   	out    %al,(%dx)
}
c010179f:	90                   	nop
    }
}
c01017a0:	90                   	nop
c01017a1:	89 ec                	mov    %ebp,%esp
c01017a3:	5d                   	pop    %ebp
c01017a4:	c3                   	ret    

c01017a5 <pic_enable>:

void
pic_enable(unsigned int irq) {
c01017a5:	55                   	push   %ebp
c01017a6:	89 e5                	mov    %esp,%ebp
c01017a8:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
c01017ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01017ae:	ba 01 00 00 00       	mov    $0x1,%edx
c01017b3:	88 c1                	mov    %al,%cl
c01017b5:	d3 e2                	shl    %cl,%edx
c01017b7:	89 d0                	mov    %edx,%eax
c01017b9:	98                   	cwtl   
c01017ba:	f7 d0                	not    %eax
c01017bc:	0f bf d0             	movswl %ax,%edx
c01017bf:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c01017c6:	98                   	cwtl   
c01017c7:	21 d0                	and    %edx,%eax
c01017c9:	98                   	cwtl   
c01017ca:	0f b7 c0             	movzwl %ax,%eax
c01017cd:	89 04 24             	mov    %eax,(%esp)
c01017d0:	e8 73 ff ff ff       	call   c0101748 <pic_setmask>
}
c01017d5:	90                   	nop
c01017d6:	89 ec                	mov    %ebp,%esp
c01017d8:	5d                   	pop    %ebp
c01017d9:	c3                   	ret    

c01017da <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
c01017da:	55                   	push   %ebp
c01017db:	89 e5                	mov    %esp,%ebp
c01017dd:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
c01017e0:	c7 05 6c c6 11 c0 01 	movl   $0x1,0xc011c66c
c01017e7:	00 00 00 
c01017ea:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
c01017f0:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01017f4:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
c01017f8:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
c01017fc:	ee                   	out    %al,(%dx)
}
c01017fd:	90                   	nop
c01017fe:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
c0101804:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101808:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
c010180c:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
c0101810:	ee                   	out    %al,(%dx)
}
c0101811:	90                   	nop
c0101812:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
c0101818:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010181c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
c0101820:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
c0101824:	ee                   	out    %al,(%dx)
}
c0101825:	90                   	nop
c0101826:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
c010182c:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101830:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
c0101834:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
c0101838:	ee                   	out    %al,(%dx)
}
c0101839:	90                   	nop
c010183a:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
c0101840:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101844:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
c0101848:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
c010184c:	ee                   	out    %al,(%dx)
}
c010184d:	90                   	nop
c010184e:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
c0101854:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101858:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
c010185c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
c0101860:	ee                   	out    %al,(%dx)
}
c0101861:	90                   	nop
c0101862:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
c0101868:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c010186c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
c0101870:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
c0101874:	ee                   	out    %al,(%dx)
}
c0101875:	90                   	nop
c0101876:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
c010187c:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101880:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
c0101884:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
c0101888:	ee                   	out    %al,(%dx)
}
c0101889:	90                   	nop
c010188a:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
c0101890:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c0101894:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
c0101898:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
c010189c:	ee                   	out    %al,(%dx)
}
c010189d:	90                   	nop
c010189e:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
c01018a4:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018a8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
c01018ac:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
c01018b0:	ee                   	out    %al,(%dx)
}
c01018b1:	90                   	nop
c01018b2:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
c01018b8:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018bc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
c01018c0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
c01018c4:	ee                   	out    %al,(%dx)
}
c01018c5:	90                   	nop
c01018c6:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
c01018cc:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018d0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
c01018d4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
c01018d8:	ee                   	out    %al,(%dx)
}
c01018d9:	90                   	nop
c01018da:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
c01018e0:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018e4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
c01018e8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
c01018ec:	ee                   	out    %al,(%dx)
}
c01018ed:	90                   	nop
c01018ee:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
c01018f4:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
c01018f8:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
c01018fc:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
c0101900:	ee                   	out    %al,(%dx)
}
c0101901:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
c0101902:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101909:	3d ff ff 00 00       	cmp    $0xffff,%eax
c010190e:	74 0f                	je     c010191f <pic_init+0x145>
        pic_setmask(irq_mask);
c0101910:	0f b7 05 50 95 11 c0 	movzwl 0xc0119550,%eax
c0101917:	89 04 24             	mov    %eax,(%esp)
c010191a:	e8 29 fe ff ff       	call   c0101748 <pic_setmask>
    }
}
c010191f:	90                   	nop
c0101920:	89 ec                	mov    %ebp,%esp
c0101922:	5d                   	pop    %ebp
c0101923:	c3                   	ret    

c0101924 <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
c0101924:	55                   	push   %ebp
c0101925:	89 e5                	mov    %esp,%ebp
c0101927:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
c010192a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
c0101931:	00 
c0101932:	c7 04 24 80 65 10 c0 	movl   $0xc0106580,(%esp)
c0101939:	e8 18 ea ff ff       	call   c0100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
c010193e:	c7 04 24 8a 65 10 c0 	movl   $0xc010658a,(%esp)
c0101945:	e8 0c ea ff ff       	call   c0100356 <cprintf>
    panic("EOT: kernel seems ok.");
c010194a:	c7 44 24 08 98 65 10 	movl   $0xc0106598,0x8(%esp)
c0101951:	c0 
c0101952:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
c0101959:	00 
c010195a:	c7 04 24 ae 65 10 c0 	movl   $0xc01065ae,(%esp)
c0101961:	e8 81 f3 ff ff       	call   c0100ce7 <__panic>

c0101966 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
c0101966:	55                   	push   %ebp
c0101967:	89 e5                	mov    %esp,%ebp
c0101969:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c010196c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
c0101973:	e9 c4 00 00 00       	jmp    c0101a3c <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
c0101978:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010197b:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101982:	0f b7 d0             	movzwl %ax,%edx
c0101985:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101988:	66 89 14 c5 e0 c6 11 	mov    %dx,-0x3fee3920(,%eax,8)
c010198f:	c0 
c0101990:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101993:	66 c7 04 c5 e2 c6 11 	movw   $0x8,-0x3fee391e(,%eax,8)
c010199a:	c0 08 00 
c010199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019a0:	0f b6 14 c5 e4 c6 11 	movzbl -0x3fee391c(,%eax,8),%edx
c01019a7:	c0 
c01019a8:	80 e2 e0             	and    $0xe0,%dl
c01019ab:	88 14 c5 e4 c6 11 c0 	mov    %dl,-0x3fee391c(,%eax,8)
c01019b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019b5:	0f b6 14 c5 e4 c6 11 	movzbl -0x3fee391c(,%eax,8),%edx
c01019bc:	c0 
c01019bd:	80 e2 1f             	and    $0x1f,%dl
c01019c0:	88 14 c5 e4 c6 11 c0 	mov    %dl,-0x3fee391c(,%eax,8)
c01019c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019ca:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c01019d1:	c0 
c01019d2:	80 e2 f0             	and    $0xf0,%dl
c01019d5:	80 ca 0e             	or     $0xe,%dl
c01019d8:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c01019df:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019e2:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c01019e9:	c0 
c01019ea:	80 e2 ef             	and    $0xef,%dl
c01019ed:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c01019f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01019f7:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c01019fe:	c0 
c01019ff:	80 e2 9f             	and    $0x9f,%dl
c0101a02:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c0101a09:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a0c:	0f b6 14 c5 e5 c6 11 	movzbl -0x3fee391b(,%eax,8),%edx
c0101a13:	c0 
c0101a14:	80 ca 80             	or     $0x80,%dl
c0101a17:	88 14 c5 e5 c6 11 c0 	mov    %dl,-0x3fee391b(,%eax,8)
c0101a1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a21:	8b 04 85 e0 95 11 c0 	mov    -0x3fee6a20(,%eax,4),%eax
c0101a28:	c1 e8 10             	shr    $0x10,%eax
c0101a2b:	0f b7 d0             	movzwl %ax,%edx
c0101a2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a31:	66 89 14 c5 e6 c6 11 	mov    %dx,-0x3fee391a(,%eax,8)
c0101a38:	c0 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
c0101a39:	ff 45 fc             	incl   -0x4(%ebp)
c0101a3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0101a3f:	3d ff 00 00 00       	cmp    $0xff,%eax
c0101a44:	0f 86 2e ff ff ff    	jbe    c0101978 <idt_init+0x12>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
c0101a4a:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101a4f:	0f b7 c0             	movzwl %ax,%eax
c0101a52:	66 a3 a8 ca 11 c0    	mov    %ax,0xc011caa8
c0101a58:	66 c7 05 aa ca 11 c0 	movw   $0x8,0xc011caaa
c0101a5f:	08 00 
c0101a61:	0f b6 05 ac ca 11 c0 	movzbl 0xc011caac,%eax
c0101a68:	24 e0                	and    $0xe0,%al
c0101a6a:	a2 ac ca 11 c0       	mov    %al,0xc011caac
c0101a6f:	0f b6 05 ac ca 11 c0 	movzbl 0xc011caac,%eax
c0101a76:	24 1f                	and    $0x1f,%al
c0101a78:	a2 ac ca 11 c0       	mov    %al,0xc011caac
c0101a7d:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101a84:	24 f0                	and    $0xf0,%al
c0101a86:	0c 0e                	or     $0xe,%al
c0101a88:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101a8d:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101a94:	24 ef                	and    $0xef,%al
c0101a96:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101a9b:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101aa2:	0c 60                	or     $0x60,%al
c0101aa4:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101aa9:	0f b6 05 ad ca 11 c0 	movzbl 0xc011caad,%eax
c0101ab0:	0c 80                	or     $0x80,%al
c0101ab2:	a2 ad ca 11 c0       	mov    %al,0xc011caad
c0101ab7:	a1 c4 97 11 c0       	mov    0xc01197c4,%eax
c0101abc:	c1 e8 10             	shr    $0x10,%eax
c0101abf:	0f b7 c0             	movzwl %ax,%eax
c0101ac2:	66 a3 ae ca 11 c0    	mov    %ax,0xc011caae
c0101ac8:	c7 45 f8 60 95 11 c0 	movl   $0xc0119560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
c0101acf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0101ad2:	0f 01 18             	lidtl  (%eax)
}
c0101ad5:	90                   	nop
	// load the IDT
    lidt(&idt_pd);
}
c0101ad6:	90                   	nop
c0101ad7:	89 ec                	mov    %ebp,%esp
c0101ad9:	5d                   	pop    %ebp
c0101ada:	c3                   	ret    

c0101adb <trapname>:

static const char *
trapname(int trapno) {
c0101adb:	55                   	push   %ebp
c0101adc:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
c0101ade:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae1:	83 f8 13             	cmp    $0x13,%eax
c0101ae4:	77 0c                	ja     c0101af2 <trapname+0x17>
        return excnames[trapno];
c0101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ae9:	8b 04 85 00 69 10 c0 	mov    -0x3fef9700(,%eax,4),%eax
c0101af0:	eb 18                	jmp    c0101b0a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
c0101af2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
c0101af6:	7e 0d                	jle    c0101b05 <trapname+0x2a>
c0101af8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
c0101afc:	7f 07                	jg     c0101b05 <trapname+0x2a>
        return "Hardware Interrupt";
c0101afe:	b8 bf 65 10 c0       	mov    $0xc01065bf,%eax
c0101b03:	eb 05                	jmp    c0101b0a <trapname+0x2f>
    }
    return "(unknown trap)";
c0101b05:	b8 d2 65 10 c0       	mov    $0xc01065d2,%eax
}
c0101b0a:	5d                   	pop    %ebp
c0101b0b:	c3                   	ret    

c0101b0c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
c0101b0c:	55                   	push   %ebp
c0101b0d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
c0101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b12:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101b16:	83 f8 08             	cmp    $0x8,%eax
c0101b19:	0f 94 c0             	sete   %al
c0101b1c:	0f b6 c0             	movzbl %al,%eax
}
c0101b1f:	5d                   	pop    %ebp
c0101b20:	c3                   	ret    

c0101b21 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
c0101b21:	55                   	push   %ebp
c0101b22:	89 e5                	mov    %esp,%ebp
c0101b24:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
c0101b27:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b2e:	c7 04 24 13 66 10 c0 	movl   $0xc0106613,(%esp)
c0101b35:	e8 1c e8 ff ff       	call   c0100356 <cprintf>
    print_regs(&tf->tf_regs);
c0101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b3d:	89 04 24             	mov    %eax,(%esp)
c0101b40:	e8 8f 01 00 00       	call   c0101cd4 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
c0101b45:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b48:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
c0101b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b50:	c7 04 24 24 66 10 c0 	movl   $0xc0106624,(%esp)
c0101b57:	e8 fa e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
c0101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b5f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
c0101b63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b67:	c7 04 24 37 66 10 c0 	movl   $0xc0106637,(%esp)
c0101b6e:	e8 e3 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
c0101b73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b76:	0f b7 40 24          	movzwl 0x24(%eax),%eax
c0101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b7e:	c7 04 24 4a 66 10 c0 	movl   $0xc010664a,(%esp)
c0101b85:	e8 cc e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
c0101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0101b8d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
c0101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101b95:	c7 04 24 5d 66 10 c0 	movl   $0xc010665d,(%esp)
c0101b9c:	e8 b5 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
c0101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ba4:	8b 40 30             	mov    0x30(%eax),%eax
c0101ba7:	89 04 24             	mov    %eax,(%esp)
c0101baa:	e8 2c ff ff ff       	call   c0101adb <trapname>
c0101baf:	8b 55 08             	mov    0x8(%ebp),%edx
c0101bb2:	8b 52 30             	mov    0x30(%edx),%edx
c0101bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
c0101bb9:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101bbd:	c7 04 24 70 66 10 c0 	movl   $0xc0106670,(%esp)
c0101bc4:	e8 8d e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
c0101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bcc:	8b 40 34             	mov    0x34(%eax),%eax
c0101bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101bd3:	c7 04 24 82 66 10 c0 	movl   $0xc0106682,(%esp)
c0101bda:	e8 77 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
c0101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
c0101be2:	8b 40 38             	mov    0x38(%eax),%eax
c0101be5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101be9:	c7 04 24 91 66 10 c0 	movl   $0xc0106691,(%esp)
c0101bf0:	e8 61 e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
c0101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
c0101bf8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c00:	c7 04 24 a0 66 10 c0 	movl   $0xc01066a0,(%esp)
c0101c07:	e8 4a e7 ff ff       	call   c0100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
c0101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c0f:	8b 40 40             	mov    0x40(%eax),%eax
c0101c12:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c16:	c7 04 24 b3 66 10 c0 	movl   $0xc01066b3,(%esp)
c0101c1d:	e8 34 e7 ff ff       	call   c0100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0101c29:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
c0101c30:	eb 3d                	jmp    c0101c6f <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
c0101c32:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c35:	8b 50 40             	mov    0x40(%eax),%edx
c0101c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0101c3b:	21 d0                	and    %edx,%eax
c0101c3d:	85 c0                	test   %eax,%eax
c0101c3f:	74 28                	je     c0101c69 <print_trapframe+0x148>
c0101c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c44:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101c4b:	85 c0                	test   %eax,%eax
c0101c4d:	74 1a                	je     c0101c69 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
c0101c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c52:	8b 04 85 80 95 11 c0 	mov    -0x3fee6a80(,%eax,4),%eax
c0101c59:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c5d:	c7 04 24 c2 66 10 c0 	movl   $0xc01066c2,(%esp)
c0101c64:	e8 ed e6 ff ff       	call   c0100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
c0101c69:	ff 45 f4             	incl   -0xc(%ebp)
c0101c6c:	d1 65 f0             	shll   -0x10(%ebp)
c0101c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0101c72:	83 f8 17             	cmp    $0x17,%eax
c0101c75:	76 bb                	jbe    c0101c32 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
c0101c77:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c7a:	8b 40 40             	mov    0x40(%eax),%eax
c0101c7d:	c1 e8 0c             	shr    $0xc,%eax
c0101c80:	83 e0 03             	and    $0x3,%eax
c0101c83:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101c87:	c7 04 24 c6 66 10 c0 	movl   $0xc01066c6,(%esp)
c0101c8e:	e8 c3 e6 ff ff       	call   c0100356 <cprintf>

    if (!trap_in_kernel(tf)) {
c0101c93:	8b 45 08             	mov    0x8(%ebp),%eax
c0101c96:	89 04 24             	mov    %eax,(%esp)
c0101c99:	e8 6e fe ff ff       	call   c0101b0c <trap_in_kernel>
c0101c9e:	85 c0                	test   %eax,%eax
c0101ca0:	75 2d                	jne    c0101ccf <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
c0101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ca5:	8b 40 44             	mov    0x44(%eax),%eax
c0101ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cac:	c7 04 24 cf 66 10 c0 	movl   $0xc01066cf,(%esp)
c0101cb3:	e8 9e e6 ff ff       	call   c0100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
c0101cb8:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cbb:	0f b7 40 48          	movzwl 0x48(%eax),%eax
c0101cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cc3:	c7 04 24 de 66 10 c0 	movl   $0xc01066de,(%esp)
c0101cca:	e8 87 e6 ff ff       	call   c0100356 <cprintf>
    }
}
c0101ccf:	90                   	nop
c0101cd0:	89 ec                	mov    %ebp,%esp
c0101cd2:	5d                   	pop    %ebp
c0101cd3:	c3                   	ret    

c0101cd4 <print_regs>:

void
print_regs(struct pushregs *regs) {
c0101cd4:	55                   	push   %ebp
c0101cd5:	89 e5                	mov    %esp,%ebp
c0101cd7:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
c0101cda:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cdd:	8b 00                	mov    (%eax),%eax
c0101cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101ce3:	c7 04 24 f1 66 10 c0 	movl   $0xc01066f1,(%esp)
c0101cea:	e8 67 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
c0101cef:	8b 45 08             	mov    0x8(%ebp),%eax
c0101cf2:	8b 40 04             	mov    0x4(%eax),%eax
c0101cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101cf9:	c7 04 24 00 67 10 c0 	movl   $0xc0106700,(%esp)
c0101d00:	e8 51 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
c0101d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d08:	8b 40 08             	mov    0x8(%eax),%eax
c0101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d0f:	c7 04 24 0f 67 10 c0 	movl   $0xc010670f,(%esp)
c0101d16:	e8 3b e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
c0101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d1e:	8b 40 0c             	mov    0xc(%eax),%eax
c0101d21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d25:	c7 04 24 1e 67 10 c0 	movl   $0xc010671e,(%esp)
c0101d2c:	e8 25 e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
c0101d31:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d34:	8b 40 10             	mov    0x10(%eax),%eax
c0101d37:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d3b:	c7 04 24 2d 67 10 c0 	movl   $0xc010672d,(%esp)
c0101d42:	e8 0f e6 ff ff       	call   c0100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
c0101d47:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d4a:	8b 40 14             	mov    0x14(%eax),%eax
c0101d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d51:	c7 04 24 3c 67 10 c0 	movl   $0xc010673c,(%esp)
c0101d58:	e8 f9 e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
c0101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d60:	8b 40 18             	mov    0x18(%eax),%eax
c0101d63:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d67:	c7 04 24 4b 67 10 c0 	movl   $0xc010674b,(%esp)
c0101d6e:	e8 e3 e5 ff ff       	call   c0100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
c0101d73:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d76:	8b 40 1c             	mov    0x1c(%eax),%eax
c0101d79:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101d7d:	c7 04 24 5a 67 10 c0 	movl   $0xc010675a,(%esp)
c0101d84:	e8 cd e5 ff ff       	call   c0100356 <cprintf>
}
c0101d89:	90                   	nop
c0101d8a:	89 ec                	mov    %ebp,%esp
c0101d8c:	5d                   	pop    %ebp
c0101d8d:	c3                   	ret    

c0101d8e <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
c0101d8e:	55                   	push   %ebp
c0101d8f:	89 e5                	mov    %esp,%ebp
c0101d91:	83 ec 28             	sub    $0x28,%esp
c0101d94:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
c0101d97:	8b 45 08             	mov    0x8(%ebp),%eax
c0101d9a:	8b 40 30             	mov    0x30(%eax),%eax
c0101d9d:	83 f8 79             	cmp    $0x79,%eax
c0101da0:	0f 84 6c 01 00 00    	je     c0101f12 <trap_dispatch+0x184>
c0101da6:	83 f8 79             	cmp    $0x79,%eax
c0101da9:	0f 87 e0 01 00 00    	ja     c0101f8f <trap_dispatch+0x201>
c0101daf:	83 f8 78             	cmp    $0x78,%eax
c0101db2:	0f 84 d0 00 00 00    	je     c0101e88 <trap_dispatch+0xfa>
c0101db8:	83 f8 78             	cmp    $0x78,%eax
c0101dbb:	0f 87 ce 01 00 00    	ja     c0101f8f <trap_dispatch+0x201>
c0101dc1:	83 f8 2f             	cmp    $0x2f,%eax
c0101dc4:	0f 87 c5 01 00 00    	ja     c0101f8f <trap_dispatch+0x201>
c0101dca:	83 f8 2e             	cmp    $0x2e,%eax
c0101dcd:	0f 83 f1 01 00 00    	jae    c0101fc4 <trap_dispatch+0x236>
c0101dd3:	83 f8 24             	cmp    $0x24,%eax
c0101dd6:	74 5e                	je     c0101e36 <trap_dispatch+0xa8>
c0101dd8:	83 f8 24             	cmp    $0x24,%eax
c0101ddb:	0f 87 ae 01 00 00    	ja     c0101f8f <trap_dispatch+0x201>
c0101de1:	83 f8 20             	cmp    $0x20,%eax
c0101de4:	74 0a                	je     c0101df0 <trap_dispatch+0x62>
c0101de6:	83 f8 21             	cmp    $0x21,%eax
c0101de9:	74 74                	je     c0101e5f <trap_dispatch+0xd1>
c0101deb:	e9 9f 01 00 00       	jmp    c0101f8f <trap_dispatch+0x201>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
c0101df0:	a1 24 c4 11 c0       	mov    0xc011c424,%eax
c0101df5:	40                   	inc    %eax
c0101df6:	a3 24 c4 11 c0       	mov    %eax,0xc011c424
        if (ticks % TICK_NUM == 0) {
c0101dfb:	8b 0d 24 c4 11 c0    	mov    0xc011c424,%ecx
c0101e01:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
c0101e06:	89 c8                	mov    %ecx,%eax
c0101e08:	f7 e2                	mul    %edx
c0101e0a:	c1 ea 05             	shr    $0x5,%edx
c0101e0d:	89 d0                	mov    %edx,%eax
c0101e0f:	c1 e0 02             	shl    $0x2,%eax
c0101e12:	01 d0                	add    %edx,%eax
c0101e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0101e1b:	01 d0                	add    %edx,%eax
c0101e1d:	c1 e0 02             	shl    $0x2,%eax
c0101e20:	29 c1                	sub    %eax,%ecx
c0101e22:	89 ca                	mov    %ecx,%edx
c0101e24:	85 d2                	test   %edx,%edx
c0101e26:	0f 85 9b 01 00 00    	jne    c0101fc7 <trap_dispatch+0x239>
            print_ticks();
c0101e2c:	e8 f3 fa ff ff       	call   c0101924 <print_ticks>
        }
        break;
c0101e31:	e9 91 01 00 00       	jmp    c0101fc7 <trap_dispatch+0x239>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
c0101e36:	e8 8c f8 ff ff       	call   c01016c7 <cons_getc>
c0101e3b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
c0101e3e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e42:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e46:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e4e:	c7 04 24 69 67 10 c0 	movl   $0xc0106769,(%esp)
c0101e55:	e8 fc e4 ff ff       	call   c0100356 <cprintf>
        break;
c0101e5a:	e9 6f 01 00 00       	jmp    c0101fce <trap_dispatch+0x240>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
c0101e5f:	e8 63 f8 ff ff       	call   c01016c7 <cons_getc>
c0101e64:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
c0101e67:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
c0101e6b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
c0101e6f:	89 54 24 08          	mov    %edx,0x8(%esp)
c0101e73:	89 44 24 04          	mov    %eax,0x4(%esp)
c0101e77:	c7 04 24 7b 67 10 c0 	movl   $0xc010677b,(%esp)
c0101e7e:	e8 d3 e4 ff ff       	call   c0100356 <cprintf>
        break;
c0101e83:	e9 46 01 00 00       	jmp    c0101fce <trap_dispatch+0x240>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
c0101e88:	8b 45 08             	mov    0x8(%ebp),%eax
c0101e8b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101e8f:	83 f8 1b             	cmp    $0x1b,%eax
c0101e92:	0f 84 32 01 00 00    	je     c0101fca <trap_dispatch+0x23c>
            switchk2u = *tf;
c0101e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
c0101e9b:	b8 4c 00 00 00       	mov    $0x4c,%eax
c0101ea0:	83 e0 fc             	and    $0xfffffffc,%eax
c0101ea3:	89 c3                	mov    %eax,%ebx
c0101ea5:	b8 00 00 00 00       	mov    $0x0,%eax
c0101eaa:	8b 14 01             	mov    (%ecx,%eax,1),%edx
c0101ead:	89 90 80 c6 11 c0    	mov    %edx,-0x3fee3980(%eax)
c0101eb3:	83 c0 04             	add    $0x4,%eax
c0101eb6:	39 d8                	cmp    %ebx,%eax
c0101eb8:	72 f0                	jb     c0101eaa <trap_dispatch+0x11c>
            switchk2u.tf_cs = USER_CS;
c0101eba:	66 c7 05 bc c6 11 c0 	movw   $0x1b,0xc011c6bc
c0101ec1:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
c0101ec3:	66 c7 05 c8 c6 11 c0 	movw   $0x23,0xc011c6c8
c0101eca:	23 00 
c0101ecc:	0f b7 05 c8 c6 11 c0 	movzwl 0xc011c6c8,%eax
c0101ed3:	66 a3 a8 c6 11 c0    	mov    %ax,0xc011c6a8
c0101ed9:	0f b7 05 a8 c6 11 c0 	movzwl 0xc011c6a8,%eax
c0101ee0:	66 a3 ac c6 11 c0    	mov    %ax,0xc011c6ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
c0101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
c0101ee9:	83 c0 44             	add    $0x44,%eax
c0101eec:	a3 c4 c6 11 c0       	mov    %eax,0xc011c6c4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
c0101ef1:	a1 c0 c6 11 c0       	mov    0xc011c6c0,%eax
c0101ef6:	0d 00 30 00 00       	or     $0x3000,%eax
c0101efb:	a3 c0 c6 11 c0       	mov    %eax,0xc011c6c0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
c0101f00:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f03:	83 e8 04             	sub    $0x4,%eax
c0101f06:	ba 80 c6 11 c0       	mov    $0xc011c680,%edx
c0101f0b:	89 10                	mov    %edx,(%eax)
        }
        break;
c0101f0d:	e9 b8 00 00 00       	jmp    c0101fca <trap_dispatch+0x23c>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
c0101f12:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f15:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f19:	83 f8 08             	cmp    $0x8,%eax
c0101f1c:	0f 84 ab 00 00 00    	je     c0101fcd <trap_dispatch+0x23f>
            tf->tf_cs = KERNEL_CS;
c0101f22:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f25:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
c0101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f2e:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
c0101f34:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f37:	0f b7 50 28          	movzwl 0x28(%eax),%edx
c0101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f3e:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
c0101f42:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f45:	8b 40 40             	mov    0x40(%eax),%eax
c0101f48:	25 ff cf ff ff       	and    $0xffffcfff,%eax
c0101f4d:	89 c2                	mov    %eax,%edx
c0101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f52:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
c0101f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f58:	8b 40 44             	mov    0x44(%eax),%eax
c0101f5b:	83 e8 44             	sub    $0x44,%eax
c0101f5e:	a3 cc c6 11 c0       	mov    %eax,0xc011c6cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
c0101f63:	a1 cc c6 11 c0       	mov    0xc011c6cc,%eax
c0101f68:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
c0101f6f:	00 
c0101f70:	8b 55 08             	mov    0x8(%ebp),%edx
c0101f73:	89 54 24 04          	mov    %edx,0x4(%esp)
c0101f77:	89 04 24             	mov    %eax,(%esp)
c0101f7a:	e8 34 41 00 00       	call   c01060b3 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
c0101f7f:	8b 15 cc c6 11 c0    	mov    0xc011c6cc,%edx
c0101f85:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f88:	83 e8 04             	sub    $0x4,%eax
c0101f8b:	89 10                	mov    %edx,(%eax)
        }
        break;
c0101f8d:	eb 3e                	jmp    c0101fcd <trap_dispatch+0x23f>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
c0101f8f:	8b 45 08             	mov    0x8(%ebp),%eax
c0101f92:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
c0101f96:	83 e0 03             	and    $0x3,%eax
c0101f99:	85 c0                	test   %eax,%eax
c0101f9b:	75 31                	jne    c0101fce <trap_dispatch+0x240>
            print_trapframe(tf);
c0101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fa0:	89 04 24             	mov    %eax,(%esp)
c0101fa3:	e8 79 fb ff ff       	call   c0101b21 <print_trapframe>
            panic("unexpected trap in kernel.\n");
c0101fa8:	c7 44 24 08 8a 67 10 	movl   $0xc010678a,0x8(%esp)
c0101faf:	c0 
c0101fb0:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
c0101fb7:	00 
c0101fb8:	c7 04 24 ae 65 10 c0 	movl   $0xc01065ae,(%esp)
c0101fbf:	e8 23 ed ff ff       	call   c0100ce7 <__panic>
        break;
c0101fc4:	90                   	nop
c0101fc5:	eb 07                	jmp    c0101fce <trap_dispatch+0x240>
        break;
c0101fc7:	90                   	nop
c0101fc8:	eb 04                	jmp    c0101fce <trap_dispatch+0x240>
        break;
c0101fca:	90                   	nop
c0101fcb:	eb 01                	jmp    c0101fce <trap_dispatch+0x240>
        break;
c0101fcd:	90                   	nop
        }
    }
}
c0101fce:	90                   	nop
c0101fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
c0101fd2:	89 ec                	mov    %ebp,%esp
c0101fd4:	5d                   	pop    %ebp
c0101fd5:	c3                   	ret    

c0101fd6 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
c0101fd6:	55                   	push   %ebp
c0101fd7:	89 e5                	mov    %esp,%ebp
c0101fd9:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
c0101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
c0101fdf:	89 04 24             	mov    %eax,(%esp)
c0101fe2:	e8 a7 fd ff ff       	call   c0101d8e <trap_dispatch>
}
c0101fe7:	90                   	nop
c0101fe8:	89 ec                	mov    %ebp,%esp
c0101fea:	5d                   	pop    %ebp
c0101feb:	c3                   	ret    

c0101fec <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
c0101fec:	1e                   	push   %ds
    pushl %es
c0101fed:	06                   	push   %es
    pushl %fs
c0101fee:	0f a0                	push   %fs
    pushl %gs
c0101ff0:	0f a8                	push   %gs
    pushal
c0101ff2:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
c0101ff3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
c0101ff8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
c0101ffa:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
c0101ffc:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
c0101ffd:	e8 d4 ff ff ff       	call   c0101fd6 <trap>

    # pop the pushed stack pointer
    popl %esp
c0102002:	5c                   	pop    %esp

c0102003 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
c0102003:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
c0102004:	0f a9                	pop    %gs
    popl %fs
c0102006:	0f a1                	pop    %fs
    popl %es
c0102008:	07                   	pop    %es
    popl %ds
c0102009:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
c010200a:	83 c4 08             	add    $0x8,%esp
    iret
c010200d:	cf                   	iret   

c010200e <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
c010200e:	6a 00                	push   $0x0
  pushl $0
c0102010:	6a 00                	push   $0x0
  jmp __alltraps
c0102012:	e9 d5 ff ff ff       	jmp    c0101fec <__alltraps>

c0102017 <vector1>:
.globl vector1
vector1:
  pushl $0
c0102017:	6a 00                	push   $0x0
  pushl $1
c0102019:	6a 01                	push   $0x1
  jmp __alltraps
c010201b:	e9 cc ff ff ff       	jmp    c0101fec <__alltraps>

c0102020 <vector2>:
.globl vector2
vector2:
  pushl $0
c0102020:	6a 00                	push   $0x0
  pushl $2
c0102022:	6a 02                	push   $0x2
  jmp __alltraps
c0102024:	e9 c3 ff ff ff       	jmp    c0101fec <__alltraps>

c0102029 <vector3>:
.globl vector3
vector3:
  pushl $0
c0102029:	6a 00                	push   $0x0
  pushl $3
c010202b:	6a 03                	push   $0x3
  jmp __alltraps
c010202d:	e9 ba ff ff ff       	jmp    c0101fec <__alltraps>

c0102032 <vector4>:
.globl vector4
vector4:
  pushl $0
c0102032:	6a 00                	push   $0x0
  pushl $4
c0102034:	6a 04                	push   $0x4
  jmp __alltraps
c0102036:	e9 b1 ff ff ff       	jmp    c0101fec <__alltraps>

c010203b <vector5>:
.globl vector5
vector5:
  pushl $0
c010203b:	6a 00                	push   $0x0
  pushl $5
c010203d:	6a 05                	push   $0x5
  jmp __alltraps
c010203f:	e9 a8 ff ff ff       	jmp    c0101fec <__alltraps>

c0102044 <vector6>:
.globl vector6
vector6:
  pushl $0
c0102044:	6a 00                	push   $0x0
  pushl $6
c0102046:	6a 06                	push   $0x6
  jmp __alltraps
c0102048:	e9 9f ff ff ff       	jmp    c0101fec <__alltraps>

c010204d <vector7>:
.globl vector7
vector7:
  pushl $0
c010204d:	6a 00                	push   $0x0
  pushl $7
c010204f:	6a 07                	push   $0x7
  jmp __alltraps
c0102051:	e9 96 ff ff ff       	jmp    c0101fec <__alltraps>

c0102056 <vector8>:
.globl vector8
vector8:
  pushl $8
c0102056:	6a 08                	push   $0x8
  jmp __alltraps
c0102058:	e9 8f ff ff ff       	jmp    c0101fec <__alltraps>

c010205d <vector9>:
.globl vector9
vector9:
  pushl $0
c010205d:	6a 00                	push   $0x0
  pushl $9
c010205f:	6a 09                	push   $0x9
  jmp __alltraps
c0102061:	e9 86 ff ff ff       	jmp    c0101fec <__alltraps>

c0102066 <vector10>:
.globl vector10
vector10:
  pushl $10
c0102066:	6a 0a                	push   $0xa
  jmp __alltraps
c0102068:	e9 7f ff ff ff       	jmp    c0101fec <__alltraps>

c010206d <vector11>:
.globl vector11
vector11:
  pushl $11
c010206d:	6a 0b                	push   $0xb
  jmp __alltraps
c010206f:	e9 78 ff ff ff       	jmp    c0101fec <__alltraps>

c0102074 <vector12>:
.globl vector12
vector12:
  pushl $12
c0102074:	6a 0c                	push   $0xc
  jmp __alltraps
c0102076:	e9 71 ff ff ff       	jmp    c0101fec <__alltraps>

c010207b <vector13>:
.globl vector13
vector13:
  pushl $13
c010207b:	6a 0d                	push   $0xd
  jmp __alltraps
c010207d:	e9 6a ff ff ff       	jmp    c0101fec <__alltraps>

c0102082 <vector14>:
.globl vector14
vector14:
  pushl $14
c0102082:	6a 0e                	push   $0xe
  jmp __alltraps
c0102084:	e9 63 ff ff ff       	jmp    c0101fec <__alltraps>

c0102089 <vector15>:
.globl vector15
vector15:
  pushl $0
c0102089:	6a 00                	push   $0x0
  pushl $15
c010208b:	6a 0f                	push   $0xf
  jmp __alltraps
c010208d:	e9 5a ff ff ff       	jmp    c0101fec <__alltraps>

c0102092 <vector16>:
.globl vector16
vector16:
  pushl $0
c0102092:	6a 00                	push   $0x0
  pushl $16
c0102094:	6a 10                	push   $0x10
  jmp __alltraps
c0102096:	e9 51 ff ff ff       	jmp    c0101fec <__alltraps>

c010209b <vector17>:
.globl vector17
vector17:
  pushl $17
c010209b:	6a 11                	push   $0x11
  jmp __alltraps
c010209d:	e9 4a ff ff ff       	jmp    c0101fec <__alltraps>

c01020a2 <vector18>:
.globl vector18
vector18:
  pushl $0
c01020a2:	6a 00                	push   $0x0
  pushl $18
c01020a4:	6a 12                	push   $0x12
  jmp __alltraps
c01020a6:	e9 41 ff ff ff       	jmp    c0101fec <__alltraps>

c01020ab <vector19>:
.globl vector19
vector19:
  pushl $0
c01020ab:	6a 00                	push   $0x0
  pushl $19
c01020ad:	6a 13                	push   $0x13
  jmp __alltraps
c01020af:	e9 38 ff ff ff       	jmp    c0101fec <__alltraps>

c01020b4 <vector20>:
.globl vector20
vector20:
  pushl $0
c01020b4:	6a 00                	push   $0x0
  pushl $20
c01020b6:	6a 14                	push   $0x14
  jmp __alltraps
c01020b8:	e9 2f ff ff ff       	jmp    c0101fec <__alltraps>

c01020bd <vector21>:
.globl vector21
vector21:
  pushl $0
c01020bd:	6a 00                	push   $0x0
  pushl $21
c01020bf:	6a 15                	push   $0x15
  jmp __alltraps
c01020c1:	e9 26 ff ff ff       	jmp    c0101fec <__alltraps>

c01020c6 <vector22>:
.globl vector22
vector22:
  pushl $0
c01020c6:	6a 00                	push   $0x0
  pushl $22
c01020c8:	6a 16                	push   $0x16
  jmp __alltraps
c01020ca:	e9 1d ff ff ff       	jmp    c0101fec <__alltraps>

c01020cf <vector23>:
.globl vector23
vector23:
  pushl $0
c01020cf:	6a 00                	push   $0x0
  pushl $23
c01020d1:	6a 17                	push   $0x17
  jmp __alltraps
c01020d3:	e9 14 ff ff ff       	jmp    c0101fec <__alltraps>

c01020d8 <vector24>:
.globl vector24
vector24:
  pushl $0
c01020d8:	6a 00                	push   $0x0
  pushl $24
c01020da:	6a 18                	push   $0x18
  jmp __alltraps
c01020dc:	e9 0b ff ff ff       	jmp    c0101fec <__alltraps>

c01020e1 <vector25>:
.globl vector25
vector25:
  pushl $0
c01020e1:	6a 00                	push   $0x0
  pushl $25
c01020e3:	6a 19                	push   $0x19
  jmp __alltraps
c01020e5:	e9 02 ff ff ff       	jmp    c0101fec <__alltraps>

c01020ea <vector26>:
.globl vector26
vector26:
  pushl $0
c01020ea:	6a 00                	push   $0x0
  pushl $26
c01020ec:	6a 1a                	push   $0x1a
  jmp __alltraps
c01020ee:	e9 f9 fe ff ff       	jmp    c0101fec <__alltraps>

c01020f3 <vector27>:
.globl vector27
vector27:
  pushl $0
c01020f3:	6a 00                	push   $0x0
  pushl $27
c01020f5:	6a 1b                	push   $0x1b
  jmp __alltraps
c01020f7:	e9 f0 fe ff ff       	jmp    c0101fec <__alltraps>

c01020fc <vector28>:
.globl vector28
vector28:
  pushl $0
c01020fc:	6a 00                	push   $0x0
  pushl $28
c01020fe:	6a 1c                	push   $0x1c
  jmp __alltraps
c0102100:	e9 e7 fe ff ff       	jmp    c0101fec <__alltraps>

c0102105 <vector29>:
.globl vector29
vector29:
  pushl $0
c0102105:	6a 00                	push   $0x0
  pushl $29
c0102107:	6a 1d                	push   $0x1d
  jmp __alltraps
c0102109:	e9 de fe ff ff       	jmp    c0101fec <__alltraps>

c010210e <vector30>:
.globl vector30
vector30:
  pushl $0
c010210e:	6a 00                	push   $0x0
  pushl $30
c0102110:	6a 1e                	push   $0x1e
  jmp __alltraps
c0102112:	e9 d5 fe ff ff       	jmp    c0101fec <__alltraps>

c0102117 <vector31>:
.globl vector31
vector31:
  pushl $0
c0102117:	6a 00                	push   $0x0
  pushl $31
c0102119:	6a 1f                	push   $0x1f
  jmp __alltraps
c010211b:	e9 cc fe ff ff       	jmp    c0101fec <__alltraps>

c0102120 <vector32>:
.globl vector32
vector32:
  pushl $0
c0102120:	6a 00                	push   $0x0
  pushl $32
c0102122:	6a 20                	push   $0x20
  jmp __alltraps
c0102124:	e9 c3 fe ff ff       	jmp    c0101fec <__alltraps>

c0102129 <vector33>:
.globl vector33
vector33:
  pushl $0
c0102129:	6a 00                	push   $0x0
  pushl $33
c010212b:	6a 21                	push   $0x21
  jmp __alltraps
c010212d:	e9 ba fe ff ff       	jmp    c0101fec <__alltraps>

c0102132 <vector34>:
.globl vector34
vector34:
  pushl $0
c0102132:	6a 00                	push   $0x0
  pushl $34
c0102134:	6a 22                	push   $0x22
  jmp __alltraps
c0102136:	e9 b1 fe ff ff       	jmp    c0101fec <__alltraps>

c010213b <vector35>:
.globl vector35
vector35:
  pushl $0
c010213b:	6a 00                	push   $0x0
  pushl $35
c010213d:	6a 23                	push   $0x23
  jmp __alltraps
c010213f:	e9 a8 fe ff ff       	jmp    c0101fec <__alltraps>

c0102144 <vector36>:
.globl vector36
vector36:
  pushl $0
c0102144:	6a 00                	push   $0x0
  pushl $36
c0102146:	6a 24                	push   $0x24
  jmp __alltraps
c0102148:	e9 9f fe ff ff       	jmp    c0101fec <__alltraps>

c010214d <vector37>:
.globl vector37
vector37:
  pushl $0
c010214d:	6a 00                	push   $0x0
  pushl $37
c010214f:	6a 25                	push   $0x25
  jmp __alltraps
c0102151:	e9 96 fe ff ff       	jmp    c0101fec <__alltraps>

c0102156 <vector38>:
.globl vector38
vector38:
  pushl $0
c0102156:	6a 00                	push   $0x0
  pushl $38
c0102158:	6a 26                	push   $0x26
  jmp __alltraps
c010215a:	e9 8d fe ff ff       	jmp    c0101fec <__alltraps>

c010215f <vector39>:
.globl vector39
vector39:
  pushl $0
c010215f:	6a 00                	push   $0x0
  pushl $39
c0102161:	6a 27                	push   $0x27
  jmp __alltraps
c0102163:	e9 84 fe ff ff       	jmp    c0101fec <__alltraps>

c0102168 <vector40>:
.globl vector40
vector40:
  pushl $0
c0102168:	6a 00                	push   $0x0
  pushl $40
c010216a:	6a 28                	push   $0x28
  jmp __alltraps
c010216c:	e9 7b fe ff ff       	jmp    c0101fec <__alltraps>

c0102171 <vector41>:
.globl vector41
vector41:
  pushl $0
c0102171:	6a 00                	push   $0x0
  pushl $41
c0102173:	6a 29                	push   $0x29
  jmp __alltraps
c0102175:	e9 72 fe ff ff       	jmp    c0101fec <__alltraps>

c010217a <vector42>:
.globl vector42
vector42:
  pushl $0
c010217a:	6a 00                	push   $0x0
  pushl $42
c010217c:	6a 2a                	push   $0x2a
  jmp __alltraps
c010217e:	e9 69 fe ff ff       	jmp    c0101fec <__alltraps>

c0102183 <vector43>:
.globl vector43
vector43:
  pushl $0
c0102183:	6a 00                	push   $0x0
  pushl $43
c0102185:	6a 2b                	push   $0x2b
  jmp __alltraps
c0102187:	e9 60 fe ff ff       	jmp    c0101fec <__alltraps>

c010218c <vector44>:
.globl vector44
vector44:
  pushl $0
c010218c:	6a 00                	push   $0x0
  pushl $44
c010218e:	6a 2c                	push   $0x2c
  jmp __alltraps
c0102190:	e9 57 fe ff ff       	jmp    c0101fec <__alltraps>

c0102195 <vector45>:
.globl vector45
vector45:
  pushl $0
c0102195:	6a 00                	push   $0x0
  pushl $45
c0102197:	6a 2d                	push   $0x2d
  jmp __alltraps
c0102199:	e9 4e fe ff ff       	jmp    c0101fec <__alltraps>

c010219e <vector46>:
.globl vector46
vector46:
  pushl $0
c010219e:	6a 00                	push   $0x0
  pushl $46
c01021a0:	6a 2e                	push   $0x2e
  jmp __alltraps
c01021a2:	e9 45 fe ff ff       	jmp    c0101fec <__alltraps>

c01021a7 <vector47>:
.globl vector47
vector47:
  pushl $0
c01021a7:	6a 00                	push   $0x0
  pushl $47
c01021a9:	6a 2f                	push   $0x2f
  jmp __alltraps
c01021ab:	e9 3c fe ff ff       	jmp    c0101fec <__alltraps>

c01021b0 <vector48>:
.globl vector48
vector48:
  pushl $0
c01021b0:	6a 00                	push   $0x0
  pushl $48
c01021b2:	6a 30                	push   $0x30
  jmp __alltraps
c01021b4:	e9 33 fe ff ff       	jmp    c0101fec <__alltraps>

c01021b9 <vector49>:
.globl vector49
vector49:
  pushl $0
c01021b9:	6a 00                	push   $0x0
  pushl $49
c01021bb:	6a 31                	push   $0x31
  jmp __alltraps
c01021bd:	e9 2a fe ff ff       	jmp    c0101fec <__alltraps>

c01021c2 <vector50>:
.globl vector50
vector50:
  pushl $0
c01021c2:	6a 00                	push   $0x0
  pushl $50
c01021c4:	6a 32                	push   $0x32
  jmp __alltraps
c01021c6:	e9 21 fe ff ff       	jmp    c0101fec <__alltraps>

c01021cb <vector51>:
.globl vector51
vector51:
  pushl $0
c01021cb:	6a 00                	push   $0x0
  pushl $51
c01021cd:	6a 33                	push   $0x33
  jmp __alltraps
c01021cf:	e9 18 fe ff ff       	jmp    c0101fec <__alltraps>

c01021d4 <vector52>:
.globl vector52
vector52:
  pushl $0
c01021d4:	6a 00                	push   $0x0
  pushl $52
c01021d6:	6a 34                	push   $0x34
  jmp __alltraps
c01021d8:	e9 0f fe ff ff       	jmp    c0101fec <__alltraps>

c01021dd <vector53>:
.globl vector53
vector53:
  pushl $0
c01021dd:	6a 00                	push   $0x0
  pushl $53
c01021df:	6a 35                	push   $0x35
  jmp __alltraps
c01021e1:	e9 06 fe ff ff       	jmp    c0101fec <__alltraps>

c01021e6 <vector54>:
.globl vector54
vector54:
  pushl $0
c01021e6:	6a 00                	push   $0x0
  pushl $54
c01021e8:	6a 36                	push   $0x36
  jmp __alltraps
c01021ea:	e9 fd fd ff ff       	jmp    c0101fec <__alltraps>

c01021ef <vector55>:
.globl vector55
vector55:
  pushl $0
c01021ef:	6a 00                	push   $0x0
  pushl $55
c01021f1:	6a 37                	push   $0x37
  jmp __alltraps
c01021f3:	e9 f4 fd ff ff       	jmp    c0101fec <__alltraps>

c01021f8 <vector56>:
.globl vector56
vector56:
  pushl $0
c01021f8:	6a 00                	push   $0x0
  pushl $56
c01021fa:	6a 38                	push   $0x38
  jmp __alltraps
c01021fc:	e9 eb fd ff ff       	jmp    c0101fec <__alltraps>

c0102201 <vector57>:
.globl vector57
vector57:
  pushl $0
c0102201:	6a 00                	push   $0x0
  pushl $57
c0102203:	6a 39                	push   $0x39
  jmp __alltraps
c0102205:	e9 e2 fd ff ff       	jmp    c0101fec <__alltraps>

c010220a <vector58>:
.globl vector58
vector58:
  pushl $0
c010220a:	6a 00                	push   $0x0
  pushl $58
c010220c:	6a 3a                	push   $0x3a
  jmp __alltraps
c010220e:	e9 d9 fd ff ff       	jmp    c0101fec <__alltraps>

c0102213 <vector59>:
.globl vector59
vector59:
  pushl $0
c0102213:	6a 00                	push   $0x0
  pushl $59
c0102215:	6a 3b                	push   $0x3b
  jmp __alltraps
c0102217:	e9 d0 fd ff ff       	jmp    c0101fec <__alltraps>

c010221c <vector60>:
.globl vector60
vector60:
  pushl $0
c010221c:	6a 00                	push   $0x0
  pushl $60
c010221e:	6a 3c                	push   $0x3c
  jmp __alltraps
c0102220:	e9 c7 fd ff ff       	jmp    c0101fec <__alltraps>

c0102225 <vector61>:
.globl vector61
vector61:
  pushl $0
c0102225:	6a 00                	push   $0x0
  pushl $61
c0102227:	6a 3d                	push   $0x3d
  jmp __alltraps
c0102229:	e9 be fd ff ff       	jmp    c0101fec <__alltraps>

c010222e <vector62>:
.globl vector62
vector62:
  pushl $0
c010222e:	6a 00                	push   $0x0
  pushl $62
c0102230:	6a 3e                	push   $0x3e
  jmp __alltraps
c0102232:	e9 b5 fd ff ff       	jmp    c0101fec <__alltraps>

c0102237 <vector63>:
.globl vector63
vector63:
  pushl $0
c0102237:	6a 00                	push   $0x0
  pushl $63
c0102239:	6a 3f                	push   $0x3f
  jmp __alltraps
c010223b:	e9 ac fd ff ff       	jmp    c0101fec <__alltraps>

c0102240 <vector64>:
.globl vector64
vector64:
  pushl $0
c0102240:	6a 00                	push   $0x0
  pushl $64
c0102242:	6a 40                	push   $0x40
  jmp __alltraps
c0102244:	e9 a3 fd ff ff       	jmp    c0101fec <__alltraps>

c0102249 <vector65>:
.globl vector65
vector65:
  pushl $0
c0102249:	6a 00                	push   $0x0
  pushl $65
c010224b:	6a 41                	push   $0x41
  jmp __alltraps
c010224d:	e9 9a fd ff ff       	jmp    c0101fec <__alltraps>

c0102252 <vector66>:
.globl vector66
vector66:
  pushl $0
c0102252:	6a 00                	push   $0x0
  pushl $66
c0102254:	6a 42                	push   $0x42
  jmp __alltraps
c0102256:	e9 91 fd ff ff       	jmp    c0101fec <__alltraps>

c010225b <vector67>:
.globl vector67
vector67:
  pushl $0
c010225b:	6a 00                	push   $0x0
  pushl $67
c010225d:	6a 43                	push   $0x43
  jmp __alltraps
c010225f:	e9 88 fd ff ff       	jmp    c0101fec <__alltraps>

c0102264 <vector68>:
.globl vector68
vector68:
  pushl $0
c0102264:	6a 00                	push   $0x0
  pushl $68
c0102266:	6a 44                	push   $0x44
  jmp __alltraps
c0102268:	e9 7f fd ff ff       	jmp    c0101fec <__alltraps>

c010226d <vector69>:
.globl vector69
vector69:
  pushl $0
c010226d:	6a 00                	push   $0x0
  pushl $69
c010226f:	6a 45                	push   $0x45
  jmp __alltraps
c0102271:	e9 76 fd ff ff       	jmp    c0101fec <__alltraps>

c0102276 <vector70>:
.globl vector70
vector70:
  pushl $0
c0102276:	6a 00                	push   $0x0
  pushl $70
c0102278:	6a 46                	push   $0x46
  jmp __alltraps
c010227a:	e9 6d fd ff ff       	jmp    c0101fec <__alltraps>

c010227f <vector71>:
.globl vector71
vector71:
  pushl $0
c010227f:	6a 00                	push   $0x0
  pushl $71
c0102281:	6a 47                	push   $0x47
  jmp __alltraps
c0102283:	e9 64 fd ff ff       	jmp    c0101fec <__alltraps>

c0102288 <vector72>:
.globl vector72
vector72:
  pushl $0
c0102288:	6a 00                	push   $0x0
  pushl $72
c010228a:	6a 48                	push   $0x48
  jmp __alltraps
c010228c:	e9 5b fd ff ff       	jmp    c0101fec <__alltraps>

c0102291 <vector73>:
.globl vector73
vector73:
  pushl $0
c0102291:	6a 00                	push   $0x0
  pushl $73
c0102293:	6a 49                	push   $0x49
  jmp __alltraps
c0102295:	e9 52 fd ff ff       	jmp    c0101fec <__alltraps>

c010229a <vector74>:
.globl vector74
vector74:
  pushl $0
c010229a:	6a 00                	push   $0x0
  pushl $74
c010229c:	6a 4a                	push   $0x4a
  jmp __alltraps
c010229e:	e9 49 fd ff ff       	jmp    c0101fec <__alltraps>

c01022a3 <vector75>:
.globl vector75
vector75:
  pushl $0
c01022a3:	6a 00                	push   $0x0
  pushl $75
c01022a5:	6a 4b                	push   $0x4b
  jmp __alltraps
c01022a7:	e9 40 fd ff ff       	jmp    c0101fec <__alltraps>

c01022ac <vector76>:
.globl vector76
vector76:
  pushl $0
c01022ac:	6a 00                	push   $0x0
  pushl $76
c01022ae:	6a 4c                	push   $0x4c
  jmp __alltraps
c01022b0:	e9 37 fd ff ff       	jmp    c0101fec <__alltraps>

c01022b5 <vector77>:
.globl vector77
vector77:
  pushl $0
c01022b5:	6a 00                	push   $0x0
  pushl $77
c01022b7:	6a 4d                	push   $0x4d
  jmp __alltraps
c01022b9:	e9 2e fd ff ff       	jmp    c0101fec <__alltraps>

c01022be <vector78>:
.globl vector78
vector78:
  pushl $0
c01022be:	6a 00                	push   $0x0
  pushl $78
c01022c0:	6a 4e                	push   $0x4e
  jmp __alltraps
c01022c2:	e9 25 fd ff ff       	jmp    c0101fec <__alltraps>

c01022c7 <vector79>:
.globl vector79
vector79:
  pushl $0
c01022c7:	6a 00                	push   $0x0
  pushl $79
c01022c9:	6a 4f                	push   $0x4f
  jmp __alltraps
c01022cb:	e9 1c fd ff ff       	jmp    c0101fec <__alltraps>

c01022d0 <vector80>:
.globl vector80
vector80:
  pushl $0
c01022d0:	6a 00                	push   $0x0
  pushl $80
c01022d2:	6a 50                	push   $0x50
  jmp __alltraps
c01022d4:	e9 13 fd ff ff       	jmp    c0101fec <__alltraps>

c01022d9 <vector81>:
.globl vector81
vector81:
  pushl $0
c01022d9:	6a 00                	push   $0x0
  pushl $81
c01022db:	6a 51                	push   $0x51
  jmp __alltraps
c01022dd:	e9 0a fd ff ff       	jmp    c0101fec <__alltraps>

c01022e2 <vector82>:
.globl vector82
vector82:
  pushl $0
c01022e2:	6a 00                	push   $0x0
  pushl $82
c01022e4:	6a 52                	push   $0x52
  jmp __alltraps
c01022e6:	e9 01 fd ff ff       	jmp    c0101fec <__alltraps>

c01022eb <vector83>:
.globl vector83
vector83:
  pushl $0
c01022eb:	6a 00                	push   $0x0
  pushl $83
c01022ed:	6a 53                	push   $0x53
  jmp __alltraps
c01022ef:	e9 f8 fc ff ff       	jmp    c0101fec <__alltraps>

c01022f4 <vector84>:
.globl vector84
vector84:
  pushl $0
c01022f4:	6a 00                	push   $0x0
  pushl $84
c01022f6:	6a 54                	push   $0x54
  jmp __alltraps
c01022f8:	e9 ef fc ff ff       	jmp    c0101fec <__alltraps>

c01022fd <vector85>:
.globl vector85
vector85:
  pushl $0
c01022fd:	6a 00                	push   $0x0
  pushl $85
c01022ff:	6a 55                	push   $0x55
  jmp __alltraps
c0102301:	e9 e6 fc ff ff       	jmp    c0101fec <__alltraps>

c0102306 <vector86>:
.globl vector86
vector86:
  pushl $0
c0102306:	6a 00                	push   $0x0
  pushl $86
c0102308:	6a 56                	push   $0x56
  jmp __alltraps
c010230a:	e9 dd fc ff ff       	jmp    c0101fec <__alltraps>

c010230f <vector87>:
.globl vector87
vector87:
  pushl $0
c010230f:	6a 00                	push   $0x0
  pushl $87
c0102311:	6a 57                	push   $0x57
  jmp __alltraps
c0102313:	e9 d4 fc ff ff       	jmp    c0101fec <__alltraps>

c0102318 <vector88>:
.globl vector88
vector88:
  pushl $0
c0102318:	6a 00                	push   $0x0
  pushl $88
c010231a:	6a 58                	push   $0x58
  jmp __alltraps
c010231c:	e9 cb fc ff ff       	jmp    c0101fec <__alltraps>

c0102321 <vector89>:
.globl vector89
vector89:
  pushl $0
c0102321:	6a 00                	push   $0x0
  pushl $89
c0102323:	6a 59                	push   $0x59
  jmp __alltraps
c0102325:	e9 c2 fc ff ff       	jmp    c0101fec <__alltraps>

c010232a <vector90>:
.globl vector90
vector90:
  pushl $0
c010232a:	6a 00                	push   $0x0
  pushl $90
c010232c:	6a 5a                	push   $0x5a
  jmp __alltraps
c010232e:	e9 b9 fc ff ff       	jmp    c0101fec <__alltraps>

c0102333 <vector91>:
.globl vector91
vector91:
  pushl $0
c0102333:	6a 00                	push   $0x0
  pushl $91
c0102335:	6a 5b                	push   $0x5b
  jmp __alltraps
c0102337:	e9 b0 fc ff ff       	jmp    c0101fec <__alltraps>

c010233c <vector92>:
.globl vector92
vector92:
  pushl $0
c010233c:	6a 00                	push   $0x0
  pushl $92
c010233e:	6a 5c                	push   $0x5c
  jmp __alltraps
c0102340:	e9 a7 fc ff ff       	jmp    c0101fec <__alltraps>

c0102345 <vector93>:
.globl vector93
vector93:
  pushl $0
c0102345:	6a 00                	push   $0x0
  pushl $93
c0102347:	6a 5d                	push   $0x5d
  jmp __alltraps
c0102349:	e9 9e fc ff ff       	jmp    c0101fec <__alltraps>

c010234e <vector94>:
.globl vector94
vector94:
  pushl $0
c010234e:	6a 00                	push   $0x0
  pushl $94
c0102350:	6a 5e                	push   $0x5e
  jmp __alltraps
c0102352:	e9 95 fc ff ff       	jmp    c0101fec <__alltraps>

c0102357 <vector95>:
.globl vector95
vector95:
  pushl $0
c0102357:	6a 00                	push   $0x0
  pushl $95
c0102359:	6a 5f                	push   $0x5f
  jmp __alltraps
c010235b:	e9 8c fc ff ff       	jmp    c0101fec <__alltraps>

c0102360 <vector96>:
.globl vector96
vector96:
  pushl $0
c0102360:	6a 00                	push   $0x0
  pushl $96
c0102362:	6a 60                	push   $0x60
  jmp __alltraps
c0102364:	e9 83 fc ff ff       	jmp    c0101fec <__alltraps>

c0102369 <vector97>:
.globl vector97
vector97:
  pushl $0
c0102369:	6a 00                	push   $0x0
  pushl $97
c010236b:	6a 61                	push   $0x61
  jmp __alltraps
c010236d:	e9 7a fc ff ff       	jmp    c0101fec <__alltraps>

c0102372 <vector98>:
.globl vector98
vector98:
  pushl $0
c0102372:	6a 00                	push   $0x0
  pushl $98
c0102374:	6a 62                	push   $0x62
  jmp __alltraps
c0102376:	e9 71 fc ff ff       	jmp    c0101fec <__alltraps>

c010237b <vector99>:
.globl vector99
vector99:
  pushl $0
c010237b:	6a 00                	push   $0x0
  pushl $99
c010237d:	6a 63                	push   $0x63
  jmp __alltraps
c010237f:	e9 68 fc ff ff       	jmp    c0101fec <__alltraps>

c0102384 <vector100>:
.globl vector100
vector100:
  pushl $0
c0102384:	6a 00                	push   $0x0
  pushl $100
c0102386:	6a 64                	push   $0x64
  jmp __alltraps
c0102388:	e9 5f fc ff ff       	jmp    c0101fec <__alltraps>

c010238d <vector101>:
.globl vector101
vector101:
  pushl $0
c010238d:	6a 00                	push   $0x0
  pushl $101
c010238f:	6a 65                	push   $0x65
  jmp __alltraps
c0102391:	e9 56 fc ff ff       	jmp    c0101fec <__alltraps>

c0102396 <vector102>:
.globl vector102
vector102:
  pushl $0
c0102396:	6a 00                	push   $0x0
  pushl $102
c0102398:	6a 66                	push   $0x66
  jmp __alltraps
c010239a:	e9 4d fc ff ff       	jmp    c0101fec <__alltraps>

c010239f <vector103>:
.globl vector103
vector103:
  pushl $0
c010239f:	6a 00                	push   $0x0
  pushl $103
c01023a1:	6a 67                	push   $0x67
  jmp __alltraps
c01023a3:	e9 44 fc ff ff       	jmp    c0101fec <__alltraps>

c01023a8 <vector104>:
.globl vector104
vector104:
  pushl $0
c01023a8:	6a 00                	push   $0x0
  pushl $104
c01023aa:	6a 68                	push   $0x68
  jmp __alltraps
c01023ac:	e9 3b fc ff ff       	jmp    c0101fec <__alltraps>

c01023b1 <vector105>:
.globl vector105
vector105:
  pushl $0
c01023b1:	6a 00                	push   $0x0
  pushl $105
c01023b3:	6a 69                	push   $0x69
  jmp __alltraps
c01023b5:	e9 32 fc ff ff       	jmp    c0101fec <__alltraps>

c01023ba <vector106>:
.globl vector106
vector106:
  pushl $0
c01023ba:	6a 00                	push   $0x0
  pushl $106
c01023bc:	6a 6a                	push   $0x6a
  jmp __alltraps
c01023be:	e9 29 fc ff ff       	jmp    c0101fec <__alltraps>

c01023c3 <vector107>:
.globl vector107
vector107:
  pushl $0
c01023c3:	6a 00                	push   $0x0
  pushl $107
c01023c5:	6a 6b                	push   $0x6b
  jmp __alltraps
c01023c7:	e9 20 fc ff ff       	jmp    c0101fec <__alltraps>

c01023cc <vector108>:
.globl vector108
vector108:
  pushl $0
c01023cc:	6a 00                	push   $0x0
  pushl $108
c01023ce:	6a 6c                	push   $0x6c
  jmp __alltraps
c01023d0:	e9 17 fc ff ff       	jmp    c0101fec <__alltraps>

c01023d5 <vector109>:
.globl vector109
vector109:
  pushl $0
c01023d5:	6a 00                	push   $0x0
  pushl $109
c01023d7:	6a 6d                	push   $0x6d
  jmp __alltraps
c01023d9:	e9 0e fc ff ff       	jmp    c0101fec <__alltraps>

c01023de <vector110>:
.globl vector110
vector110:
  pushl $0
c01023de:	6a 00                	push   $0x0
  pushl $110
c01023e0:	6a 6e                	push   $0x6e
  jmp __alltraps
c01023e2:	e9 05 fc ff ff       	jmp    c0101fec <__alltraps>

c01023e7 <vector111>:
.globl vector111
vector111:
  pushl $0
c01023e7:	6a 00                	push   $0x0
  pushl $111
c01023e9:	6a 6f                	push   $0x6f
  jmp __alltraps
c01023eb:	e9 fc fb ff ff       	jmp    c0101fec <__alltraps>

c01023f0 <vector112>:
.globl vector112
vector112:
  pushl $0
c01023f0:	6a 00                	push   $0x0
  pushl $112
c01023f2:	6a 70                	push   $0x70
  jmp __alltraps
c01023f4:	e9 f3 fb ff ff       	jmp    c0101fec <__alltraps>

c01023f9 <vector113>:
.globl vector113
vector113:
  pushl $0
c01023f9:	6a 00                	push   $0x0
  pushl $113
c01023fb:	6a 71                	push   $0x71
  jmp __alltraps
c01023fd:	e9 ea fb ff ff       	jmp    c0101fec <__alltraps>

c0102402 <vector114>:
.globl vector114
vector114:
  pushl $0
c0102402:	6a 00                	push   $0x0
  pushl $114
c0102404:	6a 72                	push   $0x72
  jmp __alltraps
c0102406:	e9 e1 fb ff ff       	jmp    c0101fec <__alltraps>

c010240b <vector115>:
.globl vector115
vector115:
  pushl $0
c010240b:	6a 00                	push   $0x0
  pushl $115
c010240d:	6a 73                	push   $0x73
  jmp __alltraps
c010240f:	e9 d8 fb ff ff       	jmp    c0101fec <__alltraps>

c0102414 <vector116>:
.globl vector116
vector116:
  pushl $0
c0102414:	6a 00                	push   $0x0
  pushl $116
c0102416:	6a 74                	push   $0x74
  jmp __alltraps
c0102418:	e9 cf fb ff ff       	jmp    c0101fec <__alltraps>

c010241d <vector117>:
.globl vector117
vector117:
  pushl $0
c010241d:	6a 00                	push   $0x0
  pushl $117
c010241f:	6a 75                	push   $0x75
  jmp __alltraps
c0102421:	e9 c6 fb ff ff       	jmp    c0101fec <__alltraps>

c0102426 <vector118>:
.globl vector118
vector118:
  pushl $0
c0102426:	6a 00                	push   $0x0
  pushl $118
c0102428:	6a 76                	push   $0x76
  jmp __alltraps
c010242a:	e9 bd fb ff ff       	jmp    c0101fec <__alltraps>

c010242f <vector119>:
.globl vector119
vector119:
  pushl $0
c010242f:	6a 00                	push   $0x0
  pushl $119
c0102431:	6a 77                	push   $0x77
  jmp __alltraps
c0102433:	e9 b4 fb ff ff       	jmp    c0101fec <__alltraps>

c0102438 <vector120>:
.globl vector120
vector120:
  pushl $0
c0102438:	6a 00                	push   $0x0
  pushl $120
c010243a:	6a 78                	push   $0x78
  jmp __alltraps
c010243c:	e9 ab fb ff ff       	jmp    c0101fec <__alltraps>

c0102441 <vector121>:
.globl vector121
vector121:
  pushl $0
c0102441:	6a 00                	push   $0x0
  pushl $121
c0102443:	6a 79                	push   $0x79
  jmp __alltraps
c0102445:	e9 a2 fb ff ff       	jmp    c0101fec <__alltraps>

c010244a <vector122>:
.globl vector122
vector122:
  pushl $0
c010244a:	6a 00                	push   $0x0
  pushl $122
c010244c:	6a 7a                	push   $0x7a
  jmp __alltraps
c010244e:	e9 99 fb ff ff       	jmp    c0101fec <__alltraps>

c0102453 <vector123>:
.globl vector123
vector123:
  pushl $0
c0102453:	6a 00                	push   $0x0
  pushl $123
c0102455:	6a 7b                	push   $0x7b
  jmp __alltraps
c0102457:	e9 90 fb ff ff       	jmp    c0101fec <__alltraps>

c010245c <vector124>:
.globl vector124
vector124:
  pushl $0
c010245c:	6a 00                	push   $0x0
  pushl $124
c010245e:	6a 7c                	push   $0x7c
  jmp __alltraps
c0102460:	e9 87 fb ff ff       	jmp    c0101fec <__alltraps>

c0102465 <vector125>:
.globl vector125
vector125:
  pushl $0
c0102465:	6a 00                	push   $0x0
  pushl $125
c0102467:	6a 7d                	push   $0x7d
  jmp __alltraps
c0102469:	e9 7e fb ff ff       	jmp    c0101fec <__alltraps>

c010246e <vector126>:
.globl vector126
vector126:
  pushl $0
c010246e:	6a 00                	push   $0x0
  pushl $126
c0102470:	6a 7e                	push   $0x7e
  jmp __alltraps
c0102472:	e9 75 fb ff ff       	jmp    c0101fec <__alltraps>

c0102477 <vector127>:
.globl vector127
vector127:
  pushl $0
c0102477:	6a 00                	push   $0x0
  pushl $127
c0102479:	6a 7f                	push   $0x7f
  jmp __alltraps
c010247b:	e9 6c fb ff ff       	jmp    c0101fec <__alltraps>

c0102480 <vector128>:
.globl vector128
vector128:
  pushl $0
c0102480:	6a 00                	push   $0x0
  pushl $128
c0102482:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
c0102487:	e9 60 fb ff ff       	jmp    c0101fec <__alltraps>

c010248c <vector129>:
.globl vector129
vector129:
  pushl $0
c010248c:	6a 00                	push   $0x0
  pushl $129
c010248e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
c0102493:	e9 54 fb ff ff       	jmp    c0101fec <__alltraps>

c0102498 <vector130>:
.globl vector130
vector130:
  pushl $0
c0102498:	6a 00                	push   $0x0
  pushl $130
c010249a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
c010249f:	e9 48 fb ff ff       	jmp    c0101fec <__alltraps>

c01024a4 <vector131>:
.globl vector131
vector131:
  pushl $0
c01024a4:	6a 00                	push   $0x0
  pushl $131
c01024a6:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
c01024ab:	e9 3c fb ff ff       	jmp    c0101fec <__alltraps>

c01024b0 <vector132>:
.globl vector132
vector132:
  pushl $0
c01024b0:	6a 00                	push   $0x0
  pushl $132
c01024b2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
c01024b7:	e9 30 fb ff ff       	jmp    c0101fec <__alltraps>

c01024bc <vector133>:
.globl vector133
vector133:
  pushl $0
c01024bc:	6a 00                	push   $0x0
  pushl $133
c01024be:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
c01024c3:	e9 24 fb ff ff       	jmp    c0101fec <__alltraps>

c01024c8 <vector134>:
.globl vector134
vector134:
  pushl $0
c01024c8:	6a 00                	push   $0x0
  pushl $134
c01024ca:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
c01024cf:	e9 18 fb ff ff       	jmp    c0101fec <__alltraps>

c01024d4 <vector135>:
.globl vector135
vector135:
  pushl $0
c01024d4:	6a 00                	push   $0x0
  pushl $135
c01024d6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
c01024db:	e9 0c fb ff ff       	jmp    c0101fec <__alltraps>

c01024e0 <vector136>:
.globl vector136
vector136:
  pushl $0
c01024e0:	6a 00                	push   $0x0
  pushl $136
c01024e2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
c01024e7:	e9 00 fb ff ff       	jmp    c0101fec <__alltraps>

c01024ec <vector137>:
.globl vector137
vector137:
  pushl $0
c01024ec:	6a 00                	push   $0x0
  pushl $137
c01024ee:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
c01024f3:	e9 f4 fa ff ff       	jmp    c0101fec <__alltraps>

c01024f8 <vector138>:
.globl vector138
vector138:
  pushl $0
c01024f8:	6a 00                	push   $0x0
  pushl $138
c01024fa:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
c01024ff:	e9 e8 fa ff ff       	jmp    c0101fec <__alltraps>

c0102504 <vector139>:
.globl vector139
vector139:
  pushl $0
c0102504:	6a 00                	push   $0x0
  pushl $139
c0102506:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
c010250b:	e9 dc fa ff ff       	jmp    c0101fec <__alltraps>

c0102510 <vector140>:
.globl vector140
vector140:
  pushl $0
c0102510:	6a 00                	push   $0x0
  pushl $140
c0102512:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
c0102517:	e9 d0 fa ff ff       	jmp    c0101fec <__alltraps>

c010251c <vector141>:
.globl vector141
vector141:
  pushl $0
c010251c:	6a 00                	push   $0x0
  pushl $141
c010251e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
c0102523:	e9 c4 fa ff ff       	jmp    c0101fec <__alltraps>

c0102528 <vector142>:
.globl vector142
vector142:
  pushl $0
c0102528:	6a 00                	push   $0x0
  pushl $142
c010252a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
c010252f:	e9 b8 fa ff ff       	jmp    c0101fec <__alltraps>

c0102534 <vector143>:
.globl vector143
vector143:
  pushl $0
c0102534:	6a 00                	push   $0x0
  pushl $143
c0102536:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
c010253b:	e9 ac fa ff ff       	jmp    c0101fec <__alltraps>

c0102540 <vector144>:
.globl vector144
vector144:
  pushl $0
c0102540:	6a 00                	push   $0x0
  pushl $144
c0102542:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
c0102547:	e9 a0 fa ff ff       	jmp    c0101fec <__alltraps>

c010254c <vector145>:
.globl vector145
vector145:
  pushl $0
c010254c:	6a 00                	push   $0x0
  pushl $145
c010254e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
c0102553:	e9 94 fa ff ff       	jmp    c0101fec <__alltraps>

c0102558 <vector146>:
.globl vector146
vector146:
  pushl $0
c0102558:	6a 00                	push   $0x0
  pushl $146
c010255a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
c010255f:	e9 88 fa ff ff       	jmp    c0101fec <__alltraps>

c0102564 <vector147>:
.globl vector147
vector147:
  pushl $0
c0102564:	6a 00                	push   $0x0
  pushl $147
c0102566:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
c010256b:	e9 7c fa ff ff       	jmp    c0101fec <__alltraps>

c0102570 <vector148>:
.globl vector148
vector148:
  pushl $0
c0102570:	6a 00                	push   $0x0
  pushl $148
c0102572:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
c0102577:	e9 70 fa ff ff       	jmp    c0101fec <__alltraps>

c010257c <vector149>:
.globl vector149
vector149:
  pushl $0
c010257c:	6a 00                	push   $0x0
  pushl $149
c010257e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
c0102583:	e9 64 fa ff ff       	jmp    c0101fec <__alltraps>

c0102588 <vector150>:
.globl vector150
vector150:
  pushl $0
c0102588:	6a 00                	push   $0x0
  pushl $150
c010258a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
c010258f:	e9 58 fa ff ff       	jmp    c0101fec <__alltraps>

c0102594 <vector151>:
.globl vector151
vector151:
  pushl $0
c0102594:	6a 00                	push   $0x0
  pushl $151
c0102596:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
c010259b:	e9 4c fa ff ff       	jmp    c0101fec <__alltraps>

c01025a0 <vector152>:
.globl vector152
vector152:
  pushl $0
c01025a0:	6a 00                	push   $0x0
  pushl $152
c01025a2:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
c01025a7:	e9 40 fa ff ff       	jmp    c0101fec <__alltraps>

c01025ac <vector153>:
.globl vector153
vector153:
  pushl $0
c01025ac:	6a 00                	push   $0x0
  pushl $153
c01025ae:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
c01025b3:	e9 34 fa ff ff       	jmp    c0101fec <__alltraps>

c01025b8 <vector154>:
.globl vector154
vector154:
  pushl $0
c01025b8:	6a 00                	push   $0x0
  pushl $154
c01025ba:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
c01025bf:	e9 28 fa ff ff       	jmp    c0101fec <__alltraps>

c01025c4 <vector155>:
.globl vector155
vector155:
  pushl $0
c01025c4:	6a 00                	push   $0x0
  pushl $155
c01025c6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
c01025cb:	e9 1c fa ff ff       	jmp    c0101fec <__alltraps>

c01025d0 <vector156>:
.globl vector156
vector156:
  pushl $0
c01025d0:	6a 00                	push   $0x0
  pushl $156
c01025d2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
c01025d7:	e9 10 fa ff ff       	jmp    c0101fec <__alltraps>

c01025dc <vector157>:
.globl vector157
vector157:
  pushl $0
c01025dc:	6a 00                	push   $0x0
  pushl $157
c01025de:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
c01025e3:	e9 04 fa ff ff       	jmp    c0101fec <__alltraps>

c01025e8 <vector158>:
.globl vector158
vector158:
  pushl $0
c01025e8:	6a 00                	push   $0x0
  pushl $158
c01025ea:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
c01025ef:	e9 f8 f9 ff ff       	jmp    c0101fec <__alltraps>

c01025f4 <vector159>:
.globl vector159
vector159:
  pushl $0
c01025f4:	6a 00                	push   $0x0
  pushl $159
c01025f6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
c01025fb:	e9 ec f9 ff ff       	jmp    c0101fec <__alltraps>

c0102600 <vector160>:
.globl vector160
vector160:
  pushl $0
c0102600:	6a 00                	push   $0x0
  pushl $160
c0102602:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
c0102607:	e9 e0 f9 ff ff       	jmp    c0101fec <__alltraps>

c010260c <vector161>:
.globl vector161
vector161:
  pushl $0
c010260c:	6a 00                	push   $0x0
  pushl $161
c010260e:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
c0102613:	e9 d4 f9 ff ff       	jmp    c0101fec <__alltraps>

c0102618 <vector162>:
.globl vector162
vector162:
  pushl $0
c0102618:	6a 00                	push   $0x0
  pushl $162
c010261a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
c010261f:	e9 c8 f9 ff ff       	jmp    c0101fec <__alltraps>

c0102624 <vector163>:
.globl vector163
vector163:
  pushl $0
c0102624:	6a 00                	push   $0x0
  pushl $163
c0102626:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
c010262b:	e9 bc f9 ff ff       	jmp    c0101fec <__alltraps>

c0102630 <vector164>:
.globl vector164
vector164:
  pushl $0
c0102630:	6a 00                	push   $0x0
  pushl $164
c0102632:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
c0102637:	e9 b0 f9 ff ff       	jmp    c0101fec <__alltraps>

c010263c <vector165>:
.globl vector165
vector165:
  pushl $0
c010263c:	6a 00                	push   $0x0
  pushl $165
c010263e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
c0102643:	e9 a4 f9 ff ff       	jmp    c0101fec <__alltraps>

c0102648 <vector166>:
.globl vector166
vector166:
  pushl $0
c0102648:	6a 00                	push   $0x0
  pushl $166
c010264a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
c010264f:	e9 98 f9 ff ff       	jmp    c0101fec <__alltraps>

c0102654 <vector167>:
.globl vector167
vector167:
  pushl $0
c0102654:	6a 00                	push   $0x0
  pushl $167
c0102656:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
c010265b:	e9 8c f9 ff ff       	jmp    c0101fec <__alltraps>

c0102660 <vector168>:
.globl vector168
vector168:
  pushl $0
c0102660:	6a 00                	push   $0x0
  pushl $168
c0102662:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
c0102667:	e9 80 f9 ff ff       	jmp    c0101fec <__alltraps>

c010266c <vector169>:
.globl vector169
vector169:
  pushl $0
c010266c:	6a 00                	push   $0x0
  pushl $169
c010266e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
c0102673:	e9 74 f9 ff ff       	jmp    c0101fec <__alltraps>

c0102678 <vector170>:
.globl vector170
vector170:
  pushl $0
c0102678:	6a 00                	push   $0x0
  pushl $170
c010267a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
c010267f:	e9 68 f9 ff ff       	jmp    c0101fec <__alltraps>

c0102684 <vector171>:
.globl vector171
vector171:
  pushl $0
c0102684:	6a 00                	push   $0x0
  pushl $171
c0102686:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
c010268b:	e9 5c f9 ff ff       	jmp    c0101fec <__alltraps>

c0102690 <vector172>:
.globl vector172
vector172:
  pushl $0
c0102690:	6a 00                	push   $0x0
  pushl $172
c0102692:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
c0102697:	e9 50 f9 ff ff       	jmp    c0101fec <__alltraps>

c010269c <vector173>:
.globl vector173
vector173:
  pushl $0
c010269c:	6a 00                	push   $0x0
  pushl $173
c010269e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
c01026a3:	e9 44 f9 ff ff       	jmp    c0101fec <__alltraps>

c01026a8 <vector174>:
.globl vector174
vector174:
  pushl $0
c01026a8:	6a 00                	push   $0x0
  pushl $174
c01026aa:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
c01026af:	e9 38 f9 ff ff       	jmp    c0101fec <__alltraps>

c01026b4 <vector175>:
.globl vector175
vector175:
  pushl $0
c01026b4:	6a 00                	push   $0x0
  pushl $175
c01026b6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
c01026bb:	e9 2c f9 ff ff       	jmp    c0101fec <__alltraps>

c01026c0 <vector176>:
.globl vector176
vector176:
  pushl $0
c01026c0:	6a 00                	push   $0x0
  pushl $176
c01026c2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
c01026c7:	e9 20 f9 ff ff       	jmp    c0101fec <__alltraps>

c01026cc <vector177>:
.globl vector177
vector177:
  pushl $0
c01026cc:	6a 00                	push   $0x0
  pushl $177
c01026ce:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
c01026d3:	e9 14 f9 ff ff       	jmp    c0101fec <__alltraps>

c01026d8 <vector178>:
.globl vector178
vector178:
  pushl $0
c01026d8:	6a 00                	push   $0x0
  pushl $178
c01026da:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
c01026df:	e9 08 f9 ff ff       	jmp    c0101fec <__alltraps>

c01026e4 <vector179>:
.globl vector179
vector179:
  pushl $0
c01026e4:	6a 00                	push   $0x0
  pushl $179
c01026e6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
c01026eb:	e9 fc f8 ff ff       	jmp    c0101fec <__alltraps>

c01026f0 <vector180>:
.globl vector180
vector180:
  pushl $0
c01026f0:	6a 00                	push   $0x0
  pushl $180
c01026f2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
c01026f7:	e9 f0 f8 ff ff       	jmp    c0101fec <__alltraps>

c01026fc <vector181>:
.globl vector181
vector181:
  pushl $0
c01026fc:	6a 00                	push   $0x0
  pushl $181
c01026fe:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
c0102703:	e9 e4 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102708 <vector182>:
.globl vector182
vector182:
  pushl $0
c0102708:	6a 00                	push   $0x0
  pushl $182
c010270a:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
c010270f:	e9 d8 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102714 <vector183>:
.globl vector183
vector183:
  pushl $0
c0102714:	6a 00                	push   $0x0
  pushl $183
c0102716:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
c010271b:	e9 cc f8 ff ff       	jmp    c0101fec <__alltraps>

c0102720 <vector184>:
.globl vector184
vector184:
  pushl $0
c0102720:	6a 00                	push   $0x0
  pushl $184
c0102722:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
c0102727:	e9 c0 f8 ff ff       	jmp    c0101fec <__alltraps>

c010272c <vector185>:
.globl vector185
vector185:
  pushl $0
c010272c:	6a 00                	push   $0x0
  pushl $185
c010272e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
c0102733:	e9 b4 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102738 <vector186>:
.globl vector186
vector186:
  pushl $0
c0102738:	6a 00                	push   $0x0
  pushl $186
c010273a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
c010273f:	e9 a8 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102744 <vector187>:
.globl vector187
vector187:
  pushl $0
c0102744:	6a 00                	push   $0x0
  pushl $187
c0102746:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
c010274b:	e9 9c f8 ff ff       	jmp    c0101fec <__alltraps>

c0102750 <vector188>:
.globl vector188
vector188:
  pushl $0
c0102750:	6a 00                	push   $0x0
  pushl $188
c0102752:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
c0102757:	e9 90 f8 ff ff       	jmp    c0101fec <__alltraps>

c010275c <vector189>:
.globl vector189
vector189:
  pushl $0
c010275c:	6a 00                	push   $0x0
  pushl $189
c010275e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
c0102763:	e9 84 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102768 <vector190>:
.globl vector190
vector190:
  pushl $0
c0102768:	6a 00                	push   $0x0
  pushl $190
c010276a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
c010276f:	e9 78 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102774 <vector191>:
.globl vector191
vector191:
  pushl $0
c0102774:	6a 00                	push   $0x0
  pushl $191
c0102776:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
c010277b:	e9 6c f8 ff ff       	jmp    c0101fec <__alltraps>

c0102780 <vector192>:
.globl vector192
vector192:
  pushl $0
c0102780:	6a 00                	push   $0x0
  pushl $192
c0102782:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
c0102787:	e9 60 f8 ff ff       	jmp    c0101fec <__alltraps>

c010278c <vector193>:
.globl vector193
vector193:
  pushl $0
c010278c:	6a 00                	push   $0x0
  pushl $193
c010278e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
c0102793:	e9 54 f8 ff ff       	jmp    c0101fec <__alltraps>

c0102798 <vector194>:
.globl vector194
vector194:
  pushl $0
c0102798:	6a 00                	push   $0x0
  pushl $194
c010279a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
c010279f:	e9 48 f8 ff ff       	jmp    c0101fec <__alltraps>

c01027a4 <vector195>:
.globl vector195
vector195:
  pushl $0
c01027a4:	6a 00                	push   $0x0
  pushl $195
c01027a6:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
c01027ab:	e9 3c f8 ff ff       	jmp    c0101fec <__alltraps>

c01027b0 <vector196>:
.globl vector196
vector196:
  pushl $0
c01027b0:	6a 00                	push   $0x0
  pushl $196
c01027b2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
c01027b7:	e9 30 f8 ff ff       	jmp    c0101fec <__alltraps>

c01027bc <vector197>:
.globl vector197
vector197:
  pushl $0
c01027bc:	6a 00                	push   $0x0
  pushl $197
c01027be:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
c01027c3:	e9 24 f8 ff ff       	jmp    c0101fec <__alltraps>

c01027c8 <vector198>:
.globl vector198
vector198:
  pushl $0
c01027c8:	6a 00                	push   $0x0
  pushl $198
c01027ca:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
c01027cf:	e9 18 f8 ff ff       	jmp    c0101fec <__alltraps>

c01027d4 <vector199>:
.globl vector199
vector199:
  pushl $0
c01027d4:	6a 00                	push   $0x0
  pushl $199
c01027d6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
c01027db:	e9 0c f8 ff ff       	jmp    c0101fec <__alltraps>

c01027e0 <vector200>:
.globl vector200
vector200:
  pushl $0
c01027e0:	6a 00                	push   $0x0
  pushl $200
c01027e2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
c01027e7:	e9 00 f8 ff ff       	jmp    c0101fec <__alltraps>

c01027ec <vector201>:
.globl vector201
vector201:
  pushl $0
c01027ec:	6a 00                	push   $0x0
  pushl $201
c01027ee:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
c01027f3:	e9 f4 f7 ff ff       	jmp    c0101fec <__alltraps>

c01027f8 <vector202>:
.globl vector202
vector202:
  pushl $0
c01027f8:	6a 00                	push   $0x0
  pushl $202
c01027fa:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
c01027ff:	e9 e8 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102804 <vector203>:
.globl vector203
vector203:
  pushl $0
c0102804:	6a 00                	push   $0x0
  pushl $203
c0102806:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
c010280b:	e9 dc f7 ff ff       	jmp    c0101fec <__alltraps>

c0102810 <vector204>:
.globl vector204
vector204:
  pushl $0
c0102810:	6a 00                	push   $0x0
  pushl $204
c0102812:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
c0102817:	e9 d0 f7 ff ff       	jmp    c0101fec <__alltraps>

c010281c <vector205>:
.globl vector205
vector205:
  pushl $0
c010281c:	6a 00                	push   $0x0
  pushl $205
c010281e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
c0102823:	e9 c4 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102828 <vector206>:
.globl vector206
vector206:
  pushl $0
c0102828:	6a 00                	push   $0x0
  pushl $206
c010282a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
c010282f:	e9 b8 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102834 <vector207>:
.globl vector207
vector207:
  pushl $0
c0102834:	6a 00                	push   $0x0
  pushl $207
c0102836:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
c010283b:	e9 ac f7 ff ff       	jmp    c0101fec <__alltraps>

c0102840 <vector208>:
.globl vector208
vector208:
  pushl $0
c0102840:	6a 00                	push   $0x0
  pushl $208
c0102842:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
c0102847:	e9 a0 f7 ff ff       	jmp    c0101fec <__alltraps>

c010284c <vector209>:
.globl vector209
vector209:
  pushl $0
c010284c:	6a 00                	push   $0x0
  pushl $209
c010284e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
c0102853:	e9 94 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102858 <vector210>:
.globl vector210
vector210:
  pushl $0
c0102858:	6a 00                	push   $0x0
  pushl $210
c010285a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
c010285f:	e9 88 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102864 <vector211>:
.globl vector211
vector211:
  pushl $0
c0102864:	6a 00                	push   $0x0
  pushl $211
c0102866:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
c010286b:	e9 7c f7 ff ff       	jmp    c0101fec <__alltraps>

c0102870 <vector212>:
.globl vector212
vector212:
  pushl $0
c0102870:	6a 00                	push   $0x0
  pushl $212
c0102872:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
c0102877:	e9 70 f7 ff ff       	jmp    c0101fec <__alltraps>

c010287c <vector213>:
.globl vector213
vector213:
  pushl $0
c010287c:	6a 00                	push   $0x0
  pushl $213
c010287e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
c0102883:	e9 64 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102888 <vector214>:
.globl vector214
vector214:
  pushl $0
c0102888:	6a 00                	push   $0x0
  pushl $214
c010288a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
c010288f:	e9 58 f7 ff ff       	jmp    c0101fec <__alltraps>

c0102894 <vector215>:
.globl vector215
vector215:
  pushl $0
c0102894:	6a 00                	push   $0x0
  pushl $215
c0102896:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
c010289b:	e9 4c f7 ff ff       	jmp    c0101fec <__alltraps>

c01028a0 <vector216>:
.globl vector216
vector216:
  pushl $0
c01028a0:	6a 00                	push   $0x0
  pushl $216
c01028a2:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
c01028a7:	e9 40 f7 ff ff       	jmp    c0101fec <__alltraps>

c01028ac <vector217>:
.globl vector217
vector217:
  pushl $0
c01028ac:	6a 00                	push   $0x0
  pushl $217
c01028ae:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
c01028b3:	e9 34 f7 ff ff       	jmp    c0101fec <__alltraps>

c01028b8 <vector218>:
.globl vector218
vector218:
  pushl $0
c01028b8:	6a 00                	push   $0x0
  pushl $218
c01028ba:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
c01028bf:	e9 28 f7 ff ff       	jmp    c0101fec <__alltraps>

c01028c4 <vector219>:
.globl vector219
vector219:
  pushl $0
c01028c4:	6a 00                	push   $0x0
  pushl $219
c01028c6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
c01028cb:	e9 1c f7 ff ff       	jmp    c0101fec <__alltraps>

c01028d0 <vector220>:
.globl vector220
vector220:
  pushl $0
c01028d0:	6a 00                	push   $0x0
  pushl $220
c01028d2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
c01028d7:	e9 10 f7 ff ff       	jmp    c0101fec <__alltraps>

c01028dc <vector221>:
.globl vector221
vector221:
  pushl $0
c01028dc:	6a 00                	push   $0x0
  pushl $221
c01028de:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
c01028e3:	e9 04 f7 ff ff       	jmp    c0101fec <__alltraps>

c01028e8 <vector222>:
.globl vector222
vector222:
  pushl $0
c01028e8:	6a 00                	push   $0x0
  pushl $222
c01028ea:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
c01028ef:	e9 f8 f6 ff ff       	jmp    c0101fec <__alltraps>

c01028f4 <vector223>:
.globl vector223
vector223:
  pushl $0
c01028f4:	6a 00                	push   $0x0
  pushl $223
c01028f6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
c01028fb:	e9 ec f6 ff ff       	jmp    c0101fec <__alltraps>

c0102900 <vector224>:
.globl vector224
vector224:
  pushl $0
c0102900:	6a 00                	push   $0x0
  pushl $224
c0102902:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
c0102907:	e9 e0 f6 ff ff       	jmp    c0101fec <__alltraps>

c010290c <vector225>:
.globl vector225
vector225:
  pushl $0
c010290c:	6a 00                	push   $0x0
  pushl $225
c010290e:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
c0102913:	e9 d4 f6 ff ff       	jmp    c0101fec <__alltraps>

c0102918 <vector226>:
.globl vector226
vector226:
  pushl $0
c0102918:	6a 00                	push   $0x0
  pushl $226
c010291a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
c010291f:	e9 c8 f6 ff ff       	jmp    c0101fec <__alltraps>

c0102924 <vector227>:
.globl vector227
vector227:
  pushl $0
c0102924:	6a 00                	push   $0x0
  pushl $227
c0102926:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
c010292b:	e9 bc f6 ff ff       	jmp    c0101fec <__alltraps>

c0102930 <vector228>:
.globl vector228
vector228:
  pushl $0
c0102930:	6a 00                	push   $0x0
  pushl $228
c0102932:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
c0102937:	e9 b0 f6 ff ff       	jmp    c0101fec <__alltraps>

c010293c <vector229>:
.globl vector229
vector229:
  pushl $0
c010293c:	6a 00                	push   $0x0
  pushl $229
c010293e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
c0102943:	e9 a4 f6 ff ff       	jmp    c0101fec <__alltraps>

c0102948 <vector230>:
.globl vector230
vector230:
  pushl $0
c0102948:	6a 00                	push   $0x0
  pushl $230
c010294a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
c010294f:	e9 98 f6 ff ff       	jmp    c0101fec <__alltraps>

c0102954 <vector231>:
.globl vector231
vector231:
  pushl $0
c0102954:	6a 00                	push   $0x0
  pushl $231
c0102956:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
c010295b:	e9 8c f6 ff ff       	jmp    c0101fec <__alltraps>

c0102960 <vector232>:
.globl vector232
vector232:
  pushl $0
c0102960:	6a 00                	push   $0x0
  pushl $232
c0102962:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
c0102967:	e9 80 f6 ff ff       	jmp    c0101fec <__alltraps>

c010296c <vector233>:
.globl vector233
vector233:
  pushl $0
c010296c:	6a 00                	push   $0x0
  pushl $233
c010296e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
c0102973:	e9 74 f6 ff ff       	jmp    c0101fec <__alltraps>

c0102978 <vector234>:
.globl vector234
vector234:
  pushl $0
c0102978:	6a 00                	push   $0x0
  pushl $234
c010297a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
c010297f:	e9 68 f6 ff ff       	jmp    c0101fec <__alltraps>

c0102984 <vector235>:
.globl vector235
vector235:
  pushl $0
c0102984:	6a 00                	push   $0x0
  pushl $235
c0102986:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
c010298b:	e9 5c f6 ff ff       	jmp    c0101fec <__alltraps>

c0102990 <vector236>:
.globl vector236
vector236:
  pushl $0
c0102990:	6a 00                	push   $0x0
  pushl $236
c0102992:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
c0102997:	e9 50 f6 ff ff       	jmp    c0101fec <__alltraps>

c010299c <vector237>:
.globl vector237
vector237:
  pushl $0
c010299c:	6a 00                	push   $0x0
  pushl $237
c010299e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
c01029a3:	e9 44 f6 ff ff       	jmp    c0101fec <__alltraps>

c01029a8 <vector238>:
.globl vector238
vector238:
  pushl $0
c01029a8:	6a 00                	push   $0x0
  pushl $238
c01029aa:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
c01029af:	e9 38 f6 ff ff       	jmp    c0101fec <__alltraps>

c01029b4 <vector239>:
.globl vector239
vector239:
  pushl $0
c01029b4:	6a 00                	push   $0x0
  pushl $239
c01029b6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
c01029bb:	e9 2c f6 ff ff       	jmp    c0101fec <__alltraps>

c01029c0 <vector240>:
.globl vector240
vector240:
  pushl $0
c01029c0:	6a 00                	push   $0x0
  pushl $240
c01029c2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
c01029c7:	e9 20 f6 ff ff       	jmp    c0101fec <__alltraps>

c01029cc <vector241>:
.globl vector241
vector241:
  pushl $0
c01029cc:	6a 00                	push   $0x0
  pushl $241
c01029ce:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
c01029d3:	e9 14 f6 ff ff       	jmp    c0101fec <__alltraps>

c01029d8 <vector242>:
.globl vector242
vector242:
  pushl $0
c01029d8:	6a 00                	push   $0x0
  pushl $242
c01029da:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
c01029df:	e9 08 f6 ff ff       	jmp    c0101fec <__alltraps>

c01029e4 <vector243>:
.globl vector243
vector243:
  pushl $0
c01029e4:	6a 00                	push   $0x0
  pushl $243
c01029e6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
c01029eb:	e9 fc f5 ff ff       	jmp    c0101fec <__alltraps>

c01029f0 <vector244>:
.globl vector244
vector244:
  pushl $0
c01029f0:	6a 00                	push   $0x0
  pushl $244
c01029f2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
c01029f7:	e9 f0 f5 ff ff       	jmp    c0101fec <__alltraps>

c01029fc <vector245>:
.globl vector245
vector245:
  pushl $0
c01029fc:	6a 00                	push   $0x0
  pushl $245
c01029fe:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
c0102a03:	e9 e4 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a08 <vector246>:
.globl vector246
vector246:
  pushl $0
c0102a08:	6a 00                	push   $0x0
  pushl $246
c0102a0a:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
c0102a0f:	e9 d8 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a14 <vector247>:
.globl vector247
vector247:
  pushl $0
c0102a14:	6a 00                	push   $0x0
  pushl $247
c0102a16:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
c0102a1b:	e9 cc f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a20 <vector248>:
.globl vector248
vector248:
  pushl $0
c0102a20:	6a 00                	push   $0x0
  pushl $248
c0102a22:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
c0102a27:	e9 c0 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a2c <vector249>:
.globl vector249
vector249:
  pushl $0
c0102a2c:	6a 00                	push   $0x0
  pushl $249
c0102a2e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
c0102a33:	e9 b4 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a38 <vector250>:
.globl vector250
vector250:
  pushl $0
c0102a38:	6a 00                	push   $0x0
  pushl $250
c0102a3a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
c0102a3f:	e9 a8 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a44 <vector251>:
.globl vector251
vector251:
  pushl $0
c0102a44:	6a 00                	push   $0x0
  pushl $251
c0102a46:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
c0102a4b:	e9 9c f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a50 <vector252>:
.globl vector252
vector252:
  pushl $0
c0102a50:	6a 00                	push   $0x0
  pushl $252
c0102a52:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
c0102a57:	e9 90 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a5c <vector253>:
.globl vector253
vector253:
  pushl $0
c0102a5c:	6a 00                	push   $0x0
  pushl $253
c0102a5e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
c0102a63:	e9 84 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a68 <vector254>:
.globl vector254
vector254:
  pushl $0
c0102a68:	6a 00                	push   $0x0
  pushl $254
c0102a6a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
c0102a6f:	e9 78 f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a74 <vector255>:
.globl vector255
vector255:
  pushl $0
c0102a74:	6a 00                	push   $0x0
  pushl $255
c0102a76:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
c0102a7b:	e9 6c f5 ff ff       	jmp    c0101fec <__alltraps>

c0102a80 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
c0102a80:	55                   	push   %ebp
c0102a81:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0102a83:	8b 15 00 cf 11 c0    	mov    0xc011cf00,%edx
c0102a89:	8b 45 08             	mov    0x8(%ebp),%eax
c0102a8c:	29 d0                	sub    %edx,%eax
c0102a8e:	c1 f8 02             	sar    $0x2,%eax
c0102a91:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0102a97:	5d                   	pop    %ebp
c0102a98:	c3                   	ret    

c0102a99 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
c0102a99:	55                   	push   %ebp
c0102a9a:	89 e5                	mov    %esp,%ebp
c0102a9c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0102a9f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102aa2:	89 04 24             	mov    %eax,(%esp)
c0102aa5:	e8 d6 ff ff ff       	call   c0102a80 <page2ppn>
c0102aaa:	c1 e0 0c             	shl    $0xc,%eax
}
c0102aad:	89 ec                	mov    %ebp,%esp
c0102aaf:	5d                   	pop    %ebp
c0102ab0:	c3                   	ret    

c0102ab1 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
c0102ab1:	55                   	push   %ebp
c0102ab2:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0102ab4:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ab7:	8b 00                	mov    (%eax),%eax
}
c0102ab9:	5d                   	pop    %ebp
c0102aba:	c3                   	ret    

c0102abb <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
c0102abb:	55                   	push   %ebp
c0102abc:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0102abe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ac4:	89 10                	mov    %edx,(%eax)
}
c0102ac6:	90                   	nop
c0102ac7:	5d                   	pop    %ebp
c0102ac8:	c3                   	ret    

c0102ac9 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
c0102ac9:	55                   	push   %ebp
c0102aca:	89 e5                	mov    %esp,%ebp
c0102acc:	83 ec 10             	sub    $0x10,%esp
c0102acf:	c7 45 fc e0 ce 11 c0 	movl   $0xc011cee0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
c0102ad6:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102ad9:	8b 55 fc             	mov    -0x4(%ebp),%edx
c0102adc:	89 50 04             	mov    %edx,0x4(%eax)
c0102adf:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102ae2:	8b 50 04             	mov    0x4(%eax),%edx
c0102ae5:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0102ae8:	89 10                	mov    %edx,(%eax)
}
c0102aea:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
c0102aeb:	c7 05 e8 ce 11 c0 00 	movl   $0x0,0xc011cee8
c0102af2:	00 00 00 
}
c0102af5:	90                   	nop
c0102af6:	89 ec                	mov    %ebp,%esp
c0102af8:	5d                   	pop    %ebp
c0102af9:	c3                   	ret    

c0102afa <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
c0102afa:	55                   	push   %ebp
c0102afb:	89 e5                	mov    %esp,%ebp
c0102afd:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
c0102b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102b04:	75 24                	jne    c0102b2a <default_init_memmap+0x30>
c0102b06:	c7 44 24 0c 50 69 10 	movl   $0xc0106950,0xc(%esp)
c0102b0d:	c0 
c0102b0e:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0102b15:	c0 
c0102b16:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
c0102b1d:	00 
c0102b1e:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0102b25:	e8 bd e1 ff ff       	call   c0100ce7 <__panic>
    struct Page *p = base;
c0102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
c0102b30:	eb 7d                	jmp    c0102baf <default_init_memmap+0xb5>
        assert(PageReserved(p));
c0102b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b35:	83 c0 04             	add    $0x4,%eax
c0102b38:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
c0102b3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102b45:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0102b48:	0f a3 10             	bt     %edx,(%eax)
c0102b4b:	19 c0                	sbb    %eax,%eax
c0102b4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
c0102b50:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0102b54:	0f 95 c0             	setne  %al
c0102b57:	0f b6 c0             	movzbl %al,%eax
c0102b5a:	85 c0                	test   %eax,%eax
c0102b5c:	75 24                	jne    c0102b82 <default_init_memmap+0x88>
c0102b5e:	c7 44 24 0c 81 69 10 	movl   $0xc0106981,0xc(%esp)
c0102b65:	c0 
c0102b66:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0102b6d:	c0 
c0102b6e:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
c0102b75:	00 
c0102b76:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0102b7d:	e8 65 e1 ff ff       	call   c0100ce7 <__panic>
        p->flags = p->property = 0;
c0102b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
c0102b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b8f:	8b 50 08             	mov    0x8(%eax),%edx
c0102b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102b95:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
c0102b98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102b9f:	00 
c0102ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ba3:	89 04 24             	mov    %eax,(%esp)
c0102ba6:	e8 10 ff ff ff       	call   c0102abb <set_page_ref>
    for (; p != base + n; p ++) {
c0102bab:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102baf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bb2:	89 d0                	mov    %edx,%eax
c0102bb4:	c1 e0 02             	shl    $0x2,%eax
c0102bb7:	01 d0                	add    %edx,%eax
c0102bb9:	c1 e0 02             	shl    $0x2,%eax
c0102bbc:	89 c2                	mov    %eax,%edx
c0102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bc1:	01 d0                	add    %edx,%eax
c0102bc3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102bc6:	0f 85 66 ff ff ff    	jne    c0102b32 <default_init_memmap+0x38>
    }
    base->property = n;
c0102bcc:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102bd2:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
c0102bd8:	83 c0 04             	add    $0x4,%eax
c0102bdb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
c0102be2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102be5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102be8:	8b 55 c8             	mov    -0x38(%ebp),%edx
c0102beb:	0f ab 10             	bts    %edx,(%eax)
}
c0102bee:	90                   	nop
    nr_free += n;
c0102bef:	8b 15 e8 ce 11 c0    	mov    0xc011cee8,%edx
c0102bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0102bf8:	01 d0                	add    %edx,%eax
c0102bfa:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8
    list_add(&free_list, &(base->page_link));
c0102bff:	8b 45 08             	mov    0x8(%ebp),%eax
c0102c02:	83 c0 0c             	add    $0xc,%eax
c0102c05:	c7 45 e4 e0 ce 11 c0 	movl   $0xc011cee0,-0x1c(%ebp)
c0102c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0102c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102c12:	89 45 dc             	mov    %eax,-0x24(%ebp)
c0102c15:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102c18:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
c0102c1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102c1e:	8b 40 04             	mov    0x4(%eax),%eax
c0102c21:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102c24:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102c27:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102c2a:	89 55 d0             	mov    %edx,-0x30(%ebp)
c0102c2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
c0102c30:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102c33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102c36:	89 10                	mov    %edx,(%eax)
c0102c38:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102c3b:	8b 10                	mov    (%eax),%edx
c0102c3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102c40:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102c43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102c46:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102c49:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102c4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102c4f:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102c52:	89 10                	mov    %edx,(%eax)
}
c0102c54:	90                   	nop
}
c0102c55:	90                   	nop
}
c0102c56:	90                   	nop
}
c0102c57:	90                   	nop
c0102c58:	89 ec                	mov    %ebp,%esp
c0102c5a:	5d                   	pop    %ebp
c0102c5b:	c3                   	ret    

c0102c5c <default_alloc_pages>:
 * 并以Page指针的形式，返回最低位物理页(最前面的)。
 * 
 * 如果分配时发生错误或者剩余空闲空间不足，则返回NULL代表分配失败
 * */
static struct Page *
default_alloc_pages(size_t n) {    assert(n > 0);
c0102c5c:	55                   	push   %ebp
c0102c5d:	89 e5                	mov    %esp,%ebp
c0102c5f:	83 ec 68             	sub    $0x68,%esp
c0102c62:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0102c66:	75 24                	jne    c0102c8c <default_alloc_pages+0x30>
c0102c68:	c7 44 24 0c 50 69 10 	movl   $0xc0106950,0xc(%esp)
c0102c6f:	c0 
c0102c70:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0102c77:	c0 
c0102c78:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
c0102c7f:	00 
c0102c80:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0102c87:	e8 5b e0 ff ff       	call   c0100ce7 <__panic>
    if (n > nr_free) {
c0102c8c:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0102c91:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102c94:	76 0a                	jbe    c0102ca0 <default_alloc_pages+0x44>
        return NULL;
c0102c96:	b8 00 00 00 00       	mov    $0x0,%eax
c0102c9b:	e9 43 01 00 00       	jmp    c0102de3 <default_alloc_pages+0x187>
    }
    struct Page *page = NULL;
c0102ca0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
c0102ca7:	c7 45 f0 e0 ce 11 c0 	movl   $0xc011cee0,-0x10(%ebp)
    // TODO: optimize (next-fit)

    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
c0102cae:	eb 1c                	jmp    c0102ccc <default_alloc_pages+0x70>
        // 将le节点转换为关联的Page结构
        struct Page *p = le2page(le, page_link);
c0102cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102cb3:	83 e8 0c             	sub    $0xc,%eax
c0102cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
c0102cb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102cbc:	8b 40 08             	mov    0x8(%eax),%eax
c0102cbf:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102cc2:	77 08                	ja     c0102ccc <default_alloc_pages+0x70>
            // 发现一个满足要求的，空闲页数大于等于N的空闲块
            page = p;
c0102cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0102cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
c0102cca:	eb 18                	jmp    c0102ce4 <default_alloc_pages+0x88>
c0102ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102ccf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
c0102cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0102cd5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0102cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0102cdb:	81 7d f0 e0 ce 11 c0 	cmpl   $0xc011cee0,-0x10(%ebp)
c0102ce2:	75 cc                	jne    c0102cb0 <default_alloc_pages+0x54>
        }
    }
    // 如果page != null代表找到了，分配成功。反之则分配物理内存失败
    if (page != NULL) {
c0102ce4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0102ce8:	0f 84 f2 00 00 00    	je     c0102de0 <default_alloc_pages+0x184>
        if (page->property > n) {
c0102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102cf1:	8b 40 08             	mov    0x8(%eax),%eax
c0102cf4:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102cf7:	0f 83 8f 00 00 00    	jae    c0102d8c <default_alloc_pages+0x130>
            // 如果空闲块的大小不是正合适(page->property != n)
            // 按照指针偏移，找到按序后面第N个Page结构p
            struct Page *p = page + n;
c0102cfd:	8b 55 08             	mov    0x8(%ebp),%edx
c0102d00:	89 d0                	mov    %edx,%eax
c0102d02:	c1 e0 02             	shl    $0x2,%eax
c0102d05:	01 d0                	add    %edx,%eax
c0102d07:	c1 e0 02             	shl    $0x2,%eax
c0102d0a:	89 c2                	mov    %eax,%edx
c0102d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d0f:	01 d0                	add    %edx,%eax
c0102d11:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // p其空闲块个数 = 当前找到的空闲块数量 - n
            p->property = page->property - n;
c0102d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d17:	8b 40 08             	mov    0x8(%eax),%eax
c0102d1a:	2b 45 08             	sub    0x8(%ebp),%eax
c0102d1d:	89 c2                	mov    %eax,%edx
c0102d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d22:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
c0102d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d28:	83 c0 04             	add    $0x4,%eax
c0102d2b:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
c0102d32:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102d35:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102d38:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0102d3b:	0f ab 10             	bts    %edx,(%eax)
}
c0102d3e:	90                   	nop
            // 按对应的物理地址顺序，将p加入到空闲链表中对应的位置
            list_add_after(&(page->page_link), &(p->page_link));
c0102d3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102d42:	83 c0 0c             	add    $0xc,%eax
c0102d45:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0102d48:	83 c2 0c             	add    $0xc,%edx
c0102d4b:	89 55 e0             	mov    %edx,-0x20(%ebp)
c0102d4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
c0102d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0102d54:	8b 40 04             	mov    0x4(%eax),%eax
c0102d57:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0102d5a:	89 55 d8             	mov    %edx,-0x28(%ebp)
c0102d5d:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102d60:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0102d63:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
c0102d66:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102d69:	8b 55 d8             	mov    -0x28(%ebp),%edx
c0102d6c:	89 10                	mov    %edx,(%eax)
c0102d6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0102d71:	8b 10                	mov    (%eax),%edx
c0102d73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102d76:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c0102d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102d7c:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102d7f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0102d82:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0102d85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0102d88:	89 10                	mov    %edx,(%eax)
}
c0102d8a:	90                   	nop
}
c0102d8b:	90                   	nop
        }
        // 在将当前page从空间链表中移除
        list_del(&(page->page_link));
c0102d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102d8f:	83 c0 0c             	add    $0xc,%eax
c0102d92:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102d95:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102d98:	8b 40 04             	mov    0x4(%eax),%eax
c0102d9b:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102d9e:	8b 12                	mov    (%edx),%edx
c0102da0:	89 55 b8             	mov    %edx,-0x48(%ebp)
c0102da3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
c0102da6:	8b 45 b8             	mov    -0x48(%ebp),%eax
c0102da9:	8b 55 b4             	mov    -0x4c(%ebp),%edx
c0102dac:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102daf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102db2:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102db5:	89 10                	mov    %edx,(%eax)
}
c0102db7:	90                   	nop
}
c0102db8:	90                   	nop
        // 闲链表整体空闲页数量自减n
        nr_free -= n;
c0102db9:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0102dbe:	2b 45 08             	sub    0x8(%ebp),%eax
c0102dc1:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8
        // 清楚page的property(因为非空闲块的头Page的property都为0)
        ClearPageProperty(page);
c0102dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102dc9:	83 c0 04             	add    $0x4,%eax
c0102dcc:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
c0102dd3:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102dd6:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102dd9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102ddc:	0f b3 10             	btr    %edx,(%eax)
}
c0102ddf:	90                   	nop
    }
    return page;
c0102de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0102de3:	89 ec                	mov    %ebp,%esp
c0102de5:	5d                   	pop    %ebp
c0102de6:	c3                   	ret    

c0102de7 <default_free_pages>:

/**
 * 释放掉自base起始的连续n个物理页,n必须为正整数
 * */
static void
default_free_pages(struct Page *base, size_t n) {
c0102de7:	55                   	push   %ebp
c0102de8:	89 e5                	mov    %esp,%ebp
c0102dea:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
c0102df0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0102df4:	75 24                	jne    c0102e1a <default_free_pages+0x33>
c0102df6:	c7 44 24 0c 50 69 10 	movl   $0xc0106950,0xc(%esp)
c0102dfd:	c0 
c0102dfe:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0102e05:	c0 
c0102e06:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
c0102e0d:	00 
c0102e0e:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0102e15:	e8 cd de ff ff       	call   c0100ce7 <__panic>
    struct Page *p = base;
c0102e1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0102e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    // 遍历这N个连续的Page页，将其相关属性设置为空闲
    for (; p != base + n; p ++) {
c0102e20:	e9 9d 00 00 00       	jmp    c0102ec2 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
c0102e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e28:	83 c0 04             	add    $0x4,%eax
c0102e2b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
c0102e32:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0102e38:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0102e3b:	0f a3 10             	bt     %edx,(%eax)
c0102e3e:	19 c0                	sbb    %eax,%eax
c0102e40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
c0102e43:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0102e47:	0f 95 c0             	setne  %al
c0102e4a:	0f b6 c0             	movzbl %al,%eax
c0102e4d:	85 c0                	test   %eax,%eax
c0102e4f:	75 2c                	jne    c0102e7d <default_free_pages+0x96>
c0102e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102e54:	83 c0 04             	add    $0x4,%eax
c0102e57:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
c0102e5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0102e61:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0102e64:	8b 55 e0             	mov    -0x20(%ebp),%edx
c0102e67:	0f a3 10             	bt     %edx,(%eax)
c0102e6a:	19 c0                	sbb    %eax,%eax
c0102e6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
c0102e6f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
c0102e73:	0f 95 c0             	setne  %al
c0102e76:	0f b6 c0             	movzbl %al,%eax
c0102e79:	85 c0                	test   %eax,%eax
c0102e7b:	74 24                	je     c0102ea1 <default_free_pages+0xba>
c0102e7d:	c7 44 24 0c 94 69 10 	movl   $0xc0106994,0xc(%esp)
c0102e84:	c0 
c0102e85:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0102e8c:	c0 
c0102e8d:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
c0102e94:	00 
c0102e95:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0102e9c:	e8 46 de ff ff       	call   c0100ce7 <__panic>
        p->flags = 0;
c0102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ea4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
c0102eab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0102eb2:	00 
c0102eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102eb6:	89 04 24             	mov    %eax,(%esp)
c0102eb9:	e8 fd fb ff ff       	call   c0102abb <set_page_ref>
    for (; p != base + n; p ++) {
c0102ebe:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
c0102ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ec5:	89 d0                	mov    %edx,%eax
c0102ec7:	c1 e0 02             	shl    $0x2,%eax
c0102eca:	01 d0                	add    %edx,%eax
c0102ecc:	c1 e0 02             	shl    $0x2,%eax
c0102ecf:	89 c2                	mov    %eax,%edx
c0102ed1:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ed4:	01 d0                	add    %edx,%eax
c0102ed6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102ed9:	0f 85 46 ff ff ff    	jne    c0102e25 <default_free_pages+0x3e>
    }

    // 由于被释放了N个空闲物理页，base头Page的property设置为n
    base->property = n;
c0102edf:	8b 45 08             	mov    0x8(%ebp),%eax
c0102ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
c0102ee5:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
c0102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102eeb:	83 c0 04             	add    $0x4,%eax
c0102eee:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c0102ef5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102ef8:	8b 45 cc             	mov    -0x34(%ebp),%eax
c0102efb:	8b 55 d0             	mov    -0x30(%ebp),%edx
c0102efe:	0f ab 10             	bts    %edx,(%eax)
}
c0102f01:	90                   	nop
c0102f02:	c7 45 d4 e0 ce 11 c0 	movl   $0xc011cee0,-0x2c(%ebp)
    return listelm->next;
c0102f09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0102f0c:	8b 40 04             	mov    0x4(%eax),%eax

    // 下面进行空闲链表相关操作
    list_entry_t *le = list_next(&free_list);
c0102f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 迭代空闲链表中的每一个节点
    while (le != &free_list) {
c0102f12:	e9 0e 01 00 00       	jmp    c0103025 <default_free_pages+0x23e>
        // 获得节点对应的Page结构
        p = le2page(le, page_link);
c0102f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f1a:	83 e8 0c             	sub    $0xc,%eax
c0102f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0102f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0102f23:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0102f26:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0102f29:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
c0102f2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
c0102f2f:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f32:	8b 50 08             	mov    0x8(%eax),%edx
c0102f35:	89 d0                	mov    %edx,%eax
c0102f37:	c1 e0 02             	shl    $0x2,%eax
c0102f3a:	01 d0                	add    %edx,%eax
c0102f3c:	c1 e0 02             	shl    $0x2,%eax
c0102f3f:	89 c2                	mov    %eax,%edx
c0102f41:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f44:	01 d0                	add    %edx,%eax
c0102f46:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0102f49:	75 5d                	jne    c0102fa8 <default_free_pages+0x1c1>
            // 如果当前base释放了N个物理页后，尾部正好能和Page p连上，则进行两个空闲块的合并
            base->property += p->property;
c0102f4b:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f4e:	8b 50 08             	mov    0x8(%eax),%edx
c0102f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f54:	8b 40 08             	mov    0x8(%eax),%eax
c0102f57:	01 c2                	add    %eax,%edx
c0102f59:	8b 45 08             	mov    0x8(%ebp),%eax
c0102f5c:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
c0102f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f62:	83 c0 04             	add    $0x4,%eax
c0102f65:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
c0102f6c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102f6f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0102f72:	8b 55 b8             	mov    -0x48(%ebp),%edx
c0102f75:	0f b3 10             	btr    %edx,(%eax)
}
c0102f78:	90                   	nop
            list_del(&(p->page_link));
c0102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102f7c:	83 c0 0c             	add    $0xc,%eax
c0102f7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
c0102f82:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0102f85:	8b 40 04             	mov    0x4(%eax),%eax
c0102f88:	8b 55 c4             	mov    -0x3c(%ebp),%edx
c0102f8b:	8b 12                	mov    (%edx),%edx
c0102f8d:	89 55 c0             	mov    %edx,-0x40(%ebp)
c0102f90:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
c0102f93:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0102f96:	8b 55 bc             	mov    -0x44(%ebp),%edx
c0102f99:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c0102f9c:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0102f9f:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0102fa2:	89 10                	mov    %edx,(%eax)
}
c0102fa4:	90                   	nop
}
c0102fa5:	90                   	nop
c0102fa6:	eb 7d                	jmp    c0103025 <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
c0102fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fab:	8b 50 08             	mov    0x8(%eax),%edx
c0102fae:	89 d0                	mov    %edx,%eax
c0102fb0:	c1 e0 02             	shl    $0x2,%eax
c0102fb3:	01 d0                	add    %edx,%eax
c0102fb5:	c1 e0 02             	shl    $0x2,%eax
c0102fb8:	89 c2                	mov    %eax,%edx
c0102fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fbd:	01 d0                	add    %edx,%eax
c0102fbf:	39 45 08             	cmp    %eax,0x8(%ebp)
c0102fc2:	75 61                	jne    c0103025 <default_free_pages+0x23e>
            // 如果当前Page p能和base头连上，则进行两个空闲块的合并
            p->property += base->property;
c0102fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fc7:	8b 50 08             	mov    0x8(%eax),%edx
c0102fca:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fcd:	8b 40 08             	mov    0x8(%eax),%eax
c0102fd0:	01 c2                	add    %eax,%edx
c0102fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102fd5:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
c0102fd8:	8b 45 08             	mov    0x8(%ebp),%eax
c0102fdb:	83 c0 04             	add    $0x4,%eax
c0102fde:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
c0102fe5:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c0102fe8:	8b 45 a0             	mov    -0x60(%ebp),%eax
c0102feb:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c0102fee:	0f b3 10             	btr    %edx,(%eax)
}
c0102ff1:	90                   	nop
            base = p;
c0102ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ff5:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
c0102ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0102ffb:	83 c0 0c             	add    $0xc,%eax
c0102ffe:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
c0103001:	8b 45 b0             	mov    -0x50(%ebp),%eax
c0103004:	8b 40 04             	mov    0x4(%eax),%eax
c0103007:	8b 55 b0             	mov    -0x50(%ebp),%edx
c010300a:	8b 12                	mov    (%edx),%edx
c010300c:	89 55 ac             	mov    %edx,-0x54(%ebp)
c010300f:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
c0103012:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0103015:	8b 55 a8             	mov    -0x58(%ebp),%edx
c0103018:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
c010301b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010301e:	8b 55 ac             	mov    -0x54(%ebp),%edx
c0103021:	89 10                	mov    %edx,(%eax)
}
c0103023:	90                   	nop
}
c0103024:	90                   	nop
    while (le != &free_list) {
c0103025:	81 7d f0 e0 ce 11 c0 	cmpl   $0xc011cee0,-0x10(%ebp)
c010302c:	0f 85 e5 fe ff ff    	jne    c0102f17 <default_free_pages+0x130>
        }
    }
    // 空闲链表整体空闲页数量自增n
    nr_free += n;
c0103032:	8b 15 e8 ce 11 c0    	mov    0xc011cee8,%edx
c0103038:	8b 45 0c             	mov    0xc(%ebp),%eax
c010303b:	01 d0                	add    %edx,%eax
c010303d:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8
c0103042:	c7 45 9c e0 ce 11 c0 	movl   $0xc011cee0,-0x64(%ebp)
    return listelm->next;
c0103049:	8b 45 9c             	mov    -0x64(%ebp),%eax
c010304c:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
c010304f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    // 迭代空闲链表中的每一个节点
    while (le != &free_list) {
c0103052:	eb 74                	jmp    c01030c8 <default_free_pages+0x2e1>
        // 转为Page结构
        p = le2page(le, page_link);
c0103054:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103057:	83 e8 0c             	sub    $0xc,%eax
c010305a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
c010305d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103060:	8b 50 08             	mov    0x8(%eax),%edx
c0103063:	89 d0                	mov    %edx,%eax
c0103065:	c1 e0 02             	shl    $0x2,%eax
c0103068:	01 d0                	add    %edx,%eax
c010306a:	c1 e0 02             	shl    $0x2,%eax
c010306d:	89 c2                	mov    %eax,%edx
c010306f:	8b 45 08             	mov    0x8(%ebp),%eax
c0103072:	01 d0                	add    %edx,%eax
c0103074:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103077:	72 40                	jb     c01030b9 <default_free_pages+0x2d2>
            // 进行空闲链表结构的校验，不能存在交叉覆盖的地方
            assert(base + base->property != p);
c0103079:	8b 45 08             	mov    0x8(%ebp),%eax
c010307c:	8b 50 08             	mov    0x8(%eax),%edx
c010307f:	89 d0                	mov    %edx,%eax
c0103081:	c1 e0 02             	shl    $0x2,%eax
c0103084:	01 d0                	add    %edx,%eax
c0103086:	c1 e0 02             	shl    $0x2,%eax
c0103089:	89 c2                	mov    %eax,%edx
c010308b:	8b 45 08             	mov    0x8(%ebp),%eax
c010308e:	01 d0                	add    %edx,%eax
c0103090:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0103093:	75 3e                	jne    c01030d3 <default_free_pages+0x2ec>
c0103095:	c7 44 24 0c b9 69 10 	movl   $0xc01069b9,0xc(%esp)
c010309c:	c0 
c010309d:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01030a4:	c0 
c01030a5:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
c01030ac:	00 
c01030ad:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01030b4:	e8 2e dc ff ff       	call   c0100ce7 <__panic>
c01030b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030bc:	89 45 98             	mov    %eax,-0x68(%ebp)
c01030bf:	8b 45 98             	mov    -0x68(%ebp),%eax
c01030c2:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
c01030c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
c01030c8:	81 7d f0 e0 ce 11 c0 	cmpl   $0xc011cee0,-0x10(%ebp)
c01030cf:	75 83                	jne    c0103054 <default_free_pages+0x26d>
c01030d1:	eb 01                	jmp    c01030d4 <default_free_pages+0x2ed>
            break;
c01030d3:	90                   	nop
    }
    // 将base加入到空闲链表之中
    list_add_before(le, &(base->page_link));
c01030d4:	8b 45 08             	mov    0x8(%ebp),%eax
c01030d7:	8d 50 0c             	lea    0xc(%eax),%edx
c01030da:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01030dd:	89 45 94             	mov    %eax,-0x6c(%ebp)
c01030e0:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
c01030e3:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01030e6:	8b 00                	mov    (%eax),%eax
c01030e8:	8b 55 90             	mov    -0x70(%ebp),%edx
c01030eb:	89 55 8c             	mov    %edx,-0x74(%ebp)
c01030ee:	89 45 88             	mov    %eax,-0x78(%ebp)
c01030f1:	8b 45 94             	mov    -0x6c(%ebp),%eax
c01030f4:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
c01030f7:	8b 45 84             	mov    -0x7c(%ebp),%eax
c01030fa:	8b 55 8c             	mov    -0x74(%ebp),%edx
c01030fd:	89 10                	mov    %edx,(%eax)
c01030ff:	8b 45 84             	mov    -0x7c(%ebp),%eax
c0103102:	8b 10                	mov    (%eax),%edx
c0103104:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103107:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
c010310a:	8b 45 8c             	mov    -0x74(%ebp),%eax
c010310d:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103110:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
c0103113:	8b 45 8c             	mov    -0x74(%ebp),%eax
c0103116:	8b 55 88             	mov    -0x78(%ebp),%edx
c0103119:	89 10                	mov    %edx,(%eax)
}
c010311b:	90                   	nop
}
c010311c:	90                   	nop
}
c010311d:	90                   	nop
c010311e:	89 ec                	mov    %ebp,%esp
c0103120:	5d                   	pop    %ebp
c0103121:	c3                   	ret    

c0103122 <default_nr_free_pages>:


static size_t
default_nr_free_pages(void) {
c0103122:	55                   	push   %ebp
c0103123:	89 e5                	mov    %esp,%ebp
    return nr_free;
c0103125:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
}
c010312a:	5d                   	pop    %ebp
c010312b:	c3                   	ret    

c010312c <basic_check>:

static void
basic_check(void) {
c010312c:	55                   	push   %ebp
c010312d:	89 e5                	mov    %esp,%ebp
c010312f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
c0103132:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c0103139:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010313c:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010313f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103142:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
c0103145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010314c:	e8 ed 0e 00 00       	call   c010403e <alloc_pages>
c0103151:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103154:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c0103158:	75 24                	jne    c010317e <basic_check+0x52>
c010315a:	c7 44 24 0c d4 69 10 	movl   $0xc01069d4,0xc(%esp)
c0103161:	c0 
c0103162:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103169:	c0 
c010316a:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
c0103171:	00 
c0103172:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103179:	e8 69 db ff ff       	call   c0100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
c010317e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103185:	e8 b4 0e 00 00       	call   c010403e <alloc_pages>
c010318a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010318d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103191:	75 24                	jne    c01031b7 <basic_check+0x8b>
c0103193:	c7 44 24 0c f0 69 10 	movl   $0xc01069f0,0xc(%esp)
c010319a:	c0 
c010319b:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01031a2:	c0 
c01031a3:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
c01031aa:	00 
c01031ab:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01031b2:	e8 30 db ff ff       	call   c0100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01031b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01031be:	e8 7b 0e 00 00       	call   c010403e <alloc_pages>
c01031c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01031c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01031ca:	75 24                	jne    c01031f0 <basic_check+0xc4>
c01031cc:	c7 44 24 0c 0c 6a 10 	movl   $0xc0106a0c,0xc(%esp)
c01031d3:	c0 
c01031d4:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01031db:	c0 
c01031dc:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
c01031e3:	00 
c01031e4:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01031eb:	e8 f7 da ff ff       	call   c0100ce7 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
c01031f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
c01031f6:	74 10                	je     c0103208 <basic_check+0xdc>
c01031f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01031fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c01031fe:	74 08                	je     c0103208 <basic_check+0xdc>
c0103200:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103203:	3b 45 f4             	cmp    -0xc(%ebp),%eax
c0103206:	75 24                	jne    c010322c <basic_check+0x100>
c0103208:	c7 44 24 0c 28 6a 10 	movl   $0xc0106a28,0xc(%esp)
c010320f:	c0 
c0103210:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103217:	c0 
c0103218:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
c010321f:	00 
c0103220:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103227:	e8 bb da ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
c010322c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010322f:	89 04 24             	mov    %eax,(%esp)
c0103232:	e8 7a f8 ff ff       	call   c0102ab1 <page_ref>
c0103237:	85 c0                	test   %eax,%eax
c0103239:	75 1e                	jne    c0103259 <basic_check+0x12d>
c010323b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010323e:	89 04 24             	mov    %eax,(%esp)
c0103241:	e8 6b f8 ff ff       	call   c0102ab1 <page_ref>
c0103246:	85 c0                	test   %eax,%eax
c0103248:	75 0f                	jne    c0103259 <basic_check+0x12d>
c010324a:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010324d:	89 04 24             	mov    %eax,(%esp)
c0103250:	e8 5c f8 ff ff       	call   c0102ab1 <page_ref>
c0103255:	85 c0                	test   %eax,%eax
c0103257:	74 24                	je     c010327d <basic_check+0x151>
c0103259:	c7 44 24 0c 4c 6a 10 	movl   $0xc0106a4c,0xc(%esp)
c0103260:	c0 
c0103261:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103268:	c0 
c0103269:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
c0103270:	00 
c0103271:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103278:	e8 6a da ff ff       	call   c0100ce7 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
c010327d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103280:	89 04 24             	mov    %eax,(%esp)
c0103283:	e8 11 f8 ff ff       	call   c0102a99 <page2pa>
c0103288:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c010328e:	c1 e2 0c             	shl    $0xc,%edx
c0103291:	39 d0                	cmp    %edx,%eax
c0103293:	72 24                	jb     c01032b9 <basic_check+0x18d>
c0103295:	c7 44 24 0c 88 6a 10 	movl   $0xc0106a88,0xc(%esp)
c010329c:	c0 
c010329d:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01032a4:	c0 
c01032a5:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
c01032ac:	00 
c01032ad:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01032b4:	e8 2e da ff ff       	call   c0100ce7 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
c01032b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01032bc:	89 04 24             	mov    %eax,(%esp)
c01032bf:	e8 d5 f7 ff ff       	call   c0102a99 <page2pa>
c01032c4:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c01032ca:	c1 e2 0c             	shl    $0xc,%edx
c01032cd:	39 d0                	cmp    %edx,%eax
c01032cf:	72 24                	jb     c01032f5 <basic_check+0x1c9>
c01032d1:	c7 44 24 0c a5 6a 10 	movl   $0xc0106aa5,0xc(%esp)
c01032d8:	c0 
c01032d9:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01032e0:	c0 
c01032e1:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
c01032e8:	00 
c01032e9:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01032f0:	e8 f2 d9 ff ff       	call   c0100ce7 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
c01032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01032f8:	89 04 24             	mov    %eax,(%esp)
c01032fb:	e8 99 f7 ff ff       	call   c0102a99 <page2pa>
c0103300:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c0103306:	c1 e2 0c             	shl    $0xc,%edx
c0103309:	39 d0                	cmp    %edx,%eax
c010330b:	72 24                	jb     c0103331 <basic_check+0x205>
c010330d:	c7 44 24 0c c2 6a 10 	movl   $0xc0106ac2,0xc(%esp)
c0103314:	c0 
c0103315:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c010331c:	c0 
c010331d:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
c0103324:	00 
c0103325:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c010332c:	e8 b6 d9 ff ff       	call   c0100ce7 <__panic>

    list_entry_t free_list_store = free_list;
c0103331:	a1 e0 ce 11 c0       	mov    0xc011cee0,%eax
c0103336:	8b 15 e4 ce 11 c0    	mov    0xc011cee4,%edx
c010333c:	89 45 d0             	mov    %eax,-0x30(%ebp)
c010333f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0103342:	c7 45 dc e0 ce 11 c0 	movl   $0xc011cee0,-0x24(%ebp)
    elm->prev = elm->next = elm;
c0103349:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010334c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010334f:	89 50 04             	mov    %edx,0x4(%eax)
c0103352:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103355:	8b 50 04             	mov    0x4(%eax),%edx
c0103358:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010335b:	89 10                	mov    %edx,(%eax)
}
c010335d:	90                   	nop
c010335e:	c7 45 e0 e0 ce 11 c0 	movl   $0xc011cee0,-0x20(%ebp)
    return list->next == list;
c0103365:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103368:	8b 40 04             	mov    0x4(%eax),%eax
c010336b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c010336e:	0f 94 c0             	sete   %al
c0103371:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103374:	85 c0                	test   %eax,%eax
c0103376:	75 24                	jne    c010339c <basic_check+0x270>
c0103378:	c7 44 24 0c df 6a 10 	movl   $0xc0106adf,0xc(%esp)
c010337f:	c0 
c0103380:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103387:	c0 
c0103388:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
c010338f:	00 
c0103390:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103397:	e8 4b d9 ff ff       	call   c0100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
c010339c:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c01033a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
c01033a4:	c7 05 e8 ce 11 c0 00 	movl   $0x0,0xc011cee8
c01033ab:	00 00 00 

    assert(alloc_page() == NULL);
c01033ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01033b5:	e8 84 0c 00 00       	call   c010403e <alloc_pages>
c01033ba:	85 c0                	test   %eax,%eax
c01033bc:	74 24                	je     c01033e2 <basic_check+0x2b6>
c01033be:	c7 44 24 0c f6 6a 10 	movl   $0xc0106af6,0xc(%esp)
c01033c5:	c0 
c01033c6:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01033cd:	c0 
c01033ce:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
c01033d5:	00 
c01033d6:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01033dd:	e8 05 d9 ff ff       	call   c0100ce7 <__panic>

    free_page(p0);
c01033e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033e9:	00 
c01033ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01033ed:	89 04 24             	mov    %eax,(%esp)
c01033f0:	e8 83 0c 00 00       	call   c0104078 <free_pages>
    free_page(p1);
c01033f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01033fc:	00 
c01033fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0103400:	89 04 24             	mov    %eax,(%esp)
c0103403:	e8 70 0c 00 00       	call   c0104078 <free_pages>
    free_page(p2);
c0103408:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010340f:	00 
c0103410:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103413:	89 04 24             	mov    %eax,(%esp)
c0103416:	e8 5d 0c 00 00       	call   c0104078 <free_pages>
    assert(nr_free == 3);
c010341b:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0103420:	83 f8 03             	cmp    $0x3,%eax
c0103423:	74 24                	je     c0103449 <basic_check+0x31d>
c0103425:	c7 44 24 0c 0b 6b 10 	movl   $0xc0106b0b,0xc(%esp)
c010342c:	c0 
c010342d:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103434:	c0 
c0103435:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
c010343c:	00 
c010343d:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103444:	e8 9e d8 ff ff       	call   c0100ce7 <__panic>

    assert((p0 = alloc_page()) != NULL);
c0103449:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103450:	e8 e9 0b 00 00       	call   c010403e <alloc_pages>
c0103455:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103458:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
c010345c:	75 24                	jne    c0103482 <basic_check+0x356>
c010345e:	c7 44 24 0c d4 69 10 	movl   $0xc01069d4,0xc(%esp)
c0103465:	c0 
c0103466:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c010346d:	c0 
c010346e:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
c0103475:	00 
c0103476:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c010347d:	e8 65 d8 ff ff       	call   c0100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
c0103482:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103489:	e8 b0 0b 00 00       	call   c010403e <alloc_pages>
c010348e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103491:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103495:	75 24                	jne    c01034bb <basic_check+0x38f>
c0103497:	c7 44 24 0c f0 69 10 	movl   $0xc01069f0,0xc(%esp)
c010349e:	c0 
c010349f:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01034a6:	c0 
c01034a7:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
c01034ae:	00 
c01034af:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01034b6:	e8 2c d8 ff ff       	call   c0100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
c01034bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034c2:	e8 77 0b 00 00       	call   c010403e <alloc_pages>
c01034c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01034ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01034ce:	75 24                	jne    c01034f4 <basic_check+0x3c8>
c01034d0:	c7 44 24 0c 0c 6a 10 	movl   $0xc0106a0c,0xc(%esp)
c01034d7:	c0 
c01034d8:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01034df:	c0 
c01034e0:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
c01034e7:	00 
c01034e8:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01034ef:	e8 f3 d7 ff ff       	call   c0100ce7 <__panic>

    assert(alloc_page() == NULL);
c01034f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01034fb:	e8 3e 0b 00 00       	call   c010403e <alloc_pages>
c0103500:	85 c0                	test   %eax,%eax
c0103502:	74 24                	je     c0103528 <basic_check+0x3fc>
c0103504:	c7 44 24 0c f6 6a 10 	movl   $0xc0106af6,0xc(%esp)
c010350b:	c0 
c010350c:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103513:	c0 
c0103514:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
c010351b:	00 
c010351c:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103523:	e8 bf d7 ff ff       	call   c0100ce7 <__panic>

    free_page(p0);
c0103528:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010352f:	00 
c0103530:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103533:	89 04 24             	mov    %eax,(%esp)
c0103536:	e8 3d 0b 00 00       	call   c0104078 <free_pages>
c010353b:	c7 45 d8 e0 ce 11 c0 	movl   $0xc011cee0,-0x28(%ebp)
c0103542:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103545:	8b 40 04             	mov    0x4(%eax),%eax
c0103548:	39 45 d8             	cmp    %eax,-0x28(%ebp)
c010354b:	0f 94 c0             	sete   %al
c010354e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
c0103551:	85 c0                	test   %eax,%eax
c0103553:	74 24                	je     c0103579 <basic_check+0x44d>
c0103555:	c7 44 24 0c 18 6b 10 	movl   $0xc0106b18,0xc(%esp)
c010355c:	c0 
c010355d:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103564:	c0 
c0103565:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
c010356c:	00 
c010356d:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103574:	e8 6e d7 ff ff       	call   c0100ce7 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
c0103579:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103580:	e8 b9 0a 00 00       	call   c010403e <alloc_pages>
c0103585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0103588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010358b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c010358e:	74 24                	je     c01035b4 <basic_check+0x488>
c0103590:	c7 44 24 0c 30 6b 10 	movl   $0xc0106b30,0xc(%esp)
c0103597:	c0 
c0103598:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c010359f:	c0 
c01035a0:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
c01035a7:	00 
c01035a8:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01035af:	e8 33 d7 ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c01035b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01035bb:	e8 7e 0a 00 00       	call   c010403e <alloc_pages>
c01035c0:	85 c0                	test   %eax,%eax
c01035c2:	74 24                	je     c01035e8 <basic_check+0x4bc>
c01035c4:	c7 44 24 0c f6 6a 10 	movl   $0xc0106af6,0xc(%esp)
c01035cb:	c0 
c01035cc:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01035d3:	c0 
c01035d4:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
c01035db:	00 
c01035dc:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01035e3:	e8 ff d6 ff ff       	call   c0100ce7 <__panic>

    assert(nr_free == 0);
c01035e8:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c01035ed:	85 c0                	test   %eax,%eax
c01035ef:	74 24                	je     c0103615 <basic_check+0x4e9>
c01035f1:	c7 44 24 0c 49 6b 10 	movl   $0xc0106b49,0xc(%esp)
c01035f8:	c0 
c01035f9:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103600:	c0 
c0103601:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
c0103608:	00 
c0103609:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103610:	e8 d2 d6 ff ff       	call   c0100ce7 <__panic>
    free_list = free_list_store;
c0103615:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0103618:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010361b:	a3 e0 ce 11 c0       	mov    %eax,0xc011cee0
c0103620:	89 15 e4 ce 11 c0    	mov    %edx,0xc011cee4
    nr_free = nr_free_store;
c0103626:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103629:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8

    free_page(p);
c010362e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103635:	00 
c0103636:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103639:	89 04 24             	mov    %eax,(%esp)
c010363c:	e8 37 0a 00 00       	call   c0104078 <free_pages>
    free_page(p1);
c0103641:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103648:	00 
c0103649:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010364c:	89 04 24             	mov    %eax,(%esp)
c010364f:	e8 24 0a 00 00       	call   c0104078 <free_pages>
    free_page(p2);
c0103654:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010365b:	00 
c010365c:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010365f:	89 04 24             	mov    %eax,(%esp)
c0103662:	e8 11 0a 00 00       	call   c0104078 <free_pages>
}
c0103667:	90                   	nop
c0103668:	89 ec                	mov    %ebp,%esp
c010366a:	5d                   	pop    %ebp
c010366b:	c3                   	ret    

c010366c <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
c010366c:	55                   	push   %ebp
c010366d:	89 e5                	mov    %esp,%ebp
c010366f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
c0103675:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c010367c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
c0103683:	c7 45 ec e0 ce 11 c0 	movl   $0xc011cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c010368a:	eb 6a                	jmp    c01036f6 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
c010368c:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010368f:	83 e8 0c             	sub    $0xc,%eax
c0103692:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
c0103695:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0103698:	83 c0 04             	add    $0x4,%eax
c010369b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
c01036a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01036a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
c01036a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01036ab:	0f a3 10             	bt     %edx,(%eax)
c01036ae:	19 c0                	sbb    %eax,%eax
c01036b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
c01036b3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
c01036b7:	0f 95 c0             	setne  %al
c01036ba:	0f b6 c0             	movzbl %al,%eax
c01036bd:	85 c0                	test   %eax,%eax
c01036bf:	75 24                	jne    c01036e5 <default_check+0x79>
c01036c1:	c7 44 24 0c 56 6b 10 	movl   $0xc0106b56,0xc(%esp)
c01036c8:	c0 
c01036c9:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01036d0:	c0 
c01036d1:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
c01036d8:	00 
c01036d9:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01036e0:	e8 02 d6 ff ff       	call   c0100ce7 <__panic>
        count ++, total += p->property;
c01036e5:	ff 45 f4             	incl   -0xc(%ebp)
c01036e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c01036eb:	8b 50 08             	mov    0x8(%eax),%edx
c01036ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01036f1:	01 d0                	add    %edx,%eax
c01036f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01036f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01036f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
c01036fc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c01036ff:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103702:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103705:	81 7d ec e0 ce 11 c0 	cmpl   $0xc011cee0,-0x14(%ebp)
c010370c:	0f 85 7a ff ff ff    	jne    c010368c <default_check+0x20>
    }
    assert(total == nr_free_pages());
c0103712:	e8 96 09 00 00       	call   c01040ad <nr_free_pages>
c0103717:	8b 55 f0             	mov    -0x10(%ebp),%edx
c010371a:	39 d0                	cmp    %edx,%eax
c010371c:	74 24                	je     c0103742 <default_check+0xd6>
c010371e:	c7 44 24 0c 66 6b 10 	movl   $0xc0106b66,0xc(%esp)
c0103725:	c0 
c0103726:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c010372d:	c0 
c010372e:	c7 44 24 04 bc 01 00 	movl   $0x1bc,0x4(%esp)
c0103735:	00 
c0103736:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c010373d:	e8 a5 d5 ff ff       	call   c0100ce7 <__panic>

    basic_check();
c0103742:	e8 e5 f9 ff ff       	call   c010312c <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
c0103747:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c010374e:	e8 eb 08 00 00       	call   c010403e <alloc_pages>
c0103753:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
c0103756:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c010375a:	75 24                	jne    c0103780 <default_check+0x114>
c010375c:	c7 44 24 0c 7f 6b 10 	movl   $0xc0106b7f,0xc(%esp)
c0103763:	c0 
c0103764:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c010376b:	c0 
c010376c:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
c0103773:	00 
c0103774:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c010377b:	e8 67 d5 ff ff       	call   c0100ce7 <__panic>
    assert(!PageProperty(p0));
c0103780:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103783:	83 c0 04             	add    $0x4,%eax
c0103786:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
c010378d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103790:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0103793:	8b 55 c0             	mov    -0x40(%ebp),%edx
c0103796:	0f a3 10             	bt     %edx,(%eax)
c0103799:	19 c0                	sbb    %eax,%eax
c010379b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
c010379e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
c01037a2:	0f 95 c0             	setne  %al
c01037a5:	0f b6 c0             	movzbl %al,%eax
c01037a8:	85 c0                	test   %eax,%eax
c01037aa:	74 24                	je     c01037d0 <default_check+0x164>
c01037ac:	c7 44 24 0c 8a 6b 10 	movl   $0xc0106b8a,0xc(%esp)
c01037b3:	c0 
c01037b4:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01037bb:	c0 
c01037bc:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
c01037c3:	00 
c01037c4:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01037cb:	e8 17 d5 ff ff       	call   c0100ce7 <__panic>

    list_entry_t free_list_store = free_list;
c01037d0:	a1 e0 ce 11 c0       	mov    0xc011cee0,%eax
c01037d5:	8b 15 e4 ce 11 c0    	mov    0xc011cee4,%edx
c01037db:	89 45 80             	mov    %eax,-0x80(%ebp)
c01037de:	89 55 84             	mov    %edx,-0x7c(%ebp)
c01037e1:	c7 45 b0 e0 ce 11 c0 	movl   $0xc011cee0,-0x50(%ebp)
    elm->prev = elm->next = elm;
c01037e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01037eb:	8b 55 b0             	mov    -0x50(%ebp),%edx
c01037ee:	89 50 04             	mov    %edx,0x4(%eax)
c01037f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01037f4:	8b 50 04             	mov    0x4(%eax),%edx
c01037f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01037fa:	89 10                	mov    %edx,(%eax)
}
c01037fc:	90                   	nop
c01037fd:	c7 45 b4 e0 ce 11 c0 	movl   $0xc011cee0,-0x4c(%ebp)
    return list->next == list;
c0103804:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0103807:	8b 40 04             	mov    0x4(%eax),%eax
c010380a:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
c010380d:	0f 94 c0             	sete   %al
c0103810:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
c0103813:	85 c0                	test   %eax,%eax
c0103815:	75 24                	jne    c010383b <default_check+0x1cf>
c0103817:	c7 44 24 0c df 6a 10 	movl   $0xc0106adf,0xc(%esp)
c010381e:	c0 
c010381f:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103826:	c0 
c0103827:	c7 44 24 04 c6 01 00 	movl   $0x1c6,0x4(%esp)
c010382e:	00 
c010382f:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103836:	e8 ac d4 ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c010383b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103842:	e8 f7 07 00 00       	call   c010403e <alloc_pages>
c0103847:	85 c0                	test   %eax,%eax
c0103849:	74 24                	je     c010386f <default_check+0x203>
c010384b:	c7 44 24 0c f6 6a 10 	movl   $0xc0106af6,0xc(%esp)
c0103852:	c0 
c0103853:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c010385a:	c0 
c010385b:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
c0103862:	00 
c0103863:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c010386a:	e8 78 d4 ff ff       	call   c0100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
c010386f:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0103874:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
c0103877:	c7 05 e8 ce 11 c0 00 	movl   $0x0,0xc011cee8
c010387e:	00 00 00 

    free_pages(p0 + 2, 3);
c0103881:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103884:	83 c0 28             	add    $0x28,%eax
c0103887:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c010388e:	00 
c010388f:	89 04 24             	mov    %eax,(%esp)
c0103892:	e8 e1 07 00 00       	call   c0104078 <free_pages>
    assert(alloc_pages(4) == NULL);
c0103897:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
c010389e:	e8 9b 07 00 00       	call   c010403e <alloc_pages>
c01038a3:	85 c0                	test   %eax,%eax
c01038a5:	74 24                	je     c01038cb <default_check+0x25f>
c01038a7:	c7 44 24 0c 9c 6b 10 	movl   $0xc0106b9c,0xc(%esp)
c01038ae:	c0 
c01038af:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01038b6:	c0 
c01038b7:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
c01038be:	00 
c01038bf:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01038c6:	e8 1c d4 ff ff       	call   c0100ce7 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
c01038cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038ce:	83 c0 28             	add    $0x28,%eax
c01038d1:	83 c0 04             	add    $0x4,%eax
c01038d4:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
c01038db:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c01038de:	8b 45 a8             	mov    -0x58(%ebp),%eax
c01038e1:	8b 55 ac             	mov    -0x54(%ebp),%edx
c01038e4:	0f a3 10             	bt     %edx,(%eax)
c01038e7:	19 c0                	sbb    %eax,%eax
c01038e9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
c01038ec:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
c01038f0:	0f 95 c0             	setne  %al
c01038f3:	0f b6 c0             	movzbl %al,%eax
c01038f6:	85 c0                	test   %eax,%eax
c01038f8:	74 0e                	je     c0103908 <default_check+0x29c>
c01038fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01038fd:	83 c0 28             	add    $0x28,%eax
c0103900:	8b 40 08             	mov    0x8(%eax),%eax
c0103903:	83 f8 03             	cmp    $0x3,%eax
c0103906:	74 24                	je     c010392c <default_check+0x2c0>
c0103908:	c7 44 24 0c b4 6b 10 	movl   $0xc0106bb4,0xc(%esp)
c010390f:	c0 
c0103910:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103917:	c0 
c0103918:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
c010391f:	00 
c0103920:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103927:	e8 bb d3 ff ff       	call   c0100ce7 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
c010392c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
c0103933:	e8 06 07 00 00       	call   c010403e <alloc_pages>
c0103938:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010393b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010393f:	75 24                	jne    c0103965 <default_check+0x2f9>
c0103941:	c7 44 24 0c e0 6b 10 	movl   $0xc0106be0,0xc(%esp)
c0103948:	c0 
c0103949:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103950:	c0 
c0103951:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
c0103958:	00 
c0103959:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103960:	e8 82 d3 ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c0103965:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c010396c:	e8 cd 06 00 00       	call   c010403e <alloc_pages>
c0103971:	85 c0                	test   %eax,%eax
c0103973:	74 24                	je     c0103999 <default_check+0x32d>
c0103975:	c7 44 24 0c f6 6a 10 	movl   $0xc0106af6,0xc(%esp)
c010397c:	c0 
c010397d:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103984:	c0 
c0103985:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
c010398c:	00 
c010398d:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103994:	e8 4e d3 ff ff       	call   c0100ce7 <__panic>
    assert(p0 + 2 == p1);
c0103999:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010399c:	83 c0 28             	add    $0x28,%eax
c010399f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c01039a2:	74 24                	je     c01039c8 <default_check+0x35c>
c01039a4:	c7 44 24 0c fe 6b 10 	movl   $0xc0106bfe,0xc(%esp)
c01039ab:	c0 
c01039ac:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c01039b3:	c0 
c01039b4:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
c01039bb:	00 
c01039bc:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c01039c3:	e8 1f d3 ff ff       	call   c0100ce7 <__panic>

    p2 = p0 + 1;
c01039c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039cb:	83 c0 14             	add    $0x14,%eax
c01039ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
c01039d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01039d8:	00 
c01039d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039dc:	89 04 24             	mov    %eax,(%esp)
c01039df:	e8 94 06 00 00       	call   c0104078 <free_pages>
    free_pages(p1, 3);
c01039e4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
c01039eb:	00 
c01039ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01039ef:	89 04 24             	mov    %eax,(%esp)
c01039f2:	e8 81 06 00 00       	call   c0104078 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
c01039f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01039fa:	83 c0 04             	add    $0x4,%eax
c01039fd:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
c0103a04:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103a07:	8b 45 9c             	mov    -0x64(%ebp),%eax
c0103a0a:	8b 55 a0             	mov    -0x60(%ebp),%edx
c0103a0d:	0f a3 10             	bt     %edx,(%eax)
c0103a10:	19 c0                	sbb    %eax,%eax
c0103a12:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
c0103a15:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
c0103a19:	0f 95 c0             	setne  %al
c0103a1c:	0f b6 c0             	movzbl %al,%eax
c0103a1f:	85 c0                	test   %eax,%eax
c0103a21:	74 0b                	je     c0103a2e <default_check+0x3c2>
c0103a23:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103a26:	8b 40 08             	mov    0x8(%eax),%eax
c0103a29:	83 f8 01             	cmp    $0x1,%eax
c0103a2c:	74 24                	je     c0103a52 <default_check+0x3e6>
c0103a2e:	c7 44 24 0c 0c 6c 10 	movl   $0xc0106c0c,0xc(%esp)
c0103a35:	c0 
c0103a36:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103a3d:	c0 
c0103a3e:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
c0103a45:	00 
c0103a46:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103a4d:	e8 95 d2 ff ff       	call   c0100ce7 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
c0103a52:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a55:	83 c0 04             	add    $0x4,%eax
c0103a58:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
c0103a5f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
c0103a62:	8b 45 90             	mov    -0x70(%ebp),%eax
c0103a65:	8b 55 94             	mov    -0x6c(%ebp),%edx
c0103a68:	0f a3 10             	bt     %edx,(%eax)
c0103a6b:	19 c0                	sbb    %eax,%eax
c0103a6d:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
c0103a70:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
c0103a74:	0f 95 c0             	setne  %al
c0103a77:	0f b6 c0             	movzbl %al,%eax
c0103a7a:	85 c0                	test   %eax,%eax
c0103a7c:	74 0b                	je     c0103a89 <default_check+0x41d>
c0103a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0103a81:	8b 40 08             	mov    0x8(%eax),%eax
c0103a84:	83 f8 03             	cmp    $0x3,%eax
c0103a87:	74 24                	je     c0103aad <default_check+0x441>
c0103a89:	c7 44 24 0c 34 6c 10 	movl   $0xc0106c34,0xc(%esp)
c0103a90:	c0 
c0103a91:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103a98:	c0 
c0103a99:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
c0103aa0:	00 
c0103aa1:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103aa8:	e8 3a d2 ff ff       	call   c0100ce7 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
c0103aad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ab4:	e8 85 05 00 00       	call   c010403e <alloc_pages>
c0103ab9:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103abc:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103abf:	83 e8 14             	sub    $0x14,%eax
c0103ac2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103ac5:	74 24                	je     c0103aeb <default_check+0x47f>
c0103ac7:	c7 44 24 0c 5a 6c 10 	movl   $0xc0106c5a,0xc(%esp)
c0103ace:	c0 
c0103acf:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103ad6:	c0 
c0103ad7:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
c0103ade:	00 
c0103adf:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103ae6:	e8 fc d1 ff ff       	call   c0100ce7 <__panic>
    free_page(p0);
c0103aeb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103af2:	00 
c0103af3:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103af6:	89 04 24             	mov    %eax,(%esp)
c0103af9:	e8 7a 05 00 00       	call   c0104078 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
c0103afe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
c0103b05:	e8 34 05 00 00       	call   c010403e <alloc_pages>
c0103b0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b10:	83 c0 14             	add    $0x14,%eax
c0103b13:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0103b16:	74 24                	je     c0103b3c <default_check+0x4d0>
c0103b18:	c7 44 24 0c 78 6c 10 	movl   $0xc0106c78,0xc(%esp)
c0103b1f:	c0 
c0103b20:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103b27:	c0 
c0103b28:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
c0103b2f:	00 
c0103b30:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103b37:	e8 ab d1 ff ff       	call   c0100ce7 <__panic>

    free_pages(p0, 2);
c0103b3c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
c0103b43:	00 
c0103b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103b47:	89 04 24             	mov    %eax,(%esp)
c0103b4a:	e8 29 05 00 00       	call   c0104078 <free_pages>
    free_page(p2);
c0103b4f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0103b56:	00 
c0103b57:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0103b5a:	89 04 24             	mov    %eax,(%esp)
c0103b5d:	e8 16 05 00 00       	call   c0104078 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
c0103b62:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
c0103b69:	e8 d0 04 00 00       	call   c010403e <alloc_pages>
c0103b6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0103b71:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0103b75:	75 24                	jne    c0103b9b <default_check+0x52f>
c0103b77:	c7 44 24 0c 98 6c 10 	movl   $0xc0106c98,0xc(%esp)
c0103b7e:	c0 
c0103b7f:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103b86:	c0 
c0103b87:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
c0103b8e:	00 
c0103b8f:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103b96:	e8 4c d1 ff ff       	call   c0100ce7 <__panic>
    assert(alloc_page() == NULL);
c0103b9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0103ba2:	e8 97 04 00 00       	call   c010403e <alloc_pages>
c0103ba7:	85 c0                	test   %eax,%eax
c0103ba9:	74 24                	je     c0103bcf <default_check+0x563>
c0103bab:	c7 44 24 0c f6 6a 10 	movl   $0xc0106af6,0xc(%esp)
c0103bb2:	c0 
c0103bb3:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103bba:	c0 
c0103bbb:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
c0103bc2:	00 
c0103bc3:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103bca:	e8 18 d1 ff ff       	call   c0100ce7 <__panic>

    assert(nr_free == 0);
c0103bcf:	a1 e8 ce 11 c0       	mov    0xc011cee8,%eax
c0103bd4:	85 c0                	test   %eax,%eax
c0103bd6:	74 24                	je     c0103bfc <default_check+0x590>
c0103bd8:	c7 44 24 0c 49 6b 10 	movl   $0xc0106b49,0xc(%esp)
c0103bdf:	c0 
c0103be0:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103be7:	c0 
c0103be8:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
c0103bef:	00 
c0103bf0:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103bf7:	e8 eb d0 ff ff       	call   c0100ce7 <__panic>
    nr_free = nr_free_store;
c0103bfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0103bff:	a3 e8 ce 11 c0       	mov    %eax,0xc011cee8

    free_list = free_list_store;
c0103c04:	8b 45 80             	mov    -0x80(%ebp),%eax
c0103c07:	8b 55 84             	mov    -0x7c(%ebp),%edx
c0103c0a:	a3 e0 ce 11 c0       	mov    %eax,0xc011cee0
c0103c0f:	89 15 e4 ce 11 c0    	mov    %edx,0xc011cee4
    free_pages(p0, 5);
c0103c15:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
c0103c1c:	00 
c0103c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0103c20:	89 04 24             	mov    %eax,(%esp)
c0103c23:	e8 50 04 00 00       	call   c0104078 <free_pages>

    le = &free_list;
c0103c28:	c7 45 ec e0 ce 11 c0 	movl   $0xc011cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
c0103c2f:	eb 5a                	jmp    c0103c8b <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
c0103c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c34:	8b 40 04             	mov    0x4(%eax),%eax
c0103c37:	8b 00                	mov    (%eax),%eax
c0103c39:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103c3c:	75 0d                	jne    c0103c4b <default_check+0x5df>
c0103c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c41:	8b 00                	mov    (%eax),%eax
c0103c43:	8b 40 04             	mov    0x4(%eax),%eax
c0103c46:	39 45 ec             	cmp    %eax,-0x14(%ebp)
c0103c49:	74 24                	je     c0103c6f <default_check+0x603>
c0103c4b:	c7 44 24 0c b8 6c 10 	movl   $0xc0106cb8,0xc(%esp)
c0103c52:	c0 
c0103c53:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103c5a:	c0 
c0103c5b:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
c0103c62:	00 
c0103c63:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103c6a:	e8 78 d0 ff ff       	call   c0100ce7 <__panic>
        struct Page *p = le2page(le, page_link);
c0103c6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c72:	83 e8 0c             	sub    $0xc,%eax
c0103c75:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
c0103c78:	ff 4d f4             	decl   -0xc(%ebp)
c0103c7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0103c7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
c0103c81:	8b 48 08             	mov    0x8(%eax),%ecx
c0103c84:	89 d0                	mov    %edx,%eax
c0103c86:	29 c8                	sub    %ecx,%eax
c0103c88:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0103c8e:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
c0103c91:	8b 45 88             	mov    -0x78(%ebp),%eax
c0103c94:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
c0103c97:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0103c9a:	81 7d ec e0 ce 11 c0 	cmpl   $0xc011cee0,-0x14(%ebp)
c0103ca1:	75 8e                	jne    c0103c31 <default_check+0x5c5>
    }
    assert(count == 0);
c0103ca3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0103ca7:	74 24                	je     c0103ccd <default_check+0x661>
c0103ca9:	c7 44 24 0c e5 6c 10 	movl   $0xc0106ce5,0xc(%esp)
c0103cb0:	c0 
c0103cb1:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103cb8:	c0 
c0103cb9:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
c0103cc0:	00 
c0103cc1:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103cc8:	e8 1a d0 ff ff       	call   c0100ce7 <__panic>
    assert(total == 0);
c0103ccd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0103cd1:	74 24                	je     c0103cf7 <default_check+0x68b>
c0103cd3:	c7 44 24 0c f0 6c 10 	movl   $0xc0106cf0,0xc(%esp)
c0103cda:	c0 
c0103cdb:	c7 44 24 08 56 69 10 	movl   $0xc0106956,0x8(%esp)
c0103ce2:	c0 
c0103ce3:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
c0103cea:	00 
c0103ceb:	c7 04 24 6b 69 10 c0 	movl   $0xc010696b,(%esp)
c0103cf2:	e8 f0 cf ff ff       	call   c0100ce7 <__panic>
}
c0103cf7:	90                   	nop
c0103cf8:	89 ec                	mov    %ebp,%esp
c0103cfa:	5d                   	pop    %ebp
c0103cfb:	c3                   	ret    

c0103cfc <page2ppn>:
page2ppn(struct Page *page) {
c0103cfc:	55                   	push   %ebp
c0103cfd:	89 e5                	mov    %esp,%ebp
    return page - pages;
c0103cff:	8b 15 00 cf 11 c0    	mov    0xc011cf00,%edx
c0103d05:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d08:	29 d0                	sub    %edx,%eax
c0103d0a:	c1 f8 02             	sar    $0x2,%eax
c0103d0d:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
c0103d13:	5d                   	pop    %ebp
c0103d14:	c3                   	ret    

c0103d15 <page2pa>:
page2pa(struct Page *page) {
c0103d15:	55                   	push   %ebp
c0103d16:	89 e5                	mov    %esp,%ebp
c0103d18:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
c0103d1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d1e:	89 04 24             	mov    %eax,(%esp)
c0103d21:	e8 d6 ff ff ff       	call   c0103cfc <page2ppn>
c0103d26:	c1 e0 0c             	shl    $0xc,%eax
}
c0103d29:	89 ec                	mov    %ebp,%esp
c0103d2b:	5d                   	pop    %ebp
c0103d2c:	c3                   	ret    

c0103d2d <pa2page>:
pa2page(uintptr_t pa) {
c0103d2d:	55                   	push   %ebp
c0103d2e:	89 e5                	mov    %esp,%ebp
c0103d30:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
c0103d33:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d36:	c1 e8 0c             	shr    $0xc,%eax
c0103d39:	89 c2                	mov    %eax,%edx
c0103d3b:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0103d40:	39 c2                	cmp    %eax,%edx
c0103d42:	72 1c                	jb     c0103d60 <pa2page+0x33>
        panic("pa2page called with invalid pa");
c0103d44:	c7 44 24 08 2c 6d 10 	movl   $0xc0106d2c,0x8(%esp)
c0103d4b:	c0 
c0103d4c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
c0103d53:	00 
c0103d54:	c7 04 24 4b 6d 10 c0 	movl   $0xc0106d4b,(%esp)
c0103d5b:	e8 87 cf ff ff       	call   c0100ce7 <__panic>
    return &pages[PPN(pa)];
c0103d60:	8b 0d 00 cf 11 c0    	mov    0xc011cf00,%ecx
c0103d66:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d69:	c1 e8 0c             	shr    $0xc,%eax
c0103d6c:	89 c2                	mov    %eax,%edx
c0103d6e:	89 d0                	mov    %edx,%eax
c0103d70:	c1 e0 02             	shl    $0x2,%eax
c0103d73:	01 d0                	add    %edx,%eax
c0103d75:	c1 e0 02             	shl    $0x2,%eax
c0103d78:	01 c8                	add    %ecx,%eax
}
c0103d7a:	89 ec                	mov    %ebp,%esp
c0103d7c:	5d                   	pop    %ebp
c0103d7d:	c3                   	ret    

c0103d7e <page2kva>:
page2kva(struct Page *page) {
c0103d7e:	55                   	push   %ebp
c0103d7f:	89 e5                	mov    %esp,%ebp
c0103d81:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
c0103d84:	8b 45 08             	mov    0x8(%ebp),%eax
c0103d87:	89 04 24             	mov    %eax,(%esp)
c0103d8a:	e8 86 ff ff ff       	call   c0103d15 <page2pa>
c0103d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0103d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103d95:	c1 e8 0c             	shr    $0xc,%eax
c0103d98:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0103d9b:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0103da0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0103da3:	72 23                	jb     c0103dc8 <page2kva+0x4a>
c0103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103da8:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0103dac:	c7 44 24 08 5c 6d 10 	movl   $0xc0106d5c,0x8(%esp)
c0103db3:	c0 
c0103db4:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
c0103dbb:	00 
c0103dbc:	c7 04 24 4b 6d 10 c0 	movl   $0xc0106d4b,(%esp)
c0103dc3:	e8 1f cf ff ff       	call   c0100ce7 <__panic>
c0103dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0103dcb:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
c0103dd0:	89 ec                	mov    %ebp,%esp
c0103dd2:	5d                   	pop    %ebp
c0103dd3:	c3                   	ret    

c0103dd4 <pte2page>:
pte2page(pte_t pte) {
c0103dd4:	55                   	push   %ebp
c0103dd5:	89 e5                	mov    %esp,%ebp
c0103dd7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
c0103dda:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ddd:	83 e0 01             	and    $0x1,%eax
c0103de0:	85 c0                	test   %eax,%eax
c0103de2:	75 1c                	jne    c0103e00 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
c0103de4:	c7 44 24 08 80 6d 10 	movl   $0xc0106d80,0x8(%esp)
c0103deb:	c0 
c0103dec:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
c0103df3:	00 
c0103df4:	c7 04 24 4b 6d 10 c0 	movl   $0xc0106d4b,(%esp)
c0103dfb:	e8 e7 ce ff ff       	call   c0100ce7 <__panic>
    return pa2page(PTE_ADDR(pte));
c0103e00:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e08:	89 04 24             	mov    %eax,(%esp)
c0103e0b:	e8 1d ff ff ff       	call   c0103d2d <pa2page>
}
c0103e10:	89 ec                	mov    %ebp,%esp
c0103e12:	5d                   	pop    %ebp
c0103e13:	c3                   	ret    

c0103e14 <pde2page>:
pde2page(pde_t pde) {
c0103e14:	55                   	push   %ebp
c0103e15:	89 e5                	mov    %esp,%ebp
c0103e17:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
c0103e1a:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0103e22:	89 04 24             	mov    %eax,(%esp)
c0103e25:	e8 03 ff ff ff       	call   c0103d2d <pa2page>
}
c0103e2a:	89 ec                	mov    %ebp,%esp
c0103e2c:	5d                   	pop    %ebp
c0103e2d:	c3                   	ret    

c0103e2e <page_ref>:
page_ref(struct Page *page) {
c0103e2e:	55                   	push   %ebp
c0103e2f:	89 e5                	mov    %esp,%ebp
    return page->ref;
c0103e31:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e34:	8b 00                	mov    (%eax),%eax
}
c0103e36:	5d                   	pop    %ebp
c0103e37:	c3                   	ret    

c0103e38 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
c0103e38:	55                   	push   %ebp
c0103e39:	89 e5                	mov    %esp,%ebp
    page->ref = val;
c0103e3b:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0103e41:	89 10                	mov    %edx,(%eax)
}
c0103e43:	90                   	nop
c0103e44:	5d                   	pop    %ebp
c0103e45:	c3                   	ret    

c0103e46 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
c0103e46:	55                   	push   %ebp
c0103e47:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
c0103e49:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e4c:	8b 00                	mov    (%eax),%eax
c0103e4e:	8d 50 01             	lea    0x1(%eax),%edx
c0103e51:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e54:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103e56:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e59:	8b 00                	mov    (%eax),%eax
}
c0103e5b:	5d                   	pop    %ebp
c0103e5c:	c3                   	ret    

c0103e5d <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
c0103e5d:	55                   	push   %ebp
c0103e5e:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
c0103e60:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e63:	8b 00                	mov    (%eax),%eax
c0103e65:	8d 50 ff             	lea    -0x1(%eax),%edx
c0103e68:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e6b:	89 10                	mov    %edx,(%eax)
    return page->ref;
c0103e6d:	8b 45 08             	mov    0x8(%ebp),%eax
c0103e70:	8b 00                	mov    (%eax),%eax
}
c0103e72:	5d                   	pop    %ebp
c0103e73:	c3                   	ret    

c0103e74 <__intr_save>:
__intr_save(void) {
c0103e74:	55                   	push   %ebp
c0103e75:	89 e5                	mov    %esp,%ebp
c0103e77:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
c0103e7a:	9c                   	pushf  
c0103e7b:	58                   	pop    %eax
c0103e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
c0103e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
c0103e82:	25 00 02 00 00       	and    $0x200,%eax
c0103e87:	85 c0                	test   %eax,%eax
c0103e89:	74 0c                	je     c0103e97 <__intr_save+0x23>
        intr_disable();
c0103e8b:	e8 b0 d8 ff ff       	call   c0101740 <intr_disable>
        return 1;
c0103e90:	b8 01 00 00 00       	mov    $0x1,%eax
c0103e95:	eb 05                	jmp    c0103e9c <__intr_save+0x28>
    return 0;
c0103e97:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0103e9c:	89 ec                	mov    %ebp,%esp
c0103e9e:	5d                   	pop    %ebp
c0103e9f:	c3                   	ret    

c0103ea0 <__intr_restore>:
__intr_restore(bool flag) {
c0103ea0:	55                   	push   %ebp
c0103ea1:	89 e5                	mov    %esp,%ebp
c0103ea3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
c0103ea6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0103eaa:	74 05                	je     c0103eb1 <__intr_restore+0x11>
        intr_enable();
c0103eac:	e8 87 d8 ff ff       	call   c0101738 <intr_enable>
}
c0103eb1:	90                   	nop
c0103eb2:	89 ec                	mov    %ebp,%esp
c0103eb4:	5d                   	pop    %ebp
c0103eb5:	c3                   	ret    

c0103eb6 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
c0103eb6:	55                   	push   %ebp
c0103eb7:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
c0103eb9:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ebc:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
c0103ebf:	b8 23 00 00 00       	mov    $0x23,%eax
c0103ec4:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
c0103ec6:	b8 23 00 00 00       	mov    $0x23,%eax
c0103ecb:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
c0103ecd:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ed2:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
c0103ed4:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ed9:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
c0103edb:	b8 10 00 00 00       	mov    $0x10,%eax
c0103ee0:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
c0103ee2:	ea e9 3e 10 c0 08 00 	ljmp   $0x8,$0xc0103ee9
}
c0103ee9:	90                   	nop
c0103eea:	5d                   	pop    %ebp
c0103eeb:	c3                   	ret    

c0103eec <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
c0103eec:	55                   	push   %ebp
c0103eed:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
c0103eef:	8b 45 08             	mov    0x8(%ebp),%eax
c0103ef2:	a3 24 cf 11 c0       	mov    %eax,0xc011cf24
}
c0103ef7:	90                   	nop
c0103ef8:	5d                   	pop    %ebp
c0103ef9:	c3                   	ret    

c0103efa <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
c0103efa:	55                   	push   %ebp
c0103efb:	89 e5                	mov    %esp,%ebp
c0103efd:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
c0103f00:	b8 00 90 11 c0       	mov    $0xc0119000,%eax
c0103f05:	89 04 24             	mov    %eax,(%esp)
c0103f08:	e8 df ff ff ff       	call   c0103eec <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
c0103f0d:	66 c7 05 28 cf 11 c0 	movw   $0x10,0xc011cf28
c0103f14:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
c0103f16:	66 c7 05 28 9a 11 c0 	movw   $0x68,0xc0119a28
c0103f1d:	68 00 
c0103f1f:	b8 20 cf 11 c0       	mov    $0xc011cf20,%eax
c0103f24:	0f b7 c0             	movzwl %ax,%eax
c0103f27:	66 a3 2a 9a 11 c0    	mov    %ax,0xc0119a2a
c0103f2d:	b8 20 cf 11 c0       	mov    $0xc011cf20,%eax
c0103f32:	c1 e8 10             	shr    $0x10,%eax
c0103f35:	a2 2c 9a 11 c0       	mov    %al,0xc0119a2c
c0103f3a:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103f41:	24 f0                	and    $0xf0,%al
c0103f43:	0c 09                	or     $0x9,%al
c0103f45:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103f4a:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103f51:	24 ef                	and    $0xef,%al
c0103f53:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103f58:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103f5f:	24 9f                	and    $0x9f,%al
c0103f61:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103f66:	0f b6 05 2d 9a 11 c0 	movzbl 0xc0119a2d,%eax
c0103f6d:	0c 80                	or     $0x80,%al
c0103f6f:	a2 2d 9a 11 c0       	mov    %al,0xc0119a2d
c0103f74:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f7b:	24 f0                	and    $0xf0,%al
c0103f7d:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f82:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f89:	24 ef                	and    $0xef,%al
c0103f8b:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f90:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103f97:	24 df                	and    $0xdf,%al
c0103f99:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103f9e:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103fa5:	0c 40                	or     $0x40,%al
c0103fa7:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103fac:	0f b6 05 2e 9a 11 c0 	movzbl 0xc0119a2e,%eax
c0103fb3:	24 7f                	and    $0x7f,%al
c0103fb5:	a2 2e 9a 11 c0       	mov    %al,0xc0119a2e
c0103fba:	b8 20 cf 11 c0       	mov    $0xc011cf20,%eax
c0103fbf:	c1 e8 18             	shr    $0x18,%eax
c0103fc2:	a2 2f 9a 11 c0       	mov    %al,0xc0119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
c0103fc7:	c7 04 24 30 9a 11 c0 	movl   $0xc0119a30,(%esp)
c0103fce:	e8 e3 fe ff ff       	call   c0103eb6 <lgdt>
c0103fd3:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
c0103fd9:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
c0103fdd:	0f 00 d8             	ltr    %ax
}
c0103fe0:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
c0103fe1:	90                   	nop
c0103fe2:	89 ec                	mov    %ebp,%esp
c0103fe4:	5d                   	pop    %ebp
c0103fe5:	c3                   	ret    

c0103fe6 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
c0103fe6:	55                   	push   %ebp
c0103fe7:	89 e5                	mov    %esp,%ebp
c0103fe9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
c0103fec:	c7 05 0c cf 11 c0 10 	movl   $0xc0106d10,0xc011cf0c
c0103ff3:	6d 10 c0 
    cprintf("memory management: %s\n", pmm_manager->name);
c0103ff6:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0103ffb:	8b 00                	mov    (%eax),%eax
c0103ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104001:	c7 04 24 ac 6d 10 c0 	movl   $0xc0106dac,(%esp)
c0104008:	e8 49 c3 ff ff       	call   c0100356 <cprintf>
    pmm_manager->init();
c010400d:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104012:	8b 40 04             	mov    0x4(%eax),%eax
c0104015:	ff d0                	call   *%eax
}
c0104017:	90                   	nop
c0104018:	89 ec                	mov    %ebp,%esp
c010401a:	5d                   	pop    %ebp
c010401b:	c3                   	ret    

c010401c <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
c010401c:	55                   	push   %ebp
c010401d:	89 e5                	mov    %esp,%ebp
c010401f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
c0104022:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104027:	8b 40 08             	mov    0x8(%eax),%eax
c010402a:	8b 55 0c             	mov    0xc(%ebp),%edx
c010402d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104031:	8b 55 08             	mov    0x8(%ebp),%edx
c0104034:	89 14 24             	mov    %edx,(%esp)
c0104037:	ff d0                	call   *%eax
}
c0104039:	90                   	nop
c010403a:	89 ec                	mov    %ebp,%esp
c010403c:	5d                   	pop    %ebp
c010403d:	c3                   	ret    

c010403e <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
c010403e:	55                   	push   %ebp
c010403f:	89 e5                	mov    %esp,%ebp
c0104041:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
c0104044:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
c010404b:	e8 24 fe ff ff       	call   c0103e74 <__intr_save>
c0104050:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
c0104053:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104058:	8b 40 0c             	mov    0xc(%eax),%eax
c010405b:	8b 55 08             	mov    0x8(%ebp),%edx
c010405e:	89 14 24             	mov    %edx,(%esp)
c0104061:	ff d0                	call   *%eax
c0104063:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
c0104066:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104069:	89 04 24             	mov    %eax,(%esp)
c010406c:	e8 2f fe ff ff       	call   c0103ea0 <__intr_restore>
    return page;
c0104071:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0104074:	89 ec                	mov    %ebp,%esp
c0104076:	5d                   	pop    %ebp
c0104077:	c3                   	ret    

c0104078 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
c0104078:	55                   	push   %ebp
c0104079:	89 e5                	mov    %esp,%ebp
c010407b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
c010407e:	e8 f1 fd ff ff       	call   c0103e74 <__intr_save>
c0104083:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
c0104086:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c010408b:	8b 40 10             	mov    0x10(%eax),%eax
c010408e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0104091:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104095:	8b 55 08             	mov    0x8(%ebp),%edx
c0104098:	89 14 24             	mov    %edx,(%esp)
c010409b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
c010409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040a0:	89 04 24             	mov    %eax,(%esp)
c01040a3:	e8 f8 fd ff ff       	call   c0103ea0 <__intr_restore>
}
c01040a8:	90                   	nop
c01040a9:	89 ec                	mov    %ebp,%esp
c01040ab:	5d                   	pop    %ebp
c01040ac:	c3                   	ret    

c01040ad <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
c01040ad:	55                   	push   %ebp
c01040ae:	89 e5                	mov    %esp,%ebp
c01040b0:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
c01040b3:	e8 bc fd ff ff       	call   c0103e74 <__intr_save>
c01040b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
c01040bb:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c01040c0:	8b 40 14             	mov    0x14(%eax),%eax
c01040c3:	ff d0                	call   *%eax
c01040c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
c01040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01040cb:	89 04 24             	mov    %eax,(%esp)
c01040ce:	e8 cd fd ff ff       	call   c0103ea0 <__intr_restore>
    return ret;
c01040d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
c01040d6:	89 ec                	mov    %ebp,%esp
c01040d8:	5d                   	pop    %ebp
c01040d9:	c3                   	ret    

c01040da <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
c01040da:	55                   	push   %ebp
c01040db:	89 e5                	mov    %esp,%ebp
c01040dd:	57                   	push   %edi
c01040de:	56                   	push   %esi
c01040df:	53                   	push   %ebx
c01040e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
c01040e6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
c01040ed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
c01040f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
c01040fb:	c7 04 24 c3 6d 10 c0 	movl   $0xc0106dc3,(%esp)
c0104102:	e8 4f c2 ff ff       	call   c0100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
c0104107:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c010410e:	e9 0c 01 00 00       	jmp    c010421f <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c0104113:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104116:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104119:	89 d0                	mov    %edx,%eax
c010411b:	c1 e0 02             	shl    $0x2,%eax
c010411e:	01 d0                	add    %edx,%eax
c0104120:	c1 e0 02             	shl    $0x2,%eax
c0104123:	01 c8                	add    %ecx,%eax
c0104125:	8b 50 08             	mov    0x8(%eax),%edx
c0104128:	8b 40 04             	mov    0x4(%eax),%eax
c010412b:	89 45 a0             	mov    %eax,-0x60(%ebp)
c010412e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
c0104131:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104134:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104137:	89 d0                	mov    %edx,%eax
c0104139:	c1 e0 02             	shl    $0x2,%eax
c010413c:	01 d0                	add    %edx,%eax
c010413e:	c1 e0 02             	shl    $0x2,%eax
c0104141:	01 c8                	add    %ecx,%eax
c0104143:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104146:	8b 58 10             	mov    0x10(%eax),%ebx
c0104149:	8b 45 a0             	mov    -0x60(%ebp),%eax
c010414c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c010414f:	01 c8                	add    %ecx,%eax
c0104151:	11 da                	adc    %ebx,%edx
c0104153:	89 45 98             	mov    %eax,-0x68(%ebp)
c0104156:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
c0104159:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010415c:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010415f:	89 d0                	mov    %edx,%eax
c0104161:	c1 e0 02             	shl    $0x2,%eax
c0104164:	01 d0                	add    %edx,%eax
c0104166:	c1 e0 02             	shl    $0x2,%eax
c0104169:	01 c8                	add    %ecx,%eax
c010416b:	83 c0 14             	add    $0x14,%eax
c010416e:	8b 00                	mov    (%eax),%eax
c0104170:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
c0104176:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104179:	8b 55 9c             	mov    -0x64(%ebp),%edx
c010417c:	83 c0 ff             	add    $0xffffffff,%eax
c010417f:	83 d2 ff             	adc    $0xffffffff,%edx
c0104182:	89 c6                	mov    %eax,%esi
c0104184:	89 d7                	mov    %edx,%edi
c0104186:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104189:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010418c:	89 d0                	mov    %edx,%eax
c010418e:	c1 e0 02             	shl    $0x2,%eax
c0104191:	01 d0                	add    %edx,%eax
c0104193:	c1 e0 02             	shl    $0x2,%eax
c0104196:	01 c8                	add    %ecx,%eax
c0104198:	8b 48 0c             	mov    0xc(%eax),%ecx
c010419b:	8b 58 10             	mov    0x10(%eax),%ebx
c010419e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
c01041a4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
c01041a8:	89 74 24 14          	mov    %esi,0x14(%esp)
c01041ac:	89 7c 24 18          	mov    %edi,0x18(%esp)
c01041b0:	8b 45 a0             	mov    -0x60(%ebp),%eax
c01041b3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
c01041b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01041ba:	89 54 24 10          	mov    %edx,0x10(%esp)
c01041be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
c01041c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
c01041c6:	c7 04 24 d0 6d 10 c0 	movl   $0xc0106dd0,(%esp)
c01041cd:	e8 84 c1 ff ff       	call   c0100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
c01041d2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c01041d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01041d8:	89 d0                	mov    %edx,%eax
c01041da:	c1 e0 02             	shl    $0x2,%eax
c01041dd:	01 d0                	add    %edx,%eax
c01041df:	c1 e0 02             	shl    $0x2,%eax
c01041e2:	01 c8                	add    %ecx,%eax
c01041e4:	83 c0 14             	add    $0x14,%eax
c01041e7:	8b 00                	mov    (%eax),%eax
c01041e9:	83 f8 01             	cmp    $0x1,%eax
c01041ec:	75 2e                	jne    c010421c <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
c01041ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01041f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01041f4:	3b 45 98             	cmp    -0x68(%ebp),%eax
c01041f7:	89 d0                	mov    %edx,%eax
c01041f9:	1b 45 9c             	sbb    -0x64(%ebp),%eax
c01041fc:	73 1e                	jae    c010421c <page_init+0x142>
c01041fe:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
c0104203:	b8 00 00 00 00       	mov    $0x0,%eax
c0104208:	3b 55 a0             	cmp    -0x60(%ebp),%edx
c010420b:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
c010420e:	72 0c                	jb     c010421c <page_init+0x142>
                maxpa = end;
c0104210:	8b 45 98             	mov    -0x68(%ebp),%eax
c0104213:	8b 55 9c             	mov    -0x64(%ebp),%edx
c0104216:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0104219:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
c010421c:	ff 45 dc             	incl   -0x24(%ebp)
c010421f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104222:	8b 00                	mov    (%eax),%eax
c0104224:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104227:	0f 8c e6 fe ff ff    	jl     c0104113 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
c010422d:	ba 00 00 00 38       	mov    $0x38000000,%edx
c0104232:	b8 00 00 00 00       	mov    $0x0,%eax
c0104237:	3b 55 e0             	cmp    -0x20(%ebp),%edx
c010423a:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
c010423d:	73 0e                	jae    c010424d <page_init+0x173>
        maxpa = KMEMSIZE;
c010423f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
c0104246:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
c010424d:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104250:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104253:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104257:	c1 ea 0c             	shr    $0xc,%edx
c010425a:	a3 04 cf 11 c0       	mov    %eax,0xc011cf04
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
c010425f:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
c0104266:	b8 8c cf 11 c0       	mov    $0xc011cf8c,%eax
c010426b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010426e:	8b 45 c0             	mov    -0x40(%ebp),%eax
c0104271:	01 d0                	add    %edx,%eax
c0104273:	89 45 bc             	mov    %eax,-0x44(%ebp)
c0104276:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104279:	ba 00 00 00 00       	mov    $0x0,%edx
c010427e:	f7 75 c0             	divl   -0x40(%ebp)
c0104281:	8b 45 bc             	mov    -0x44(%ebp),%eax
c0104284:	29 d0                	sub    %edx,%eax
c0104286:	a3 00 cf 11 c0       	mov    %eax,0xc011cf00

    for (i = 0; i < npage; i ++) {
c010428b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104292:	eb 2f                	jmp    c01042c3 <page_init+0x1e9>
        SetPageReserved(pages + i);
c0104294:	8b 0d 00 cf 11 c0    	mov    0xc011cf00,%ecx
c010429a:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010429d:	89 d0                	mov    %edx,%eax
c010429f:	c1 e0 02             	shl    $0x2,%eax
c01042a2:	01 d0                	add    %edx,%eax
c01042a4:	c1 e0 02             	shl    $0x2,%eax
c01042a7:	01 c8                	add    %ecx,%eax
c01042a9:	83 c0 04             	add    $0x4,%eax
c01042ac:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
c01042b3:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
c01042b6:	8b 45 90             	mov    -0x70(%ebp),%eax
c01042b9:	8b 55 94             	mov    -0x6c(%ebp),%edx
c01042bc:	0f ab 10             	bts    %edx,(%eax)
}
c01042bf:	90                   	nop
    for (i = 0; i < npage; i ++) {
c01042c0:	ff 45 dc             	incl   -0x24(%ebp)
c01042c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01042c6:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c01042cb:	39 c2                	cmp    %eax,%edx
c01042cd:	72 c5                	jb     c0104294 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
c01042cf:	8b 15 04 cf 11 c0    	mov    0xc011cf04,%edx
c01042d5:	89 d0                	mov    %edx,%eax
c01042d7:	c1 e0 02             	shl    $0x2,%eax
c01042da:	01 d0                	add    %edx,%eax
c01042dc:	c1 e0 02             	shl    $0x2,%eax
c01042df:	89 c2                	mov    %eax,%edx
c01042e1:	a1 00 cf 11 c0       	mov    0xc011cf00,%eax
c01042e6:	01 d0                	add    %edx,%eax
c01042e8:	89 45 b8             	mov    %eax,-0x48(%ebp)
c01042eb:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
c01042f2:	77 23                	ja     c0104317 <page_init+0x23d>
c01042f4:	8b 45 b8             	mov    -0x48(%ebp),%eax
c01042f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01042fb:	c7 44 24 08 00 6e 10 	movl   $0xc0106e00,0x8(%esp)
c0104302:	c0 
c0104303:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
c010430a:	00 
c010430b:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104312:	e8 d0 c9 ff ff       	call   c0100ce7 <__panic>
c0104317:	8b 45 b8             	mov    -0x48(%ebp),%eax
c010431a:	05 00 00 00 40       	add    $0x40000000,%eax
c010431f:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
c0104322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c0104329:	e9 53 01 00 00       	jmp    c0104481 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
c010432e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104331:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104334:	89 d0                	mov    %edx,%eax
c0104336:	c1 e0 02             	shl    $0x2,%eax
c0104339:	01 d0                	add    %edx,%eax
c010433b:	c1 e0 02             	shl    $0x2,%eax
c010433e:	01 c8                	add    %ecx,%eax
c0104340:	8b 50 08             	mov    0x8(%eax),%edx
c0104343:	8b 40 04             	mov    0x4(%eax),%eax
c0104346:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104349:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c010434c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c010434f:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0104352:	89 d0                	mov    %edx,%eax
c0104354:	c1 e0 02             	shl    $0x2,%eax
c0104357:	01 d0                	add    %edx,%eax
c0104359:	c1 e0 02             	shl    $0x2,%eax
c010435c:	01 c8                	add    %ecx,%eax
c010435e:	8b 48 0c             	mov    0xc(%eax),%ecx
c0104361:	8b 58 10             	mov    0x10(%eax),%ebx
c0104364:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104367:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c010436a:	01 c8                	add    %ecx,%eax
c010436c:	11 da                	adc    %ebx,%edx
c010436e:	89 45 c8             	mov    %eax,-0x38(%ebp)
c0104371:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
c0104374:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
c0104377:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010437a:	89 d0                	mov    %edx,%eax
c010437c:	c1 e0 02             	shl    $0x2,%eax
c010437f:	01 d0                	add    %edx,%eax
c0104381:	c1 e0 02             	shl    $0x2,%eax
c0104384:	01 c8                	add    %ecx,%eax
c0104386:	83 c0 14             	add    $0x14,%eax
c0104389:	8b 00                	mov    (%eax),%eax
c010438b:	83 f8 01             	cmp    $0x1,%eax
c010438e:	0f 85 ea 00 00 00    	jne    c010447e <page_init+0x3a4>
            if (begin < freemem) {
c0104394:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c0104397:	ba 00 00 00 00       	mov    $0x0,%edx
c010439c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c010439f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c01043a2:	19 d1                	sbb    %edx,%ecx
c01043a4:	73 0d                	jae    c01043b3 <page_init+0x2d9>
                begin = freemem;
c01043a6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
c01043a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01043ac:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
c01043b3:	ba 00 00 00 38       	mov    $0x38000000,%edx
c01043b8:	b8 00 00 00 00       	mov    $0x0,%eax
c01043bd:	3b 55 c8             	cmp    -0x38(%ebp),%edx
c01043c0:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01043c3:	73 0e                	jae    c01043d3 <page_init+0x2f9>
                end = KMEMSIZE;
c01043c5:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
c01043cc:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
c01043d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01043d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01043d9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c01043dc:	89 d0                	mov    %edx,%eax
c01043de:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c01043e1:	0f 83 97 00 00 00    	jae    c010447e <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
c01043e7:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
c01043ee:	8b 55 d0             	mov    -0x30(%ebp),%edx
c01043f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
c01043f4:	01 d0                	add    %edx,%eax
c01043f6:	48                   	dec    %eax
c01043f7:	89 45 ac             	mov    %eax,-0x54(%ebp)
c01043fa:	8b 45 ac             	mov    -0x54(%ebp),%eax
c01043fd:	ba 00 00 00 00       	mov    $0x0,%edx
c0104402:	f7 75 b0             	divl   -0x50(%ebp)
c0104405:	8b 45 ac             	mov    -0x54(%ebp),%eax
c0104408:	29 d0                	sub    %edx,%eax
c010440a:	ba 00 00 00 00       	mov    $0x0,%edx
c010440f:	89 45 d0             	mov    %eax,-0x30(%ebp)
c0104412:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
c0104415:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104418:	89 45 a8             	mov    %eax,-0x58(%ebp)
c010441b:	8b 45 a8             	mov    -0x58(%ebp),%eax
c010441e:	ba 00 00 00 00       	mov    $0x0,%edx
c0104423:	89 c7                	mov    %eax,%edi
c0104425:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
c010442b:	89 7d 80             	mov    %edi,-0x80(%ebp)
c010442e:	89 d0                	mov    %edx,%eax
c0104430:	83 e0 00             	and    $0x0,%eax
c0104433:	89 45 84             	mov    %eax,-0x7c(%ebp)
c0104436:	8b 45 80             	mov    -0x80(%ebp),%eax
c0104439:	8b 55 84             	mov    -0x7c(%ebp),%edx
c010443c:	89 45 c8             	mov    %eax,-0x38(%ebp)
c010443f:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
c0104442:	8b 45 d0             	mov    -0x30(%ebp),%eax
c0104445:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0104448:	3b 45 c8             	cmp    -0x38(%ebp),%eax
c010444b:	89 d0                	mov    %edx,%eax
c010444d:	1b 45 cc             	sbb    -0x34(%ebp),%eax
c0104450:	73 2c                	jae    c010447e <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
c0104452:	8b 45 c8             	mov    -0x38(%ebp),%eax
c0104455:	8b 55 cc             	mov    -0x34(%ebp),%edx
c0104458:	2b 45 d0             	sub    -0x30(%ebp),%eax
c010445b:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
c010445e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
c0104462:	c1 ea 0c             	shr    $0xc,%edx
c0104465:	89 c3                	mov    %eax,%ebx
c0104467:	8b 45 d0             	mov    -0x30(%ebp),%eax
c010446a:	89 04 24             	mov    %eax,(%esp)
c010446d:	e8 bb f8 ff ff       	call   c0103d2d <pa2page>
c0104472:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c0104476:	89 04 24             	mov    %eax,(%esp)
c0104479:	e8 9e fb ff ff       	call   c010401c <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
c010447e:	ff 45 dc             	incl   -0x24(%ebp)
c0104481:	8b 45 c4             	mov    -0x3c(%ebp),%eax
c0104484:	8b 00                	mov    (%eax),%eax
c0104486:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c0104489:	0f 8c 9f fe ff ff    	jl     c010432e <page_init+0x254>
                }
            }
        }
    }
}
c010448f:	90                   	nop
c0104490:	90                   	nop
c0104491:	81 c4 9c 00 00 00    	add    $0x9c,%esp
c0104497:	5b                   	pop    %ebx
c0104498:	5e                   	pop    %esi
c0104499:	5f                   	pop    %edi
c010449a:	5d                   	pop    %ebp
c010449b:	c3                   	ret    

c010449c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
c010449c:	55                   	push   %ebp
c010449d:	89 e5                	mov    %esp,%ebp
c010449f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
c01044a2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044a5:	33 45 14             	xor    0x14(%ebp),%eax
c01044a8:	25 ff 0f 00 00       	and    $0xfff,%eax
c01044ad:	85 c0                	test   %eax,%eax
c01044af:	74 24                	je     c01044d5 <boot_map_segment+0x39>
c01044b1:	c7 44 24 0c 32 6e 10 	movl   $0xc0106e32,0xc(%esp)
c01044b8:	c0 
c01044b9:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c01044c0:	c0 
c01044c1:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
c01044c8:	00 
c01044c9:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01044d0:	e8 12 c8 ff ff       	call   c0100ce7 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
c01044d5:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
c01044dc:	8b 45 0c             	mov    0xc(%ebp),%eax
c01044df:	25 ff 0f 00 00       	and    $0xfff,%eax
c01044e4:	89 c2                	mov    %eax,%edx
c01044e6:	8b 45 10             	mov    0x10(%ebp),%eax
c01044e9:	01 c2                	add    %eax,%edx
c01044eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01044ee:	01 d0                	add    %edx,%eax
c01044f0:	48                   	dec    %eax
c01044f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01044f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01044f7:	ba 00 00 00 00       	mov    $0x0,%edx
c01044fc:	f7 75 f0             	divl   -0x10(%ebp)
c01044ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104502:	29 d0                	sub    %edx,%eax
c0104504:	c1 e8 0c             	shr    $0xc,%eax
c0104507:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
c010450a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010450d:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104510:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104513:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104518:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
c010451b:	8b 45 14             	mov    0x14(%ebp),%eax
c010451e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104521:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104524:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104529:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c010452c:	eb 68                	jmp    c0104596 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
c010452e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c0104535:	00 
c0104536:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104539:	89 44 24 04          	mov    %eax,0x4(%esp)
c010453d:	8b 45 08             	mov    0x8(%ebp),%eax
c0104540:	89 04 24             	mov    %eax,(%esp)
c0104543:	e8 88 01 00 00       	call   c01046d0 <get_pte>
c0104548:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
c010454b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
c010454f:	75 24                	jne    c0104575 <boot_map_segment+0xd9>
c0104551:	c7 44 24 0c 5e 6e 10 	movl   $0xc0106e5e,0xc(%esp)
c0104558:	c0 
c0104559:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104560:	c0 
c0104561:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
c0104568:	00 
c0104569:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104570:	e8 72 c7 ff ff       	call   c0100ce7 <__panic>
        *ptep = pa | PTE_P | perm;
c0104575:	8b 45 14             	mov    0x14(%ebp),%eax
c0104578:	0b 45 18             	or     0x18(%ebp),%eax
c010457b:	83 c8 01             	or     $0x1,%eax
c010457e:	89 c2                	mov    %eax,%edx
c0104580:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0104583:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
c0104585:	ff 4d f4             	decl   -0xc(%ebp)
c0104588:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
c010458f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
c0104596:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c010459a:	75 92                	jne    c010452e <boot_map_segment+0x92>
    }
}
c010459c:	90                   	nop
c010459d:	90                   	nop
c010459e:	89 ec                	mov    %ebp,%esp
c01045a0:	5d                   	pop    %ebp
c01045a1:	c3                   	ret    

c01045a2 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
c01045a2:	55                   	push   %ebp
c01045a3:	89 e5                	mov    %esp,%ebp
c01045a5:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
c01045a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c01045af:	e8 8a fa ff ff       	call   c010403e <alloc_pages>
c01045b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
c01045b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01045bb:	75 1c                	jne    c01045d9 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
c01045bd:	c7 44 24 08 6b 6e 10 	movl   $0xc0106e6b,0x8(%esp)
c01045c4:	c0 
c01045c5:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
c01045cc:	00 
c01045cd:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01045d4:	e8 0e c7 ff ff       	call   c0100ce7 <__panic>
    }
    return page2kva(p);
c01045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01045dc:	89 04 24             	mov    %eax,(%esp)
c01045df:	e8 9a f7 ff ff       	call   c0103d7e <page2kva>
}
c01045e4:	89 ec                	mov    %ebp,%esp
c01045e6:	5d                   	pop    %ebp
c01045e7:	c3                   	ret    

c01045e8 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
c01045e8:	55                   	push   %ebp
c01045e9:	89 e5                	mov    %esp,%ebp
c01045eb:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
c01045ee:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01045f6:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01045fd:	77 23                	ja     c0104622 <pmm_init+0x3a>
c01045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104602:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104606:	c7 44 24 08 00 6e 10 	movl   $0xc0106e00,0x8(%esp)
c010460d:	c0 
c010460e:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
c0104615:	00 
c0104616:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c010461d:	e8 c5 c6 ff ff       	call   c0100ce7 <__panic>
c0104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104625:	05 00 00 00 40       	add    $0x40000000,%eax
c010462a:	a3 08 cf 11 c0       	mov    %eax,0xc011cf08
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
c010462f:	e8 b2 f9 ff ff       	call   c0103fe6 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
c0104634:	e8 a1 fa ff ff       	call   c01040da <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
c0104639:	e8 ed 03 00 00       	call   c0104a2b <check_alloc_page>

    check_pgdir();
c010463e:	e8 09 04 00 00       	call   c0104a4c <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
c0104643:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104648:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010464b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c0104652:	77 23                	ja     c0104677 <pmm_init+0x8f>
c0104654:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104657:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010465b:	c7 44 24 08 00 6e 10 	movl   $0xc0106e00,0x8(%esp)
c0104662:	c0 
c0104663:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
c010466a:	00 
c010466b:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104672:	e8 70 c6 ff ff       	call   c0100ce7 <__panic>
c0104677:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010467a:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
c0104680:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104685:	05 ac 0f 00 00       	add    $0xfac,%eax
c010468a:	83 ca 03             	or     $0x3,%edx
c010468d:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
c010468f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104694:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
c010469b:	00 
c010469c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c01046a3:	00 
c01046a4:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
c01046ab:	38 
c01046ac:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
c01046b3:	c0 
c01046b4:	89 04 24             	mov    %eax,(%esp)
c01046b7:	e8 e0 fd ff ff       	call   c010449c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
c01046bc:	e8 39 f8 ff ff       	call   c0103efa <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
c01046c1:	e8 24 0a 00 00       	call   c01050ea <check_boot_pgdir>

    print_pgdir();
c01046c6:	e8 a1 0e 00 00       	call   c010556c <print_pgdir>

}
c01046cb:	90                   	nop
c01046cc:	89 ec                	mov    %ebp,%esp
c01046ce:	5d                   	pop    %ebp
c01046cf:	c3                   	ret    

c01046d0 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT   页目录表(一级页表)的起始内核虚拟地址
//  la:     the linear address need to map              需要被映射关联的线性虚拟地址
//  create: a logical value to decide if alloc a page for PT   一个布尔变量决定对应页表项所属的页表不存在时，是否将页表创建
// return vaule: the kernel virtual address of this pte  返回值: la参数对应的二级页表项结构的内核虚拟地址
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
c01046d0:	55                   	push   %ebp
c01046d1:	89 e5                	mov    %esp,%ebp
c01046d3:	83 ec 38             	sub    $0x38,%esp
    }
    return NULL;          // (8) return page table entry
#endif
    // PDX(la) 根据la的高10位获得对应的页目录项(一级页表中的某一项)索引(页目录项)
    // &pgdir[PDX(la)] 根据一级页表项索引从一级页表中找到对应的页目录项指针
    pde_t *pdep = &pgdir[PDX(la)];
c01046d6:	8b 45 0c             	mov    0xc(%ebp),%eax
c01046d9:	c1 e8 16             	shr    $0x16,%eax
c01046dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01046e3:	8b 45 08             	mov    0x8(%ebp),%eax
c01046e6:	01 d0                	add    %edx,%eax
c01046e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 判断当前页目录项的Present存在位是否为1(对应的二级页表是否存在)
    if (!(*pdep & PTE_P)) {
c01046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01046ee:	8b 00                	mov    (%eax),%eax
c01046f0:	83 e0 01             	and    $0x1,%eax
c01046f3:	85 c0                	test   %eax,%eax
c01046f5:	0f 85 af 00 00 00    	jne    c01047aa <get_pte+0xda>
        // 对应的二级页表不存在
        // *page指向的是这个新创建的二级页表基地址
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
c01046fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c01046ff:	74 15                	je     c0104716 <get_pte+0x46>
c0104701:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104708:	e8 31 f9 ff ff       	call   c010403e <alloc_pages>
c010470d:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104714:	75 0a                	jne    c0104720 <get_pte+0x50>
             // 如果create参数为false或是alloc_page分配物理内存失败
            return NULL;
c0104716:	b8 00 00 00 00       	mov    $0x0,%eax
c010471b:	e9 e7 00 00 00       	jmp    c0104807 <get_pte+0x137>
        }
        // 二级页表所对应的物理页 引用数为1
        set_page_ref(page, 1);
c0104720:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0104727:	00 
c0104728:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010472b:	89 04 24             	mov    %eax,(%esp)
c010472e:	e8 05 f7 ff ff       	call   c0103e38 <set_page_ref>
        // 获得page变量的物理地址
        uintptr_t pa = page2pa(page);
c0104733:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104736:	89 04 24             	mov    %eax,(%esp)
c0104739:	e8 d7 f5 ff ff       	call   c0103d15 <page2pa>
c010473e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将整个page所在的物理页格式化，全部填满0
        memset(KADDR(pa), 0, PGSIZE);
c0104741:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104744:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104747:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010474a:	c1 e8 0c             	shr    $0xc,%eax
c010474d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0104750:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0104755:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
c0104758:	72 23                	jb     c010477d <get_pte+0xad>
c010475a:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010475d:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104761:	c7 44 24 08 5c 6d 10 	movl   $0xc0106d5c,0x8(%esp)
c0104768:	c0 
c0104769:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
c0104770:	00 
c0104771:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104778:	e8 6a c5 ff ff       	call   c0100ce7 <__panic>
c010477d:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0104780:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104785:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c010478c:	00 
c010478d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104794:	00 
c0104795:	89 04 24             	mov    %eax,(%esp)
c0104798:	e8 d4 18 00 00       	call   c0106071 <memset>
        // la对应的一级页目录项进行赋值，使其指向新创建的二级页表(页表中的数据被MMU直接处理，为了映射效率存放的都是物理地址)
        // 或PTE_U/PTE_W/PET_P 标识当前页目录项是用户级别的、可写的、已存在的
        *pdep = pa | PTE_U | PTE_W | PTE_P;
c010479d:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01047a0:	83 c8 07             	or     $0x7,%eax
c01047a3:	89 c2                	mov    %eax,%edx
c01047a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047a8:	89 10                	mov    %edx,(%eax)
    }

    // 要想通过C语言中的数组来访问对应数据，需要的是数组基址(虚拟地址),而*pdep中页目录表项中存放了对应二级页表的一个物理地址
    // PDE_ADDR将*pdep的低12位抹零对齐(指向二级页表的起始基地址)，再通过KADDR转为内核虚拟地址，进行数组访问
    // PTX(la)获得la线性地址的中间10位部分，即二级页表中对应页表项的索引下标。这样便能得到la对应的二级页表项了
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
c01047aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01047ad:	8b 00                	mov    (%eax),%eax
c01047af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01047b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01047b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047ba:	c1 e8 0c             	shr    $0xc,%eax
c01047bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
c01047c0:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c01047c5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
c01047c8:	72 23                	jb     c01047ed <get_pte+0x11d>
c01047ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01047d1:	c7 44 24 08 5c 6d 10 	movl   $0xc0106d5c,0x8(%esp)
c01047d8:	c0 
c01047d9:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
c01047e0:	00 
c01047e1:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01047e8:	e8 fa c4 ff ff       	call   c0100ce7 <__panic>
c01047ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01047f0:	2d 00 00 00 40       	sub    $0x40000000,%eax
c01047f5:	89 c2                	mov    %eax,%edx
c01047f7:	8b 45 0c             	mov    0xc(%ebp),%eax
c01047fa:	c1 e8 0c             	shr    $0xc,%eax
c01047fd:	25 ff 03 00 00       	and    $0x3ff,%eax
c0104802:	c1 e0 02             	shl    $0x2,%eax
c0104805:	01 d0                	add    %edx,%eax
}
c0104807:	89 ec                	mov    %ebp,%esp
c0104809:	5d                   	pop    %ebp
c010480a:	c3                   	ret    

c010480b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
c010480b:	55                   	push   %ebp
c010480c:	89 e5                	mov    %esp,%ebp
c010480e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c0104811:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104818:	00 
c0104819:	8b 45 0c             	mov    0xc(%ebp),%eax
c010481c:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104820:	8b 45 08             	mov    0x8(%ebp),%eax
c0104823:	89 04 24             	mov    %eax,(%esp)
c0104826:	e8 a5 fe ff ff       	call   c01046d0 <get_pte>
c010482b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
c010482e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0104832:	74 08                	je     c010483c <get_page+0x31>
        *ptep_store = ptep;
c0104834:	8b 45 10             	mov    0x10(%ebp),%eax
c0104837:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010483a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
c010483c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104840:	74 1b                	je     c010485d <get_page+0x52>
c0104842:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104845:	8b 00                	mov    (%eax),%eax
c0104847:	83 e0 01             	and    $0x1,%eax
c010484a:	85 c0                	test   %eax,%eax
c010484c:	74 0f                	je     c010485d <get_page+0x52>
        return pte2page(*ptep);
c010484e:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104851:	8b 00                	mov    (%eax),%eax
c0104853:	89 04 24             	mov    %eax,(%esp)
c0104856:	e8 79 f5 ff ff       	call   c0103dd4 <pte2page>
c010485b:	eb 05                	jmp    c0104862 <get_page+0x57>
    }
    return NULL;
c010485d:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0104862:	89 ec                	mov    %ebp,%esp
c0104864:	5d                   	pop    %ebp
c0104865:	c3                   	ret    

c0104866 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
c0104866:	55                   	push   %ebp
c0104867:	89 e5                	mov    %esp,%ebp
c0104869:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
c010486c:	8b 45 10             	mov    0x10(%ebp),%eax
c010486f:	8b 00                	mov    (%eax),%eax
c0104871:	83 e0 01             	and    $0x1,%eax
c0104874:	85 c0                	test   %eax,%eax
c0104876:	74 4d                	je     c01048c5 <page_remove_pte+0x5f>
        // 如果对应的二级页表项存在
        // 获得*ptep对应的Page结构
        struct Page *page = pte2page(*ptep);
c0104878:	8b 45 10             	mov    0x10(%ebp),%eax
c010487b:	8b 00                	mov    (%eax),%eax
c010487d:	89 04 24             	mov    %eax,(%esp)
c0104880:	e8 4f f5 ff ff       	call   c0103dd4 <pte2page>
c0104885:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 关联的page引用数自减1
        if (page_ref_dec(page) == 0) {
c0104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010488b:	89 04 24             	mov    %eax,(%esp)
c010488e:	e8 ca f5 ff ff       	call   c0103e5d <page_ref_dec>
c0104893:	85 c0                	test   %eax,%eax
c0104895:	75 13                	jne    c01048aa <page_remove_pte+0x44>
            // 如果自减1后，引用数为0，需要free释放掉该物理页
            free_page(page);
c0104897:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010489e:	00 
c010489f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048a2:	89 04 24             	mov    %eax,(%esp)
c01048a5:	e8 ce f7 ff ff       	call   c0104078 <free_pages>
        }
        // 清空当前二级页表项(整体设置为0)
        *ptep = 0;
c01048aa:	8b 45 10             	mov    0x10(%ebp),%eax
c01048ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 由于页表项发生了改变，需要TLB快表
        tlb_invalidate(pgdir, la);
c01048b3:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048b6:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01048bd:	89 04 24             	mov    %eax,(%esp)
c01048c0:	e8 07 01 00 00       	call   c01049cc <tlb_invalidate>
    }
}
c01048c5:	90                   	nop
c01048c6:	89 ec                	mov    %ebp,%esp
c01048c8:	5d                   	pop    %ebp
c01048c9:	c3                   	ret    

c01048ca <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
c01048ca:	55                   	push   %ebp
c01048cb:	89 e5                	mov    %esp,%ebp
c01048cd:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
c01048d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c01048d7:	00 
c01048d8:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048db:	89 44 24 04          	mov    %eax,0x4(%esp)
c01048df:	8b 45 08             	mov    0x8(%ebp),%eax
c01048e2:	89 04 24             	mov    %eax,(%esp)
c01048e5:	e8 e6 fd ff ff       	call   c01046d0 <get_pte>
c01048ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
c01048ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c01048f1:	74 19                	je     c010490c <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
c01048f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01048f6:	89 44 24 08          	mov    %eax,0x8(%esp)
c01048fa:	8b 45 0c             	mov    0xc(%ebp),%eax
c01048fd:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104901:	8b 45 08             	mov    0x8(%ebp),%eax
c0104904:	89 04 24             	mov    %eax,(%esp)
c0104907:	e8 5a ff ff ff       	call   c0104866 <page_remove_pte>
    }
}
c010490c:	90                   	nop
c010490d:	89 ec                	mov    %ebp,%esp
c010490f:	5d                   	pop    %ebp
c0104910:	c3                   	ret    

c0104911 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
c0104911:	55                   	push   %ebp
c0104912:	89 e5                	mov    %esp,%ebp
c0104914:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
c0104917:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
c010491e:	00 
c010491f:	8b 45 10             	mov    0x10(%ebp),%eax
c0104922:	89 44 24 04          	mov    %eax,0x4(%esp)
c0104926:	8b 45 08             	mov    0x8(%ebp),%eax
c0104929:	89 04 24             	mov    %eax,(%esp)
c010492c:	e8 9f fd ff ff       	call   c01046d0 <get_pte>
c0104931:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
c0104934:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
c0104938:	75 0a                	jne    c0104944 <page_insert+0x33>
        return -E_NO_MEM;
c010493a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
c010493f:	e9 84 00 00 00       	jmp    c01049c8 <page_insert+0xb7>
    }
    page_ref_inc(page);
c0104944:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104947:	89 04 24             	mov    %eax,(%esp)
c010494a:	e8 f7 f4 ff ff       	call   c0103e46 <page_ref_inc>
    if (*ptep & PTE_P) {
c010494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104952:	8b 00                	mov    (%eax),%eax
c0104954:	83 e0 01             	and    $0x1,%eax
c0104957:	85 c0                	test   %eax,%eax
c0104959:	74 3e                	je     c0104999 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
c010495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010495e:	8b 00                	mov    (%eax),%eax
c0104960:	89 04 24             	mov    %eax,(%esp)
c0104963:	e8 6c f4 ff ff       	call   c0103dd4 <pte2page>
c0104968:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
c010496b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010496e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0104971:	75 0d                	jne    c0104980 <page_insert+0x6f>
            page_ref_dec(page);
c0104973:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104976:	89 04 24             	mov    %eax,(%esp)
c0104979:	e8 df f4 ff ff       	call   c0103e5d <page_ref_dec>
c010497e:	eb 19                	jmp    c0104999 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
c0104980:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104983:	89 44 24 08          	mov    %eax,0x8(%esp)
c0104987:	8b 45 10             	mov    0x10(%ebp),%eax
c010498a:	89 44 24 04          	mov    %eax,0x4(%esp)
c010498e:	8b 45 08             	mov    0x8(%ebp),%eax
c0104991:	89 04 24             	mov    %eax,(%esp)
c0104994:	e8 cd fe ff ff       	call   c0104866 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
c0104999:	8b 45 0c             	mov    0xc(%ebp),%eax
c010499c:	89 04 24             	mov    %eax,(%esp)
c010499f:	e8 71 f3 ff ff       	call   c0103d15 <page2pa>
c01049a4:	0b 45 14             	or     0x14(%ebp),%eax
c01049a7:	83 c8 01             	or     $0x1,%eax
c01049aa:	89 c2                	mov    %eax,%edx
c01049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049af:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
c01049b1:	8b 45 10             	mov    0x10(%ebp),%eax
c01049b4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01049b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01049bb:	89 04 24             	mov    %eax,(%esp)
c01049be:	e8 09 00 00 00       	call   c01049cc <tlb_invalidate>
    return 0;
c01049c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01049c8:	89 ec                	mov    %ebp,%esp
c01049ca:	5d                   	pop    %ebp
c01049cb:	c3                   	ret    

c01049cc <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
c01049cc:	55                   	push   %ebp
c01049cd:	89 e5                	mov    %esp,%ebp
c01049cf:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
c01049d2:	0f 20 d8             	mov    %cr3,%eax
c01049d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
c01049d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
c01049db:	8b 45 08             	mov    0x8(%ebp),%eax
c01049de:	89 45 f4             	mov    %eax,-0xc(%ebp)
c01049e1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
c01049e8:	77 23                	ja     c0104a0d <tlb_invalidate+0x41>
c01049ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01049ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
c01049f1:	c7 44 24 08 00 6e 10 	movl   $0xc0106e00,0x8(%esp)
c01049f8:	c0 
c01049f9:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
c0104a00:	00 
c0104a01:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104a08:	e8 da c2 ff ff       	call   c0100ce7 <__panic>
c0104a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104a10:	05 00 00 00 40       	add    $0x40000000,%eax
c0104a15:	39 d0                	cmp    %edx,%eax
c0104a17:	75 0d                	jne    c0104a26 <tlb_invalidate+0x5a>
        invlpg((void *)la);
c0104a19:	8b 45 0c             	mov    0xc(%ebp),%eax
c0104a1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
c0104a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104a22:	0f 01 38             	invlpg (%eax)
}
c0104a25:	90                   	nop
    }
}
c0104a26:	90                   	nop
c0104a27:	89 ec                	mov    %ebp,%esp
c0104a29:	5d                   	pop    %ebp
c0104a2a:	c3                   	ret    

c0104a2b <check_alloc_page>:

static void
check_alloc_page(void) {
c0104a2b:	55                   	push   %ebp
c0104a2c:	89 e5                	mov    %esp,%ebp
c0104a2e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
c0104a31:	a1 0c cf 11 c0       	mov    0xc011cf0c,%eax
c0104a36:	8b 40 18             	mov    0x18(%eax),%eax
c0104a39:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
c0104a3b:	c7 04 24 84 6e 10 c0 	movl   $0xc0106e84,(%esp)
c0104a42:	e8 0f b9 ff ff       	call   c0100356 <cprintf>
}
c0104a47:	90                   	nop
c0104a48:	89 ec                	mov    %ebp,%esp
c0104a4a:	5d                   	pop    %ebp
c0104a4b:	c3                   	ret    

c0104a4c <check_pgdir>:

static void
check_pgdir(void) {
c0104a4c:	55                   	push   %ebp
c0104a4d:	89 e5                	mov    %esp,%ebp
c0104a4f:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
c0104a52:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0104a57:	3d 00 80 03 00       	cmp    $0x38000,%eax
c0104a5c:	76 24                	jbe    c0104a82 <check_pgdir+0x36>
c0104a5e:	c7 44 24 0c a3 6e 10 	movl   $0xc0106ea3,0xc(%esp)
c0104a65:	c0 
c0104a66:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104a6d:	c0 
c0104a6e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
c0104a75:	00 
c0104a76:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104a7d:	e8 65 c2 ff ff       	call   c0100ce7 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
c0104a82:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104a87:	85 c0                	test   %eax,%eax
c0104a89:	74 0e                	je     c0104a99 <check_pgdir+0x4d>
c0104a8b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104a90:	25 ff 0f 00 00       	and    $0xfff,%eax
c0104a95:	85 c0                	test   %eax,%eax
c0104a97:	74 24                	je     c0104abd <check_pgdir+0x71>
c0104a99:	c7 44 24 0c c0 6e 10 	movl   $0xc0106ec0,0xc(%esp)
c0104aa0:	c0 
c0104aa1:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104aa8:	c0 
c0104aa9:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
c0104ab0:	00 
c0104ab1:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104ab8:	e8 2a c2 ff ff       	call   c0100ce7 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
c0104abd:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ac2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ac9:	00 
c0104aca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104ad1:	00 
c0104ad2:	89 04 24             	mov    %eax,(%esp)
c0104ad5:	e8 31 fd ff ff       	call   c010480b <get_page>
c0104ada:	85 c0                	test   %eax,%eax
c0104adc:	74 24                	je     c0104b02 <check_pgdir+0xb6>
c0104ade:	c7 44 24 0c f8 6e 10 	movl   $0xc0106ef8,0xc(%esp)
c0104ae5:	c0 
c0104ae6:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104aed:	c0 
c0104aee:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
c0104af5:	00 
c0104af6:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104afd:	e8 e5 c1 ff ff       	call   c0100ce7 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
c0104b02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104b09:	e8 30 f5 ff ff       	call   c010403e <alloc_pages>
c0104b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
c0104b11:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104b16:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104b1d:	00 
c0104b1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b25:	00 
c0104b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104b29:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104b2d:	89 04 24             	mov    %eax,(%esp)
c0104b30:	e8 dc fd ff ff       	call   c0104911 <page_insert>
c0104b35:	85 c0                	test   %eax,%eax
c0104b37:	74 24                	je     c0104b5d <check_pgdir+0x111>
c0104b39:	c7 44 24 0c 20 6f 10 	movl   $0xc0106f20,0xc(%esp)
c0104b40:	c0 
c0104b41:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104b48:	c0 
c0104b49:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
c0104b50:	00 
c0104b51:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104b58:	e8 8a c1 ff ff       	call   c0100ce7 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
c0104b5d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104b62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104b69:	00 
c0104b6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104b71:	00 
c0104b72:	89 04 24             	mov    %eax,(%esp)
c0104b75:	e8 56 fb ff ff       	call   c01046d0 <get_pte>
c0104b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104b7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104b81:	75 24                	jne    c0104ba7 <check_pgdir+0x15b>
c0104b83:	c7 44 24 0c 4c 6f 10 	movl   $0xc0106f4c,0xc(%esp)
c0104b8a:	c0 
c0104b8b:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104b92:	c0 
c0104b93:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
c0104b9a:	00 
c0104b9b:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104ba2:	e8 40 c1 ff ff       	call   c0100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
c0104ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104baa:	8b 00                	mov    (%eax),%eax
c0104bac:	89 04 24             	mov    %eax,(%esp)
c0104baf:	e8 20 f2 ff ff       	call   c0103dd4 <pte2page>
c0104bb4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104bb7:	74 24                	je     c0104bdd <check_pgdir+0x191>
c0104bb9:	c7 44 24 0c 79 6f 10 	movl   $0xc0106f79,0xc(%esp)
c0104bc0:	c0 
c0104bc1:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104bc8:	c0 
c0104bc9:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
c0104bd0:	00 
c0104bd1:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104bd8:	e8 0a c1 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p1) == 1);
c0104bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104be0:	89 04 24             	mov    %eax,(%esp)
c0104be3:	e8 46 f2 ff ff       	call   c0103e2e <page_ref>
c0104be8:	83 f8 01             	cmp    $0x1,%eax
c0104beb:	74 24                	je     c0104c11 <check_pgdir+0x1c5>
c0104bed:	c7 44 24 0c 8f 6f 10 	movl   $0xc0106f8f,0xc(%esp)
c0104bf4:	c0 
c0104bf5:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104bfc:	c0 
c0104bfd:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
c0104c04:	00 
c0104c05:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104c0c:	e8 d6 c0 ff ff       	call   c0100ce7 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
c0104c11:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104c16:	8b 00                	mov    (%eax),%eax
c0104c18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0104c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0104c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c23:	c1 e8 0c             	shr    $0xc,%eax
c0104c26:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0104c29:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0104c2e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
c0104c31:	72 23                	jb     c0104c56 <check_pgdir+0x20a>
c0104c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c36:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0104c3a:	c7 44 24 08 5c 6d 10 	movl   $0xc0106d5c,0x8(%esp)
c0104c41:	c0 
c0104c42:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
c0104c49:	00 
c0104c4a:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104c51:	e8 91 c0 ff ff       	call   c0100ce7 <__panic>
c0104c56:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0104c59:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0104c5e:	83 c0 04             	add    $0x4,%eax
c0104c61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
c0104c64:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104c69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104c70:	00 
c0104c71:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104c78:	00 
c0104c79:	89 04 24             	mov    %eax,(%esp)
c0104c7c:	e8 4f fa ff ff       	call   c01046d0 <get_pte>
c0104c81:	39 45 f0             	cmp    %eax,-0x10(%ebp)
c0104c84:	74 24                	je     c0104caa <check_pgdir+0x25e>
c0104c86:	c7 44 24 0c a4 6f 10 	movl   $0xc0106fa4,0xc(%esp)
c0104c8d:	c0 
c0104c8e:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104c95:	c0 
c0104c96:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
c0104c9d:	00 
c0104c9e:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104ca5:	e8 3d c0 ff ff       	call   c0100ce7 <__panic>

    p2 = alloc_page();
c0104caa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0104cb1:	e8 88 f3 ff ff       	call   c010403e <alloc_pages>
c0104cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
c0104cb9:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104cbe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
c0104cc5:	00 
c0104cc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104ccd:	00 
c0104cce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0104cd1:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104cd5:	89 04 24             	mov    %eax,(%esp)
c0104cd8:	e8 34 fc ff ff       	call   c0104911 <page_insert>
c0104cdd:	85 c0                	test   %eax,%eax
c0104cdf:	74 24                	je     c0104d05 <check_pgdir+0x2b9>
c0104ce1:	c7 44 24 0c cc 6f 10 	movl   $0xc0106fcc,0xc(%esp)
c0104ce8:	c0 
c0104ce9:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104cf0:	c0 
c0104cf1:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
c0104cf8:	00 
c0104cf9:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104d00:	e8 e2 bf ff ff       	call   c0100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104d05:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104d0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104d11:	00 
c0104d12:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104d19:	00 
c0104d1a:	89 04 24             	mov    %eax,(%esp)
c0104d1d:	e8 ae f9 ff ff       	call   c01046d0 <get_pte>
c0104d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104d29:	75 24                	jne    c0104d4f <check_pgdir+0x303>
c0104d2b:	c7 44 24 0c 04 70 10 	movl   $0xc0107004,0xc(%esp)
c0104d32:	c0 
c0104d33:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104d3a:	c0 
c0104d3b:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
c0104d42:	00 
c0104d43:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104d4a:	e8 98 bf ff ff       	call   c0100ce7 <__panic>
    assert(*ptep & PTE_U);
c0104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d52:	8b 00                	mov    (%eax),%eax
c0104d54:	83 e0 04             	and    $0x4,%eax
c0104d57:	85 c0                	test   %eax,%eax
c0104d59:	75 24                	jne    c0104d7f <check_pgdir+0x333>
c0104d5b:	c7 44 24 0c 34 70 10 	movl   $0xc0107034,0xc(%esp)
c0104d62:	c0 
c0104d63:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104d6a:	c0 
c0104d6b:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
c0104d72:	00 
c0104d73:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104d7a:	e8 68 bf ff ff       	call   c0100ce7 <__panic>
    assert(*ptep & PTE_W);
c0104d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104d82:	8b 00                	mov    (%eax),%eax
c0104d84:	83 e0 02             	and    $0x2,%eax
c0104d87:	85 c0                	test   %eax,%eax
c0104d89:	75 24                	jne    c0104daf <check_pgdir+0x363>
c0104d8b:	c7 44 24 0c 42 70 10 	movl   $0xc0107042,0xc(%esp)
c0104d92:	c0 
c0104d93:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104d9a:	c0 
c0104d9b:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
c0104da2:	00 
c0104da3:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104daa:	e8 38 bf ff ff       	call   c0100ce7 <__panic>
    assert(boot_pgdir[0] & PTE_U);
c0104daf:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104db4:	8b 00                	mov    (%eax),%eax
c0104db6:	83 e0 04             	and    $0x4,%eax
c0104db9:	85 c0                	test   %eax,%eax
c0104dbb:	75 24                	jne    c0104de1 <check_pgdir+0x395>
c0104dbd:	c7 44 24 0c 50 70 10 	movl   $0xc0107050,0xc(%esp)
c0104dc4:	c0 
c0104dc5:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104dcc:	c0 
c0104dcd:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
c0104dd4:	00 
c0104dd5:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104ddc:	e8 06 bf ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 1);
c0104de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104de4:	89 04 24             	mov    %eax,(%esp)
c0104de7:	e8 42 f0 ff ff       	call   c0103e2e <page_ref>
c0104dec:	83 f8 01             	cmp    $0x1,%eax
c0104def:	74 24                	je     c0104e15 <check_pgdir+0x3c9>
c0104df1:	c7 44 24 0c 66 70 10 	movl   $0xc0107066,0xc(%esp)
c0104df8:	c0 
c0104df9:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104e00:	c0 
c0104e01:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
c0104e08:	00 
c0104e09:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104e10:	e8 d2 be ff ff       	call   c0100ce7 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
c0104e15:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104e1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
c0104e21:	00 
c0104e22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
c0104e29:	00 
c0104e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0104e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0104e31:	89 04 24             	mov    %eax,(%esp)
c0104e34:	e8 d8 fa ff ff       	call   c0104911 <page_insert>
c0104e39:	85 c0                	test   %eax,%eax
c0104e3b:	74 24                	je     c0104e61 <check_pgdir+0x415>
c0104e3d:	c7 44 24 0c 78 70 10 	movl   $0xc0107078,0xc(%esp)
c0104e44:	c0 
c0104e45:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104e4c:	c0 
c0104e4d:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
c0104e54:	00 
c0104e55:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104e5c:	e8 86 be ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p1) == 2);
c0104e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104e64:	89 04 24             	mov    %eax,(%esp)
c0104e67:	e8 c2 ef ff ff       	call   c0103e2e <page_ref>
c0104e6c:	83 f8 02             	cmp    $0x2,%eax
c0104e6f:	74 24                	je     c0104e95 <check_pgdir+0x449>
c0104e71:	c7 44 24 0c a4 70 10 	movl   $0xc01070a4,0xc(%esp)
c0104e78:	c0 
c0104e79:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104e80:	c0 
c0104e81:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
c0104e88:	00 
c0104e89:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104e90:	e8 52 be ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 0);
c0104e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104e98:	89 04 24             	mov    %eax,(%esp)
c0104e9b:	e8 8e ef ff ff       	call   c0103e2e <page_ref>
c0104ea0:	85 c0                	test   %eax,%eax
c0104ea2:	74 24                	je     c0104ec8 <check_pgdir+0x47c>
c0104ea4:	c7 44 24 0c b6 70 10 	movl   $0xc01070b6,0xc(%esp)
c0104eab:	c0 
c0104eac:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104eb3:	c0 
c0104eb4:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
c0104ebb:	00 
c0104ebc:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104ec3:	e8 1f be ff ff       	call   c0100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
c0104ec8:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ecd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c0104ed4:	00 
c0104ed5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0104edc:	00 
c0104edd:	89 04 24             	mov    %eax,(%esp)
c0104ee0:	e8 eb f7 ff ff       	call   c01046d0 <get_pte>
c0104ee5:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0104ee8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c0104eec:	75 24                	jne    c0104f12 <check_pgdir+0x4c6>
c0104eee:	c7 44 24 0c 04 70 10 	movl   $0xc0107004,0xc(%esp)
c0104ef5:	c0 
c0104ef6:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104efd:	c0 
c0104efe:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
c0104f05:	00 
c0104f06:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104f0d:	e8 d5 bd ff ff       	call   c0100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
c0104f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f15:	8b 00                	mov    (%eax),%eax
c0104f17:	89 04 24             	mov    %eax,(%esp)
c0104f1a:	e8 b5 ee ff ff       	call   c0103dd4 <pte2page>
c0104f1f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
c0104f22:	74 24                	je     c0104f48 <check_pgdir+0x4fc>
c0104f24:	c7 44 24 0c 79 6f 10 	movl   $0xc0106f79,0xc(%esp)
c0104f2b:	c0 
c0104f2c:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104f33:	c0 
c0104f34:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
c0104f3b:	00 
c0104f3c:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104f43:	e8 9f bd ff ff       	call   c0100ce7 <__panic>
    assert((*ptep & PTE_U) == 0);
c0104f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0104f4b:	8b 00                	mov    (%eax),%eax
c0104f4d:	83 e0 04             	and    $0x4,%eax
c0104f50:	85 c0                	test   %eax,%eax
c0104f52:	74 24                	je     c0104f78 <check_pgdir+0x52c>
c0104f54:	c7 44 24 0c c8 70 10 	movl   $0xc01070c8,0xc(%esp)
c0104f5b:	c0 
c0104f5c:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104f63:	c0 
c0104f64:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
c0104f6b:	00 
c0104f6c:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104f73:	e8 6f bd ff ff       	call   c0100ce7 <__panic>

    page_remove(boot_pgdir, 0x0);
c0104f78:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104f7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
c0104f84:	00 
c0104f85:	89 04 24             	mov    %eax,(%esp)
c0104f88:	e8 3d f9 ff ff       	call   c01048ca <page_remove>
    assert(page_ref(p1) == 1);
c0104f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0104f90:	89 04 24             	mov    %eax,(%esp)
c0104f93:	e8 96 ee ff ff       	call   c0103e2e <page_ref>
c0104f98:	83 f8 01             	cmp    $0x1,%eax
c0104f9b:	74 24                	je     c0104fc1 <check_pgdir+0x575>
c0104f9d:	c7 44 24 0c 8f 6f 10 	movl   $0xc0106f8f,0xc(%esp)
c0104fa4:	c0 
c0104fa5:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104fac:	c0 
c0104fad:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
c0104fb4:	00 
c0104fb5:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104fbc:	e8 26 bd ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 0);
c0104fc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0104fc4:	89 04 24             	mov    %eax,(%esp)
c0104fc7:	e8 62 ee ff ff       	call   c0103e2e <page_ref>
c0104fcc:	85 c0                	test   %eax,%eax
c0104fce:	74 24                	je     c0104ff4 <check_pgdir+0x5a8>
c0104fd0:	c7 44 24 0c b6 70 10 	movl   $0xc01070b6,0xc(%esp)
c0104fd7:	c0 
c0104fd8:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0104fdf:	c0 
c0104fe0:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
c0104fe7:	00 
c0104fe8:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0104fef:	e8 f3 bc ff ff       	call   c0100ce7 <__panic>

    page_remove(boot_pgdir, PGSIZE);
c0104ff4:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0104ff9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
c0105000:	00 
c0105001:	89 04 24             	mov    %eax,(%esp)
c0105004:	e8 c1 f8 ff ff       	call   c01048ca <page_remove>
    assert(page_ref(p1) == 0);
c0105009:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010500c:	89 04 24             	mov    %eax,(%esp)
c010500f:	e8 1a ee ff ff       	call   c0103e2e <page_ref>
c0105014:	85 c0                	test   %eax,%eax
c0105016:	74 24                	je     c010503c <check_pgdir+0x5f0>
c0105018:	c7 44 24 0c dd 70 10 	movl   $0xc01070dd,0xc(%esp)
c010501f:	c0 
c0105020:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105027:	c0 
c0105028:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
c010502f:	00 
c0105030:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105037:	e8 ab bc ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p2) == 0);
c010503c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010503f:	89 04 24             	mov    %eax,(%esp)
c0105042:	e8 e7 ed ff ff       	call   c0103e2e <page_ref>
c0105047:	85 c0                	test   %eax,%eax
c0105049:	74 24                	je     c010506f <check_pgdir+0x623>
c010504b:	c7 44 24 0c b6 70 10 	movl   $0xc01070b6,0xc(%esp)
c0105052:	c0 
c0105053:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c010505a:	c0 
c010505b:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
c0105062:	00 
c0105063:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c010506a:	e8 78 bc ff ff       	call   c0100ce7 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
c010506f:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105074:	8b 00                	mov    (%eax),%eax
c0105076:	89 04 24             	mov    %eax,(%esp)
c0105079:	e8 96 ed ff ff       	call   c0103e14 <pde2page>
c010507e:	89 04 24             	mov    %eax,(%esp)
c0105081:	e8 a8 ed ff ff       	call   c0103e2e <page_ref>
c0105086:	83 f8 01             	cmp    $0x1,%eax
c0105089:	74 24                	je     c01050af <check_pgdir+0x663>
c010508b:	c7 44 24 0c f0 70 10 	movl   $0xc01070f0,0xc(%esp)
c0105092:	c0 
c0105093:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c010509a:	c0 
c010509b:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
c01050a2:	00 
c01050a3:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01050aa:	e8 38 bc ff ff       	call   c0100ce7 <__panic>
    free_page(pde2page(boot_pgdir[0]));
c01050af:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050b4:	8b 00                	mov    (%eax),%eax
c01050b6:	89 04 24             	mov    %eax,(%esp)
c01050b9:	e8 56 ed ff ff       	call   c0103e14 <pde2page>
c01050be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c01050c5:	00 
c01050c6:	89 04 24             	mov    %eax,(%esp)
c01050c9:	e8 aa ef ff ff       	call   c0104078 <free_pages>
    boot_pgdir[0] = 0;
c01050ce:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01050d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
c01050d9:	c7 04 24 17 71 10 c0 	movl   $0xc0107117,(%esp)
c01050e0:	e8 71 b2 ff ff       	call   c0100356 <cprintf>
}
c01050e5:	90                   	nop
c01050e6:	89 ec                	mov    %ebp,%esp
c01050e8:	5d                   	pop    %ebp
c01050e9:	c3                   	ret    

c01050ea <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
c01050ea:	55                   	push   %ebp
c01050eb:	89 e5                	mov    %esp,%ebp
c01050ed:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
c01050f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
c01050f7:	e9 ca 00 00 00       	jmp    c01051c6 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
c01050fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
c01050ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105105:	c1 e8 0c             	shr    $0xc,%eax
c0105108:	89 45 e0             	mov    %eax,-0x20(%ebp)
c010510b:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c0105110:	39 45 e0             	cmp    %eax,-0x20(%ebp)
c0105113:	72 23                	jb     c0105138 <check_boot_pgdir+0x4e>
c0105115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105118:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010511c:	c7 44 24 08 5c 6d 10 	movl   $0xc0106d5c,0x8(%esp)
c0105123:	c0 
c0105124:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c010512b:	00 
c010512c:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105133:	e8 af bb ff ff       	call   c0100ce7 <__panic>
c0105138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010513b:	2d 00 00 00 40       	sub    $0x40000000,%eax
c0105140:	89 c2                	mov    %eax,%edx
c0105142:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105147:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
c010514e:	00 
c010514f:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105153:	89 04 24             	mov    %eax,(%esp)
c0105156:	e8 75 f5 ff ff       	call   c01046d0 <get_pte>
c010515b:	89 45 dc             	mov    %eax,-0x24(%ebp)
c010515e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105162:	75 24                	jne    c0105188 <check_boot_pgdir+0x9e>
c0105164:	c7 44 24 0c 34 71 10 	movl   $0xc0107134,0xc(%esp)
c010516b:	c0 
c010516c:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105173:	c0 
c0105174:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
c010517b:	00 
c010517c:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105183:	e8 5f bb ff ff       	call   c0100ce7 <__panic>
        assert(PTE_ADDR(*ptep) == i);
c0105188:	8b 45 dc             	mov    -0x24(%ebp),%eax
c010518b:	8b 00                	mov    (%eax),%eax
c010518d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c0105192:	89 c2                	mov    %eax,%edx
c0105194:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105197:	39 c2                	cmp    %eax,%edx
c0105199:	74 24                	je     c01051bf <check_boot_pgdir+0xd5>
c010519b:	c7 44 24 0c 71 71 10 	movl   $0xc0107171,0xc(%esp)
c01051a2:	c0 
c01051a3:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c01051aa:	c0 
c01051ab:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
c01051b2:	00 
c01051b3:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01051ba:	e8 28 bb ff ff       	call   c0100ce7 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
c01051bf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
c01051c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
c01051c9:	a1 04 cf 11 c0       	mov    0xc011cf04,%eax
c01051ce:	39 c2                	cmp    %eax,%edx
c01051d0:	0f 82 26 ff ff ff    	jb     c01050fc <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
c01051d6:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01051db:	05 ac 0f 00 00       	add    $0xfac,%eax
c01051e0:	8b 00                	mov    (%eax),%eax
c01051e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
c01051e7:	89 c2                	mov    %eax,%edx
c01051e9:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c01051ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01051f1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
c01051f8:	77 23                	ja     c010521d <check_boot_pgdir+0x133>
c01051fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01051fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105201:	c7 44 24 08 00 6e 10 	movl   $0xc0106e00,0x8(%esp)
c0105208:	c0 
c0105209:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0105210:	00 
c0105211:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105218:	e8 ca ba ff ff       	call   c0100ce7 <__panic>
c010521d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105220:	05 00 00 00 40       	add    $0x40000000,%eax
c0105225:	39 d0                	cmp    %edx,%eax
c0105227:	74 24                	je     c010524d <check_boot_pgdir+0x163>
c0105229:	c7 44 24 0c 88 71 10 	movl   $0xc0107188,0xc(%esp)
c0105230:	c0 
c0105231:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105238:	c0 
c0105239:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
c0105240:	00 
c0105241:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105248:	e8 9a ba ff ff       	call   c0100ce7 <__panic>

    assert(boot_pgdir[0] == 0);
c010524d:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105252:	8b 00                	mov    (%eax),%eax
c0105254:	85 c0                	test   %eax,%eax
c0105256:	74 24                	je     c010527c <check_boot_pgdir+0x192>
c0105258:	c7 44 24 0c bc 71 10 	movl   $0xc01071bc,0xc(%esp)
c010525f:	c0 
c0105260:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105267:	c0 
c0105268:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
c010526f:	00 
c0105270:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105277:	e8 6b ba ff ff       	call   c0100ce7 <__panic>

    struct Page *p;
    p = alloc_page();
c010527c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
c0105283:	e8 b6 ed ff ff       	call   c010403e <alloc_pages>
c0105288:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
c010528b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105290:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105297:	00 
c0105298:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
c010529f:	00 
c01052a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01052a3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01052a7:	89 04 24             	mov    %eax,(%esp)
c01052aa:	e8 62 f6 ff ff       	call   c0104911 <page_insert>
c01052af:	85 c0                	test   %eax,%eax
c01052b1:	74 24                	je     c01052d7 <check_boot_pgdir+0x1ed>
c01052b3:	c7 44 24 0c d0 71 10 	movl   $0xc01071d0,0xc(%esp)
c01052ba:	c0 
c01052bb:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c01052c2:	c0 
c01052c3:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
c01052ca:	00 
c01052cb:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01052d2:	e8 10 ba ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p) == 1);
c01052d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01052da:	89 04 24             	mov    %eax,(%esp)
c01052dd:	e8 4c eb ff ff       	call   c0103e2e <page_ref>
c01052e2:	83 f8 01             	cmp    $0x1,%eax
c01052e5:	74 24                	je     c010530b <check_boot_pgdir+0x221>
c01052e7:	c7 44 24 0c fe 71 10 	movl   $0xc01071fe,0xc(%esp)
c01052ee:	c0 
c01052ef:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c01052f6:	c0 
c01052f7:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
c01052fe:	00 
c01052ff:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105306:	e8 dc b9 ff ff       	call   c0100ce7 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
c010530b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105310:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
c0105317:	00 
c0105318:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
c010531f:	00 
c0105320:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105323:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105327:	89 04 24             	mov    %eax,(%esp)
c010532a:	e8 e2 f5 ff ff       	call   c0104911 <page_insert>
c010532f:	85 c0                	test   %eax,%eax
c0105331:	74 24                	je     c0105357 <check_boot_pgdir+0x26d>
c0105333:	c7 44 24 0c 10 72 10 	movl   $0xc0107210,0xc(%esp)
c010533a:	c0 
c010533b:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105342:	c0 
c0105343:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
c010534a:	00 
c010534b:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105352:	e8 90 b9 ff ff       	call   c0100ce7 <__panic>
    assert(page_ref(p) == 2);
c0105357:	8b 45 ec             	mov    -0x14(%ebp),%eax
c010535a:	89 04 24             	mov    %eax,(%esp)
c010535d:	e8 cc ea ff ff       	call   c0103e2e <page_ref>
c0105362:	83 f8 02             	cmp    $0x2,%eax
c0105365:	74 24                	je     c010538b <check_boot_pgdir+0x2a1>
c0105367:	c7 44 24 0c 47 72 10 	movl   $0xc0107247,0xc(%esp)
c010536e:	c0 
c010536f:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105376:	c0 
c0105377:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
c010537e:	00 
c010537f:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105386:	e8 5c b9 ff ff       	call   c0100ce7 <__panic>

    const char *str = "ucore: Hello world!!";
c010538b:	c7 45 e8 58 72 10 c0 	movl   $0xc0107258,-0x18(%ebp)
    strcpy((void *)0x100, str);
c0105392:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105395:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105399:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01053a0:	e8 fc 09 00 00       	call   c0105da1 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
c01053a5:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
c01053ac:	00 
c01053ad:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01053b4:	e8 60 0a 00 00       	call   c0105e19 <strcmp>
c01053b9:	85 c0                	test   %eax,%eax
c01053bb:	74 24                	je     c01053e1 <check_boot_pgdir+0x2f7>
c01053bd:	c7 44 24 0c 70 72 10 	movl   $0xc0107270,0xc(%esp)
c01053c4:	c0 
c01053c5:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c01053cc:	c0 
c01053cd:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
c01053d4:	00 
c01053d5:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c01053dc:	e8 06 b9 ff ff       	call   c0100ce7 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
c01053e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01053e4:	89 04 24             	mov    %eax,(%esp)
c01053e7:	e8 92 e9 ff ff       	call   c0103d7e <page2kva>
c01053ec:	05 00 01 00 00       	add    $0x100,%eax
c01053f1:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
c01053f4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
c01053fb:	e8 47 09 00 00       	call   c0105d47 <strlen>
c0105400:	85 c0                	test   %eax,%eax
c0105402:	74 24                	je     c0105428 <check_boot_pgdir+0x33e>
c0105404:	c7 44 24 0c a8 72 10 	movl   $0xc01072a8,0xc(%esp)
c010540b:	c0 
c010540c:	c7 44 24 08 49 6e 10 	movl   $0xc0106e49,0x8(%esp)
c0105413:	c0 
c0105414:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
c010541b:	00 
c010541c:	c7 04 24 24 6e 10 c0 	movl   $0xc0106e24,(%esp)
c0105423:	e8 bf b8 ff ff       	call   c0100ce7 <__panic>

    free_page(p);
c0105428:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c010542f:	00 
c0105430:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105433:	89 04 24             	mov    %eax,(%esp)
c0105436:	e8 3d ec ff ff       	call   c0104078 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
c010543b:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c0105440:	8b 00                	mov    (%eax),%eax
c0105442:	89 04 24             	mov    %eax,(%esp)
c0105445:	e8 ca e9 ff ff       	call   c0103e14 <pde2page>
c010544a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
c0105451:	00 
c0105452:	89 04 24             	mov    %eax,(%esp)
c0105455:	e8 1e ec ff ff       	call   c0104078 <free_pages>
    boot_pgdir[0] = 0;
c010545a:	a1 e0 99 11 c0       	mov    0xc01199e0,%eax
c010545f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
c0105465:	c7 04 24 cc 72 10 c0 	movl   $0xc01072cc,(%esp)
c010546c:	e8 e5 ae ff ff       	call   c0100356 <cprintf>
}
c0105471:	90                   	nop
c0105472:	89 ec                	mov    %ebp,%esp
c0105474:	5d                   	pop    %ebp
c0105475:	c3                   	ret    

c0105476 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
c0105476:	55                   	push   %ebp
c0105477:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
c0105479:	8b 45 08             	mov    0x8(%ebp),%eax
c010547c:	83 e0 04             	and    $0x4,%eax
c010547f:	85 c0                	test   %eax,%eax
c0105481:	74 04                	je     c0105487 <perm2str+0x11>
c0105483:	b0 75                	mov    $0x75,%al
c0105485:	eb 02                	jmp    c0105489 <perm2str+0x13>
c0105487:	b0 2d                	mov    $0x2d,%al
c0105489:	a2 88 cf 11 c0       	mov    %al,0xc011cf88
    str[1] = 'r';
c010548e:	c6 05 89 cf 11 c0 72 	movb   $0x72,0xc011cf89
    str[2] = (perm & PTE_W) ? 'w' : '-';
c0105495:	8b 45 08             	mov    0x8(%ebp),%eax
c0105498:	83 e0 02             	and    $0x2,%eax
c010549b:	85 c0                	test   %eax,%eax
c010549d:	74 04                	je     c01054a3 <perm2str+0x2d>
c010549f:	b0 77                	mov    $0x77,%al
c01054a1:	eb 02                	jmp    c01054a5 <perm2str+0x2f>
c01054a3:	b0 2d                	mov    $0x2d,%al
c01054a5:	a2 8a cf 11 c0       	mov    %al,0xc011cf8a
    str[3] = '\0';
c01054aa:	c6 05 8b cf 11 c0 00 	movb   $0x0,0xc011cf8b
    return str;
c01054b1:	b8 88 cf 11 c0       	mov    $0xc011cf88,%eax
}
c01054b6:	5d                   	pop    %ebp
c01054b7:	c3                   	ret    

c01054b8 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
c01054b8:	55                   	push   %ebp
c01054b9:	89 e5                	mov    %esp,%ebp
c01054bb:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
c01054be:	8b 45 10             	mov    0x10(%ebp),%eax
c01054c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01054c4:	72 0d                	jb     c01054d3 <get_pgtable_items+0x1b>
        return 0;
c01054c6:	b8 00 00 00 00       	mov    $0x0,%eax
c01054cb:	e9 98 00 00 00       	jmp    c0105568 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
c01054d0:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
c01054d3:	8b 45 10             	mov    0x10(%ebp),%eax
c01054d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01054d9:	73 18                	jae    c01054f3 <get_pgtable_items+0x3b>
c01054db:	8b 45 10             	mov    0x10(%ebp),%eax
c01054de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c01054e5:	8b 45 14             	mov    0x14(%ebp),%eax
c01054e8:	01 d0                	add    %edx,%eax
c01054ea:	8b 00                	mov    (%eax),%eax
c01054ec:	83 e0 01             	and    $0x1,%eax
c01054ef:	85 c0                	test   %eax,%eax
c01054f1:	74 dd                	je     c01054d0 <get_pgtable_items+0x18>
    }
    if (start < right) {
c01054f3:	8b 45 10             	mov    0x10(%ebp),%eax
c01054f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
c01054f9:	73 68                	jae    c0105563 <get_pgtable_items+0xab>
        if (left_store != NULL) {
c01054fb:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
c01054ff:	74 08                	je     c0105509 <get_pgtable_items+0x51>
            *left_store = start;
c0105501:	8b 45 18             	mov    0x18(%ebp),%eax
c0105504:	8b 55 10             	mov    0x10(%ebp),%edx
c0105507:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
c0105509:	8b 45 10             	mov    0x10(%ebp),%eax
c010550c:	8d 50 01             	lea    0x1(%eax),%edx
c010550f:	89 55 10             	mov    %edx,0x10(%ebp)
c0105512:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c0105519:	8b 45 14             	mov    0x14(%ebp),%eax
c010551c:	01 d0                	add    %edx,%eax
c010551e:	8b 00                	mov    (%eax),%eax
c0105520:	83 e0 07             	and    $0x7,%eax
c0105523:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c0105526:	eb 03                	jmp    c010552b <get_pgtable_items+0x73>
            start ++;
c0105528:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
c010552b:	8b 45 10             	mov    0x10(%ebp),%eax
c010552e:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105531:	73 1d                	jae    c0105550 <get_pgtable_items+0x98>
c0105533:	8b 45 10             	mov    0x10(%ebp),%eax
c0105536:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
c010553d:	8b 45 14             	mov    0x14(%ebp),%eax
c0105540:	01 d0                	add    %edx,%eax
c0105542:	8b 00                	mov    (%eax),%eax
c0105544:	83 e0 07             	and    $0x7,%eax
c0105547:	89 c2                	mov    %eax,%edx
c0105549:	8b 45 fc             	mov    -0x4(%ebp),%eax
c010554c:	39 c2                	cmp    %eax,%edx
c010554e:	74 d8                	je     c0105528 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
c0105550:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c0105554:	74 08                	je     c010555e <get_pgtable_items+0xa6>
            *right_store = start;
c0105556:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105559:	8b 55 10             	mov    0x10(%ebp),%edx
c010555c:	89 10                	mov    %edx,(%eax)
        }
        return perm;
c010555e:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105561:	eb 05                	jmp    c0105568 <get_pgtable_items+0xb0>
    }
    return 0;
c0105563:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105568:	89 ec                	mov    %ebp,%esp
c010556a:	5d                   	pop    %ebp
c010556b:	c3                   	ret    

c010556c <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
c010556c:	55                   	push   %ebp
c010556d:	89 e5                	mov    %esp,%ebp
c010556f:	57                   	push   %edi
c0105570:	56                   	push   %esi
c0105571:	53                   	push   %ebx
c0105572:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
c0105575:	c7 04 24 ec 72 10 c0 	movl   $0xc01072ec,(%esp)
c010557c:	e8 d5 ad ff ff       	call   c0100356 <cprintf>
    size_t left, right = 0, perm;
c0105581:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c0105588:	e9 f2 00 00 00       	jmp    c010567f <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c010558d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105590:	89 04 24             	mov    %eax,(%esp)
c0105593:	e8 de fe ff ff       	call   c0105476 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
c0105598:	8b 55 dc             	mov    -0x24(%ebp),%edx
c010559b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
c010559e:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
c01055a0:	89 d6                	mov    %edx,%esi
c01055a2:	c1 e6 16             	shl    $0x16,%esi
c01055a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055a8:	89 d3                	mov    %edx,%ebx
c01055aa:	c1 e3 16             	shl    $0x16,%ebx
c01055ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
c01055b0:	89 d1                	mov    %edx,%ecx
c01055b2:	c1 e1 16             	shl    $0x16,%ecx
c01055b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
c01055b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
c01055bb:	29 fa                	sub    %edi,%edx
c01055bd:	89 44 24 14          	mov    %eax,0x14(%esp)
c01055c1:	89 74 24 10          	mov    %esi,0x10(%esp)
c01055c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01055c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c01055cd:	89 54 24 04          	mov    %edx,0x4(%esp)
c01055d1:	c7 04 24 1d 73 10 c0 	movl   $0xc010731d,(%esp)
c01055d8:	e8 79 ad ff ff       	call   c0100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
c01055dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01055e0:	c1 e0 0a             	shl    $0xa,%eax
c01055e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c01055e6:	eb 50                	jmp    c0105638 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01055e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01055eb:	89 04 24             	mov    %eax,(%esp)
c01055ee:	e8 83 fe ff ff       	call   c0105476 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
c01055f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01055f6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
c01055f9:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
c01055fb:	89 d6                	mov    %edx,%esi
c01055fd:	c1 e6 0c             	shl    $0xc,%esi
c0105600:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105603:	89 d3                	mov    %edx,%ebx
c0105605:	c1 e3 0c             	shl    $0xc,%ebx
c0105608:	8b 55 d8             	mov    -0x28(%ebp),%edx
c010560b:	89 d1                	mov    %edx,%ecx
c010560d:	c1 e1 0c             	shl    $0xc,%ecx
c0105610:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c0105613:	8b 7d d8             	mov    -0x28(%ebp),%edi
c0105616:	29 fa                	sub    %edi,%edx
c0105618:	89 44 24 14          	mov    %eax,0x14(%esp)
c010561c:	89 74 24 10          	mov    %esi,0x10(%esp)
c0105620:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c0105624:	89 4c 24 08          	mov    %ecx,0x8(%esp)
c0105628:	89 54 24 04          	mov    %edx,0x4(%esp)
c010562c:	c7 04 24 3c 73 10 c0 	movl   $0xc010733c,(%esp)
c0105633:	e8 1e ad ff ff       	call   c0100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
c0105638:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
c010563d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
c0105640:	8b 55 dc             	mov    -0x24(%ebp),%edx
c0105643:	89 d3                	mov    %edx,%ebx
c0105645:	c1 e3 0a             	shl    $0xa,%ebx
c0105648:	8b 55 e0             	mov    -0x20(%ebp),%edx
c010564b:	89 d1                	mov    %edx,%ecx
c010564d:	c1 e1 0a             	shl    $0xa,%ecx
c0105650:	8d 55 d4             	lea    -0x2c(%ebp),%edx
c0105653:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105657:	8d 55 d8             	lea    -0x28(%ebp),%edx
c010565a:	89 54 24 10          	mov    %edx,0x10(%esp)
c010565e:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105662:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
c010566a:	89 0c 24             	mov    %ecx,(%esp)
c010566d:	e8 46 fe ff ff       	call   c01054b8 <get_pgtable_items>
c0105672:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c0105675:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105679:	0f 85 69 ff ff ff    	jne    c01055e8 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
c010567f:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
c0105684:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105687:	8d 55 dc             	lea    -0x24(%ebp),%edx
c010568a:	89 54 24 14          	mov    %edx,0x14(%esp)
c010568e:	8d 55 e0             	lea    -0x20(%ebp),%edx
c0105691:	89 54 24 10          	mov    %edx,0x10(%esp)
c0105695:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
c0105699:	89 44 24 08          	mov    %eax,0x8(%esp)
c010569d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
c01056a4:	00 
c01056a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
c01056ac:	e8 07 fe ff ff       	call   c01054b8 <get_pgtable_items>
c01056b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c01056b8:	0f 85 cf fe ff ff    	jne    c010558d <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
c01056be:	c7 04 24 60 73 10 c0 	movl   $0xc0107360,(%esp)
c01056c5:	e8 8c ac ff ff       	call   c0100356 <cprintf>
}
c01056ca:	90                   	nop
c01056cb:	83 c4 4c             	add    $0x4c,%esp
c01056ce:	5b                   	pop    %ebx
c01056cf:	5e                   	pop    %esi
c01056d0:	5f                   	pop    %edi
c01056d1:	5d                   	pop    %ebp
c01056d2:	c3                   	ret    

c01056d3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
c01056d3:	55                   	push   %ebp
c01056d4:	89 e5                	mov    %esp,%ebp
c01056d6:	83 ec 58             	sub    $0x58,%esp
c01056d9:	8b 45 10             	mov    0x10(%ebp),%eax
c01056dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
c01056df:	8b 45 14             	mov    0x14(%ebp),%eax
c01056e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
c01056e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
c01056e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
c01056eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
c01056ee:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
c01056f1:	8b 45 18             	mov    0x18(%ebp),%eax
c01056f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01056f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01056fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
c01056fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105700:	89 55 f0             	mov    %edx,-0x10(%ebp)
c0105703:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105706:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105709:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
c010570d:	74 1c                	je     c010572b <printnum+0x58>
c010570f:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105712:	ba 00 00 00 00       	mov    $0x0,%edx
c0105717:	f7 75 e4             	divl   -0x1c(%ebp)
c010571a:	89 55 f4             	mov    %edx,-0xc(%ebp)
c010571d:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105720:	ba 00 00 00 00       	mov    $0x0,%edx
c0105725:	f7 75 e4             	divl   -0x1c(%ebp)
c0105728:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010572b:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010572e:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105731:	f7 75 e4             	divl   -0x1c(%ebp)
c0105734:	89 45 e0             	mov    %eax,-0x20(%ebp)
c0105737:	89 55 dc             	mov    %edx,-0x24(%ebp)
c010573a:	8b 45 e0             	mov    -0x20(%ebp),%eax
c010573d:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105740:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105743:	89 55 ec             	mov    %edx,-0x14(%ebp)
c0105746:	8b 45 dc             	mov    -0x24(%ebp),%eax
c0105749:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
c010574c:	8b 45 18             	mov    0x18(%ebp),%eax
c010574f:	ba 00 00 00 00       	mov    $0x0,%edx
c0105754:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
c0105757:	39 45 d0             	cmp    %eax,-0x30(%ebp)
c010575a:	19 d1                	sbb    %edx,%ecx
c010575c:	72 4c                	jb     c01057aa <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
c010575e:	8b 45 1c             	mov    0x1c(%ebp),%eax
c0105761:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105764:	8b 45 20             	mov    0x20(%ebp),%eax
c0105767:	89 44 24 18          	mov    %eax,0x18(%esp)
c010576b:	89 54 24 14          	mov    %edx,0x14(%esp)
c010576f:	8b 45 18             	mov    0x18(%ebp),%eax
c0105772:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105776:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105779:	8b 55 ec             	mov    -0x14(%ebp),%edx
c010577c:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105780:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105784:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105787:	89 44 24 04          	mov    %eax,0x4(%esp)
c010578b:	8b 45 08             	mov    0x8(%ebp),%eax
c010578e:	89 04 24             	mov    %eax,(%esp)
c0105791:	e8 3d ff ff ff       	call   c01056d3 <printnum>
c0105796:	eb 1b                	jmp    c01057b3 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
c0105798:	8b 45 0c             	mov    0xc(%ebp),%eax
c010579b:	89 44 24 04          	mov    %eax,0x4(%esp)
c010579f:	8b 45 20             	mov    0x20(%ebp),%eax
c01057a2:	89 04 24             	mov    %eax,(%esp)
c01057a5:	8b 45 08             	mov    0x8(%ebp),%eax
c01057a8:	ff d0                	call   *%eax
        while (-- width > 0)
c01057aa:	ff 4d 1c             	decl   0x1c(%ebp)
c01057ad:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
c01057b1:	7f e5                	jg     c0105798 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
c01057b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
c01057b6:	05 14 74 10 c0       	add    $0xc0107414,%eax
c01057bb:	0f b6 00             	movzbl (%eax),%eax
c01057be:	0f be c0             	movsbl %al,%eax
c01057c1:	8b 55 0c             	mov    0xc(%ebp),%edx
c01057c4:	89 54 24 04          	mov    %edx,0x4(%esp)
c01057c8:	89 04 24             	mov    %eax,(%esp)
c01057cb:	8b 45 08             	mov    0x8(%ebp),%eax
c01057ce:	ff d0                	call   *%eax
}
c01057d0:	90                   	nop
c01057d1:	89 ec                	mov    %ebp,%esp
c01057d3:	5d                   	pop    %ebp
c01057d4:	c3                   	ret    

c01057d5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
c01057d5:	55                   	push   %ebp
c01057d6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c01057d8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c01057dc:	7e 14                	jle    c01057f2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
c01057de:	8b 45 08             	mov    0x8(%ebp),%eax
c01057e1:	8b 00                	mov    (%eax),%eax
c01057e3:	8d 48 08             	lea    0x8(%eax),%ecx
c01057e6:	8b 55 08             	mov    0x8(%ebp),%edx
c01057e9:	89 0a                	mov    %ecx,(%edx)
c01057eb:	8b 50 04             	mov    0x4(%eax),%edx
c01057ee:	8b 00                	mov    (%eax),%eax
c01057f0:	eb 30                	jmp    c0105822 <getuint+0x4d>
    }
    else if (lflag) {
c01057f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c01057f6:	74 16                	je     c010580e <getuint+0x39>
        return va_arg(*ap, unsigned long);
c01057f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01057fb:	8b 00                	mov    (%eax),%eax
c01057fd:	8d 48 04             	lea    0x4(%eax),%ecx
c0105800:	8b 55 08             	mov    0x8(%ebp),%edx
c0105803:	89 0a                	mov    %ecx,(%edx)
c0105805:	8b 00                	mov    (%eax),%eax
c0105807:	ba 00 00 00 00       	mov    $0x0,%edx
c010580c:	eb 14                	jmp    c0105822 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
c010580e:	8b 45 08             	mov    0x8(%ebp),%eax
c0105811:	8b 00                	mov    (%eax),%eax
c0105813:	8d 48 04             	lea    0x4(%eax),%ecx
c0105816:	8b 55 08             	mov    0x8(%ebp),%edx
c0105819:	89 0a                	mov    %ecx,(%edx)
c010581b:	8b 00                	mov    (%eax),%eax
c010581d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
c0105822:	5d                   	pop    %ebp
c0105823:	c3                   	ret    

c0105824 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
c0105824:	55                   	push   %ebp
c0105825:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
c0105827:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
c010582b:	7e 14                	jle    c0105841 <getint+0x1d>
        return va_arg(*ap, long long);
c010582d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105830:	8b 00                	mov    (%eax),%eax
c0105832:	8d 48 08             	lea    0x8(%eax),%ecx
c0105835:	8b 55 08             	mov    0x8(%ebp),%edx
c0105838:	89 0a                	mov    %ecx,(%edx)
c010583a:	8b 50 04             	mov    0x4(%eax),%edx
c010583d:	8b 00                	mov    (%eax),%eax
c010583f:	eb 28                	jmp    c0105869 <getint+0x45>
    }
    else if (lflag) {
c0105841:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0105845:	74 12                	je     c0105859 <getint+0x35>
        return va_arg(*ap, long);
c0105847:	8b 45 08             	mov    0x8(%ebp),%eax
c010584a:	8b 00                	mov    (%eax),%eax
c010584c:	8d 48 04             	lea    0x4(%eax),%ecx
c010584f:	8b 55 08             	mov    0x8(%ebp),%edx
c0105852:	89 0a                	mov    %ecx,(%edx)
c0105854:	8b 00                	mov    (%eax),%eax
c0105856:	99                   	cltd   
c0105857:	eb 10                	jmp    c0105869 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
c0105859:	8b 45 08             	mov    0x8(%ebp),%eax
c010585c:	8b 00                	mov    (%eax),%eax
c010585e:	8d 48 04             	lea    0x4(%eax),%ecx
c0105861:	8b 55 08             	mov    0x8(%ebp),%edx
c0105864:	89 0a                	mov    %ecx,(%edx)
c0105866:	8b 00                	mov    (%eax),%eax
c0105868:	99                   	cltd   
    }
}
c0105869:	5d                   	pop    %ebp
c010586a:	c3                   	ret    

c010586b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
c010586b:	55                   	push   %ebp
c010586c:	89 e5                	mov    %esp,%ebp
c010586e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
c0105871:	8d 45 14             	lea    0x14(%ebp),%eax
c0105874:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
c0105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
c010587a:	89 44 24 0c          	mov    %eax,0xc(%esp)
c010587e:	8b 45 10             	mov    0x10(%ebp),%eax
c0105881:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105885:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105888:	89 44 24 04          	mov    %eax,0x4(%esp)
c010588c:	8b 45 08             	mov    0x8(%ebp),%eax
c010588f:	89 04 24             	mov    %eax,(%esp)
c0105892:	e8 05 00 00 00       	call   c010589c <vprintfmt>
    va_end(ap);
}
c0105897:	90                   	nop
c0105898:	89 ec                	mov    %ebp,%esp
c010589a:	5d                   	pop    %ebp
c010589b:	c3                   	ret    

c010589c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
c010589c:	55                   	push   %ebp
c010589d:	89 e5                	mov    %esp,%ebp
c010589f:	56                   	push   %esi
c01058a0:	53                   	push   %ebx
c01058a1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01058a4:	eb 17                	jmp    c01058bd <vprintfmt+0x21>
            if (ch == '\0') {
c01058a6:	85 db                	test   %ebx,%ebx
c01058a8:	0f 84 bf 03 00 00    	je     c0105c6d <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
c01058ae:	8b 45 0c             	mov    0xc(%ebp),%eax
c01058b1:	89 44 24 04          	mov    %eax,0x4(%esp)
c01058b5:	89 1c 24             	mov    %ebx,(%esp)
c01058b8:	8b 45 08             	mov    0x8(%ebp),%eax
c01058bb:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
c01058bd:	8b 45 10             	mov    0x10(%ebp),%eax
c01058c0:	8d 50 01             	lea    0x1(%eax),%edx
c01058c3:	89 55 10             	mov    %edx,0x10(%ebp)
c01058c6:	0f b6 00             	movzbl (%eax),%eax
c01058c9:	0f b6 d8             	movzbl %al,%ebx
c01058cc:	83 fb 25             	cmp    $0x25,%ebx
c01058cf:	75 d5                	jne    c01058a6 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
c01058d1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
c01058d5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
c01058dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c01058df:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
c01058e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
c01058e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01058ec:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
c01058ef:	8b 45 10             	mov    0x10(%ebp),%eax
c01058f2:	8d 50 01             	lea    0x1(%eax),%edx
c01058f5:	89 55 10             	mov    %edx,0x10(%ebp)
c01058f8:	0f b6 00             	movzbl (%eax),%eax
c01058fb:	0f b6 d8             	movzbl %al,%ebx
c01058fe:	8d 43 dd             	lea    -0x23(%ebx),%eax
c0105901:	83 f8 55             	cmp    $0x55,%eax
c0105904:	0f 87 37 03 00 00    	ja     c0105c41 <vprintfmt+0x3a5>
c010590a:	8b 04 85 38 74 10 c0 	mov    -0x3fef8bc8(,%eax,4),%eax
c0105911:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
c0105913:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
c0105917:	eb d6                	jmp    c01058ef <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
c0105919:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
c010591d:	eb d0                	jmp    c01058ef <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
c010591f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
c0105926:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c0105929:	89 d0                	mov    %edx,%eax
c010592b:	c1 e0 02             	shl    $0x2,%eax
c010592e:	01 d0                	add    %edx,%eax
c0105930:	01 c0                	add    %eax,%eax
c0105932:	01 d8                	add    %ebx,%eax
c0105934:	83 e8 30             	sub    $0x30,%eax
c0105937:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
c010593a:	8b 45 10             	mov    0x10(%ebp),%eax
c010593d:	0f b6 00             	movzbl (%eax),%eax
c0105940:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
c0105943:	83 fb 2f             	cmp    $0x2f,%ebx
c0105946:	7e 38                	jle    c0105980 <vprintfmt+0xe4>
c0105948:	83 fb 39             	cmp    $0x39,%ebx
c010594b:	7f 33                	jg     c0105980 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
c010594d:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
c0105950:	eb d4                	jmp    c0105926 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
c0105952:	8b 45 14             	mov    0x14(%ebp),%eax
c0105955:	8d 50 04             	lea    0x4(%eax),%edx
c0105958:	89 55 14             	mov    %edx,0x14(%ebp)
c010595b:	8b 00                	mov    (%eax),%eax
c010595d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
c0105960:	eb 1f                	jmp    c0105981 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
c0105962:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105966:	79 87                	jns    c01058ef <vprintfmt+0x53>
                width = 0;
c0105968:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
c010596f:	e9 7b ff ff ff       	jmp    c01058ef <vprintfmt+0x53>

        case '#':
            altflag = 1;
c0105974:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
c010597b:	e9 6f ff ff ff       	jmp    c01058ef <vprintfmt+0x53>
            goto process_precision;
c0105980:	90                   	nop

        process_precision:
            if (width < 0)
c0105981:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105985:	0f 89 64 ff ff ff    	jns    c01058ef <vprintfmt+0x53>
                width = precision, precision = -1;
c010598b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c010598e:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105991:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
c0105998:	e9 52 ff ff ff       	jmp    c01058ef <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
c010599d:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
c01059a0:	e9 4a ff ff ff       	jmp    c01058ef <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
c01059a5:	8b 45 14             	mov    0x14(%ebp),%eax
c01059a8:	8d 50 04             	lea    0x4(%eax),%edx
c01059ab:	89 55 14             	mov    %edx,0x14(%ebp)
c01059ae:	8b 00                	mov    (%eax),%eax
c01059b0:	8b 55 0c             	mov    0xc(%ebp),%edx
c01059b3:	89 54 24 04          	mov    %edx,0x4(%esp)
c01059b7:	89 04 24             	mov    %eax,(%esp)
c01059ba:	8b 45 08             	mov    0x8(%ebp),%eax
c01059bd:	ff d0                	call   *%eax
            break;
c01059bf:	e9 a4 02 00 00       	jmp    c0105c68 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
c01059c4:	8b 45 14             	mov    0x14(%ebp),%eax
c01059c7:	8d 50 04             	lea    0x4(%eax),%edx
c01059ca:	89 55 14             	mov    %edx,0x14(%ebp)
c01059cd:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
c01059cf:	85 db                	test   %ebx,%ebx
c01059d1:	79 02                	jns    c01059d5 <vprintfmt+0x139>
                err = -err;
c01059d3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
c01059d5:	83 fb 06             	cmp    $0x6,%ebx
c01059d8:	7f 0b                	jg     c01059e5 <vprintfmt+0x149>
c01059da:	8b 34 9d f8 73 10 c0 	mov    -0x3fef8c08(,%ebx,4),%esi
c01059e1:	85 f6                	test   %esi,%esi
c01059e3:	75 23                	jne    c0105a08 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
c01059e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
c01059e9:	c7 44 24 08 25 74 10 	movl   $0xc0107425,0x8(%esp)
c01059f0:	c0 
c01059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01059f4:	89 44 24 04          	mov    %eax,0x4(%esp)
c01059f8:	8b 45 08             	mov    0x8(%ebp),%eax
c01059fb:	89 04 24             	mov    %eax,(%esp)
c01059fe:	e8 68 fe ff ff       	call   c010586b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
c0105a03:	e9 60 02 00 00       	jmp    c0105c68 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
c0105a08:	89 74 24 0c          	mov    %esi,0xc(%esp)
c0105a0c:	c7 44 24 08 2e 74 10 	movl   $0xc010742e,0x8(%esp)
c0105a13:	c0 
c0105a14:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a17:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a1b:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a1e:	89 04 24             	mov    %eax,(%esp)
c0105a21:	e8 45 fe ff ff       	call   c010586b <printfmt>
            break;
c0105a26:	e9 3d 02 00 00       	jmp    c0105c68 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
c0105a2b:	8b 45 14             	mov    0x14(%ebp),%eax
c0105a2e:	8d 50 04             	lea    0x4(%eax),%edx
c0105a31:	89 55 14             	mov    %edx,0x14(%ebp)
c0105a34:	8b 30                	mov    (%eax),%esi
c0105a36:	85 f6                	test   %esi,%esi
c0105a38:	75 05                	jne    c0105a3f <vprintfmt+0x1a3>
                p = "(null)";
c0105a3a:	be 31 74 10 c0       	mov    $0xc0107431,%esi
            }
            if (width > 0 && padc != '-') {
c0105a3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a43:	7e 76                	jle    c0105abb <vprintfmt+0x21f>
c0105a45:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
c0105a49:	74 70                	je     c0105abb <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
c0105a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a52:	89 34 24             	mov    %esi,(%esp)
c0105a55:	e8 16 03 00 00       	call   c0105d70 <strnlen>
c0105a5a:	89 c2                	mov    %eax,%edx
c0105a5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0105a5f:	29 d0                	sub    %edx,%eax
c0105a61:	89 45 e8             	mov    %eax,-0x18(%ebp)
c0105a64:	eb 16                	jmp    c0105a7c <vprintfmt+0x1e0>
                    putch(padc, putdat);
c0105a66:	0f be 45 db          	movsbl -0x25(%ebp),%eax
c0105a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
c0105a71:	89 04 24             	mov    %eax,(%esp)
c0105a74:	8b 45 08             	mov    0x8(%ebp),%eax
c0105a77:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
c0105a79:	ff 4d e8             	decl   -0x18(%ebp)
c0105a7c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105a80:	7f e4                	jg     c0105a66 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105a82:	eb 37                	jmp    c0105abb <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
c0105a84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
c0105a88:	74 1f                	je     c0105aa9 <vprintfmt+0x20d>
c0105a8a:	83 fb 1f             	cmp    $0x1f,%ebx
c0105a8d:	7e 05                	jle    c0105a94 <vprintfmt+0x1f8>
c0105a8f:	83 fb 7e             	cmp    $0x7e,%ebx
c0105a92:	7e 15                	jle    c0105aa9 <vprintfmt+0x20d>
                    putch('?', putdat);
c0105a94:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105a97:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105a9b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
c0105aa2:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aa5:	ff d0                	call   *%eax
c0105aa7:	eb 0f                	jmp    c0105ab8 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
c0105aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105aac:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ab0:	89 1c 24             	mov    %ebx,(%esp)
c0105ab3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ab6:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
c0105ab8:	ff 4d e8             	decl   -0x18(%ebp)
c0105abb:	89 f0                	mov    %esi,%eax
c0105abd:	8d 70 01             	lea    0x1(%eax),%esi
c0105ac0:	0f b6 00             	movzbl (%eax),%eax
c0105ac3:	0f be d8             	movsbl %al,%ebx
c0105ac6:	85 db                	test   %ebx,%ebx
c0105ac8:	74 27                	je     c0105af1 <vprintfmt+0x255>
c0105aca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ace:	78 b4                	js     c0105a84 <vprintfmt+0x1e8>
c0105ad0:	ff 4d e4             	decl   -0x1c(%ebp)
c0105ad3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
c0105ad7:	79 ab                	jns    c0105a84 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
c0105ad9:	eb 16                	jmp    c0105af1 <vprintfmt+0x255>
                putch(' ', putdat);
c0105adb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ade:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ae2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
c0105ae9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105aec:	ff d0                	call   *%eax
            for (; width > 0; width --) {
c0105aee:	ff 4d e8             	decl   -0x18(%ebp)
c0105af1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
c0105af5:	7f e4                	jg     c0105adb <vprintfmt+0x23f>
            }
            break;
c0105af7:	e9 6c 01 00 00       	jmp    c0105c68 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
c0105afc:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105aff:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b03:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b06:	89 04 24             	mov    %eax,(%esp)
c0105b09:	e8 16 fd ff ff       	call   c0105824 <getint>
c0105b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b11:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
c0105b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b17:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b1a:	85 d2                	test   %edx,%edx
c0105b1c:	79 26                	jns    c0105b44 <vprintfmt+0x2a8>
                putch('-', putdat);
c0105b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b21:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b25:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
c0105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105b2f:	ff d0                	call   *%eax
                num = -(long long)num;
c0105b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105b34:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105b37:	f7 d8                	neg    %eax
c0105b39:	83 d2 00             	adc    $0x0,%edx
c0105b3c:	f7 da                	neg    %edx
c0105b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b41:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
c0105b44:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105b4b:	e9 a8 00 00 00       	jmp    c0105bf8 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
c0105b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b53:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b57:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b5a:	89 04 24             	mov    %eax,(%esp)
c0105b5d:	e8 73 fc ff ff       	call   c01057d5 <getuint>
c0105b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b65:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
c0105b68:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
c0105b6f:	e9 84 00 00 00       	jmp    c0105bf8 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
c0105b74:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105b77:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b7b:	8d 45 14             	lea    0x14(%ebp),%eax
c0105b7e:	89 04 24             	mov    %eax,(%esp)
c0105b81:	e8 4f fc ff ff       	call   c01057d5 <getuint>
c0105b86:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105b89:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
c0105b8c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
c0105b93:	eb 63                	jmp    c0105bf8 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
c0105b95:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105b98:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105b9c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
c0105ba3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ba6:	ff d0                	call   *%eax
            putch('x', putdat);
c0105ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105bab:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105baf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
c0105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105bb9:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
c0105bbb:	8b 45 14             	mov    0x14(%ebp),%eax
c0105bbe:	8d 50 04             	lea    0x4(%eax),%edx
c0105bc1:	89 55 14             	mov    %edx,0x14(%ebp)
c0105bc4:	8b 00                	mov    (%eax),%eax
c0105bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
c0105bd0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
c0105bd7:	eb 1f                	jmp    c0105bf8 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
c0105bd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
c0105bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105be0:	8d 45 14             	lea    0x14(%ebp),%eax
c0105be3:	89 04 24             	mov    %eax,(%esp)
c0105be6:	e8 ea fb ff ff       	call   c01057d5 <getuint>
c0105beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105bee:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
c0105bf1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
c0105bf8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
c0105bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105bff:	89 54 24 18          	mov    %edx,0x18(%esp)
c0105c03:	8b 55 e8             	mov    -0x18(%ebp),%edx
c0105c06:	89 54 24 14          	mov    %edx,0x14(%esp)
c0105c0a:	89 44 24 10          	mov    %eax,0x10(%esp)
c0105c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105c11:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105c14:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105c18:	89 54 24 0c          	mov    %edx,0xc(%esp)
c0105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c23:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c26:	89 04 24             	mov    %eax,(%esp)
c0105c29:	e8 a5 fa ff ff       	call   c01056d3 <printnum>
            break;
c0105c2e:	eb 38                	jmp    c0105c68 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
c0105c30:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c37:	89 1c 24             	mov    %ebx,(%esp)
c0105c3a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c3d:	ff d0                	call   *%eax
            break;
c0105c3f:	eb 27                	jmp    c0105c68 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
c0105c41:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c44:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105c48:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
c0105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105c52:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
c0105c54:	ff 4d 10             	decl   0x10(%ebp)
c0105c57:	eb 03                	jmp    c0105c5c <vprintfmt+0x3c0>
c0105c59:	ff 4d 10             	decl   0x10(%ebp)
c0105c5c:	8b 45 10             	mov    0x10(%ebp),%eax
c0105c5f:	48                   	dec    %eax
c0105c60:	0f b6 00             	movzbl (%eax),%eax
c0105c63:	3c 25                	cmp    $0x25,%al
c0105c65:	75 f2                	jne    c0105c59 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
c0105c67:	90                   	nop
    while (1) {
c0105c68:	e9 37 fc ff ff       	jmp    c01058a4 <vprintfmt+0x8>
                return;
c0105c6d:	90                   	nop
        }
    }
}
c0105c6e:	83 c4 40             	add    $0x40,%esp
c0105c71:	5b                   	pop    %ebx
c0105c72:	5e                   	pop    %esi
c0105c73:	5d                   	pop    %ebp
c0105c74:	c3                   	ret    

c0105c75 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
c0105c75:	55                   	push   %ebp
c0105c76:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
c0105c78:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c7b:	8b 40 08             	mov    0x8(%eax),%eax
c0105c7e:	8d 50 01             	lea    0x1(%eax),%edx
c0105c81:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c84:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
c0105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8a:	8b 10                	mov    (%eax),%edx
c0105c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c8f:	8b 40 04             	mov    0x4(%eax),%eax
c0105c92:	39 c2                	cmp    %eax,%edx
c0105c94:	73 12                	jae    c0105ca8 <sprintputch+0x33>
        *b->buf ++ = ch;
c0105c96:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105c99:	8b 00                	mov    (%eax),%eax
c0105c9b:	8d 48 01             	lea    0x1(%eax),%ecx
c0105c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
c0105ca1:	89 0a                	mov    %ecx,(%edx)
c0105ca3:	8b 55 08             	mov    0x8(%ebp),%edx
c0105ca6:	88 10                	mov    %dl,(%eax)
    }
}
c0105ca8:	90                   	nop
c0105ca9:	5d                   	pop    %ebp
c0105caa:	c3                   	ret    

c0105cab <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
c0105cab:	55                   	push   %ebp
c0105cac:	89 e5                	mov    %esp,%ebp
c0105cae:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
c0105cb1:	8d 45 14             	lea    0x14(%ebp),%eax
c0105cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
c0105cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105cba:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105cbe:	8b 45 10             	mov    0x10(%ebp),%eax
c0105cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105ccc:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ccf:	89 04 24             	mov    %eax,(%esp)
c0105cd2:	e8 0a 00 00 00       	call   c0105ce1 <vsnprintf>
c0105cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
c0105cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105cdd:	89 ec                	mov    %ebp,%esp
c0105cdf:	5d                   	pop    %ebp
c0105ce0:	c3                   	ret    

c0105ce1 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
c0105ce1:	55                   	push   %ebp
c0105ce2:	89 e5                	mov    %esp,%ebp
c0105ce4:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
c0105ce7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cea:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105ced:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105cf0:	8d 50 ff             	lea    -0x1(%eax),%edx
c0105cf3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105cf6:	01 d0                	add    %edx,%eax
c0105cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
c0105cfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
c0105d02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
c0105d06:	74 0a                	je     c0105d12 <vsnprintf+0x31>
c0105d08:	8b 55 ec             	mov    -0x14(%ebp),%edx
c0105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105d0e:	39 c2                	cmp    %eax,%edx
c0105d10:	76 07                	jbe    c0105d19 <vsnprintf+0x38>
        return -E_INVAL;
c0105d12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
c0105d17:	eb 2a                	jmp    c0105d43 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
c0105d19:	8b 45 14             	mov    0x14(%ebp),%eax
c0105d1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
c0105d20:	8b 45 10             	mov    0x10(%ebp),%eax
c0105d23:	89 44 24 08          	mov    %eax,0x8(%esp)
c0105d27:	8d 45 ec             	lea    -0x14(%ebp),%eax
c0105d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
c0105d2e:	c7 04 24 75 5c 10 c0 	movl   $0xc0105c75,(%esp)
c0105d35:	e8 62 fb ff ff       	call   c010589c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
c0105d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0105d3d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
c0105d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
c0105d43:	89 ec                	mov    %ebp,%esp
c0105d45:	5d                   	pop    %ebp
c0105d46:	c3                   	ret    

c0105d47 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
c0105d47:	55                   	push   %ebp
c0105d48:	89 e5                	mov    %esp,%ebp
c0105d4a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105d4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
c0105d54:	eb 03                	jmp    c0105d59 <strlen+0x12>
        cnt ++;
c0105d56:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
c0105d59:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d5c:	8d 50 01             	lea    0x1(%eax),%edx
c0105d5f:	89 55 08             	mov    %edx,0x8(%ebp)
c0105d62:	0f b6 00             	movzbl (%eax),%eax
c0105d65:	84 c0                	test   %al,%al
c0105d67:	75 ed                	jne    c0105d56 <strlen+0xf>
    }
    return cnt;
c0105d69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105d6c:	89 ec                	mov    %ebp,%esp
c0105d6e:	5d                   	pop    %ebp
c0105d6f:	c3                   	ret    

c0105d70 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
c0105d70:	55                   	push   %ebp
c0105d71:	89 e5                	mov    %esp,%ebp
c0105d73:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
c0105d76:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105d7d:	eb 03                	jmp    c0105d82 <strnlen+0x12>
        cnt ++;
c0105d7f:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
c0105d82:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105d85:	3b 45 0c             	cmp    0xc(%ebp),%eax
c0105d88:	73 10                	jae    c0105d9a <strnlen+0x2a>
c0105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
c0105d8d:	8d 50 01             	lea    0x1(%eax),%edx
c0105d90:	89 55 08             	mov    %edx,0x8(%ebp)
c0105d93:	0f b6 00             	movzbl (%eax),%eax
c0105d96:	84 c0                	test   %al,%al
c0105d98:	75 e5                	jne    c0105d7f <strnlen+0xf>
    }
    return cnt;
c0105d9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
c0105d9d:	89 ec                	mov    %ebp,%esp
c0105d9f:	5d                   	pop    %ebp
c0105da0:	c3                   	ret    

c0105da1 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
c0105da1:	55                   	push   %ebp
c0105da2:	89 e5                	mov    %esp,%ebp
c0105da4:	57                   	push   %edi
c0105da5:	56                   	push   %esi
c0105da6:	83 ec 20             	sub    $0x20,%esp
c0105da9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105daf:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105db2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
c0105db5:	8b 55 f0             	mov    -0x10(%ebp),%edx
c0105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0105dbb:	89 d1                	mov    %edx,%ecx
c0105dbd:	89 c2                	mov    %eax,%edx
c0105dbf:	89 ce                	mov    %ecx,%esi
c0105dc1:	89 d7                	mov    %edx,%edi
c0105dc3:	ac                   	lods   %ds:(%esi),%al
c0105dc4:	aa                   	stos   %al,%es:(%edi)
c0105dc5:	84 c0                	test   %al,%al
c0105dc7:	75 fa                	jne    c0105dc3 <strcpy+0x22>
c0105dc9:	89 fa                	mov    %edi,%edx
c0105dcb:	89 f1                	mov    %esi,%ecx
c0105dcd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c0105dd0:	89 55 e8             	mov    %edx,-0x18(%ebp)
c0105dd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
c0105dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
c0105dd9:	83 c4 20             	add    $0x20,%esp
c0105ddc:	5e                   	pop    %esi
c0105ddd:	5f                   	pop    %edi
c0105dde:	5d                   	pop    %ebp
c0105ddf:	c3                   	ret    

c0105de0 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
c0105de0:	55                   	push   %ebp
c0105de1:	89 e5                	mov    %esp,%ebp
c0105de3:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
c0105de6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105de9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
c0105dec:	eb 1e                	jmp    c0105e0c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
c0105dee:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105df1:	0f b6 10             	movzbl (%eax),%edx
c0105df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105df7:	88 10                	mov    %dl,(%eax)
c0105df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c0105dfc:	0f b6 00             	movzbl (%eax),%eax
c0105dff:	84 c0                	test   %al,%al
c0105e01:	74 03                	je     c0105e06 <strncpy+0x26>
            src ++;
c0105e03:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
c0105e06:	ff 45 fc             	incl   -0x4(%ebp)
c0105e09:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
c0105e0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e10:	75 dc                	jne    c0105dee <strncpy+0xe>
    }
    return dst;
c0105e12:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105e15:	89 ec                	mov    %ebp,%esp
c0105e17:	5d                   	pop    %ebp
c0105e18:	c3                   	ret    

c0105e19 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
c0105e19:	55                   	push   %ebp
c0105e1a:	89 e5                	mov    %esp,%ebp
c0105e1c:	57                   	push   %edi
c0105e1d:	56                   	push   %esi
c0105e1e:	83 ec 20             	sub    $0x20,%esp
c0105e21:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105e27:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
c0105e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
c0105e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
c0105e33:	89 d1                	mov    %edx,%ecx
c0105e35:	89 c2                	mov    %eax,%edx
c0105e37:	89 ce                	mov    %ecx,%esi
c0105e39:	89 d7                	mov    %edx,%edi
c0105e3b:	ac                   	lods   %ds:(%esi),%al
c0105e3c:	ae                   	scas   %es:(%edi),%al
c0105e3d:	75 08                	jne    c0105e47 <strcmp+0x2e>
c0105e3f:	84 c0                	test   %al,%al
c0105e41:	75 f8                	jne    c0105e3b <strcmp+0x22>
c0105e43:	31 c0                	xor    %eax,%eax
c0105e45:	eb 04                	jmp    c0105e4b <strcmp+0x32>
c0105e47:	19 c0                	sbb    %eax,%eax
c0105e49:	0c 01                	or     $0x1,%al
c0105e4b:	89 fa                	mov    %edi,%edx
c0105e4d:	89 f1                	mov    %esi,%ecx
c0105e4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
c0105e52:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0105e55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
c0105e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
c0105e5b:	83 c4 20             	add    $0x20,%esp
c0105e5e:	5e                   	pop    %esi
c0105e5f:	5f                   	pop    %edi
c0105e60:	5d                   	pop    %ebp
c0105e61:	c3                   	ret    

c0105e62 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
c0105e62:	55                   	push   %ebp
c0105e63:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105e65:	eb 09                	jmp    c0105e70 <strncmp+0xe>
        n --, s1 ++, s2 ++;
c0105e67:	ff 4d 10             	decl   0x10(%ebp)
c0105e6a:	ff 45 08             	incl   0x8(%ebp)
c0105e6d:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
c0105e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e74:	74 1a                	je     c0105e90 <strncmp+0x2e>
c0105e76:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e79:	0f b6 00             	movzbl (%eax),%eax
c0105e7c:	84 c0                	test   %al,%al
c0105e7e:	74 10                	je     c0105e90 <strncmp+0x2e>
c0105e80:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e83:	0f b6 10             	movzbl (%eax),%edx
c0105e86:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105e89:	0f b6 00             	movzbl (%eax),%eax
c0105e8c:	38 c2                	cmp    %al,%dl
c0105e8e:	74 d7                	je     c0105e67 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
c0105e90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105e94:	74 18                	je     c0105eae <strncmp+0x4c>
c0105e96:	8b 45 08             	mov    0x8(%ebp),%eax
c0105e99:	0f b6 00             	movzbl (%eax),%eax
c0105e9c:	0f b6 d0             	movzbl %al,%edx
c0105e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ea2:	0f b6 00             	movzbl (%eax),%eax
c0105ea5:	0f b6 c8             	movzbl %al,%ecx
c0105ea8:	89 d0                	mov    %edx,%eax
c0105eaa:	29 c8                	sub    %ecx,%eax
c0105eac:	eb 05                	jmp    c0105eb3 <strncmp+0x51>
c0105eae:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105eb3:	5d                   	pop    %ebp
c0105eb4:	c3                   	ret    

c0105eb5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
c0105eb5:	55                   	push   %ebp
c0105eb6:	89 e5                	mov    %esp,%ebp
c0105eb8:	83 ec 04             	sub    $0x4,%esp
c0105ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ebe:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ec1:	eb 13                	jmp    c0105ed6 <strchr+0x21>
        if (*s == c) {
c0105ec3:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ec6:	0f b6 00             	movzbl (%eax),%eax
c0105ec9:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105ecc:	75 05                	jne    c0105ed3 <strchr+0x1e>
            return (char *)s;
c0105ece:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed1:	eb 12                	jmp    c0105ee5 <strchr+0x30>
        }
        s ++;
c0105ed3:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105ed6:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ed9:	0f b6 00             	movzbl (%eax),%eax
c0105edc:	84 c0                	test   %al,%al
c0105ede:	75 e3                	jne    c0105ec3 <strchr+0xe>
    }
    return NULL;
c0105ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
c0105ee5:	89 ec                	mov    %ebp,%esp
c0105ee7:	5d                   	pop    %ebp
c0105ee8:	c3                   	ret    

c0105ee9 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
c0105ee9:	55                   	push   %ebp
c0105eea:	89 e5                	mov    %esp,%ebp
c0105eec:	83 ec 04             	sub    $0x4,%esp
c0105eef:	8b 45 0c             	mov    0xc(%ebp),%eax
c0105ef2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
c0105ef5:	eb 0e                	jmp    c0105f05 <strfind+0x1c>
        if (*s == c) {
c0105ef7:	8b 45 08             	mov    0x8(%ebp),%eax
c0105efa:	0f b6 00             	movzbl (%eax),%eax
c0105efd:	38 45 fc             	cmp    %al,-0x4(%ebp)
c0105f00:	74 0f                	je     c0105f11 <strfind+0x28>
            break;
        }
        s ++;
c0105f02:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
c0105f05:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f08:	0f b6 00             	movzbl (%eax),%eax
c0105f0b:	84 c0                	test   %al,%al
c0105f0d:	75 e8                	jne    c0105ef7 <strfind+0xe>
c0105f0f:	eb 01                	jmp    c0105f12 <strfind+0x29>
            break;
c0105f11:	90                   	nop
    }
    return (char *)s;
c0105f12:	8b 45 08             	mov    0x8(%ebp),%eax
}
c0105f15:	89 ec                	mov    %ebp,%esp
c0105f17:	5d                   	pop    %ebp
c0105f18:	c3                   	ret    

c0105f19 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
c0105f19:	55                   	push   %ebp
c0105f1a:	89 e5                	mov    %esp,%ebp
c0105f1c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
c0105f1f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
c0105f26:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
c0105f2d:	eb 03                	jmp    c0105f32 <strtol+0x19>
        s ++;
c0105f2f:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
c0105f32:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f35:	0f b6 00             	movzbl (%eax),%eax
c0105f38:	3c 20                	cmp    $0x20,%al
c0105f3a:	74 f3                	je     c0105f2f <strtol+0x16>
c0105f3c:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f3f:	0f b6 00             	movzbl (%eax),%eax
c0105f42:	3c 09                	cmp    $0x9,%al
c0105f44:	74 e9                	je     c0105f2f <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
c0105f46:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f49:	0f b6 00             	movzbl (%eax),%eax
c0105f4c:	3c 2b                	cmp    $0x2b,%al
c0105f4e:	75 05                	jne    c0105f55 <strtol+0x3c>
        s ++;
c0105f50:	ff 45 08             	incl   0x8(%ebp)
c0105f53:	eb 14                	jmp    c0105f69 <strtol+0x50>
    }
    else if (*s == '-') {
c0105f55:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f58:	0f b6 00             	movzbl (%eax),%eax
c0105f5b:	3c 2d                	cmp    $0x2d,%al
c0105f5d:	75 0a                	jne    c0105f69 <strtol+0x50>
        s ++, neg = 1;
c0105f5f:	ff 45 08             	incl   0x8(%ebp)
c0105f62:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
c0105f69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105f6d:	74 06                	je     c0105f75 <strtol+0x5c>
c0105f6f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
c0105f73:	75 22                	jne    c0105f97 <strtol+0x7e>
c0105f75:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f78:	0f b6 00             	movzbl (%eax),%eax
c0105f7b:	3c 30                	cmp    $0x30,%al
c0105f7d:	75 18                	jne    c0105f97 <strtol+0x7e>
c0105f7f:	8b 45 08             	mov    0x8(%ebp),%eax
c0105f82:	40                   	inc    %eax
c0105f83:	0f b6 00             	movzbl (%eax),%eax
c0105f86:	3c 78                	cmp    $0x78,%al
c0105f88:	75 0d                	jne    c0105f97 <strtol+0x7e>
        s += 2, base = 16;
c0105f8a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
c0105f8e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
c0105f95:	eb 29                	jmp    c0105fc0 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
c0105f97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105f9b:	75 16                	jne    c0105fb3 <strtol+0x9a>
c0105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fa0:	0f b6 00             	movzbl (%eax),%eax
c0105fa3:	3c 30                	cmp    $0x30,%al
c0105fa5:	75 0c                	jne    c0105fb3 <strtol+0x9a>
        s ++, base = 8;
c0105fa7:	ff 45 08             	incl   0x8(%ebp)
c0105faa:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
c0105fb1:	eb 0d                	jmp    c0105fc0 <strtol+0xa7>
    }
    else if (base == 0) {
c0105fb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
c0105fb7:	75 07                	jne    c0105fc0 <strtol+0xa7>
        base = 10;
c0105fb9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
c0105fc0:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fc3:	0f b6 00             	movzbl (%eax),%eax
c0105fc6:	3c 2f                	cmp    $0x2f,%al
c0105fc8:	7e 1b                	jle    c0105fe5 <strtol+0xcc>
c0105fca:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fcd:	0f b6 00             	movzbl (%eax),%eax
c0105fd0:	3c 39                	cmp    $0x39,%al
c0105fd2:	7f 11                	jg     c0105fe5 <strtol+0xcc>
            dig = *s - '0';
c0105fd4:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fd7:	0f b6 00             	movzbl (%eax),%eax
c0105fda:	0f be c0             	movsbl %al,%eax
c0105fdd:	83 e8 30             	sub    $0x30,%eax
c0105fe0:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0105fe3:	eb 48                	jmp    c010602d <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
c0105fe5:	8b 45 08             	mov    0x8(%ebp),%eax
c0105fe8:	0f b6 00             	movzbl (%eax),%eax
c0105feb:	3c 60                	cmp    $0x60,%al
c0105fed:	7e 1b                	jle    c010600a <strtol+0xf1>
c0105fef:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ff2:	0f b6 00             	movzbl (%eax),%eax
c0105ff5:	3c 7a                	cmp    $0x7a,%al
c0105ff7:	7f 11                	jg     c010600a <strtol+0xf1>
            dig = *s - 'a' + 10;
c0105ff9:	8b 45 08             	mov    0x8(%ebp),%eax
c0105ffc:	0f b6 00             	movzbl (%eax),%eax
c0105fff:	0f be c0             	movsbl %al,%eax
c0106002:	83 e8 57             	sub    $0x57,%eax
c0106005:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106008:	eb 23                	jmp    c010602d <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
c010600a:	8b 45 08             	mov    0x8(%ebp),%eax
c010600d:	0f b6 00             	movzbl (%eax),%eax
c0106010:	3c 40                	cmp    $0x40,%al
c0106012:	7e 3b                	jle    c010604f <strtol+0x136>
c0106014:	8b 45 08             	mov    0x8(%ebp),%eax
c0106017:	0f b6 00             	movzbl (%eax),%eax
c010601a:	3c 5a                	cmp    $0x5a,%al
c010601c:	7f 31                	jg     c010604f <strtol+0x136>
            dig = *s - 'A' + 10;
c010601e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106021:	0f b6 00             	movzbl (%eax),%eax
c0106024:	0f be c0             	movsbl %al,%eax
c0106027:	83 e8 37             	sub    $0x37,%eax
c010602a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
c010602d:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106030:	3b 45 10             	cmp    0x10(%ebp),%eax
c0106033:	7d 19                	jge    c010604e <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
c0106035:	ff 45 08             	incl   0x8(%ebp)
c0106038:	8b 45 f8             	mov    -0x8(%ebp),%eax
c010603b:	0f af 45 10          	imul   0x10(%ebp),%eax
c010603f:	89 c2                	mov    %eax,%edx
c0106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
c0106044:	01 d0                	add    %edx,%eax
c0106046:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
c0106049:	e9 72 ff ff ff       	jmp    c0105fc0 <strtol+0xa7>
            break;
c010604e:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
c010604f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
c0106053:	74 08                	je     c010605d <strtol+0x144>
        *endptr = (char *) s;
c0106055:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106058:	8b 55 08             	mov    0x8(%ebp),%edx
c010605b:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
c010605d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
c0106061:	74 07                	je     c010606a <strtol+0x151>
c0106063:	8b 45 f8             	mov    -0x8(%ebp),%eax
c0106066:	f7 d8                	neg    %eax
c0106068:	eb 03                	jmp    c010606d <strtol+0x154>
c010606a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
c010606d:	89 ec                	mov    %ebp,%esp
c010606f:	5d                   	pop    %ebp
c0106070:	c3                   	ret    

c0106071 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
c0106071:	55                   	push   %ebp
c0106072:	89 e5                	mov    %esp,%ebp
c0106074:	83 ec 28             	sub    $0x28,%esp
c0106077:	89 7d fc             	mov    %edi,-0x4(%ebp)
c010607a:	8b 45 0c             	mov    0xc(%ebp),%eax
c010607d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
c0106080:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
c0106084:	8b 45 08             	mov    0x8(%ebp),%eax
c0106087:	89 45 f8             	mov    %eax,-0x8(%ebp)
c010608a:	88 55 f7             	mov    %dl,-0x9(%ebp)
c010608d:	8b 45 10             	mov    0x10(%ebp),%eax
c0106090:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
c0106093:	8b 4d f0             	mov    -0x10(%ebp),%ecx
c0106096:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
c010609a:	8b 55 f8             	mov    -0x8(%ebp),%edx
c010609d:	89 d7                	mov    %edx,%edi
c010609f:	f3 aa                	rep stos %al,%es:(%edi)
c01060a1:	89 fa                	mov    %edi,%edx
c01060a3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
c01060a6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
c01060a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
c01060ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
c01060af:	89 ec                	mov    %ebp,%esp
c01060b1:	5d                   	pop    %ebp
c01060b2:	c3                   	ret    

c01060b3 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
c01060b3:	55                   	push   %ebp
c01060b4:	89 e5                	mov    %esp,%ebp
c01060b6:	57                   	push   %edi
c01060b7:	56                   	push   %esi
c01060b8:	53                   	push   %ebx
c01060b9:	83 ec 30             	sub    $0x30,%esp
c01060bc:	8b 45 08             	mov    0x8(%ebp),%eax
c01060bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
c01060c2:	8b 45 0c             	mov    0xc(%ebp),%eax
c01060c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
c01060c8:	8b 45 10             	mov    0x10(%ebp),%eax
c01060cb:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
c01060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060d1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
c01060d4:	73 42                	jae    c0106118 <memmove+0x65>
c01060d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
c01060d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
c01060dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
c01060df:	89 45 e0             	mov    %eax,-0x20(%ebp)
c01060e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
c01060e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c01060e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
c01060eb:	c1 e8 02             	shr    $0x2,%eax
c01060ee:	89 c1                	mov    %eax,%ecx
    asm volatile (
c01060f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
c01060f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
c01060f6:	89 d7                	mov    %edx,%edi
c01060f8:	89 c6                	mov    %eax,%esi
c01060fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c01060fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
c01060ff:	83 e1 03             	and    $0x3,%ecx
c0106102:	74 02                	je     c0106106 <memmove+0x53>
c0106104:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c0106106:	89 f0                	mov    %esi,%eax
c0106108:	89 fa                	mov    %edi,%edx
c010610a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
c010610d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
c0106110:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
c0106113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
c0106116:	eb 36                	jmp    c010614e <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
c0106118:	8b 45 e8             	mov    -0x18(%ebp),%eax
c010611b:	8d 50 ff             	lea    -0x1(%eax),%edx
c010611e:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106121:	01 c2                	add    %eax,%edx
c0106123:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106126:	8d 48 ff             	lea    -0x1(%eax),%ecx
c0106129:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010612c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
c010612f:	8b 45 e8             	mov    -0x18(%ebp),%eax
c0106132:	89 c1                	mov    %eax,%ecx
c0106134:	89 d8                	mov    %ebx,%eax
c0106136:	89 d6                	mov    %edx,%esi
c0106138:	89 c7                	mov    %eax,%edi
c010613a:	fd                   	std    
c010613b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010613d:	fc                   	cld    
c010613e:	89 f8                	mov    %edi,%eax
c0106140:	89 f2                	mov    %esi,%edx
c0106142:	89 4d cc             	mov    %ecx,-0x34(%ebp)
c0106145:	89 55 c8             	mov    %edx,-0x38(%ebp)
c0106148:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
c010614b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
c010614e:	83 c4 30             	add    $0x30,%esp
c0106151:	5b                   	pop    %ebx
c0106152:	5e                   	pop    %esi
c0106153:	5f                   	pop    %edi
c0106154:	5d                   	pop    %ebp
c0106155:	c3                   	ret    

c0106156 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
c0106156:	55                   	push   %ebp
c0106157:	89 e5                	mov    %esp,%ebp
c0106159:	57                   	push   %edi
c010615a:	56                   	push   %esi
c010615b:	83 ec 20             	sub    $0x20,%esp
c010615e:	8b 45 08             	mov    0x8(%ebp),%eax
c0106161:	89 45 f4             	mov    %eax,-0xc(%ebp)
c0106164:	8b 45 0c             	mov    0xc(%ebp),%eax
c0106167:	89 45 f0             	mov    %eax,-0x10(%ebp)
c010616a:	8b 45 10             	mov    0x10(%ebp),%eax
c010616d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
c0106170:	8b 45 ec             	mov    -0x14(%ebp),%eax
c0106173:	c1 e8 02             	shr    $0x2,%eax
c0106176:	89 c1                	mov    %eax,%ecx
    asm volatile (
c0106178:	8b 55 f4             	mov    -0xc(%ebp),%edx
c010617b:	8b 45 f0             	mov    -0x10(%ebp),%eax
c010617e:	89 d7                	mov    %edx,%edi
c0106180:	89 c6                	mov    %eax,%esi
c0106182:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
c0106184:	8b 4d ec             	mov    -0x14(%ebp),%ecx
c0106187:	83 e1 03             	and    $0x3,%ecx
c010618a:	74 02                	je     c010618e <memcpy+0x38>
c010618c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
c010618e:	89 f0                	mov    %esi,%eax
c0106190:	89 fa                	mov    %edi,%edx
c0106192:	89 4d e8             	mov    %ecx,-0x18(%ebp)
c0106195:	89 55 e4             	mov    %edx,-0x1c(%ebp)
c0106198:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
c010619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
c010619e:	83 c4 20             	add    $0x20,%esp
c01061a1:	5e                   	pop    %esi
c01061a2:	5f                   	pop    %edi
c01061a3:	5d                   	pop    %ebp
c01061a4:	c3                   	ret    

c01061a5 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
c01061a5:	55                   	push   %ebp
c01061a6:	89 e5                	mov    %esp,%ebp
c01061a8:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
c01061ab:	8b 45 08             	mov    0x8(%ebp),%eax
c01061ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
c01061b1:	8b 45 0c             	mov    0xc(%ebp),%eax
c01061b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
c01061b7:	eb 2e                	jmp    c01061e7 <memcmp+0x42>
        if (*s1 != *s2) {
c01061b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061bc:	0f b6 10             	movzbl (%eax),%edx
c01061bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01061c2:	0f b6 00             	movzbl (%eax),%eax
c01061c5:	38 c2                	cmp    %al,%dl
c01061c7:	74 18                	je     c01061e1 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
c01061c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
c01061cc:	0f b6 00             	movzbl (%eax),%eax
c01061cf:	0f b6 d0             	movzbl %al,%edx
c01061d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
c01061d5:	0f b6 00             	movzbl (%eax),%eax
c01061d8:	0f b6 c8             	movzbl %al,%ecx
c01061db:	89 d0                	mov    %edx,%eax
c01061dd:	29 c8                	sub    %ecx,%eax
c01061df:	eb 18                	jmp    c01061f9 <memcmp+0x54>
        }
        s1 ++, s2 ++;
c01061e1:	ff 45 fc             	incl   -0x4(%ebp)
c01061e4:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
c01061e7:	8b 45 10             	mov    0x10(%ebp),%eax
c01061ea:	8d 50 ff             	lea    -0x1(%eax),%edx
c01061ed:	89 55 10             	mov    %edx,0x10(%ebp)
c01061f0:	85 c0                	test   %eax,%eax
c01061f2:	75 c5                	jne    c01061b9 <memcmp+0x14>
    }
    return 0;
c01061f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
c01061f9:	89 ec                	mov    %ebp,%esp
c01061fb:	5d                   	pop    %ebp
c01061fc:	c3                   	ret    
