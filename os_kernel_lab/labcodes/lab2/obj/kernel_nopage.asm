
bin/kernel_nopage：     文件格式 elf32-i386


Disassembly of section .text:

00100000 <kern_entry>:

.text
.globl kern_entry
kern_entry:
    # load pa of boot pgdir
    movl $REALLOC(__boot_pgdir), %eax
  100000:	b8 00 a0 11 40       	mov    $0x4011a000,%eax
    movl %eax, %cr3
  100005:	0f 22 d8             	mov    %eax,%cr3

    # enable paging
    movl %cr0, %eax
  100008:	0f 20 c0             	mov    %cr0,%eax
    orl $(CR0_PE | CR0_PG | CR0_AM | CR0_WP | CR0_NE | CR0_TS | CR0_EM | CR0_MP), %eax
  10000b:	0d 2f 00 05 80       	or     $0x8005002f,%eax
    andl $~(CR0_TS | CR0_EM), %eax
  100010:	83 e0 f3             	and    $0xfffffff3,%eax
    movl %eax, %cr0
  100013:	0f 22 c0             	mov    %eax,%cr0

    # update eip
    # now, eip = 0x1.....
    leal next, %eax
  100016:	8d 05 1e 00 10 00    	lea    0x10001e,%eax
    # set eip = KERNBASE + 0x1.....
    jmp *%eax
  10001c:	ff e0                	jmp    *%eax

0010001e <next>:
next:

    # unmap va 0 ~ 4M, it's temporary mapping
    xorl %eax, %eax
  10001e:	31 c0                	xor    %eax,%eax
    movl %eax, __boot_pgdir
  100020:	a3 00 a0 11 00       	mov    %eax,0x11a000

    # set ebp, esp
    movl $0x0, %ebp
  100025:	bd 00 00 00 00       	mov    $0x0,%ebp
    # the kernel stack region is from bootstack -- bootstacktop,
    # the kernel stack size is KSTACKSIZE (8KB)defined in memlayout.h
    movl $bootstacktop, %esp
  10002a:	bc 00 90 11 00       	mov    $0x119000,%esp
    # now kernel stack is ready , call the first C function
    call kern_init
  10002f:	e8 02 00 00 00       	call   100036 <kern_init>

00100034 <spin>:

# should never get here
spin:
    jmp spin
  100034:	eb fe                	jmp    100034 <spin>

00100036 <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);
static void lab1_switch_test(void);

int
kern_init(void) {
  100036:	55                   	push   %ebp
  100037:	89 e5                	mov    %esp,%ebp
  100039:	83 ec 28             	sub    $0x28,%esp
    extern char edata[], end[];
    memset(edata, 0, end - edata);
  10003c:	b8 8c cf 11 00       	mov    $0x11cf8c,%eax
  100041:	2d 36 9a 11 00       	sub    $0x119a36,%eax
  100046:	89 44 24 08          	mov    %eax,0x8(%esp)
  10004a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  100051:	00 
  100052:	c7 04 24 36 9a 11 00 	movl   $0x119a36,(%esp)
  100059:	e8 13 60 00 00       	call   106071 <memset>

    cons_init();                // init the console
  10005e:	e8 f6 15 00 00       	call   101659 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
  100063:	c7 45 f4 00 62 10 00 	movl   $0x106200,-0xc(%ebp)
    cprintf("%s\n\n", message);
  10006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10006d:	89 44 24 04          	mov    %eax,0x4(%esp)
  100071:	c7 04 24 1c 62 10 00 	movl   $0x10621c,(%esp)
  100078:	e8 d9 02 00 00       	call   100356 <cprintf>

    print_kerninfo();
  10007d:	e8 f7 07 00 00       	call   100879 <print_kerninfo>

    grade_backtrace();
  100082:	e8 90 00 00 00       	call   100117 <grade_backtrace>

    pmm_init();                 // init physical memory management
  100087:	e8 5c 45 00 00       	call   1045e8 <pmm_init>

    pic_init();                 // init interrupt controller
  10008c:	e8 49 17 00 00       	call   1017da <pic_init>
    idt_init();                 // init interrupt descriptor table
  100091:	e8 d0 18 00 00       	call   101966 <idt_init>

    clock_init();               // init clock interrupt
  100096:	e8 1d 0d 00 00       	call   100db8 <clock_init>
    intr_enable();              // enable irq interrupt
  10009b:	e8 98 16 00 00       	call   101738 <intr_enable>
    //LAB1: CAHLLENGE 1 If you try to do it, uncomment lab1_switch_test()
    // user/kernel mode switch test
    //lab1_switch_test();

    /* do nothing */
    while (1);
  1000a0:	eb fe                	jmp    1000a0 <kern_init+0x6a>

001000a2 <grade_backtrace2>:
}

void __attribute__((noinline))
grade_backtrace2(int arg0, int arg1, int arg2, int arg3) {
  1000a2:	55                   	push   %ebp
  1000a3:	89 e5                	mov    %esp,%ebp
  1000a5:	83 ec 18             	sub    $0x18,%esp
    mon_backtrace(0, NULL, NULL);
  1000a8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1000af:	00 
  1000b0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  1000b7:	00 
  1000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1000bf:	e8 0f 0c 00 00       	call   100cd3 <mon_backtrace>
}
  1000c4:	90                   	nop
  1000c5:	89 ec                	mov    %ebp,%esp
  1000c7:	5d                   	pop    %ebp
  1000c8:	c3                   	ret    

001000c9 <grade_backtrace1>:

void __attribute__((noinline))
grade_backtrace1(int arg0, int arg1) {
  1000c9:	55                   	push   %ebp
  1000ca:	89 e5                	mov    %esp,%ebp
  1000cc:	83 ec 18             	sub    $0x18,%esp
  1000cf:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    grade_backtrace2(arg0, (int)&arg0, arg1, (int)&arg1);
  1000d2:	8d 4d 0c             	lea    0xc(%ebp),%ecx
  1000d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  1000d8:	8d 5d 08             	lea    0x8(%ebp),%ebx
  1000db:	8b 45 08             	mov    0x8(%ebp),%eax
  1000de:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  1000e2:	89 54 24 08          	mov    %edx,0x8(%esp)
  1000e6:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  1000ea:	89 04 24             	mov    %eax,(%esp)
  1000ed:	e8 b0 ff ff ff       	call   1000a2 <grade_backtrace2>
}
  1000f2:	90                   	nop
  1000f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  1000f6:	89 ec                	mov    %ebp,%esp
  1000f8:	5d                   	pop    %ebp
  1000f9:	c3                   	ret    

001000fa <grade_backtrace0>:

void __attribute__((noinline))
grade_backtrace0(int arg0, int arg1, int arg2) {
  1000fa:	55                   	push   %ebp
  1000fb:	89 e5                	mov    %esp,%ebp
  1000fd:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace1(arg0, arg2);
  100100:	8b 45 10             	mov    0x10(%ebp),%eax
  100103:	89 44 24 04          	mov    %eax,0x4(%esp)
  100107:	8b 45 08             	mov    0x8(%ebp),%eax
  10010a:	89 04 24             	mov    %eax,(%esp)
  10010d:	e8 b7 ff ff ff       	call   1000c9 <grade_backtrace1>
}
  100112:	90                   	nop
  100113:	89 ec                	mov    %ebp,%esp
  100115:	5d                   	pop    %ebp
  100116:	c3                   	ret    

00100117 <grade_backtrace>:

void
grade_backtrace(void) {
  100117:	55                   	push   %ebp
  100118:	89 e5                	mov    %esp,%ebp
  10011a:	83 ec 18             	sub    $0x18,%esp
    grade_backtrace0(0, (int)kern_init, 0xffff0000);
  10011d:	b8 36 00 10 00       	mov    $0x100036,%eax
  100122:	c7 44 24 08 00 00 ff 	movl   $0xffff0000,0x8(%esp)
  100129:	ff 
  10012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10012e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100135:	e8 c0 ff ff ff       	call   1000fa <grade_backtrace0>
}
  10013a:	90                   	nop
  10013b:	89 ec                	mov    %ebp,%esp
  10013d:	5d                   	pop    %ebp
  10013e:	c3                   	ret    

0010013f <lab1_print_cur_status>:

static void
lab1_print_cur_status(void) {
  10013f:	55                   	push   %ebp
  100140:	89 e5                	mov    %esp,%ebp
  100142:	83 ec 28             	sub    $0x28,%esp
    static int round = 0;
    uint16_t reg1, reg2, reg3, reg4;
    asm volatile (
  100145:	8c 4d f6             	mov    %cs,-0xa(%ebp)
  100148:	8c 5d f4             	mov    %ds,-0xc(%ebp)
  10014b:	8c 45 f2             	mov    %es,-0xe(%ebp)
  10014e:	8c 55 f0             	mov    %ss,-0x10(%ebp)
            "mov %%cs, %0;"
            "mov %%ds, %1;"
            "mov %%es, %2;"
            "mov %%ss, %3;"
            : "=m"(reg1), "=m"(reg2), "=m"(reg3), "=m"(reg4));
    cprintf("%d: @ring %d\n", round, reg1 & 3);
  100151:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100155:	83 e0 03             	and    $0x3,%eax
  100158:	89 c2                	mov    %eax,%edx
  10015a:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10015f:	89 54 24 08          	mov    %edx,0x8(%esp)
  100163:	89 44 24 04          	mov    %eax,0x4(%esp)
  100167:	c7 04 24 21 62 10 00 	movl   $0x106221,(%esp)
  10016e:	e8 e3 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  cs = %x\n", round, reg1);
  100173:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100177:	89 c2                	mov    %eax,%edx
  100179:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10017e:	89 54 24 08          	mov    %edx,0x8(%esp)
  100182:	89 44 24 04          	mov    %eax,0x4(%esp)
  100186:	c7 04 24 2f 62 10 00 	movl   $0x10622f,(%esp)
  10018d:	e8 c4 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ds = %x\n", round, reg2);
  100192:	0f b7 45 f4          	movzwl -0xc(%ebp),%eax
  100196:	89 c2                	mov    %eax,%edx
  100198:	a1 00 c0 11 00       	mov    0x11c000,%eax
  10019d:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001a5:	c7 04 24 3d 62 10 00 	movl   $0x10623d,(%esp)
  1001ac:	e8 a5 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  es = %x\n", round, reg3);
  1001b1:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  1001b5:	89 c2                	mov    %eax,%edx
  1001b7:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001bc:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001c0:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001c4:	c7 04 24 4b 62 10 00 	movl   $0x10624b,(%esp)
  1001cb:	e8 86 01 00 00       	call   100356 <cprintf>
    cprintf("%d:  ss = %x\n", round, reg4);
  1001d0:	0f b7 45 f0          	movzwl -0x10(%ebp),%eax
  1001d4:	89 c2                	mov    %eax,%edx
  1001d6:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001db:	89 54 24 08          	mov    %edx,0x8(%esp)
  1001df:	89 44 24 04          	mov    %eax,0x4(%esp)
  1001e3:	c7 04 24 59 62 10 00 	movl   $0x106259,(%esp)
  1001ea:	e8 67 01 00 00       	call   100356 <cprintf>
    round ++;
  1001ef:	a1 00 c0 11 00       	mov    0x11c000,%eax
  1001f4:	40                   	inc    %eax
  1001f5:	a3 00 c0 11 00       	mov    %eax,0x11c000
}
  1001fa:	90                   	nop
  1001fb:	89 ec                	mov    %ebp,%esp
  1001fd:	5d                   	pop    %ebp
  1001fe:	c3                   	ret    

001001ff <lab1_switch_to_user>:

static void
lab1_switch_to_user(void) {
  1001ff:	55                   	push   %ebp
  100200:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 : TODO
}
  100202:	90                   	nop
  100203:	5d                   	pop    %ebp
  100204:	c3                   	ret    

00100205 <lab1_switch_to_kernel>:

static void
lab1_switch_to_kernel(void) {
  100205:	55                   	push   %ebp
  100206:	89 e5                	mov    %esp,%ebp
    //LAB1 CHALLENGE 1 :  TODO
}
  100208:	90                   	nop
  100209:	5d                   	pop    %ebp
  10020a:	c3                   	ret    

0010020b <lab1_switch_test>:

static void
lab1_switch_test(void) {
  10020b:	55                   	push   %ebp
  10020c:	89 e5                	mov    %esp,%ebp
  10020e:	83 ec 18             	sub    $0x18,%esp
    lab1_print_cur_status();
  100211:	e8 29 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to  user  mode +++\n");
  100216:	c7 04 24 68 62 10 00 	movl   $0x106268,(%esp)
  10021d:	e8 34 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_user();
  100222:	e8 d8 ff ff ff       	call   1001ff <lab1_switch_to_user>
    lab1_print_cur_status();
  100227:	e8 13 ff ff ff       	call   10013f <lab1_print_cur_status>
    cprintf("+++ switch to kernel mode +++\n");
  10022c:	c7 04 24 88 62 10 00 	movl   $0x106288,(%esp)
  100233:	e8 1e 01 00 00       	call   100356 <cprintf>
    lab1_switch_to_kernel();
  100238:	e8 c8 ff ff ff       	call   100205 <lab1_switch_to_kernel>
    lab1_print_cur_status();
  10023d:	e8 fd fe ff ff       	call   10013f <lab1_print_cur_status>
}
  100242:	90                   	nop
  100243:	89 ec                	mov    %ebp,%esp
  100245:	5d                   	pop    %ebp
  100246:	c3                   	ret    

00100247 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
  100247:	55                   	push   %ebp
  100248:	89 e5                	mov    %esp,%ebp
  10024a:	83 ec 28             	sub    $0x28,%esp
    if (prompt != NULL) {
  10024d:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100251:	74 13                	je     100266 <readline+0x1f>
        cprintf("%s", prompt);
  100253:	8b 45 08             	mov    0x8(%ebp),%eax
  100256:	89 44 24 04          	mov    %eax,0x4(%esp)
  10025a:	c7 04 24 a7 62 10 00 	movl   $0x1062a7,(%esp)
  100261:	e8 f0 00 00 00       	call   100356 <cprintf>
    }
    int i = 0, c;
  100266:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        c = getchar();
  10026d:	e8 73 01 00 00       	call   1003e5 <getchar>
  100272:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (c < 0) {
  100275:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100279:	79 07                	jns    100282 <readline+0x3b>
            return NULL;
  10027b:	b8 00 00 00 00       	mov    $0x0,%eax
  100280:	eb 78                	jmp    1002fa <readline+0xb3>
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
  100282:	83 7d f0 1f          	cmpl   $0x1f,-0x10(%ebp)
  100286:	7e 28                	jle    1002b0 <readline+0x69>
  100288:	81 7d f4 fe 03 00 00 	cmpl   $0x3fe,-0xc(%ebp)
  10028f:	7f 1f                	jg     1002b0 <readline+0x69>
            cputchar(c);
  100291:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100294:	89 04 24             	mov    %eax,(%esp)
  100297:	e8 e2 00 00 00       	call   10037e <cputchar>
            buf[i ++] = c;
  10029c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10029f:	8d 50 01             	lea    0x1(%eax),%edx
  1002a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
  1002a5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1002a8:	88 90 20 c0 11 00    	mov    %dl,0x11c020(%eax)
  1002ae:	eb 45                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\b' && i > 0) {
  1002b0:	83 7d f0 08          	cmpl   $0x8,-0x10(%ebp)
  1002b4:	75 16                	jne    1002cc <readline+0x85>
  1002b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1002ba:	7e 10                	jle    1002cc <readline+0x85>
            cputchar(c);
  1002bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002bf:	89 04 24             	mov    %eax,(%esp)
  1002c2:	e8 b7 00 00 00       	call   10037e <cputchar>
            i --;
  1002c7:	ff 4d f4             	decl   -0xc(%ebp)
  1002ca:	eb 29                	jmp    1002f5 <readline+0xae>
        }
        else if (c == '\n' || c == '\r') {
  1002cc:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
  1002d0:	74 06                	je     1002d8 <readline+0x91>
  1002d2:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
  1002d6:	75 95                	jne    10026d <readline+0x26>
            cputchar(c);
  1002d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1002db:	89 04 24             	mov    %eax,(%esp)
  1002de:	e8 9b 00 00 00       	call   10037e <cputchar>
            buf[i] = '\0';
  1002e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1002e6:	05 20 c0 11 00       	add    $0x11c020,%eax
  1002eb:	c6 00 00             	movb   $0x0,(%eax)
            return buf;
  1002ee:	b8 20 c0 11 00       	mov    $0x11c020,%eax
  1002f3:	eb 05                	jmp    1002fa <readline+0xb3>
        c = getchar();
  1002f5:	e9 73 ff ff ff       	jmp    10026d <readline+0x26>
        }
    }
}
  1002fa:	89 ec                	mov    %ebp,%esp
  1002fc:	5d                   	pop    %ebp
  1002fd:	c3                   	ret    

001002fe <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  1002fe:	55                   	push   %ebp
  1002ff:	89 e5                	mov    %esp,%ebp
  100301:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100304:	8b 45 08             	mov    0x8(%ebp),%eax
  100307:	89 04 24             	mov    %eax,(%esp)
  10030a:	e8 79 13 00 00       	call   101688 <cons_putc>
    (*cnt) ++;
  10030f:	8b 45 0c             	mov    0xc(%ebp),%eax
  100312:	8b 00                	mov    (%eax),%eax
  100314:	8d 50 01             	lea    0x1(%eax),%edx
  100317:	8b 45 0c             	mov    0xc(%ebp),%eax
  10031a:	89 10                	mov    %edx,(%eax)
}
  10031c:	90                   	nop
  10031d:	89 ec                	mov    %ebp,%esp
  10031f:	5d                   	pop    %ebp
  100320:	c3                   	ret    

00100321 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  100321:	55                   	push   %ebp
  100322:	89 e5                	mov    %esp,%ebp
  100324:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  100327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  10032e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100331:	89 44 24 0c          	mov    %eax,0xc(%esp)
  100335:	8b 45 08             	mov    0x8(%ebp),%eax
  100338:	89 44 24 08          	mov    %eax,0x8(%esp)
  10033c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  10033f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100343:	c7 04 24 fe 02 10 00 	movl   $0x1002fe,(%esp)
  10034a:	e8 4d 55 00 00       	call   10589c <vprintfmt>
    return cnt;
  10034f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100352:	89 ec                	mov    %ebp,%esp
  100354:	5d                   	pop    %ebp
  100355:	c3                   	ret    

00100356 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  100356:	55                   	push   %ebp
  100357:	89 e5                	mov    %esp,%ebp
  100359:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  10035c:	8d 45 0c             	lea    0xc(%ebp),%eax
  10035f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vcprintf(fmt, ap);
  100362:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100365:	89 44 24 04          	mov    %eax,0x4(%esp)
  100369:	8b 45 08             	mov    0x8(%ebp),%eax
  10036c:	89 04 24             	mov    %eax,(%esp)
  10036f:	e8 ad ff ff ff       	call   100321 <vcprintf>
  100374:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  100377:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  10037a:	89 ec                	mov    %ebp,%esp
  10037c:	5d                   	pop    %ebp
  10037d:	c3                   	ret    

0010037e <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
  10037e:	55                   	push   %ebp
  10037f:	89 e5                	mov    %esp,%ebp
  100381:	83 ec 18             	sub    $0x18,%esp
    cons_putc(c);
  100384:	8b 45 08             	mov    0x8(%ebp),%eax
  100387:	89 04 24             	mov    %eax,(%esp)
  10038a:	e8 f9 12 00 00       	call   101688 <cons_putc>
}
  10038f:	90                   	nop
  100390:	89 ec                	mov    %ebp,%esp
  100392:	5d                   	pop    %ebp
  100393:	c3                   	ret    

00100394 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
  100394:	55                   	push   %ebp
  100395:	89 e5                	mov    %esp,%ebp
  100397:	83 ec 28             	sub    $0x28,%esp
    int cnt = 0;
  10039a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    char c;
    while ((c = *str ++) != '\0') {
  1003a1:	eb 13                	jmp    1003b6 <cputs+0x22>
        cputch(c, &cnt);
  1003a3:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  1003a7:	8d 55 f0             	lea    -0x10(%ebp),%edx
  1003aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  1003ae:	89 04 24             	mov    %eax,(%esp)
  1003b1:	e8 48 ff ff ff       	call   1002fe <cputch>
    while ((c = *str ++) != '\0') {
  1003b6:	8b 45 08             	mov    0x8(%ebp),%eax
  1003b9:	8d 50 01             	lea    0x1(%eax),%edx
  1003bc:	89 55 08             	mov    %edx,0x8(%ebp)
  1003bf:	0f b6 00             	movzbl (%eax),%eax
  1003c2:	88 45 f7             	mov    %al,-0x9(%ebp)
  1003c5:	80 7d f7 00          	cmpb   $0x0,-0x9(%ebp)
  1003c9:	75 d8                	jne    1003a3 <cputs+0xf>
    }
    cputch('\n', &cnt);
  1003cb:	8d 45 f0             	lea    -0x10(%ebp),%eax
  1003ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  1003d2:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  1003d9:	e8 20 ff ff ff       	call   1002fe <cputch>
    return cnt;
  1003de:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1003e1:	89 ec                	mov    %ebp,%esp
  1003e3:	5d                   	pop    %ebp
  1003e4:	c3                   	ret    

001003e5 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
  1003e5:	55                   	push   %ebp
  1003e6:	89 e5                	mov    %esp,%ebp
  1003e8:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = cons_getc()) == 0)
  1003eb:	90                   	nop
  1003ec:	e8 d6 12 00 00       	call   1016c7 <cons_getc>
  1003f1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1003f4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1003f8:	74 f2                	je     1003ec <getchar+0x7>
        /* do nothing */;
    return c;
  1003fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  1003fd:	89 ec                	mov    %ebp,%esp
  1003ff:	5d                   	pop    %ebp
  100400:	c3                   	ret    

00100401 <stab_binsearch>:
 *      stab_binsearch(stabs, &left, &right, N_SO, 0xf0100184);
 * will exit setting left = 118, right = 554.
 * */
static void
stab_binsearch(const struct stab *stabs, int *region_left, int *region_right,
           int type, uintptr_t addr) {
  100401:	55                   	push   %ebp
  100402:	89 e5                	mov    %esp,%ebp
  100404:	83 ec 20             	sub    $0x20,%esp
    int l = *region_left, r = *region_right, any_matches = 0;
  100407:	8b 45 0c             	mov    0xc(%ebp),%eax
  10040a:	8b 00                	mov    (%eax),%eax
  10040c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  10040f:	8b 45 10             	mov    0x10(%ebp),%eax
  100412:	8b 00                	mov    (%eax),%eax
  100414:	89 45 f8             	mov    %eax,-0x8(%ebp)
  100417:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

    while (l <= r) {
  10041e:	e9 ca 00 00 00       	jmp    1004ed <stab_binsearch+0xec>
        int true_m = (l + r) / 2, m = true_m;
  100423:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100426:	8b 45 f8             	mov    -0x8(%ebp),%eax
  100429:	01 d0                	add    %edx,%eax
  10042b:	89 c2                	mov    %eax,%edx
  10042d:	c1 ea 1f             	shr    $0x1f,%edx
  100430:	01 d0                	add    %edx,%eax
  100432:	d1 f8                	sar    %eax
  100434:	89 45 ec             	mov    %eax,-0x14(%ebp)
  100437:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10043a:	89 45 f0             	mov    %eax,-0x10(%ebp)

        // search for earliest stab with right type
        while (m >= l && stabs[m].n_type != type) {
  10043d:	eb 03                	jmp    100442 <stab_binsearch+0x41>
            m --;
  10043f:	ff 4d f0             	decl   -0x10(%ebp)
        while (m >= l && stabs[m].n_type != type) {
  100442:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100445:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  100448:	7c 1f                	jl     100469 <stab_binsearch+0x68>
  10044a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10044d:	89 d0                	mov    %edx,%eax
  10044f:	01 c0                	add    %eax,%eax
  100451:	01 d0                	add    %edx,%eax
  100453:	c1 e0 02             	shl    $0x2,%eax
  100456:	89 c2                	mov    %eax,%edx
  100458:	8b 45 08             	mov    0x8(%ebp),%eax
  10045b:	01 d0                	add    %edx,%eax
  10045d:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100461:	0f b6 c0             	movzbl %al,%eax
  100464:	39 45 14             	cmp    %eax,0x14(%ebp)
  100467:	75 d6                	jne    10043f <stab_binsearch+0x3e>
        }
        if (m < l) {    // no match in [l, m]
  100469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10046c:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  10046f:	7d 09                	jge    10047a <stab_binsearch+0x79>
            l = true_m + 1;
  100471:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100474:	40                   	inc    %eax
  100475:	89 45 fc             	mov    %eax,-0x4(%ebp)
            continue;
  100478:	eb 73                	jmp    1004ed <stab_binsearch+0xec>
        }

        // actual binary search
        any_matches = 1;
  10047a:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
        if (stabs[m].n_value < addr) {
  100481:	8b 55 f0             	mov    -0x10(%ebp),%edx
  100484:	89 d0                	mov    %edx,%eax
  100486:	01 c0                	add    %eax,%eax
  100488:	01 d0                	add    %edx,%eax
  10048a:	c1 e0 02             	shl    $0x2,%eax
  10048d:	89 c2                	mov    %eax,%edx
  10048f:	8b 45 08             	mov    0x8(%ebp),%eax
  100492:	01 d0                	add    %edx,%eax
  100494:	8b 40 08             	mov    0x8(%eax),%eax
  100497:	39 45 18             	cmp    %eax,0x18(%ebp)
  10049a:	76 11                	jbe    1004ad <stab_binsearch+0xac>
            *region_left = m;
  10049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10049f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004a2:	89 10                	mov    %edx,(%eax)
            l = true_m + 1;
  1004a4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1004a7:	40                   	inc    %eax
  1004a8:	89 45 fc             	mov    %eax,-0x4(%ebp)
  1004ab:	eb 40                	jmp    1004ed <stab_binsearch+0xec>
        } else if (stabs[m].n_value > addr) {
  1004ad:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004b0:	89 d0                	mov    %edx,%eax
  1004b2:	01 c0                	add    %eax,%eax
  1004b4:	01 d0                	add    %edx,%eax
  1004b6:	c1 e0 02             	shl    $0x2,%eax
  1004b9:	89 c2                	mov    %eax,%edx
  1004bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1004be:	01 d0                	add    %edx,%eax
  1004c0:	8b 40 08             	mov    0x8(%eax),%eax
  1004c3:	39 45 18             	cmp    %eax,0x18(%ebp)
  1004c6:	73 14                	jae    1004dc <stab_binsearch+0xdb>
            *region_right = m - 1;
  1004c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004cb:	8d 50 ff             	lea    -0x1(%eax),%edx
  1004ce:	8b 45 10             	mov    0x10(%ebp),%eax
  1004d1:	89 10                	mov    %edx,(%eax)
            r = m - 1;
  1004d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004d6:	48                   	dec    %eax
  1004d7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  1004da:	eb 11                	jmp    1004ed <stab_binsearch+0xec>
        } else {
            // exact match for 'addr', but continue loop to find
            // *region_right
            *region_left = m;
  1004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1004df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  1004e2:	89 10                	mov    %edx,(%eax)
            l = m;
  1004e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1004e7:	89 45 fc             	mov    %eax,-0x4(%ebp)
            addr ++;
  1004ea:	ff 45 18             	incl   0x18(%ebp)
    while (l <= r) {
  1004ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1004f0:	3b 45 f8             	cmp    -0x8(%ebp),%eax
  1004f3:	0f 8e 2a ff ff ff    	jle    100423 <stab_binsearch+0x22>
        }
    }

    if (!any_matches) {
  1004f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1004fd:	75 0f                	jne    10050e <stab_binsearch+0x10d>
        *region_right = *region_left - 1;
  1004ff:	8b 45 0c             	mov    0xc(%ebp),%eax
  100502:	8b 00                	mov    (%eax),%eax
  100504:	8d 50 ff             	lea    -0x1(%eax),%edx
  100507:	8b 45 10             	mov    0x10(%ebp),%eax
  10050a:	89 10                	mov    %edx,(%eax)
        l = *region_right;
        for (; l > *region_left && stabs[l].n_type != type; l --)
            /* do nothing */;
        *region_left = l;
    }
}
  10050c:	eb 3e                	jmp    10054c <stab_binsearch+0x14b>
        l = *region_right;
  10050e:	8b 45 10             	mov    0x10(%ebp),%eax
  100511:	8b 00                	mov    (%eax),%eax
  100513:	89 45 fc             	mov    %eax,-0x4(%ebp)
        for (; l > *region_left && stabs[l].n_type != type; l --)
  100516:	eb 03                	jmp    10051b <stab_binsearch+0x11a>
  100518:	ff 4d fc             	decl   -0x4(%ebp)
  10051b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10051e:	8b 00                	mov    (%eax),%eax
  100520:	39 45 fc             	cmp    %eax,-0x4(%ebp)
  100523:	7e 1f                	jle    100544 <stab_binsearch+0x143>
  100525:	8b 55 fc             	mov    -0x4(%ebp),%edx
  100528:	89 d0                	mov    %edx,%eax
  10052a:	01 c0                	add    %eax,%eax
  10052c:	01 d0                	add    %edx,%eax
  10052e:	c1 e0 02             	shl    $0x2,%eax
  100531:	89 c2                	mov    %eax,%edx
  100533:	8b 45 08             	mov    0x8(%ebp),%eax
  100536:	01 d0                	add    %edx,%eax
  100538:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10053c:	0f b6 c0             	movzbl %al,%eax
  10053f:	39 45 14             	cmp    %eax,0x14(%ebp)
  100542:	75 d4                	jne    100518 <stab_binsearch+0x117>
        *region_left = l;
  100544:	8b 45 0c             	mov    0xc(%ebp),%eax
  100547:	8b 55 fc             	mov    -0x4(%ebp),%edx
  10054a:	89 10                	mov    %edx,(%eax)
}
  10054c:	90                   	nop
  10054d:	89 ec                	mov    %ebp,%esp
  10054f:	5d                   	pop    %ebp
  100550:	c3                   	ret    

00100551 <debuginfo_eip>:
 * the specified instruction address, @addr.  Returns 0 if information
 * was found, and negative if not.  But even if it returns negative it
 * has stored some information into '*info'.
 * */
int
debuginfo_eip(uintptr_t addr, struct eipdebuginfo *info) {
  100551:	55                   	push   %ebp
  100552:	89 e5                	mov    %esp,%ebp
  100554:	83 ec 58             	sub    $0x58,%esp
    const struct stab *stabs, *stab_end;
    const char *stabstr, *stabstr_end;

    info->eip_file = "<unknown>";
  100557:	8b 45 0c             	mov    0xc(%ebp),%eax
  10055a:	c7 00 ac 62 10 00    	movl   $0x1062ac,(%eax)
    info->eip_line = 0;
  100560:	8b 45 0c             	mov    0xc(%ebp),%eax
  100563:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
    info->eip_fn_name = "<unknown>";
  10056a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10056d:	c7 40 08 ac 62 10 00 	movl   $0x1062ac,0x8(%eax)
    info->eip_fn_namelen = 9;
  100574:	8b 45 0c             	mov    0xc(%ebp),%eax
  100577:	c7 40 0c 09 00 00 00 	movl   $0x9,0xc(%eax)
    info->eip_fn_addr = addr;
  10057e:	8b 45 0c             	mov    0xc(%ebp),%eax
  100581:	8b 55 08             	mov    0x8(%ebp),%edx
  100584:	89 50 10             	mov    %edx,0x10(%eax)
    info->eip_fn_narg = 0;
  100587:	8b 45 0c             	mov    0xc(%ebp),%eax
  10058a:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)

    stabs = __STAB_BEGIN__;
  100591:	c7 45 f4 90 75 10 00 	movl   $0x107590,-0xc(%ebp)
    stab_end = __STAB_END__;
  100598:	c7 45 f0 f4 2e 11 00 	movl   $0x112ef4,-0x10(%ebp)
    stabstr = __STABSTR_BEGIN__;
  10059f:	c7 45 ec f5 2e 11 00 	movl   $0x112ef5,-0x14(%ebp)
    stabstr_end = __STABSTR_END__;
  1005a6:	c7 45 e8 b0 64 11 00 	movl   $0x1164b0,-0x18(%ebp)

    // String table validity checks
    if (stabstr_end <= stabstr || stabstr_end[-1] != 0) {
  1005ad:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1005b3:	76 0b                	jbe    1005c0 <debuginfo_eip+0x6f>
  1005b5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1005b8:	48                   	dec    %eax
  1005b9:	0f b6 00             	movzbl (%eax),%eax
  1005bc:	84 c0                	test   %al,%al
  1005be:	74 0a                	je     1005ca <debuginfo_eip+0x79>
        return -1;
  1005c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1005c5:	e9 ab 02 00 00       	jmp    100875 <debuginfo_eip+0x324>
    // 'eip'.  First, we find the basic source file containing 'eip'.
    // Then, we look in that source file for the function.  Then we look
    // for the line number.

    // Search the entire set of stabs for the source file (type N_SO).
    int lfile = 0, rfile = (stab_end - stabs) - 1;
  1005ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  1005d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1005d4:	2b 45 f4             	sub    -0xc(%ebp),%eax
  1005d7:	c1 f8 02             	sar    $0x2,%eax
  1005da:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
  1005e0:	48                   	dec    %eax
  1005e1:	89 45 e0             	mov    %eax,-0x20(%ebp)
    stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
  1005e4:	8b 45 08             	mov    0x8(%ebp),%eax
  1005e7:	89 44 24 10          	mov    %eax,0x10(%esp)
  1005eb:	c7 44 24 0c 64 00 00 	movl   $0x64,0xc(%esp)
  1005f2:	00 
  1005f3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  1005f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1005fa:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  1005fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100601:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100604:	89 04 24             	mov    %eax,(%esp)
  100607:	e8 f5 fd ff ff       	call   100401 <stab_binsearch>
    if (lfile == 0)
  10060c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10060f:	85 c0                	test   %eax,%eax
  100611:	75 0a                	jne    10061d <debuginfo_eip+0xcc>
        return -1;
  100613:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100618:	e9 58 02 00 00       	jmp    100875 <debuginfo_eip+0x324>

    // Search within that file's stabs for the function definition
    // (N_FUN).
    int lfun = lfile, rfun = rfile;
  10061d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  100620:	89 45 dc             	mov    %eax,-0x24(%ebp)
  100623:	8b 45 e0             	mov    -0x20(%ebp),%eax
  100626:	89 45 d8             	mov    %eax,-0x28(%ebp)
    int lline, rline;
    stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
  100629:	8b 45 08             	mov    0x8(%ebp),%eax
  10062c:	89 44 24 10          	mov    %eax,0x10(%esp)
  100630:	c7 44 24 0c 24 00 00 	movl   $0x24,0xc(%esp)
  100637:	00 
  100638:	8d 45 d8             	lea    -0x28(%ebp),%eax
  10063b:	89 44 24 08          	mov    %eax,0x8(%esp)
  10063f:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100642:	89 44 24 04          	mov    %eax,0x4(%esp)
  100646:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100649:	89 04 24             	mov    %eax,(%esp)
  10064c:	e8 b0 fd ff ff       	call   100401 <stab_binsearch>

    if (lfun <= rfun) {
  100651:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100654:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100657:	39 c2                	cmp    %eax,%edx
  100659:	7f 78                	jg     1006d3 <debuginfo_eip+0x182>
        // stabs[lfun] points to the function name
        // in the string table, but check bounds just in case.
        if (stabs[lfun].n_strx < stabstr_end - stabstr) {
  10065b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10065e:	89 c2                	mov    %eax,%edx
  100660:	89 d0                	mov    %edx,%eax
  100662:	01 c0                	add    %eax,%eax
  100664:	01 d0                	add    %edx,%eax
  100666:	c1 e0 02             	shl    $0x2,%eax
  100669:	89 c2                	mov    %eax,%edx
  10066b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10066e:	01 d0                	add    %edx,%eax
  100670:	8b 10                	mov    (%eax),%edx
  100672:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100675:	2b 45 ec             	sub    -0x14(%ebp),%eax
  100678:	39 c2                	cmp    %eax,%edx
  10067a:	73 22                	jae    10069e <debuginfo_eip+0x14d>
            info->eip_fn_name = stabstr + stabs[lfun].n_strx;
  10067c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10067f:	89 c2                	mov    %eax,%edx
  100681:	89 d0                	mov    %edx,%eax
  100683:	01 c0                	add    %eax,%eax
  100685:	01 d0                	add    %edx,%eax
  100687:	c1 e0 02             	shl    $0x2,%eax
  10068a:	89 c2                	mov    %eax,%edx
  10068c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10068f:	01 d0                	add    %edx,%eax
  100691:	8b 10                	mov    (%eax),%edx
  100693:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100696:	01 c2                	add    %eax,%edx
  100698:	8b 45 0c             	mov    0xc(%ebp),%eax
  10069b:	89 50 08             	mov    %edx,0x8(%eax)
        }
        info->eip_fn_addr = stabs[lfun].n_value;
  10069e:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006a1:	89 c2                	mov    %eax,%edx
  1006a3:	89 d0                	mov    %edx,%eax
  1006a5:	01 c0                	add    %eax,%eax
  1006a7:	01 d0                	add    %edx,%eax
  1006a9:	c1 e0 02             	shl    $0x2,%eax
  1006ac:	89 c2                	mov    %eax,%edx
  1006ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1006b1:	01 d0                	add    %edx,%eax
  1006b3:	8b 50 08             	mov    0x8(%eax),%edx
  1006b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006b9:	89 50 10             	mov    %edx,0x10(%eax)
        addr -= info->eip_fn_addr;
  1006bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006bf:	8b 40 10             	mov    0x10(%eax),%eax
  1006c2:	29 45 08             	sub    %eax,0x8(%ebp)
        // Search within the function definition for the line number.
        lline = lfun;
  1006c5:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1006c8:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfun;
  1006cb:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1006ce:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1006d1:	eb 15                	jmp    1006e8 <debuginfo_eip+0x197>
    } else {
        // Couldn't find function stab!  Maybe we're in an assembly
        // file.  Search the whole file for the line number.
        info->eip_fn_addr = addr;
  1006d3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006d6:	8b 55 08             	mov    0x8(%ebp),%edx
  1006d9:	89 50 10             	mov    %edx,0x10(%eax)
        lline = lfile;
  1006dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1006df:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        rline = rfile;
  1006e2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1006e5:	89 45 d0             	mov    %eax,-0x30(%ebp)
    }
    info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
  1006e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1006eb:	8b 40 08             	mov    0x8(%eax),%eax
  1006ee:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
  1006f5:	00 
  1006f6:	89 04 24             	mov    %eax,(%esp)
  1006f9:	e8 eb 57 00 00       	call   105ee9 <strfind>
  1006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  100701:	8b 4a 08             	mov    0x8(%edx),%ecx
  100704:	29 c8                	sub    %ecx,%eax
  100706:	89 c2                	mov    %eax,%edx
  100708:	8b 45 0c             	mov    0xc(%ebp),%eax
  10070b:	89 50 0c             	mov    %edx,0xc(%eax)

    // Search within [lline, rline] for the line number stab.
    // If found, set info->eip_line to the right line number.
    // If not found, return -1.
    stab_binsearch(stabs, &lline, &rline, N_SLINE, addr);
  10070e:	8b 45 08             	mov    0x8(%ebp),%eax
  100711:	89 44 24 10          	mov    %eax,0x10(%esp)
  100715:	c7 44 24 0c 44 00 00 	movl   $0x44,0xc(%esp)
  10071c:	00 
  10071d:	8d 45 d0             	lea    -0x30(%ebp),%eax
  100720:	89 44 24 08          	mov    %eax,0x8(%esp)
  100724:	8d 45 d4             	lea    -0x2c(%ebp),%eax
  100727:	89 44 24 04          	mov    %eax,0x4(%esp)
  10072b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10072e:	89 04 24             	mov    %eax,(%esp)
  100731:	e8 cb fc ff ff       	call   100401 <stab_binsearch>
    if (lline <= rline) {
  100736:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100739:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10073c:	39 c2                	cmp    %eax,%edx
  10073e:	7f 23                	jg     100763 <debuginfo_eip+0x212>
        info->eip_line = stabs[rline].n_desc;
  100740:	8b 45 d0             	mov    -0x30(%ebp),%eax
  100743:	89 c2                	mov    %eax,%edx
  100745:	89 d0                	mov    %edx,%eax
  100747:	01 c0                	add    %eax,%eax
  100749:	01 d0                	add    %edx,%eax
  10074b:	c1 e0 02             	shl    $0x2,%eax
  10074e:	89 c2                	mov    %eax,%edx
  100750:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100753:	01 d0                	add    %edx,%eax
  100755:	0f b7 40 06          	movzwl 0x6(%eax),%eax
  100759:	89 c2                	mov    %eax,%edx
  10075b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10075e:	89 50 04             	mov    %edx,0x4(%eax)

    // Search backwards from the line number for the relevant filename stab.
    // We can't just use the "lfile" stab because inlined functions
    // can interpolate code from a different file!
    // Such included source files use the N_SOL stab type.
    while (lline >= lfile
  100761:	eb 11                	jmp    100774 <debuginfo_eip+0x223>
        return -1;
  100763:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  100768:	e9 08 01 00 00       	jmp    100875 <debuginfo_eip+0x324>
           && stabs[lline].n_type != N_SOL
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
        lline --;
  10076d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100770:	48                   	dec    %eax
  100771:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    while (lline >= lfile
  100774:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  100777:	8b 45 e4             	mov    -0x1c(%ebp),%eax
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10077a:	39 c2                	cmp    %eax,%edx
  10077c:	7c 56                	jl     1007d4 <debuginfo_eip+0x283>
           && stabs[lline].n_type != N_SOL
  10077e:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100781:	89 c2                	mov    %eax,%edx
  100783:	89 d0                	mov    %edx,%eax
  100785:	01 c0                	add    %eax,%eax
  100787:	01 d0                	add    %edx,%eax
  100789:	c1 e0 02             	shl    $0x2,%eax
  10078c:	89 c2                	mov    %eax,%edx
  10078e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100791:	01 d0                	add    %edx,%eax
  100793:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  100797:	3c 84                	cmp    $0x84,%al
  100799:	74 39                	je     1007d4 <debuginfo_eip+0x283>
           && (stabs[lline].n_type != N_SO || !stabs[lline].n_value)) {
  10079b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  10079e:	89 c2                	mov    %eax,%edx
  1007a0:	89 d0                	mov    %edx,%eax
  1007a2:	01 c0                	add    %eax,%eax
  1007a4:	01 d0                	add    %edx,%eax
  1007a6:	c1 e0 02             	shl    $0x2,%eax
  1007a9:	89 c2                	mov    %eax,%edx
  1007ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007ae:	01 d0                	add    %edx,%eax
  1007b0:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  1007b4:	3c 64                	cmp    $0x64,%al
  1007b6:	75 b5                	jne    10076d <debuginfo_eip+0x21c>
  1007b8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007bb:	89 c2                	mov    %eax,%edx
  1007bd:	89 d0                	mov    %edx,%eax
  1007bf:	01 c0                	add    %eax,%eax
  1007c1:	01 d0                	add    %edx,%eax
  1007c3:	c1 e0 02             	shl    $0x2,%eax
  1007c6:	89 c2                	mov    %eax,%edx
  1007c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007cb:	01 d0                	add    %edx,%eax
  1007cd:	8b 40 08             	mov    0x8(%eax),%eax
  1007d0:	85 c0                	test   %eax,%eax
  1007d2:	74 99                	je     10076d <debuginfo_eip+0x21c>
    }
    if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr) {
  1007d4:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1007d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1007da:	39 c2                	cmp    %eax,%edx
  1007dc:	7c 42                	jl     100820 <debuginfo_eip+0x2cf>
  1007de:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1007e1:	89 c2                	mov    %eax,%edx
  1007e3:	89 d0                	mov    %edx,%eax
  1007e5:	01 c0                	add    %eax,%eax
  1007e7:	01 d0                	add    %edx,%eax
  1007e9:	c1 e0 02             	shl    $0x2,%eax
  1007ec:	89 c2                	mov    %eax,%edx
  1007ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1007f1:	01 d0                	add    %edx,%eax
  1007f3:	8b 10                	mov    (%eax),%edx
  1007f5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1007f8:	2b 45 ec             	sub    -0x14(%ebp),%eax
  1007fb:	39 c2                	cmp    %eax,%edx
  1007fd:	73 21                	jae    100820 <debuginfo_eip+0x2cf>
        info->eip_file = stabstr + stabs[lline].n_strx;
  1007ff:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100802:	89 c2                	mov    %eax,%edx
  100804:	89 d0                	mov    %edx,%eax
  100806:	01 c0                	add    %eax,%eax
  100808:	01 d0                	add    %edx,%eax
  10080a:	c1 e0 02             	shl    $0x2,%eax
  10080d:	89 c2                	mov    %eax,%edx
  10080f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100812:	01 d0                	add    %edx,%eax
  100814:	8b 10                	mov    (%eax),%edx
  100816:	8b 45 ec             	mov    -0x14(%ebp),%eax
  100819:	01 c2                	add    %eax,%edx
  10081b:	8b 45 0c             	mov    0xc(%ebp),%eax
  10081e:	89 10                	mov    %edx,(%eax)
    }

    // Set eip_fn_narg to the number of arguments taken by the function,
    // or 0 if there was no containing function.
    if (lfun < rfun) {
  100820:	8b 55 dc             	mov    -0x24(%ebp),%edx
  100823:	8b 45 d8             	mov    -0x28(%ebp),%eax
  100826:	39 c2                	cmp    %eax,%edx
  100828:	7d 46                	jge    100870 <debuginfo_eip+0x31f>
        for (lline = lfun + 1;
  10082a:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10082d:	40                   	inc    %eax
  10082e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  100831:	eb 16                	jmp    100849 <debuginfo_eip+0x2f8>
             lline < rfun && stabs[lline].n_type == N_PSYM;
             lline ++) {
            info->eip_fn_narg ++;
  100833:	8b 45 0c             	mov    0xc(%ebp),%eax
  100836:	8b 40 14             	mov    0x14(%eax),%eax
  100839:	8d 50 01             	lea    0x1(%eax),%edx
  10083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  10083f:	89 50 14             	mov    %edx,0x14(%eax)
             lline ++) {
  100842:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100845:	40                   	inc    %eax
  100846:	89 45 d4             	mov    %eax,-0x2c(%ebp)
             lline < rfun && stabs[lline].n_type == N_PSYM;
  100849:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10084c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  10084f:	39 c2                	cmp    %eax,%edx
  100851:	7d 1d                	jge    100870 <debuginfo_eip+0x31f>
  100853:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  100856:	89 c2                	mov    %eax,%edx
  100858:	89 d0                	mov    %edx,%eax
  10085a:	01 c0                	add    %eax,%eax
  10085c:	01 d0                	add    %edx,%eax
  10085e:	c1 e0 02             	shl    $0x2,%eax
  100861:	89 c2                	mov    %eax,%edx
  100863:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100866:	01 d0                	add    %edx,%eax
  100868:	0f b6 40 04          	movzbl 0x4(%eax),%eax
  10086c:	3c a0                	cmp    $0xa0,%al
  10086e:	74 c3                	je     100833 <debuginfo_eip+0x2e2>
        }
    }
    return 0;
  100870:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100875:	89 ec                	mov    %ebp,%esp
  100877:	5d                   	pop    %ebp
  100878:	c3                   	ret    

00100879 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void
print_kerninfo(void) {
  100879:	55                   	push   %ebp
  10087a:	89 e5                	mov    %esp,%ebp
  10087c:	83 ec 18             	sub    $0x18,%esp
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
  10087f:	c7 04 24 b6 62 10 00 	movl   $0x1062b6,(%esp)
  100886:	e8 cb fa ff ff       	call   100356 <cprintf>
    cprintf("  entry  0x%08x (phys)\n", kern_init);
  10088b:	c7 44 24 04 36 00 10 	movl   $0x100036,0x4(%esp)
  100892:	00 
  100893:	c7 04 24 cf 62 10 00 	movl   $0x1062cf,(%esp)
  10089a:	e8 b7 fa ff ff       	call   100356 <cprintf>
    cprintf("  etext  0x%08x (phys)\n", etext);
  10089f:	c7 44 24 04 fd 61 10 	movl   $0x1061fd,0x4(%esp)
  1008a6:	00 
  1008a7:	c7 04 24 e7 62 10 00 	movl   $0x1062e7,(%esp)
  1008ae:	e8 a3 fa ff ff       	call   100356 <cprintf>
    cprintf("  edata  0x%08x (phys)\n", edata);
  1008b3:	c7 44 24 04 36 9a 11 	movl   $0x119a36,0x4(%esp)
  1008ba:	00 
  1008bb:	c7 04 24 ff 62 10 00 	movl   $0x1062ff,(%esp)
  1008c2:	e8 8f fa ff ff       	call   100356 <cprintf>
    cprintf("  end    0x%08x (phys)\n", end);
  1008c7:	c7 44 24 04 8c cf 11 	movl   $0x11cf8c,0x4(%esp)
  1008ce:	00 
  1008cf:	c7 04 24 17 63 10 00 	movl   $0x106317,(%esp)
  1008d6:	e8 7b fa ff ff       	call   100356 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n", (end - kern_init + 1023)/1024);
  1008db:	b8 8c cf 11 00       	mov    $0x11cf8c,%eax
  1008e0:	2d 36 00 10 00       	sub    $0x100036,%eax
  1008e5:	05 ff 03 00 00       	add    $0x3ff,%eax
  1008ea:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
  1008f0:	85 c0                	test   %eax,%eax
  1008f2:	0f 48 c2             	cmovs  %edx,%eax
  1008f5:	c1 f8 0a             	sar    $0xa,%eax
  1008f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  1008fc:	c7 04 24 30 63 10 00 	movl   $0x106330,(%esp)
  100903:	e8 4e fa ff ff       	call   100356 <cprintf>
}
  100908:	90                   	nop
  100909:	89 ec                	mov    %ebp,%esp
  10090b:	5d                   	pop    %ebp
  10090c:	c3                   	ret    

0010090d <print_debuginfo>:
/* *
 * print_debuginfo - read and print the stat information for the address @eip,
 * and info.eip_fn_addr should be the first address of the related function.
 * */
void
print_debuginfo(uintptr_t eip) {
  10090d:	55                   	push   %ebp
  10090e:	89 e5                	mov    %esp,%ebp
  100910:	81 ec 48 01 00 00    	sub    $0x148,%esp
    struct eipdebuginfo info;
    if (debuginfo_eip(eip, &info) != 0) {
  100916:	8d 45 dc             	lea    -0x24(%ebp),%eax
  100919:	89 44 24 04          	mov    %eax,0x4(%esp)
  10091d:	8b 45 08             	mov    0x8(%ebp),%eax
  100920:	89 04 24             	mov    %eax,(%esp)
  100923:	e8 29 fc ff ff       	call   100551 <debuginfo_eip>
  100928:	85 c0                	test   %eax,%eax
  10092a:	74 15                	je     100941 <print_debuginfo+0x34>
        cprintf("    <unknow>: -- 0x%08x --\n", eip);
  10092c:	8b 45 08             	mov    0x8(%ebp),%eax
  10092f:	89 44 24 04          	mov    %eax,0x4(%esp)
  100933:	c7 04 24 5a 63 10 00 	movl   $0x10635a,(%esp)
  10093a:	e8 17 fa ff ff       	call   100356 <cprintf>
        }
        fnname[j] = '\0';
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
                fnname, eip - info.eip_fn_addr);
    }
}
  10093f:	eb 6c                	jmp    1009ad <print_debuginfo+0xa0>
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100941:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100948:	eb 1b                	jmp    100965 <print_debuginfo+0x58>
            fnname[j] = info.eip_fn_name[j];
  10094a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  10094d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100950:	01 d0                	add    %edx,%eax
  100952:	0f b6 10             	movzbl (%eax),%edx
  100955:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  10095b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10095e:	01 c8                	add    %ecx,%eax
  100960:	88 10                	mov    %dl,(%eax)
        for (j = 0; j < info.eip_fn_namelen; j ++) {
  100962:	ff 45 f4             	incl   -0xc(%ebp)
  100965:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100968:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  10096b:	7c dd                	jl     10094a <print_debuginfo+0x3d>
        fnname[j] = '\0';
  10096d:	8d 95 dc fe ff ff    	lea    -0x124(%ebp),%edx
  100973:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100976:	01 d0                	add    %edx,%eax
  100978:	c6 00 00             	movb   $0x0,(%eax)
                fnname, eip - info.eip_fn_addr);
  10097b:	8b 55 ec             	mov    -0x14(%ebp),%edx
        cprintf("    %s:%d: %s+%d\n", info.eip_file, info.eip_line,
  10097e:	8b 45 08             	mov    0x8(%ebp),%eax
  100981:	29 d0                	sub    %edx,%eax
  100983:	89 c1                	mov    %eax,%ecx
  100985:	8b 55 e0             	mov    -0x20(%ebp),%edx
  100988:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10098b:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  10098f:	8d 8d dc fe ff ff    	lea    -0x124(%ebp),%ecx
  100995:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100999:	89 54 24 08          	mov    %edx,0x8(%esp)
  10099d:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009a1:	c7 04 24 76 63 10 00 	movl   $0x106376,(%esp)
  1009a8:	e8 a9 f9 ff ff       	call   100356 <cprintf>
}
  1009ad:	90                   	nop
  1009ae:	89 ec                	mov    %ebp,%esp
  1009b0:	5d                   	pop    %ebp
  1009b1:	c3                   	ret    

001009b2 <read_eip>:

static __noinline uint32_t
read_eip(void) {
  1009b2:	55                   	push   %ebp
  1009b3:	89 e5                	mov    %esp,%ebp
  1009b5:	83 ec 10             	sub    $0x10,%esp
    uint32_t eip;
    asm volatile("movl 4(%%ebp), %0" : "=r" (eip));
  1009b8:	8b 45 04             	mov    0x4(%ebp),%eax
  1009bb:	89 45 fc             	mov    %eax,-0x4(%ebp)
    return eip;
  1009be:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  1009c1:	89 ec                	mov    %ebp,%esp
  1009c3:	5d                   	pop    %ebp
  1009c4:	c3                   	ret    

001009c5 <print_stackframe>:
 *
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the boundary.
 * */
void
print_stackframe(void) {
  1009c5:	55                   	push   %ebp
  1009c6:	89 e5                	mov    %esp,%ebp
  1009c8:	83 ec 48             	sub    $0x48,%esp
  1009cb:	89 5d fc             	mov    %ebx,-0x4(%ebp)
}

static inline uint32_t
read_ebp(void) {
    uint32_t ebp;
    asm volatile ("movl %%ebp, %0" : "=r" (ebp));
  1009ce:	89 e8                	mov    %ebp,%eax
  1009d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return ebp;
  1009d3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
      *    (3.5) popup a calling stackframe
      *           NOTICE: the calling funciton's return addr eip  = ss:[ebp+4]
      *                   the calling funciton's ebp = ss:[ebp]
      */
 
    uint32_t ebp=read_ebp();
  1009d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
    uint32_t eip=read_eip();
  1009d9:	e8 d4 ff ff ff       	call   1009b2 <read_eip>
  1009de:	89 45 f0             	mov    %eax,-0x10(%ebp)
    int i;
    for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  1009e1:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  1009e8:	e9 8a 00 00 00       	jmp    100a77 <print_stackframe+0xb2>
          cprintf("ebp:0x%08x   eip:0x%08x ",ebp,eip);
  1009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1009f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  1009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1009f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  1009fb:	c7 04 24 88 63 10 00 	movl   $0x106388,(%esp)
  100a02:	e8 4f f9 ff ff       	call   100356 <cprintf>
          uint32_t *tmp=(uint32_t *)ebp+2;
  100a07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a0a:	83 c0 08             	add    $0x8,%eax
  100a0d:	89 45 e8             	mov    %eax,-0x18(%ebp)
          cprintf("arg :0x%08x 0x%08x 0x%08x 0x%08x",*(tmp+0),*(tmp+1),*(tmp+2),*(tmp+3));
  100a10:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a13:	83 c0 0c             	add    $0xc,%eax
  100a16:	8b 18                	mov    (%eax),%ebx
  100a18:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a1b:	83 c0 08             	add    $0x8,%eax
  100a1e:	8b 08                	mov    (%eax),%ecx
  100a20:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a23:	83 c0 04             	add    $0x4,%eax
  100a26:	8b 10                	mov    (%eax),%edx
  100a28:	8b 45 e8             	mov    -0x18(%ebp),%eax
  100a2b:	8b 00                	mov    (%eax),%eax
  100a2d:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  100a31:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  100a35:	89 54 24 08          	mov    %edx,0x8(%esp)
  100a39:	89 44 24 04          	mov    %eax,0x4(%esp)
  100a3d:	c7 04 24 a4 63 10 00 	movl   $0x1063a4,(%esp)
  100a44:	e8 0d f9 ff ff       	call   100356 <cprintf>
          cprintf("\n");
  100a49:	c7 04 24 c5 63 10 00 	movl   $0x1063c5,(%esp)
  100a50:	e8 01 f9 ff ff       	call   100356 <cprintf>
          print_debuginfo(eip-1);
  100a55:	8b 45 f0             	mov    -0x10(%ebp),%eax
  100a58:	48                   	dec    %eax
  100a59:	89 04 24             	mov    %eax,(%esp)
  100a5c:	e8 ac fe ff ff       	call   10090d <print_debuginfo>
          eip=((uint32_t *)ebp)[1];
  100a61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a64:	83 c0 04             	add    $0x4,%eax
  100a67:	8b 00                	mov    (%eax),%eax
  100a69:	89 45 f0             	mov    %eax,-0x10(%ebp)
          ebp=((uint32_t *)ebp)[0];
  100a6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100a6f:	8b 00                	mov    (%eax),%eax
  100a71:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for(i=0;i<STACKFRAME_DEPTH&&ebp!=0;i++){
  100a74:	ff 45 ec             	incl   -0x14(%ebp)
  100a77:	83 7d ec 13          	cmpl   $0x13,-0x14(%ebp)
  100a7b:	7f 0a                	jg     100a87 <print_stackframe+0xc2>
  100a7d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100a81:	0f 85 66 ff ff ff    	jne    1009ed <print_stackframe+0x28>
    }

}
  100a87:	90                   	nop
  100a88:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100a8b:	89 ec                	mov    %ebp,%esp
  100a8d:	5d                   	pop    %ebp
  100a8e:	c3                   	ret    

00100a8f <parse>:
#define MAXARGS         16
#define WHITESPACE      " \t\n\r"

/* parse - parse the command buffer into whitespace-separated arguments */
static int
parse(char *buf, char **argv) {
  100a8f:	55                   	push   %ebp
  100a90:	89 e5                	mov    %esp,%ebp
  100a92:	83 ec 28             	sub    $0x28,%esp
    int argc = 0;
  100a95:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while (1) {
        // find global whitespace
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100a9c:	eb 0c                	jmp    100aaa <parse+0x1b>
            *buf ++ = '\0';
  100a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  100aa1:	8d 50 01             	lea    0x1(%eax),%edx
  100aa4:	89 55 08             	mov    %edx,0x8(%ebp)
  100aa7:	c6 00 00             	movb   $0x0,(%eax)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100aaa:	8b 45 08             	mov    0x8(%ebp),%eax
  100aad:	0f b6 00             	movzbl (%eax),%eax
  100ab0:	84 c0                	test   %al,%al
  100ab2:	74 1d                	je     100ad1 <parse+0x42>
  100ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  100ab7:	0f b6 00             	movzbl (%eax),%eax
  100aba:	0f be c0             	movsbl %al,%eax
  100abd:	89 44 24 04          	mov    %eax,0x4(%esp)
  100ac1:	c7 04 24 48 64 10 00 	movl   $0x106448,(%esp)
  100ac8:	e8 e8 53 00 00       	call   105eb5 <strchr>
  100acd:	85 c0                	test   %eax,%eax
  100acf:	75 cd                	jne    100a9e <parse+0xf>
        }
        if (*buf == '\0') {
  100ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  100ad4:	0f b6 00             	movzbl (%eax),%eax
  100ad7:	84 c0                	test   %al,%al
  100ad9:	74 65                	je     100b40 <parse+0xb1>
            break;
        }

        // save and scan past next arg
        if (argc == MAXARGS - 1) {
  100adb:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
  100adf:	75 14                	jne    100af5 <parse+0x66>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
  100ae1:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
  100ae8:	00 
  100ae9:	c7 04 24 4d 64 10 00 	movl   $0x10644d,(%esp)
  100af0:	e8 61 f8 ff ff       	call   100356 <cprintf>
        }
        argv[argc ++] = buf;
  100af5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100af8:	8d 50 01             	lea    0x1(%eax),%edx
  100afb:	89 55 f4             	mov    %edx,-0xc(%ebp)
  100afe:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  100b05:	8b 45 0c             	mov    0xc(%ebp),%eax
  100b08:	01 c2                	add    %eax,%edx
  100b0a:	8b 45 08             	mov    0x8(%ebp),%eax
  100b0d:	89 02                	mov    %eax,(%edx)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b0f:	eb 03                	jmp    100b14 <parse+0x85>
            buf ++;
  100b11:	ff 45 08             	incl   0x8(%ebp)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
  100b14:	8b 45 08             	mov    0x8(%ebp),%eax
  100b17:	0f b6 00             	movzbl (%eax),%eax
  100b1a:	84 c0                	test   %al,%al
  100b1c:	74 8c                	je     100aaa <parse+0x1b>
  100b1e:	8b 45 08             	mov    0x8(%ebp),%eax
  100b21:	0f b6 00             	movzbl (%eax),%eax
  100b24:	0f be c0             	movsbl %al,%eax
  100b27:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b2b:	c7 04 24 48 64 10 00 	movl   $0x106448,(%esp)
  100b32:	e8 7e 53 00 00       	call   105eb5 <strchr>
  100b37:	85 c0                	test   %eax,%eax
  100b39:	74 d6                	je     100b11 <parse+0x82>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
  100b3b:	e9 6a ff ff ff       	jmp    100aaa <parse+0x1b>
            break;
  100b40:	90                   	nop
        }
    }
    return argc;
  100b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  100b44:	89 ec                	mov    %ebp,%esp
  100b46:	5d                   	pop    %ebp
  100b47:	c3                   	ret    

00100b48 <runcmd>:
/* *
 * runcmd - parse the input string, split it into separated arguments
 * and then lookup and invoke some related commands/
 * */
static int
runcmd(char *buf, struct trapframe *tf) {
  100b48:	55                   	push   %ebp
  100b49:	89 e5                	mov    %esp,%ebp
  100b4b:	83 ec 68             	sub    $0x68,%esp
  100b4e:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char *argv[MAXARGS];
    int argc = parse(buf, argv);
  100b51:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  100b58:	8b 45 08             	mov    0x8(%ebp),%eax
  100b5b:	89 04 24             	mov    %eax,(%esp)
  100b5e:	e8 2c ff ff ff       	call   100a8f <parse>
  100b63:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if (argc == 0) {
  100b66:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  100b6a:	75 0a                	jne    100b76 <runcmd+0x2e>
        return 0;
  100b6c:	b8 00 00 00 00       	mov    $0x0,%eax
  100b71:	e9 83 00 00 00       	jmp    100bf9 <runcmd+0xb1>
    }
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100b76:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100b7d:	eb 5a                	jmp    100bd9 <runcmd+0x91>
        if (strcmp(commands[i].name, argv[0]) == 0) {
  100b7f:	8b 55 b0             	mov    -0x50(%ebp),%edx
  100b82:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100b85:	89 c8                	mov    %ecx,%eax
  100b87:	01 c0                	add    %eax,%eax
  100b89:	01 c8                	add    %ecx,%eax
  100b8b:	c1 e0 02             	shl    $0x2,%eax
  100b8e:	05 00 90 11 00       	add    $0x119000,%eax
  100b93:	8b 00                	mov    (%eax),%eax
  100b95:	89 54 24 04          	mov    %edx,0x4(%esp)
  100b99:	89 04 24             	mov    %eax,(%esp)
  100b9c:	e8 78 52 00 00       	call   105e19 <strcmp>
  100ba1:	85 c0                	test   %eax,%eax
  100ba3:	75 31                	jne    100bd6 <runcmd+0x8e>
            return commands[i].func(argc - 1, argv + 1, tf);
  100ba5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100ba8:	89 d0                	mov    %edx,%eax
  100baa:	01 c0                	add    %eax,%eax
  100bac:	01 d0                	add    %edx,%eax
  100bae:	c1 e0 02             	shl    $0x2,%eax
  100bb1:	05 08 90 11 00       	add    $0x119008,%eax
  100bb6:	8b 10                	mov    (%eax),%edx
  100bb8:	8d 45 b0             	lea    -0x50(%ebp),%eax
  100bbb:	83 c0 04             	add    $0x4,%eax
  100bbe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  100bc1:	8d 59 ff             	lea    -0x1(%ecx),%ebx
  100bc4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  100bc7:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  100bcb:	89 44 24 04          	mov    %eax,0x4(%esp)
  100bcf:	89 1c 24             	mov    %ebx,(%esp)
  100bd2:	ff d2                	call   *%edx
  100bd4:	eb 23                	jmp    100bf9 <runcmd+0xb1>
    for (i = 0; i < NCOMMANDS; i ++) {
  100bd6:	ff 45 f4             	incl   -0xc(%ebp)
  100bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100bdc:	83 f8 02             	cmp    $0x2,%eax
  100bdf:	76 9e                	jbe    100b7f <runcmd+0x37>
        }
    }
    cprintf("Unknown command '%s'\n", argv[0]);
  100be1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  100be4:	89 44 24 04          	mov    %eax,0x4(%esp)
  100be8:	c7 04 24 6b 64 10 00 	movl   $0x10646b,(%esp)
  100bef:	e8 62 f7 ff ff       	call   100356 <cprintf>
    return 0;
  100bf4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100bf9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  100bfc:	89 ec                	mov    %ebp,%esp
  100bfe:	5d                   	pop    %ebp
  100bff:	c3                   	ret    

00100c00 <kmonitor>:

/***** Implementations of basic kernel monitor commands *****/

void
kmonitor(struct trapframe *tf) {
  100c00:	55                   	push   %ebp
  100c01:	89 e5                	mov    %esp,%ebp
  100c03:	83 ec 28             	sub    $0x28,%esp
    cprintf("Welcome to the kernel debug monitor!!\n");
  100c06:	c7 04 24 84 64 10 00 	movl   $0x106484,(%esp)
  100c0d:	e8 44 f7 ff ff       	call   100356 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
  100c12:	c7 04 24 ac 64 10 00 	movl   $0x1064ac,(%esp)
  100c19:	e8 38 f7 ff ff       	call   100356 <cprintf>

    if (tf != NULL) {
  100c1e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100c22:	74 0b                	je     100c2f <kmonitor+0x2f>
        print_trapframe(tf);
  100c24:	8b 45 08             	mov    0x8(%ebp),%eax
  100c27:	89 04 24             	mov    %eax,(%esp)
  100c2a:	e8 f2 0e 00 00       	call   101b21 <print_trapframe>
    }

    char *buf;
    while (1) {
        if ((buf = readline("K> ")) != NULL) {
  100c2f:	c7 04 24 d1 64 10 00 	movl   $0x1064d1,(%esp)
  100c36:	e8 0c f6 ff ff       	call   100247 <readline>
  100c3b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  100c3e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  100c42:	74 eb                	je     100c2f <kmonitor+0x2f>
            if (runcmd(buf, tf) < 0) {
  100c44:	8b 45 08             	mov    0x8(%ebp),%eax
  100c47:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100c4e:	89 04 24             	mov    %eax,(%esp)
  100c51:	e8 f2 fe ff ff       	call   100b48 <runcmd>
  100c56:	85 c0                	test   %eax,%eax
  100c58:	78 02                	js     100c5c <kmonitor+0x5c>
        if ((buf = readline("K> ")) != NULL) {
  100c5a:	eb d3                	jmp    100c2f <kmonitor+0x2f>
                break;
  100c5c:	90                   	nop
            }
        }
    }
}
  100c5d:	90                   	nop
  100c5e:	89 ec                	mov    %ebp,%esp
  100c60:	5d                   	pop    %ebp
  100c61:	c3                   	ret    

00100c62 <mon_help>:

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
  100c62:	55                   	push   %ebp
  100c63:	89 e5                	mov    %esp,%ebp
  100c65:	83 ec 28             	sub    $0x28,%esp
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
  100c68:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  100c6f:	eb 3d                	jmp    100cae <mon_help+0x4c>
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
  100c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  100c74:	89 d0                	mov    %edx,%eax
  100c76:	01 c0                	add    %eax,%eax
  100c78:	01 d0                	add    %edx,%eax
  100c7a:	c1 e0 02             	shl    $0x2,%eax
  100c7d:	05 04 90 11 00       	add    $0x119004,%eax
  100c82:	8b 10                	mov    (%eax),%edx
  100c84:	8b 4d f4             	mov    -0xc(%ebp),%ecx
  100c87:	89 c8                	mov    %ecx,%eax
  100c89:	01 c0                	add    %eax,%eax
  100c8b:	01 c8                	add    %ecx,%eax
  100c8d:	c1 e0 02             	shl    $0x2,%eax
  100c90:	05 00 90 11 00       	add    $0x119000,%eax
  100c95:	8b 00                	mov    (%eax),%eax
  100c97:	89 54 24 08          	mov    %edx,0x8(%esp)
  100c9b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100c9f:	c7 04 24 d5 64 10 00 	movl   $0x1064d5,(%esp)
  100ca6:	e8 ab f6 ff ff       	call   100356 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
  100cab:	ff 45 f4             	incl   -0xc(%ebp)
  100cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100cb1:	83 f8 02             	cmp    $0x2,%eax
  100cb4:	76 bb                	jbe    100c71 <mon_help+0xf>
    }
    return 0;
  100cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100cbb:	89 ec                	mov    %ebp,%esp
  100cbd:	5d                   	pop    %ebp
  100cbe:	c3                   	ret    

00100cbf <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
  100cbf:	55                   	push   %ebp
  100cc0:	89 e5                	mov    %esp,%ebp
  100cc2:	83 ec 08             	sub    $0x8,%esp
    print_kerninfo();
  100cc5:	e8 af fb ff ff       	call   100879 <print_kerninfo>
    return 0;
  100cca:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ccf:	89 ec                	mov    %ebp,%esp
  100cd1:	5d                   	pop    %ebp
  100cd2:	c3                   	ret    

00100cd3 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
  100cd3:	55                   	push   %ebp
  100cd4:	89 e5                	mov    %esp,%ebp
  100cd6:	83 ec 08             	sub    $0x8,%esp
    print_stackframe();
  100cd9:	e8 e7 fc ff ff       	call   1009c5 <print_stackframe>
    return 0;
  100cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100ce3:	89 ec                	mov    %ebp,%esp
  100ce5:	5d                   	pop    %ebp
  100ce6:	c3                   	ret    

00100ce7 <__panic>:
/* *
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
  100ce7:	55                   	push   %ebp
  100ce8:	89 e5                	mov    %esp,%ebp
  100cea:	83 ec 28             	sub    $0x28,%esp
    if (is_panic) {
  100ced:	a1 20 c4 11 00       	mov    0x11c420,%eax
  100cf2:	85 c0                	test   %eax,%eax
  100cf4:	75 5b                	jne    100d51 <__panic+0x6a>
        goto panic_dead;
    }
    is_panic = 1;
  100cf6:	c7 05 20 c4 11 00 01 	movl   $0x1,0x11c420
  100cfd:	00 00 00 

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  100d00:	8d 45 14             	lea    0x14(%ebp),%eax
  100d03:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
  100d06:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d09:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d0d:	8b 45 08             	mov    0x8(%ebp),%eax
  100d10:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d14:	c7 04 24 de 64 10 00 	movl   $0x1064de,(%esp)
  100d1b:	e8 36 f6 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d20:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d23:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d27:	8b 45 10             	mov    0x10(%ebp),%eax
  100d2a:	89 04 24             	mov    %eax,(%esp)
  100d2d:	e8 ef f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d32:	c7 04 24 fa 64 10 00 	movl   $0x1064fa,(%esp)
  100d39:	e8 18 f6 ff ff       	call   100356 <cprintf>
    
    cprintf("stack trackback:\n");
  100d3e:	c7 04 24 fc 64 10 00 	movl   $0x1064fc,(%esp)
  100d45:	e8 0c f6 ff ff       	call   100356 <cprintf>
    print_stackframe();
  100d4a:	e8 76 fc ff ff       	call   1009c5 <print_stackframe>
  100d4f:	eb 01                	jmp    100d52 <__panic+0x6b>
        goto panic_dead;
  100d51:	90                   	nop
    
    va_end(ap);

panic_dead:
    intr_disable();
  100d52:	e8 e9 09 00 00       	call   101740 <intr_disable>
    while (1) {
        kmonitor(NULL);
  100d57:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100d5e:	e8 9d fe ff ff       	call   100c00 <kmonitor>
  100d63:	eb f2                	jmp    100d57 <__panic+0x70>

00100d65 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
  100d65:	55                   	push   %ebp
  100d66:	89 e5                	mov    %esp,%ebp
  100d68:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    va_start(ap, fmt);
  100d6b:	8d 45 14             	lea    0x14(%ebp),%eax
  100d6e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
  100d71:	8b 45 0c             	mov    0xc(%ebp),%eax
  100d74:	89 44 24 08          	mov    %eax,0x8(%esp)
  100d78:	8b 45 08             	mov    0x8(%ebp),%eax
  100d7b:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d7f:	c7 04 24 0e 65 10 00 	movl   $0x10650e,(%esp)
  100d86:	e8 cb f5 ff ff       	call   100356 <cprintf>
    vcprintf(fmt, ap);
  100d8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100d8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  100d92:	8b 45 10             	mov    0x10(%ebp),%eax
  100d95:	89 04 24             	mov    %eax,(%esp)
  100d98:	e8 84 f5 ff ff       	call   100321 <vcprintf>
    cprintf("\n");
  100d9d:	c7 04 24 fa 64 10 00 	movl   $0x1064fa,(%esp)
  100da4:	e8 ad f5 ff ff       	call   100356 <cprintf>
    va_end(ap);
}
  100da9:	90                   	nop
  100daa:	89 ec                	mov    %ebp,%esp
  100dac:	5d                   	pop    %ebp
  100dad:	c3                   	ret    

00100dae <is_kernel_panic>:

bool
is_kernel_panic(void) {
  100dae:	55                   	push   %ebp
  100daf:	89 e5                	mov    %esp,%ebp
    return is_panic;
  100db1:	a1 20 c4 11 00       	mov    0x11c420,%eax
}
  100db6:	5d                   	pop    %ebp
  100db7:	c3                   	ret    

00100db8 <clock_init>:
/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void
clock_init(void) {
  100db8:	55                   	push   %ebp
  100db9:	89 e5                	mov    %esp,%ebp
  100dbb:	83 ec 28             	sub    $0x28,%esp
  100dbe:	66 c7 45 ee 43 00    	movw   $0x43,-0x12(%ebp)
  100dc4:	c6 45 ed 34          	movb   $0x34,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100dc8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100dcc:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100dd0:	ee                   	out    %al,(%dx)
}
  100dd1:	90                   	nop
  100dd2:	66 c7 45 f2 40 00    	movw   $0x40,-0xe(%ebp)
  100dd8:	c6 45 f1 9c          	movb   $0x9c,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ddc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100de0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  100de4:	ee                   	out    %al,(%dx)
}
  100de5:	90                   	nop
  100de6:	66 c7 45 f6 40 00    	movw   $0x40,-0xa(%ebp)
  100dec:	c6 45 f5 2e          	movb   $0x2e,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100df0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  100df4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  100df8:	ee                   	out    %al,(%dx)
}
  100df9:	90                   	nop
    outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
    outb(IO_TIMER1, TIMER_DIV(100) % 256);
    outb(IO_TIMER1, TIMER_DIV(100) / 256);

    // initialize time counter 'ticks' to zero
    ticks = 0;
  100dfa:	c7 05 24 c4 11 00 00 	movl   $0x0,0x11c424
  100e01:	00 00 00 

    cprintf("++ setup timer interrupts\n");
  100e04:	c7 04 24 2c 65 10 00 	movl   $0x10652c,(%esp)
  100e0b:	e8 46 f5 ff ff       	call   100356 <cprintf>
    pic_enable(IRQ_TIMER);
  100e10:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  100e17:	e8 89 09 00 00       	call   1017a5 <pic_enable>
}
  100e1c:	90                   	nop
  100e1d:	89 ec                	mov    %ebp,%esp
  100e1f:	5d                   	pop    %ebp
  100e20:	c3                   	ret    

00100e21 <__intr_save>:
#include <x86.h>
#include <intr.h>
#include <mmu.h>

static inline bool
__intr_save(void) {
  100e21:	55                   	push   %ebp
  100e22:	89 e5                	mov    %esp,%ebp
  100e24:	83 ec 18             	sub    $0x18,%esp
}

static inline uint32_t
read_eflags(void) {
    uint32_t eflags;
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  100e27:	9c                   	pushf  
  100e28:	58                   	pop    %eax
  100e29:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  100e2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  100e2f:	25 00 02 00 00       	and    $0x200,%eax
  100e34:	85 c0                	test   %eax,%eax
  100e36:	74 0c                	je     100e44 <__intr_save+0x23>
        intr_disable();
  100e38:	e8 03 09 00 00       	call   101740 <intr_disable>
        return 1;
  100e3d:	b8 01 00 00 00       	mov    $0x1,%eax
  100e42:	eb 05                	jmp    100e49 <__intr_save+0x28>
    }
    return 0;
  100e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  100e49:	89 ec                	mov    %ebp,%esp
  100e4b:	5d                   	pop    %ebp
  100e4c:	c3                   	ret    

00100e4d <__intr_restore>:

static inline void
__intr_restore(bool flag) {
  100e4d:	55                   	push   %ebp
  100e4e:	89 e5                	mov    %esp,%ebp
  100e50:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  100e53:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  100e57:	74 05                	je     100e5e <__intr_restore+0x11>
        intr_enable();
  100e59:	e8 da 08 00 00       	call   101738 <intr_enable>
    }
}
  100e5e:	90                   	nop
  100e5f:	89 ec                	mov    %ebp,%esp
  100e61:	5d                   	pop    %ebp
  100e62:	c3                   	ret    

00100e63 <delay>:
#include <memlayout.h>
#include <sync.h>

/* stupid I/O delay routine necessitated by historical PC design flaws */
static void
delay(void) {
  100e63:	55                   	push   %ebp
  100e64:	89 e5                	mov    %esp,%ebp
  100e66:	83 ec 10             	sub    $0x10,%esp
  100e69:	66 c7 45 f2 84 00    	movw   $0x84,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100e6f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100e73:	89 c2                	mov    %eax,%edx
  100e75:	ec                   	in     (%dx),%al
  100e76:	88 45 f1             	mov    %al,-0xf(%ebp)
  100e79:	66 c7 45 f6 84 00    	movw   $0x84,-0xa(%ebp)
  100e7f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  100e83:	89 c2                	mov    %eax,%edx
  100e85:	ec                   	in     (%dx),%al
  100e86:	88 45 f5             	mov    %al,-0xb(%ebp)
  100e89:	66 c7 45 fa 84 00    	movw   $0x84,-0x6(%ebp)
  100e8f:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  100e93:	89 c2                	mov    %eax,%edx
  100e95:	ec                   	in     (%dx),%al
  100e96:	88 45 f9             	mov    %al,-0x7(%ebp)
  100e99:	66 c7 45 fe 84 00    	movw   $0x84,-0x2(%ebp)
  100e9f:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  100ea3:	89 c2                	mov    %eax,%edx
  100ea5:	ec                   	in     (%dx),%al
  100ea6:	88 45 fd             	mov    %al,-0x3(%ebp)
    inb(0x84);
    inb(0x84);
    inb(0x84);
    inb(0x84);
}
  100ea9:	90                   	nop
  100eaa:	89 ec                	mov    %ebp,%esp
  100eac:	5d                   	pop    %ebp
  100ead:	c3                   	ret    

00100eae <cga_init>:
static uint16_t addr_6845;

/* TEXT-mode CGA/VGA display output */

static void
cga_init(void) {
  100eae:	55                   	push   %ebp
  100eaf:	89 e5                	mov    %esp,%ebp
  100eb1:	83 ec 20             	sub    $0x20,%esp
    volatile uint16_t *cp = (uint16_t *)(CGA_BUF + KERNBASE);
  100eb4:	c7 45 fc 00 80 0b c0 	movl   $0xc00b8000,-0x4(%ebp)
    uint16_t was = *cp;
  100ebb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ebe:	0f b7 00             	movzwl (%eax),%eax
  100ec1:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
    *cp = (uint16_t) 0xA55A;
  100ec5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ec8:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
    if (*cp != 0xA55A) {
  100ecd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ed0:	0f b7 00             	movzwl (%eax),%eax
  100ed3:	0f b7 c0             	movzwl %ax,%eax
  100ed6:	3d 5a a5 00 00       	cmp    $0xa55a,%eax
  100edb:	74 12                	je     100eef <cga_init+0x41>
        cp = (uint16_t*)(MONO_BUF + KERNBASE);
  100edd:	c7 45 fc 00 00 0b c0 	movl   $0xc00b0000,-0x4(%ebp)
        addr_6845 = MONO_BASE;
  100ee4:	66 c7 05 46 c4 11 00 	movw   $0x3b4,0x11c446
  100eeb:	b4 03 
  100eed:	eb 13                	jmp    100f02 <cga_init+0x54>
    } else {
        *cp = was;
  100eef:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100ef2:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  100ef6:	66 89 10             	mov    %dx,(%eax)
        addr_6845 = CGA_BASE;
  100ef9:	66 c7 05 46 c4 11 00 	movw   $0x3d4,0x11c446
  100f00:	d4 03 
    }

    // Extract cursor location
    uint32_t pos;
    outb(addr_6845, 14);
  100f02:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f09:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  100f0d:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f11:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  100f15:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  100f19:	ee                   	out    %al,(%dx)
}
  100f1a:	90                   	nop
    pos = inb(addr_6845 + 1) << 8;
  100f1b:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f22:	40                   	inc    %eax
  100f23:	0f b7 c0             	movzwl %ax,%eax
  100f26:	66 89 45 ea          	mov    %ax,-0x16(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f2a:	0f b7 45 ea          	movzwl -0x16(%ebp),%eax
  100f2e:	89 c2                	mov    %eax,%edx
  100f30:	ec                   	in     (%dx),%al
  100f31:	88 45 e9             	mov    %al,-0x17(%ebp)
    return data;
  100f34:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  100f38:	0f b6 c0             	movzbl %al,%eax
  100f3b:	c1 e0 08             	shl    $0x8,%eax
  100f3e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    outb(addr_6845, 15);
  100f41:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f48:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  100f4c:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100f50:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  100f54:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  100f58:	ee                   	out    %al,(%dx)
}
  100f59:	90                   	nop
    pos |= inb(addr_6845 + 1);
  100f5a:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  100f61:	40                   	inc    %eax
  100f62:	0f b7 c0             	movzwl %ax,%eax
  100f65:	66 89 45 f2          	mov    %ax,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  100f69:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  100f6d:	89 c2                	mov    %eax,%edx
  100f6f:	ec                   	in     (%dx),%al
  100f70:	88 45 f1             	mov    %al,-0xf(%ebp)
    return data;
  100f73:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  100f77:	0f b6 c0             	movzbl %al,%eax
  100f7a:	09 45 f4             	or     %eax,-0xc(%ebp)

    crt_buf = (uint16_t*) cp;
  100f7d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  100f80:	a3 40 c4 11 00       	mov    %eax,0x11c440
    crt_pos = pos;
  100f85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  100f88:	0f b7 c0             	movzwl %ax,%eax
  100f8b:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
}
  100f91:	90                   	nop
  100f92:	89 ec                	mov    %ebp,%esp
  100f94:	5d                   	pop    %ebp
  100f95:	c3                   	ret    

00100f96 <serial_init>:

static bool serial_exists = 0;

static void
serial_init(void) {
  100f96:	55                   	push   %ebp
  100f97:	89 e5                	mov    %esp,%ebp
  100f99:	83 ec 48             	sub    $0x48,%esp
  100f9c:	66 c7 45 d2 fa 03    	movw   $0x3fa,-0x2e(%ebp)
  100fa2:	c6 45 d1 00          	movb   $0x0,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fa6:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  100faa:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  100fae:	ee                   	out    %al,(%dx)
}
  100faf:	90                   	nop
  100fb0:	66 c7 45 d6 fb 03    	movw   $0x3fb,-0x2a(%ebp)
  100fb6:	c6 45 d5 80          	movb   $0x80,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fba:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  100fbe:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  100fc2:	ee                   	out    %al,(%dx)
}
  100fc3:	90                   	nop
  100fc4:	66 c7 45 da f8 03    	movw   $0x3f8,-0x26(%ebp)
  100fca:	c6 45 d9 0c          	movb   $0xc,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fce:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  100fd2:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  100fd6:	ee                   	out    %al,(%dx)
}
  100fd7:	90                   	nop
  100fd8:	66 c7 45 de f9 03    	movw   $0x3f9,-0x22(%ebp)
  100fde:	c6 45 dd 00          	movb   $0x0,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100fe2:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  100fe6:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  100fea:	ee                   	out    %al,(%dx)
}
  100feb:	90                   	nop
  100fec:	66 c7 45 e2 fb 03    	movw   $0x3fb,-0x1e(%ebp)
  100ff2:	c6 45 e1 03          	movb   $0x3,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  100ff6:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  100ffa:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  100ffe:	ee                   	out    %al,(%dx)
}
  100fff:	90                   	nop
  101000:	66 c7 45 e6 fc 03    	movw   $0x3fc,-0x1a(%ebp)
  101006:	c6 45 e5 00          	movb   $0x0,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10100a:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  10100e:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101012:	ee                   	out    %al,(%dx)
}
  101013:	90                   	nop
  101014:	66 c7 45 ea f9 03    	movw   $0x3f9,-0x16(%ebp)
  10101a:	c6 45 e9 01          	movb   $0x1,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10101e:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101022:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  101026:	ee                   	out    %al,(%dx)
}
  101027:	90                   	nop
  101028:	66 c7 45 ee fd 03    	movw   $0x3fd,-0x12(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10102e:	0f b7 45 ee          	movzwl -0x12(%ebp),%eax
  101032:	89 c2                	mov    %eax,%edx
  101034:	ec                   	in     (%dx),%al
  101035:	88 45 ed             	mov    %al,-0x13(%ebp)
    return data;
  101038:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
    // Enable rcv interrupts
    outb(COM1 + COM_IER, COM_IER_RDI);

    // Clear any preexisting overrun indications and interrupts
    // Serial port doesn't exist if COM_LSR returns 0xFF
    serial_exists = (inb(COM1 + COM_LSR) != 0xFF);
  10103c:	3c ff                	cmp    $0xff,%al
  10103e:	0f 95 c0             	setne  %al
  101041:	0f b6 c0             	movzbl %al,%eax
  101044:	a3 48 c4 11 00       	mov    %eax,0x11c448
  101049:	66 c7 45 f2 fa 03    	movw   $0x3fa,-0xe(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  10104f:	0f b7 45 f2          	movzwl -0xe(%ebp),%eax
  101053:	89 c2                	mov    %eax,%edx
  101055:	ec                   	in     (%dx),%al
  101056:	88 45 f1             	mov    %al,-0xf(%ebp)
  101059:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  10105f:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  101063:	89 c2                	mov    %eax,%edx
  101065:	ec                   	in     (%dx),%al
  101066:	88 45 f5             	mov    %al,-0xb(%ebp)
    (void) inb(COM1+COM_IIR);
    (void) inb(COM1+COM_RX);

    if (serial_exists) {
  101069:	a1 48 c4 11 00       	mov    0x11c448,%eax
  10106e:	85 c0                	test   %eax,%eax
  101070:	74 0c                	je     10107e <serial_init+0xe8>
        pic_enable(IRQ_COM1);
  101072:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  101079:	e8 27 07 00 00       	call   1017a5 <pic_enable>
    }
}
  10107e:	90                   	nop
  10107f:	89 ec                	mov    %ebp,%esp
  101081:	5d                   	pop    %ebp
  101082:	c3                   	ret    

00101083 <lpt_putc_sub>:

static void
lpt_putc_sub(int c) {
  101083:	55                   	push   %ebp
  101084:	89 e5                	mov    %esp,%ebp
  101086:	83 ec 20             	sub    $0x20,%esp
    int i;
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101089:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101090:	eb 08                	jmp    10109a <lpt_putc_sub+0x17>
        delay();
  101092:	e8 cc fd ff ff       	call   100e63 <delay>
    for (i = 0; !(inb(LPTPORT + 1) & 0x80) && i < 12800; i ++) {
  101097:	ff 45 fc             	incl   -0x4(%ebp)
  10109a:	66 c7 45 fa 79 03    	movw   $0x379,-0x6(%ebp)
  1010a0:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  1010a4:	89 c2                	mov    %eax,%edx
  1010a6:	ec                   	in     (%dx),%al
  1010a7:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  1010aa:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1010ae:	84 c0                	test   %al,%al
  1010b0:	78 09                	js     1010bb <lpt_putc_sub+0x38>
  1010b2:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  1010b9:	7e d7                	jle    101092 <lpt_putc_sub+0xf>
    }
    outb(LPTPORT + 0, c);
  1010bb:	8b 45 08             	mov    0x8(%ebp),%eax
  1010be:	0f b6 c0             	movzbl %al,%eax
  1010c1:	66 c7 45 ee 78 03    	movw   $0x378,-0x12(%ebp)
  1010c7:	88 45 ed             	mov    %al,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010ca:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1010ce:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1010d2:	ee                   	out    %al,(%dx)
}
  1010d3:	90                   	nop
  1010d4:	66 c7 45 f2 7a 03    	movw   $0x37a,-0xe(%ebp)
  1010da:	c6 45 f1 0d          	movb   $0xd,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010de:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1010e2:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1010e6:	ee                   	out    %al,(%dx)
}
  1010e7:	90                   	nop
  1010e8:	66 c7 45 f6 7a 03    	movw   $0x37a,-0xa(%ebp)
  1010ee:	c6 45 f5 08          	movb   $0x8,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1010f2:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1010f6:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1010fa:	ee                   	out    %al,(%dx)
}
  1010fb:	90                   	nop
    outb(LPTPORT + 2, 0x08 | 0x04 | 0x01);
    outb(LPTPORT + 2, 0x08);
}
  1010fc:	90                   	nop
  1010fd:	89 ec                	mov    %ebp,%esp
  1010ff:	5d                   	pop    %ebp
  101100:	c3                   	ret    

00101101 <lpt_putc>:

/* lpt_putc - copy console output to parallel port */
static void
lpt_putc(int c) {
  101101:	55                   	push   %ebp
  101102:	89 e5                	mov    %esp,%ebp
  101104:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  101107:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10110b:	74 0d                	je     10111a <lpt_putc+0x19>
        lpt_putc_sub(c);
  10110d:	8b 45 08             	mov    0x8(%ebp),%eax
  101110:	89 04 24             	mov    %eax,(%esp)
  101113:	e8 6b ff ff ff       	call   101083 <lpt_putc_sub>
    else {
        lpt_putc_sub('\b');
        lpt_putc_sub(' ');
        lpt_putc_sub('\b');
    }
}
  101118:	eb 24                	jmp    10113e <lpt_putc+0x3d>
        lpt_putc_sub('\b');
  10111a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101121:	e8 5d ff ff ff       	call   101083 <lpt_putc_sub>
        lpt_putc_sub(' ');
  101126:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  10112d:	e8 51 ff ff ff       	call   101083 <lpt_putc_sub>
        lpt_putc_sub('\b');
  101132:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  101139:	e8 45 ff ff ff       	call   101083 <lpt_putc_sub>
}
  10113e:	90                   	nop
  10113f:	89 ec                	mov    %ebp,%esp
  101141:	5d                   	pop    %ebp
  101142:	c3                   	ret    

00101143 <cga_putc>:

/* cga_putc - print character to console */
static void
cga_putc(int c) {
  101143:	55                   	push   %ebp
  101144:	89 e5                	mov    %esp,%ebp
  101146:	83 ec 38             	sub    $0x38,%esp
  101149:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    // set black on white
    if (!(c & ~0xFF)) {
  10114c:	8b 45 08             	mov    0x8(%ebp),%eax
  10114f:	25 00 ff ff ff       	and    $0xffffff00,%eax
  101154:	85 c0                	test   %eax,%eax
  101156:	75 07                	jne    10115f <cga_putc+0x1c>
        c |= 0x0700;
  101158:	81 4d 08 00 07 00 00 	orl    $0x700,0x8(%ebp)
    }

    switch (c & 0xff) {
  10115f:	8b 45 08             	mov    0x8(%ebp),%eax
  101162:	0f b6 c0             	movzbl %al,%eax
  101165:	83 f8 0d             	cmp    $0xd,%eax
  101168:	74 72                	je     1011dc <cga_putc+0x99>
  10116a:	83 f8 0d             	cmp    $0xd,%eax
  10116d:	0f 8f a3 00 00 00    	jg     101216 <cga_putc+0xd3>
  101173:	83 f8 08             	cmp    $0x8,%eax
  101176:	74 0a                	je     101182 <cga_putc+0x3f>
  101178:	83 f8 0a             	cmp    $0xa,%eax
  10117b:	74 4c                	je     1011c9 <cga_putc+0x86>
  10117d:	e9 94 00 00 00       	jmp    101216 <cga_putc+0xd3>
    case '\b':
        if (crt_pos > 0) {
  101182:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101189:	85 c0                	test   %eax,%eax
  10118b:	0f 84 af 00 00 00    	je     101240 <cga_putc+0xfd>
            crt_pos --;
  101191:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101198:	48                   	dec    %eax
  101199:	0f b7 c0             	movzwl %ax,%eax
  10119c:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
            crt_buf[crt_pos] = (c & ~0xff) | ' ';
  1011a2:	8b 45 08             	mov    0x8(%ebp),%eax
  1011a5:	98                   	cwtl   
  1011a6:	25 00 ff ff ff       	and    $0xffffff00,%eax
  1011ab:	98                   	cwtl   
  1011ac:	83 c8 20             	or     $0x20,%eax
  1011af:	98                   	cwtl   
  1011b0:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  1011b6:	0f b7 15 44 c4 11 00 	movzwl 0x11c444,%edx
  1011bd:	01 d2                	add    %edx,%edx
  1011bf:	01 ca                	add    %ecx,%edx
  1011c1:	0f b7 c0             	movzwl %ax,%eax
  1011c4:	66 89 02             	mov    %ax,(%edx)
        }
        break;
  1011c7:	eb 77                	jmp    101240 <cga_putc+0xfd>
    case '\n':
        crt_pos += CRT_COLS;
  1011c9:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1011d0:	83 c0 50             	add    $0x50,%eax
  1011d3:	0f b7 c0             	movzwl %ax,%eax
  1011d6:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    case '\r':
        crt_pos -= (crt_pos % CRT_COLS);
  1011dc:	0f b7 1d 44 c4 11 00 	movzwl 0x11c444,%ebx
  1011e3:	0f b7 0d 44 c4 11 00 	movzwl 0x11c444,%ecx
  1011ea:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
  1011ef:	89 c8                	mov    %ecx,%eax
  1011f1:	f7 e2                	mul    %edx
  1011f3:	c1 ea 06             	shr    $0x6,%edx
  1011f6:	89 d0                	mov    %edx,%eax
  1011f8:	c1 e0 02             	shl    $0x2,%eax
  1011fb:	01 d0                	add    %edx,%eax
  1011fd:	c1 e0 04             	shl    $0x4,%eax
  101200:	29 c1                	sub    %eax,%ecx
  101202:	89 ca                	mov    %ecx,%edx
  101204:	0f b7 d2             	movzwl %dx,%edx
  101207:	89 d8                	mov    %ebx,%eax
  101209:	29 d0                	sub    %edx,%eax
  10120b:	0f b7 c0             	movzwl %ax,%eax
  10120e:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
        break;
  101214:	eb 2b                	jmp    101241 <cga_putc+0xfe>
    default:
        crt_buf[crt_pos ++] = c;     // write the character
  101216:	8b 0d 40 c4 11 00    	mov    0x11c440,%ecx
  10121c:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101223:	8d 50 01             	lea    0x1(%eax),%edx
  101226:	0f b7 d2             	movzwl %dx,%edx
  101229:	66 89 15 44 c4 11 00 	mov    %dx,0x11c444
  101230:	01 c0                	add    %eax,%eax
  101232:	8d 14 01             	lea    (%ecx,%eax,1),%edx
  101235:	8b 45 08             	mov    0x8(%ebp),%eax
  101238:	0f b7 c0             	movzwl %ax,%eax
  10123b:	66 89 02             	mov    %ax,(%edx)
        break;
  10123e:	eb 01                	jmp    101241 <cga_putc+0xfe>
        break;
  101240:	90                   	nop
    }

    // What is the purpose of this?
    if (crt_pos >= CRT_SIZE) {
  101241:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101248:	3d cf 07 00 00       	cmp    $0x7cf,%eax
  10124d:	76 5e                	jbe    1012ad <cga_putc+0x16a>
        int i;
        memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
  10124f:	a1 40 c4 11 00       	mov    0x11c440,%eax
  101254:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
  10125a:	a1 40 c4 11 00       	mov    0x11c440,%eax
  10125f:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
  101266:	00 
  101267:	89 54 24 04          	mov    %edx,0x4(%esp)
  10126b:	89 04 24             	mov    %eax,(%esp)
  10126e:	e8 40 4e 00 00       	call   1060b3 <memmove>
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  101273:	c7 45 f4 80 07 00 00 	movl   $0x780,-0xc(%ebp)
  10127a:	eb 15                	jmp    101291 <cga_putc+0x14e>
            crt_buf[i] = 0x0700 | ' ';
  10127c:	8b 15 40 c4 11 00    	mov    0x11c440,%edx
  101282:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101285:	01 c0                	add    %eax,%eax
  101287:	01 d0                	add    %edx,%eax
  101289:	66 c7 00 20 07       	movw   $0x720,(%eax)
        for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i ++) {
  10128e:	ff 45 f4             	incl   -0xc(%ebp)
  101291:	81 7d f4 cf 07 00 00 	cmpl   $0x7cf,-0xc(%ebp)
  101298:	7e e2                	jle    10127c <cga_putc+0x139>
        }
        crt_pos -= CRT_COLS;
  10129a:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012a1:	83 e8 50             	sub    $0x50,%eax
  1012a4:	0f b7 c0             	movzwl %ax,%eax
  1012a7:	66 a3 44 c4 11 00    	mov    %ax,0x11c444
    }

    // move that little blinky thing
    outb(addr_6845, 14);
  1012ad:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012b4:	66 89 45 e6          	mov    %ax,-0x1a(%ebp)
  1012b8:	c6 45 e5 0e          	movb   $0xe,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012bc:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  1012c0:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  1012c4:	ee                   	out    %al,(%dx)
}
  1012c5:	90                   	nop
    outb(addr_6845 + 1, crt_pos >> 8);
  1012c6:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  1012cd:	c1 e8 08             	shr    $0x8,%eax
  1012d0:	0f b7 c0             	movzwl %ax,%eax
  1012d3:	0f b6 c0             	movzbl %al,%eax
  1012d6:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  1012dd:	42                   	inc    %edx
  1012de:	0f b7 d2             	movzwl %dx,%edx
  1012e1:	66 89 55 ea          	mov    %dx,-0x16(%ebp)
  1012e5:	88 45 e9             	mov    %al,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1012e8:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  1012ec:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  1012f0:	ee                   	out    %al,(%dx)
}
  1012f1:	90                   	nop
    outb(addr_6845, 15);
  1012f2:	0f b7 05 46 c4 11 00 	movzwl 0x11c446,%eax
  1012f9:	66 89 45 ee          	mov    %ax,-0x12(%ebp)
  1012fd:	c6 45 ed 0f          	movb   $0xf,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101301:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  101305:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  101309:	ee                   	out    %al,(%dx)
}
  10130a:	90                   	nop
    outb(addr_6845 + 1, crt_pos);
  10130b:	0f b7 05 44 c4 11 00 	movzwl 0x11c444,%eax
  101312:	0f b6 c0             	movzbl %al,%eax
  101315:	0f b7 15 46 c4 11 00 	movzwl 0x11c446,%edx
  10131c:	42                   	inc    %edx
  10131d:	0f b7 d2             	movzwl %dx,%edx
  101320:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  101324:	88 45 f1             	mov    %al,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101327:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  10132b:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  10132f:	ee                   	out    %al,(%dx)
}
  101330:	90                   	nop
}
  101331:	90                   	nop
  101332:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101335:	89 ec                	mov    %ebp,%esp
  101337:	5d                   	pop    %ebp
  101338:	c3                   	ret    

00101339 <serial_putc_sub>:

static void
serial_putc_sub(int c) {
  101339:	55                   	push   %ebp
  10133a:	89 e5                	mov    %esp,%ebp
  10133c:	83 ec 10             	sub    $0x10,%esp
    int i;
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10133f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101346:	eb 08                	jmp    101350 <serial_putc_sub+0x17>
        delay();
  101348:	e8 16 fb ff ff       	call   100e63 <delay>
    for (i = 0; !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800; i ++) {
  10134d:	ff 45 fc             	incl   -0x4(%ebp)
  101350:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101356:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  10135a:	89 c2                	mov    %eax,%edx
  10135c:	ec                   	in     (%dx),%al
  10135d:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  101360:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  101364:	0f b6 c0             	movzbl %al,%eax
  101367:	83 e0 20             	and    $0x20,%eax
  10136a:	85 c0                	test   %eax,%eax
  10136c:	75 09                	jne    101377 <serial_putc_sub+0x3e>
  10136e:	81 7d fc ff 31 00 00 	cmpl   $0x31ff,-0x4(%ebp)
  101375:	7e d1                	jle    101348 <serial_putc_sub+0xf>
    }
    outb(COM1 + COM_TX, c);
  101377:	8b 45 08             	mov    0x8(%ebp),%eax
  10137a:	0f b6 c0             	movzbl %al,%eax
  10137d:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
  101383:	88 45 f5             	mov    %al,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101386:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  10138a:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  10138e:	ee                   	out    %al,(%dx)
}
  10138f:	90                   	nop
}
  101390:	90                   	nop
  101391:	89 ec                	mov    %ebp,%esp
  101393:	5d                   	pop    %ebp
  101394:	c3                   	ret    

00101395 <serial_putc>:

/* serial_putc - print character to serial port */
static void
serial_putc(int c) {
  101395:	55                   	push   %ebp
  101396:	89 e5                	mov    %esp,%ebp
  101398:	83 ec 04             	sub    $0x4,%esp
    if (c != '\b') {
  10139b:	83 7d 08 08          	cmpl   $0x8,0x8(%ebp)
  10139f:	74 0d                	je     1013ae <serial_putc+0x19>
        serial_putc_sub(c);
  1013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1013a4:	89 04 24             	mov    %eax,(%esp)
  1013a7:	e8 8d ff ff ff       	call   101339 <serial_putc_sub>
    else {
        serial_putc_sub('\b');
        serial_putc_sub(' ');
        serial_putc_sub('\b');
    }
}
  1013ac:	eb 24                	jmp    1013d2 <serial_putc+0x3d>
        serial_putc_sub('\b');
  1013ae:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013b5:	e8 7f ff ff ff       	call   101339 <serial_putc_sub>
        serial_putc_sub(' ');
  1013ba:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  1013c1:	e8 73 ff ff ff       	call   101339 <serial_putc_sub>
        serial_putc_sub('\b');
  1013c6:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  1013cd:	e8 67 ff ff ff       	call   101339 <serial_putc_sub>
}
  1013d2:	90                   	nop
  1013d3:	89 ec                	mov    %ebp,%esp
  1013d5:	5d                   	pop    %ebp
  1013d6:	c3                   	ret    

001013d7 <cons_intr>:
/* *
 * cons_intr - called by device interrupt routines to feed input
 * characters into the circular console input buffer.
 * */
static void
cons_intr(int (*proc)(void)) {
  1013d7:	55                   	push   %ebp
  1013d8:	89 e5                	mov    %esp,%ebp
  1013da:	83 ec 18             	sub    $0x18,%esp
    int c;
    while ((c = (*proc)()) != -1) {
  1013dd:	eb 33                	jmp    101412 <cons_intr+0x3b>
        if (c != 0) {
  1013df:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1013e3:	74 2d                	je     101412 <cons_intr+0x3b>
            cons.buf[cons.wpos ++] = c;
  1013e5:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1013ea:	8d 50 01             	lea    0x1(%eax),%edx
  1013ed:	89 15 64 c6 11 00    	mov    %edx,0x11c664
  1013f3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1013f6:	88 90 60 c4 11 00    	mov    %dl,0x11c460(%eax)
            if (cons.wpos == CONSBUFSIZE) {
  1013fc:	a1 64 c6 11 00       	mov    0x11c664,%eax
  101401:	3d 00 02 00 00       	cmp    $0x200,%eax
  101406:	75 0a                	jne    101412 <cons_intr+0x3b>
                cons.wpos = 0;
  101408:	c7 05 64 c6 11 00 00 	movl   $0x0,0x11c664
  10140f:	00 00 00 
    while ((c = (*proc)()) != -1) {
  101412:	8b 45 08             	mov    0x8(%ebp),%eax
  101415:	ff d0                	call   *%eax
  101417:	89 45 f4             	mov    %eax,-0xc(%ebp)
  10141a:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
  10141e:	75 bf                	jne    1013df <cons_intr+0x8>
            }
        }
    }
}
  101420:	90                   	nop
  101421:	90                   	nop
  101422:	89 ec                	mov    %ebp,%esp
  101424:	5d                   	pop    %ebp
  101425:	c3                   	ret    

00101426 <serial_proc_data>:

/* serial_proc_data - get data from serial port */
static int
serial_proc_data(void) {
  101426:	55                   	push   %ebp
  101427:	89 e5                	mov    %esp,%ebp
  101429:	83 ec 10             	sub    $0x10,%esp
  10142c:	66 c7 45 fa fd 03    	movw   $0x3fd,-0x6(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101432:	0f b7 45 fa          	movzwl -0x6(%ebp),%eax
  101436:	89 c2                	mov    %eax,%edx
  101438:	ec                   	in     (%dx),%al
  101439:	88 45 f9             	mov    %al,-0x7(%ebp)
    return data;
  10143c:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
    if (!(inb(COM1 + COM_LSR) & COM_LSR_DATA)) {
  101440:	0f b6 c0             	movzbl %al,%eax
  101443:	83 e0 01             	and    $0x1,%eax
  101446:	85 c0                	test   %eax,%eax
  101448:	75 07                	jne    101451 <serial_proc_data+0x2b>
        return -1;
  10144a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  10144f:	eb 2a                	jmp    10147b <serial_proc_data+0x55>
  101451:	66 c7 45 f6 f8 03    	movw   $0x3f8,-0xa(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  101457:	0f b7 45 f6          	movzwl -0xa(%ebp),%eax
  10145b:	89 c2                	mov    %eax,%edx
  10145d:	ec                   	in     (%dx),%al
  10145e:	88 45 f5             	mov    %al,-0xb(%ebp)
    return data;
  101461:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
    }
    int c = inb(COM1 + COM_RX);
  101465:	0f b6 c0             	movzbl %al,%eax
  101468:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if (c == 127) {
  10146b:	83 7d fc 7f          	cmpl   $0x7f,-0x4(%ebp)
  10146f:	75 07                	jne    101478 <serial_proc_data+0x52>
        c = '\b';
  101471:	c7 45 fc 08 00 00 00 	movl   $0x8,-0x4(%ebp)
    }
    return c;
  101478:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  10147b:	89 ec                	mov    %ebp,%esp
  10147d:	5d                   	pop    %ebp
  10147e:	c3                   	ret    

0010147f <serial_intr>:

/* serial_intr - try to feed input characters from serial port */
void
serial_intr(void) {
  10147f:	55                   	push   %ebp
  101480:	89 e5                	mov    %esp,%ebp
  101482:	83 ec 18             	sub    $0x18,%esp
    if (serial_exists) {
  101485:	a1 48 c4 11 00       	mov    0x11c448,%eax
  10148a:	85 c0                	test   %eax,%eax
  10148c:	74 0c                	je     10149a <serial_intr+0x1b>
        cons_intr(serial_proc_data);
  10148e:	c7 04 24 26 14 10 00 	movl   $0x101426,(%esp)
  101495:	e8 3d ff ff ff       	call   1013d7 <cons_intr>
    }
}
  10149a:	90                   	nop
  10149b:	89 ec                	mov    %ebp,%esp
  10149d:	5d                   	pop    %ebp
  10149e:	c3                   	ret    

0010149f <kbd_proc_data>:
 *
 * The kbd_proc_data() function gets data from the keyboard.
 * If we finish a character, return it, else 0. And return -1 if no data.
 * */
static int
kbd_proc_data(void) {
  10149f:	55                   	push   %ebp
  1014a0:	89 e5                	mov    %esp,%ebp
  1014a2:	83 ec 38             	sub    $0x38,%esp
  1014a5:	66 c7 45 f0 64 00    	movw   $0x64,-0x10(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1014ae:	89 c2                	mov    %eax,%edx
  1014b0:	ec                   	in     (%dx),%al
  1014b1:	88 45 ef             	mov    %al,-0x11(%ebp)
    return data;
  1014b4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
    int c;
    uint8_t data;
    static uint32_t shift;

    if ((inb(KBSTATP) & KBS_DIB) == 0) {
  1014b8:	0f b6 c0             	movzbl %al,%eax
  1014bb:	83 e0 01             	and    $0x1,%eax
  1014be:	85 c0                	test   %eax,%eax
  1014c0:	75 0a                	jne    1014cc <kbd_proc_data+0x2d>
        return -1;
  1014c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  1014c7:	e9 56 01 00 00       	jmp    101622 <kbd_proc_data+0x183>
  1014cc:	66 c7 45 ec 60 00    	movw   $0x60,-0x14(%ebp)
    asm volatile ("inb %1, %0" : "=a" (data) : "d" (port) : "memory");
  1014d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1014d5:	89 c2                	mov    %eax,%edx
  1014d7:	ec                   	in     (%dx),%al
  1014d8:	88 45 eb             	mov    %al,-0x15(%ebp)
    return data;
  1014db:	0f b6 45 eb          	movzbl -0x15(%ebp),%eax
    }

    data = inb(KBDATAP);
  1014df:	88 45 f3             	mov    %al,-0xd(%ebp)

    if (data == 0xE0) {
  1014e2:	80 7d f3 e0          	cmpb   $0xe0,-0xd(%ebp)
  1014e6:	75 17                	jne    1014ff <kbd_proc_data+0x60>
        // E0 escape character
        shift |= E0ESC;
  1014e8:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1014ed:	83 c8 40             	or     $0x40,%eax
  1014f0:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  1014f5:	b8 00 00 00 00       	mov    $0x0,%eax
  1014fa:	e9 23 01 00 00       	jmp    101622 <kbd_proc_data+0x183>
    } else if (data & 0x80) {
  1014ff:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101503:	84 c0                	test   %al,%al
  101505:	79 45                	jns    10154c <kbd_proc_data+0xad>
        // Key released
        data = (shift & E0ESC ? data : data & 0x7F);
  101507:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10150c:	83 e0 40             	and    $0x40,%eax
  10150f:	85 c0                	test   %eax,%eax
  101511:	75 08                	jne    10151b <kbd_proc_data+0x7c>
  101513:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101517:	24 7f                	and    $0x7f,%al
  101519:	eb 04                	jmp    10151f <kbd_proc_data+0x80>
  10151b:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10151f:	88 45 f3             	mov    %al,-0xd(%ebp)
        shift &= ~(shiftcode[data] | E0ESC);
  101522:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101526:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  10152d:	0c 40                	or     $0x40,%al
  10152f:	0f b6 c0             	movzbl %al,%eax
  101532:	f7 d0                	not    %eax
  101534:	89 c2                	mov    %eax,%edx
  101536:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10153b:	21 d0                	and    %edx,%eax
  10153d:	a3 68 c6 11 00       	mov    %eax,0x11c668
        return 0;
  101542:	b8 00 00 00 00       	mov    $0x0,%eax
  101547:	e9 d6 00 00 00       	jmp    101622 <kbd_proc_data+0x183>
    } else if (shift & E0ESC) {
  10154c:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101551:	83 e0 40             	and    $0x40,%eax
  101554:	85 c0                	test   %eax,%eax
  101556:	74 11                	je     101569 <kbd_proc_data+0xca>
        // Last character was an E0 escape; or with 0x80
        data |= 0x80;
  101558:	80 4d f3 80          	orb    $0x80,-0xd(%ebp)
        shift &= ~E0ESC;
  10155c:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101561:	83 e0 bf             	and    $0xffffffbf,%eax
  101564:	a3 68 c6 11 00       	mov    %eax,0x11c668
    }

    shift |= shiftcode[data];
  101569:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  10156d:	0f b6 80 40 90 11 00 	movzbl 0x119040(%eax),%eax
  101574:	0f b6 d0             	movzbl %al,%edx
  101577:	a1 68 c6 11 00       	mov    0x11c668,%eax
  10157c:	09 d0                	or     %edx,%eax
  10157e:	a3 68 c6 11 00       	mov    %eax,0x11c668
    shift ^= togglecode[data];
  101583:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  101587:	0f b6 80 40 91 11 00 	movzbl 0x119140(%eax),%eax
  10158e:	0f b6 d0             	movzbl %al,%edx
  101591:	a1 68 c6 11 00       	mov    0x11c668,%eax
  101596:	31 d0                	xor    %edx,%eax
  101598:	a3 68 c6 11 00       	mov    %eax,0x11c668

    c = charcode[shift & (CTL | SHIFT)][data];
  10159d:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015a2:	83 e0 03             	and    $0x3,%eax
  1015a5:	8b 14 85 40 95 11 00 	mov    0x119540(,%eax,4),%edx
  1015ac:	0f b6 45 f3          	movzbl -0xd(%ebp),%eax
  1015b0:	01 d0                	add    %edx,%eax
  1015b2:	0f b6 00             	movzbl (%eax),%eax
  1015b5:	0f b6 c0             	movzbl %al,%eax
  1015b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (shift & CAPSLOCK) {
  1015bb:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015c0:	83 e0 08             	and    $0x8,%eax
  1015c3:	85 c0                	test   %eax,%eax
  1015c5:	74 22                	je     1015e9 <kbd_proc_data+0x14a>
        if ('a' <= c && c <= 'z')
  1015c7:	83 7d f4 60          	cmpl   $0x60,-0xc(%ebp)
  1015cb:	7e 0c                	jle    1015d9 <kbd_proc_data+0x13a>
  1015cd:	83 7d f4 7a          	cmpl   $0x7a,-0xc(%ebp)
  1015d1:	7f 06                	jg     1015d9 <kbd_proc_data+0x13a>
            c += 'A' - 'a';
  1015d3:	83 6d f4 20          	subl   $0x20,-0xc(%ebp)
  1015d7:	eb 10                	jmp    1015e9 <kbd_proc_data+0x14a>
        else if ('A' <= c && c <= 'Z')
  1015d9:	83 7d f4 40          	cmpl   $0x40,-0xc(%ebp)
  1015dd:	7e 0a                	jle    1015e9 <kbd_proc_data+0x14a>
  1015df:	83 7d f4 5a          	cmpl   $0x5a,-0xc(%ebp)
  1015e3:	7f 04                	jg     1015e9 <kbd_proc_data+0x14a>
            c += 'a' - 'A';
  1015e5:	83 45 f4 20          	addl   $0x20,-0xc(%ebp)
    }

    // Process special keys
    // Ctrl-Alt-Del: reboot
    if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
  1015e9:	a1 68 c6 11 00       	mov    0x11c668,%eax
  1015ee:	f7 d0                	not    %eax
  1015f0:	83 e0 06             	and    $0x6,%eax
  1015f3:	85 c0                	test   %eax,%eax
  1015f5:	75 28                	jne    10161f <kbd_proc_data+0x180>
  1015f7:	81 7d f4 e9 00 00 00 	cmpl   $0xe9,-0xc(%ebp)
  1015fe:	75 1f                	jne    10161f <kbd_proc_data+0x180>
        cprintf("Rebooting!\n");
  101600:	c7 04 24 47 65 10 00 	movl   $0x106547,(%esp)
  101607:	e8 4a ed ff ff       	call   100356 <cprintf>
  10160c:	66 c7 45 e8 92 00    	movw   $0x92,-0x18(%ebp)
  101612:	c6 45 e7 03          	movb   $0x3,-0x19(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101616:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  10161a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  10161d:	ee                   	out    %al,(%dx)
}
  10161e:	90                   	nop
        outb(0x92, 0x3); // courtesy of Chris Frost
    }
    return c;
  10161f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101622:	89 ec                	mov    %ebp,%esp
  101624:	5d                   	pop    %ebp
  101625:	c3                   	ret    

00101626 <kbd_intr>:

/* kbd_intr - try to feed input characters from keyboard */
static void
kbd_intr(void) {
  101626:	55                   	push   %ebp
  101627:	89 e5                	mov    %esp,%ebp
  101629:	83 ec 18             	sub    $0x18,%esp
    cons_intr(kbd_proc_data);
  10162c:	c7 04 24 9f 14 10 00 	movl   $0x10149f,(%esp)
  101633:	e8 9f fd ff ff       	call   1013d7 <cons_intr>
}
  101638:	90                   	nop
  101639:	89 ec                	mov    %ebp,%esp
  10163b:	5d                   	pop    %ebp
  10163c:	c3                   	ret    

0010163d <kbd_init>:

static void
kbd_init(void) {
  10163d:	55                   	push   %ebp
  10163e:	89 e5                	mov    %esp,%ebp
  101640:	83 ec 18             	sub    $0x18,%esp
    // drain the kbd buffer
    kbd_intr();
  101643:	e8 de ff ff ff       	call   101626 <kbd_intr>
    pic_enable(IRQ_KBD);
  101648:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10164f:	e8 51 01 00 00       	call   1017a5 <pic_enable>
}
  101654:	90                   	nop
  101655:	89 ec                	mov    %ebp,%esp
  101657:	5d                   	pop    %ebp
  101658:	c3                   	ret    

00101659 <cons_init>:

/* cons_init - initializes the console devices */
void
cons_init(void) {
  101659:	55                   	push   %ebp
  10165a:	89 e5                	mov    %esp,%ebp
  10165c:	83 ec 18             	sub    $0x18,%esp
    cga_init();
  10165f:	e8 4a f8 ff ff       	call   100eae <cga_init>
    serial_init();
  101664:	e8 2d f9 ff ff       	call   100f96 <serial_init>
    kbd_init();
  101669:	e8 cf ff ff ff       	call   10163d <kbd_init>
    if (!serial_exists) {
  10166e:	a1 48 c4 11 00       	mov    0x11c448,%eax
  101673:	85 c0                	test   %eax,%eax
  101675:	75 0c                	jne    101683 <cons_init+0x2a>
        cprintf("serial port does not exist!!\n");
  101677:	c7 04 24 53 65 10 00 	movl   $0x106553,(%esp)
  10167e:	e8 d3 ec ff ff       	call   100356 <cprintf>
    }
}
  101683:	90                   	nop
  101684:	89 ec                	mov    %ebp,%esp
  101686:	5d                   	pop    %ebp
  101687:	c3                   	ret    

00101688 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void
cons_putc(int c) {
  101688:	55                   	push   %ebp
  101689:	89 e5                	mov    %esp,%ebp
  10168b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10168e:	e8 8e f7 ff ff       	call   100e21 <__intr_save>
  101693:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        lpt_putc(c);
  101696:	8b 45 08             	mov    0x8(%ebp),%eax
  101699:	89 04 24             	mov    %eax,(%esp)
  10169c:	e8 60 fa ff ff       	call   101101 <lpt_putc>
        cga_putc(c);
  1016a1:	8b 45 08             	mov    0x8(%ebp),%eax
  1016a4:	89 04 24             	mov    %eax,(%esp)
  1016a7:	e8 97 fa ff ff       	call   101143 <cga_putc>
        serial_putc(c);
  1016ac:	8b 45 08             	mov    0x8(%ebp),%eax
  1016af:	89 04 24             	mov    %eax,(%esp)
  1016b2:	e8 de fc ff ff       	call   101395 <serial_putc>
    }
    local_intr_restore(intr_flag);
  1016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1016ba:	89 04 24             	mov    %eax,(%esp)
  1016bd:	e8 8b f7 ff ff       	call   100e4d <__intr_restore>
}
  1016c2:	90                   	nop
  1016c3:	89 ec                	mov    %ebp,%esp
  1016c5:	5d                   	pop    %ebp
  1016c6:	c3                   	ret    

001016c7 <cons_getc>:
/* *
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int
cons_getc(void) {
  1016c7:	55                   	push   %ebp
  1016c8:	89 e5                	mov    %esp,%ebp
  1016ca:	83 ec 28             	sub    $0x28,%esp
    int c = 0;
  1016cd:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  1016d4:	e8 48 f7 ff ff       	call   100e21 <__intr_save>
  1016d9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        // poll for any pending input characters,
        // so that this function works even when interrupts are disabled
        // (e.g., when called from the kernel monitor).
        serial_intr();
  1016dc:	e8 9e fd ff ff       	call   10147f <serial_intr>
        kbd_intr();
  1016e1:	e8 40 ff ff ff       	call   101626 <kbd_intr>

        // grab the next character from the input buffer.
        if (cons.rpos != cons.wpos) {
  1016e6:	8b 15 60 c6 11 00    	mov    0x11c660,%edx
  1016ec:	a1 64 c6 11 00       	mov    0x11c664,%eax
  1016f1:	39 c2                	cmp    %eax,%edx
  1016f3:	74 31                	je     101726 <cons_getc+0x5f>
            c = cons.buf[cons.rpos ++];
  1016f5:	a1 60 c6 11 00       	mov    0x11c660,%eax
  1016fa:	8d 50 01             	lea    0x1(%eax),%edx
  1016fd:	89 15 60 c6 11 00    	mov    %edx,0x11c660
  101703:	0f b6 80 60 c4 11 00 	movzbl 0x11c460(%eax),%eax
  10170a:	0f b6 c0             	movzbl %al,%eax
  10170d:	89 45 f4             	mov    %eax,-0xc(%ebp)
            if (cons.rpos == CONSBUFSIZE) {
  101710:	a1 60 c6 11 00       	mov    0x11c660,%eax
  101715:	3d 00 02 00 00       	cmp    $0x200,%eax
  10171a:	75 0a                	jne    101726 <cons_getc+0x5f>
                cons.rpos = 0;
  10171c:	c7 05 60 c6 11 00 00 	movl   $0x0,0x11c660
  101723:	00 00 00 
            }
        }
    }
    local_intr_restore(intr_flag);
  101726:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101729:	89 04 24             	mov    %eax,(%esp)
  10172c:	e8 1c f7 ff ff       	call   100e4d <__intr_restore>
    return c;
  101731:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  101734:	89 ec                	mov    %ebp,%esp
  101736:	5d                   	pop    %ebp
  101737:	c3                   	ret    

00101738 <intr_enable>:
#include <x86.h>
#include <intr.h>

/* intr_enable - enable irq interrupt */
void
intr_enable(void) {
  101738:	55                   	push   %ebp
  101739:	89 e5                	mov    %esp,%ebp
    asm volatile ("sti");
  10173b:	fb                   	sti    
}
  10173c:	90                   	nop
    sti();
}
  10173d:	90                   	nop
  10173e:	5d                   	pop    %ebp
  10173f:	c3                   	ret    

00101740 <intr_disable>:

/* intr_disable - disable irq interrupt */
void
intr_disable(void) {
  101740:	55                   	push   %ebp
  101741:	89 e5                	mov    %esp,%ebp
    asm volatile ("cli" ::: "memory");
  101743:	fa                   	cli    
}
  101744:	90                   	nop
    cli();
}
  101745:	90                   	nop
  101746:	5d                   	pop    %ebp
  101747:	c3                   	ret    

00101748 <pic_setmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static uint16_t irq_mask = 0xFFFF & ~(1 << IRQ_SLAVE);
static bool did_init = 0;

static void
pic_setmask(uint16_t mask) {
  101748:	55                   	push   %ebp
  101749:	89 e5                	mov    %esp,%ebp
  10174b:	83 ec 14             	sub    $0x14,%esp
  10174e:	8b 45 08             	mov    0x8(%ebp),%eax
  101751:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
    irq_mask = mask;
  101755:	8b 45 ec             	mov    -0x14(%ebp),%eax
  101758:	66 a3 50 95 11 00    	mov    %ax,0x119550
    if (did_init) {
  10175e:	a1 6c c6 11 00       	mov    0x11c66c,%eax
  101763:	85 c0                	test   %eax,%eax
  101765:	74 39                	je     1017a0 <pic_setmask+0x58>
        outb(IO_PIC1 + 1, mask);
  101767:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10176a:	0f b6 c0             	movzbl %al,%eax
  10176d:	66 c7 45 fa 21 00    	movw   $0x21,-0x6(%ebp)
  101773:	88 45 f9             	mov    %al,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101776:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  10177a:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  10177e:	ee                   	out    %al,(%dx)
}
  10177f:	90                   	nop
        outb(IO_PIC2 + 1, mask >> 8);
  101780:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
  101784:	c1 e8 08             	shr    $0x8,%eax
  101787:	0f b7 c0             	movzwl %ax,%eax
  10178a:	0f b6 c0             	movzbl %al,%eax
  10178d:	66 c7 45 fe a1 00    	movw   $0xa1,-0x2(%ebp)
  101793:	88 45 fd             	mov    %al,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101796:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  10179a:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  10179e:	ee                   	out    %al,(%dx)
}
  10179f:	90                   	nop
    }
}
  1017a0:	90                   	nop
  1017a1:	89 ec                	mov    %ebp,%esp
  1017a3:	5d                   	pop    %ebp
  1017a4:	c3                   	ret    

001017a5 <pic_enable>:

void
pic_enable(unsigned int irq) {
  1017a5:	55                   	push   %ebp
  1017a6:	89 e5                	mov    %esp,%ebp
  1017a8:	83 ec 04             	sub    $0x4,%esp
    pic_setmask(irq_mask & ~(1 << irq));
  1017ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1017ae:	ba 01 00 00 00       	mov    $0x1,%edx
  1017b3:	88 c1                	mov    %al,%cl
  1017b5:	d3 e2                	shl    %cl,%edx
  1017b7:	89 d0                	mov    %edx,%eax
  1017b9:	98                   	cwtl   
  1017ba:	f7 d0                	not    %eax
  1017bc:	0f bf d0             	movswl %ax,%edx
  1017bf:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  1017c6:	98                   	cwtl   
  1017c7:	21 d0                	and    %edx,%eax
  1017c9:	98                   	cwtl   
  1017ca:	0f b7 c0             	movzwl %ax,%eax
  1017cd:	89 04 24             	mov    %eax,(%esp)
  1017d0:	e8 73 ff ff ff       	call   101748 <pic_setmask>
}
  1017d5:	90                   	nop
  1017d6:	89 ec                	mov    %ebp,%esp
  1017d8:	5d                   	pop    %ebp
  1017d9:	c3                   	ret    

001017da <pic_init>:

/* pic_init - initialize the 8259A interrupt controllers */
void
pic_init(void) {
  1017da:	55                   	push   %ebp
  1017db:	89 e5                	mov    %esp,%ebp
  1017dd:	83 ec 44             	sub    $0x44,%esp
    did_init = 1;
  1017e0:	c7 05 6c c6 11 00 01 	movl   $0x1,0x11c66c
  1017e7:	00 00 00 
  1017ea:	66 c7 45 ca 21 00    	movw   $0x21,-0x36(%ebp)
  1017f0:	c6 45 c9 ff          	movb   $0xff,-0x37(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1017f4:	0f b6 45 c9          	movzbl -0x37(%ebp),%eax
  1017f8:	0f b7 55 ca          	movzwl -0x36(%ebp),%edx
  1017fc:	ee                   	out    %al,(%dx)
}
  1017fd:	90                   	nop
  1017fe:	66 c7 45 ce a1 00    	movw   $0xa1,-0x32(%ebp)
  101804:	c6 45 cd ff          	movb   $0xff,-0x33(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101808:	0f b6 45 cd          	movzbl -0x33(%ebp),%eax
  10180c:	0f b7 55 ce          	movzwl -0x32(%ebp),%edx
  101810:	ee                   	out    %al,(%dx)
}
  101811:	90                   	nop
  101812:	66 c7 45 d2 20 00    	movw   $0x20,-0x2e(%ebp)
  101818:	c6 45 d1 11          	movb   $0x11,-0x2f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10181c:	0f b6 45 d1          	movzbl -0x2f(%ebp),%eax
  101820:	0f b7 55 d2          	movzwl -0x2e(%ebp),%edx
  101824:	ee                   	out    %al,(%dx)
}
  101825:	90                   	nop
  101826:	66 c7 45 d6 21 00    	movw   $0x21,-0x2a(%ebp)
  10182c:	c6 45 d5 20          	movb   $0x20,-0x2b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101830:	0f b6 45 d5          	movzbl -0x2b(%ebp),%eax
  101834:	0f b7 55 d6          	movzwl -0x2a(%ebp),%edx
  101838:	ee                   	out    %al,(%dx)
}
  101839:	90                   	nop
  10183a:	66 c7 45 da 21 00    	movw   $0x21,-0x26(%ebp)
  101840:	c6 45 d9 04          	movb   $0x4,-0x27(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101844:	0f b6 45 d9          	movzbl -0x27(%ebp),%eax
  101848:	0f b7 55 da          	movzwl -0x26(%ebp),%edx
  10184c:	ee                   	out    %al,(%dx)
}
  10184d:	90                   	nop
  10184e:	66 c7 45 de 21 00    	movw   $0x21,-0x22(%ebp)
  101854:	c6 45 dd 03          	movb   $0x3,-0x23(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101858:	0f b6 45 dd          	movzbl -0x23(%ebp),%eax
  10185c:	0f b7 55 de          	movzwl -0x22(%ebp),%edx
  101860:	ee                   	out    %al,(%dx)
}
  101861:	90                   	nop
  101862:	66 c7 45 e2 a0 00    	movw   $0xa0,-0x1e(%ebp)
  101868:	c6 45 e1 11          	movb   $0x11,-0x1f(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  10186c:	0f b6 45 e1          	movzbl -0x1f(%ebp),%eax
  101870:	0f b7 55 e2          	movzwl -0x1e(%ebp),%edx
  101874:	ee                   	out    %al,(%dx)
}
  101875:	90                   	nop
  101876:	66 c7 45 e6 a1 00    	movw   $0xa1,-0x1a(%ebp)
  10187c:	c6 45 e5 28          	movb   $0x28,-0x1b(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101880:	0f b6 45 e5          	movzbl -0x1b(%ebp),%eax
  101884:	0f b7 55 e6          	movzwl -0x1a(%ebp),%edx
  101888:	ee                   	out    %al,(%dx)
}
  101889:	90                   	nop
  10188a:	66 c7 45 ea a1 00    	movw   $0xa1,-0x16(%ebp)
  101890:	c6 45 e9 02          	movb   $0x2,-0x17(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  101894:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
  101898:	0f b7 55 ea          	movzwl -0x16(%ebp),%edx
  10189c:	ee                   	out    %al,(%dx)
}
  10189d:	90                   	nop
  10189e:	66 c7 45 ee a1 00    	movw   $0xa1,-0x12(%ebp)
  1018a4:	c6 45 ed 03          	movb   $0x3,-0x13(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018a8:	0f b6 45 ed          	movzbl -0x13(%ebp),%eax
  1018ac:	0f b7 55 ee          	movzwl -0x12(%ebp),%edx
  1018b0:	ee                   	out    %al,(%dx)
}
  1018b1:	90                   	nop
  1018b2:	66 c7 45 f2 20 00    	movw   $0x20,-0xe(%ebp)
  1018b8:	c6 45 f1 68          	movb   $0x68,-0xf(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018bc:	0f b6 45 f1          	movzbl -0xf(%ebp),%eax
  1018c0:	0f b7 55 f2          	movzwl -0xe(%ebp),%edx
  1018c4:	ee                   	out    %al,(%dx)
}
  1018c5:	90                   	nop
  1018c6:	66 c7 45 f6 20 00    	movw   $0x20,-0xa(%ebp)
  1018cc:	c6 45 f5 0a          	movb   $0xa,-0xb(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018d0:	0f b6 45 f5          	movzbl -0xb(%ebp),%eax
  1018d4:	0f b7 55 f6          	movzwl -0xa(%ebp),%edx
  1018d8:	ee                   	out    %al,(%dx)
}
  1018d9:	90                   	nop
  1018da:	66 c7 45 fa a0 00    	movw   $0xa0,-0x6(%ebp)
  1018e0:	c6 45 f9 68          	movb   $0x68,-0x7(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018e4:	0f b6 45 f9          	movzbl -0x7(%ebp),%eax
  1018e8:	0f b7 55 fa          	movzwl -0x6(%ebp),%edx
  1018ec:	ee                   	out    %al,(%dx)
}
  1018ed:	90                   	nop
  1018ee:	66 c7 45 fe a0 00    	movw   $0xa0,-0x2(%ebp)
  1018f4:	c6 45 fd 0a          	movb   $0xa,-0x3(%ebp)
    asm volatile ("outb %0, %1" :: "a" (data), "d" (port) : "memory");
  1018f8:	0f b6 45 fd          	movzbl -0x3(%ebp),%eax
  1018fc:	0f b7 55 fe          	movzwl -0x2(%ebp),%edx
  101900:	ee                   	out    %al,(%dx)
}
  101901:	90                   	nop
    outb(IO_PIC1, 0x0a);    // read IRR by default

    outb(IO_PIC2, 0x68);    // OCW3
    outb(IO_PIC2, 0x0a);    // OCW3

    if (irq_mask != 0xFFFF) {
  101902:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101909:	3d ff ff 00 00       	cmp    $0xffff,%eax
  10190e:	74 0f                	je     10191f <pic_init+0x145>
        pic_setmask(irq_mask);
  101910:	0f b7 05 50 95 11 00 	movzwl 0x119550,%eax
  101917:	89 04 24             	mov    %eax,(%esp)
  10191a:	e8 29 fe ff ff       	call   101748 <pic_setmask>
    }
}
  10191f:	90                   	nop
  101920:	89 ec                	mov    %ebp,%esp
  101922:	5d                   	pop    %ebp
  101923:	c3                   	ret    

00101924 <print_ticks>:
#include <console.h>
#include <kdebug.h>
#include <string.h>
#define TICK_NUM 100

static void print_ticks() {
  101924:	55                   	push   %ebp
  101925:	89 e5                	mov    %esp,%ebp
  101927:	83 ec 18             	sub    $0x18,%esp
    cprintf("%d ticks\n",TICK_NUM);
  10192a:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  101931:	00 
  101932:	c7 04 24 80 65 10 00 	movl   $0x106580,(%esp)
  101939:	e8 18 ea ff ff       	call   100356 <cprintf>
#ifdef DEBUG_GRADE
    cprintf("End of Test.\n");
  10193e:	c7 04 24 8a 65 10 00 	movl   $0x10658a,(%esp)
  101945:	e8 0c ea ff ff       	call   100356 <cprintf>
    panic("EOT: kernel seems ok.");
  10194a:	c7 44 24 08 98 65 10 	movl   $0x106598,0x8(%esp)
  101951:	00 
  101952:	c7 44 24 04 12 00 00 	movl   $0x12,0x4(%esp)
  101959:	00 
  10195a:	c7 04 24 ae 65 10 00 	movl   $0x1065ae,(%esp)
  101961:	e8 81 f3 ff ff       	call   100ce7 <__panic>

00101966 <idt_init>:
    sizeof(idt) - 1, (uintptr_t)idt
};

/* idt_init - initialize IDT to each of the entry points in kern/trap/vectors.S */
void
idt_init(void) {
  101966:	55                   	push   %ebp
  101967:	89 e5                	mov    %esp,%ebp
  101969:	83 ec 10             	sub    $0x10,%esp
      *     You don't know the meaning of this instruction? just google it! and check the libs/x86.h to know more.
      *     Notice: the argument of lidt is idt_pd. try to find it!
      */
    extern uintptr_t __vectors[];
    int i;
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  10196c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  101973:	e9 c4 00 00 00       	jmp    101a3c <idt_init+0xd6>
        SETGATE(idt[i], 0, GD_KTEXT, __vectors[i], DPL_KERNEL);
  101978:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10197b:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101982:	0f b7 d0             	movzwl %ax,%edx
  101985:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101988:	66 89 14 c5 e0 c6 11 	mov    %dx,0x11c6e0(,%eax,8)
  10198f:	00 
  101990:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101993:	66 c7 04 c5 e2 c6 11 	movw   $0x8,0x11c6e2(,%eax,8)
  10199a:	00 08 00 
  10199d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019a0:	0f b6 14 c5 e4 c6 11 	movzbl 0x11c6e4(,%eax,8),%edx
  1019a7:	00 
  1019a8:	80 e2 e0             	and    $0xe0,%dl
  1019ab:	88 14 c5 e4 c6 11 00 	mov    %dl,0x11c6e4(,%eax,8)
  1019b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019b5:	0f b6 14 c5 e4 c6 11 	movzbl 0x11c6e4(,%eax,8),%edx
  1019bc:	00 
  1019bd:	80 e2 1f             	and    $0x1f,%dl
  1019c0:	88 14 c5 e4 c6 11 00 	mov    %dl,0x11c6e4(,%eax,8)
  1019c7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019ca:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  1019d1:	00 
  1019d2:	80 e2 f0             	and    $0xf0,%dl
  1019d5:	80 ca 0e             	or     $0xe,%dl
  1019d8:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  1019df:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019e2:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  1019e9:	00 
  1019ea:	80 e2 ef             	and    $0xef,%dl
  1019ed:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  1019f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1019f7:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  1019fe:	00 
  1019ff:	80 e2 9f             	and    $0x9f,%dl
  101a02:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  101a09:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a0c:	0f b6 14 c5 e5 c6 11 	movzbl 0x11c6e5(,%eax,8),%edx
  101a13:	00 
  101a14:	80 ca 80             	or     $0x80,%dl
  101a17:	88 14 c5 e5 c6 11 00 	mov    %dl,0x11c6e5(,%eax,8)
  101a1e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a21:	8b 04 85 e0 95 11 00 	mov    0x1195e0(,%eax,4),%eax
  101a28:	c1 e8 10             	shr    $0x10,%eax
  101a2b:	0f b7 d0             	movzwl %ax,%edx
  101a2e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a31:	66 89 14 c5 e6 c6 11 	mov    %dx,0x11c6e6(,%eax,8)
  101a38:	00 
    for (i = 0; i < sizeof(idt) / sizeof(struct gatedesc); i ++) {
  101a39:	ff 45 fc             	incl   -0x4(%ebp)
  101a3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  101a3f:	3d ff 00 00 00       	cmp    $0xff,%eax
  101a44:	0f 86 2e ff ff ff    	jbe    101978 <idt_init+0x12>
    }
	// set for switch from user to kernel
    SETGATE(idt[T_SWITCH_TOK], 0, GD_KTEXT, __vectors[T_SWITCH_TOK], DPL_USER);
  101a4a:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101a4f:	0f b7 c0             	movzwl %ax,%eax
  101a52:	66 a3 a8 ca 11 00    	mov    %ax,0x11caa8
  101a58:	66 c7 05 aa ca 11 00 	movw   $0x8,0x11caaa
  101a5f:	08 00 
  101a61:	0f b6 05 ac ca 11 00 	movzbl 0x11caac,%eax
  101a68:	24 e0                	and    $0xe0,%al
  101a6a:	a2 ac ca 11 00       	mov    %al,0x11caac
  101a6f:	0f b6 05 ac ca 11 00 	movzbl 0x11caac,%eax
  101a76:	24 1f                	and    $0x1f,%al
  101a78:	a2 ac ca 11 00       	mov    %al,0x11caac
  101a7d:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101a84:	24 f0                	and    $0xf0,%al
  101a86:	0c 0e                	or     $0xe,%al
  101a88:	a2 ad ca 11 00       	mov    %al,0x11caad
  101a8d:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101a94:	24 ef                	and    $0xef,%al
  101a96:	a2 ad ca 11 00       	mov    %al,0x11caad
  101a9b:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101aa2:	0c 60                	or     $0x60,%al
  101aa4:	a2 ad ca 11 00       	mov    %al,0x11caad
  101aa9:	0f b6 05 ad ca 11 00 	movzbl 0x11caad,%eax
  101ab0:	0c 80                	or     $0x80,%al
  101ab2:	a2 ad ca 11 00       	mov    %al,0x11caad
  101ab7:	a1 c4 97 11 00       	mov    0x1197c4,%eax
  101abc:	c1 e8 10             	shr    $0x10,%eax
  101abf:	0f b7 c0             	movzwl %ax,%eax
  101ac2:	66 a3 ae ca 11 00    	mov    %ax,0x11caae
  101ac8:	c7 45 f8 60 95 11 00 	movl   $0x119560,-0x8(%ebp)
    asm volatile ("lidt (%0)" :: "r" (pd) : "memory");
  101acf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  101ad2:	0f 01 18             	lidtl  (%eax)
}
  101ad5:	90                   	nop
	// load the IDT
    lidt(&idt_pd);
}
  101ad6:	90                   	nop
  101ad7:	89 ec                	mov    %ebp,%esp
  101ad9:	5d                   	pop    %ebp
  101ada:	c3                   	ret    

00101adb <trapname>:

static const char *
trapname(int trapno) {
  101adb:	55                   	push   %ebp
  101adc:	89 e5                	mov    %esp,%ebp
        "Alignment Check",
        "Machine-Check",
        "SIMD Floating-Point Exception"
    };

    if (trapno < sizeof(excnames)/sizeof(const char * const)) {
  101ade:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae1:	83 f8 13             	cmp    $0x13,%eax
  101ae4:	77 0c                	ja     101af2 <trapname+0x17>
        return excnames[trapno];
  101ae6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ae9:	8b 04 85 00 69 10 00 	mov    0x106900(,%eax,4),%eax
  101af0:	eb 18                	jmp    101b0a <trapname+0x2f>
    }
    if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16) {
  101af2:	83 7d 08 1f          	cmpl   $0x1f,0x8(%ebp)
  101af6:	7e 0d                	jle    101b05 <trapname+0x2a>
  101af8:	83 7d 08 2f          	cmpl   $0x2f,0x8(%ebp)
  101afc:	7f 07                	jg     101b05 <trapname+0x2a>
        return "Hardware Interrupt";
  101afe:	b8 bf 65 10 00       	mov    $0x1065bf,%eax
  101b03:	eb 05                	jmp    101b0a <trapname+0x2f>
    }
    return "(unknown trap)";
  101b05:	b8 d2 65 10 00       	mov    $0x1065d2,%eax
}
  101b0a:	5d                   	pop    %ebp
  101b0b:	c3                   	ret    

00101b0c <trap_in_kernel>:

/* trap_in_kernel - test if trap happened in kernel */
bool
trap_in_kernel(struct trapframe *tf) {
  101b0c:	55                   	push   %ebp
  101b0d:	89 e5                	mov    %esp,%ebp
    return (tf->tf_cs == (uint16_t)KERNEL_CS);
  101b0f:	8b 45 08             	mov    0x8(%ebp),%eax
  101b12:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101b16:	83 f8 08             	cmp    $0x8,%eax
  101b19:	0f 94 c0             	sete   %al
  101b1c:	0f b6 c0             	movzbl %al,%eax
}
  101b1f:	5d                   	pop    %ebp
  101b20:	c3                   	ret    

00101b21 <print_trapframe>:
    "TF", "IF", "DF", "OF", NULL, NULL, "NT", NULL,
    "RF", "VM", "AC", "VIF", "VIP", "ID", NULL, NULL,
};

void
print_trapframe(struct trapframe *tf) {
  101b21:	55                   	push   %ebp
  101b22:	89 e5                	mov    %esp,%ebp
  101b24:	83 ec 28             	sub    $0x28,%esp
    cprintf("trapframe at %p\n", tf);
  101b27:	8b 45 08             	mov    0x8(%ebp),%eax
  101b2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b2e:	c7 04 24 13 66 10 00 	movl   $0x106613,(%esp)
  101b35:	e8 1c e8 ff ff       	call   100356 <cprintf>
    print_regs(&tf->tf_regs);
  101b3a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b3d:	89 04 24             	mov    %eax,(%esp)
  101b40:	e8 8f 01 00 00       	call   101cd4 <print_regs>
    cprintf("  ds   0x----%04x\n", tf->tf_ds);
  101b45:	8b 45 08             	mov    0x8(%ebp),%eax
  101b48:	0f b7 40 2c          	movzwl 0x2c(%eax),%eax
  101b4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b50:	c7 04 24 24 66 10 00 	movl   $0x106624,(%esp)
  101b57:	e8 fa e7 ff ff       	call   100356 <cprintf>
    cprintf("  es   0x----%04x\n", tf->tf_es);
  101b5c:	8b 45 08             	mov    0x8(%ebp),%eax
  101b5f:	0f b7 40 28          	movzwl 0x28(%eax),%eax
  101b63:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b67:	c7 04 24 37 66 10 00 	movl   $0x106637,(%esp)
  101b6e:	e8 e3 e7 ff ff       	call   100356 <cprintf>
    cprintf("  fs   0x----%04x\n", tf->tf_fs);
  101b73:	8b 45 08             	mov    0x8(%ebp),%eax
  101b76:	0f b7 40 24          	movzwl 0x24(%eax),%eax
  101b7a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b7e:	c7 04 24 4a 66 10 00 	movl   $0x10664a,(%esp)
  101b85:	e8 cc e7 ff ff       	call   100356 <cprintf>
    cprintf("  gs   0x----%04x\n", tf->tf_gs);
  101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
  101b8d:	0f b7 40 20          	movzwl 0x20(%eax),%eax
  101b91:	89 44 24 04          	mov    %eax,0x4(%esp)
  101b95:	c7 04 24 5d 66 10 00 	movl   $0x10665d,(%esp)
  101b9c:	e8 b5 e7 ff ff       	call   100356 <cprintf>
    cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
  101ba1:	8b 45 08             	mov    0x8(%ebp),%eax
  101ba4:	8b 40 30             	mov    0x30(%eax),%eax
  101ba7:	89 04 24             	mov    %eax,(%esp)
  101baa:	e8 2c ff ff ff       	call   101adb <trapname>
  101baf:	8b 55 08             	mov    0x8(%ebp),%edx
  101bb2:	8b 52 30             	mov    0x30(%edx),%edx
  101bb5:	89 44 24 08          	mov    %eax,0x8(%esp)
  101bb9:	89 54 24 04          	mov    %edx,0x4(%esp)
  101bbd:	c7 04 24 70 66 10 00 	movl   $0x106670,(%esp)
  101bc4:	e8 8d e7 ff ff       	call   100356 <cprintf>
    cprintf("  err  0x%08x\n", tf->tf_err);
  101bc9:	8b 45 08             	mov    0x8(%ebp),%eax
  101bcc:	8b 40 34             	mov    0x34(%eax),%eax
  101bcf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101bd3:	c7 04 24 82 66 10 00 	movl   $0x106682,(%esp)
  101bda:	e8 77 e7 ff ff       	call   100356 <cprintf>
    cprintf("  eip  0x%08x\n", tf->tf_eip);
  101bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  101be2:	8b 40 38             	mov    0x38(%eax),%eax
  101be5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101be9:	c7 04 24 91 66 10 00 	movl   $0x106691,(%esp)
  101bf0:	e8 61 e7 ff ff       	call   100356 <cprintf>
    cprintf("  cs   0x----%04x\n", tf->tf_cs);
  101bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  101bf8:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101bfc:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c00:	c7 04 24 a0 66 10 00 	movl   $0x1066a0,(%esp)
  101c07:	e8 4a e7 ff ff       	call   100356 <cprintf>
    cprintf("  flag 0x%08x ", tf->tf_eflags);
  101c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  101c0f:	8b 40 40             	mov    0x40(%eax),%eax
  101c12:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c16:	c7 04 24 b3 66 10 00 	movl   $0x1066b3,(%esp)
  101c1d:	e8 34 e7 ff ff       	call   100356 <cprintf>

    int i, j;
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  101c29:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  101c30:	eb 3d                	jmp    101c6f <print_trapframe+0x14e>
        if ((tf->tf_eflags & j) && IA32flags[i] != NULL) {
  101c32:	8b 45 08             	mov    0x8(%ebp),%eax
  101c35:	8b 50 40             	mov    0x40(%eax),%edx
  101c38:	8b 45 f0             	mov    -0x10(%ebp),%eax
  101c3b:	21 d0                	and    %edx,%eax
  101c3d:	85 c0                	test   %eax,%eax
  101c3f:	74 28                	je     101c69 <print_trapframe+0x148>
  101c41:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c44:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101c4b:	85 c0                	test   %eax,%eax
  101c4d:	74 1a                	je     101c69 <print_trapframe+0x148>
            cprintf("%s,", IA32flags[i]);
  101c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c52:	8b 04 85 80 95 11 00 	mov    0x119580(,%eax,4),%eax
  101c59:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c5d:	c7 04 24 c2 66 10 00 	movl   $0x1066c2,(%esp)
  101c64:	e8 ed e6 ff ff       	call   100356 <cprintf>
    for (i = 0, j = 1; i < sizeof(IA32flags) / sizeof(IA32flags[0]); i ++, j <<= 1) {
  101c69:	ff 45 f4             	incl   -0xc(%ebp)
  101c6c:	d1 65 f0             	shll   -0x10(%ebp)
  101c6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  101c72:	83 f8 17             	cmp    $0x17,%eax
  101c75:	76 bb                	jbe    101c32 <print_trapframe+0x111>
        }
    }
    cprintf("IOPL=%d\n", (tf->tf_eflags & FL_IOPL_MASK) >> 12);
  101c77:	8b 45 08             	mov    0x8(%ebp),%eax
  101c7a:	8b 40 40             	mov    0x40(%eax),%eax
  101c7d:	c1 e8 0c             	shr    $0xc,%eax
  101c80:	83 e0 03             	and    $0x3,%eax
  101c83:	89 44 24 04          	mov    %eax,0x4(%esp)
  101c87:	c7 04 24 c6 66 10 00 	movl   $0x1066c6,(%esp)
  101c8e:	e8 c3 e6 ff ff       	call   100356 <cprintf>

    if (!trap_in_kernel(tf)) {
  101c93:	8b 45 08             	mov    0x8(%ebp),%eax
  101c96:	89 04 24             	mov    %eax,(%esp)
  101c99:	e8 6e fe ff ff       	call   101b0c <trap_in_kernel>
  101c9e:	85 c0                	test   %eax,%eax
  101ca0:	75 2d                	jne    101ccf <print_trapframe+0x1ae>
        cprintf("  esp  0x%08x\n", tf->tf_esp);
  101ca2:	8b 45 08             	mov    0x8(%ebp),%eax
  101ca5:	8b 40 44             	mov    0x44(%eax),%eax
  101ca8:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cac:	c7 04 24 cf 66 10 00 	movl   $0x1066cf,(%esp)
  101cb3:	e8 9e e6 ff ff       	call   100356 <cprintf>
        cprintf("  ss   0x----%04x\n", tf->tf_ss);
  101cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  101cbb:	0f b7 40 48          	movzwl 0x48(%eax),%eax
  101cbf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cc3:	c7 04 24 de 66 10 00 	movl   $0x1066de,(%esp)
  101cca:	e8 87 e6 ff ff       	call   100356 <cprintf>
    }
}
  101ccf:	90                   	nop
  101cd0:	89 ec                	mov    %ebp,%esp
  101cd2:	5d                   	pop    %ebp
  101cd3:	c3                   	ret    

00101cd4 <print_regs>:

void
print_regs(struct pushregs *regs) {
  101cd4:	55                   	push   %ebp
  101cd5:	89 e5                	mov    %esp,%ebp
  101cd7:	83 ec 18             	sub    $0x18,%esp
    cprintf("  edi  0x%08x\n", regs->reg_edi);
  101cda:	8b 45 08             	mov    0x8(%ebp),%eax
  101cdd:	8b 00                	mov    (%eax),%eax
  101cdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  101ce3:	c7 04 24 f1 66 10 00 	movl   $0x1066f1,(%esp)
  101cea:	e8 67 e6 ff ff       	call   100356 <cprintf>
    cprintf("  esi  0x%08x\n", regs->reg_esi);
  101cef:	8b 45 08             	mov    0x8(%ebp),%eax
  101cf2:	8b 40 04             	mov    0x4(%eax),%eax
  101cf5:	89 44 24 04          	mov    %eax,0x4(%esp)
  101cf9:	c7 04 24 00 67 10 00 	movl   $0x106700,(%esp)
  101d00:	e8 51 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebp  0x%08x\n", regs->reg_ebp);
  101d05:	8b 45 08             	mov    0x8(%ebp),%eax
  101d08:	8b 40 08             	mov    0x8(%eax),%eax
  101d0b:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d0f:	c7 04 24 0f 67 10 00 	movl   $0x10670f,(%esp)
  101d16:	e8 3b e6 ff ff       	call   100356 <cprintf>
    cprintf("  oesp 0x%08x\n", regs->reg_oesp);
  101d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  101d1e:	8b 40 0c             	mov    0xc(%eax),%eax
  101d21:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d25:	c7 04 24 1e 67 10 00 	movl   $0x10671e,(%esp)
  101d2c:	e8 25 e6 ff ff       	call   100356 <cprintf>
    cprintf("  ebx  0x%08x\n", regs->reg_ebx);
  101d31:	8b 45 08             	mov    0x8(%ebp),%eax
  101d34:	8b 40 10             	mov    0x10(%eax),%eax
  101d37:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d3b:	c7 04 24 2d 67 10 00 	movl   $0x10672d,(%esp)
  101d42:	e8 0f e6 ff ff       	call   100356 <cprintf>
    cprintf("  edx  0x%08x\n", regs->reg_edx);
  101d47:	8b 45 08             	mov    0x8(%ebp),%eax
  101d4a:	8b 40 14             	mov    0x14(%eax),%eax
  101d4d:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d51:	c7 04 24 3c 67 10 00 	movl   $0x10673c,(%esp)
  101d58:	e8 f9 e5 ff ff       	call   100356 <cprintf>
    cprintf("  ecx  0x%08x\n", regs->reg_ecx);
  101d5d:	8b 45 08             	mov    0x8(%ebp),%eax
  101d60:	8b 40 18             	mov    0x18(%eax),%eax
  101d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d67:	c7 04 24 4b 67 10 00 	movl   $0x10674b,(%esp)
  101d6e:	e8 e3 e5 ff ff       	call   100356 <cprintf>
    cprintf("  eax  0x%08x\n", regs->reg_eax);
  101d73:	8b 45 08             	mov    0x8(%ebp),%eax
  101d76:	8b 40 1c             	mov    0x1c(%eax),%eax
  101d79:	89 44 24 04          	mov    %eax,0x4(%esp)
  101d7d:	c7 04 24 5a 67 10 00 	movl   $0x10675a,(%esp)
  101d84:	e8 cd e5 ff ff       	call   100356 <cprintf>
}
  101d89:	90                   	nop
  101d8a:	89 ec                	mov    %ebp,%esp
  101d8c:	5d                   	pop    %ebp
  101d8d:	c3                   	ret    

00101d8e <trap_dispatch>:
/* temporary trapframe or pointer to trapframe */
struct trapframe switchk2u, *switchu2k;

/* trap_dispatch - dispatch based on what type of trap occurred */
static void
trap_dispatch(struct trapframe *tf) {
  101d8e:	55                   	push   %ebp
  101d8f:	89 e5                	mov    %esp,%ebp
  101d91:	83 ec 28             	sub    $0x28,%esp
  101d94:	89 5d fc             	mov    %ebx,-0x4(%ebp)
    char c;

    switch (tf->tf_trapno) {
  101d97:	8b 45 08             	mov    0x8(%ebp),%eax
  101d9a:	8b 40 30             	mov    0x30(%eax),%eax
  101d9d:	83 f8 79             	cmp    $0x79,%eax
  101da0:	0f 84 6c 01 00 00    	je     101f12 <trap_dispatch+0x184>
  101da6:	83 f8 79             	cmp    $0x79,%eax
  101da9:	0f 87 e0 01 00 00    	ja     101f8f <trap_dispatch+0x201>
  101daf:	83 f8 78             	cmp    $0x78,%eax
  101db2:	0f 84 d0 00 00 00    	je     101e88 <trap_dispatch+0xfa>
  101db8:	83 f8 78             	cmp    $0x78,%eax
  101dbb:	0f 87 ce 01 00 00    	ja     101f8f <trap_dispatch+0x201>
  101dc1:	83 f8 2f             	cmp    $0x2f,%eax
  101dc4:	0f 87 c5 01 00 00    	ja     101f8f <trap_dispatch+0x201>
  101dca:	83 f8 2e             	cmp    $0x2e,%eax
  101dcd:	0f 83 f1 01 00 00    	jae    101fc4 <trap_dispatch+0x236>
  101dd3:	83 f8 24             	cmp    $0x24,%eax
  101dd6:	74 5e                	je     101e36 <trap_dispatch+0xa8>
  101dd8:	83 f8 24             	cmp    $0x24,%eax
  101ddb:	0f 87 ae 01 00 00    	ja     101f8f <trap_dispatch+0x201>
  101de1:	83 f8 20             	cmp    $0x20,%eax
  101de4:	74 0a                	je     101df0 <trap_dispatch+0x62>
  101de6:	83 f8 21             	cmp    $0x21,%eax
  101de9:	74 74                	je     101e5f <trap_dispatch+0xd1>
  101deb:	e9 9f 01 00 00       	jmp    101f8f <trap_dispatch+0x201>
        /* handle the timer interrupt */
        /* (1) After a timer interrupt, you should record this event using a global variable (increase it), such as ticks in kern/driver/clock.c
         * (2) Every TICK_NUM cycle, you can print some info using a funciton, such as print_ticks().
         * (3) Too Simple? Yes, I think so!
         */
        ticks ++;
  101df0:	a1 24 c4 11 00       	mov    0x11c424,%eax
  101df5:	40                   	inc    %eax
  101df6:	a3 24 c4 11 00       	mov    %eax,0x11c424
        if (ticks % TICK_NUM == 0) {
  101dfb:	8b 0d 24 c4 11 00    	mov    0x11c424,%ecx
  101e01:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
  101e06:	89 c8                	mov    %ecx,%eax
  101e08:	f7 e2                	mul    %edx
  101e0a:	c1 ea 05             	shr    $0x5,%edx
  101e0d:	89 d0                	mov    %edx,%eax
  101e0f:	c1 e0 02             	shl    $0x2,%eax
  101e12:	01 d0                	add    %edx,%eax
  101e14:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  101e1b:	01 d0                	add    %edx,%eax
  101e1d:	c1 e0 02             	shl    $0x2,%eax
  101e20:	29 c1                	sub    %eax,%ecx
  101e22:	89 ca                	mov    %ecx,%edx
  101e24:	85 d2                	test   %edx,%edx
  101e26:	0f 85 9b 01 00 00    	jne    101fc7 <trap_dispatch+0x239>
            print_ticks();
  101e2c:	e8 f3 fa ff ff       	call   101924 <print_ticks>
        }
        break;
  101e31:	e9 91 01 00 00       	jmp    101fc7 <trap_dispatch+0x239>
    case IRQ_OFFSET + IRQ_COM1:
        c = cons_getc();
  101e36:	e8 8c f8 ff ff       	call   1016c7 <cons_getc>
  101e3b:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("serial [%03d] %c\n", c, c);
  101e3e:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e42:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e46:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e4e:	c7 04 24 69 67 10 00 	movl   $0x106769,(%esp)
  101e55:	e8 fc e4 ff ff       	call   100356 <cprintf>
        break;
  101e5a:	e9 6f 01 00 00       	jmp    101fce <trap_dispatch+0x240>
    case IRQ_OFFSET + IRQ_KBD:
        c = cons_getc();
  101e5f:	e8 63 f8 ff ff       	call   1016c7 <cons_getc>
  101e64:	88 45 f7             	mov    %al,-0x9(%ebp)
        cprintf("kbd [%03d] %c\n", c, c);
  101e67:	0f be 55 f7          	movsbl -0x9(%ebp),%edx
  101e6b:	0f be 45 f7          	movsbl -0x9(%ebp),%eax
  101e6f:	89 54 24 08          	mov    %edx,0x8(%esp)
  101e73:	89 44 24 04          	mov    %eax,0x4(%esp)
  101e77:	c7 04 24 7b 67 10 00 	movl   $0x10677b,(%esp)
  101e7e:	e8 d3 e4 ff ff       	call   100356 <cprintf>
        break;
  101e83:	e9 46 01 00 00       	jmp    101fce <trap_dispatch+0x240>
    //LAB1 CHALLENGE 1 : YOUR CODE you should modify below codes.
    case T_SWITCH_TOU:
        if (tf->tf_cs != USER_CS) {
  101e88:	8b 45 08             	mov    0x8(%ebp),%eax
  101e8b:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101e8f:	83 f8 1b             	cmp    $0x1b,%eax
  101e92:	0f 84 32 01 00 00    	je     101fca <trap_dispatch+0x23c>
            switchk2u = *tf;
  101e98:	8b 4d 08             	mov    0x8(%ebp),%ecx
  101e9b:	b8 4c 00 00 00       	mov    $0x4c,%eax
  101ea0:	83 e0 fc             	and    $0xfffffffc,%eax
  101ea3:	89 c3                	mov    %eax,%ebx
  101ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  101eaa:	8b 14 01             	mov    (%ecx,%eax,1),%edx
  101ead:	89 90 80 c6 11 00    	mov    %edx,0x11c680(%eax)
  101eb3:	83 c0 04             	add    $0x4,%eax
  101eb6:	39 d8                	cmp    %ebx,%eax
  101eb8:	72 f0                	jb     101eaa <trap_dispatch+0x11c>
            switchk2u.tf_cs = USER_CS;
  101eba:	66 c7 05 bc c6 11 00 	movw   $0x1b,0x11c6bc
  101ec1:	1b 00 
            switchk2u.tf_ds = switchk2u.tf_es = switchk2u.tf_ss = USER_DS;
  101ec3:	66 c7 05 c8 c6 11 00 	movw   $0x23,0x11c6c8
  101eca:	23 00 
  101ecc:	0f b7 05 c8 c6 11 00 	movzwl 0x11c6c8,%eax
  101ed3:	66 a3 a8 c6 11 00    	mov    %ax,0x11c6a8
  101ed9:	0f b7 05 a8 c6 11 00 	movzwl 0x11c6a8,%eax
  101ee0:	66 a3 ac c6 11 00    	mov    %ax,0x11c6ac
            switchk2u.tf_esp = (uint32_t)tf + sizeof(struct trapframe) - 8;
  101ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  101ee9:	83 c0 44             	add    $0x44,%eax
  101eec:	a3 c4 c6 11 00       	mov    %eax,0x11c6c4
		
            // set eflags, make sure ucore can use io under user mode.
            // if CPL > IOPL, then cpu will generate a general protection.
            switchk2u.tf_eflags |= FL_IOPL_MASK;
  101ef1:	a1 c0 c6 11 00       	mov    0x11c6c0,%eax
  101ef6:	0d 00 30 00 00       	or     $0x3000,%eax
  101efb:	a3 c0 c6 11 00       	mov    %eax,0x11c6c0
		
            // set temporary stack
            // then iret will jump to the right stack
            *((uint32_t *)tf - 1) = (uint32_t)&switchk2u;
  101f00:	8b 45 08             	mov    0x8(%ebp),%eax
  101f03:	83 e8 04             	sub    $0x4,%eax
  101f06:	ba 80 c6 11 00       	mov    $0x11c680,%edx
  101f0b:	89 10                	mov    %edx,(%eax)
        }
        break;
  101f0d:	e9 b8 00 00 00       	jmp    101fca <trap_dispatch+0x23c>
    case T_SWITCH_TOK:
        if (tf->tf_cs != KERNEL_CS) {
  101f12:	8b 45 08             	mov    0x8(%ebp),%eax
  101f15:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f19:	83 f8 08             	cmp    $0x8,%eax
  101f1c:	0f 84 ab 00 00 00    	je     101fcd <trap_dispatch+0x23f>
            tf->tf_cs = KERNEL_CS;
  101f22:	8b 45 08             	mov    0x8(%ebp),%eax
  101f25:	66 c7 40 3c 08 00    	movw   $0x8,0x3c(%eax)
            tf->tf_ds = tf->tf_es = KERNEL_DS;
  101f2b:	8b 45 08             	mov    0x8(%ebp),%eax
  101f2e:	66 c7 40 28 10 00    	movw   $0x10,0x28(%eax)
  101f34:	8b 45 08             	mov    0x8(%ebp),%eax
  101f37:	0f b7 50 28          	movzwl 0x28(%eax),%edx
  101f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  101f3e:	66 89 50 2c          	mov    %dx,0x2c(%eax)
            tf->tf_eflags &= ~FL_IOPL_MASK;
  101f42:	8b 45 08             	mov    0x8(%ebp),%eax
  101f45:	8b 40 40             	mov    0x40(%eax),%eax
  101f48:	25 ff cf ff ff       	and    $0xffffcfff,%eax
  101f4d:	89 c2                	mov    %eax,%edx
  101f4f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f52:	89 50 40             	mov    %edx,0x40(%eax)
            switchu2k = (struct trapframe *)(tf->tf_esp - (sizeof(struct trapframe) - 8));
  101f55:	8b 45 08             	mov    0x8(%ebp),%eax
  101f58:	8b 40 44             	mov    0x44(%eax),%eax
  101f5b:	83 e8 44             	sub    $0x44,%eax
  101f5e:	a3 cc c6 11 00       	mov    %eax,0x11c6cc
            memmove(switchu2k, tf, sizeof(struct trapframe) - 8);
  101f63:	a1 cc c6 11 00       	mov    0x11c6cc,%eax
  101f68:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
  101f6f:	00 
  101f70:	8b 55 08             	mov    0x8(%ebp),%edx
  101f73:	89 54 24 04          	mov    %edx,0x4(%esp)
  101f77:	89 04 24             	mov    %eax,(%esp)
  101f7a:	e8 34 41 00 00       	call   1060b3 <memmove>
            *((uint32_t *)tf - 1) = (uint32_t)switchu2k;
  101f7f:	8b 15 cc c6 11 00    	mov    0x11c6cc,%edx
  101f85:	8b 45 08             	mov    0x8(%ebp),%eax
  101f88:	83 e8 04             	sub    $0x4,%eax
  101f8b:	89 10                	mov    %edx,(%eax)
        }
        break;
  101f8d:	eb 3e                	jmp    101fcd <trap_dispatch+0x23f>
    case IRQ_OFFSET + IRQ_IDE2:
        /* do nothing */
        break;
    default:
        // in kernel, it must be a mistake
        if ((tf->tf_cs & 3) == 0) {
  101f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  101f92:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
  101f96:	83 e0 03             	and    $0x3,%eax
  101f99:	85 c0                	test   %eax,%eax
  101f9b:	75 31                	jne    101fce <trap_dispatch+0x240>
            print_trapframe(tf);
  101f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  101fa0:	89 04 24             	mov    %eax,(%esp)
  101fa3:	e8 79 fb ff ff       	call   101b21 <print_trapframe>
            panic("unexpected trap in kernel.\n");
  101fa8:	c7 44 24 08 8a 67 10 	movl   $0x10678a,0x8(%esp)
  101faf:	00 
  101fb0:	c7 44 24 04 d2 00 00 	movl   $0xd2,0x4(%esp)
  101fb7:	00 
  101fb8:	c7 04 24 ae 65 10 00 	movl   $0x1065ae,(%esp)
  101fbf:	e8 23 ed ff ff       	call   100ce7 <__panic>
        break;
  101fc4:	90                   	nop
  101fc5:	eb 07                	jmp    101fce <trap_dispatch+0x240>
        break;
  101fc7:	90                   	nop
  101fc8:	eb 04                	jmp    101fce <trap_dispatch+0x240>
        break;
  101fca:	90                   	nop
  101fcb:	eb 01                	jmp    101fce <trap_dispatch+0x240>
        break;
  101fcd:	90                   	nop
        }
    }
}
  101fce:	90                   	nop
  101fcf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  101fd2:	89 ec                	mov    %ebp,%esp
  101fd4:	5d                   	pop    %ebp
  101fd5:	c3                   	ret    

00101fd6 <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
  101fd6:	55                   	push   %ebp
  101fd7:	89 e5                	mov    %esp,%ebp
  101fd9:	83 ec 18             	sub    $0x18,%esp
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
  101fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  101fdf:	89 04 24             	mov    %eax,(%esp)
  101fe2:	e8 a7 fd ff ff       	call   101d8e <trap_dispatch>
}
  101fe7:	90                   	nop
  101fe8:	89 ec                	mov    %ebp,%esp
  101fea:	5d                   	pop    %ebp
  101feb:	c3                   	ret    

00101fec <__alltraps>:
.text
.globl __alltraps
__alltraps:
    # push registers to build a trap frame
    # therefore make the stack look like a struct trapframe
    pushl %ds
  101fec:	1e                   	push   %ds
    pushl %es
  101fed:	06                   	push   %es
    pushl %fs
  101fee:	0f a0                	push   %fs
    pushl %gs
  101ff0:	0f a8                	push   %gs
    pushal
  101ff2:	60                   	pusha  

    # load GD_KDATA into %ds and %es to set up data segments for kernel
    movl $GD_KDATA, %eax
  101ff3:	b8 10 00 00 00       	mov    $0x10,%eax
    movw %ax, %ds
  101ff8:	8e d8                	mov    %eax,%ds
    movw %ax, %es
  101ffa:	8e c0                	mov    %eax,%es

    # push %esp to pass a pointer to the trapframe as an argument to trap()
    pushl %esp
  101ffc:	54                   	push   %esp

    # call trap(tf), where tf=%esp
    call trap
  101ffd:	e8 d4 ff ff ff       	call   101fd6 <trap>

    # pop the pushed stack pointer
    popl %esp
  102002:	5c                   	pop    %esp

00102003 <__trapret>:

    # return falls through to trapret...
.globl __trapret
__trapret:
    # restore registers from stack
    popal
  102003:	61                   	popa   

    # restore %ds, %es, %fs and %gs
    popl %gs
  102004:	0f a9                	pop    %gs
    popl %fs
  102006:	0f a1                	pop    %fs
    popl %es
  102008:	07                   	pop    %es
    popl %ds
  102009:	1f                   	pop    %ds

    # get rid of the trap number and error code
    addl $0x8, %esp
  10200a:	83 c4 08             	add    $0x8,%esp
    iret
  10200d:	cf                   	iret   

0010200e <vector0>:
# handler
.text
.globl __alltraps
.globl vector0
vector0:
  pushl $0
  10200e:	6a 00                	push   $0x0
  pushl $0
  102010:	6a 00                	push   $0x0
  jmp __alltraps
  102012:	e9 d5 ff ff ff       	jmp    101fec <__alltraps>

00102017 <vector1>:
.globl vector1
vector1:
  pushl $0
  102017:	6a 00                	push   $0x0
  pushl $1
  102019:	6a 01                	push   $0x1
  jmp __alltraps
  10201b:	e9 cc ff ff ff       	jmp    101fec <__alltraps>

00102020 <vector2>:
.globl vector2
vector2:
  pushl $0
  102020:	6a 00                	push   $0x0
  pushl $2
  102022:	6a 02                	push   $0x2
  jmp __alltraps
  102024:	e9 c3 ff ff ff       	jmp    101fec <__alltraps>

00102029 <vector3>:
.globl vector3
vector3:
  pushl $0
  102029:	6a 00                	push   $0x0
  pushl $3
  10202b:	6a 03                	push   $0x3
  jmp __alltraps
  10202d:	e9 ba ff ff ff       	jmp    101fec <__alltraps>

00102032 <vector4>:
.globl vector4
vector4:
  pushl $0
  102032:	6a 00                	push   $0x0
  pushl $4
  102034:	6a 04                	push   $0x4
  jmp __alltraps
  102036:	e9 b1 ff ff ff       	jmp    101fec <__alltraps>

0010203b <vector5>:
.globl vector5
vector5:
  pushl $0
  10203b:	6a 00                	push   $0x0
  pushl $5
  10203d:	6a 05                	push   $0x5
  jmp __alltraps
  10203f:	e9 a8 ff ff ff       	jmp    101fec <__alltraps>

00102044 <vector6>:
.globl vector6
vector6:
  pushl $0
  102044:	6a 00                	push   $0x0
  pushl $6
  102046:	6a 06                	push   $0x6
  jmp __alltraps
  102048:	e9 9f ff ff ff       	jmp    101fec <__alltraps>

0010204d <vector7>:
.globl vector7
vector7:
  pushl $0
  10204d:	6a 00                	push   $0x0
  pushl $7
  10204f:	6a 07                	push   $0x7
  jmp __alltraps
  102051:	e9 96 ff ff ff       	jmp    101fec <__alltraps>

00102056 <vector8>:
.globl vector8
vector8:
  pushl $8
  102056:	6a 08                	push   $0x8
  jmp __alltraps
  102058:	e9 8f ff ff ff       	jmp    101fec <__alltraps>

0010205d <vector9>:
.globl vector9
vector9:
  pushl $0
  10205d:	6a 00                	push   $0x0
  pushl $9
  10205f:	6a 09                	push   $0x9
  jmp __alltraps
  102061:	e9 86 ff ff ff       	jmp    101fec <__alltraps>

00102066 <vector10>:
.globl vector10
vector10:
  pushl $10
  102066:	6a 0a                	push   $0xa
  jmp __alltraps
  102068:	e9 7f ff ff ff       	jmp    101fec <__alltraps>

0010206d <vector11>:
.globl vector11
vector11:
  pushl $11
  10206d:	6a 0b                	push   $0xb
  jmp __alltraps
  10206f:	e9 78 ff ff ff       	jmp    101fec <__alltraps>

00102074 <vector12>:
.globl vector12
vector12:
  pushl $12
  102074:	6a 0c                	push   $0xc
  jmp __alltraps
  102076:	e9 71 ff ff ff       	jmp    101fec <__alltraps>

0010207b <vector13>:
.globl vector13
vector13:
  pushl $13
  10207b:	6a 0d                	push   $0xd
  jmp __alltraps
  10207d:	e9 6a ff ff ff       	jmp    101fec <__alltraps>

00102082 <vector14>:
.globl vector14
vector14:
  pushl $14
  102082:	6a 0e                	push   $0xe
  jmp __alltraps
  102084:	e9 63 ff ff ff       	jmp    101fec <__alltraps>

00102089 <vector15>:
.globl vector15
vector15:
  pushl $0
  102089:	6a 00                	push   $0x0
  pushl $15
  10208b:	6a 0f                	push   $0xf
  jmp __alltraps
  10208d:	e9 5a ff ff ff       	jmp    101fec <__alltraps>

00102092 <vector16>:
.globl vector16
vector16:
  pushl $0
  102092:	6a 00                	push   $0x0
  pushl $16
  102094:	6a 10                	push   $0x10
  jmp __alltraps
  102096:	e9 51 ff ff ff       	jmp    101fec <__alltraps>

0010209b <vector17>:
.globl vector17
vector17:
  pushl $17
  10209b:	6a 11                	push   $0x11
  jmp __alltraps
  10209d:	e9 4a ff ff ff       	jmp    101fec <__alltraps>

001020a2 <vector18>:
.globl vector18
vector18:
  pushl $0
  1020a2:	6a 00                	push   $0x0
  pushl $18
  1020a4:	6a 12                	push   $0x12
  jmp __alltraps
  1020a6:	e9 41 ff ff ff       	jmp    101fec <__alltraps>

001020ab <vector19>:
.globl vector19
vector19:
  pushl $0
  1020ab:	6a 00                	push   $0x0
  pushl $19
  1020ad:	6a 13                	push   $0x13
  jmp __alltraps
  1020af:	e9 38 ff ff ff       	jmp    101fec <__alltraps>

001020b4 <vector20>:
.globl vector20
vector20:
  pushl $0
  1020b4:	6a 00                	push   $0x0
  pushl $20
  1020b6:	6a 14                	push   $0x14
  jmp __alltraps
  1020b8:	e9 2f ff ff ff       	jmp    101fec <__alltraps>

001020bd <vector21>:
.globl vector21
vector21:
  pushl $0
  1020bd:	6a 00                	push   $0x0
  pushl $21
  1020bf:	6a 15                	push   $0x15
  jmp __alltraps
  1020c1:	e9 26 ff ff ff       	jmp    101fec <__alltraps>

001020c6 <vector22>:
.globl vector22
vector22:
  pushl $0
  1020c6:	6a 00                	push   $0x0
  pushl $22
  1020c8:	6a 16                	push   $0x16
  jmp __alltraps
  1020ca:	e9 1d ff ff ff       	jmp    101fec <__alltraps>

001020cf <vector23>:
.globl vector23
vector23:
  pushl $0
  1020cf:	6a 00                	push   $0x0
  pushl $23
  1020d1:	6a 17                	push   $0x17
  jmp __alltraps
  1020d3:	e9 14 ff ff ff       	jmp    101fec <__alltraps>

001020d8 <vector24>:
.globl vector24
vector24:
  pushl $0
  1020d8:	6a 00                	push   $0x0
  pushl $24
  1020da:	6a 18                	push   $0x18
  jmp __alltraps
  1020dc:	e9 0b ff ff ff       	jmp    101fec <__alltraps>

001020e1 <vector25>:
.globl vector25
vector25:
  pushl $0
  1020e1:	6a 00                	push   $0x0
  pushl $25
  1020e3:	6a 19                	push   $0x19
  jmp __alltraps
  1020e5:	e9 02 ff ff ff       	jmp    101fec <__alltraps>

001020ea <vector26>:
.globl vector26
vector26:
  pushl $0
  1020ea:	6a 00                	push   $0x0
  pushl $26
  1020ec:	6a 1a                	push   $0x1a
  jmp __alltraps
  1020ee:	e9 f9 fe ff ff       	jmp    101fec <__alltraps>

001020f3 <vector27>:
.globl vector27
vector27:
  pushl $0
  1020f3:	6a 00                	push   $0x0
  pushl $27
  1020f5:	6a 1b                	push   $0x1b
  jmp __alltraps
  1020f7:	e9 f0 fe ff ff       	jmp    101fec <__alltraps>

001020fc <vector28>:
.globl vector28
vector28:
  pushl $0
  1020fc:	6a 00                	push   $0x0
  pushl $28
  1020fe:	6a 1c                	push   $0x1c
  jmp __alltraps
  102100:	e9 e7 fe ff ff       	jmp    101fec <__alltraps>

00102105 <vector29>:
.globl vector29
vector29:
  pushl $0
  102105:	6a 00                	push   $0x0
  pushl $29
  102107:	6a 1d                	push   $0x1d
  jmp __alltraps
  102109:	e9 de fe ff ff       	jmp    101fec <__alltraps>

0010210e <vector30>:
.globl vector30
vector30:
  pushl $0
  10210e:	6a 00                	push   $0x0
  pushl $30
  102110:	6a 1e                	push   $0x1e
  jmp __alltraps
  102112:	e9 d5 fe ff ff       	jmp    101fec <__alltraps>

00102117 <vector31>:
.globl vector31
vector31:
  pushl $0
  102117:	6a 00                	push   $0x0
  pushl $31
  102119:	6a 1f                	push   $0x1f
  jmp __alltraps
  10211b:	e9 cc fe ff ff       	jmp    101fec <__alltraps>

00102120 <vector32>:
.globl vector32
vector32:
  pushl $0
  102120:	6a 00                	push   $0x0
  pushl $32
  102122:	6a 20                	push   $0x20
  jmp __alltraps
  102124:	e9 c3 fe ff ff       	jmp    101fec <__alltraps>

00102129 <vector33>:
.globl vector33
vector33:
  pushl $0
  102129:	6a 00                	push   $0x0
  pushl $33
  10212b:	6a 21                	push   $0x21
  jmp __alltraps
  10212d:	e9 ba fe ff ff       	jmp    101fec <__alltraps>

00102132 <vector34>:
.globl vector34
vector34:
  pushl $0
  102132:	6a 00                	push   $0x0
  pushl $34
  102134:	6a 22                	push   $0x22
  jmp __alltraps
  102136:	e9 b1 fe ff ff       	jmp    101fec <__alltraps>

0010213b <vector35>:
.globl vector35
vector35:
  pushl $0
  10213b:	6a 00                	push   $0x0
  pushl $35
  10213d:	6a 23                	push   $0x23
  jmp __alltraps
  10213f:	e9 a8 fe ff ff       	jmp    101fec <__alltraps>

00102144 <vector36>:
.globl vector36
vector36:
  pushl $0
  102144:	6a 00                	push   $0x0
  pushl $36
  102146:	6a 24                	push   $0x24
  jmp __alltraps
  102148:	e9 9f fe ff ff       	jmp    101fec <__alltraps>

0010214d <vector37>:
.globl vector37
vector37:
  pushl $0
  10214d:	6a 00                	push   $0x0
  pushl $37
  10214f:	6a 25                	push   $0x25
  jmp __alltraps
  102151:	e9 96 fe ff ff       	jmp    101fec <__alltraps>

00102156 <vector38>:
.globl vector38
vector38:
  pushl $0
  102156:	6a 00                	push   $0x0
  pushl $38
  102158:	6a 26                	push   $0x26
  jmp __alltraps
  10215a:	e9 8d fe ff ff       	jmp    101fec <__alltraps>

0010215f <vector39>:
.globl vector39
vector39:
  pushl $0
  10215f:	6a 00                	push   $0x0
  pushl $39
  102161:	6a 27                	push   $0x27
  jmp __alltraps
  102163:	e9 84 fe ff ff       	jmp    101fec <__alltraps>

00102168 <vector40>:
.globl vector40
vector40:
  pushl $0
  102168:	6a 00                	push   $0x0
  pushl $40
  10216a:	6a 28                	push   $0x28
  jmp __alltraps
  10216c:	e9 7b fe ff ff       	jmp    101fec <__alltraps>

00102171 <vector41>:
.globl vector41
vector41:
  pushl $0
  102171:	6a 00                	push   $0x0
  pushl $41
  102173:	6a 29                	push   $0x29
  jmp __alltraps
  102175:	e9 72 fe ff ff       	jmp    101fec <__alltraps>

0010217a <vector42>:
.globl vector42
vector42:
  pushl $0
  10217a:	6a 00                	push   $0x0
  pushl $42
  10217c:	6a 2a                	push   $0x2a
  jmp __alltraps
  10217e:	e9 69 fe ff ff       	jmp    101fec <__alltraps>

00102183 <vector43>:
.globl vector43
vector43:
  pushl $0
  102183:	6a 00                	push   $0x0
  pushl $43
  102185:	6a 2b                	push   $0x2b
  jmp __alltraps
  102187:	e9 60 fe ff ff       	jmp    101fec <__alltraps>

0010218c <vector44>:
.globl vector44
vector44:
  pushl $0
  10218c:	6a 00                	push   $0x0
  pushl $44
  10218e:	6a 2c                	push   $0x2c
  jmp __alltraps
  102190:	e9 57 fe ff ff       	jmp    101fec <__alltraps>

00102195 <vector45>:
.globl vector45
vector45:
  pushl $0
  102195:	6a 00                	push   $0x0
  pushl $45
  102197:	6a 2d                	push   $0x2d
  jmp __alltraps
  102199:	e9 4e fe ff ff       	jmp    101fec <__alltraps>

0010219e <vector46>:
.globl vector46
vector46:
  pushl $0
  10219e:	6a 00                	push   $0x0
  pushl $46
  1021a0:	6a 2e                	push   $0x2e
  jmp __alltraps
  1021a2:	e9 45 fe ff ff       	jmp    101fec <__alltraps>

001021a7 <vector47>:
.globl vector47
vector47:
  pushl $0
  1021a7:	6a 00                	push   $0x0
  pushl $47
  1021a9:	6a 2f                	push   $0x2f
  jmp __alltraps
  1021ab:	e9 3c fe ff ff       	jmp    101fec <__alltraps>

001021b0 <vector48>:
.globl vector48
vector48:
  pushl $0
  1021b0:	6a 00                	push   $0x0
  pushl $48
  1021b2:	6a 30                	push   $0x30
  jmp __alltraps
  1021b4:	e9 33 fe ff ff       	jmp    101fec <__alltraps>

001021b9 <vector49>:
.globl vector49
vector49:
  pushl $0
  1021b9:	6a 00                	push   $0x0
  pushl $49
  1021bb:	6a 31                	push   $0x31
  jmp __alltraps
  1021bd:	e9 2a fe ff ff       	jmp    101fec <__alltraps>

001021c2 <vector50>:
.globl vector50
vector50:
  pushl $0
  1021c2:	6a 00                	push   $0x0
  pushl $50
  1021c4:	6a 32                	push   $0x32
  jmp __alltraps
  1021c6:	e9 21 fe ff ff       	jmp    101fec <__alltraps>

001021cb <vector51>:
.globl vector51
vector51:
  pushl $0
  1021cb:	6a 00                	push   $0x0
  pushl $51
  1021cd:	6a 33                	push   $0x33
  jmp __alltraps
  1021cf:	e9 18 fe ff ff       	jmp    101fec <__alltraps>

001021d4 <vector52>:
.globl vector52
vector52:
  pushl $0
  1021d4:	6a 00                	push   $0x0
  pushl $52
  1021d6:	6a 34                	push   $0x34
  jmp __alltraps
  1021d8:	e9 0f fe ff ff       	jmp    101fec <__alltraps>

001021dd <vector53>:
.globl vector53
vector53:
  pushl $0
  1021dd:	6a 00                	push   $0x0
  pushl $53
  1021df:	6a 35                	push   $0x35
  jmp __alltraps
  1021e1:	e9 06 fe ff ff       	jmp    101fec <__alltraps>

001021e6 <vector54>:
.globl vector54
vector54:
  pushl $0
  1021e6:	6a 00                	push   $0x0
  pushl $54
  1021e8:	6a 36                	push   $0x36
  jmp __alltraps
  1021ea:	e9 fd fd ff ff       	jmp    101fec <__alltraps>

001021ef <vector55>:
.globl vector55
vector55:
  pushl $0
  1021ef:	6a 00                	push   $0x0
  pushl $55
  1021f1:	6a 37                	push   $0x37
  jmp __alltraps
  1021f3:	e9 f4 fd ff ff       	jmp    101fec <__alltraps>

001021f8 <vector56>:
.globl vector56
vector56:
  pushl $0
  1021f8:	6a 00                	push   $0x0
  pushl $56
  1021fa:	6a 38                	push   $0x38
  jmp __alltraps
  1021fc:	e9 eb fd ff ff       	jmp    101fec <__alltraps>

00102201 <vector57>:
.globl vector57
vector57:
  pushl $0
  102201:	6a 00                	push   $0x0
  pushl $57
  102203:	6a 39                	push   $0x39
  jmp __alltraps
  102205:	e9 e2 fd ff ff       	jmp    101fec <__alltraps>

0010220a <vector58>:
.globl vector58
vector58:
  pushl $0
  10220a:	6a 00                	push   $0x0
  pushl $58
  10220c:	6a 3a                	push   $0x3a
  jmp __alltraps
  10220e:	e9 d9 fd ff ff       	jmp    101fec <__alltraps>

00102213 <vector59>:
.globl vector59
vector59:
  pushl $0
  102213:	6a 00                	push   $0x0
  pushl $59
  102215:	6a 3b                	push   $0x3b
  jmp __alltraps
  102217:	e9 d0 fd ff ff       	jmp    101fec <__alltraps>

0010221c <vector60>:
.globl vector60
vector60:
  pushl $0
  10221c:	6a 00                	push   $0x0
  pushl $60
  10221e:	6a 3c                	push   $0x3c
  jmp __alltraps
  102220:	e9 c7 fd ff ff       	jmp    101fec <__alltraps>

00102225 <vector61>:
.globl vector61
vector61:
  pushl $0
  102225:	6a 00                	push   $0x0
  pushl $61
  102227:	6a 3d                	push   $0x3d
  jmp __alltraps
  102229:	e9 be fd ff ff       	jmp    101fec <__alltraps>

0010222e <vector62>:
.globl vector62
vector62:
  pushl $0
  10222e:	6a 00                	push   $0x0
  pushl $62
  102230:	6a 3e                	push   $0x3e
  jmp __alltraps
  102232:	e9 b5 fd ff ff       	jmp    101fec <__alltraps>

00102237 <vector63>:
.globl vector63
vector63:
  pushl $0
  102237:	6a 00                	push   $0x0
  pushl $63
  102239:	6a 3f                	push   $0x3f
  jmp __alltraps
  10223b:	e9 ac fd ff ff       	jmp    101fec <__alltraps>

00102240 <vector64>:
.globl vector64
vector64:
  pushl $0
  102240:	6a 00                	push   $0x0
  pushl $64
  102242:	6a 40                	push   $0x40
  jmp __alltraps
  102244:	e9 a3 fd ff ff       	jmp    101fec <__alltraps>

00102249 <vector65>:
.globl vector65
vector65:
  pushl $0
  102249:	6a 00                	push   $0x0
  pushl $65
  10224b:	6a 41                	push   $0x41
  jmp __alltraps
  10224d:	e9 9a fd ff ff       	jmp    101fec <__alltraps>

00102252 <vector66>:
.globl vector66
vector66:
  pushl $0
  102252:	6a 00                	push   $0x0
  pushl $66
  102254:	6a 42                	push   $0x42
  jmp __alltraps
  102256:	e9 91 fd ff ff       	jmp    101fec <__alltraps>

0010225b <vector67>:
.globl vector67
vector67:
  pushl $0
  10225b:	6a 00                	push   $0x0
  pushl $67
  10225d:	6a 43                	push   $0x43
  jmp __alltraps
  10225f:	e9 88 fd ff ff       	jmp    101fec <__alltraps>

00102264 <vector68>:
.globl vector68
vector68:
  pushl $0
  102264:	6a 00                	push   $0x0
  pushl $68
  102266:	6a 44                	push   $0x44
  jmp __alltraps
  102268:	e9 7f fd ff ff       	jmp    101fec <__alltraps>

0010226d <vector69>:
.globl vector69
vector69:
  pushl $0
  10226d:	6a 00                	push   $0x0
  pushl $69
  10226f:	6a 45                	push   $0x45
  jmp __alltraps
  102271:	e9 76 fd ff ff       	jmp    101fec <__alltraps>

00102276 <vector70>:
.globl vector70
vector70:
  pushl $0
  102276:	6a 00                	push   $0x0
  pushl $70
  102278:	6a 46                	push   $0x46
  jmp __alltraps
  10227a:	e9 6d fd ff ff       	jmp    101fec <__alltraps>

0010227f <vector71>:
.globl vector71
vector71:
  pushl $0
  10227f:	6a 00                	push   $0x0
  pushl $71
  102281:	6a 47                	push   $0x47
  jmp __alltraps
  102283:	e9 64 fd ff ff       	jmp    101fec <__alltraps>

00102288 <vector72>:
.globl vector72
vector72:
  pushl $0
  102288:	6a 00                	push   $0x0
  pushl $72
  10228a:	6a 48                	push   $0x48
  jmp __alltraps
  10228c:	e9 5b fd ff ff       	jmp    101fec <__alltraps>

00102291 <vector73>:
.globl vector73
vector73:
  pushl $0
  102291:	6a 00                	push   $0x0
  pushl $73
  102293:	6a 49                	push   $0x49
  jmp __alltraps
  102295:	e9 52 fd ff ff       	jmp    101fec <__alltraps>

0010229a <vector74>:
.globl vector74
vector74:
  pushl $0
  10229a:	6a 00                	push   $0x0
  pushl $74
  10229c:	6a 4a                	push   $0x4a
  jmp __alltraps
  10229e:	e9 49 fd ff ff       	jmp    101fec <__alltraps>

001022a3 <vector75>:
.globl vector75
vector75:
  pushl $0
  1022a3:	6a 00                	push   $0x0
  pushl $75
  1022a5:	6a 4b                	push   $0x4b
  jmp __alltraps
  1022a7:	e9 40 fd ff ff       	jmp    101fec <__alltraps>

001022ac <vector76>:
.globl vector76
vector76:
  pushl $0
  1022ac:	6a 00                	push   $0x0
  pushl $76
  1022ae:	6a 4c                	push   $0x4c
  jmp __alltraps
  1022b0:	e9 37 fd ff ff       	jmp    101fec <__alltraps>

001022b5 <vector77>:
.globl vector77
vector77:
  pushl $0
  1022b5:	6a 00                	push   $0x0
  pushl $77
  1022b7:	6a 4d                	push   $0x4d
  jmp __alltraps
  1022b9:	e9 2e fd ff ff       	jmp    101fec <__alltraps>

001022be <vector78>:
.globl vector78
vector78:
  pushl $0
  1022be:	6a 00                	push   $0x0
  pushl $78
  1022c0:	6a 4e                	push   $0x4e
  jmp __alltraps
  1022c2:	e9 25 fd ff ff       	jmp    101fec <__alltraps>

001022c7 <vector79>:
.globl vector79
vector79:
  pushl $0
  1022c7:	6a 00                	push   $0x0
  pushl $79
  1022c9:	6a 4f                	push   $0x4f
  jmp __alltraps
  1022cb:	e9 1c fd ff ff       	jmp    101fec <__alltraps>

001022d0 <vector80>:
.globl vector80
vector80:
  pushl $0
  1022d0:	6a 00                	push   $0x0
  pushl $80
  1022d2:	6a 50                	push   $0x50
  jmp __alltraps
  1022d4:	e9 13 fd ff ff       	jmp    101fec <__alltraps>

001022d9 <vector81>:
.globl vector81
vector81:
  pushl $0
  1022d9:	6a 00                	push   $0x0
  pushl $81
  1022db:	6a 51                	push   $0x51
  jmp __alltraps
  1022dd:	e9 0a fd ff ff       	jmp    101fec <__alltraps>

001022e2 <vector82>:
.globl vector82
vector82:
  pushl $0
  1022e2:	6a 00                	push   $0x0
  pushl $82
  1022e4:	6a 52                	push   $0x52
  jmp __alltraps
  1022e6:	e9 01 fd ff ff       	jmp    101fec <__alltraps>

001022eb <vector83>:
.globl vector83
vector83:
  pushl $0
  1022eb:	6a 00                	push   $0x0
  pushl $83
  1022ed:	6a 53                	push   $0x53
  jmp __alltraps
  1022ef:	e9 f8 fc ff ff       	jmp    101fec <__alltraps>

001022f4 <vector84>:
.globl vector84
vector84:
  pushl $0
  1022f4:	6a 00                	push   $0x0
  pushl $84
  1022f6:	6a 54                	push   $0x54
  jmp __alltraps
  1022f8:	e9 ef fc ff ff       	jmp    101fec <__alltraps>

001022fd <vector85>:
.globl vector85
vector85:
  pushl $0
  1022fd:	6a 00                	push   $0x0
  pushl $85
  1022ff:	6a 55                	push   $0x55
  jmp __alltraps
  102301:	e9 e6 fc ff ff       	jmp    101fec <__alltraps>

00102306 <vector86>:
.globl vector86
vector86:
  pushl $0
  102306:	6a 00                	push   $0x0
  pushl $86
  102308:	6a 56                	push   $0x56
  jmp __alltraps
  10230a:	e9 dd fc ff ff       	jmp    101fec <__alltraps>

0010230f <vector87>:
.globl vector87
vector87:
  pushl $0
  10230f:	6a 00                	push   $0x0
  pushl $87
  102311:	6a 57                	push   $0x57
  jmp __alltraps
  102313:	e9 d4 fc ff ff       	jmp    101fec <__alltraps>

00102318 <vector88>:
.globl vector88
vector88:
  pushl $0
  102318:	6a 00                	push   $0x0
  pushl $88
  10231a:	6a 58                	push   $0x58
  jmp __alltraps
  10231c:	e9 cb fc ff ff       	jmp    101fec <__alltraps>

00102321 <vector89>:
.globl vector89
vector89:
  pushl $0
  102321:	6a 00                	push   $0x0
  pushl $89
  102323:	6a 59                	push   $0x59
  jmp __alltraps
  102325:	e9 c2 fc ff ff       	jmp    101fec <__alltraps>

0010232a <vector90>:
.globl vector90
vector90:
  pushl $0
  10232a:	6a 00                	push   $0x0
  pushl $90
  10232c:	6a 5a                	push   $0x5a
  jmp __alltraps
  10232e:	e9 b9 fc ff ff       	jmp    101fec <__alltraps>

00102333 <vector91>:
.globl vector91
vector91:
  pushl $0
  102333:	6a 00                	push   $0x0
  pushl $91
  102335:	6a 5b                	push   $0x5b
  jmp __alltraps
  102337:	e9 b0 fc ff ff       	jmp    101fec <__alltraps>

0010233c <vector92>:
.globl vector92
vector92:
  pushl $0
  10233c:	6a 00                	push   $0x0
  pushl $92
  10233e:	6a 5c                	push   $0x5c
  jmp __alltraps
  102340:	e9 a7 fc ff ff       	jmp    101fec <__alltraps>

00102345 <vector93>:
.globl vector93
vector93:
  pushl $0
  102345:	6a 00                	push   $0x0
  pushl $93
  102347:	6a 5d                	push   $0x5d
  jmp __alltraps
  102349:	e9 9e fc ff ff       	jmp    101fec <__alltraps>

0010234e <vector94>:
.globl vector94
vector94:
  pushl $0
  10234e:	6a 00                	push   $0x0
  pushl $94
  102350:	6a 5e                	push   $0x5e
  jmp __alltraps
  102352:	e9 95 fc ff ff       	jmp    101fec <__alltraps>

00102357 <vector95>:
.globl vector95
vector95:
  pushl $0
  102357:	6a 00                	push   $0x0
  pushl $95
  102359:	6a 5f                	push   $0x5f
  jmp __alltraps
  10235b:	e9 8c fc ff ff       	jmp    101fec <__alltraps>

00102360 <vector96>:
.globl vector96
vector96:
  pushl $0
  102360:	6a 00                	push   $0x0
  pushl $96
  102362:	6a 60                	push   $0x60
  jmp __alltraps
  102364:	e9 83 fc ff ff       	jmp    101fec <__alltraps>

00102369 <vector97>:
.globl vector97
vector97:
  pushl $0
  102369:	6a 00                	push   $0x0
  pushl $97
  10236b:	6a 61                	push   $0x61
  jmp __alltraps
  10236d:	e9 7a fc ff ff       	jmp    101fec <__alltraps>

00102372 <vector98>:
.globl vector98
vector98:
  pushl $0
  102372:	6a 00                	push   $0x0
  pushl $98
  102374:	6a 62                	push   $0x62
  jmp __alltraps
  102376:	e9 71 fc ff ff       	jmp    101fec <__alltraps>

0010237b <vector99>:
.globl vector99
vector99:
  pushl $0
  10237b:	6a 00                	push   $0x0
  pushl $99
  10237d:	6a 63                	push   $0x63
  jmp __alltraps
  10237f:	e9 68 fc ff ff       	jmp    101fec <__alltraps>

00102384 <vector100>:
.globl vector100
vector100:
  pushl $0
  102384:	6a 00                	push   $0x0
  pushl $100
  102386:	6a 64                	push   $0x64
  jmp __alltraps
  102388:	e9 5f fc ff ff       	jmp    101fec <__alltraps>

0010238d <vector101>:
.globl vector101
vector101:
  pushl $0
  10238d:	6a 00                	push   $0x0
  pushl $101
  10238f:	6a 65                	push   $0x65
  jmp __alltraps
  102391:	e9 56 fc ff ff       	jmp    101fec <__alltraps>

00102396 <vector102>:
.globl vector102
vector102:
  pushl $0
  102396:	6a 00                	push   $0x0
  pushl $102
  102398:	6a 66                	push   $0x66
  jmp __alltraps
  10239a:	e9 4d fc ff ff       	jmp    101fec <__alltraps>

0010239f <vector103>:
.globl vector103
vector103:
  pushl $0
  10239f:	6a 00                	push   $0x0
  pushl $103
  1023a1:	6a 67                	push   $0x67
  jmp __alltraps
  1023a3:	e9 44 fc ff ff       	jmp    101fec <__alltraps>

001023a8 <vector104>:
.globl vector104
vector104:
  pushl $0
  1023a8:	6a 00                	push   $0x0
  pushl $104
  1023aa:	6a 68                	push   $0x68
  jmp __alltraps
  1023ac:	e9 3b fc ff ff       	jmp    101fec <__alltraps>

001023b1 <vector105>:
.globl vector105
vector105:
  pushl $0
  1023b1:	6a 00                	push   $0x0
  pushl $105
  1023b3:	6a 69                	push   $0x69
  jmp __alltraps
  1023b5:	e9 32 fc ff ff       	jmp    101fec <__alltraps>

001023ba <vector106>:
.globl vector106
vector106:
  pushl $0
  1023ba:	6a 00                	push   $0x0
  pushl $106
  1023bc:	6a 6a                	push   $0x6a
  jmp __alltraps
  1023be:	e9 29 fc ff ff       	jmp    101fec <__alltraps>

001023c3 <vector107>:
.globl vector107
vector107:
  pushl $0
  1023c3:	6a 00                	push   $0x0
  pushl $107
  1023c5:	6a 6b                	push   $0x6b
  jmp __alltraps
  1023c7:	e9 20 fc ff ff       	jmp    101fec <__alltraps>

001023cc <vector108>:
.globl vector108
vector108:
  pushl $0
  1023cc:	6a 00                	push   $0x0
  pushl $108
  1023ce:	6a 6c                	push   $0x6c
  jmp __alltraps
  1023d0:	e9 17 fc ff ff       	jmp    101fec <__alltraps>

001023d5 <vector109>:
.globl vector109
vector109:
  pushl $0
  1023d5:	6a 00                	push   $0x0
  pushl $109
  1023d7:	6a 6d                	push   $0x6d
  jmp __alltraps
  1023d9:	e9 0e fc ff ff       	jmp    101fec <__alltraps>

001023de <vector110>:
.globl vector110
vector110:
  pushl $0
  1023de:	6a 00                	push   $0x0
  pushl $110
  1023e0:	6a 6e                	push   $0x6e
  jmp __alltraps
  1023e2:	e9 05 fc ff ff       	jmp    101fec <__alltraps>

001023e7 <vector111>:
.globl vector111
vector111:
  pushl $0
  1023e7:	6a 00                	push   $0x0
  pushl $111
  1023e9:	6a 6f                	push   $0x6f
  jmp __alltraps
  1023eb:	e9 fc fb ff ff       	jmp    101fec <__alltraps>

001023f0 <vector112>:
.globl vector112
vector112:
  pushl $0
  1023f0:	6a 00                	push   $0x0
  pushl $112
  1023f2:	6a 70                	push   $0x70
  jmp __alltraps
  1023f4:	e9 f3 fb ff ff       	jmp    101fec <__alltraps>

001023f9 <vector113>:
.globl vector113
vector113:
  pushl $0
  1023f9:	6a 00                	push   $0x0
  pushl $113
  1023fb:	6a 71                	push   $0x71
  jmp __alltraps
  1023fd:	e9 ea fb ff ff       	jmp    101fec <__alltraps>

00102402 <vector114>:
.globl vector114
vector114:
  pushl $0
  102402:	6a 00                	push   $0x0
  pushl $114
  102404:	6a 72                	push   $0x72
  jmp __alltraps
  102406:	e9 e1 fb ff ff       	jmp    101fec <__alltraps>

0010240b <vector115>:
.globl vector115
vector115:
  pushl $0
  10240b:	6a 00                	push   $0x0
  pushl $115
  10240d:	6a 73                	push   $0x73
  jmp __alltraps
  10240f:	e9 d8 fb ff ff       	jmp    101fec <__alltraps>

00102414 <vector116>:
.globl vector116
vector116:
  pushl $0
  102414:	6a 00                	push   $0x0
  pushl $116
  102416:	6a 74                	push   $0x74
  jmp __alltraps
  102418:	e9 cf fb ff ff       	jmp    101fec <__alltraps>

0010241d <vector117>:
.globl vector117
vector117:
  pushl $0
  10241d:	6a 00                	push   $0x0
  pushl $117
  10241f:	6a 75                	push   $0x75
  jmp __alltraps
  102421:	e9 c6 fb ff ff       	jmp    101fec <__alltraps>

00102426 <vector118>:
.globl vector118
vector118:
  pushl $0
  102426:	6a 00                	push   $0x0
  pushl $118
  102428:	6a 76                	push   $0x76
  jmp __alltraps
  10242a:	e9 bd fb ff ff       	jmp    101fec <__alltraps>

0010242f <vector119>:
.globl vector119
vector119:
  pushl $0
  10242f:	6a 00                	push   $0x0
  pushl $119
  102431:	6a 77                	push   $0x77
  jmp __alltraps
  102433:	e9 b4 fb ff ff       	jmp    101fec <__alltraps>

00102438 <vector120>:
.globl vector120
vector120:
  pushl $0
  102438:	6a 00                	push   $0x0
  pushl $120
  10243a:	6a 78                	push   $0x78
  jmp __alltraps
  10243c:	e9 ab fb ff ff       	jmp    101fec <__alltraps>

00102441 <vector121>:
.globl vector121
vector121:
  pushl $0
  102441:	6a 00                	push   $0x0
  pushl $121
  102443:	6a 79                	push   $0x79
  jmp __alltraps
  102445:	e9 a2 fb ff ff       	jmp    101fec <__alltraps>

0010244a <vector122>:
.globl vector122
vector122:
  pushl $0
  10244a:	6a 00                	push   $0x0
  pushl $122
  10244c:	6a 7a                	push   $0x7a
  jmp __alltraps
  10244e:	e9 99 fb ff ff       	jmp    101fec <__alltraps>

00102453 <vector123>:
.globl vector123
vector123:
  pushl $0
  102453:	6a 00                	push   $0x0
  pushl $123
  102455:	6a 7b                	push   $0x7b
  jmp __alltraps
  102457:	e9 90 fb ff ff       	jmp    101fec <__alltraps>

0010245c <vector124>:
.globl vector124
vector124:
  pushl $0
  10245c:	6a 00                	push   $0x0
  pushl $124
  10245e:	6a 7c                	push   $0x7c
  jmp __alltraps
  102460:	e9 87 fb ff ff       	jmp    101fec <__alltraps>

00102465 <vector125>:
.globl vector125
vector125:
  pushl $0
  102465:	6a 00                	push   $0x0
  pushl $125
  102467:	6a 7d                	push   $0x7d
  jmp __alltraps
  102469:	e9 7e fb ff ff       	jmp    101fec <__alltraps>

0010246e <vector126>:
.globl vector126
vector126:
  pushl $0
  10246e:	6a 00                	push   $0x0
  pushl $126
  102470:	6a 7e                	push   $0x7e
  jmp __alltraps
  102472:	e9 75 fb ff ff       	jmp    101fec <__alltraps>

00102477 <vector127>:
.globl vector127
vector127:
  pushl $0
  102477:	6a 00                	push   $0x0
  pushl $127
  102479:	6a 7f                	push   $0x7f
  jmp __alltraps
  10247b:	e9 6c fb ff ff       	jmp    101fec <__alltraps>

00102480 <vector128>:
.globl vector128
vector128:
  pushl $0
  102480:	6a 00                	push   $0x0
  pushl $128
  102482:	68 80 00 00 00       	push   $0x80
  jmp __alltraps
  102487:	e9 60 fb ff ff       	jmp    101fec <__alltraps>

0010248c <vector129>:
.globl vector129
vector129:
  pushl $0
  10248c:	6a 00                	push   $0x0
  pushl $129
  10248e:	68 81 00 00 00       	push   $0x81
  jmp __alltraps
  102493:	e9 54 fb ff ff       	jmp    101fec <__alltraps>

00102498 <vector130>:
.globl vector130
vector130:
  pushl $0
  102498:	6a 00                	push   $0x0
  pushl $130
  10249a:	68 82 00 00 00       	push   $0x82
  jmp __alltraps
  10249f:	e9 48 fb ff ff       	jmp    101fec <__alltraps>

001024a4 <vector131>:
.globl vector131
vector131:
  pushl $0
  1024a4:	6a 00                	push   $0x0
  pushl $131
  1024a6:	68 83 00 00 00       	push   $0x83
  jmp __alltraps
  1024ab:	e9 3c fb ff ff       	jmp    101fec <__alltraps>

001024b0 <vector132>:
.globl vector132
vector132:
  pushl $0
  1024b0:	6a 00                	push   $0x0
  pushl $132
  1024b2:	68 84 00 00 00       	push   $0x84
  jmp __alltraps
  1024b7:	e9 30 fb ff ff       	jmp    101fec <__alltraps>

001024bc <vector133>:
.globl vector133
vector133:
  pushl $0
  1024bc:	6a 00                	push   $0x0
  pushl $133
  1024be:	68 85 00 00 00       	push   $0x85
  jmp __alltraps
  1024c3:	e9 24 fb ff ff       	jmp    101fec <__alltraps>

001024c8 <vector134>:
.globl vector134
vector134:
  pushl $0
  1024c8:	6a 00                	push   $0x0
  pushl $134
  1024ca:	68 86 00 00 00       	push   $0x86
  jmp __alltraps
  1024cf:	e9 18 fb ff ff       	jmp    101fec <__alltraps>

001024d4 <vector135>:
.globl vector135
vector135:
  pushl $0
  1024d4:	6a 00                	push   $0x0
  pushl $135
  1024d6:	68 87 00 00 00       	push   $0x87
  jmp __alltraps
  1024db:	e9 0c fb ff ff       	jmp    101fec <__alltraps>

001024e0 <vector136>:
.globl vector136
vector136:
  pushl $0
  1024e0:	6a 00                	push   $0x0
  pushl $136
  1024e2:	68 88 00 00 00       	push   $0x88
  jmp __alltraps
  1024e7:	e9 00 fb ff ff       	jmp    101fec <__alltraps>

001024ec <vector137>:
.globl vector137
vector137:
  pushl $0
  1024ec:	6a 00                	push   $0x0
  pushl $137
  1024ee:	68 89 00 00 00       	push   $0x89
  jmp __alltraps
  1024f3:	e9 f4 fa ff ff       	jmp    101fec <__alltraps>

001024f8 <vector138>:
.globl vector138
vector138:
  pushl $0
  1024f8:	6a 00                	push   $0x0
  pushl $138
  1024fa:	68 8a 00 00 00       	push   $0x8a
  jmp __alltraps
  1024ff:	e9 e8 fa ff ff       	jmp    101fec <__alltraps>

00102504 <vector139>:
.globl vector139
vector139:
  pushl $0
  102504:	6a 00                	push   $0x0
  pushl $139
  102506:	68 8b 00 00 00       	push   $0x8b
  jmp __alltraps
  10250b:	e9 dc fa ff ff       	jmp    101fec <__alltraps>

00102510 <vector140>:
.globl vector140
vector140:
  pushl $0
  102510:	6a 00                	push   $0x0
  pushl $140
  102512:	68 8c 00 00 00       	push   $0x8c
  jmp __alltraps
  102517:	e9 d0 fa ff ff       	jmp    101fec <__alltraps>

0010251c <vector141>:
.globl vector141
vector141:
  pushl $0
  10251c:	6a 00                	push   $0x0
  pushl $141
  10251e:	68 8d 00 00 00       	push   $0x8d
  jmp __alltraps
  102523:	e9 c4 fa ff ff       	jmp    101fec <__alltraps>

00102528 <vector142>:
.globl vector142
vector142:
  pushl $0
  102528:	6a 00                	push   $0x0
  pushl $142
  10252a:	68 8e 00 00 00       	push   $0x8e
  jmp __alltraps
  10252f:	e9 b8 fa ff ff       	jmp    101fec <__alltraps>

00102534 <vector143>:
.globl vector143
vector143:
  pushl $0
  102534:	6a 00                	push   $0x0
  pushl $143
  102536:	68 8f 00 00 00       	push   $0x8f
  jmp __alltraps
  10253b:	e9 ac fa ff ff       	jmp    101fec <__alltraps>

00102540 <vector144>:
.globl vector144
vector144:
  pushl $0
  102540:	6a 00                	push   $0x0
  pushl $144
  102542:	68 90 00 00 00       	push   $0x90
  jmp __alltraps
  102547:	e9 a0 fa ff ff       	jmp    101fec <__alltraps>

0010254c <vector145>:
.globl vector145
vector145:
  pushl $0
  10254c:	6a 00                	push   $0x0
  pushl $145
  10254e:	68 91 00 00 00       	push   $0x91
  jmp __alltraps
  102553:	e9 94 fa ff ff       	jmp    101fec <__alltraps>

00102558 <vector146>:
.globl vector146
vector146:
  pushl $0
  102558:	6a 00                	push   $0x0
  pushl $146
  10255a:	68 92 00 00 00       	push   $0x92
  jmp __alltraps
  10255f:	e9 88 fa ff ff       	jmp    101fec <__alltraps>

00102564 <vector147>:
.globl vector147
vector147:
  pushl $0
  102564:	6a 00                	push   $0x0
  pushl $147
  102566:	68 93 00 00 00       	push   $0x93
  jmp __alltraps
  10256b:	e9 7c fa ff ff       	jmp    101fec <__alltraps>

00102570 <vector148>:
.globl vector148
vector148:
  pushl $0
  102570:	6a 00                	push   $0x0
  pushl $148
  102572:	68 94 00 00 00       	push   $0x94
  jmp __alltraps
  102577:	e9 70 fa ff ff       	jmp    101fec <__alltraps>

0010257c <vector149>:
.globl vector149
vector149:
  pushl $0
  10257c:	6a 00                	push   $0x0
  pushl $149
  10257e:	68 95 00 00 00       	push   $0x95
  jmp __alltraps
  102583:	e9 64 fa ff ff       	jmp    101fec <__alltraps>

00102588 <vector150>:
.globl vector150
vector150:
  pushl $0
  102588:	6a 00                	push   $0x0
  pushl $150
  10258a:	68 96 00 00 00       	push   $0x96
  jmp __alltraps
  10258f:	e9 58 fa ff ff       	jmp    101fec <__alltraps>

00102594 <vector151>:
.globl vector151
vector151:
  pushl $0
  102594:	6a 00                	push   $0x0
  pushl $151
  102596:	68 97 00 00 00       	push   $0x97
  jmp __alltraps
  10259b:	e9 4c fa ff ff       	jmp    101fec <__alltraps>

001025a0 <vector152>:
.globl vector152
vector152:
  pushl $0
  1025a0:	6a 00                	push   $0x0
  pushl $152
  1025a2:	68 98 00 00 00       	push   $0x98
  jmp __alltraps
  1025a7:	e9 40 fa ff ff       	jmp    101fec <__alltraps>

001025ac <vector153>:
.globl vector153
vector153:
  pushl $0
  1025ac:	6a 00                	push   $0x0
  pushl $153
  1025ae:	68 99 00 00 00       	push   $0x99
  jmp __alltraps
  1025b3:	e9 34 fa ff ff       	jmp    101fec <__alltraps>

001025b8 <vector154>:
.globl vector154
vector154:
  pushl $0
  1025b8:	6a 00                	push   $0x0
  pushl $154
  1025ba:	68 9a 00 00 00       	push   $0x9a
  jmp __alltraps
  1025bf:	e9 28 fa ff ff       	jmp    101fec <__alltraps>

001025c4 <vector155>:
.globl vector155
vector155:
  pushl $0
  1025c4:	6a 00                	push   $0x0
  pushl $155
  1025c6:	68 9b 00 00 00       	push   $0x9b
  jmp __alltraps
  1025cb:	e9 1c fa ff ff       	jmp    101fec <__alltraps>

001025d0 <vector156>:
.globl vector156
vector156:
  pushl $0
  1025d0:	6a 00                	push   $0x0
  pushl $156
  1025d2:	68 9c 00 00 00       	push   $0x9c
  jmp __alltraps
  1025d7:	e9 10 fa ff ff       	jmp    101fec <__alltraps>

001025dc <vector157>:
.globl vector157
vector157:
  pushl $0
  1025dc:	6a 00                	push   $0x0
  pushl $157
  1025de:	68 9d 00 00 00       	push   $0x9d
  jmp __alltraps
  1025e3:	e9 04 fa ff ff       	jmp    101fec <__alltraps>

001025e8 <vector158>:
.globl vector158
vector158:
  pushl $0
  1025e8:	6a 00                	push   $0x0
  pushl $158
  1025ea:	68 9e 00 00 00       	push   $0x9e
  jmp __alltraps
  1025ef:	e9 f8 f9 ff ff       	jmp    101fec <__alltraps>

001025f4 <vector159>:
.globl vector159
vector159:
  pushl $0
  1025f4:	6a 00                	push   $0x0
  pushl $159
  1025f6:	68 9f 00 00 00       	push   $0x9f
  jmp __alltraps
  1025fb:	e9 ec f9 ff ff       	jmp    101fec <__alltraps>

00102600 <vector160>:
.globl vector160
vector160:
  pushl $0
  102600:	6a 00                	push   $0x0
  pushl $160
  102602:	68 a0 00 00 00       	push   $0xa0
  jmp __alltraps
  102607:	e9 e0 f9 ff ff       	jmp    101fec <__alltraps>

0010260c <vector161>:
.globl vector161
vector161:
  pushl $0
  10260c:	6a 00                	push   $0x0
  pushl $161
  10260e:	68 a1 00 00 00       	push   $0xa1
  jmp __alltraps
  102613:	e9 d4 f9 ff ff       	jmp    101fec <__alltraps>

00102618 <vector162>:
.globl vector162
vector162:
  pushl $0
  102618:	6a 00                	push   $0x0
  pushl $162
  10261a:	68 a2 00 00 00       	push   $0xa2
  jmp __alltraps
  10261f:	e9 c8 f9 ff ff       	jmp    101fec <__alltraps>

00102624 <vector163>:
.globl vector163
vector163:
  pushl $0
  102624:	6a 00                	push   $0x0
  pushl $163
  102626:	68 a3 00 00 00       	push   $0xa3
  jmp __alltraps
  10262b:	e9 bc f9 ff ff       	jmp    101fec <__alltraps>

00102630 <vector164>:
.globl vector164
vector164:
  pushl $0
  102630:	6a 00                	push   $0x0
  pushl $164
  102632:	68 a4 00 00 00       	push   $0xa4
  jmp __alltraps
  102637:	e9 b0 f9 ff ff       	jmp    101fec <__alltraps>

0010263c <vector165>:
.globl vector165
vector165:
  pushl $0
  10263c:	6a 00                	push   $0x0
  pushl $165
  10263e:	68 a5 00 00 00       	push   $0xa5
  jmp __alltraps
  102643:	e9 a4 f9 ff ff       	jmp    101fec <__alltraps>

00102648 <vector166>:
.globl vector166
vector166:
  pushl $0
  102648:	6a 00                	push   $0x0
  pushl $166
  10264a:	68 a6 00 00 00       	push   $0xa6
  jmp __alltraps
  10264f:	e9 98 f9 ff ff       	jmp    101fec <__alltraps>

00102654 <vector167>:
.globl vector167
vector167:
  pushl $0
  102654:	6a 00                	push   $0x0
  pushl $167
  102656:	68 a7 00 00 00       	push   $0xa7
  jmp __alltraps
  10265b:	e9 8c f9 ff ff       	jmp    101fec <__alltraps>

00102660 <vector168>:
.globl vector168
vector168:
  pushl $0
  102660:	6a 00                	push   $0x0
  pushl $168
  102662:	68 a8 00 00 00       	push   $0xa8
  jmp __alltraps
  102667:	e9 80 f9 ff ff       	jmp    101fec <__alltraps>

0010266c <vector169>:
.globl vector169
vector169:
  pushl $0
  10266c:	6a 00                	push   $0x0
  pushl $169
  10266e:	68 a9 00 00 00       	push   $0xa9
  jmp __alltraps
  102673:	e9 74 f9 ff ff       	jmp    101fec <__alltraps>

00102678 <vector170>:
.globl vector170
vector170:
  pushl $0
  102678:	6a 00                	push   $0x0
  pushl $170
  10267a:	68 aa 00 00 00       	push   $0xaa
  jmp __alltraps
  10267f:	e9 68 f9 ff ff       	jmp    101fec <__alltraps>

00102684 <vector171>:
.globl vector171
vector171:
  pushl $0
  102684:	6a 00                	push   $0x0
  pushl $171
  102686:	68 ab 00 00 00       	push   $0xab
  jmp __alltraps
  10268b:	e9 5c f9 ff ff       	jmp    101fec <__alltraps>

00102690 <vector172>:
.globl vector172
vector172:
  pushl $0
  102690:	6a 00                	push   $0x0
  pushl $172
  102692:	68 ac 00 00 00       	push   $0xac
  jmp __alltraps
  102697:	e9 50 f9 ff ff       	jmp    101fec <__alltraps>

0010269c <vector173>:
.globl vector173
vector173:
  pushl $0
  10269c:	6a 00                	push   $0x0
  pushl $173
  10269e:	68 ad 00 00 00       	push   $0xad
  jmp __alltraps
  1026a3:	e9 44 f9 ff ff       	jmp    101fec <__alltraps>

001026a8 <vector174>:
.globl vector174
vector174:
  pushl $0
  1026a8:	6a 00                	push   $0x0
  pushl $174
  1026aa:	68 ae 00 00 00       	push   $0xae
  jmp __alltraps
  1026af:	e9 38 f9 ff ff       	jmp    101fec <__alltraps>

001026b4 <vector175>:
.globl vector175
vector175:
  pushl $0
  1026b4:	6a 00                	push   $0x0
  pushl $175
  1026b6:	68 af 00 00 00       	push   $0xaf
  jmp __alltraps
  1026bb:	e9 2c f9 ff ff       	jmp    101fec <__alltraps>

001026c0 <vector176>:
.globl vector176
vector176:
  pushl $0
  1026c0:	6a 00                	push   $0x0
  pushl $176
  1026c2:	68 b0 00 00 00       	push   $0xb0
  jmp __alltraps
  1026c7:	e9 20 f9 ff ff       	jmp    101fec <__alltraps>

001026cc <vector177>:
.globl vector177
vector177:
  pushl $0
  1026cc:	6a 00                	push   $0x0
  pushl $177
  1026ce:	68 b1 00 00 00       	push   $0xb1
  jmp __alltraps
  1026d3:	e9 14 f9 ff ff       	jmp    101fec <__alltraps>

001026d8 <vector178>:
.globl vector178
vector178:
  pushl $0
  1026d8:	6a 00                	push   $0x0
  pushl $178
  1026da:	68 b2 00 00 00       	push   $0xb2
  jmp __alltraps
  1026df:	e9 08 f9 ff ff       	jmp    101fec <__alltraps>

001026e4 <vector179>:
.globl vector179
vector179:
  pushl $0
  1026e4:	6a 00                	push   $0x0
  pushl $179
  1026e6:	68 b3 00 00 00       	push   $0xb3
  jmp __alltraps
  1026eb:	e9 fc f8 ff ff       	jmp    101fec <__alltraps>

001026f0 <vector180>:
.globl vector180
vector180:
  pushl $0
  1026f0:	6a 00                	push   $0x0
  pushl $180
  1026f2:	68 b4 00 00 00       	push   $0xb4
  jmp __alltraps
  1026f7:	e9 f0 f8 ff ff       	jmp    101fec <__alltraps>

001026fc <vector181>:
.globl vector181
vector181:
  pushl $0
  1026fc:	6a 00                	push   $0x0
  pushl $181
  1026fe:	68 b5 00 00 00       	push   $0xb5
  jmp __alltraps
  102703:	e9 e4 f8 ff ff       	jmp    101fec <__alltraps>

00102708 <vector182>:
.globl vector182
vector182:
  pushl $0
  102708:	6a 00                	push   $0x0
  pushl $182
  10270a:	68 b6 00 00 00       	push   $0xb6
  jmp __alltraps
  10270f:	e9 d8 f8 ff ff       	jmp    101fec <__alltraps>

00102714 <vector183>:
.globl vector183
vector183:
  pushl $0
  102714:	6a 00                	push   $0x0
  pushl $183
  102716:	68 b7 00 00 00       	push   $0xb7
  jmp __alltraps
  10271b:	e9 cc f8 ff ff       	jmp    101fec <__alltraps>

00102720 <vector184>:
.globl vector184
vector184:
  pushl $0
  102720:	6a 00                	push   $0x0
  pushl $184
  102722:	68 b8 00 00 00       	push   $0xb8
  jmp __alltraps
  102727:	e9 c0 f8 ff ff       	jmp    101fec <__alltraps>

0010272c <vector185>:
.globl vector185
vector185:
  pushl $0
  10272c:	6a 00                	push   $0x0
  pushl $185
  10272e:	68 b9 00 00 00       	push   $0xb9
  jmp __alltraps
  102733:	e9 b4 f8 ff ff       	jmp    101fec <__alltraps>

00102738 <vector186>:
.globl vector186
vector186:
  pushl $0
  102738:	6a 00                	push   $0x0
  pushl $186
  10273a:	68 ba 00 00 00       	push   $0xba
  jmp __alltraps
  10273f:	e9 a8 f8 ff ff       	jmp    101fec <__alltraps>

00102744 <vector187>:
.globl vector187
vector187:
  pushl $0
  102744:	6a 00                	push   $0x0
  pushl $187
  102746:	68 bb 00 00 00       	push   $0xbb
  jmp __alltraps
  10274b:	e9 9c f8 ff ff       	jmp    101fec <__alltraps>

00102750 <vector188>:
.globl vector188
vector188:
  pushl $0
  102750:	6a 00                	push   $0x0
  pushl $188
  102752:	68 bc 00 00 00       	push   $0xbc
  jmp __alltraps
  102757:	e9 90 f8 ff ff       	jmp    101fec <__alltraps>

0010275c <vector189>:
.globl vector189
vector189:
  pushl $0
  10275c:	6a 00                	push   $0x0
  pushl $189
  10275e:	68 bd 00 00 00       	push   $0xbd
  jmp __alltraps
  102763:	e9 84 f8 ff ff       	jmp    101fec <__alltraps>

00102768 <vector190>:
.globl vector190
vector190:
  pushl $0
  102768:	6a 00                	push   $0x0
  pushl $190
  10276a:	68 be 00 00 00       	push   $0xbe
  jmp __alltraps
  10276f:	e9 78 f8 ff ff       	jmp    101fec <__alltraps>

00102774 <vector191>:
.globl vector191
vector191:
  pushl $0
  102774:	6a 00                	push   $0x0
  pushl $191
  102776:	68 bf 00 00 00       	push   $0xbf
  jmp __alltraps
  10277b:	e9 6c f8 ff ff       	jmp    101fec <__alltraps>

00102780 <vector192>:
.globl vector192
vector192:
  pushl $0
  102780:	6a 00                	push   $0x0
  pushl $192
  102782:	68 c0 00 00 00       	push   $0xc0
  jmp __alltraps
  102787:	e9 60 f8 ff ff       	jmp    101fec <__alltraps>

0010278c <vector193>:
.globl vector193
vector193:
  pushl $0
  10278c:	6a 00                	push   $0x0
  pushl $193
  10278e:	68 c1 00 00 00       	push   $0xc1
  jmp __alltraps
  102793:	e9 54 f8 ff ff       	jmp    101fec <__alltraps>

00102798 <vector194>:
.globl vector194
vector194:
  pushl $0
  102798:	6a 00                	push   $0x0
  pushl $194
  10279a:	68 c2 00 00 00       	push   $0xc2
  jmp __alltraps
  10279f:	e9 48 f8 ff ff       	jmp    101fec <__alltraps>

001027a4 <vector195>:
.globl vector195
vector195:
  pushl $0
  1027a4:	6a 00                	push   $0x0
  pushl $195
  1027a6:	68 c3 00 00 00       	push   $0xc3
  jmp __alltraps
  1027ab:	e9 3c f8 ff ff       	jmp    101fec <__alltraps>

001027b0 <vector196>:
.globl vector196
vector196:
  pushl $0
  1027b0:	6a 00                	push   $0x0
  pushl $196
  1027b2:	68 c4 00 00 00       	push   $0xc4
  jmp __alltraps
  1027b7:	e9 30 f8 ff ff       	jmp    101fec <__alltraps>

001027bc <vector197>:
.globl vector197
vector197:
  pushl $0
  1027bc:	6a 00                	push   $0x0
  pushl $197
  1027be:	68 c5 00 00 00       	push   $0xc5
  jmp __alltraps
  1027c3:	e9 24 f8 ff ff       	jmp    101fec <__alltraps>

001027c8 <vector198>:
.globl vector198
vector198:
  pushl $0
  1027c8:	6a 00                	push   $0x0
  pushl $198
  1027ca:	68 c6 00 00 00       	push   $0xc6
  jmp __alltraps
  1027cf:	e9 18 f8 ff ff       	jmp    101fec <__alltraps>

001027d4 <vector199>:
.globl vector199
vector199:
  pushl $0
  1027d4:	6a 00                	push   $0x0
  pushl $199
  1027d6:	68 c7 00 00 00       	push   $0xc7
  jmp __alltraps
  1027db:	e9 0c f8 ff ff       	jmp    101fec <__alltraps>

001027e0 <vector200>:
.globl vector200
vector200:
  pushl $0
  1027e0:	6a 00                	push   $0x0
  pushl $200
  1027e2:	68 c8 00 00 00       	push   $0xc8
  jmp __alltraps
  1027e7:	e9 00 f8 ff ff       	jmp    101fec <__alltraps>

001027ec <vector201>:
.globl vector201
vector201:
  pushl $0
  1027ec:	6a 00                	push   $0x0
  pushl $201
  1027ee:	68 c9 00 00 00       	push   $0xc9
  jmp __alltraps
  1027f3:	e9 f4 f7 ff ff       	jmp    101fec <__alltraps>

001027f8 <vector202>:
.globl vector202
vector202:
  pushl $0
  1027f8:	6a 00                	push   $0x0
  pushl $202
  1027fa:	68 ca 00 00 00       	push   $0xca
  jmp __alltraps
  1027ff:	e9 e8 f7 ff ff       	jmp    101fec <__alltraps>

00102804 <vector203>:
.globl vector203
vector203:
  pushl $0
  102804:	6a 00                	push   $0x0
  pushl $203
  102806:	68 cb 00 00 00       	push   $0xcb
  jmp __alltraps
  10280b:	e9 dc f7 ff ff       	jmp    101fec <__alltraps>

00102810 <vector204>:
.globl vector204
vector204:
  pushl $0
  102810:	6a 00                	push   $0x0
  pushl $204
  102812:	68 cc 00 00 00       	push   $0xcc
  jmp __alltraps
  102817:	e9 d0 f7 ff ff       	jmp    101fec <__alltraps>

0010281c <vector205>:
.globl vector205
vector205:
  pushl $0
  10281c:	6a 00                	push   $0x0
  pushl $205
  10281e:	68 cd 00 00 00       	push   $0xcd
  jmp __alltraps
  102823:	e9 c4 f7 ff ff       	jmp    101fec <__alltraps>

00102828 <vector206>:
.globl vector206
vector206:
  pushl $0
  102828:	6a 00                	push   $0x0
  pushl $206
  10282a:	68 ce 00 00 00       	push   $0xce
  jmp __alltraps
  10282f:	e9 b8 f7 ff ff       	jmp    101fec <__alltraps>

00102834 <vector207>:
.globl vector207
vector207:
  pushl $0
  102834:	6a 00                	push   $0x0
  pushl $207
  102836:	68 cf 00 00 00       	push   $0xcf
  jmp __alltraps
  10283b:	e9 ac f7 ff ff       	jmp    101fec <__alltraps>

00102840 <vector208>:
.globl vector208
vector208:
  pushl $0
  102840:	6a 00                	push   $0x0
  pushl $208
  102842:	68 d0 00 00 00       	push   $0xd0
  jmp __alltraps
  102847:	e9 a0 f7 ff ff       	jmp    101fec <__alltraps>

0010284c <vector209>:
.globl vector209
vector209:
  pushl $0
  10284c:	6a 00                	push   $0x0
  pushl $209
  10284e:	68 d1 00 00 00       	push   $0xd1
  jmp __alltraps
  102853:	e9 94 f7 ff ff       	jmp    101fec <__alltraps>

00102858 <vector210>:
.globl vector210
vector210:
  pushl $0
  102858:	6a 00                	push   $0x0
  pushl $210
  10285a:	68 d2 00 00 00       	push   $0xd2
  jmp __alltraps
  10285f:	e9 88 f7 ff ff       	jmp    101fec <__alltraps>

00102864 <vector211>:
.globl vector211
vector211:
  pushl $0
  102864:	6a 00                	push   $0x0
  pushl $211
  102866:	68 d3 00 00 00       	push   $0xd3
  jmp __alltraps
  10286b:	e9 7c f7 ff ff       	jmp    101fec <__alltraps>

00102870 <vector212>:
.globl vector212
vector212:
  pushl $0
  102870:	6a 00                	push   $0x0
  pushl $212
  102872:	68 d4 00 00 00       	push   $0xd4
  jmp __alltraps
  102877:	e9 70 f7 ff ff       	jmp    101fec <__alltraps>

0010287c <vector213>:
.globl vector213
vector213:
  pushl $0
  10287c:	6a 00                	push   $0x0
  pushl $213
  10287e:	68 d5 00 00 00       	push   $0xd5
  jmp __alltraps
  102883:	e9 64 f7 ff ff       	jmp    101fec <__alltraps>

00102888 <vector214>:
.globl vector214
vector214:
  pushl $0
  102888:	6a 00                	push   $0x0
  pushl $214
  10288a:	68 d6 00 00 00       	push   $0xd6
  jmp __alltraps
  10288f:	e9 58 f7 ff ff       	jmp    101fec <__alltraps>

00102894 <vector215>:
.globl vector215
vector215:
  pushl $0
  102894:	6a 00                	push   $0x0
  pushl $215
  102896:	68 d7 00 00 00       	push   $0xd7
  jmp __alltraps
  10289b:	e9 4c f7 ff ff       	jmp    101fec <__alltraps>

001028a0 <vector216>:
.globl vector216
vector216:
  pushl $0
  1028a0:	6a 00                	push   $0x0
  pushl $216
  1028a2:	68 d8 00 00 00       	push   $0xd8
  jmp __alltraps
  1028a7:	e9 40 f7 ff ff       	jmp    101fec <__alltraps>

001028ac <vector217>:
.globl vector217
vector217:
  pushl $0
  1028ac:	6a 00                	push   $0x0
  pushl $217
  1028ae:	68 d9 00 00 00       	push   $0xd9
  jmp __alltraps
  1028b3:	e9 34 f7 ff ff       	jmp    101fec <__alltraps>

001028b8 <vector218>:
.globl vector218
vector218:
  pushl $0
  1028b8:	6a 00                	push   $0x0
  pushl $218
  1028ba:	68 da 00 00 00       	push   $0xda
  jmp __alltraps
  1028bf:	e9 28 f7 ff ff       	jmp    101fec <__alltraps>

001028c4 <vector219>:
.globl vector219
vector219:
  pushl $0
  1028c4:	6a 00                	push   $0x0
  pushl $219
  1028c6:	68 db 00 00 00       	push   $0xdb
  jmp __alltraps
  1028cb:	e9 1c f7 ff ff       	jmp    101fec <__alltraps>

001028d0 <vector220>:
.globl vector220
vector220:
  pushl $0
  1028d0:	6a 00                	push   $0x0
  pushl $220
  1028d2:	68 dc 00 00 00       	push   $0xdc
  jmp __alltraps
  1028d7:	e9 10 f7 ff ff       	jmp    101fec <__alltraps>

001028dc <vector221>:
.globl vector221
vector221:
  pushl $0
  1028dc:	6a 00                	push   $0x0
  pushl $221
  1028de:	68 dd 00 00 00       	push   $0xdd
  jmp __alltraps
  1028e3:	e9 04 f7 ff ff       	jmp    101fec <__alltraps>

001028e8 <vector222>:
.globl vector222
vector222:
  pushl $0
  1028e8:	6a 00                	push   $0x0
  pushl $222
  1028ea:	68 de 00 00 00       	push   $0xde
  jmp __alltraps
  1028ef:	e9 f8 f6 ff ff       	jmp    101fec <__alltraps>

001028f4 <vector223>:
.globl vector223
vector223:
  pushl $0
  1028f4:	6a 00                	push   $0x0
  pushl $223
  1028f6:	68 df 00 00 00       	push   $0xdf
  jmp __alltraps
  1028fb:	e9 ec f6 ff ff       	jmp    101fec <__alltraps>

00102900 <vector224>:
.globl vector224
vector224:
  pushl $0
  102900:	6a 00                	push   $0x0
  pushl $224
  102902:	68 e0 00 00 00       	push   $0xe0
  jmp __alltraps
  102907:	e9 e0 f6 ff ff       	jmp    101fec <__alltraps>

0010290c <vector225>:
.globl vector225
vector225:
  pushl $0
  10290c:	6a 00                	push   $0x0
  pushl $225
  10290e:	68 e1 00 00 00       	push   $0xe1
  jmp __alltraps
  102913:	e9 d4 f6 ff ff       	jmp    101fec <__alltraps>

00102918 <vector226>:
.globl vector226
vector226:
  pushl $0
  102918:	6a 00                	push   $0x0
  pushl $226
  10291a:	68 e2 00 00 00       	push   $0xe2
  jmp __alltraps
  10291f:	e9 c8 f6 ff ff       	jmp    101fec <__alltraps>

00102924 <vector227>:
.globl vector227
vector227:
  pushl $0
  102924:	6a 00                	push   $0x0
  pushl $227
  102926:	68 e3 00 00 00       	push   $0xe3
  jmp __alltraps
  10292b:	e9 bc f6 ff ff       	jmp    101fec <__alltraps>

00102930 <vector228>:
.globl vector228
vector228:
  pushl $0
  102930:	6a 00                	push   $0x0
  pushl $228
  102932:	68 e4 00 00 00       	push   $0xe4
  jmp __alltraps
  102937:	e9 b0 f6 ff ff       	jmp    101fec <__alltraps>

0010293c <vector229>:
.globl vector229
vector229:
  pushl $0
  10293c:	6a 00                	push   $0x0
  pushl $229
  10293e:	68 e5 00 00 00       	push   $0xe5
  jmp __alltraps
  102943:	e9 a4 f6 ff ff       	jmp    101fec <__alltraps>

00102948 <vector230>:
.globl vector230
vector230:
  pushl $0
  102948:	6a 00                	push   $0x0
  pushl $230
  10294a:	68 e6 00 00 00       	push   $0xe6
  jmp __alltraps
  10294f:	e9 98 f6 ff ff       	jmp    101fec <__alltraps>

00102954 <vector231>:
.globl vector231
vector231:
  pushl $0
  102954:	6a 00                	push   $0x0
  pushl $231
  102956:	68 e7 00 00 00       	push   $0xe7
  jmp __alltraps
  10295b:	e9 8c f6 ff ff       	jmp    101fec <__alltraps>

00102960 <vector232>:
.globl vector232
vector232:
  pushl $0
  102960:	6a 00                	push   $0x0
  pushl $232
  102962:	68 e8 00 00 00       	push   $0xe8
  jmp __alltraps
  102967:	e9 80 f6 ff ff       	jmp    101fec <__alltraps>

0010296c <vector233>:
.globl vector233
vector233:
  pushl $0
  10296c:	6a 00                	push   $0x0
  pushl $233
  10296e:	68 e9 00 00 00       	push   $0xe9
  jmp __alltraps
  102973:	e9 74 f6 ff ff       	jmp    101fec <__alltraps>

00102978 <vector234>:
.globl vector234
vector234:
  pushl $0
  102978:	6a 00                	push   $0x0
  pushl $234
  10297a:	68 ea 00 00 00       	push   $0xea
  jmp __alltraps
  10297f:	e9 68 f6 ff ff       	jmp    101fec <__alltraps>

00102984 <vector235>:
.globl vector235
vector235:
  pushl $0
  102984:	6a 00                	push   $0x0
  pushl $235
  102986:	68 eb 00 00 00       	push   $0xeb
  jmp __alltraps
  10298b:	e9 5c f6 ff ff       	jmp    101fec <__alltraps>

00102990 <vector236>:
.globl vector236
vector236:
  pushl $0
  102990:	6a 00                	push   $0x0
  pushl $236
  102992:	68 ec 00 00 00       	push   $0xec
  jmp __alltraps
  102997:	e9 50 f6 ff ff       	jmp    101fec <__alltraps>

0010299c <vector237>:
.globl vector237
vector237:
  pushl $0
  10299c:	6a 00                	push   $0x0
  pushl $237
  10299e:	68 ed 00 00 00       	push   $0xed
  jmp __alltraps
  1029a3:	e9 44 f6 ff ff       	jmp    101fec <__alltraps>

001029a8 <vector238>:
.globl vector238
vector238:
  pushl $0
  1029a8:	6a 00                	push   $0x0
  pushl $238
  1029aa:	68 ee 00 00 00       	push   $0xee
  jmp __alltraps
  1029af:	e9 38 f6 ff ff       	jmp    101fec <__alltraps>

001029b4 <vector239>:
.globl vector239
vector239:
  pushl $0
  1029b4:	6a 00                	push   $0x0
  pushl $239
  1029b6:	68 ef 00 00 00       	push   $0xef
  jmp __alltraps
  1029bb:	e9 2c f6 ff ff       	jmp    101fec <__alltraps>

001029c0 <vector240>:
.globl vector240
vector240:
  pushl $0
  1029c0:	6a 00                	push   $0x0
  pushl $240
  1029c2:	68 f0 00 00 00       	push   $0xf0
  jmp __alltraps
  1029c7:	e9 20 f6 ff ff       	jmp    101fec <__alltraps>

001029cc <vector241>:
.globl vector241
vector241:
  pushl $0
  1029cc:	6a 00                	push   $0x0
  pushl $241
  1029ce:	68 f1 00 00 00       	push   $0xf1
  jmp __alltraps
  1029d3:	e9 14 f6 ff ff       	jmp    101fec <__alltraps>

001029d8 <vector242>:
.globl vector242
vector242:
  pushl $0
  1029d8:	6a 00                	push   $0x0
  pushl $242
  1029da:	68 f2 00 00 00       	push   $0xf2
  jmp __alltraps
  1029df:	e9 08 f6 ff ff       	jmp    101fec <__alltraps>

001029e4 <vector243>:
.globl vector243
vector243:
  pushl $0
  1029e4:	6a 00                	push   $0x0
  pushl $243
  1029e6:	68 f3 00 00 00       	push   $0xf3
  jmp __alltraps
  1029eb:	e9 fc f5 ff ff       	jmp    101fec <__alltraps>

001029f0 <vector244>:
.globl vector244
vector244:
  pushl $0
  1029f0:	6a 00                	push   $0x0
  pushl $244
  1029f2:	68 f4 00 00 00       	push   $0xf4
  jmp __alltraps
  1029f7:	e9 f0 f5 ff ff       	jmp    101fec <__alltraps>

001029fc <vector245>:
.globl vector245
vector245:
  pushl $0
  1029fc:	6a 00                	push   $0x0
  pushl $245
  1029fe:	68 f5 00 00 00       	push   $0xf5
  jmp __alltraps
  102a03:	e9 e4 f5 ff ff       	jmp    101fec <__alltraps>

00102a08 <vector246>:
.globl vector246
vector246:
  pushl $0
  102a08:	6a 00                	push   $0x0
  pushl $246
  102a0a:	68 f6 00 00 00       	push   $0xf6
  jmp __alltraps
  102a0f:	e9 d8 f5 ff ff       	jmp    101fec <__alltraps>

00102a14 <vector247>:
.globl vector247
vector247:
  pushl $0
  102a14:	6a 00                	push   $0x0
  pushl $247
  102a16:	68 f7 00 00 00       	push   $0xf7
  jmp __alltraps
  102a1b:	e9 cc f5 ff ff       	jmp    101fec <__alltraps>

00102a20 <vector248>:
.globl vector248
vector248:
  pushl $0
  102a20:	6a 00                	push   $0x0
  pushl $248
  102a22:	68 f8 00 00 00       	push   $0xf8
  jmp __alltraps
  102a27:	e9 c0 f5 ff ff       	jmp    101fec <__alltraps>

00102a2c <vector249>:
.globl vector249
vector249:
  pushl $0
  102a2c:	6a 00                	push   $0x0
  pushl $249
  102a2e:	68 f9 00 00 00       	push   $0xf9
  jmp __alltraps
  102a33:	e9 b4 f5 ff ff       	jmp    101fec <__alltraps>

00102a38 <vector250>:
.globl vector250
vector250:
  pushl $0
  102a38:	6a 00                	push   $0x0
  pushl $250
  102a3a:	68 fa 00 00 00       	push   $0xfa
  jmp __alltraps
  102a3f:	e9 a8 f5 ff ff       	jmp    101fec <__alltraps>

00102a44 <vector251>:
.globl vector251
vector251:
  pushl $0
  102a44:	6a 00                	push   $0x0
  pushl $251
  102a46:	68 fb 00 00 00       	push   $0xfb
  jmp __alltraps
  102a4b:	e9 9c f5 ff ff       	jmp    101fec <__alltraps>

00102a50 <vector252>:
.globl vector252
vector252:
  pushl $0
  102a50:	6a 00                	push   $0x0
  pushl $252
  102a52:	68 fc 00 00 00       	push   $0xfc
  jmp __alltraps
  102a57:	e9 90 f5 ff ff       	jmp    101fec <__alltraps>

00102a5c <vector253>:
.globl vector253
vector253:
  pushl $0
  102a5c:	6a 00                	push   $0x0
  pushl $253
  102a5e:	68 fd 00 00 00       	push   $0xfd
  jmp __alltraps
  102a63:	e9 84 f5 ff ff       	jmp    101fec <__alltraps>

00102a68 <vector254>:
.globl vector254
vector254:
  pushl $0
  102a68:	6a 00                	push   $0x0
  pushl $254
  102a6a:	68 fe 00 00 00       	push   $0xfe
  jmp __alltraps
  102a6f:	e9 78 f5 ff ff       	jmp    101fec <__alltraps>

00102a74 <vector255>:
.globl vector255
vector255:
  pushl $0
  102a74:	6a 00                	push   $0x0
  pushl $255
  102a76:	68 ff 00 00 00       	push   $0xff
  jmp __alltraps
  102a7b:	e9 6c f5 ff ff       	jmp    101fec <__alltraps>

00102a80 <page2ppn>:

extern struct Page *pages;
extern size_t npage;

static inline ppn_t
page2ppn(struct Page *page) {
  102a80:	55                   	push   %ebp
  102a81:	89 e5                	mov    %esp,%ebp
    return page - pages;
  102a83:	8b 15 00 cf 11 00    	mov    0x11cf00,%edx
  102a89:	8b 45 08             	mov    0x8(%ebp),%eax
  102a8c:	29 d0                	sub    %edx,%eax
  102a8e:	c1 f8 02             	sar    $0x2,%eax
  102a91:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  102a97:	5d                   	pop    %ebp
  102a98:	c3                   	ret    

00102a99 <page2pa>:

static inline uintptr_t
page2pa(struct Page *page) {
  102a99:	55                   	push   %ebp
  102a9a:	89 e5                	mov    %esp,%ebp
  102a9c:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  102a9f:	8b 45 08             	mov    0x8(%ebp),%eax
  102aa2:	89 04 24             	mov    %eax,(%esp)
  102aa5:	e8 d6 ff ff ff       	call   102a80 <page2ppn>
  102aaa:	c1 e0 0c             	shl    $0xc,%eax
}
  102aad:	89 ec                	mov    %ebp,%esp
  102aaf:	5d                   	pop    %ebp
  102ab0:	c3                   	ret    

00102ab1 <page_ref>:
pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

static inline int
page_ref(struct Page *page) {
  102ab1:	55                   	push   %ebp
  102ab2:	89 e5                	mov    %esp,%ebp
    return page->ref;
  102ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  102ab7:	8b 00                	mov    (%eax),%eax
}
  102ab9:	5d                   	pop    %ebp
  102aba:	c3                   	ret    

00102abb <set_page_ref>:

static inline void
set_page_ref(struct Page *page, int val) {
  102abb:	55                   	push   %ebp
  102abc:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  102abe:	8b 45 08             	mov    0x8(%ebp),%eax
  102ac1:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ac4:	89 10                	mov    %edx,(%eax)
}
  102ac6:	90                   	nop
  102ac7:	5d                   	pop    %ebp
  102ac8:	c3                   	ret    

00102ac9 <default_init>:

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
  102ac9:	55                   	push   %ebp
  102aca:	89 e5                	mov    %esp,%ebp
  102acc:	83 ec 10             	sub    $0x10,%esp
  102acf:	c7 45 fc e0 ce 11 00 	movl   $0x11cee0,-0x4(%ebp)
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
  102ad6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ad9:	8b 55 fc             	mov    -0x4(%ebp),%edx
  102adc:	89 50 04             	mov    %edx,0x4(%eax)
  102adf:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ae2:	8b 50 04             	mov    0x4(%eax),%edx
  102ae5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  102ae8:	89 10                	mov    %edx,(%eax)
}
  102aea:	90                   	nop
    list_init(&free_list);
    nr_free = 0;
  102aeb:	c7 05 e8 ce 11 00 00 	movl   $0x0,0x11cee8
  102af2:	00 00 00 
}
  102af5:	90                   	nop
  102af6:	89 ec                	mov    %ebp,%esp
  102af8:	5d                   	pop    %ebp
  102af9:	c3                   	ret    

00102afa <default_init_memmap>:

static void
default_init_memmap(struct Page *base, size_t n) {
  102afa:	55                   	push   %ebp
  102afb:	89 e5                	mov    %esp,%ebp
  102afd:	83 ec 58             	sub    $0x58,%esp
    assert(n > 0);
  102b00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102b04:	75 24                	jne    102b2a <default_init_memmap+0x30>
  102b06:	c7 44 24 0c 50 69 10 	movl   $0x106950,0xc(%esp)
  102b0d:	00 
  102b0e:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  102b15:	00 
  102b16:	c7 44 24 04 c7 00 00 	movl   $0xc7,0x4(%esp)
  102b1d:	00 
  102b1e:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  102b25:	e8 bd e1 ff ff       	call   100ce7 <__panic>
    struct Page *p = base;
  102b2a:	8b 45 08             	mov    0x8(%ebp),%eax
  102b2d:	89 45 f4             	mov    %eax,-0xc(%ebp)
    for (; p != base + n; p ++) {
  102b30:	eb 7d                	jmp    102baf <default_init_memmap+0xb5>
        assert(PageReserved(p));
  102b32:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b35:	83 c0 04             	add    $0x4,%eax
  102b38:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  102b3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
 * @addr:   the address to count from
 * */
static inline bool
test_bit(int nr, volatile void *addr) {
    int oldbit;
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102b42:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102b45:	8b 55 f0             	mov    -0x10(%ebp),%edx
  102b48:	0f a3 10             	bt     %edx,(%eax)
  102b4b:	19 c0                	sbb    %eax,%eax
  102b4d:	89 45 e8             	mov    %eax,-0x18(%ebp)
    return oldbit != 0;
  102b50:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  102b54:	0f 95 c0             	setne  %al
  102b57:	0f b6 c0             	movzbl %al,%eax
  102b5a:	85 c0                	test   %eax,%eax
  102b5c:	75 24                	jne    102b82 <default_init_memmap+0x88>
  102b5e:	c7 44 24 0c 81 69 10 	movl   $0x106981,0xc(%esp)
  102b65:	00 
  102b66:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  102b6d:	00 
  102b6e:	c7 44 24 04 ca 00 00 	movl   $0xca,0x4(%esp)
  102b75:	00 
  102b76:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  102b7d:	e8 65 e1 ff ff       	call   100ce7 <__panic>
        p->flags = p->property = 0;
  102b82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b85:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  102b8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b8f:	8b 50 08             	mov    0x8(%eax),%edx
  102b92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102b95:	89 50 04             	mov    %edx,0x4(%eax)
        set_page_ref(p, 0);
  102b98:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102b9f:	00 
  102ba0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ba3:	89 04 24             	mov    %eax,(%esp)
  102ba6:	e8 10 ff ff ff       	call   102abb <set_page_ref>
    for (; p != base + n; p ++) {
  102bab:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102baf:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bb2:	89 d0                	mov    %edx,%eax
  102bb4:	c1 e0 02             	shl    $0x2,%eax
  102bb7:	01 d0                	add    %edx,%eax
  102bb9:	c1 e0 02             	shl    $0x2,%eax
  102bbc:	89 c2                	mov    %eax,%edx
  102bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  102bc1:	01 d0                	add    %edx,%eax
  102bc3:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102bc6:	0f 85 66 ff ff ff    	jne    102b32 <default_init_memmap+0x38>
    }
    base->property = n;
  102bcc:	8b 45 08             	mov    0x8(%ebp),%eax
  102bcf:	8b 55 0c             	mov    0xc(%ebp),%edx
  102bd2:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  102bd8:	83 c0 04             	add    $0x4,%eax
  102bdb:	c7 45 c8 01 00 00 00 	movl   $0x1,-0x38(%ebp)
  102be2:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102be5:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102be8:	8b 55 c8             	mov    -0x38(%ebp),%edx
  102beb:	0f ab 10             	bts    %edx,(%eax)
}
  102bee:	90                   	nop
    nr_free += n;
  102bef:	8b 15 e8 ce 11 00    	mov    0x11cee8,%edx
  102bf5:	8b 45 0c             	mov    0xc(%ebp),%eax
  102bf8:	01 d0                	add    %edx,%eax
  102bfa:	a3 e8 ce 11 00       	mov    %eax,0x11cee8
    list_add(&free_list, &(base->page_link));
  102bff:	8b 45 08             	mov    0x8(%ebp),%eax
  102c02:	83 c0 0c             	add    $0xc,%eax
  102c05:	c7 45 e4 e0 ce 11 00 	movl   $0x11cee0,-0x1c(%ebp)
  102c0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  102c0f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102c12:	89 45 dc             	mov    %eax,-0x24(%ebp)
  102c15:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102c18:	89 45 d8             	mov    %eax,-0x28(%ebp)
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
  102c1b:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102c1e:	8b 40 04             	mov    0x4(%eax),%eax
  102c21:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102c24:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102c27:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102c2a:	89 55 d0             	mov    %edx,-0x30(%ebp)
  102c2d:	89 45 cc             	mov    %eax,-0x34(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
  102c30:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102c33:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102c36:	89 10                	mov    %edx,(%eax)
  102c38:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102c3b:	8b 10                	mov    (%eax),%edx
  102c3d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102c40:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102c43:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102c46:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102c49:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102c4c:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102c4f:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102c52:	89 10                	mov    %edx,(%eax)
}
  102c54:	90                   	nop
}
  102c55:	90                   	nop
}
  102c56:	90                   	nop
}
  102c57:	90                   	nop
  102c58:	89 ec                	mov    %ebp,%esp
  102c5a:	5d                   	pop    %ebp
  102c5b:	c3                   	ret    

00102c5c <default_alloc_pages>:
 * 并以Page指针的形式，返回最低位物理页(最前面的)。
 * 
 * 如果分配时发生错误或者剩余空闲空间不足，则返回NULL代表分配失败
 * */
static struct Page *
default_alloc_pages(size_t n) {    assert(n > 0);
  102c5c:	55                   	push   %ebp
  102c5d:	89 e5                	mov    %esp,%ebp
  102c5f:	83 ec 68             	sub    $0x68,%esp
  102c62:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  102c66:	75 24                	jne    102c8c <default_alloc_pages+0x30>
  102c68:	c7 44 24 0c 50 69 10 	movl   $0x106950,0xc(%esp)
  102c6f:	00 
  102c70:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  102c77:	00 
  102c78:	c7 44 24 04 f6 00 00 	movl   $0xf6,0x4(%esp)
  102c7f:	00 
  102c80:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  102c87:	e8 5b e0 ff ff       	call   100ce7 <__panic>
    if (n > nr_free) {
  102c8c:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  102c91:	39 45 08             	cmp    %eax,0x8(%ebp)
  102c94:	76 0a                	jbe    102ca0 <default_alloc_pages+0x44>
        return NULL;
  102c96:	b8 00 00 00 00       	mov    $0x0,%eax
  102c9b:	e9 43 01 00 00       	jmp    102de3 <default_alloc_pages+0x187>
    }
    struct Page *page = NULL;
  102ca0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    list_entry_t *le = &free_list;
  102ca7:	c7 45 f0 e0 ce 11 00 	movl   $0x11cee0,-0x10(%ebp)
    // TODO: optimize (next-fit)

    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
  102cae:	eb 1c                	jmp    102ccc <default_alloc_pages+0x70>
        // 将le节点转换为关联的Page结构
        struct Page *p = le2page(le, page_link);
  102cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102cb3:	83 e8 0c             	sub    $0xc,%eax
  102cb6:	89 45 ec             	mov    %eax,-0x14(%ebp)
        if (p->property >= n) {
  102cb9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102cbc:	8b 40 08             	mov    0x8(%eax),%eax
  102cbf:	39 45 08             	cmp    %eax,0x8(%ebp)
  102cc2:	77 08                	ja     102ccc <default_alloc_pages+0x70>
            // 发现一个满足要求的，空闲页数大于等于N的空闲块
            page = p;
  102cc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  102cc7:	89 45 f4             	mov    %eax,-0xc(%ebp)
            break;
  102cca:	eb 18                	jmp    102ce4 <default_alloc_pages+0x88>
  102ccc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102ccf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return listelm->next;
  102cd2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  102cd5:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  102cd8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  102cdb:	81 7d f0 e0 ce 11 00 	cmpl   $0x11cee0,-0x10(%ebp)
  102ce2:	75 cc                	jne    102cb0 <default_alloc_pages+0x54>
        }
    }
    // 如果page != null代表找到了，分配成功。反之则分配物理内存失败
    if (page != NULL) {
  102ce4:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  102ce8:	0f 84 f2 00 00 00    	je     102de0 <default_alloc_pages+0x184>
        if (page->property > n) {
  102cee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102cf1:	8b 40 08             	mov    0x8(%eax),%eax
  102cf4:	39 45 08             	cmp    %eax,0x8(%ebp)
  102cf7:	0f 83 8f 00 00 00    	jae    102d8c <default_alloc_pages+0x130>
            // 如果空闲块的大小不是正合适(page->property != n)
            // 按照指针偏移，找到按序后面第N个Page结构p
            struct Page *p = page + n;
  102cfd:	8b 55 08             	mov    0x8(%ebp),%edx
  102d00:	89 d0                	mov    %edx,%eax
  102d02:	c1 e0 02             	shl    $0x2,%eax
  102d05:	01 d0                	add    %edx,%eax
  102d07:	c1 e0 02             	shl    $0x2,%eax
  102d0a:	89 c2                	mov    %eax,%edx
  102d0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d0f:	01 d0                	add    %edx,%eax
  102d11:	89 45 e8             	mov    %eax,-0x18(%ebp)
            // p其空闲块个数 = 当前找到的空闲块数量 - n
            p->property = page->property - n;
  102d14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d17:	8b 40 08             	mov    0x8(%eax),%eax
  102d1a:	2b 45 08             	sub    0x8(%ebp),%eax
  102d1d:	89 c2                	mov    %eax,%edx
  102d1f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d22:	89 50 08             	mov    %edx,0x8(%eax)
            SetPageProperty(p);
  102d25:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d28:	83 c0 04             	add    $0x4,%eax
  102d2b:	c7 45 cc 01 00 00 00 	movl   $0x1,-0x34(%ebp)
  102d32:	89 45 c8             	mov    %eax,-0x38(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102d35:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102d38:	8b 55 cc             	mov    -0x34(%ebp),%edx
  102d3b:	0f ab 10             	bts    %edx,(%eax)
}
  102d3e:	90                   	nop
            // 按对应的物理地址顺序，将p加入到空闲链表中对应的位置
            list_add_after(&(page->page_link), &(p->page_link));
  102d3f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102d42:	83 c0 0c             	add    $0xc,%eax
  102d45:	8b 55 f4             	mov    -0xc(%ebp),%edx
  102d48:	83 c2 0c             	add    $0xc,%edx
  102d4b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  102d4e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    __list_add(elm, listelm, listelm->next);
  102d51:	8b 45 e0             	mov    -0x20(%ebp),%eax
  102d54:	8b 40 04             	mov    0x4(%eax),%eax
  102d57:	8b 55 dc             	mov    -0x24(%ebp),%edx
  102d5a:	89 55 d8             	mov    %edx,-0x28(%ebp)
  102d5d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102d60:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  102d63:	89 45 d0             	mov    %eax,-0x30(%ebp)
    prev->next = next->prev = elm;
  102d66:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d69:	8b 55 d8             	mov    -0x28(%ebp),%edx
  102d6c:	89 10                	mov    %edx,(%eax)
  102d6e:	8b 45 d0             	mov    -0x30(%ebp),%eax
  102d71:	8b 10                	mov    (%eax),%edx
  102d73:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102d76:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  102d79:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102d7c:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102d7f:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  102d82:	8b 45 d8             	mov    -0x28(%ebp),%eax
  102d85:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  102d88:	89 10                	mov    %edx,(%eax)
}
  102d8a:	90                   	nop
}
  102d8b:	90                   	nop
        }
        // 在将当前page从空间链表中移除
        list_del(&(page->page_link));
  102d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102d8f:	83 c0 0c             	add    $0xc,%eax
  102d92:	89 45 bc             	mov    %eax,-0x44(%ebp)
    __list_del(listelm->prev, listelm->next);
  102d95:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102d98:	8b 40 04             	mov    0x4(%eax),%eax
  102d9b:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102d9e:	8b 12                	mov    (%edx),%edx
  102da0:	89 55 b8             	mov    %edx,-0x48(%ebp)
  102da3:	89 45 b4             	mov    %eax,-0x4c(%ebp)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
  102da6:	8b 45 b8             	mov    -0x48(%ebp),%eax
  102da9:	8b 55 b4             	mov    -0x4c(%ebp),%edx
  102dac:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102daf:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102db2:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102db5:	89 10                	mov    %edx,(%eax)
}
  102db7:	90                   	nop
}
  102db8:	90                   	nop
        // 闲链表整体空闲页数量自减n
        nr_free -= n;
  102db9:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  102dbe:	2b 45 08             	sub    0x8(%ebp),%eax
  102dc1:	a3 e8 ce 11 00       	mov    %eax,0x11cee8
        // 清楚page的property(因为非空闲块的头Page的property都为0)
        ClearPageProperty(page);
  102dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102dc9:	83 c0 04             	add    $0x4,%eax
  102dcc:	c7 45 c4 01 00 00 00 	movl   $0x1,-0x3c(%ebp)
  102dd3:	89 45 c0             	mov    %eax,-0x40(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102dd6:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102dd9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102ddc:	0f b3 10             	btr    %edx,(%eax)
}
  102ddf:	90                   	nop
    }
    return page;
  102de0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  102de3:	89 ec                	mov    %ebp,%esp
  102de5:	5d                   	pop    %ebp
  102de6:	c3                   	ret    

00102de7 <default_free_pages>:

/**
 * 释放掉自base起始的连续n个物理页,n必须为正整数
 * */
static void
default_free_pages(struct Page *base, size_t n) {
  102de7:	55                   	push   %ebp
  102de8:	89 e5                	mov    %esp,%ebp
  102dea:	81 ec 98 00 00 00    	sub    $0x98,%esp
    assert(n > 0);
  102df0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  102df4:	75 24                	jne    102e1a <default_free_pages+0x33>
  102df6:	c7 44 24 0c 50 69 10 	movl   $0x106950,0xc(%esp)
  102dfd:	00 
  102dfe:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  102e05:	00 
  102e06:	c7 44 24 04 41 01 00 	movl   $0x141,0x4(%esp)
  102e0d:	00 
  102e0e:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  102e15:	e8 cd de ff ff       	call   100ce7 <__panic>
    struct Page *p = base;
  102e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  102e1d:	89 45 f4             	mov    %eax,-0xc(%ebp)

    // 遍历这N个连续的Page页，将其相关属性设置为空闲
    for (; p != base + n; p ++) {
  102e20:	e9 9d 00 00 00       	jmp    102ec2 <default_free_pages+0xdb>
        assert(!PageReserved(p) && !PageProperty(p));
  102e25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e28:	83 c0 04             	add    $0x4,%eax
  102e2b:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  102e32:	89 45 e8             	mov    %eax,-0x18(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102e35:	8b 45 e8             	mov    -0x18(%ebp),%eax
  102e38:	8b 55 ec             	mov    -0x14(%ebp),%edx
  102e3b:	0f a3 10             	bt     %edx,(%eax)
  102e3e:	19 c0                	sbb    %eax,%eax
  102e40:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    return oldbit != 0;
  102e43:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  102e47:	0f 95 c0             	setne  %al
  102e4a:	0f b6 c0             	movzbl %al,%eax
  102e4d:	85 c0                	test   %eax,%eax
  102e4f:	75 2c                	jne    102e7d <default_free_pages+0x96>
  102e51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102e54:	83 c0 04             	add    $0x4,%eax
  102e57:	c7 45 e0 01 00 00 00 	movl   $0x1,-0x20(%ebp)
  102e5e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  102e61:	8b 45 dc             	mov    -0x24(%ebp),%eax
  102e64:	8b 55 e0             	mov    -0x20(%ebp),%edx
  102e67:	0f a3 10             	bt     %edx,(%eax)
  102e6a:	19 c0                	sbb    %eax,%eax
  102e6c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    return oldbit != 0;
  102e6f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  102e73:	0f 95 c0             	setne  %al
  102e76:	0f b6 c0             	movzbl %al,%eax
  102e79:	85 c0                	test   %eax,%eax
  102e7b:	74 24                	je     102ea1 <default_free_pages+0xba>
  102e7d:	c7 44 24 0c 94 69 10 	movl   $0x106994,0xc(%esp)
  102e84:	00 
  102e85:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  102e8c:	00 
  102e8d:	c7 44 24 04 46 01 00 	movl   $0x146,0x4(%esp)
  102e94:	00 
  102e95:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  102e9c:	e8 46 de ff ff       	call   100ce7 <__panic>
        p->flags = 0;
  102ea1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ea4:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
        set_page_ref(p, 0);
  102eab:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  102eb2:	00 
  102eb3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102eb6:	89 04 24             	mov    %eax,(%esp)
  102eb9:	e8 fd fb ff ff       	call   102abb <set_page_ref>
    for (; p != base + n; p ++) {
  102ebe:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
  102ec2:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ec5:	89 d0                	mov    %edx,%eax
  102ec7:	c1 e0 02             	shl    $0x2,%eax
  102eca:	01 d0                	add    %edx,%eax
  102ecc:	c1 e0 02             	shl    $0x2,%eax
  102ecf:	89 c2                	mov    %eax,%edx
  102ed1:	8b 45 08             	mov    0x8(%ebp),%eax
  102ed4:	01 d0                	add    %edx,%eax
  102ed6:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102ed9:	0f 85 46 ff ff ff    	jne    102e25 <default_free_pages+0x3e>
    }

    // 由于被释放了N个空闲物理页，base头Page的property设置为n
    base->property = n;
  102edf:	8b 45 08             	mov    0x8(%ebp),%eax
  102ee2:	8b 55 0c             	mov    0xc(%ebp),%edx
  102ee5:	89 50 08             	mov    %edx,0x8(%eax)
    SetPageProperty(base);
  102ee8:	8b 45 08             	mov    0x8(%ebp),%eax
  102eeb:	83 c0 04             	add    $0x4,%eax
  102eee:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  102ef5:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102ef8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  102efb:	8b 55 d0             	mov    -0x30(%ebp),%edx
  102efe:	0f ab 10             	bts    %edx,(%eax)
}
  102f01:	90                   	nop
  102f02:	c7 45 d4 e0 ce 11 00 	movl   $0x11cee0,-0x2c(%ebp)
    return listelm->next;
  102f09:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  102f0c:	8b 40 04             	mov    0x4(%eax),%eax

    // 下面进行空闲链表相关操作
    list_entry_t *le = list_next(&free_list);
  102f0f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    // 迭代空闲链表中的每一个节点
    while (le != &free_list) {
  102f12:	e9 0e 01 00 00       	jmp    103025 <default_free_pages+0x23e>
        // 获得节点对应的Page结构
        p = le2page(le, page_link);
  102f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f1a:	83 e8 0c             	sub    $0xc,%eax
  102f1d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  102f20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  102f23:	89 45 c8             	mov    %eax,-0x38(%ebp)
  102f26:	8b 45 c8             	mov    -0x38(%ebp),%eax
  102f29:	8b 40 04             	mov    0x4(%eax),%eax
        le = list_next(le);
  102f2c:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // TODO: optimize
        if (base + base->property == p) {
  102f2f:	8b 45 08             	mov    0x8(%ebp),%eax
  102f32:	8b 50 08             	mov    0x8(%eax),%edx
  102f35:	89 d0                	mov    %edx,%eax
  102f37:	c1 e0 02             	shl    $0x2,%eax
  102f3a:	01 d0                	add    %edx,%eax
  102f3c:	c1 e0 02             	shl    $0x2,%eax
  102f3f:	89 c2                	mov    %eax,%edx
  102f41:	8b 45 08             	mov    0x8(%ebp),%eax
  102f44:	01 d0                	add    %edx,%eax
  102f46:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  102f49:	75 5d                	jne    102fa8 <default_free_pages+0x1c1>
            // 如果当前base释放了N个物理页后，尾部正好能和Page p连上，则进行两个空闲块的合并
            base->property += p->property;
  102f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  102f4e:	8b 50 08             	mov    0x8(%eax),%edx
  102f51:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f54:	8b 40 08             	mov    0x8(%eax),%eax
  102f57:	01 c2                	add    %eax,%edx
  102f59:	8b 45 08             	mov    0x8(%ebp),%eax
  102f5c:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(p);
  102f5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f62:	83 c0 04             	add    $0x4,%eax
  102f65:	c7 45 b8 01 00 00 00 	movl   $0x1,-0x48(%ebp)
  102f6c:	89 45 b4             	mov    %eax,-0x4c(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102f6f:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  102f72:	8b 55 b8             	mov    -0x48(%ebp),%edx
  102f75:	0f b3 10             	btr    %edx,(%eax)
}
  102f78:	90                   	nop
            list_del(&(p->page_link));
  102f79:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102f7c:	83 c0 0c             	add    $0xc,%eax
  102f7f:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    __list_del(listelm->prev, listelm->next);
  102f82:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  102f85:	8b 40 04             	mov    0x4(%eax),%eax
  102f88:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  102f8b:	8b 12                	mov    (%edx),%edx
  102f8d:	89 55 c0             	mov    %edx,-0x40(%ebp)
  102f90:	89 45 bc             	mov    %eax,-0x44(%ebp)
    prev->next = next;
  102f93:	8b 45 c0             	mov    -0x40(%ebp),%eax
  102f96:	8b 55 bc             	mov    -0x44(%ebp),%edx
  102f99:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  102f9c:	8b 45 bc             	mov    -0x44(%ebp),%eax
  102f9f:	8b 55 c0             	mov    -0x40(%ebp),%edx
  102fa2:	89 10                	mov    %edx,(%eax)
}
  102fa4:	90                   	nop
}
  102fa5:	90                   	nop
  102fa6:	eb 7d                	jmp    103025 <default_free_pages+0x23e>
        }
        else if (p + p->property == base) {
  102fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fab:	8b 50 08             	mov    0x8(%eax),%edx
  102fae:	89 d0                	mov    %edx,%eax
  102fb0:	c1 e0 02             	shl    $0x2,%eax
  102fb3:	01 d0                	add    %edx,%eax
  102fb5:	c1 e0 02             	shl    $0x2,%eax
  102fb8:	89 c2                	mov    %eax,%edx
  102fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fbd:	01 d0                	add    %edx,%eax
  102fbf:	39 45 08             	cmp    %eax,0x8(%ebp)
  102fc2:	75 61                	jne    103025 <default_free_pages+0x23e>
            // 如果当前Page p能和base头连上，则进行两个空闲块的合并
            p->property += base->property;
  102fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fc7:	8b 50 08             	mov    0x8(%eax),%edx
  102fca:	8b 45 08             	mov    0x8(%ebp),%eax
  102fcd:	8b 40 08             	mov    0x8(%eax),%eax
  102fd0:	01 c2                	add    %eax,%edx
  102fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102fd5:	89 50 08             	mov    %edx,0x8(%eax)
            ClearPageProperty(base);
  102fd8:	8b 45 08             	mov    0x8(%ebp),%eax
  102fdb:	83 c0 04             	add    $0x4,%eax
  102fde:	c7 45 a4 01 00 00 00 	movl   $0x1,-0x5c(%ebp)
  102fe5:	89 45 a0             	mov    %eax,-0x60(%ebp)
    asm volatile ("btrl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  102fe8:	8b 45 a0             	mov    -0x60(%ebp),%eax
  102feb:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  102fee:	0f b3 10             	btr    %edx,(%eax)
}
  102ff1:	90                   	nop
            base = p;
  102ff2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ff5:	89 45 08             	mov    %eax,0x8(%ebp)
            list_del(&(p->page_link));
  102ff8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  102ffb:	83 c0 0c             	add    $0xc,%eax
  102ffe:	89 45 b0             	mov    %eax,-0x50(%ebp)
    __list_del(listelm->prev, listelm->next);
  103001:	8b 45 b0             	mov    -0x50(%ebp),%eax
  103004:	8b 40 04             	mov    0x4(%eax),%eax
  103007:	8b 55 b0             	mov    -0x50(%ebp),%edx
  10300a:	8b 12                	mov    (%edx),%edx
  10300c:	89 55 ac             	mov    %edx,-0x54(%ebp)
  10300f:	89 45 a8             	mov    %eax,-0x58(%ebp)
    prev->next = next;
  103012:	8b 45 ac             	mov    -0x54(%ebp),%eax
  103015:	8b 55 a8             	mov    -0x58(%ebp),%edx
  103018:	89 50 04             	mov    %edx,0x4(%eax)
    next->prev = prev;
  10301b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10301e:	8b 55 ac             	mov    -0x54(%ebp),%edx
  103021:	89 10                	mov    %edx,(%eax)
}
  103023:	90                   	nop
}
  103024:	90                   	nop
    while (le != &free_list) {
  103025:	81 7d f0 e0 ce 11 00 	cmpl   $0x11cee0,-0x10(%ebp)
  10302c:	0f 85 e5 fe ff ff    	jne    102f17 <default_free_pages+0x130>
        }
    }
    // 空闲链表整体空闲页数量自增n
    nr_free += n;
  103032:	8b 15 e8 ce 11 00    	mov    0x11cee8,%edx
  103038:	8b 45 0c             	mov    0xc(%ebp),%eax
  10303b:	01 d0                	add    %edx,%eax
  10303d:	a3 e8 ce 11 00       	mov    %eax,0x11cee8
  103042:	c7 45 9c e0 ce 11 00 	movl   $0x11cee0,-0x64(%ebp)
    return listelm->next;
  103049:	8b 45 9c             	mov    -0x64(%ebp),%eax
  10304c:	8b 40 04             	mov    0x4(%eax),%eax
    le = list_next(&free_list);
  10304f:	89 45 f0             	mov    %eax,-0x10(%ebp)

    // 迭代空闲链表中的每一个节点
    while (le != &free_list) {
  103052:	eb 74                	jmp    1030c8 <default_free_pages+0x2e1>
        // 转为Page结构
        p = le2page(le, page_link);
  103054:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103057:	83 e8 0c             	sub    $0xc,%eax
  10305a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        if (base + base->property <= p) {
  10305d:	8b 45 08             	mov    0x8(%ebp),%eax
  103060:	8b 50 08             	mov    0x8(%eax),%edx
  103063:	89 d0                	mov    %edx,%eax
  103065:	c1 e0 02             	shl    $0x2,%eax
  103068:	01 d0                	add    %edx,%eax
  10306a:	c1 e0 02             	shl    $0x2,%eax
  10306d:	89 c2                	mov    %eax,%edx
  10306f:	8b 45 08             	mov    0x8(%ebp),%eax
  103072:	01 d0                	add    %edx,%eax
  103074:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103077:	72 40                	jb     1030b9 <default_free_pages+0x2d2>
            // 进行空闲链表结构的校验，不能存在交叉覆盖的地方
            assert(base + base->property != p);
  103079:	8b 45 08             	mov    0x8(%ebp),%eax
  10307c:	8b 50 08             	mov    0x8(%eax),%edx
  10307f:	89 d0                	mov    %edx,%eax
  103081:	c1 e0 02             	shl    $0x2,%eax
  103084:	01 d0                	add    %edx,%eax
  103086:	c1 e0 02             	shl    $0x2,%eax
  103089:	89 c2                	mov    %eax,%edx
  10308b:	8b 45 08             	mov    0x8(%ebp),%eax
  10308e:	01 d0                	add    %edx,%eax
  103090:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  103093:	75 3e                	jne    1030d3 <default_free_pages+0x2ec>
  103095:	c7 44 24 0c b9 69 10 	movl   $0x1069b9,0xc(%esp)
  10309c:	00 
  10309d:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1030a4:	00 
  1030a5:	c7 44 24 04 6f 01 00 	movl   $0x16f,0x4(%esp)
  1030ac:	00 
  1030ad:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1030b4:	e8 2e dc ff ff       	call   100ce7 <__panic>
  1030b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030bc:	89 45 98             	mov    %eax,-0x68(%ebp)
  1030bf:	8b 45 98             	mov    -0x68(%ebp),%eax
  1030c2:	8b 40 04             	mov    0x4(%eax),%eax
            break;
        }
        le = list_next(le);
  1030c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    while (le != &free_list) {
  1030c8:	81 7d f0 e0 ce 11 00 	cmpl   $0x11cee0,-0x10(%ebp)
  1030cf:	75 83                	jne    103054 <default_free_pages+0x26d>
  1030d1:	eb 01                	jmp    1030d4 <default_free_pages+0x2ed>
            break;
  1030d3:	90                   	nop
    }
    // 将base加入到空闲链表之中
    list_add_before(le, &(base->page_link));
  1030d4:	8b 45 08             	mov    0x8(%ebp),%eax
  1030d7:	8d 50 0c             	lea    0xc(%eax),%edx
  1030da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1030dd:	89 45 94             	mov    %eax,-0x6c(%ebp)
  1030e0:	89 55 90             	mov    %edx,-0x70(%ebp)
    __list_add(elm, listelm->prev, listelm);
  1030e3:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1030e6:	8b 00                	mov    (%eax),%eax
  1030e8:	8b 55 90             	mov    -0x70(%ebp),%edx
  1030eb:	89 55 8c             	mov    %edx,-0x74(%ebp)
  1030ee:	89 45 88             	mov    %eax,-0x78(%ebp)
  1030f1:	8b 45 94             	mov    -0x6c(%ebp),%eax
  1030f4:	89 45 84             	mov    %eax,-0x7c(%ebp)
    prev->next = next->prev = elm;
  1030f7:	8b 45 84             	mov    -0x7c(%ebp),%eax
  1030fa:	8b 55 8c             	mov    -0x74(%ebp),%edx
  1030fd:	89 10                	mov    %edx,(%eax)
  1030ff:	8b 45 84             	mov    -0x7c(%ebp),%eax
  103102:	8b 10                	mov    (%eax),%edx
  103104:	8b 45 88             	mov    -0x78(%ebp),%eax
  103107:	89 50 04             	mov    %edx,0x4(%eax)
    elm->next = next;
  10310a:	8b 45 8c             	mov    -0x74(%ebp),%eax
  10310d:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103110:	89 50 04             	mov    %edx,0x4(%eax)
    elm->prev = prev;
  103113:	8b 45 8c             	mov    -0x74(%ebp),%eax
  103116:	8b 55 88             	mov    -0x78(%ebp),%edx
  103119:	89 10                	mov    %edx,(%eax)
}
  10311b:	90                   	nop
}
  10311c:	90                   	nop
}
  10311d:	90                   	nop
  10311e:	89 ec                	mov    %ebp,%esp
  103120:	5d                   	pop    %ebp
  103121:	c3                   	ret    

00103122 <default_nr_free_pages>:


static size_t
default_nr_free_pages(void) {
  103122:	55                   	push   %ebp
  103123:	89 e5                	mov    %esp,%ebp
    return nr_free;
  103125:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
}
  10312a:	5d                   	pop    %ebp
  10312b:	c3                   	ret    

0010312c <basic_check>:

static void
basic_check(void) {
  10312c:	55                   	push   %ebp
  10312d:	89 e5                	mov    %esp,%ebp
  10312f:	83 ec 48             	sub    $0x48,%esp
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
  103132:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  103139:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10313c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10313f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103142:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert((p0 = alloc_page()) != NULL);
  103145:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10314c:	e8 ed 0e 00 00       	call   10403e <alloc_pages>
  103151:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103154:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  103158:	75 24                	jne    10317e <basic_check+0x52>
  10315a:	c7 44 24 0c d4 69 10 	movl   $0x1069d4,0xc(%esp)
  103161:	00 
  103162:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103169:	00 
  10316a:	c7 44 24 04 82 01 00 	movl   $0x182,0x4(%esp)
  103171:	00 
  103172:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103179:	e8 69 db ff ff       	call   100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
  10317e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103185:	e8 b4 0e 00 00       	call   10403e <alloc_pages>
  10318a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10318d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103191:	75 24                	jne    1031b7 <basic_check+0x8b>
  103193:	c7 44 24 0c f0 69 10 	movl   $0x1069f0,0xc(%esp)
  10319a:	00 
  10319b:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1031a2:	00 
  1031a3:	c7 44 24 04 83 01 00 	movl   $0x183,0x4(%esp)
  1031aa:	00 
  1031ab:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1031b2:	e8 30 db ff ff       	call   100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1031b7:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1031be:	e8 7b 0e 00 00       	call   10403e <alloc_pages>
  1031c3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1031c6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1031ca:	75 24                	jne    1031f0 <basic_check+0xc4>
  1031cc:	c7 44 24 0c 0c 6a 10 	movl   $0x106a0c,0xc(%esp)
  1031d3:	00 
  1031d4:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1031db:	00 
  1031dc:	c7 44 24 04 84 01 00 	movl   $0x184,0x4(%esp)
  1031e3:	00 
  1031e4:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1031eb:	e8 f7 da ff ff       	call   100ce7 <__panic>

    assert(p0 != p1 && p0 != p2 && p1 != p2);
  1031f0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031f3:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  1031f6:	74 10                	je     103208 <basic_check+0xdc>
  1031f8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1031fb:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  1031fe:	74 08                	je     103208 <basic_check+0xdc>
  103200:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103203:	3b 45 f4             	cmp    -0xc(%ebp),%eax
  103206:	75 24                	jne    10322c <basic_check+0x100>
  103208:	c7 44 24 0c 28 6a 10 	movl   $0x106a28,0xc(%esp)
  10320f:	00 
  103210:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103217:	00 
  103218:	c7 44 24 04 86 01 00 	movl   $0x186,0x4(%esp)
  10321f:	00 
  103220:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103227:	e8 bb da ff ff       	call   100ce7 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
  10322c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10322f:	89 04 24             	mov    %eax,(%esp)
  103232:	e8 7a f8 ff ff       	call   102ab1 <page_ref>
  103237:	85 c0                	test   %eax,%eax
  103239:	75 1e                	jne    103259 <basic_check+0x12d>
  10323b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10323e:	89 04 24             	mov    %eax,(%esp)
  103241:	e8 6b f8 ff ff       	call   102ab1 <page_ref>
  103246:	85 c0                	test   %eax,%eax
  103248:	75 0f                	jne    103259 <basic_check+0x12d>
  10324a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10324d:	89 04 24             	mov    %eax,(%esp)
  103250:	e8 5c f8 ff ff       	call   102ab1 <page_ref>
  103255:	85 c0                	test   %eax,%eax
  103257:	74 24                	je     10327d <basic_check+0x151>
  103259:	c7 44 24 0c 4c 6a 10 	movl   $0x106a4c,0xc(%esp)
  103260:	00 
  103261:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103268:	00 
  103269:	c7 44 24 04 87 01 00 	movl   $0x187,0x4(%esp)
  103270:	00 
  103271:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103278:	e8 6a da ff ff       	call   100ce7 <__panic>

    assert(page2pa(p0) < npage * PGSIZE);
  10327d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103280:	89 04 24             	mov    %eax,(%esp)
  103283:	e8 11 f8 ff ff       	call   102a99 <page2pa>
  103288:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  10328e:	c1 e2 0c             	shl    $0xc,%edx
  103291:	39 d0                	cmp    %edx,%eax
  103293:	72 24                	jb     1032b9 <basic_check+0x18d>
  103295:	c7 44 24 0c 88 6a 10 	movl   $0x106a88,0xc(%esp)
  10329c:	00 
  10329d:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1032a4:	00 
  1032a5:	c7 44 24 04 89 01 00 	movl   $0x189,0x4(%esp)
  1032ac:	00 
  1032ad:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1032b4:	e8 2e da ff ff       	call   100ce7 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
  1032b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1032bc:	89 04 24             	mov    %eax,(%esp)
  1032bf:	e8 d5 f7 ff ff       	call   102a99 <page2pa>
  1032c4:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  1032ca:	c1 e2 0c             	shl    $0xc,%edx
  1032cd:	39 d0                	cmp    %edx,%eax
  1032cf:	72 24                	jb     1032f5 <basic_check+0x1c9>
  1032d1:	c7 44 24 0c a5 6a 10 	movl   $0x106aa5,0xc(%esp)
  1032d8:	00 
  1032d9:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1032e0:	00 
  1032e1:	c7 44 24 04 8a 01 00 	movl   $0x18a,0x4(%esp)
  1032e8:	00 
  1032e9:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1032f0:	e8 f2 d9 ff ff       	call   100ce7 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
  1032f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1032f8:	89 04 24             	mov    %eax,(%esp)
  1032fb:	e8 99 f7 ff ff       	call   102a99 <page2pa>
  103300:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  103306:	c1 e2 0c             	shl    $0xc,%edx
  103309:	39 d0                	cmp    %edx,%eax
  10330b:	72 24                	jb     103331 <basic_check+0x205>
  10330d:	c7 44 24 0c c2 6a 10 	movl   $0x106ac2,0xc(%esp)
  103314:	00 
  103315:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  10331c:	00 
  10331d:	c7 44 24 04 8b 01 00 	movl   $0x18b,0x4(%esp)
  103324:	00 
  103325:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  10332c:	e8 b6 d9 ff ff       	call   100ce7 <__panic>

    list_entry_t free_list_store = free_list;
  103331:	a1 e0 ce 11 00       	mov    0x11cee0,%eax
  103336:	8b 15 e4 ce 11 00    	mov    0x11cee4,%edx
  10333c:	89 45 d0             	mov    %eax,-0x30(%ebp)
  10333f:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  103342:	c7 45 dc e0 ce 11 00 	movl   $0x11cee0,-0x24(%ebp)
    elm->prev = elm->next = elm;
  103349:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10334c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10334f:	89 50 04             	mov    %edx,0x4(%eax)
  103352:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103355:	8b 50 04             	mov    0x4(%eax),%edx
  103358:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10335b:	89 10                	mov    %edx,(%eax)
}
  10335d:	90                   	nop
  10335e:	c7 45 e0 e0 ce 11 00 	movl   $0x11cee0,-0x20(%ebp)
    return list->next == list;
  103365:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103368:	8b 40 04             	mov    0x4(%eax),%eax
  10336b:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  10336e:	0f 94 c0             	sete   %al
  103371:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103374:	85 c0                	test   %eax,%eax
  103376:	75 24                	jne    10339c <basic_check+0x270>
  103378:	c7 44 24 0c df 6a 10 	movl   $0x106adf,0xc(%esp)
  10337f:	00 
  103380:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103387:	00 
  103388:	c7 44 24 04 8f 01 00 	movl   $0x18f,0x4(%esp)
  10338f:	00 
  103390:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103397:	e8 4b d9 ff ff       	call   100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
  10339c:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  1033a1:	89 45 e8             	mov    %eax,-0x18(%ebp)
    nr_free = 0;
  1033a4:	c7 05 e8 ce 11 00 00 	movl   $0x0,0x11cee8
  1033ab:	00 00 00 

    assert(alloc_page() == NULL);
  1033ae:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1033b5:	e8 84 0c 00 00       	call   10403e <alloc_pages>
  1033ba:	85 c0                	test   %eax,%eax
  1033bc:	74 24                	je     1033e2 <basic_check+0x2b6>
  1033be:	c7 44 24 0c f6 6a 10 	movl   $0x106af6,0xc(%esp)
  1033c5:	00 
  1033c6:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1033cd:	00 
  1033ce:	c7 44 24 04 94 01 00 	movl   $0x194,0x4(%esp)
  1033d5:	00 
  1033d6:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1033dd:	e8 05 d9 ff ff       	call   100ce7 <__panic>

    free_page(p0);
  1033e2:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033e9:	00 
  1033ea:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1033ed:	89 04 24             	mov    %eax,(%esp)
  1033f0:	e8 83 0c 00 00       	call   104078 <free_pages>
    free_page(p1);
  1033f5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1033fc:	00 
  1033fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  103400:	89 04 24             	mov    %eax,(%esp)
  103403:	e8 70 0c 00 00       	call   104078 <free_pages>
    free_page(p2);
  103408:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10340f:	00 
  103410:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103413:	89 04 24             	mov    %eax,(%esp)
  103416:	e8 5d 0c 00 00       	call   104078 <free_pages>
    assert(nr_free == 3);
  10341b:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  103420:	83 f8 03             	cmp    $0x3,%eax
  103423:	74 24                	je     103449 <basic_check+0x31d>
  103425:	c7 44 24 0c 0b 6b 10 	movl   $0x106b0b,0xc(%esp)
  10342c:	00 
  10342d:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103434:	00 
  103435:	c7 44 24 04 99 01 00 	movl   $0x199,0x4(%esp)
  10343c:	00 
  10343d:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103444:	e8 9e d8 ff ff       	call   100ce7 <__panic>

    assert((p0 = alloc_page()) != NULL);
  103449:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103450:	e8 e9 0b 00 00       	call   10403e <alloc_pages>
  103455:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103458:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
  10345c:	75 24                	jne    103482 <basic_check+0x356>
  10345e:	c7 44 24 0c d4 69 10 	movl   $0x1069d4,0xc(%esp)
  103465:	00 
  103466:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  10346d:	00 
  10346e:	c7 44 24 04 9b 01 00 	movl   $0x19b,0x4(%esp)
  103475:	00 
  103476:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  10347d:	e8 65 d8 ff ff       	call   100ce7 <__panic>
    assert((p1 = alloc_page()) != NULL);
  103482:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103489:	e8 b0 0b 00 00       	call   10403e <alloc_pages>
  10348e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103491:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103495:	75 24                	jne    1034bb <basic_check+0x38f>
  103497:	c7 44 24 0c f0 69 10 	movl   $0x1069f0,0xc(%esp)
  10349e:	00 
  10349f:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1034a6:	00 
  1034a7:	c7 44 24 04 9c 01 00 	movl   $0x19c,0x4(%esp)
  1034ae:	00 
  1034af:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1034b6:	e8 2c d8 ff ff       	call   100ce7 <__panic>
    assert((p2 = alloc_page()) != NULL);
  1034bb:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034c2:	e8 77 0b 00 00       	call   10403e <alloc_pages>
  1034c7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1034ca:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1034ce:	75 24                	jne    1034f4 <basic_check+0x3c8>
  1034d0:	c7 44 24 0c 0c 6a 10 	movl   $0x106a0c,0xc(%esp)
  1034d7:	00 
  1034d8:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1034df:	00 
  1034e0:	c7 44 24 04 9d 01 00 	movl   $0x19d,0x4(%esp)
  1034e7:	00 
  1034e8:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1034ef:	e8 f3 d7 ff ff       	call   100ce7 <__panic>

    assert(alloc_page() == NULL);
  1034f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1034fb:	e8 3e 0b 00 00       	call   10403e <alloc_pages>
  103500:	85 c0                	test   %eax,%eax
  103502:	74 24                	je     103528 <basic_check+0x3fc>
  103504:	c7 44 24 0c f6 6a 10 	movl   $0x106af6,0xc(%esp)
  10350b:	00 
  10350c:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103513:	00 
  103514:	c7 44 24 04 9f 01 00 	movl   $0x19f,0x4(%esp)
  10351b:	00 
  10351c:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103523:	e8 bf d7 ff ff       	call   100ce7 <__panic>

    free_page(p0);
  103528:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10352f:	00 
  103530:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103533:	89 04 24             	mov    %eax,(%esp)
  103536:	e8 3d 0b 00 00       	call   104078 <free_pages>
  10353b:	c7 45 d8 e0 ce 11 00 	movl   $0x11cee0,-0x28(%ebp)
  103542:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103545:	8b 40 04             	mov    0x4(%eax),%eax
  103548:	39 45 d8             	cmp    %eax,-0x28(%ebp)
  10354b:	0f 94 c0             	sete   %al
  10354e:	0f b6 c0             	movzbl %al,%eax
    assert(!list_empty(&free_list));
  103551:	85 c0                	test   %eax,%eax
  103553:	74 24                	je     103579 <basic_check+0x44d>
  103555:	c7 44 24 0c 18 6b 10 	movl   $0x106b18,0xc(%esp)
  10355c:	00 
  10355d:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103564:	00 
  103565:	c7 44 24 04 a2 01 00 	movl   $0x1a2,0x4(%esp)
  10356c:	00 
  10356d:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103574:	e8 6e d7 ff ff       	call   100ce7 <__panic>

    struct Page *p;
    assert((p = alloc_page()) == p0);
  103579:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103580:	e8 b9 0a 00 00       	call   10403e <alloc_pages>
  103585:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  103588:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10358b:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  10358e:	74 24                	je     1035b4 <basic_check+0x488>
  103590:	c7 44 24 0c 30 6b 10 	movl   $0x106b30,0xc(%esp)
  103597:	00 
  103598:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  10359f:	00 
  1035a0:	c7 44 24 04 a5 01 00 	movl   $0x1a5,0x4(%esp)
  1035a7:	00 
  1035a8:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1035af:	e8 33 d7 ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  1035b4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1035bb:	e8 7e 0a 00 00       	call   10403e <alloc_pages>
  1035c0:	85 c0                	test   %eax,%eax
  1035c2:	74 24                	je     1035e8 <basic_check+0x4bc>
  1035c4:	c7 44 24 0c f6 6a 10 	movl   $0x106af6,0xc(%esp)
  1035cb:	00 
  1035cc:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1035d3:	00 
  1035d4:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
  1035db:	00 
  1035dc:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1035e3:	e8 ff d6 ff ff       	call   100ce7 <__panic>

    assert(nr_free == 0);
  1035e8:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  1035ed:	85 c0                	test   %eax,%eax
  1035ef:	74 24                	je     103615 <basic_check+0x4e9>
  1035f1:	c7 44 24 0c 49 6b 10 	movl   $0x106b49,0xc(%esp)
  1035f8:	00 
  1035f9:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103600:	00 
  103601:	c7 44 24 04 a8 01 00 	movl   $0x1a8,0x4(%esp)
  103608:	00 
  103609:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103610:	e8 d2 d6 ff ff       	call   100ce7 <__panic>
    free_list = free_list_store;
  103615:	8b 45 d0             	mov    -0x30(%ebp),%eax
  103618:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10361b:	a3 e0 ce 11 00       	mov    %eax,0x11cee0
  103620:	89 15 e4 ce 11 00    	mov    %edx,0x11cee4
    nr_free = nr_free_store;
  103626:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103629:	a3 e8 ce 11 00       	mov    %eax,0x11cee8

    free_page(p);
  10362e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103635:	00 
  103636:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103639:	89 04 24             	mov    %eax,(%esp)
  10363c:	e8 37 0a 00 00       	call   104078 <free_pages>
    free_page(p1);
  103641:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103648:	00 
  103649:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10364c:	89 04 24             	mov    %eax,(%esp)
  10364f:	e8 24 0a 00 00       	call   104078 <free_pages>
    free_page(p2);
  103654:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10365b:	00 
  10365c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10365f:	89 04 24             	mov    %eax,(%esp)
  103662:	e8 11 0a 00 00       	call   104078 <free_pages>
}
  103667:	90                   	nop
  103668:	89 ec                	mov    %ebp,%esp
  10366a:	5d                   	pop    %ebp
  10366b:	c3                   	ret    

0010366c <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
  10366c:	55                   	push   %ebp
  10366d:	89 e5                	mov    %esp,%ebp
  10366f:	81 ec 98 00 00 00    	sub    $0x98,%esp
    int count = 0, total = 0;
  103675:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  10367c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    list_entry_t *le = &free_list;
  103683:	c7 45 ec e0 ce 11 00 	movl   $0x11cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  10368a:	eb 6a                	jmp    1036f6 <default_check+0x8a>
        struct Page *p = le2page(le, page_link);
  10368c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10368f:	83 e8 0c             	sub    $0xc,%eax
  103692:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        assert(PageProperty(p));
  103695:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  103698:	83 c0 04             	add    $0x4,%eax
  10369b:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
  1036a2:	89 45 cc             	mov    %eax,-0x34(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1036a5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  1036a8:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1036ab:	0f a3 10             	bt     %edx,(%eax)
  1036ae:	19 c0                	sbb    %eax,%eax
  1036b0:	89 45 c8             	mov    %eax,-0x38(%ebp)
    return oldbit != 0;
  1036b3:	83 7d c8 00          	cmpl   $0x0,-0x38(%ebp)
  1036b7:	0f 95 c0             	setne  %al
  1036ba:	0f b6 c0             	movzbl %al,%eax
  1036bd:	85 c0                	test   %eax,%eax
  1036bf:	75 24                	jne    1036e5 <default_check+0x79>
  1036c1:	c7 44 24 0c 56 6b 10 	movl   $0x106b56,0xc(%esp)
  1036c8:	00 
  1036c9:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1036d0:	00 
  1036d1:	c7 44 24 04 b9 01 00 	movl   $0x1b9,0x4(%esp)
  1036d8:	00 
  1036d9:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1036e0:	e8 02 d6 ff ff       	call   100ce7 <__panic>
        count ++, total += p->property;
  1036e5:	ff 45 f4             	incl   -0xc(%ebp)
  1036e8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  1036eb:	8b 50 08             	mov    0x8(%eax),%edx
  1036ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1036f1:	01 d0                	add    %edx,%eax
  1036f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1036f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1036f9:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return listelm->next;
  1036fc:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  1036ff:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103702:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103705:	81 7d ec e0 ce 11 00 	cmpl   $0x11cee0,-0x14(%ebp)
  10370c:	0f 85 7a ff ff ff    	jne    10368c <default_check+0x20>
    }
    assert(total == nr_free_pages());
  103712:	e8 96 09 00 00       	call   1040ad <nr_free_pages>
  103717:	8b 55 f0             	mov    -0x10(%ebp),%edx
  10371a:	39 d0                	cmp    %edx,%eax
  10371c:	74 24                	je     103742 <default_check+0xd6>
  10371e:	c7 44 24 0c 66 6b 10 	movl   $0x106b66,0xc(%esp)
  103725:	00 
  103726:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  10372d:	00 
  10372e:	c7 44 24 04 bc 01 00 	movl   $0x1bc,0x4(%esp)
  103735:	00 
  103736:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  10373d:	e8 a5 d5 ff ff       	call   100ce7 <__panic>

    basic_check();
  103742:	e8 e5 f9 ff ff       	call   10312c <basic_check>

    struct Page *p0 = alloc_pages(5), *p1, *p2;
  103747:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  10374e:	e8 eb 08 00 00       	call   10403e <alloc_pages>
  103753:	89 45 e8             	mov    %eax,-0x18(%ebp)
    assert(p0 != NULL);
  103756:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  10375a:	75 24                	jne    103780 <default_check+0x114>
  10375c:	c7 44 24 0c 7f 6b 10 	movl   $0x106b7f,0xc(%esp)
  103763:	00 
  103764:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  10376b:	00 
  10376c:	c7 44 24 04 c1 01 00 	movl   $0x1c1,0x4(%esp)
  103773:	00 
  103774:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  10377b:	e8 67 d5 ff ff       	call   100ce7 <__panic>
    assert(!PageProperty(p0));
  103780:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103783:	83 c0 04             	add    $0x4,%eax
  103786:	c7 45 c0 01 00 00 00 	movl   $0x1,-0x40(%ebp)
  10378d:	89 45 bc             	mov    %eax,-0x44(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103790:	8b 45 bc             	mov    -0x44(%ebp),%eax
  103793:	8b 55 c0             	mov    -0x40(%ebp),%edx
  103796:	0f a3 10             	bt     %edx,(%eax)
  103799:	19 c0                	sbb    %eax,%eax
  10379b:	89 45 b8             	mov    %eax,-0x48(%ebp)
    return oldbit != 0;
  10379e:	83 7d b8 00          	cmpl   $0x0,-0x48(%ebp)
  1037a2:	0f 95 c0             	setne  %al
  1037a5:	0f b6 c0             	movzbl %al,%eax
  1037a8:	85 c0                	test   %eax,%eax
  1037aa:	74 24                	je     1037d0 <default_check+0x164>
  1037ac:	c7 44 24 0c 8a 6b 10 	movl   $0x106b8a,0xc(%esp)
  1037b3:	00 
  1037b4:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1037bb:	00 
  1037bc:	c7 44 24 04 c2 01 00 	movl   $0x1c2,0x4(%esp)
  1037c3:	00 
  1037c4:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1037cb:	e8 17 d5 ff ff       	call   100ce7 <__panic>

    list_entry_t free_list_store = free_list;
  1037d0:	a1 e0 ce 11 00       	mov    0x11cee0,%eax
  1037d5:	8b 15 e4 ce 11 00    	mov    0x11cee4,%edx
  1037db:	89 45 80             	mov    %eax,-0x80(%ebp)
  1037de:	89 55 84             	mov    %edx,-0x7c(%ebp)
  1037e1:	c7 45 b0 e0 ce 11 00 	movl   $0x11cee0,-0x50(%ebp)
    elm->prev = elm->next = elm;
  1037e8:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1037eb:	8b 55 b0             	mov    -0x50(%ebp),%edx
  1037ee:	89 50 04             	mov    %edx,0x4(%eax)
  1037f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1037f4:	8b 50 04             	mov    0x4(%eax),%edx
  1037f7:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1037fa:	89 10                	mov    %edx,(%eax)
}
  1037fc:	90                   	nop
  1037fd:	c7 45 b4 e0 ce 11 00 	movl   $0x11cee0,-0x4c(%ebp)
    return list->next == list;
  103804:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  103807:	8b 40 04             	mov    0x4(%eax),%eax
  10380a:	39 45 b4             	cmp    %eax,-0x4c(%ebp)
  10380d:	0f 94 c0             	sete   %al
  103810:	0f b6 c0             	movzbl %al,%eax
    list_init(&free_list);
    assert(list_empty(&free_list));
  103813:	85 c0                	test   %eax,%eax
  103815:	75 24                	jne    10383b <default_check+0x1cf>
  103817:	c7 44 24 0c df 6a 10 	movl   $0x106adf,0xc(%esp)
  10381e:	00 
  10381f:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103826:	00 
  103827:	c7 44 24 04 c6 01 00 	movl   $0x1c6,0x4(%esp)
  10382e:	00 
  10382f:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103836:	e8 ac d4 ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  10383b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103842:	e8 f7 07 00 00       	call   10403e <alloc_pages>
  103847:	85 c0                	test   %eax,%eax
  103849:	74 24                	je     10386f <default_check+0x203>
  10384b:	c7 44 24 0c f6 6a 10 	movl   $0x106af6,0xc(%esp)
  103852:	00 
  103853:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  10385a:	00 
  10385b:	c7 44 24 04 c7 01 00 	movl   $0x1c7,0x4(%esp)
  103862:	00 
  103863:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  10386a:	e8 78 d4 ff ff       	call   100ce7 <__panic>

    unsigned int nr_free_store = nr_free;
  10386f:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  103874:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    nr_free = 0;
  103877:	c7 05 e8 ce 11 00 00 	movl   $0x0,0x11cee8
  10387e:	00 00 00 

    free_pages(p0 + 2, 3);
  103881:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103884:	83 c0 28             	add    $0x28,%eax
  103887:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  10388e:	00 
  10388f:	89 04 24             	mov    %eax,(%esp)
  103892:	e8 e1 07 00 00       	call   104078 <free_pages>
    assert(alloc_pages(4) == NULL);
  103897:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  10389e:	e8 9b 07 00 00       	call   10403e <alloc_pages>
  1038a3:	85 c0                	test   %eax,%eax
  1038a5:	74 24                	je     1038cb <default_check+0x25f>
  1038a7:	c7 44 24 0c 9c 6b 10 	movl   $0x106b9c,0xc(%esp)
  1038ae:	00 
  1038af:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1038b6:	00 
  1038b7:	c7 44 24 04 cd 01 00 	movl   $0x1cd,0x4(%esp)
  1038be:	00 
  1038bf:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1038c6:	e8 1c d4 ff ff       	call   100ce7 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
  1038cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1038ce:	83 c0 28             	add    $0x28,%eax
  1038d1:	83 c0 04             	add    $0x4,%eax
  1038d4:	c7 45 ac 01 00 00 00 	movl   $0x1,-0x54(%ebp)
  1038db:	89 45 a8             	mov    %eax,-0x58(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  1038de:	8b 45 a8             	mov    -0x58(%ebp),%eax
  1038e1:	8b 55 ac             	mov    -0x54(%ebp),%edx
  1038e4:	0f a3 10             	bt     %edx,(%eax)
  1038e7:	19 c0                	sbb    %eax,%eax
  1038e9:	89 45 a4             	mov    %eax,-0x5c(%ebp)
    return oldbit != 0;
  1038ec:	83 7d a4 00          	cmpl   $0x0,-0x5c(%ebp)
  1038f0:	0f 95 c0             	setne  %al
  1038f3:	0f b6 c0             	movzbl %al,%eax
  1038f6:	85 c0                	test   %eax,%eax
  1038f8:	74 0e                	je     103908 <default_check+0x29c>
  1038fa:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1038fd:	83 c0 28             	add    $0x28,%eax
  103900:	8b 40 08             	mov    0x8(%eax),%eax
  103903:	83 f8 03             	cmp    $0x3,%eax
  103906:	74 24                	je     10392c <default_check+0x2c0>
  103908:	c7 44 24 0c b4 6b 10 	movl   $0x106bb4,0xc(%esp)
  10390f:	00 
  103910:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103917:	00 
  103918:	c7 44 24 04 ce 01 00 	movl   $0x1ce,0x4(%esp)
  10391f:	00 
  103920:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103927:	e8 bb d3 ff ff       	call   100ce7 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
  10392c:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  103933:	e8 06 07 00 00       	call   10403e <alloc_pages>
  103938:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10393b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10393f:	75 24                	jne    103965 <default_check+0x2f9>
  103941:	c7 44 24 0c e0 6b 10 	movl   $0x106be0,0xc(%esp)
  103948:	00 
  103949:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103950:	00 
  103951:	c7 44 24 04 cf 01 00 	movl   $0x1cf,0x4(%esp)
  103958:	00 
  103959:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103960:	e8 82 d3 ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  103965:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  10396c:	e8 cd 06 00 00       	call   10403e <alloc_pages>
  103971:	85 c0                	test   %eax,%eax
  103973:	74 24                	je     103999 <default_check+0x32d>
  103975:	c7 44 24 0c f6 6a 10 	movl   $0x106af6,0xc(%esp)
  10397c:	00 
  10397d:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103984:	00 
  103985:	c7 44 24 04 d0 01 00 	movl   $0x1d0,0x4(%esp)
  10398c:	00 
  10398d:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103994:	e8 4e d3 ff ff       	call   100ce7 <__panic>
    assert(p0 + 2 == p1);
  103999:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10399c:	83 c0 28             	add    $0x28,%eax
  10399f:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  1039a2:	74 24                	je     1039c8 <default_check+0x35c>
  1039a4:	c7 44 24 0c fe 6b 10 	movl   $0x106bfe,0xc(%esp)
  1039ab:	00 
  1039ac:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  1039b3:	00 
  1039b4:	c7 44 24 04 d1 01 00 	movl   $0x1d1,0x4(%esp)
  1039bb:	00 
  1039bc:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  1039c3:	e8 1f d3 ff ff       	call   100ce7 <__panic>

    p2 = p0 + 1;
  1039c8:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1039cb:	83 c0 14             	add    $0x14,%eax
  1039ce:	89 45 dc             	mov    %eax,-0x24(%ebp)
    free_page(p0);
  1039d1:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1039d8:	00 
  1039d9:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1039dc:	89 04 24             	mov    %eax,(%esp)
  1039df:	e8 94 06 00 00       	call   104078 <free_pages>
    free_pages(p1, 3);
  1039e4:	c7 44 24 04 03 00 00 	movl   $0x3,0x4(%esp)
  1039eb:	00 
  1039ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1039ef:	89 04 24             	mov    %eax,(%esp)
  1039f2:	e8 81 06 00 00       	call   104078 <free_pages>
    assert(PageProperty(p0) && p0->property == 1);
  1039f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1039fa:	83 c0 04             	add    $0x4,%eax
  1039fd:	c7 45 a0 01 00 00 00 	movl   $0x1,-0x60(%ebp)
  103a04:	89 45 9c             	mov    %eax,-0x64(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103a07:	8b 45 9c             	mov    -0x64(%ebp),%eax
  103a0a:	8b 55 a0             	mov    -0x60(%ebp),%edx
  103a0d:	0f a3 10             	bt     %edx,(%eax)
  103a10:	19 c0                	sbb    %eax,%eax
  103a12:	89 45 98             	mov    %eax,-0x68(%ebp)
    return oldbit != 0;
  103a15:	83 7d 98 00          	cmpl   $0x0,-0x68(%ebp)
  103a19:	0f 95 c0             	setne  %al
  103a1c:	0f b6 c0             	movzbl %al,%eax
  103a1f:	85 c0                	test   %eax,%eax
  103a21:	74 0b                	je     103a2e <default_check+0x3c2>
  103a23:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103a26:	8b 40 08             	mov    0x8(%eax),%eax
  103a29:	83 f8 01             	cmp    $0x1,%eax
  103a2c:	74 24                	je     103a52 <default_check+0x3e6>
  103a2e:	c7 44 24 0c 0c 6c 10 	movl   $0x106c0c,0xc(%esp)
  103a35:	00 
  103a36:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103a3d:	00 
  103a3e:	c7 44 24 04 d6 01 00 	movl   $0x1d6,0x4(%esp)
  103a45:	00 
  103a46:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103a4d:	e8 95 d2 ff ff       	call   100ce7 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
  103a52:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103a55:	83 c0 04             	add    $0x4,%eax
  103a58:	c7 45 94 01 00 00 00 	movl   $0x1,-0x6c(%ebp)
  103a5f:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btl %2, %1; sbbl %0,%0" : "=r" (oldbit) : "m" (*(volatile long *)addr), "Ir" (nr));
  103a62:	8b 45 90             	mov    -0x70(%ebp),%eax
  103a65:	8b 55 94             	mov    -0x6c(%ebp),%edx
  103a68:	0f a3 10             	bt     %edx,(%eax)
  103a6b:	19 c0                	sbb    %eax,%eax
  103a6d:	89 45 8c             	mov    %eax,-0x74(%ebp)
    return oldbit != 0;
  103a70:	83 7d 8c 00          	cmpl   $0x0,-0x74(%ebp)
  103a74:	0f 95 c0             	setne  %al
  103a77:	0f b6 c0             	movzbl %al,%eax
  103a7a:	85 c0                	test   %eax,%eax
  103a7c:	74 0b                	je     103a89 <default_check+0x41d>
  103a7e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  103a81:	8b 40 08             	mov    0x8(%eax),%eax
  103a84:	83 f8 03             	cmp    $0x3,%eax
  103a87:	74 24                	je     103aad <default_check+0x441>
  103a89:	c7 44 24 0c 34 6c 10 	movl   $0x106c34,0xc(%esp)
  103a90:	00 
  103a91:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103a98:	00 
  103a99:	c7 44 24 04 d7 01 00 	movl   $0x1d7,0x4(%esp)
  103aa0:	00 
  103aa1:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103aa8:	e8 3a d2 ff ff       	call   100ce7 <__panic>

    assert((p0 = alloc_page()) == p2 - 1);
  103aad:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ab4:	e8 85 05 00 00       	call   10403e <alloc_pages>
  103ab9:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103abc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103abf:	83 e8 14             	sub    $0x14,%eax
  103ac2:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103ac5:	74 24                	je     103aeb <default_check+0x47f>
  103ac7:	c7 44 24 0c 5a 6c 10 	movl   $0x106c5a,0xc(%esp)
  103ace:	00 
  103acf:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103ad6:	00 
  103ad7:	c7 44 24 04 d9 01 00 	movl   $0x1d9,0x4(%esp)
  103ade:	00 
  103adf:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103ae6:	e8 fc d1 ff ff       	call   100ce7 <__panic>
    free_page(p0);
  103aeb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103af2:	00 
  103af3:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103af6:	89 04 24             	mov    %eax,(%esp)
  103af9:	e8 7a 05 00 00       	call   104078 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
  103afe:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  103b05:	e8 34 05 00 00       	call   10403e <alloc_pages>
  103b0a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103b0d:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103b10:	83 c0 14             	add    $0x14,%eax
  103b13:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  103b16:	74 24                	je     103b3c <default_check+0x4d0>
  103b18:	c7 44 24 0c 78 6c 10 	movl   $0x106c78,0xc(%esp)
  103b1f:	00 
  103b20:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103b27:	00 
  103b28:	c7 44 24 04 db 01 00 	movl   $0x1db,0x4(%esp)
  103b2f:	00 
  103b30:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103b37:	e8 ab d1 ff ff       	call   100ce7 <__panic>

    free_pages(p0, 2);
  103b3c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  103b43:	00 
  103b44:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103b47:	89 04 24             	mov    %eax,(%esp)
  103b4a:	e8 29 05 00 00       	call   104078 <free_pages>
    free_page(p2);
  103b4f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  103b56:	00 
  103b57:	8b 45 dc             	mov    -0x24(%ebp),%eax
  103b5a:	89 04 24             	mov    %eax,(%esp)
  103b5d:	e8 16 05 00 00       	call   104078 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
  103b62:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  103b69:	e8 d0 04 00 00       	call   10403e <alloc_pages>
  103b6e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  103b71:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  103b75:	75 24                	jne    103b9b <default_check+0x52f>
  103b77:	c7 44 24 0c 98 6c 10 	movl   $0x106c98,0xc(%esp)
  103b7e:	00 
  103b7f:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103b86:	00 
  103b87:	c7 44 24 04 e0 01 00 	movl   $0x1e0,0x4(%esp)
  103b8e:	00 
  103b8f:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103b96:	e8 4c d1 ff ff       	call   100ce7 <__panic>
    assert(alloc_page() == NULL);
  103b9b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  103ba2:	e8 97 04 00 00       	call   10403e <alloc_pages>
  103ba7:	85 c0                	test   %eax,%eax
  103ba9:	74 24                	je     103bcf <default_check+0x563>
  103bab:	c7 44 24 0c f6 6a 10 	movl   $0x106af6,0xc(%esp)
  103bb2:	00 
  103bb3:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103bba:	00 
  103bbb:	c7 44 24 04 e1 01 00 	movl   $0x1e1,0x4(%esp)
  103bc2:	00 
  103bc3:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103bca:	e8 18 d1 ff ff       	call   100ce7 <__panic>

    assert(nr_free == 0);
  103bcf:	a1 e8 ce 11 00       	mov    0x11cee8,%eax
  103bd4:	85 c0                	test   %eax,%eax
  103bd6:	74 24                	je     103bfc <default_check+0x590>
  103bd8:	c7 44 24 0c 49 6b 10 	movl   $0x106b49,0xc(%esp)
  103bdf:	00 
  103be0:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103be7:	00 
  103be8:	c7 44 24 04 e3 01 00 	movl   $0x1e3,0x4(%esp)
  103bef:	00 
  103bf0:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103bf7:	e8 eb d0 ff ff       	call   100ce7 <__panic>
    nr_free = nr_free_store;
  103bfc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  103bff:	a3 e8 ce 11 00       	mov    %eax,0x11cee8

    free_list = free_list_store;
  103c04:	8b 45 80             	mov    -0x80(%ebp),%eax
  103c07:	8b 55 84             	mov    -0x7c(%ebp),%edx
  103c0a:	a3 e0 ce 11 00       	mov    %eax,0x11cee0
  103c0f:	89 15 e4 ce 11 00    	mov    %edx,0x11cee4
    free_pages(p0, 5);
  103c15:	c7 44 24 04 05 00 00 	movl   $0x5,0x4(%esp)
  103c1c:	00 
  103c1d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  103c20:	89 04 24             	mov    %eax,(%esp)
  103c23:	e8 50 04 00 00       	call   104078 <free_pages>

    le = &free_list;
  103c28:	c7 45 ec e0 ce 11 00 	movl   $0x11cee0,-0x14(%ebp)
    while ((le = list_next(le)) != &free_list) {
  103c2f:	eb 5a                	jmp    103c8b <default_check+0x61f>
        assert(le->next->prev == le && le->prev->next == le);
  103c31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c34:	8b 40 04             	mov    0x4(%eax),%eax
  103c37:	8b 00                	mov    (%eax),%eax
  103c39:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103c3c:	75 0d                	jne    103c4b <default_check+0x5df>
  103c3e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c41:	8b 00                	mov    (%eax),%eax
  103c43:	8b 40 04             	mov    0x4(%eax),%eax
  103c46:	39 45 ec             	cmp    %eax,-0x14(%ebp)
  103c49:	74 24                	je     103c6f <default_check+0x603>
  103c4b:	c7 44 24 0c b8 6c 10 	movl   $0x106cb8,0xc(%esp)
  103c52:	00 
  103c53:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103c5a:	00 
  103c5b:	c7 44 24 04 eb 01 00 	movl   $0x1eb,0x4(%esp)
  103c62:	00 
  103c63:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103c6a:	e8 78 d0 ff ff       	call   100ce7 <__panic>
        struct Page *p = le2page(le, page_link);
  103c6f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c72:	83 e8 0c             	sub    $0xc,%eax
  103c75:	89 45 d8             	mov    %eax,-0x28(%ebp)
        count --, total -= p->property;
  103c78:	ff 4d f4             	decl   -0xc(%ebp)
  103c7b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  103c7e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  103c81:	8b 48 08             	mov    0x8(%eax),%ecx
  103c84:	89 d0                	mov    %edx,%eax
  103c86:	29 c8                	sub    %ecx,%eax
  103c88:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103c8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  103c8e:	89 45 88             	mov    %eax,-0x78(%ebp)
    return listelm->next;
  103c91:	8b 45 88             	mov    -0x78(%ebp),%eax
  103c94:	8b 40 04             	mov    0x4(%eax),%eax
    while ((le = list_next(le)) != &free_list) {
  103c97:	89 45 ec             	mov    %eax,-0x14(%ebp)
  103c9a:	81 7d ec e0 ce 11 00 	cmpl   $0x11cee0,-0x14(%ebp)
  103ca1:	75 8e                	jne    103c31 <default_check+0x5c5>
    }
    assert(count == 0);
  103ca3:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  103ca7:	74 24                	je     103ccd <default_check+0x661>
  103ca9:	c7 44 24 0c e5 6c 10 	movl   $0x106ce5,0xc(%esp)
  103cb0:	00 
  103cb1:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103cb8:	00 
  103cb9:	c7 44 24 04 ef 01 00 	movl   $0x1ef,0x4(%esp)
  103cc0:	00 
  103cc1:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103cc8:	e8 1a d0 ff ff       	call   100ce7 <__panic>
    assert(total == 0);
  103ccd:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  103cd1:	74 24                	je     103cf7 <default_check+0x68b>
  103cd3:	c7 44 24 0c f0 6c 10 	movl   $0x106cf0,0xc(%esp)
  103cda:	00 
  103cdb:	c7 44 24 08 56 69 10 	movl   $0x106956,0x8(%esp)
  103ce2:	00 
  103ce3:	c7 44 24 04 f0 01 00 	movl   $0x1f0,0x4(%esp)
  103cea:	00 
  103ceb:	c7 04 24 6b 69 10 00 	movl   $0x10696b,(%esp)
  103cf2:	e8 f0 cf ff ff       	call   100ce7 <__panic>
}
  103cf7:	90                   	nop
  103cf8:	89 ec                	mov    %ebp,%esp
  103cfa:	5d                   	pop    %ebp
  103cfb:	c3                   	ret    

00103cfc <page2ppn>:
page2ppn(struct Page *page) {
  103cfc:	55                   	push   %ebp
  103cfd:	89 e5                	mov    %esp,%ebp
    return page - pages;
  103cff:	8b 15 00 cf 11 00    	mov    0x11cf00,%edx
  103d05:	8b 45 08             	mov    0x8(%ebp),%eax
  103d08:	29 d0                	sub    %edx,%eax
  103d0a:	c1 f8 02             	sar    $0x2,%eax
  103d0d:	69 c0 cd cc cc cc    	imul   $0xcccccccd,%eax,%eax
}
  103d13:	5d                   	pop    %ebp
  103d14:	c3                   	ret    

00103d15 <page2pa>:
page2pa(struct Page *page) {
  103d15:	55                   	push   %ebp
  103d16:	89 e5                	mov    %esp,%ebp
  103d18:	83 ec 04             	sub    $0x4,%esp
    return page2ppn(page) << PGSHIFT;
  103d1b:	8b 45 08             	mov    0x8(%ebp),%eax
  103d1e:	89 04 24             	mov    %eax,(%esp)
  103d21:	e8 d6 ff ff ff       	call   103cfc <page2ppn>
  103d26:	c1 e0 0c             	shl    $0xc,%eax
}
  103d29:	89 ec                	mov    %ebp,%esp
  103d2b:	5d                   	pop    %ebp
  103d2c:	c3                   	ret    

00103d2d <pa2page>:
pa2page(uintptr_t pa) {
  103d2d:	55                   	push   %ebp
  103d2e:	89 e5                	mov    %esp,%ebp
  103d30:	83 ec 18             	sub    $0x18,%esp
    if (PPN(pa) >= npage) {
  103d33:	8b 45 08             	mov    0x8(%ebp),%eax
  103d36:	c1 e8 0c             	shr    $0xc,%eax
  103d39:	89 c2                	mov    %eax,%edx
  103d3b:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  103d40:	39 c2                	cmp    %eax,%edx
  103d42:	72 1c                	jb     103d60 <pa2page+0x33>
        panic("pa2page called with invalid pa");
  103d44:	c7 44 24 08 2c 6d 10 	movl   $0x106d2c,0x8(%esp)
  103d4b:	00 
  103d4c:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  103d53:	00 
  103d54:	c7 04 24 4b 6d 10 00 	movl   $0x106d4b,(%esp)
  103d5b:	e8 87 cf ff ff       	call   100ce7 <__panic>
    return &pages[PPN(pa)];
  103d60:	8b 0d 00 cf 11 00    	mov    0x11cf00,%ecx
  103d66:	8b 45 08             	mov    0x8(%ebp),%eax
  103d69:	c1 e8 0c             	shr    $0xc,%eax
  103d6c:	89 c2                	mov    %eax,%edx
  103d6e:	89 d0                	mov    %edx,%eax
  103d70:	c1 e0 02             	shl    $0x2,%eax
  103d73:	01 d0                	add    %edx,%eax
  103d75:	c1 e0 02             	shl    $0x2,%eax
  103d78:	01 c8                	add    %ecx,%eax
}
  103d7a:	89 ec                	mov    %ebp,%esp
  103d7c:	5d                   	pop    %ebp
  103d7d:	c3                   	ret    

00103d7e <page2kva>:
page2kva(struct Page *page) {
  103d7e:	55                   	push   %ebp
  103d7f:	89 e5                	mov    %esp,%ebp
  103d81:	83 ec 28             	sub    $0x28,%esp
    return KADDR(page2pa(page));
  103d84:	8b 45 08             	mov    0x8(%ebp),%eax
  103d87:	89 04 24             	mov    %eax,(%esp)
  103d8a:	e8 86 ff ff ff       	call   103d15 <page2pa>
  103d8f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  103d92:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103d95:	c1 e8 0c             	shr    $0xc,%eax
  103d98:	89 45 f0             	mov    %eax,-0x10(%ebp)
  103d9b:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  103da0:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  103da3:	72 23                	jb     103dc8 <page2kva+0x4a>
  103da5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103da8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  103dac:	c7 44 24 08 5c 6d 10 	movl   $0x106d5c,0x8(%esp)
  103db3:	00 
  103db4:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  103dbb:	00 
  103dbc:	c7 04 24 4b 6d 10 00 	movl   $0x106d4b,(%esp)
  103dc3:	e8 1f cf ff ff       	call   100ce7 <__panic>
  103dc8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  103dcb:	2d 00 00 00 40       	sub    $0x40000000,%eax
}
  103dd0:	89 ec                	mov    %ebp,%esp
  103dd2:	5d                   	pop    %ebp
  103dd3:	c3                   	ret    

00103dd4 <pte2page>:
pte2page(pte_t pte) {
  103dd4:	55                   	push   %ebp
  103dd5:	89 e5                	mov    %esp,%ebp
  103dd7:	83 ec 18             	sub    $0x18,%esp
    if (!(pte & PTE_P)) {
  103dda:	8b 45 08             	mov    0x8(%ebp),%eax
  103ddd:	83 e0 01             	and    $0x1,%eax
  103de0:	85 c0                	test   %eax,%eax
  103de2:	75 1c                	jne    103e00 <pte2page+0x2c>
        panic("pte2page called with invalid pte");
  103de4:	c7 44 24 08 80 6d 10 	movl   $0x106d80,0x8(%esp)
  103deb:	00 
  103dec:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  103df3:	00 
  103df4:	c7 04 24 4b 6d 10 00 	movl   $0x106d4b,(%esp)
  103dfb:	e8 e7 ce ff ff       	call   100ce7 <__panic>
    return pa2page(PTE_ADDR(pte));
  103e00:	8b 45 08             	mov    0x8(%ebp),%eax
  103e03:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103e08:	89 04 24             	mov    %eax,(%esp)
  103e0b:	e8 1d ff ff ff       	call   103d2d <pa2page>
}
  103e10:	89 ec                	mov    %ebp,%esp
  103e12:	5d                   	pop    %ebp
  103e13:	c3                   	ret    

00103e14 <pde2page>:
pde2page(pde_t pde) {
  103e14:	55                   	push   %ebp
  103e15:	89 e5                	mov    %esp,%ebp
  103e17:	83 ec 18             	sub    $0x18,%esp
    return pa2page(PDE_ADDR(pde));
  103e1a:	8b 45 08             	mov    0x8(%ebp),%eax
  103e1d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  103e22:	89 04 24             	mov    %eax,(%esp)
  103e25:	e8 03 ff ff ff       	call   103d2d <pa2page>
}
  103e2a:	89 ec                	mov    %ebp,%esp
  103e2c:	5d                   	pop    %ebp
  103e2d:	c3                   	ret    

00103e2e <page_ref>:
page_ref(struct Page *page) {
  103e2e:	55                   	push   %ebp
  103e2f:	89 e5                	mov    %esp,%ebp
    return page->ref;
  103e31:	8b 45 08             	mov    0x8(%ebp),%eax
  103e34:	8b 00                	mov    (%eax),%eax
}
  103e36:	5d                   	pop    %ebp
  103e37:	c3                   	ret    

00103e38 <set_page_ref>:
set_page_ref(struct Page *page, int val) {
  103e38:	55                   	push   %ebp
  103e39:	89 e5                	mov    %esp,%ebp
    page->ref = val;
  103e3b:	8b 45 08             	mov    0x8(%ebp),%eax
  103e3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  103e41:	89 10                	mov    %edx,(%eax)
}
  103e43:	90                   	nop
  103e44:	5d                   	pop    %ebp
  103e45:	c3                   	ret    

00103e46 <page_ref_inc>:

static inline int
page_ref_inc(struct Page *page) {
  103e46:	55                   	push   %ebp
  103e47:	89 e5                	mov    %esp,%ebp
    page->ref += 1;
  103e49:	8b 45 08             	mov    0x8(%ebp),%eax
  103e4c:	8b 00                	mov    (%eax),%eax
  103e4e:	8d 50 01             	lea    0x1(%eax),%edx
  103e51:	8b 45 08             	mov    0x8(%ebp),%eax
  103e54:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103e56:	8b 45 08             	mov    0x8(%ebp),%eax
  103e59:	8b 00                	mov    (%eax),%eax
}
  103e5b:	5d                   	pop    %ebp
  103e5c:	c3                   	ret    

00103e5d <page_ref_dec>:

static inline int
page_ref_dec(struct Page *page) {
  103e5d:	55                   	push   %ebp
  103e5e:	89 e5                	mov    %esp,%ebp
    page->ref -= 1;
  103e60:	8b 45 08             	mov    0x8(%ebp),%eax
  103e63:	8b 00                	mov    (%eax),%eax
  103e65:	8d 50 ff             	lea    -0x1(%eax),%edx
  103e68:	8b 45 08             	mov    0x8(%ebp),%eax
  103e6b:	89 10                	mov    %edx,(%eax)
    return page->ref;
  103e6d:	8b 45 08             	mov    0x8(%ebp),%eax
  103e70:	8b 00                	mov    (%eax),%eax
}
  103e72:	5d                   	pop    %ebp
  103e73:	c3                   	ret    

00103e74 <__intr_save>:
__intr_save(void) {
  103e74:	55                   	push   %ebp
  103e75:	89 e5                	mov    %esp,%ebp
  103e77:	83 ec 18             	sub    $0x18,%esp
    asm volatile ("pushfl; popl %0" : "=r" (eflags));
  103e7a:	9c                   	pushf  
  103e7b:	58                   	pop    %eax
  103e7c:	89 45 f4             	mov    %eax,-0xc(%ebp)
    return eflags;
  103e7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
    if (read_eflags() & FL_IF) {
  103e82:	25 00 02 00 00       	and    $0x200,%eax
  103e87:	85 c0                	test   %eax,%eax
  103e89:	74 0c                	je     103e97 <__intr_save+0x23>
        intr_disable();
  103e8b:	e8 b0 d8 ff ff       	call   101740 <intr_disable>
        return 1;
  103e90:	b8 01 00 00 00       	mov    $0x1,%eax
  103e95:	eb 05                	jmp    103e9c <__intr_save+0x28>
    return 0;
  103e97:	b8 00 00 00 00       	mov    $0x0,%eax
}
  103e9c:	89 ec                	mov    %ebp,%esp
  103e9e:	5d                   	pop    %ebp
  103e9f:	c3                   	ret    

00103ea0 <__intr_restore>:
__intr_restore(bool flag) {
  103ea0:	55                   	push   %ebp
  103ea1:	89 e5                	mov    %esp,%ebp
  103ea3:	83 ec 08             	sub    $0x8,%esp
    if (flag) {
  103ea6:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  103eaa:	74 05                	je     103eb1 <__intr_restore+0x11>
        intr_enable();
  103eac:	e8 87 d8 ff ff       	call   101738 <intr_enable>
}
  103eb1:	90                   	nop
  103eb2:	89 ec                	mov    %ebp,%esp
  103eb4:	5d                   	pop    %ebp
  103eb5:	c3                   	ret    

00103eb6 <lgdt>:
/* *
 * lgdt - load the global descriptor table register and reset the
 * data/code segement registers for kernel.
 * */
static inline void
lgdt(struct pseudodesc *pd) {
  103eb6:	55                   	push   %ebp
  103eb7:	89 e5                	mov    %esp,%ebp
    asm volatile ("lgdt (%0)" :: "r" (pd));
  103eb9:	8b 45 08             	mov    0x8(%ebp),%eax
  103ebc:	0f 01 10             	lgdtl  (%eax)
    asm volatile ("movw %%ax, %%gs" :: "a" (USER_DS));
  103ebf:	b8 23 00 00 00       	mov    $0x23,%eax
  103ec4:	8e e8                	mov    %eax,%gs
    asm volatile ("movw %%ax, %%fs" :: "a" (USER_DS));
  103ec6:	b8 23 00 00 00       	mov    $0x23,%eax
  103ecb:	8e e0                	mov    %eax,%fs
    asm volatile ("movw %%ax, %%es" :: "a" (KERNEL_DS));
  103ecd:	b8 10 00 00 00       	mov    $0x10,%eax
  103ed2:	8e c0                	mov    %eax,%es
    asm volatile ("movw %%ax, %%ds" :: "a" (KERNEL_DS));
  103ed4:	b8 10 00 00 00       	mov    $0x10,%eax
  103ed9:	8e d8                	mov    %eax,%ds
    asm volatile ("movw %%ax, %%ss" :: "a" (KERNEL_DS));
  103edb:	b8 10 00 00 00       	mov    $0x10,%eax
  103ee0:	8e d0                	mov    %eax,%ss
    // reload cs
    asm volatile ("ljmp %0, $1f\n 1:\n" :: "i" (KERNEL_CS));
  103ee2:	ea e9 3e 10 00 08 00 	ljmp   $0x8,$0x103ee9
}
  103ee9:	90                   	nop
  103eea:	5d                   	pop    %ebp
  103eeb:	c3                   	ret    

00103eec <load_esp0>:
 * load_esp0 - change the ESP0 in default task state segment,
 * so that we can use different kernel stack when we trap frame
 * user to kernel.
 * */
void
load_esp0(uintptr_t esp0) {
  103eec:	55                   	push   %ebp
  103eed:	89 e5                	mov    %esp,%ebp
    ts.ts_esp0 = esp0;
  103eef:	8b 45 08             	mov    0x8(%ebp),%eax
  103ef2:	a3 24 cf 11 00       	mov    %eax,0x11cf24
}
  103ef7:	90                   	nop
  103ef8:	5d                   	pop    %ebp
  103ef9:	c3                   	ret    

00103efa <gdt_init>:

/* gdt_init - initialize the default GDT and TSS */
static void
gdt_init(void) {
  103efa:	55                   	push   %ebp
  103efb:	89 e5                	mov    %esp,%ebp
  103efd:	83 ec 14             	sub    $0x14,%esp
    // set boot kernel stack and default SS0
    load_esp0((uintptr_t)bootstacktop);
  103f00:	b8 00 90 11 00       	mov    $0x119000,%eax
  103f05:	89 04 24             	mov    %eax,(%esp)
  103f08:	e8 df ff ff ff       	call   103eec <load_esp0>
    ts.ts_ss0 = KERNEL_DS;
  103f0d:	66 c7 05 28 cf 11 00 	movw   $0x10,0x11cf28
  103f14:	10 00 

    // initialize the TSS filed of the gdt
    gdt[SEG_TSS] = SEGTSS(STS_T32A, (uintptr_t)&ts, sizeof(ts), DPL_KERNEL);
  103f16:	66 c7 05 28 9a 11 00 	movw   $0x68,0x119a28
  103f1d:	68 00 
  103f1f:	b8 20 cf 11 00       	mov    $0x11cf20,%eax
  103f24:	0f b7 c0             	movzwl %ax,%eax
  103f27:	66 a3 2a 9a 11 00    	mov    %ax,0x119a2a
  103f2d:	b8 20 cf 11 00       	mov    $0x11cf20,%eax
  103f32:	c1 e8 10             	shr    $0x10,%eax
  103f35:	a2 2c 9a 11 00       	mov    %al,0x119a2c
  103f3a:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103f41:	24 f0                	and    $0xf0,%al
  103f43:	0c 09                	or     $0x9,%al
  103f45:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103f4a:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103f51:	24 ef                	and    $0xef,%al
  103f53:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103f58:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103f5f:	24 9f                	and    $0x9f,%al
  103f61:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103f66:	0f b6 05 2d 9a 11 00 	movzbl 0x119a2d,%eax
  103f6d:	0c 80                	or     $0x80,%al
  103f6f:	a2 2d 9a 11 00       	mov    %al,0x119a2d
  103f74:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f7b:	24 f0                	and    $0xf0,%al
  103f7d:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f82:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f89:	24 ef                	and    $0xef,%al
  103f8b:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f90:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103f97:	24 df                	and    $0xdf,%al
  103f99:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103f9e:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103fa5:	0c 40                	or     $0x40,%al
  103fa7:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103fac:	0f b6 05 2e 9a 11 00 	movzbl 0x119a2e,%eax
  103fb3:	24 7f                	and    $0x7f,%al
  103fb5:	a2 2e 9a 11 00       	mov    %al,0x119a2e
  103fba:	b8 20 cf 11 00       	mov    $0x11cf20,%eax
  103fbf:	c1 e8 18             	shr    $0x18,%eax
  103fc2:	a2 2f 9a 11 00       	mov    %al,0x119a2f

    // reload all segment registers
    lgdt(&gdt_pd);
  103fc7:	c7 04 24 30 9a 11 00 	movl   $0x119a30,(%esp)
  103fce:	e8 e3 fe ff ff       	call   103eb6 <lgdt>
  103fd3:	66 c7 45 fe 28 00    	movw   $0x28,-0x2(%ebp)
    asm volatile ("ltr %0" :: "r" (sel) : "memory");
  103fd9:	0f b7 45 fe          	movzwl -0x2(%ebp),%eax
  103fdd:	0f 00 d8             	ltr    %ax
}
  103fe0:	90                   	nop

    // load the TSS
    ltr(GD_TSS);
}
  103fe1:	90                   	nop
  103fe2:	89 ec                	mov    %ebp,%esp
  103fe4:	5d                   	pop    %ebp
  103fe5:	c3                   	ret    

00103fe6 <init_pmm_manager>:

//init_pmm_manager - initialize a pmm_manager instance
static void
init_pmm_manager(void) {
  103fe6:	55                   	push   %ebp
  103fe7:	89 e5                	mov    %esp,%ebp
  103fe9:	83 ec 18             	sub    $0x18,%esp
    pmm_manager = &default_pmm_manager;
  103fec:	c7 05 0c cf 11 00 10 	movl   $0x106d10,0x11cf0c
  103ff3:	6d 10 00 
    cprintf("memory management: %s\n", pmm_manager->name);
  103ff6:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  103ffb:	8b 00                	mov    (%eax),%eax
  103ffd:	89 44 24 04          	mov    %eax,0x4(%esp)
  104001:	c7 04 24 ac 6d 10 00 	movl   $0x106dac,(%esp)
  104008:	e8 49 c3 ff ff       	call   100356 <cprintf>
    pmm_manager->init();
  10400d:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104012:	8b 40 04             	mov    0x4(%eax),%eax
  104015:	ff d0                	call   *%eax
}
  104017:	90                   	nop
  104018:	89 ec                	mov    %ebp,%esp
  10401a:	5d                   	pop    %ebp
  10401b:	c3                   	ret    

0010401c <init_memmap>:

//init_memmap - call pmm->init_memmap to build Page struct for free memory  
static void
init_memmap(struct Page *base, size_t n) {
  10401c:	55                   	push   %ebp
  10401d:	89 e5                	mov    %esp,%ebp
  10401f:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->init_memmap(base, n);
  104022:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104027:	8b 40 08             	mov    0x8(%eax),%eax
  10402a:	8b 55 0c             	mov    0xc(%ebp),%edx
  10402d:	89 54 24 04          	mov    %edx,0x4(%esp)
  104031:	8b 55 08             	mov    0x8(%ebp),%edx
  104034:	89 14 24             	mov    %edx,(%esp)
  104037:	ff d0                	call   *%eax
}
  104039:	90                   	nop
  10403a:	89 ec                	mov    %ebp,%esp
  10403c:	5d                   	pop    %ebp
  10403d:	c3                   	ret    

0010403e <alloc_pages>:

//alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE memory 
struct Page *
alloc_pages(size_t n) {
  10403e:	55                   	push   %ebp
  10403f:	89 e5                	mov    %esp,%ebp
  104041:	83 ec 28             	sub    $0x28,%esp
    struct Page *page=NULL;
  104044:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    bool intr_flag;
    local_intr_save(intr_flag);
  10404b:	e8 24 fe ff ff       	call   103e74 <__intr_save>
  104050:	89 45 f0             	mov    %eax,-0x10(%ebp)
    {
        page = pmm_manager->alloc_pages(n);
  104053:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104058:	8b 40 0c             	mov    0xc(%eax),%eax
  10405b:	8b 55 08             	mov    0x8(%ebp),%edx
  10405e:	89 14 24             	mov    %edx,(%esp)
  104061:	ff d0                	call   *%eax
  104063:	89 45 f4             	mov    %eax,-0xc(%ebp)
    }
    local_intr_restore(intr_flag);
  104066:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104069:	89 04 24             	mov    %eax,(%esp)
  10406c:	e8 2f fe ff ff       	call   103ea0 <__intr_restore>
    return page;
  104071:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  104074:	89 ec                	mov    %ebp,%esp
  104076:	5d                   	pop    %ebp
  104077:	c3                   	ret    

00104078 <free_pages>:

//free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory 
void
free_pages(struct Page *base, size_t n) {
  104078:	55                   	push   %ebp
  104079:	89 e5                	mov    %esp,%ebp
  10407b:	83 ec 28             	sub    $0x28,%esp
    bool intr_flag;
    local_intr_save(intr_flag);
  10407e:	e8 f1 fd ff ff       	call   103e74 <__intr_save>
  104083:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        pmm_manager->free_pages(base, n);
  104086:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  10408b:	8b 40 10             	mov    0x10(%eax),%eax
  10408e:	8b 55 0c             	mov    0xc(%ebp),%edx
  104091:	89 54 24 04          	mov    %edx,0x4(%esp)
  104095:	8b 55 08             	mov    0x8(%ebp),%edx
  104098:	89 14 24             	mov    %edx,(%esp)
  10409b:	ff d0                	call   *%eax
    }
    local_intr_restore(intr_flag);
  10409d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040a0:	89 04 24             	mov    %eax,(%esp)
  1040a3:	e8 f8 fd ff ff       	call   103ea0 <__intr_restore>
}
  1040a8:	90                   	nop
  1040a9:	89 ec                	mov    %ebp,%esp
  1040ab:	5d                   	pop    %ebp
  1040ac:	c3                   	ret    

001040ad <nr_free_pages>:

//nr_free_pages - call pmm->nr_free_pages to get the size (nr*PAGESIZE) 
//of current free memory
size_t
nr_free_pages(void) {
  1040ad:	55                   	push   %ebp
  1040ae:	89 e5                	mov    %esp,%ebp
  1040b0:	83 ec 28             	sub    $0x28,%esp
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
  1040b3:	e8 bc fd ff ff       	call   103e74 <__intr_save>
  1040b8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    {
        ret = pmm_manager->nr_free_pages();
  1040bb:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  1040c0:	8b 40 14             	mov    0x14(%eax),%eax
  1040c3:	ff d0                	call   *%eax
  1040c5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    }
    local_intr_restore(intr_flag);
  1040c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1040cb:	89 04 24             	mov    %eax,(%esp)
  1040ce:	e8 cd fd ff ff       	call   103ea0 <__intr_restore>
    return ret;
  1040d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
  1040d6:	89 ec                	mov    %ebp,%esp
  1040d8:	5d                   	pop    %ebp
  1040d9:	c3                   	ret    

001040da <page_init>:

/* pmm_init - initialize the physical memory management */
static void
page_init(void) {
  1040da:	55                   	push   %ebp
  1040db:	89 e5                	mov    %esp,%ebp
  1040dd:	57                   	push   %edi
  1040de:	56                   	push   %esi
  1040df:	53                   	push   %ebx
  1040e0:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
    struct e820map *memmap = (struct e820map *)(0x8000 + KERNBASE);
  1040e6:	c7 45 c4 00 80 00 c0 	movl   $0xc0008000,-0x3c(%ebp)
    uint64_t maxpa = 0;
  1040ed:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  1040f4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)

    cprintf("e820map:\n");
  1040fb:	c7 04 24 c3 6d 10 00 	movl   $0x106dc3,(%esp)
  104102:	e8 4f c2 ff ff       	call   100356 <cprintf>
    int i;
    for (i = 0; i < memmap->nr_map; i ++) {
  104107:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  10410e:	e9 0c 01 00 00       	jmp    10421f <page_init+0x145>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  104113:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104116:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104119:	89 d0                	mov    %edx,%eax
  10411b:	c1 e0 02             	shl    $0x2,%eax
  10411e:	01 d0                	add    %edx,%eax
  104120:	c1 e0 02             	shl    $0x2,%eax
  104123:	01 c8                	add    %ecx,%eax
  104125:	8b 50 08             	mov    0x8(%eax),%edx
  104128:	8b 40 04             	mov    0x4(%eax),%eax
  10412b:	89 45 a0             	mov    %eax,-0x60(%ebp)
  10412e:	89 55 a4             	mov    %edx,-0x5c(%ebp)
  104131:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104134:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104137:	89 d0                	mov    %edx,%eax
  104139:	c1 e0 02             	shl    $0x2,%eax
  10413c:	01 d0                	add    %edx,%eax
  10413e:	c1 e0 02             	shl    $0x2,%eax
  104141:	01 c8                	add    %ecx,%eax
  104143:	8b 48 0c             	mov    0xc(%eax),%ecx
  104146:	8b 58 10             	mov    0x10(%eax),%ebx
  104149:	8b 45 a0             	mov    -0x60(%ebp),%eax
  10414c:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  10414f:	01 c8                	add    %ecx,%eax
  104151:	11 da                	adc    %ebx,%edx
  104153:	89 45 98             	mov    %eax,-0x68(%ebp)
  104156:	89 55 9c             	mov    %edx,-0x64(%ebp)
        cprintf("  memory: %08llx, [%08llx, %08llx], type = %d.\n",
  104159:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10415c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10415f:	89 d0                	mov    %edx,%eax
  104161:	c1 e0 02             	shl    $0x2,%eax
  104164:	01 d0                	add    %edx,%eax
  104166:	c1 e0 02             	shl    $0x2,%eax
  104169:	01 c8                	add    %ecx,%eax
  10416b:	83 c0 14             	add    $0x14,%eax
  10416e:	8b 00                	mov    (%eax),%eax
  104170:	89 85 7c ff ff ff    	mov    %eax,-0x84(%ebp)
  104176:	8b 45 98             	mov    -0x68(%ebp),%eax
  104179:	8b 55 9c             	mov    -0x64(%ebp),%edx
  10417c:	83 c0 ff             	add    $0xffffffff,%eax
  10417f:	83 d2 ff             	adc    $0xffffffff,%edx
  104182:	89 c6                	mov    %eax,%esi
  104184:	89 d7                	mov    %edx,%edi
  104186:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104189:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10418c:	89 d0                	mov    %edx,%eax
  10418e:	c1 e0 02             	shl    $0x2,%eax
  104191:	01 d0                	add    %edx,%eax
  104193:	c1 e0 02             	shl    $0x2,%eax
  104196:	01 c8                	add    %ecx,%eax
  104198:	8b 48 0c             	mov    0xc(%eax),%ecx
  10419b:	8b 58 10             	mov    0x10(%eax),%ebx
  10419e:	8b 85 7c ff ff ff    	mov    -0x84(%ebp),%eax
  1041a4:	89 44 24 1c          	mov    %eax,0x1c(%esp)
  1041a8:	89 74 24 14          	mov    %esi,0x14(%esp)
  1041ac:	89 7c 24 18          	mov    %edi,0x18(%esp)
  1041b0:	8b 45 a0             	mov    -0x60(%ebp),%eax
  1041b3:	8b 55 a4             	mov    -0x5c(%ebp),%edx
  1041b6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1041ba:	89 54 24 10          	mov    %edx,0x10(%esp)
  1041be:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  1041c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  1041c6:	c7 04 24 d0 6d 10 00 	movl   $0x106dd0,(%esp)
  1041cd:	e8 84 c1 ff ff       	call   100356 <cprintf>
                memmap->map[i].size, begin, end - 1, memmap->map[i].type);
        if (memmap->map[i].type == E820_ARM) {
  1041d2:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  1041d5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1041d8:	89 d0                	mov    %edx,%eax
  1041da:	c1 e0 02             	shl    $0x2,%eax
  1041dd:	01 d0                	add    %edx,%eax
  1041df:	c1 e0 02             	shl    $0x2,%eax
  1041e2:	01 c8                	add    %ecx,%eax
  1041e4:	83 c0 14             	add    $0x14,%eax
  1041e7:	8b 00                	mov    (%eax),%eax
  1041e9:	83 f8 01             	cmp    $0x1,%eax
  1041ec:	75 2e                	jne    10421c <page_init+0x142>
            if (maxpa < end && begin < KMEMSIZE) {
  1041ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1041f1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1041f4:	3b 45 98             	cmp    -0x68(%ebp),%eax
  1041f7:	89 d0                	mov    %edx,%eax
  1041f9:	1b 45 9c             	sbb    -0x64(%ebp),%eax
  1041fc:	73 1e                	jae    10421c <page_init+0x142>
  1041fe:	ba ff ff ff 37       	mov    $0x37ffffff,%edx
  104203:	b8 00 00 00 00       	mov    $0x0,%eax
  104208:	3b 55 a0             	cmp    -0x60(%ebp),%edx
  10420b:	1b 45 a4             	sbb    -0x5c(%ebp),%eax
  10420e:	72 0c                	jb     10421c <page_init+0x142>
                maxpa = end;
  104210:	8b 45 98             	mov    -0x68(%ebp),%eax
  104213:	8b 55 9c             	mov    -0x64(%ebp),%edx
  104216:	89 45 e0             	mov    %eax,-0x20(%ebp)
  104219:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    for (i = 0; i < memmap->nr_map; i ++) {
  10421c:	ff 45 dc             	incl   -0x24(%ebp)
  10421f:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104222:	8b 00                	mov    (%eax),%eax
  104224:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104227:	0f 8c e6 fe ff ff    	jl     104113 <page_init+0x39>
            }
        }
    }
    if (maxpa > KMEMSIZE) {
  10422d:	ba 00 00 00 38       	mov    $0x38000000,%edx
  104232:	b8 00 00 00 00       	mov    $0x0,%eax
  104237:	3b 55 e0             	cmp    -0x20(%ebp),%edx
  10423a:	1b 45 e4             	sbb    -0x1c(%ebp),%eax
  10423d:	73 0e                	jae    10424d <page_init+0x173>
        maxpa = KMEMSIZE;
  10423f:	c7 45 e0 00 00 00 38 	movl   $0x38000000,-0x20(%ebp)
  104246:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    }

    extern char end[];

    npage = maxpa / PGSIZE;
  10424d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104250:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104253:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104257:	c1 ea 0c             	shr    $0xc,%edx
  10425a:	a3 04 cf 11 00       	mov    %eax,0x11cf04
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
  10425f:	c7 45 c0 00 10 00 00 	movl   $0x1000,-0x40(%ebp)
  104266:	b8 8c cf 11 00       	mov    $0x11cf8c,%eax
  10426b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10426e:	8b 45 c0             	mov    -0x40(%ebp),%eax
  104271:	01 d0                	add    %edx,%eax
  104273:	89 45 bc             	mov    %eax,-0x44(%ebp)
  104276:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104279:	ba 00 00 00 00       	mov    $0x0,%edx
  10427e:	f7 75 c0             	divl   -0x40(%ebp)
  104281:	8b 45 bc             	mov    -0x44(%ebp),%eax
  104284:	29 d0                	sub    %edx,%eax
  104286:	a3 00 cf 11 00       	mov    %eax,0x11cf00

    for (i = 0; i < npage; i ++) {
  10428b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104292:	eb 2f                	jmp    1042c3 <page_init+0x1e9>
        SetPageReserved(pages + i);
  104294:	8b 0d 00 cf 11 00    	mov    0x11cf00,%ecx
  10429a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10429d:	89 d0                	mov    %edx,%eax
  10429f:	c1 e0 02             	shl    $0x2,%eax
  1042a2:	01 d0                	add    %edx,%eax
  1042a4:	c1 e0 02             	shl    $0x2,%eax
  1042a7:	01 c8                	add    %ecx,%eax
  1042a9:	83 c0 04             	add    $0x4,%eax
  1042ac:	c7 45 94 00 00 00 00 	movl   $0x0,-0x6c(%ebp)
  1042b3:	89 45 90             	mov    %eax,-0x70(%ebp)
    asm volatile ("btsl %1, %0" :"=m" (*(volatile long *)addr) : "Ir" (nr));
  1042b6:	8b 45 90             	mov    -0x70(%ebp),%eax
  1042b9:	8b 55 94             	mov    -0x6c(%ebp),%edx
  1042bc:	0f ab 10             	bts    %edx,(%eax)
}
  1042bf:	90                   	nop
    for (i = 0; i < npage; i ++) {
  1042c0:	ff 45 dc             	incl   -0x24(%ebp)
  1042c3:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1042c6:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  1042cb:	39 c2                	cmp    %eax,%edx
  1042cd:	72 c5                	jb     104294 <page_init+0x1ba>
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * npage);
  1042cf:	8b 15 04 cf 11 00    	mov    0x11cf04,%edx
  1042d5:	89 d0                	mov    %edx,%eax
  1042d7:	c1 e0 02             	shl    $0x2,%eax
  1042da:	01 d0                	add    %edx,%eax
  1042dc:	c1 e0 02             	shl    $0x2,%eax
  1042df:	89 c2                	mov    %eax,%edx
  1042e1:	a1 00 cf 11 00       	mov    0x11cf00,%eax
  1042e6:	01 d0                	add    %edx,%eax
  1042e8:	89 45 b8             	mov    %eax,-0x48(%ebp)
  1042eb:	81 7d b8 ff ff ff bf 	cmpl   $0xbfffffff,-0x48(%ebp)
  1042f2:	77 23                	ja     104317 <page_init+0x23d>
  1042f4:	8b 45 b8             	mov    -0x48(%ebp),%eax
  1042f7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1042fb:	c7 44 24 08 00 6e 10 	movl   $0x106e00,0x8(%esp)
  104302:	00 
  104303:	c7 44 24 04 dc 00 00 	movl   $0xdc,0x4(%esp)
  10430a:	00 
  10430b:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104312:	e8 d0 c9 ff ff       	call   100ce7 <__panic>
  104317:	8b 45 b8             	mov    -0x48(%ebp),%eax
  10431a:	05 00 00 00 40       	add    $0x40000000,%eax
  10431f:	89 45 b4             	mov    %eax,-0x4c(%ebp)

    for (i = 0; i < memmap->nr_map; i ++) {
  104322:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  104329:	e9 53 01 00 00       	jmp    104481 <page_init+0x3a7>
        uint64_t begin = memmap->map[i].addr, end = begin + memmap->map[i].size;
  10432e:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104331:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104334:	89 d0                	mov    %edx,%eax
  104336:	c1 e0 02             	shl    $0x2,%eax
  104339:	01 d0                	add    %edx,%eax
  10433b:	c1 e0 02             	shl    $0x2,%eax
  10433e:	01 c8                	add    %ecx,%eax
  104340:	8b 50 08             	mov    0x8(%eax),%edx
  104343:	8b 40 04             	mov    0x4(%eax),%eax
  104346:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104349:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  10434c:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  10434f:	8b 55 dc             	mov    -0x24(%ebp),%edx
  104352:	89 d0                	mov    %edx,%eax
  104354:	c1 e0 02             	shl    $0x2,%eax
  104357:	01 d0                	add    %edx,%eax
  104359:	c1 e0 02             	shl    $0x2,%eax
  10435c:	01 c8                	add    %ecx,%eax
  10435e:	8b 48 0c             	mov    0xc(%eax),%ecx
  104361:	8b 58 10             	mov    0x10(%eax),%ebx
  104364:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104367:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  10436a:	01 c8                	add    %ecx,%eax
  10436c:	11 da                	adc    %ebx,%edx
  10436e:	89 45 c8             	mov    %eax,-0x38(%ebp)
  104371:	89 55 cc             	mov    %edx,-0x34(%ebp)
        if (memmap->map[i].type == E820_ARM) {
  104374:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  104377:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10437a:	89 d0                	mov    %edx,%eax
  10437c:	c1 e0 02             	shl    $0x2,%eax
  10437f:	01 d0                	add    %edx,%eax
  104381:	c1 e0 02             	shl    $0x2,%eax
  104384:	01 c8                	add    %ecx,%eax
  104386:	83 c0 14             	add    $0x14,%eax
  104389:	8b 00                	mov    (%eax),%eax
  10438b:	83 f8 01             	cmp    $0x1,%eax
  10438e:	0f 85 ea 00 00 00    	jne    10447e <page_init+0x3a4>
            if (begin < freemem) {
  104394:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  104397:	ba 00 00 00 00       	mov    $0x0,%edx
  10439c:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  10439f:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  1043a2:	19 d1                	sbb    %edx,%ecx
  1043a4:	73 0d                	jae    1043b3 <page_init+0x2d9>
                begin = freemem;
  1043a6:	8b 45 b4             	mov    -0x4c(%ebp),%eax
  1043a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1043ac:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
            }
            if (end > KMEMSIZE) {
  1043b3:	ba 00 00 00 38       	mov    $0x38000000,%edx
  1043b8:	b8 00 00 00 00       	mov    $0x0,%eax
  1043bd:	3b 55 c8             	cmp    -0x38(%ebp),%edx
  1043c0:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1043c3:	73 0e                	jae    1043d3 <page_init+0x2f9>
                end = KMEMSIZE;
  1043c5:	c7 45 c8 00 00 00 38 	movl   $0x38000000,-0x38(%ebp)
  1043cc:	c7 45 cc 00 00 00 00 	movl   $0x0,-0x34(%ebp)
            }
            if (begin < end) {
  1043d3:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1043d6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1043d9:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  1043dc:	89 d0                	mov    %edx,%eax
  1043de:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  1043e1:	0f 83 97 00 00 00    	jae    10447e <page_init+0x3a4>
                begin = ROUNDUP(begin, PGSIZE);
  1043e7:	c7 45 b0 00 10 00 00 	movl   $0x1000,-0x50(%ebp)
  1043ee:	8b 55 d0             	mov    -0x30(%ebp),%edx
  1043f1:	8b 45 b0             	mov    -0x50(%ebp),%eax
  1043f4:	01 d0                	add    %edx,%eax
  1043f6:	48                   	dec    %eax
  1043f7:	89 45 ac             	mov    %eax,-0x54(%ebp)
  1043fa:	8b 45 ac             	mov    -0x54(%ebp),%eax
  1043fd:	ba 00 00 00 00       	mov    $0x0,%edx
  104402:	f7 75 b0             	divl   -0x50(%ebp)
  104405:	8b 45 ac             	mov    -0x54(%ebp),%eax
  104408:	29 d0                	sub    %edx,%eax
  10440a:	ba 00 00 00 00       	mov    $0x0,%edx
  10440f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  104412:	89 55 d4             	mov    %edx,-0x2c(%ebp)
                end = ROUNDDOWN(end, PGSIZE);
  104415:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104418:	89 45 a8             	mov    %eax,-0x58(%ebp)
  10441b:	8b 45 a8             	mov    -0x58(%ebp),%eax
  10441e:	ba 00 00 00 00       	mov    $0x0,%edx
  104423:	89 c7                	mov    %eax,%edi
  104425:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  10442b:	89 7d 80             	mov    %edi,-0x80(%ebp)
  10442e:	89 d0                	mov    %edx,%eax
  104430:	83 e0 00             	and    $0x0,%eax
  104433:	89 45 84             	mov    %eax,-0x7c(%ebp)
  104436:	8b 45 80             	mov    -0x80(%ebp),%eax
  104439:	8b 55 84             	mov    -0x7c(%ebp),%edx
  10443c:	89 45 c8             	mov    %eax,-0x38(%ebp)
  10443f:	89 55 cc             	mov    %edx,-0x34(%ebp)
                if (begin < end) {
  104442:	8b 45 d0             	mov    -0x30(%ebp),%eax
  104445:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  104448:	3b 45 c8             	cmp    -0x38(%ebp),%eax
  10444b:	89 d0                	mov    %edx,%eax
  10444d:	1b 45 cc             	sbb    -0x34(%ebp),%eax
  104450:	73 2c                	jae    10447e <page_init+0x3a4>
                    init_memmap(pa2page(begin), (end - begin) / PGSIZE);
  104452:	8b 45 c8             	mov    -0x38(%ebp),%eax
  104455:	8b 55 cc             	mov    -0x34(%ebp),%edx
  104458:	2b 45 d0             	sub    -0x30(%ebp),%eax
  10445b:	1b 55 d4             	sbb    -0x2c(%ebp),%edx
  10445e:	0f ac d0 0c          	shrd   $0xc,%edx,%eax
  104462:	c1 ea 0c             	shr    $0xc,%edx
  104465:	89 c3                	mov    %eax,%ebx
  104467:	8b 45 d0             	mov    -0x30(%ebp),%eax
  10446a:	89 04 24             	mov    %eax,(%esp)
  10446d:	e8 bb f8 ff ff       	call   103d2d <pa2page>
  104472:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  104476:	89 04 24             	mov    %eax,(%esp)
  104479:	e8 9e fb ff ff       	call   10401c <init_memmap>
    for (i = 0; i < memmap->nr_map; i ++) {
  10447e:	ff 45 dc             	incl   -0x24(%ebp)
  104481:	8b 45 c4             	mov    -0x3c(%ebp),%eax
  104484:	8b 00                	mov    (%eax),%eax
  104486:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  104489:	0f 8c 9f fe ff ff    	jl     10432e <page_init+0x254>
                }
            }
        }
    }
}
  10448f:	90                   	nop
  104490:	90                   	nop
  104491:	81 c4 9c 00 00 00    	add    $0x9c,%esp
  104497:	5b                   	pop    %ebx
  104498:	5e                   	pop    %esi
  104499:	5f                   	pop    %edi
  10449a:	5d                   	pop    %ebp
  10449b:	c3                   	ret    

0010449c <boot_map_segment>:
//  la:   linear address of this memory need to map (after x86 segment map)
//  size: memory size
//  pa:   physical address of this memory
//  perm: permission of this memory  
static void
boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size, uintptr_t pa, uint32_t perm) {
  10449c:	55                   	push   %ebp
  10449d:	89 e5                	mov    %esp,%ebp
  10449f:	83 ec 38             	sub    $0x38,%esp
    assert(PGOFF(la) == PGOFF(pa));
  1044a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044a5:	33 45 14             	xor    0x14(%ebp),%eax
  1044a8:	25 ff 0f 00 00       	and    $0xfff,%eax
  1044ad:	85 c0                	test   %eax,%eax
  1044af:	74 24                	je     1044d5 <boot_map_segment+0x39>
  1044b1:	c7 44 24 0c 32 6e 10 	movl   $0x106e32,0xc(%esp)
  1044b8:	00 
  1044b9:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  1044c0:	00 
  1044c1:	c7 44 24 04 fa 00 00 	movl   $0xfa,0x4(%esp)
  1044c8:	00 
  1044c9:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1044d0:	e8 12 c8 ff ff       	call   100ce7 <__panic>
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
  1044d5:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
  1044dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  1044df:	25 ff 0f 00 00       	and    $0xfff,%eax
  1044e4:	89 c2                	mov    %eax,%edx
  1044e6:	8b 45 10             	mov    0x10(%ebp),%eax
  1044e9:	01 c2                	add    %eax,%edx
  1044eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1044ee:	01 d0                	add    %edx,%eax
  1044f0:	48                   	dec    %eax
  1044f1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1044f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1044f7:	ba 00 00 00 00       	mov    $0x0,%edx
  1044fc:	f7 75 f0             	divl   -0x10(%ebp)
  1044ff:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104502:	29 d0                	sub    %edx,%eax
  104504:	c1 e8 0c             	shr    $0xc,%eax
  104507:	89 45 f4             	mov    %eax,-0xc(%ebp)
    la = ROUNDDOWN(la, PGSIZE);
  10450a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10450d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104510:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104513:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104518:	89 45 0c             	mov    %eax,0xc(%ebp)
    pa = ROUNDDOWN(pa, PGSIZE);
  10451b:	8b 45 14             	mov    0x14(%ebp),%eax
  10451e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104521:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104524:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104529:	89 45 14             	mov    %eax,0x14(%ebp)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  10452c:	eb 68                	jmp    104596 <boot_map_segment+0xfa>
        pte_t *ptep = get_pte(pgdir, la, 1);
  10452e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  104535:	00 
  104536:	8b 45 0c             	mov    0xc(%ebp),%eax
  104539:	89 44 24 04          	mov    %eax,0x4(%esp)
  10453d:	8b 45 08             	mov    0x8(%ebp),%eax
  104540:	89 04 24             	mov    %eax,(%esp)
  104543:	e8 88 01 00 00       	call   1046d0 <get_pte>
  104548:	89 45 e0             	mov    %eax,-0x20(%ebp)
        assert(ptep != NULL);
  10454b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  10454f:	75 24                	jne    104575 <boot_map_segment+0xd9>
  104551:	c7 44 24 0c 5e 6e 10 	movl   $0x106e5e,0xc(%esp)
  104558:	00 
  104559:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104560:	00 
  104561:	c7 44 24 04 00 01 00 	movl   $0x100,0x4(%esp)
  104568:	00 
  104569:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104570:	e8 72 c7 ff ff       	call   100ce7 <__panic>
        *ptep = pa | PTE_P | perm;
  104575:	8b 45 14             	mov    0x14(%ebp),%eax
  104578:	0b 45 18             	or     0x18(%ebp),%eax
  10457b:	83 c8 01             	or     $0x1,%eax
  10457e:	89 c2                	mov    %eax,%edx
  104580:	8b 45 e0             	mov    -0x20(%ebp),%eax
  104583:	89 10                	mov    %edx,(%eax)
    for (; n > 0; n --, la += PGSIZE, pa += PGSIZE) {
  104585:	ff 4d f4             	decl   -0xc(%ebp)
  104588:	81 45 0c 00 10 00 00 	addl   $0x1000,0xc(%ebp)
  10458f:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  104596:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  10459a:	75 92                	jne    10452e <boot_map_segment+0x92>
    }
}
  10459c:	90                   	nop
  10459d:	90                   	nop
  10459e:	89 ec                	mov    %ebp,%esp
  1045a0:	5d                   	pop    %ebp
  1045a1:	c3                   	ret    

001045a2 <boot_alloc_page>:

//boot_alloc_page - allocate one page using pmm->alloc_pages(1) 
// return value: the kernel virtual address of this allocated page
//note: this function is used to get the memory for PDT(Page Directory Table)&PT(Page Table)
static void *
boot_alloc_page(void) {
  1045a2:	55                   	push   %ebp
  1045a3:	89 e5                	mov    %esp,%ebp
  1045a5:	83 ec 28             	sub    $0x28,%esp
    struct Page *p = alloc_page();
  1045a8:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  1045af:	e8 8a fa ff ff       	call   10403e <alloc_pages>
  1045b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (p == NULL) {
  1045b7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1045bb:	75 1c                	jne    1045d9 <boot_alloc_page+0x37>
        panic("boot_alloc_page failed.\n");
  1045bd:	c7 44 24 08 6b 6e 10 	movl   $0x106e6b,0x8(%esp)
  1045c4:	00 
  1045c5:	c7 44 24 04 0c 01 00 	movl   $0x10c,0x4(%esp)
  1045cc:	00 
  1045cd:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1045d4:	e8 0e c7 ff ff       	call   100ce7 <__panic>
    }
    return page2kva(p);
  1045d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1045dc:	89 04 24             	mov    %eax,(%esp)
  1045df:	e8 9a f7 ff ff       	call   103d7e <page2kva>
}
  1045e4:	89 ec                	mov    %ebp,%esp
  1045e6:	5d                   	pop    %ebp
  1045e7:	c3                   	ret    

001045e8 <pmm_init>:

//pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup paging mechanism 
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void
pmm_init(void) {
  1045e8:	55                   	push   %ebp
  1045e9:	89 e5                	mov    %esp,%ebp
  1045eb:	83 ec 38             	sub    $0x38,%esp
    // We've already enabled paging
    boot_cr3 = PADDR(boot_pgdir);
  1045ee:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1045f3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1045f6:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1045fd:	77 23                	ja     104622 <pmm_init+0x3a>
  1045ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104602:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104606:	c7 44 24 08 00 6e 10 	movl   $0x106e00,0x8(%esp)
  10460d:	00 
  10460e:	c7 44 24 04 16 01 00 	movl   $0x116,0x4(%esp)
  104615:	00 
  104616:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  10461d:	e8 c5 c6 ff ff       	call   100ce7 <__panic>
  104622:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104625:	05 00 00 00 40       	add    $0x40000000,%eax
  10462a:	a3 08 cf 11 00       	mov    %eax,0x11cf08
    //We need to alloc/free the physical memory (granularity is 4KB or other size). 
    //So a framework of physical memory manager (struct pmm_manager)is defined in pmm.h
    //First we should init a physical memory manager(pmm) based on the framework.
    //Then pmm can alloc/free the physical memory. 
    //Now the first_fit/best_fit/worst_fit/buddy_system pmm are available.
    init_pmm_manager();
  10462f:	e8 b2 f9 ff ff       	call   103fe6 <init_pmm_manager>

    // detect physical memory space, reserve already used memory,
    // then use pmm->init_memmap to create free page list
    page_init();
  104634:	e8 a1 fa ff ff       	call   1040da <page_init>

    //use pmm->check to verify the correctness of the alloc/free function in a pmm
    check_alloc_page();
  104639:	e8 ed 03 00 00       	call   104a2b <check_alloc_page>

    check_pgdir();
  10463e:	e8 09 04 00 00       	call   104a4c <check_pgdir>

    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // recursively insert boot_pgdir in itself
    // to form a virtual page table at virtual address VPT
    boot_pgdir[PDX(VPT)] = PADDR(boot_pgdir) | PTE_P | PTE_W;
  104643:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104648:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10464b:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  104652:	77 23                	ja     104677 <pmm_init+0x8f>
  104654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104657:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10465b:	c7 44 24 08 00 6e 10 	movl   $0x106e00,0x8(%esp)
  104662:	00 
  104663:	c7 44 24 04 2c 01 00 	movl   $0x12c,0x4(%esp)
  10466a:	00 
  10466b:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104672:	e8 70 c6 ff ff       	call   100ce7 <__panic>
  104677:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10467a:	8d 90 00 00 00 40    	lea    0x40000000(%eax),%edx
  104680:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104685:	05 ac 0f 00 00       	add    $0xfac,%eax
  10468a:	83 ca 03             	or     $0x3,%edx
  10468d:	89 10                	mov    %edx,(%eax)

    // map all physical memory to linear memory with base linear addr KERNBASE
    // linear_addr KERNBASE ~ KERNBASE + KMEMSIZE = phy_addr 0 ~ KMEMSIZE
    boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, 0, PTE_W);
  10468f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104694:	c7 44 24 10 02 00 00 	movl   $0x2,0x10(%esp)
  10469b:	00 
  10469c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  1046a3:	00 
  1046a4:	c7 44 24 08 00 00 00 	movl   $0x38000000,0x8(%esp)
  1046ab:	38 
  1046ac:	c7 44 24 04 00 00 00 	movl   $0xc0000000,0x4(%esp)
  1046b3:	c0 
  1046b4:	89 04 24             	mov    %eax,(%esp)
  1046b7:	e8 e0 fd ff ff       	call   10449c <boot_map_segment>

    // Since we are using bootloader's GDT,
    // we should reload gdt (second time, the last time) to get user segments and the TSS
    // map virtual_addr 0 ~ 4G = linear_addr 0 ~ 4G
    // then set kernel stack (ss:esp) in TSS, setup TSS in gdt, load TSS
    gdt_init();
  1046bc:	e8 39 f8 ff ff       	call   103efa <gdt_init>

    //now the basic virtual memory map(see memalyout.h) is established.
    //check the correctness of the basic virtual memory map.
    check_boot_pgdir();
  1046c1:	e8 24 0a 00 00       	call   1050ea <check_boot_pgdir>

    print_pgdir();
  1046c6:	e8 a1 0e 00 00       	call   10556c <print_pgdir>

}
  1046cb:	90                   	nop
  1046cc:	89 ec                	mov    %ebp,%esp
  1046ce:	5d                   	pop    %ebp
  1046cf:	c3                   	ret    

001046d0 <get_pte>:
//  pgdir:  the kernel virtual base address of PDT   页目录表(一级页表)的起始内核虚拟地址
//  la:     the linear address need to map              需要被映射关联的线性虚拟地址
//  create: a logical value to decide if alloc a page for PT   一个布尔变量决定对应页表项所属的页表不存在时，是否将页表创建
// return vaule: the kernel virtual address of this pte  返回值: la参数对应的二级页表项结构的内核虚拟地址
pte_t *
get_pte(pde_t *pgdir, uintptr_t la, bool create) {
  1046d0:	55                   	push   %ebp
  1046d1:	89 e5                	mov    %esp,%ebp
  1046d3:	83 ec 38             	sub    $0x38,%esp
    }
    return NULL;          // (8) return page table entry
#endif
    // PDX(la) 根据la的高10位获得对应的页目录项(一级页表中的某一项)索引(页目录项)
    // &pgdir[PDX(la)] 根据一级页表项索引从一级页表中找到对应的页目录项指针
    pde_t *pdep = &pgdir[PDX(la)];
  1046d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  1046d9:	c1 e8 16             	shr    $0x16,%eax
  1046dc:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1046e3:	8b 45 08             	mov    0x8(%ebp),%eax
  1046e6:	01 d0                	add    %edx,%eax
  1046e8:	89 45 f4             	mov    %eax,-0xc(%ebp)
    // 判断当前页目录项的Present存在位是否为1(对应的二级页表是否存在)
    if (!(*pdep & PTE_P)) {
  1046eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1046ee:	8b 00                	mov    (%eax),%eax
  1046f0:	83 e0 01             	and    $0x1,%eax
  1046f3:	85 c0                	test   %eax,%eax
  1046f5:	0f 85 af 00 00 00    	jne    1047aa <get_pte+0xda>
        // 对应的二级页表不存在
        // *page指向的是这个新创建的二级页表基地址
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
  1046fb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  1046ff:	74 15                	je     104716 <get_pte+0x46>
  104701:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104708:	e8 31 f9 ff ff       	call   10403e <alloc_pages>
  10470d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104710:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104714:	75 0a                	jne    104720 <get_pte+0x50>
             // 如果create参数为false或是alloc_page分配物理内存失败
            return NULL;
  104716:	b8 00 00 00 00       	mov    $0x0,%eax
  10471b:	e9 e7 00 00 00       	jmp    104807 <get_pte+0x137>
        }
        // 二级页表所对应的物理页 引用数为1
        set_page_ref(page, 1);
  104720:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  104727:	00 
  104728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10472b:	89 04 24             	mov    %eax,(%esp)
  10472e:	e8 05 f7 ff ff       	call   103e38 <set_page_ref>
        // 获得page变量的物理地址
        uintptr_t pa = page2pa(page);
  104733:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104736:	89 04 24             	mov    %eax,(%esp)
  104739:	e8 d7 f5 ff ff       	call   103d15 <page2pa>
  10473e:	89 45 ec             	mov    %eax,-0x14(%ebp)
        // 将整个page所在的物理页格式化，全部填满0
        memset(KADDR(pa), 0, PGSIZE);
  104741:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104744:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104747:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10474a:	c1 e8 0c             	shr    $0xc,%eax
  10474d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  104750:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  104755:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  104758:	72 23                	jb     10477d <get_pte+0xad>
  10475a:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10475d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104761:	c7 44 24 08 5c 6d 10 	movl   $0x106d5c,0x8(%esp)
  104768:	00 
  104769:	c7 44 24 04 7c 01 00 	movl   $0x17c,0x4(%esp)
  104770:	00 
  104771:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104778:	e8 6a c5 ff ff       	call   100ce7 <__panic>
  10477d:	8b 45 e8             	mov    -0x18(%ebp),%eax
  104780:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104785:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  10478c:	00 
  10478d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104794:	00 
  104795:	89 04 24             	mov    %eax,(%esp)
  104798:	e8 d4 18 00 00       	call   106071 <memset>
        // la对应的一级页目录项进行赋值，使其指向新创建的二级页表(页表中的数据被MMU直接处理，为了映射效率存放的都是物理地址)
        // 或PTE_U/PTE_W/PET_P 标识当前页目录项是用户级别的、可写的、已存在的
        *pdep = pa | PTE_U | PTE_W | PTE_P;
  10479d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1047a0:	83 c8 07             	or     $0x7,%eax
  1047a3:	89 c2                	mov    %eax,%edx
  1047a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047a8:	89 10                	mov    %edx,(%eax)
    }

    // 要想通过C语言中的数组来访问对应数据，需要的是数组基址(虚拟地址),而*pdep中页目录表项中存放了对应二级页表的一个物理地址
    // PDE_ADDR将*pdep的低12位抹零对齐(指向二级页表的起始基地址)，再通过KADDR转为内核虚拟地址，进行数组访问
    // PTX(la)获得la线性地址的中间10位部分，即二级页表中对应页表项的索引下标。这样便能得到la对应的二级页表项了
    return &((pte_t *)KADDR(PDE_ADDR(*pdep)))[PTX(la)];
  1047aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1047ad:	8b 00                	mov    (%eax),%eax
  1047af:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1047b4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1047b7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1047ba:	c1 e8 0c             	shr    $0xc,%eax
  1047bd:	89 45 dc             	mov    %eax,-0x24(%ebp)
  1047c0:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  1047c5:	39 45 dc             	cmp    %eax,-0x24(%ebp)
  1047c8:	72 23                	jb     1047ed <get_pte+0x11d>
  1047ca:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1047cd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1047d1:	c7 44 24 08 5c 6d 10 	movl   $0x106d5c,0x8(%esp)
  1047d8:	00 
  1047d9:	c7 44 24 04 85 01 00 	movl   $0x185,0x4(%esp)
  1047e0:	00 
  1047e1:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1047e8:	e8 fa c4 ff ff       	call   100ce7 <__panic>
  1047ed:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1047f0:	2d 00 00 00 40       	sub    $0x40000000,%eax
  1047f5:	89 c2                	mov    %eax,%edx
  1047f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  1047fa:	c1 e8 0c             	shr    $0xc,%eax
  1047fd:	25 ff 03 00 00       	and    $0x3ff,%eax
  104802:	c1 e0 02             	shl    $0x2,%eax
  104805:	01 d0                	add    %edx,%eax
}
  104807:	89 ec                	mov    %ebp,%esp
  104809:	5d                   	pop    %ebp
  10480a:	c3                   	ret    

0010480b <get_page>:

//get_page - get related Page struct for linear address la using PDT pgdir
struct Page *
get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
  10480b:	55                   	push   %ebp
  10480c:	89 e5                	mov    %esp,%ebp
  10480e:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  104811:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104818:	00 
  104819:	8b 45 0c             	mov    0xc(%ebp),%eax
  10481c:	89 44 24 04          	mov    %eax,0x4(%esp)
  104820:	8b 45 08             	mov    0x8(%ebp),%eax
  104823:	89 04 24             	mov    %eax,(%esp)
  104826:	e8 a5 fe ff ff       	call   1046d0 <get_pte>
  10482b:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep_store != NULL) {
  10482e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  104832:	74 08                	je     10483c <get_page+0x31>
        *ptep_store = ptep;
  104834:	8b 45 10             	mov    0x10(%ebp),%eax
  104837:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10483a:	89 10                	mov    %edx,(%eax)
    }
    if (ptep != NULL && *ptep & PTE_P) {
  10483c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104840:	74 1b                	je     10485d <get_page+0x52>
  104842:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104845:	8b 00                	mov    (%eax),%eax
  104847:	83 e0 01             	and    $0x1,%eax
  10484a:	85 c0                	test   %eax,%eax
  10484c:	74 0f                	je     10485d <get_page+0x52>
        return pte2page(*ptep);
  10484e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104851:	8b 00                	mov    (%eax),%eax
  104853:	89 04 24             	mov    %eax,(%esp)
  104856:	e8 79 f5 ff ff       	call   103dd4 <pte2page>
  10485b:	eb 05                	jmp    104862 <get_page+0x57>
    }
    return NULL;
  10485d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  104862:	89 ec                	mov    %ebp,%esp
  104864:	5d                   	pop    %ebp
  104865:	c3                   	ret    

00104866 <page_remove_pte>:

//page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
//note: PT is changed, so the TLB need to be invalidate 
static inline void
page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
  104866:	55                   	push   %ebp
  104867:	89 e5                	mov    %esp,%ebp
  104869:	83 ec 28             	sub    $0x28,%esp
                                  //(4) and free this page when page reference reachs 0
                                  //(5) clear second page table entry
                                  //(6) flush tlb
    }
#endif
    if (*ptep & PTE_P) {
  10486c:	8b 45 10             	mov    0x10(%ebp),%eax
  10486f:	8b 00                	mov    (%eax),%eax
  104871:	83 e0 01             	and    $0x1,%eax
  104874:	85 c0                	test   %eax,%eax
  104876:	74 4d                	je     1048c5 <page_remove_pte+0x5f>
        // 如果对应的二级页表项存在
        // 获得*ptep对应的Page结构
        struct Page *page = pte2page(*ptep);
  104878:	8b 45 10             	mov    0x10(%ebp),%eax
  10487b:	8b 00                	mov    (%eax),%eax
  10487d:	89 04 24             	mov    %eax,(%esp)
  104880:	e8 4f f5 ff ff       	call   103dd4 <pte2page>
  104885:	89 45 f4             	mov    %eax,-0xc(%ebp)
        // 关联的page引用数自减1
        if (page_ref_dec(page) == 0) {
  104888:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10488b:	89 04 24             	mov    %eax,(%esp)
  10488e:	e8 ca f5 ff ff       	call   103e5d <page_ref_dec>
  104893:	85 c0                	test   %eax,%eax
  104895:	75 13                	jne    1048aa <page_remove_pte+0x44>
            // 如果自减1后，引用数为0，需要free释放掉该物理页
            free_page(page);
  104897:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10489e:	00 
  10489f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048a2:	89 04 24             	mov    %eax,(%esp)
  1048a5:	e8 ce f7 ff ff       	call   104078 <free_pages>
        }
        // 清空当前二级页表项(整体设置为0)
        *ptep = 0;
  1048aa:	8b 45 10             	mov    0x10(%ebp),%eax
  1048ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
        // 由于页表项发生了改变，需要TLB快表
        tlb_invalidate(pgdir, la);
  1048b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048b6:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1048bd:	89 04 24             	mov    %eax,(%esp)
  1048c0:	e8 07 01 00 00       	call   1049cc <tlb_invalidate>
    }
}
  1048c5:	90                   	nop
  1048c6:	89 ec                	mov    %ebp,%esp
  1048c8:	5d                   	pop    %ebp
  1048c9:	c3                   	ret    

001048ca <page_remove>:

//page_remove - free an Page which is related linear address la and has an validated pte
void
page_remove(pde_t *pgdir, uintptr_t la) {
  1048ca:	55                   	push   %ebp
  1048cb:	89 e5                	mov    %esp,%ebp
  1048cd:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 0);
  1048d0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  1048d7:	00 
  1048d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048db:	89 44 24 04          	mov    %eax,0x4(%esp)
  1048df:	8b 45 08             	mov    0x8(%ebp),%eax
  1048e2:	89 04 24             	mov    %eax,(%esp)
  1048e5:	e8 e6 fd ff ff       	call   1046d0 <get_pte>
  1048ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep != NULL) {
  1048ed:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  1048f1:	74 19                	je     10490c <page_remove+0x42>
        page_remove_pte(pgdir, la, ptep);
  1048f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1048f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  1048fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  1048fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  104901:	8b 45 08             	mov    0x8(%ebp),%eax
  104904:	89 04 24             	mov    %eax,(%esp)
  104907:	e8 5a ff ff ff       	call   104866 <page_remove_pte>
    }
}
  10490c:	90                   	nop
  10490d:	89 ec                	mov    %ebp,%esp
  10490f:	5d                   	pop    %ebp
  104910:	c3                   	ret    

00104911 <page_insert>:
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
//note: PT is changed, so the TLB need to be invalidate 
int
page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
  104911:	55                   	push   %ebp
  104912:	89 e5                	mov    %esp,%ebp
  104914:	83 ec 28             	sub    $0x28,%esp
    pte_t *ptep = get_pte(pgdir, la, 1);
  104917:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
  10491e:	00 
  10491f:	8b 45 10             	mov    0x10(%ebp),%eax
  104922:	89 44 24 04          	mov    %eax,0x4(%esp)
  104926:	8b 45 08             	mov    0x8(%ebp),%eax
  104929:	89 04 24             	mov    %eax,(%esp)
  10492c:	e8 9f fd ff ff       	call   1046d0 <get_pte>
  104931:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if (ptep == NULL) {
  104934:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  104938:	75 0a                	jne    104944 <page_insert+0x33>
        return -E_NO_MEM;
  10493a:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
  10493f:	e9 84 00 00 00       	jmp    1049c8 <page_insert+0xb7>
    }
    page_ref_inc(page);
  104944:	8b 45 0c             	mov    0xc(%ebp),%eax
  104947:	89 04 24             	mov    %eax,(%esp)
  10494a:	e8 f7 f4 ff ff       	call   103e46 <page_ref_inc>
    if (*ptep & PTE_P) {
  10494f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104952:	8b 00                	mov    (%eax),%eax
  104954:	83 e0 01             	and    $0x1,%eax
  104957:	85 c0                	test   %eax,%eax
  104959:	74 3e                	je     104999 <page_insert+0x88>
        struct Page *p = pte2page(*ptep);
  10495b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10495e:	8b 00                	mov    (%eax),%eax
  104960:	89 04 24             	mov    %eax,(%esp)
  104963:	e8 6c f4 ff ff       	call   103dd4 <pte2page>
  104968:	89 45 f0             	mov    %eax,-0x10(%ebp)
        if (p == page) {
  10496b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10496e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  104971:	75 0d                	jne    104980 <page_insert+0x6f>
            page_ref_dec(page);
  104973:	8b 45 0c             	mov    0xc(%ebp),%eax
  104976:	89 04 24             	mov    %eax,(%esp)
  104979:	e8 df f4 ff ff       	call   103e5d <page_ref_dec>
  10497e:	eb 19                	jmp    104999 <page_insert+0x88>
        }
        else {
            page_remove_pte(pgdir, la, ptep);
  104980:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104983:	89 44 24 08          	mov    %eax,0x8(%esp)
  104987:	8b 45 10             	mov    0x10(%ebp),%eax
  10498a:	89 44 24 04          	mov    %eax,0x4(%esp)
  10498e:	8b 45 08             	mov    0x8(%ebp),%eax
  104991:	89 04 24             	mov    %eax,(%esp)
  104994:	e8 cd fe ff ff       	call   104866 <page_remove_pte>
        }
    }
    *ptep = page2pa(page) | PTE_P | perm;
  104999:	8b 45 0c             	mov    0xc(%ebp),%eax
  10499c:	89 04 24             	mov    %eax,(%esp)
  10499f:	e8 71 f3 ff ff       	call   103d15 <page2pa>
  1049a4:	0b 45 14             	or     0x14(%ebp),%eax
  1049a7:	83 c8 01             	or     $0x1,%eax
  1049aa:	89 c2                	mov    %eax,%edx
  1049ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049af:	89 10                	mov    %edx,(%eax)
    tlb_invalidate(pgdir, la);
  1049b1:	8b 45 10             	mov    0x10(%ebp),%eax
  1049b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1049b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1049bb:	89 04 24             	mov    %eax,(%esp)
  1049be:	e8 09 00 00 00       	call   1049cc <tlb_invalidate>
    return 0;
  1049c3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1049c8:	89 ec                	mov    %ebp,%esp
  1049ca:	5d                   	pop    %ebp
  1049cb:	c3                   	ret    

001049cc <tlb_invalidate>:

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void
tlb_invalidate(pde_t *pgdir, uintptr_t la) {
  1049cc:	55                   	push   %ebp
  1049cd:	89 e5                	mov    %esp,%ebp
  1049cf:	83 ec 28             	sub    $0x28,%esp
}

static inline uintptr_t
rcr3(void) {
    uintptr_t cr3;
    asm volatile ("mov %%cr3, %0" : "=r" (cr3) :: "memory");
  1049d2:	0f 20 d8             	mov    %cr3,%eax
  1049d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    return cr3;
  1049d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
    if (rcr3() == PADDR(pgdir)) {
  1049db:	8b 45 08             	mov    0x8(%ebp),%eax
  1049de:	89 45 f4             	mov    %eax,-0xc(%ebp)
  1049e1:	81 7d f4 ff ff ff bf 	cmpl   $0xbfffffff,-0xc(%ebp)
  1049e8:	77 23                	ja     104a0d <tlb_invalidate+0x41>
  1049ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1049ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  1049f1:	c7 44 24 08 00 6e 10 	movl   $0x106e00,0x8(%esp)
  1049f8:	00 
  1049f9:	c7 44 24 04 ed 01 00 	movl   $0x1ed,0x4(%esp)
  104a00:	00 
  104a01:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104a08:	e8 da c2 ff ff       	call   100ce7 <__panic>
  104a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104a10:	05 00 00 00 40       	add    $0x40000000,%eax
  104a15:	39 d0                	cmp    %edx,%eax
  104a17:	75 0d                	jne    104a26 <tlb_invalidate+0x5a>
        invlpg((void *)la);
  104a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  104a1c:	89 45 ec             	mov    %eax,-0x14(%ebp)
}

static inline void
invlpg(void *addr) {
    asm volatile ("invlpg (%0)" :: "r" (addr) : "memory");
  104a1f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104a22:	0f 01 38             	invlpg (%eax)
}
  104a25:	90                   	nop
    }
}
  104a26:	90                   	nop
  104a27:	89 ec                	mov    %ebp,%esp
  104a29:	5d                   	pop    %ebp
  104a2a:	c3                   	ret    

00104a2b <check_alloc_page>:

static void
check_alloc_page(void) {
  104a2b:	55                   	push   %ebp
  104a2c:	89 e5                	mov    %esp,%ebp
  104a2e:	83 ec 18             	sub    $0x18,%esp
    pmm_manager->check();
  104a31:	a1 0c cf 11 00       	mov    0x11cf0c,%eax
  104a36:	8b 40 18             	mov    0x18(%eax),%eax
  104a39:	ff d0                	call   *%eax
    cprintf("check_alloc_page() succeeded!\n");
  104a3b:	c7 04 24 84 6e 10 00 	movl   $0x106e84,(%esp)
  104a42:	e8 0f b9 ff ff       	call   100356 <cprintf>
}
  104a47:	90                   	nop
  104a48:	89 ec                	mov    %ebp,%esp
  104a4a:	5d                   	pop    %ebp
  104a4b:	c3                   	ret    

00104a4c <check_pgdir>:

static void
check_pgdir(void) {
  104a4c:	55                   	push   %ebp
  104a4d:	89 e5                	mov    %esp,%ebp
  104a4f:	83 ec 38             	sub    $0x38,%esp
    assert(npage <= KMEMSIZE / PGSIZE);
  104a52:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  104a57:	3d 00 80 03 00       	cmp    $0x38000,%eax
  104a5c:	76 24                	jbe    104a82 <check_pgdir+0x36>
  104a5e:	c7 44 24 0c a3 6e 10 	movl   $0x106ea3,0xc(%esp)
  104a65:	00 
  104a66:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104a6d:	00 
  104a6e:	c7 44 24 04 fa 01 00 	movl   $0x1fa,0x4(%esp)
  104a75:	00 
  104a76:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104a7d:	e8 65 c2 ff ff       	call   100ce7 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
  104a82:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104a87:	85 c0                	test   %eax,%eax
  104a89:	74 0e                	je     104a99 <check_pgdir+0x4d>
  104a8b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104a90:	25 ff 0f 00 00       	and    $0xfff,%eax
  104a95:	85 c0                	test   %eax,%eax
  104a97:	74 24                	je     104abd <check_pgdir+0x71>
  104a99:	c7 44 24 0c c0 6e 10 	movl   $0x106ec0,0xc(%esp)
  104aa0:	00 
  104aa1:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104aa8:	00 
  104aa9:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
  104ab0:	00 
  104ab1:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104ab8:	e8 2a c2 ff ff       	call   100ce7 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
  104abd:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ac2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ac9:	00 
  104aca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104ad1:	00 
  104ad2:	89 04 24             	mov    %eax,(%esp)
  104ad5:	e8 31 fd ff ff       	call   10480b <get_page>
  104ada:	85 c0                	test   %eax,%eax
  104adc:	74 24                	je     104b02 <check_pgdir+0xb6>
  104ade:	c7 44 24 0c f8 6e 10 	movl   $0x106ef8,0xc(%esp)
  104ae5:	00 
  104ae6:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104aed:	00 
  104aee:	c7 44 24 04 fc 01 00 	movl   $0x1fc,0x4(%esp)
  104af5:	00 
  104af6:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104afd:	e8 e5 c1 ff ff       	call   100ce7 <__panic>

    struct Page *p1, *p2;
    p1 = alloc_page();
  104b02:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104b09:	e8 30 f5 ff ff       	call   10403e <alloc_pages>
  104b0e:	89 45 f4             	mov    %eax,-0xc(%ebp)
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
  104b11:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104b16:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104b1d:	00 
  104b1e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b25:	00 
  104b26:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104b29:	89 54 24 04          	mov    %edx,0x4(%esp)
  104b2d:	89 04 24             	mov    %eax,(%esp)
  104b30:	e8 dc fd ff ff       	call   104911 <page_insert>
  104b35:	85 c0                	test   %eax,%eax
  104b37:	74 24                	je     104b5d <check_pgdir+0x111>
  104b39:	c7 44 24 0c 20 6f 10 	movl   $0x106f20,0xc(%esp)
  104b40:	00 
  104b41:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104b48:	00 
  104b49:	c7 44 24 04 00 02 00 	movl   $0x200,0x4(%esp)
  104b50:	00 
  104b51:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104b58:	e8 8a c1 ff ff       	call   100ce7 <__panic>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
  104b5d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104b62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104b69:	00 
  104b6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104b71:	00 
  104b72:	89 04 24             	mov    %eax,(%esp)
  104b75:	e8 56 fb ff ff       	call   1046d0 <get_pte>
  104b7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104b7d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104b81:	75 24                	jne    104ba7 <check_pgdir+0x15b>
  104b83:	c7 44 24 0c 4c 6f 10 	movl   $0x106f4c,0xc(%esp)
  104b8a:	00 
  104b8b:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104b92:	00 
  104b93:	c7 44 24 04 03 02 00 	movl   $0x203,0x4(%esp)
  104b9a:	00 
  104b9b:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104ba2:	e8 40 c1 ff ff       	call   100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
  104ba7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104baa:	8b 00                	mov    (%eax),%eax
  104bac:	89 04 24             	mov    %eax,(%esp)
  104baf:	e8 20 f2 ff ff       	call   103dd4 <pte2page>
  104bb4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104bb7:	74 24                	je     104bdd <check_pgdir+0x191>
  104bb9:	c7 44 24 0c 79 6f 10 	movl   $0x106f79,0xc(%esp)
  104bc0:	00 
  104bc1:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104bc8:	00 
  104bc9:	c7 44 24 04 04 02 00 	movl   $0x204,0x4(%esp)
  104bd0:	00 
  104bd1:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104bd8:	e8 0a c1 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p1) == 1);
  104bdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104be0:	89 04 24             	mov    %eax,(%esp)
  104be3:	e8 46 f2 ff ff       	call   103e2e <page_ref>
  104be8:	83 f8 01             	cmp    $0x1,%eax
  104beb:	74 24                	je     104c11 <check_pgdir+0x1c5>
  104bed:	c7 44 24 0c 8f 6f 10 	movl   $0x106f8f,0xc(%esp)
  104bf4:	00 
  104bf5:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104bfc:	00 
  104bfd:	c7 44 24 04 05 02 00 	movl   $0x205,0x4(%esp)
  104c04:	00 
  104c05:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104c0c:	e8 d6 c0 ff ff       	call   100ce7 <__panic>

    ptep = &((pte_t *)KADDR(PDE_ADDR(boot_pgdir[0])))[1];
  104c11:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104c16:	8b 00                	mov    (%eax),%eax
  104c18:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  104c1d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  104c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c23:	c1 e8 0c             	shr    $0xc,%eax
  104c26:	89 45 e8             	mov    %eax,-0x18(%ebp)
  104c29:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  104c2e:	39 45 e8             	cmp    %eax,-0x18(%ebp)
  104c31:	72 23                	jb     104c56 <check_pgdir+0x20a>
  104c33:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c36:	89 44 24 0c          	mov    %eax,0xc(%esp)
  104c3a:	c7 44 24 08 5c 6d 10 	movl   $0x106d5c,0x8(%esp)
  104c41:	00 
  104c42:	c7 44 24 04 07 02 00 	movl   $0x207,0x4(%esp)
  104c49:	00 
  104c4a:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104c51:	e8 91 c0 ff ff       	call   100ce7 <__panic>
  104c56:	8b 45 ec             	mov    -0x14(%ebp),%eax
  104c59:	2d 00 00 00 40       	sub    $0x40000000,%eax
  104c5e:	83 c0 04             	add    $0x4,%eax
  104c61:	89 45 f0             	mov    %eax,-0x10(%ebp)
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
  104c64:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104c69:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104c70:	00 
  104c71:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104c78:	00 
  104c79:	89 04 24             	mov    %eax,(%esp)
  104c7c:	e8 4f fa ff ff       	call   1046d0 <get_pte>
  104c81:	39 45 f0             	cmp    %eax,-0x10(%ebp)
  104c84:	74 24                	je     104caa <check_pgdir+0x25e>
  104c86:	c7 44 24 0c a4 6f 10 	movl   $0x106fa4,0xc(%esp)
  104c8d:	00 
  104c8e:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104c95:	00 
  104c96:	c7 44 24 04 08 02 00 	movl   $0x208,0x4(%esp)
  104c9d:	00 
  104c9e:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104ca5:	e8 3d c0 ff ff       	call   100ce7 <__panic>

    p2 = alloc_page();
  104caa:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  104cb1:	e8 88 f3 ff ff       	call   10403e <alloc_pages>
  104cb6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
  104cb9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104cbe:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  104cc5:	00 
  104cc6:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104ccd:	00 
  104cce:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  104cd1:	89 54 24 04          	mov    %edx,0x4(%esp)
  104cd5:	89 04 24             	mov    %eax,(%esp)
  104cd8:	e8 34 fc ff ff       	call   104911 <page_insert>
  104cdd:	85 c0                	test   %eax,%eax
  104cdf:	74 24                	je     104d05 <check_pgdir+0x2b9>
  104ce1:	c7 44 24 0c cc 6f 10 	movl   $0x106fcc,0xc(%esp)
  104ce8:	00 
  104ce9:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104cf0:	00 
  104cf1:	c7 44 24 04 0b 02 00 	movl   $0x20b,0x4(%esp)
  104cf8:	00 
  104cf9:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104d00:	e8 e2 bf ff ff       	call   100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104d05:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104d0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104d11:	00 
  104d12:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104d19:	00 
  104d1a:	89 04 24             	mov    %eax,(%esp)
  104d1d:	e8 ae f9 ff ff       	call   1046d0 <get_pte>
  104d22:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104d25:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104d29:	75 24                	jne    104d4f <check_pgdir+0x303>
  104d2b:	c7 44 24 0c 04 70 10 	movl   $0x107004,0xc(%esp)
  104d32:	00 
  104d33:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104d3a:	00 
  104d3b:	c7 44 24 04 0c 02 00 	movl   $0x20c,0x4(%esp)
  104d42:	00 
  104d43:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104d4a:	e8 98 bf ff ff       	call   100ce7 <__panic>
    assert(*ptep & PTE_U);
  104d4f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d52:	8b 00                	mov    (%eax),%eax
  104d54:	83 e0 04             	and    $0x4,%eax
  104d57:	85 c0                	test   %eax,%eax
  104d59:	75 24                	jne    104d7f <check_pgdir+0x333>
  104d5b:	c7 44 24 0c 34 70 10 	movl   $0x107034,0xc(%esp)
  104d62:	00 
  104d63:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104d6a:	00 
  104d6b:	c7 44 24 04 0d 02 00 	movl   $0x20d,0x4(%esp)
  104d72:	00 
  104d73:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104d7a:	e8 68 bf ff ff       	call   100ce7 <__panic>
    assert(*ptep & PTE_W);
  104d7f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104d82:	8b 00                	mov    (%eax),%eax
  104d84:	83 e0 02             	and    $0x2,%eax
  104d87:	85 c0                	test   %eax,%eax
  104d89:	75 24                	jne    104daf <check_pgdir+0x363>
  104d8b:	c7 44 24 0c 42 70 10 	movl   $0x107042,0xc(%esp)
  104d92:	00 
  104d93:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104d9a:	00 
  104d9b:	c7 44 24 04 0e 02 00 	movl   $0x20e,0x4(%esp)
  104da2:	00 
  104da3:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104daa:	e8 38 bf ff ff       	call   100ce7 <__panic>
    assert(boot_pgdir[0] & PTE_U);
  104daf:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104db4:	8b 00                	mov    (%eax),%eax
  104db6:	83 e0 04             	and    $0x4,%eax
  104db9:	85 c0                	test   %eax,%eax
  104dbb:	75 24                	jne    104de1 <check_pgdir+0x395>
  104dbd:	c7 44 24 0c 50 70 10 	movl   $0x107050,0xc(%esp)
  104dc4:	00 
  104dc5:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104dcc:	00 
  104dcd:	c7 44 24 04 0f 02 00 	movl   $0x20f,0x4(%esp)
  104dd4:	00 
  104dd5:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104ddc:	e8 06 bf ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 1);
  104de1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104de4:	89 04 24             	mov    %eax,(%esp)
  104de7:	e8 42 f0 ff ff       	call   103e2e <page_ref>
  104dec:	83 f8 01             	cmp    $0x1,%eax
  104def:	74 24                	je     104e15 <check_pgdir+0x3c9>
  104df1:	c7 44 24 0c 66 70 10 	movl   $0x107066,0xc(%esp)
  104df8:	00 
  104df9:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104e00:	00 
  104e01:	c7 44 24 04 10 02 00 	movl   $0x210,0x4(%esp)
  104e08:	00 
  104e09:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104e10:	e8 d2 be ff ff       	call   100ce7 <__panic>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
  104e15:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104e1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  104e21:	00 
  104e22:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  104e29:	00 
  104e2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  104e2d:	89 54 24 04          	mov    %edx,0x4(%esp)
  104e31:	89 04 24             	mov    %eax,(%esp)
  104e34:	e8 d8 fa ff ff       	call   104911 <page_insert>
  104e39:	85 c0                	test   %eax,%eax
  104e3b:	74 24                	je     104e61 <check_pgdir+0x415>
  104e3d:	c7 44 24 0c 78 70 10 	movl   $0x107078,0xc(%esp)
  104e44:	00 
  104e45:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104e4c:	00 
  104e4d:	c7 44 24 04 12 02 00 	movl   $0x212,0x4(%esp)
  104e54:	00 
  104e55:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104e5c:	e8 86 be ff ff       	call   100ce7 <__panic>
    assert(page_ref(p1) == 2);
  104e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104e64:	89 04 24             	mov    %eax,(%esp)
  104e67:	e8 c2 ef ff ff       	call   103e2e <page_ref>
  104e6c:	83 f8 02             	cmp    $0x2,%eax
  104e6f:	74 24                	je     104e95 <check_pgdir+0x449>
  104e71:	c7 44 24 0c a4 70 10 	movl   $0x1070a4,0xc(%esp)
  104e78:	00 
  104e79:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104e80:	00 
  104e81:	c7 44 24 04 13 02 00 	movl   $0x213,0x4(%esp)
  104e88:	00 
  104e89:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104e90:	e8 52 be ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 0);
  104e95:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104e98:	89 04 24             	mov    %eax,(%esp)
  104e9b:	e8 8e ef ff ff       	call   103e2e <page_ref>
  104ea0:	85 c0                	test   %eax,%eax
  104ea2:	74 24                	je     104ec8 <check_pgdir+0x47c>
  104ea4:	c7 44 24 0c b6 70 10 	movl   $0x1070b6,0xc(%esp)
  104eab:	00 
  104eac:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104eb3:	00 
  104eb4:	c7 44 24 04 14 02 00 	movl   $0x214,0x4(%esp)
  104ebb:	00 
  104ebc:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104ec3:	e8 1f be ff ff       	call   100ce7 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
  104ec8:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ecd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  104ed4:	00 
  104ed5:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  104edc:	00 
  104edd:	89 04 24             	mov    %eax,(%esp)
  104ee0:	e8 eb f7 ff ff       	call   1046d0 <get_pte>
  104ee5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  104ee8:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  104eec:	75 24                	jne    104f12 <check_pgdir+0x4c6>
  104eee:	c7 44 24 0c 04 70 10 	movl   $0x107004,0xc(%esp)
  104ef5:	00 
  104ef6:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104efd:	00 
  104efe:	c7 44 24 04 15 02 00 	movl   $0x215,0x4(%esp)
  104f05:	00 
  104f06:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104f0d:	e8 d5 bd ff ff       	call   100ce7 <__panic>
    assert(pte2page(*ptep) == p1);
  104f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f15:	8b 00                	mov    (%eax),%eax
  104f17:	89 04 24             	mov    %eax,(%esp)
  104f1a:	e8 b5 ee ff ff       	call   103dd4 <pte2page>
  104f1f:	39 45 f4             	cmp    %eax,-0xc(%ebp)
  104f22:	74 24                	je     104f48 <check_pgdir+0x4fc>
  104f24:	c7 44 24 0c 79 6f 10 	movl   $0x106f79,0xc(%esp)
  104f2b:	00 
  104f2c:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104f33:	00 
  104f34:	c7 44 24 04 16 02 00 	movl   $0x216,0x4(%esp)
  104f3b:	00 
  104f3c:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104f43:	e8 9f bd ff ff       	call   100ce7 <__panic>
    assert((*ptep & PTE_U) == 0);
  104f48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  104f4b:	8b 00                	mov    (%eax),%eax
  104f4d:	83 e0 04             	and    $0x4,%eax
  104f50:	85 c0                	test   %eax,%eax
  104f52:	74 24                	je     104f78 <check_pgdir+0x52c>
  104f54:	c7 44 24 0c c8 70 10 	movl   $0x1070c8,0xc(%esp)
  104f5b:	00 
  104f5c:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104f63:	00 
  104f64:	c7 44 24 04 17 02 00 	movl   $0x217,0x4(%esp)
  104f6b:	00 
  104f6c:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104f73:	e8 6f bd ff ff       	call   100ce7 <__panic>

    page_remove(boot_pgdir, 0x0);
  104f78:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104f7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  104f84:	00 
  104f85:	89 04 24             	mov    %eax,(%esp)
  104f88:	e8 3d f9 ff ff       	call   1048ca <page_remove>
    assert(page_ref(p1) == 1);
  104f8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  104f90:	89 04 24             	mov    %eax,(%esp)
  104f93:	e8 96 ee ff ff       	call   103e2e <page_ref>
  104f98:	83 f8 01             	cmp    $0x1,%eax
  104f9b:	74 24                	je     104fc1 <check_pgdir+0x575>
  104f9d:	c7 44 24 0c 8f 6f 10 	movl   $0x106f8f,0xc(%esp)
  104fa4:	00 
  104fa5:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104fac:	00 
  104fad:	c7 44 24 04 1a 02 00 	movl   $0x21a,0x4(%esp)
  104fb4:	00 
  104fb5:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104fbc:	e8 26 bd ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 0);
  104fc1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  104fc4:	89 04 24             	mov    %eax,(%esp)
  104fc7:	e8 62 ee ff ff       	call   103e2e <page_ref>
  104fcc:	85 c0                	test   %eax,%eax
  104fce:	74 24                	je     104ff4 <check_pgdir+0x5a8>
  104fd0:	c7 44 24 0c b6 70 10 	movl   $0x1070b6,0xc(%esp)
  104fd7:	00 
  104fd8:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  104fdf:	00 
  104fe0:	c7 44 24 04 1b 02 00 	movl   $0x21b,0x4(%esp)
  104fe7:	00 
  104fe8:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  104fef:	e8 f3 bc ff ff       	call   100ce7 <__panic>

    page_remove(boot_pgdir, PGSIZE);
  104ff4:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  104ff9:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
  105000:	00 
  105001:	89 04 24             	mov    %eax,(%esp)
  105004:	e8 c1 f8 ff ff       	call   1048ca <page_remove>
    assert(page_ref(p1) == 0);
  105009:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10500c:	89 04 24             	mov    %eax,(%esp)
  10500f:	e8 1a ee ff ff       	call   103e2e <page_ref>
  105014:	85 c0                	test   %eax,%eax
  105016:	74 24                	je     10503c <check_pgdir+0x5f0>
  105018:	c7 44 24 0c dd 70 10 	movl   $0x1070dd,0xc(%esp)
  10501f:	00 
  105020:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105027:	00 
  105028:	c7 44 24 04 1e 02 00 	movl   $0x21e,0x4(%esp)
  10502f:	00 
  105030:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105037:	e8 ab bc ff ff       	call   100ce7 <__panic>
    assert(page_ref(p2) == 0);
  10503c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10503f:	89 04 24             	mov    %eax,(%esp)
  105042:	e8 e7 ed ff ff       	call   103e2e <page_ref>
  105047:	85 c0                	test   %eax,%eax
  105049:	74 24                	je     10506f <check_pgdir+0x623>
  10504b:	c7 44 24 0c b6 70 10 	movl   $0x1070b6,0xc(%esp)
  105052:	00 
  105053:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  10505a:	00 
  10505b:	c7 44 24 04 1f 02 00 	movl   $0x21f,0x4(%esp)
  105062:	00 
  105063:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  10506a:	e8 78 bc ff ff       	call   100ce7 <__panic>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
  10506f:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105074:	8b 00                	mov    (%eax),%eax
  105076:	89 04 24             	mov    %eax,(%esp)
  105079:	e8 96 ed ff ff       	call   103e14 <pde2page>
  10507e:	89 04 24             	mov    %eax,(%esp)
  105081:	e8 a8 ed ff ff       	call   103e2e <page_ref>
  105086:	83 f8 01             	cmp    $0x1,%eax
  105089:	74 24                	je     1050af <check_pgdir+0x663>
  10508b:	c7 44 24 0c f0 70 10 	movl   $0x1070f0,0xc(%esp)
  105092:	00 
  105093:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  10509a:	00 
  10509b:	c7 44 24 04 21 02 00 	movl   $0x221,0x4(%esp)
  1050a2:	00 
  1050a3:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1050aa:	e8 38 bc ff ff       	call   100ce7 <__panic>
    free_page(pde2page(boot_pgdir[0]));
  1050af:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050b4:	8b 00                	mov    (%eax),%eax
  1050b6:	89 04 24             	mov    %eax,(%esp)
  1050b9:	e8 56 ed ff ff       	call   103e14 <pde2page>
  1050be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  1050c5:	00 
  1050c6:	89 04 24             	mov    %eax,(%esp)
  1050c9:	e8 aa ef ff ff       	call   104078 <free_pages>
    boot_pgdir[0] = 0;
  1050ce:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1050d3:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_pgdir() succeeded!\n");
  1050d9:	c7 04 24 17 71 10 00 	movl   $0x107117,(%esp)
  1050e0:	e8 71 b2 ff ff       	call   100356 <cprintf>
}
  1050e5:	90                   	nop
  1050e6:	89 ec                	mov    %ebp,%esp
  1050e8:	5d                   	pop    %ebp
  1050e9:	c3                   	ret    

001050ea <check_boot_pgdir>:

static void
check_boot_pgdir(void) {
  1050ea:	55                   	push   %ebp
  1050eb:	89 e5                	mov    %esp,%ebp
  1050ed:	83 ec 38             	sub    $0x38,%esp
    pte_t *ptep;
    int i;
    for (i = 0; i < npage; i += PGSIZE) {
  1050f0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  1050f7:	e9 ca 00 00 00       	jmp    1051c6 <check_boot_pgdir+0xdc>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
  1050fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  1050ff:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105105:	c1 e8 0c             	shr    $0xc,%eax
  105108:	89 45 e0             	mov    %eax,-0x20(%ebp)
  10510b:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  105110:	39 45 e0             	cmp    %eax,-0x20(%ebp)
  105113:	72 23                	jb     105138 <check_boot_pgdir+0x4e>
  105115:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105118:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10511c:	c7 44 24 08 5c 6d 10 	movl   $0x106d5c,0x8(%esp)
  105123:	00 
  105124:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  10512b:	00 
  10512c:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105133:	e8 af bb ff ff       	call   100ce7 <__panic>
  105138:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10513b:	2d 00 00 00 40       	sub    $0x40000000,%eax
  105140:	89 c2                	mov    %eax,%edx
  105142:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105147:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  10514e:	00 
  10514f:	89 54 24 04          	mov    %edx,0x4(%esp)
  105153:	89 04 24             	mov    %eax,(%esp)
  105156:	e8 75 f5 ff ff       	call   1046d0 <get_pte>
  10515b:	89 45 dc             	mov    %eax,-0x24(%ebp)
  10515e:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105162:	75 24                	jne    105188 <check_boot_pgdir+0x9e>
  105164:	c7 44 24 0c 34 71 10 	movl   $0x107134,0xc(%esp)
  10516b:	00 
  10516c:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105173:	00 
  105174:	c7 44 24 04 2d 02 00 	movl   $0x22d,0x4(%esp)
  10517b:	00 
  10517c:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105183:	e8 5f bb ff ff       	call   100ce7 <__panic>
        assert(PTE_ADDR(*ptep) == i);
  105188:	8b 45 dc             	mov    -0x24(%ebp),%eax
  10518b:	8b 00                	mov    (%eax),%eax
  10518d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  105192:	89 c2                	mov    %eax,%edx
  105194:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105197:	39 c2                	cmp    %eax,%edx
  105199:	74 24                	je     1051bf <check_boot_pgdir+0xd5>
  10519b:	c7 44 24 0c 71 71 10 	movl   $0x107171,0xc(%esp)
  1051a2:	00 
  1051a3:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  1051aa:	00 
  1051ab:	c7 44 24 04 2e 02 00 	movl   $0x22e,0x4(%esp)
  1051b2:	00 
  1051b3:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1051ba:	e8 28 bb ff ff       	call   100ce7 <__panic>
    for (i = 0; i < npage; i += PGSIZE) {
  1051bf:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
  1051c6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  1051c9:	a1 04 cf 11 00       	mov    0x11cf04,%eax
  1051ce:	39 c2                	cmp    %eax,%edx
  1051d0:	0f 82 26 ff ff ff    	jb     1050fc <check_boot_pgdir+0x12>
    }

    assert(PDE_ADDR(boot_pgdir[PDX(VPT)]) == PADDR(boot_pgdir));
  1051d6:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1051db:	05 ac 0f 00 00       	add    $0xfac,%eax
  1051e0:	8b 00                	mov    (%eax),%eax
  1051e2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  1051e7:	89 c2                	mov    %eax,%edx
  1051e9:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  1051ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1051f1:	81 7d f0 ff ff ff bf 	cmpl   $0xbfffffff,-0x10(%ebp)
  1051f8:	77 23                	ja     10521d <check_boot_pgdir+0x133>
  1051fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1051fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105201:	c7 44 24 08 00 6e 10 	movl   $0x106e00,0x8(%esp)
  105208:	00 
  105209:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
  105210:	00 
  105211:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105218:	e8 ca ba ff ff       	call   100ce7 <__panic>
  10521d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105220:	05 00 00 00 40       	add    $0x40000000,%eax
  105225:	39 d0                	cmp    %edx,%eax
  105227:	74 24                	je     10524d <check_boot_pgdir+0x163>
  105229:	c7 44 24 0c 88 71 10 	movl   $0x107188,0xc(%esp)
  105230:	00 
  105231:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105238:	00 
  105239:	c7 44 24 04 31 02 00 	movl   $0x231,0x4(%esp)
  105240:	00 
  105241:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105248:	e8 9a ba ff ff       	call   100ce7 <__panic>

    assert(boot_pgdir[0] == 0);
  10524d:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105252:	8b 00                	mov    (%eax),%eax
  105254:	85 c0                	test   %eax,%eax
  105256:	74 24                	je     10527c <check_boot_pgdir+0x192>
  105258:	c7 44 24 0c bc 71 10 	movl   $0x1071bc,0xc(%esp)
  10525f:	00 
  105260:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105267:	00 
  105268:	c7 44 24 04 33 02 00 	movl   $0x233,0x4(%esp)
  10526f:	00 
  105270:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105277:	e8 6b ba ff ff       	call   100ce7 <__panic>

    struct Page *p;
    p = alloc_page();
  10527c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  105283:	e8 b6 ed ff ff       	call   10403e <alloc_pages>
  105288:	89 45 ec             	mov    %eax,-0x14(%ebp)
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W) == 0);
  10528b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105290:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105297:	00 
  105298:	c7 44 24 08 00 01 00 	movl   $0x100,0x8(%esp)
  10529f:	00 
  1052a0:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1052a3:	89 54 24 04          	mov    %edx,0x4(%esp)
  1052a7:	89 04 24             	mov    %eax,(%esp)
  1052aa:	e8 62 f6 ff ff       	call   104911 <page_insert>
  1052af:	85 c0                	test   %eax,%eax
  1052b1:	74 24                	je     1052d7 <check_boot_pgdir+0x1ed>
  1052b3:	c7 44 24 0c d0 71 10 	movl   $0x1071d0,0xc(%esp)
  1052ba:	00 
  1052bb:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  1052c2:	00 
  1052c3:	c7 44 24 04 37 02 00 	movl   $0x237,0x4(%esp)
  1052ca:	00 
  1052cb:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1052d2:	e8 10 ba ff ff       	call   100ce7 <__panic>
    assert(page_ref(p) == 1);
  1052d7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1052da:	89 04 24             	mov    %eax,(%esp)
  1052dd:	e8 4c eb ff ff       	call   103e2e <page_ref>
  1052e2:	83 f8 01             	cmp    $0x1,%eax
  1052e5:	74 24                	je     10530b <check_boot_pgdir+0x221>
  1052e7:	c7 44 24 0c fe 71 10 	movl   $0x1071fe,0xc(%esp)
  1052ee:	00 
  1052ef:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  1052f6:	00 
  1052f7:	c7 44 24 04 38 02 00 	movl   $0x238,0x4(%esp)
  1052fe:	00 
  1052ff:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105306:	e8 dc b9 ff ff       	call   100ce7 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W) == 0);
  10530b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105310:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
  105317:	00 
  105318:	c7 44 24 08 00 11 00 	movl   $0x1100,0x8(%esp)
  10531f:	00 
  105320:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105323:	89 54 24 04          	mov    %edx,0x4(%esp)
  105327:	89 04 24             	mov    %eax,(%esp)
  10532a:	e8 e2 f5 ff ff       	call   104911 <page_insert>
  10532f:	85 c0                	test   %eax,%eax
  105331:	74 24                	je     105357 <check_boot_pgdir+0x26d>
  105333:	c7 44 24 0c 10 72 10 	movl   $0x107210,0xc(%esp)
  10533a:	00 
  10533b:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105342:	00 
  105343:	c7 44 24 04 39 02 00 	movl   $0x239,0x4(%esp)
  10534a:	00 
  10534b:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105352:	e8 90 b9 ff ff       	call   100ce7 <__panic>
    assert(page_ref(p) == 2);
  105357:	8b 45 ec             	mov    -0x14(%ebp),%eax
  10535a:	89 04 24             	mov    %eax,(%esp)
  10535d:	e8 cc ea ff ff       	call   103e2e <page_ref>
  105362:	83 f8 02             	cmp    $0x2,%eax
  105365:	74 24                	je     10538b <check_boot_pgdir+0x2a1>
  105367:	c7 44 24 0c 47 72 10 	movl   $0x107247,0xc(%esp)
  10536e:	00 
  10536f:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105376:	00 
  105377:	c7 44 24 04 3a 02 00 	movl   $0x23a,0x4(%esp)
  10537e:	00 
  10537f:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105386:	e8 5c b9 ff ff       	call   100ce7 <__panic>

    const char *str = "ucore: Hello world!!";
  10538b:	c7 45 e8 58 72 10 00 	movl   $0x107258,-0x18(%ebp)
    strcpy((void *)0x100, str);
  105392:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105395:	89 44 24 04          	mov    %eax,0x4(%esp)
  105399:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1053a0:	e8 fc 09 00 00       	call   105da1 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
  1053a5:	c7 44 24 04 00 11 00 	movl   $0x1100,0x4(%esp)
  1053ac:	00 
  1053ad:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1053b4:	e8 60 0a 00 00       	call   105e19 <strcmp>
  1053b9:	85 c0                	test   %eax,%eax
  1053bb:	74 24                	je     1053e1 <check_boot_pgdir+0x2f7>
  1053bd:	c7 44 24 0c 70 72 10 	movl   $0x107270,0xc(%esp)
  1053c4:	00 
  1053c5:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  1053cc:	00 
  1053cd:	c7 44 24 04 3e 02 00 	movl   $0x23e,0x4(%esp)
  1053d4:	00 
  1053d5:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  1053dc:	e8 06 b9 ff ff       	call   100ce7 <__panic>

    *(char *)(page2kva(p) + 0x100) = '\0';
  1053e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1053e4:	89 04 24             	mov    %eax,(%esp)
  1053e7:	e8 92 e9 ff ff       	call   103d7e <page2kva>
  1053ec:	05 00 01 00 00       	add    $0x100,%eax
  1053f1:	c6 00 00             	movb   $0x0,(%eax)
    assert(strlen((const char *)0x100) == 0);
  1053f4:	c7 04 24 00 01 00 00 	movl   $0x100,(%esp)
  1053fb:	e8 47 09 00 00       	call   105d47 <strlen>
  105400:	85 c0                	test   %eax,%eax
  105402:	74 24                	je     105428 <check_boot_pgdir+0x33e>
  105404:	c7 44 24 0c a8 72 10 	movl   $0x1072a8,0xc(%esp)
  10540b:	00 
  10540c:	c7 44 24 08 49 6e 10 	movl   $0x106e49,0x8(%esp)
  105413:	00 
  105414:	c7 44 24 04 41 02 00 	movl   $0x241,0x4(%esp)
  10541b:	00 
  10541c:	c7 04 24 24 6e 10 00 	movl   $0x106e24,(%esp)
  105423:	e8 bf b8 ff ff       	call   100ce7 <__panic>

    free_page(p);
  105428:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  10542f:	00 
  105430:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105433:	89 04 24             	mov    %eax,(%esp)
  105436:	e8 3d ec ff ff       	call   104078 <free_pages>
    free_page(pde2page(boot_pgdir[0]));
  10543b:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  105440:	8b 00                	mov    (%eax),%eax
  105442:	89 04 24             	mov    %eax,(%esp)
  105445:	e8 ca e9 ff ff       	call   103e14 <pde2page>
  10544a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  105451:	00 
  105452:	89 04 24             	mov    %eax,(%esp)
  105455:	e8 1e ec ff ff       	call   104078 <free_pages>
    boot_pgdir[0] = 0;
  10545a:	a1 e0 99 11 00       	mov    0x1199e0,%eax
  10545f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

    cprintf("check_boot_pgdir() succeeded!\n");
  105465:	c7 04 24 cc 72 10 00 	movl   $0x1072cc,(%esp)
  10546c:	e8 e5 ae ff ff       	call   100356 <cprintf>
}
  105471:	90                   	nop
  105472:	89 ec                	mov    %ebp,%esp
  105474:	5d                   	pop    %ebp
  105475:	c3                   	ret    

00105476 <perm2str>:

//perm2str - use string 'u,r,w,-' to present the permission
static const char *
perm2str(int perm) {
  105476:	55                   	push   %ebp
  105477:	89 e5                	mov    %esp,%ebp
    static char str[4];
    str[0] = (perm & PTE_U) ? 'u' : '-';
  105479:	8b 45 08             	mov    0x8(%ebp),%eax
  10547c:	83 e0 04             	and    $0x4,%eax
  10547f:	85 c0                	test   %eax,%eax
  105481:	74 04                	je     105487 <perm2str+0x11>
  105483:	b0 75                	mov    $0x75,%al
  105485:	eb 02                	jmp    105489 <perm2str+0x13>
  105487:	b0 2d                	mov    $0x2d,%al
  105489:	a2 88 cf 11 00       	mov    %al,0x11cf88
    str[1] = 'r';
  10548e:	c6 05 89 cf 11 00 72 	movb   $0x72,0x11cf89
    str[2] = (perm & PTE_W) ? 'w' : '-';
  105495:	8b 45 08             	mov    0x8(%ebp),%eax
  105498:	83 e0 02             	and    $0x2,%eax
  10549b:	85 c0                	test   %eax,%eax
  10549d:	74 04                	je     1054a3 <perm2str+0x2d>
  10549f:	b0 77                	mov    $0x77,%al
  1054a1:	eb 02                	jmp    1054a5 <perm2str+0x2f>
  1054a3:	b0 2d                	mov    $0x2d,%al
  1054a5:	a2 8a cf 11 00       	mov    %al,0x11cf8a
    str[3] = '\0';
  1054aa:	c6 05 8b cf 11 00 00 	movb   $0x0,0x11cf8b
    return str;
  1054b1:	b8 88 cf 11 00       	mov    $0x11cf88,%eax
}
  1054b6:	5d                   	pop    %ebp
  1054b7:	c3                   	ret    

001054b8 <get_pgtable_items>:
//  table:       the beginning addr of table
//  left_store:  the pointer of the high side of table's next range
//  right_store: the pointer of the low side of table's next range
// return value: 0 - not a invalid item range, perm - a valid item range with perm permission 
static int
get_pgtable_items(size_t left, size_t right, size_t start, uintptr_t *table, size_t *left_store, size_t *right_store) {
  1054b8:	55                   	push   %ebp
  1054b9:	89 e5                	mov    %esp,%ebp
  1054bb:	83 ec 10             	sub    $0x10,%esp
    if (start >= right) {
  1054be:	8b 45 10             	mov    0x10(%ebp),%eax
  1054c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054c4:	72 0d                	jb     1054d3 <get_pgtable_items+0x1b>
        return 0;
  1054c6:	b8 00 00 00 00       	mov    $0x0,%eax
  1054cb:	e9 98 00 00 00       	jmp    105568 <get_pgtable_items+0xb0>
    }
    while (start < right && !(table[start] & PTE_P)) {
        start ++;
  1054d0:	ff 45 10             	incl   0x10(%ebp)
    while (start < right && !(table[start] & PTE_P)) {
  1054d3:	8b 45 10             	mov    0x10(%ebp),%eax
  1054d6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054d9:	73 18                	jae    1054f3 <get_pgtable_items+0x3b>
  1054db:	8b 45 10             	mov    0x10(%ebp),%eax
  1054de:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  1054e5:	8b 45 14             	mov    0x14(%ebp),%eax
  1054e8:	01 d0                	add    %edx,%eax
  1054ea:	8b 00                	mov    (%eax),%eax
  1054ec:	83 e0 01             	and    $0x1,%eax
  1054ef:	85 c0                	test   %eax,%eax
  1054f1:	74 dd                	je     1054d0 <get_pgtable_items+0x18>
    }
    if (start < right) {
  1054f3:	8b 45 10             	mov    0x10(%ebp),%eax
  1054f6:	3b 45 0c             	cmp    0xc(%ebp),%eax
  1054f9:	73 68                	jae    105563 <get_pgtable_items+0xab>
        if (left_store != NULL) {
  1054fb:	83 7d 18 00          	cmpl   $0x0,0x18(%ebp)
  1054ff:	74 08                	je     105509 <get_pgtable_items+0x51>
            *left_store = start;
  105501:	8b 45 18             	mov    0x18(%ebp),%eax
  105504:	8b 55 10             	mov    0x10(%ebp),%edx
  105507:	89 10                	mov    %edx,(%eax)
        }
        int perm = (table[start ++] & PTE_USER);
  105509:	8b 45 10             	mov    0x10(%ebp),%eax
  10550c:	8d 50 01             	lea    0x1(%eax),%edx
  10550f:	89 55 10             	mov    %edx,0x10(%ebp)
  105512:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  105519:	8b 45 14             	mov    0x14(%ebp),%eax
  10551c:	01 d0                	add    %edx,%eax
  10551e:	8b 00                	mov    (%eax),%eax
  105520:	83 e0 07             	and    $0x7,%eax
  105523:	89 45 fc             	mov    %eax,-0x4(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  105526:	eb 03                	jmp    10552b <get_pgtable_items+0x73>
            start ++;
  105528:	ff 45 10             	incl   0x10(%ebp)
        while (start < right && (table[start] & PTE_USER) == perm) {
  10552b:	8b 45 10             	mov    0x10(%ebp),%eax
  10552e:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105531:	73 1d                	jae    105550 <get_pgtable_items+0x98>
  105533:	8b 45 10             	mov    0x10(%ebp),%eax
  105536:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  10553d:	8b 45 14             	mov    0x14(%ebp),%eax
  105540:	01 d0                	add    %edx,%eax
  105542:	8b 00                	mov    (%eax),%eax
  105544:	83 e0 07             	and    $0x7,%eax
  105547:	89 c2                	mov    %eax,%edx
  105549:	8b 45 fc             	mov    -0x4(%ebp),%eax
  10554c:	39 c2                	cmp    %eax,%edx
  10554e:	74 d8                	je     105528 <get_pgtable_items+0x70>
        }
        if (right_store != NULL) {
  105550:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  105554:	74 08                	je     10555e <get_pgtable_items+0xa6>
            *right_store = start;
  105556:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105559:	8b 55 10             	mov    0x10(%ebp),%edx
  10555c:	89 10                	mov    %edx,(%eax)
        }
        return perm;
  10555e:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105561:	eb 05                	jmp    105568 <get_pgtable_items+0xb0>
    }
    return 0;
  105563:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105568:	89 ec                	mov    %ebp,%esp
  10556a:	5d                   	pop    %ebp
  10556b:	c3                   	ret    

0010556c <print_pgdir>:

//print_pgdir - print the PDT&PT
void
print_pgdir(void) {
  10556c:	55                   	push   %ebp
  10556d:	89 e5                	mov    %esp,%ebp
  10556f:	57                   	push   %edi
  105570:	56                   	push   %esi
  105571:	53                   	push   %ebx
  105572:	83 ec 4c             	sub    $0x4c,%esp
    cprintf("-------------------- BEGIN --------------------\n");
  105575:	c7 04 24 ec 72 10 00 	movl   $0x1072ec,(%esp)
  10557c:	e8 d5 ad ff ff       	call   100356 <cprintf>
    size_t left, right = 0, perm;
  105581:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  105588:	e9 f2 00 00 00       	jmp    10567f <print_pgdir+0x113>
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  10558d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105590:	89 04 24             	mov    %eax,(%esp)
  105593:	e8 de fe ff ff       	call   105476 <perm2str>
                left * PTSIZE, right * PTSIZE, (right - left) * PTSIZE, perm2str(perm));
  105598:	8b 55 dc             	mov    -0x24(%ebp),%edx
  10559b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  10559e:	29 ca                	sub    %ecx,%edx
        cprintf("PDE(%03x) %08x-%08x %08x %s\n", right - left,
  1055a0:	89 d6                	mov    %edx,%esi
  1055a2:	c1 e6 16             	shl    $0x16,%esi
  1055a5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1055a8:	89 d3                	mov    %edx,%ebx
  1055aa:	c1 e3 16             	shl    $0x16,%ebx
  1055ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
  1055b0:	89 d1                	mov    %edx,%ecx
  1055b2:	c1 e1 16             	shl    $0x16,%ecx
  1055b5:	8b 55 dc             	mov    -0x24(%ebp),%edx
  1055b8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  1055bb:	29 fa                	sub    %edi,%edx
  1055bd:	89 44 24 14          	mov    %eax,0x14(%esp)
  1055c1:	89 74 24 10          	mov    %esi,0x10(%esp)
  1055c5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1055c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  1055cd:	89 54 24 04          	mov    %edx,0x4(%esp)
  1055d1:	c7 04 24 1d 73 10 00 	movl   $0x10731d,(%esp)
  1055d8:	e8 79 ad ff ff       	call   100356 <cprintf>
        size_t l, r = left * NPTEENTRY;
  1055dd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1055e0:	c1 e0 0a             	shl    $0xa,%eax
  1055e3:	89 45 d4             	mov    %eax,-0x2c(%ebp)
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  1055e6:	eb 50                	jmp    105638 <print_pgdir+0xcc>
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1055e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1055eb:	89 04 24             	mov    %eax,(%esp)
  1055ee:	e8 83 fe ff ff       	call   105476 <perm2str>
                    l * PGSIZE, r * PGSIZE, (r - l) * PGSIZE, perm2str(perm));
  1055f3:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1055f6:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  1055f9:	29 ca                	sub    %ecx,%edx
            cprintf("  |-- PTE(%05x) %08x-%08x %08x %s\n", r - l,
  1055fb:	89 d6                	mov    %edx,%esi
  1055fd:	c1 e6 0c             	shl    $0xc,%esi
  105600:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105603:	89 d3                	mov    %edx,%ebx
  105605:	c1 e3 0c             	shl    $0xc,%ebx
  105608:	8b 55 d8             	mov    -0x28(%ebp),%edx
  10560b:	89 d1                	mov    %edx,%ecx
  10560d:	c1 e1 0c             	shl    $0xc,%ecx
  105610:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  105613:	8b 7d d8             	mov    -0x28(%ebp),%edi
  105616:	29 fa                	sub    %edi,%edx
  105618:	89 44 24 14          	mov    %eax,0x14(%esp)
  10561c:	89 74 24 10          	mov    %esi,0x10(%esp)
  105620:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  105624:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  105628:	89 54 24 04          	mov    %edx,0x4(%esp)
  10562c:	c7 04 24 3c 73 10 00 	movl   $0x10733c,(%esp)
  105633:	e8 1e ad ff ff       	call   100356 <cprintf>
        while ((perm = get_pgtable_items(left * NPTEENTRY, right * NPTEENTRY, r, vpt, &l, &r)) != 0) {
  105638:	be 00 00 c0 fa       	mov    $0xfac00000,%esi
  10563d:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  105640:	8b 55 dc             	mov    -0x24(%ebp),%edx
  105643:	89 d3                	mov    %edx,%ebx
  105645:	c1 e3 0a             	shl    $0xa,%ebx
  105648:	8b 55 e0             	mov    -0x20(%ebp),%edx
  10564b:	89 d1                	mov    %edx,%ecx
  10564d:	c1 e1 0a             	shl    $0xa,%ecx
  105650:	8d 55 d4             	lea    -0x2c(%ebp),%edx
  105653:	89 54 24 14          	mov    %edx,0x14(%esp)
  105657:	8d 55 d8             	lea    -0x28(%ebp),%edx
  10565a:	89 54 24 10          	mov    %edx,0x10(%esp)
  10565e:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105662:	89 44 24 08          	mov    %eax,0x8(%esp)
  105666:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  10566a:	89 0c 24             	mov    %ecx,(%esp)
  10566d:	e8 46 fe ff ff       	call   1054b8 <get_pgtable_items>
  105672:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  105675:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105679:	0f 85 69 ff ff ff    	jne    1055e8 <print_pgdir+0x7c>
    while ((perm = get_pgtable_items(0, NPDEENTRY, right, vpd, &left, &right)) != 0) {
  10567f:	b9 00 b0 fe fa       	mov    $0xfafeb000,%ecx
  105684:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105687:	8d 55 dc             	lea    -0x24(%ebp),%edx
  10568a:	89 54 24 14          	mov    %edx,0x14(%esp)
  10568e:	8d 55 e0             	lea    -0x20(%ebp),%edx
  105691:	89 54 24 10          	mov    %edx,0x10(%esp)
  105695:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  105699:	89 44 24 08          	mov    %eax,0x8(%esp)
  10569d:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
  1056a4:	00 
  1056a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  1056ac:	e8 07 fe ff ff       	call   1054b8 <get_pgtable_items>
  1056b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1056b4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  1056b8:	0f 85 cf fe ff ff    	jne    10558d <print_pgdir+0x21>
        }
    }
    cprintf("--------------------- END ---------------------\n");
  1056be:	c7 04 24 60 73 10 00 	movl   $0x107360,(%esp)
  1056c5:	e8 8c ac ff ff       	call   100356 <cprintf>
}
  1056ca:	90                   	nop
  1056cb:	83 c4 4c             	add    $0x4c,%esp
  1056ce:	5b                   	pop    %ebx
  1056cf:	5e                   	pop    %esi
  1056d0:	5f                   	pop    %edi
  1056d1:	5d                   	pop    %ebp
  1056d2:	c3                   	ret    

001056d3 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  1056d3:	55                   	push   %ebp
  1056d4:	89 e5                	mov    %esp,%ebp
  1056d6:	83 ec 58             	sub    $0x58,%esp
  1056d9:	8b 45 10             	mov    0x10(%ebp),%eax
  1056dc:	89 45 d0             	mov    %eax,-0x30(%ebp)
  1056df:	8b 45 14             	mov    0x14(%ebp),%eax
  1056e2:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    unsigned long long result = num;
  1056e5:	8b 45 d0             	mov    -0x30(%ebp),%eax
  1056e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  1056eb:	89 45 e8             	mov    %eax,-0x18(%ebp)
  1056ee:	89 55 ec             	mov    %edx,-0x14(%ebp)
    unsigned mod = do_div(result, base);
  1056f1:	8b 45 18             	mov    0x18(%ebp),%eax
  1056f4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1056f7:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1056fa:	8b 55 ec             	mov    -0x14(%ebp),%edx
  1056fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105700:	89 55 f0             	mov    %edx,-0x10(%ebp)
  105703:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105706:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105709:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  10570d:	74 1c                	je     10572b <printnum+0x58>
  10570f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105712:	ba 00 00 00 00       	mov    $0x0,%edx
  105717:	f7 75 e4             	divl   -0x1c(%ebp)
  10571a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  10571d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105720:	ba 00 00 00 00       	mov    $0x0,%edx
  105725:	f7 75 e4             	divl   -0x1c(%ebp)
  105728:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10572b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10572e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105731:	f7 75 e4             	divl   -0x1c(%ebp)
  105734:	89 45 e0             	mov    %eax,-0x20(%ebp)
  105737:	89 55 dc             	mov    %edx,-0x24(%ebp)
  10573a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  10573d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105740:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105743:	89 55 ec             	mov    %edx,-0x14(%ebp)
  105746:	8b 45 dc             	mov    -0x24(%ebp),%eax
  105749:	89 45 d8             	mov    %eax,-0x28(%ebp)

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  10574c:	8b 45 18             	mov    0x18(%ebp),%eax
  10574f:	ba 00 00 00 00       	mov    $0x0,%edx
  105754:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  105757:	39 45 d0             	cmp    %eax,-0x30(%ebp)
  10575a:	19 d1                	sbb    %edx,%ecx
  10575c:	72 4c                	jb     1057aa <printnum+0xd7>
        printnum(putch, putdat, result, base, width - 1, padc);
  10575e:	8b 45 1c             	mov    0x1c(%ebp),%eax
  105761:	8d 50 ff             	lea    -0x1(%eax),%edx
  105764:	8b 45 20             	mov    0x20(%ebp),%eax
  105767:	89 44 24 18          	mov    %eax,0x18(%esp)
  10576b:	89 54 24 14          	mov    %edx,0x14(%esp)
  10576f:	8b 45 18             	mov    0x18(%ebp),%eax
  105772:	89 44 24 10          	mov    %eax,0x10(%esp)
  105776:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105779:	8b 55 ec             	mov    -0x14(%ebp),%edx
  10577c:	89 44 24 08          	mov    %eax,0x8(%esp)
  105780:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105784:	8b 45 0c             	mov    0xc(%ebp),%eax
  105787:	89 44 24 04          	mov    %eax,0x4(%esp)
  10578b:	8b 45 08             	mov    0x8(%ebp),%eax
  10578e:	89 04 24             	mov    %eax,(%esp)
  105791:	e8 3d ff ff ff       	call   1056d3 <printnum>
  105796:	eb 1b                	jmp    1057b3 <printnum+0xe0>
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
            putch(padc, putdat);
  105798:	8b 45 0c             	mov    0xc(%ebp),%eax
  10579b:	89 44 24 04          	mov    %eax,0x4(%esp)
  10579f:	8b 45 20             	mov    0x20(%ebp),%eax
  1057a2:	89 04 24             	mov    %eax,(%esp)
  1057a5:	8b 45 08             	mov    0x8(%ebp),%eax
  1057a8:	ff d0                	call   *%eax
        while (-- width > 0)
  1057aa:	ff 4d 1c             	decl   0x1c(%ebp)
  1057ad:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  1057b1:	7f e5                	jg     105798 <printnum+0xc5>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  1057b3:	8b 45 d8             	mov    -0x28(%ebp),%eax
  1057b6:	05 14 74 10 00       	add    $0x107414,%eax
  1057bb:	0f b6 00             	movzbl (%eax),%eax
  1057be:	0f be c0             	movsbl %al,%eax
  1057c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  1057c4:	89 54 24 04          	mov    %edx,0x4(%esp)
  1057c8:	89 04 24             	mov    %eax,(%esp)
  1057cb:	8b 45 08             	mov    0x8(%ebp),%eax
  1057ce:	ff d0                	call   *%eax
}
  1057d0:	90                   	nop
  1057d1:	89 ec                	mov    %ebp,%esp
  1057d3:	5d                   	pop    %ebp
  1057d4:	c3                   	ret    

001057d5 <getuint>:
 * getuint - get an unsigned int of various possible sizes from a varargs list
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static unsigned long long
getuint(va_list *ap, int lflag) {
  1057d5:	55                   	push   %ebp
  1057d6:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  1057d8:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  1057dc:	7e 14                	jle    1057f2 <getuint+0x1d>
        return va_arg(*ap, unsigned long long);
  1057de:	8b 45 08             	mov    0x8(%ebp),%eax
  1057e1:	8b 00                	mov    (%eax),%eax
  1057e3:	8d 48 08             	lea    0x8(%eax),%ecx
  1057e6:	8b 55 08             	mov    0x8(%ebp),%edx
  1057e9:	89 0a                	mov    %ecx,(%edx)
  1057eb:	8b 50 04             	mov    0x4(%eax),%edx
  1057ee:	8b 00                	mov    (%eax),%eax
  1057f0:	eb 30                	jmp    105822 <getuint+0x4d>
    }
    else if (lflag) {
  1057f2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  1057f6:	74 16                	je     10580e <getuint+0x39>
        return va_arg(*ap, unsigned long);
  1057f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1057fb:	8b 00                	mov    (%eax),%eax
  1057fd:	8d 48 04             	lea    0x4(%eax),%ecx
  105800:	8b 55 08             	mov    0x8(%ebp),%edx
  105803:	89 0a                	mov    %ecx,(%edx)
  105805:	8b 00                	mov    (%eax),%eax
  105807:	ba 00 00 00 00       	mov    $0x0,%edx
  10580c:	eb 14                	jmp    105822 <getuint+0x4d>
    }
    else {
        return va_arg(*ap, unsigned int);
  10580e:	8b 45 08             	mov    0x8(%ebp),%eax
  105811:	8b 00                	mov    (%eax),%eax
  105813:	8d 48 04             	lea    0x4(%eax),%ecx
  105816:	8b 55 08             	mov    0x8(%ebp),%edx
  105819:	89 0a                	mov    %ecx,(%edx)
  10581b:	8b 00                	mov    (%eax),%eax
  10581d:	ba 00 00 00 00       	mov    $0x0,%edx
    }
}
  105822:	5d                   	pop    %ebp
  105823:	c3                   	ret    

00105824 <getint>:
 * getint - same as getuint but signed, we can't use getuint because of sign extension
 * @ap:         a varargs list pointer
 * @lflag:      determines the size of the vararg that @ap points to
 * */
static long long
getint(va_list *ap, int lflag) {
  105824:	55                   	push   %ebp
  105825:	89 e5                	mov    %esp,%ebp
    if (lflag >= 2) {
  105827:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  10582b:	7e 14                	jle    105841 <getint+0x1d>
        return va_arg(*ap, long long);
  10582d:	8b 45 08             	mov    0x8(%ebp),%eax
  105830:	8b 00                	mov    (%eax),%eax
  105832:	8d 48 08             	lea    0x8(%eax),%ecx
  105835:	8b 55 08             	mov    0x8(%ebp),%edx
  105838:	89 0a                	mov    %ecx,(%edx)
  10583a:	8b 50 04             	mov    0x4(%eax),%edx
  10583d:	8b 00                	mov    (%eax),%eax
  10583f:	eb 28                	jmp    105869 <getint+0x45>
    }
    else if (lflag) {
  105841:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  105845:	74 12                	je     105859 <getint+0x35>
        return va_arg(*ap, long);
  105847:	8b 45 08             	mov    0x8(%ebp),%eax
  10584a:	8b 00                	mov    (%eax),%eax
  10584c:	8d 48 04             	lea    0x4(%eax),%ecx
  10584f:	8b 55 08             	mov    0x8(%ebp),%edx
  105852:	89 0a                	mov    %ecx,(%edx)
  105854:	8b 00                	mov    (%eax),%eax
  105856:	99                   	cltd   
  105857:	eb 10                	jmp    105869 <getint+0x45>
    }
    else {
        return va_arg(*ap, int);
  105859:	8b 45 08             	mov    0x8(%ebp),%eax
  10585c:	8b 00                	mov    (%eax),%eax
  10585e:	8d 48 04             	lea    0x4(%eax),%ecx
  105861:	8b 55 08             	mov    0x8(%ebp),%edx
  105864:	89 0a                	mov    %ecx,(%edx)
  105866:	8b 00                	mov    (%eax),%eax
  105868:	99                   	cltd   
    }
}
  105869:	5d                   	pop    %ebp
  10586a:	c3                   	ret    

0010586b <printfmt>:
 * @putch:      specified putch function, print a single character
 * @putdat:     used by @putch function
 * @fmt:        the format string to use
 * */
void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  10586b:	55                   	push   %ebp
  10586c:	89 e5                	mov    %esp,%ebp
  10586e:	83 ec 28             	sub    $0x28,%esp
    va_list ap;

    va_start(ap, fmt);
  105871:	8d 45 14             	lea    0x14(%ebp),%eax
  105874:	89 45 f4             	mov    %eax,-0xc(%ebp)
    vprintfmt(putch, putdat, fmt, ap);
  105877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  10587a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  10587e:	8b 45 10             	mov    0x10(%ebp),%eax
  105881:	89 44 24 08          	mov    %eax,0x8(%esp)
  105885:	8b 45 0c             	mov    0xc(%ebp),%eax
  105888:	89 44 24 04          	mov    %eax,0x4(%esp)
  10588c:	8b 45 08             	mov    0x8(%ebp),%eax
  10588f:	89 04 24             	mov    %eax,(%esp)
  105892:	e8 05 00 00 00       	call   10589c <vprintfmt>
    va_end(ap);
}
  105897:	90                   	nop
  105898:	89 ec                	mov    %ebp,%esp
  10589a:	5d                   	pop    %ebp
  10589b:	c3                   	ret    

0010589c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  10589c:	55                   	push   %ebp
  10589d:	89 e5                	mov    %esp,%ebp
  10589f:	56                   	push   %esi
  1058a0:	53                   	push   %ebx
  1058a1:	83 ec 40             	sub    $0x40,%esp
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1058a4:	eb 17                	jmp    1058bd <vprintfmt+0x21>
            if (ch == '\0') {
  1058a6:	85 db                	test   %ebx,%ebx
  1058a8:	0f 84 bf 03 00 00    	je     105c6d <vprintfmt+0x3d1>
                return;
            }
            putch(ch, putdat);
  1058ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  1058b1:	89 44 24 04          	mov    %eax,0x4(%esp)
  1058b5:	89 1c 24             	mov    %ebx,(%esp)
  1058b8:	8b 45 08             	mov    0x8(%ebp),%eax
  1058bb:	ff d0                	call   *%eax
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  1058bd:	8b 45 10             	mov    0x10(%ebp),%eax
  1058c0:	8d 50 01             	lea    0x1(%eax),%edx
  1058c3:	89 55 10             	mov    %edx,0x10(%ebp)
  1058c6:	0f b6 00             	movzbl (%eax),%eax
  1058c9:	0f b6 d8             	movzbl %al,%ebx
  1058cc:	83 fb 25             	cmp    $0x25,%ebx
  1058cf:	75 d5                	jne    1058a6 <vprintfmt+0xa>
        }

        // Process a %-escape sequence
        char padc = ' ';
  1058d1:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
        width = precision = -1;
  1058d5:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  1058dc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  1058df:	89 45 e8             	mov    %eax,-0x18(%ebp)
        lflag = altflag = 0;
  1058e2:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
  1058e9:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1058ec:	89 45 e0             	mov    %eax,-0x20(%ebp)

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  1058ef:	8b 45 10             	mov    0x10(%ebp),%eax
  1058f2:	8d 50 01             	lea    0x1(%eax),%edx
  1058f5:	89 55 10             	mov    %edx,0x10(%ebp)
  1058f8:	0f b6 00             	movzbl (%eax),%eax
  1058fb:	0f b6 d8             	movzbl %al,%ebx
  1058fe:	8d 43 dd             	lea    -0x23(%ebx),%eax
  105901:	83 f8 55             	cmp    $0x55,%eax
  105904:	0f 87 37 03 00 00    	ja     105c41 <vprintfmt+0x3a5>
  10590a:	8b 04 85 38 74 10 00 	mov    0x107438(,%eax,4),%eax
  105911:	ff e0                	jmp    *%eax

        // flag to pad on the right
        case '-':
            padc = '-';
  105913:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
            goto reswitch;
  105917:	eb d6                	jmp    1058ef <vprintfmt+0x53>

        // flag to pad with 0's instead of spaces
        case '0':
            padc = '0';
  105919:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
            goto reswitch;
  10591d:	eb d0                	jmp    1058ef <vprintfmt+0x53>

        // width field
        case '1' ... '9':
            for (precision = 0; ; ++ fmt) {
  10591f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
                precision = precision * 10 + ch - '0';
  105926:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  105929:	89 d0                	mov    %edx,%eax
  10592b:	c1 e0 02             	shl    $0x2,%eax
  10592e:	01 d0                	add    %edx,%eax
  105930:	01 c0                	add    %eax,%eax
  105932:	01 d8                	add    %ebx,%eax
  105934:	83 e8 30             	sub    $0x30,%eax
  105937:	89 45 e4             	mov    %eax,-0x1c(%ebp)
                ch = *fmt;
  10593a:	8b 45 10             	mov    0x10(%ebp),%eax
  10593d:	0f b6 00             	movzbl (%eax),%eax
  105940:	0f be d8             	movsbl %al,%ebx
                if (ch < '0' || ch > '9') {
  105943:	83 fb 2f             	cmp    $0x2f,%ebx
  105946:	7e 38                	jle    105980 <vprintfmt+0xe4>
  105948:	83 fb 39             	cmp    $0x39,%ebx
  10594b:	7f 33                	jg     105980 <vprintfmt+0xe4>
            for (precision = 0; ; ++ fmt) {
  10594d:	ff 45 10             	incl   0x10(%ebp)
                precision = precision * 10 + ch - '0';
  105950:	eb d4                	jmp    105926 <vprintfmt+0x8a>
                }
            }
            goto process_precision;

        case '*':
            precision = va_arg(ap, int);
  105952:	8b 45 14             	mov    0x14(%ebp),%eax
  105955:	8d 50 04             	lea    0x4(%eax),%edx
  105958:	89 55 14             	mov    %edx,0x14(%ebp)
  10595b:	8b 00                	mov    (%eax),%eax
  10595d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            goto process_precision;
  105960:	eb 1f                	jmp    105981 <vprintfmt+0xe5>

        case '.':
            if (width < 0)
  105962:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105966:	79 87                	jns    1058ef <vprintfmt+0x53>
                width = 0;
  105968:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
            goto reswitch;
  10596f:	e9 7b ff ff ff       	jmp    1058ef <vprintfmt+0x53>

        case '#':
            altflag = 1;
  105974:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
            goto reswitch;
  10597b:	e9 6f ff ff ff       	jmp    1058ef <vprintfmt+0x53>
            goto process_precision;
  105980:	90                   	nop

        process_precision:
            if (width < 0)
  105981:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105985:	0f 89 64 ff ff ff    	jns    1058ef <vprintfmt+0x53>
                width = precision, precision = -1;
  10598b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  10598e:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105991:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
            goto reswitch;
  105998:	e9 52 ff ff ff       	jmp    1058ef <vprintfmt+0x53>

        // long flag (doubled for long long)
        case 'l':
            lflag ++;
  10599d:	ff 45 e0             	incl   -0x20(%ebp)
            goto reswitch;
  1059a0:	e9 4a ff ff ff       	jmp    1058ef <vprintfmt+0x53>

        // character
        case 'c':
            putch(va_arg(ap, int), putdat);
  1059a5:	8b 45 14             	mov    0x14(%ebp),%eax
  1059a8:	8d 50 04             	lea    0x4(%eax),%edx
  1059ab:	89 55 14             	mov    %edx,0x14(%ebp)
  1059ae:	8b 00                	mov    (%eax),%eax
  1059b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  1059b3:	89 54 24 04          	mov    %edx,0x4(%esp)
  1059b7:	89 04 24             	mov    %eax,(%esp)
  1059ba:	8b 45 08             	mov    0x8(%ebp),%eax
  1059bd:	ff d0                	call   *%eax
            break;
  1059bf:	e9 a4 02 00 00       	jmp    105c68 <vprintfmt+0x3cc>

        // error message
        case 'e':
            err = va_arg(ap, int);
  1059c4:	8b 45 14             	mov    0x14(%ebp),%eax
  1059c7:	8d 50 04             	lea    0x4(%eax),%edx
  1059ca:	89 55 14             	mov    %edx,0x14(%ebp)
  1059cd:	8b 18                	mov    (%eax),%ebx
            if (err < 0) {
  1059cf:	85 db                	test   %ebx,%ebx
  1059d1:	79 02                	jns    1059d5 <vprintfmt+0x139>
                err = -err;
  1059d3:	f7 db                	neg    %ebx
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  1059d5:	83 fb 06             	cmp    $0x6,%ebx
  1059d8:	7f 0b                	jg     1059e5 <vprintfmt+0x149>
  1059da:	8b 34 9d f8 73 10 00 	mov    0x1073f8(,%ebx,4),%esi
  1059e1:	85 f6                	test   %esi,%esi
  1059e3:	75 23                	jne    105a08 <vprintfmt+0x16c>
                printfmt(putch, putdat, "error %d", err);
  1059e5:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  1059e9:	c7 44 24 08 25 74 10 	movl   $0x107425,0x8(%esp)
  1059f0:	00 
  1059f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1059f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  1059f8:	8b 45 08             	mov    0x8(%ebp),%eax
  1059fb:	89 04 24             	mov    %eax,(%esp)
  1059fe:	e8 68 fe ff ff       	call   10586b <printfmt>
            }
            else {
                printfmt(putch, putdat, "%s", p);
            }
            break;
  105a03:	e9 60 02 00 00       	jmp    105c68 <vprintfmt+0x3cc>
                printfmt(putch, putdat, "%s", p);
  105a08:	89 74 24 0c          	mov    %esi,0xc(%esp)
  105a0c:	c7 44 24 08 2e 74 10 	movl   $0x10742e,0x8(%esp)
  105a13:	00 
  105a14:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  105a1e:	89 04 24             	mov    %eax,(%esp)
  105a21:	e8 45 fe ff ff       	call   10586b <printfmt>
            break;
  105a26:	e9 3d 02 00 00       	jmp    105c68 <vprintfmt+0x3cc>

        // string
        case 's':
            if ((p = va_arg(ap, char *)) == NULL) {
  105a2b:	8b 45 14             	mov    0x14(%ebp),%eax
  105a2e:	8d 50 04             	lea    0x4(%eax),%edx
  105a31:	89 55 14             	mov    %edx,0x14(%ebp)
  105a34:	8b 30                	mov    (%eax),%esi
  105a36:	85 f6                	test   %esi,%esi
  105a38:	75 05                	jne    105a3f <vprintfmt+0x1a3>
                p = "(null)";
  105a3a:	be 31 74 10 00       	mov    $0x107431,%esi
            }
            if (width > 0 && padc != '-') {
  105a3f:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a43:	7e 76                	jle    105abb <vprintfmt+0x21f>
  105a45:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  105a49:	74 70                	je     105abb <vprintfmt+0x21f>
                for (width -= strnlen(p, precision); width > 0; width --) {
  105a4b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  105a4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a52:	89 34 24             	mov    %esi,(%esp)
  105a55:	e8 16 03 00 00       	call   105d70 <strnlen>
  105a5a:	89 c2                	mov    %eax,%edx
  105a5c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  105a5f:	29 d0                	sub    %edx,%eax
  105a61:	89 45 e8             	mov    %eax,-0x18(%ebp)
  105a64:	eb 16                	jmp    105a7c <vprintfmt+0x1e0>
                    putch(padc, putdat);
  105a66:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  105a6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  105a6d:	89 54 24 04          	mov    %edx,0x4(%esp)
  105a71:	89 04 24             	mov    %eax,(%esp)
  105a74:	8b 45 08             	mov    0x8(%ebp),%eax
  105a77:	ff d0                	call   *%eax
                for (width -= strnlen(p, precision); width > 0; width --) {
  105a79:	ff 4d e8             	decl   -0x18(%ebp)
  105a7c:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105a80:	7f e4                	jg     105a66 <vprintfmt+0x1ca>
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105a82:	eb 37                	jmp    105abb <vprintfmt+0x21f>
                if (altflag && (ch < ' ' || ch > '~')) {
  105a84:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  105a88:	74 1f                	je     105aa9 <vprintfmt+0x20d>
  105a8a:	83 fb 1f             	cmp    $0x1f,%ebx
  105a8d:	7e 05                	jle    105a94 <vprintfmt+0x1f8>
  105a8f:	83 fb 7e             	cmp    $0x7e,%ebx
  105a92:	7e 15                	jle    105aa9 <vprintfmt+0x20d>
                    putch('?', putdat);
  105a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  105a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  105a9b:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  105aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  105aa5:	ff d0                	call   *%eax
  105aa7:	eb 0f                	jmp    105ab8 <vprintfmt+0x21c>
                }
                else {
                    putch(ch, putdat);
  105aa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  105aac:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ab0:	89 1c 24             	mov    %ebx,(%esp)
  105ab3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ab6:	ff d0                	call   *%eax
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  105ab8:	ff 4d e8             	decl   -0x18(%ebp)
  105abb:	89 f0                	mov    %esi,%eax
  105abd:	8d 70 01             	lea    0x1(%eax),%esi
  105ac0:	0f b6 00             	movzbl (%eax),%eax
  105ac3:	0f be d8             	movsbl %al,%ebx
  105ac6:	85 db                	test   %ebx,%ebx
  105ac8:	74 27                	je     105af1 <vprintfmt+0x255>
  105aca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105ace:	78 b4                	js     105a84 <vprintfmt+0x1e8>
  105ad0:	ff 4d e4             	decl   -0x1c(%ebp)
  105ad3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  105ad7:	79 ab                	jns    105a84 <vprintfmt+0x1e8>
                }
            }
            for (; width > 0; width --) {
  105ad9:	eb 16                	jmp    105af1 <vprintfmt+0x255>
                putch(' ', putdat);
  105adb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ade:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ae2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  105ae9:	8b 45 08             	mov    0x8(%ebp),%eax
  105aec:	ff d0                	call   *%eax
            for (; width > 0; width --) {
  105aee:	ff 4d e8             	decl   -0x18(%ebp)
  105af1:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
  105af5:	7f e4                	jg     105adb <vprintfmt+0x23f>
            }
            break;
  105af7:	e9 6c 01 00 00       	jmp    105c68 <vprintfmt+0x3cc>

        // (signed) decimal
        case 'd':
            num = getint(&ap, lflag);
  105afc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105aff:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b03:	8d 45 14             	lea    0x14(%ebp),%eax
  105b06:	89 04 24             	mov    %eax,(%esp)
  105b09:	e8 16 fd ff ff       	call   105824 <getint>
  105b0e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b11:	89 55 f4             	mov    %edx,-0xc(%ebp)
            if ((long long)num < 0) {
  105b14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b1a:	85 d2                	test   %edx,%edx
  105b1c:	79 26                	jns    105b44 <vprintfmt+0x2a8>
                putch('-', putdat);
  105b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b25:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  105b2c:	8b 45 08             	mov    0x8(%ebp),%eax
  105b2f:	ff d0                	call   *%eax
                num = -(long long)num;
  105b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105b34:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105b37:	f7 d8                	neg    %eax
  105b39:	83 d2 00             	adc    $0x0,%edx
  105b3c:	f7 da                	neg    %edx
  105b3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b41:	89 55 f4             	mov    %edx,-0xc(%ebp)
            }
            base = 10;
  105b44:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105b4b:	e9 a8 00 00 00       	jmp    105bf8 <vprintfmt+0x35c>

        // unsigned decimal
        case 'u':
            num = getuint(&ap, lflag);
  105b50:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b53:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b57:	8d 45 14             	lea    0x14(%ebp),%eax
  105b5a:	89 04 24             	mov    %eax,(%esp)
  105b5d:	e8 73 fc ff ff       	call   1057d5 <getuint>
  105b62:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b65:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 10;
  105b68:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
            goto number;
  105b6f:	e9 84 00 00 00       	jmp    105bf8 <vprintfmt+0x35c>

        // (unsigned) octal
        case 'o':
            num = getuint(&ap, lflag);
  105b74:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b7b:	8d 45 14             	lea    0x14(%ebp),%eax
  105b7e:	89 04 24             	mov    %eax,(%esp)
  105b81:	e8 4f fc ff ff       	call   1057d5 <getuint>
  105b86:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105b89:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 8;
  105b8c:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
            goto number;
  105b93:	eb 63                	jmp    105bf8 <vprintfmt+0x35c>

        // pointer
        case 'p':
            putch('0', putdat);
  105b95:	8b 45 0c             	mov    0xc(%ebp),%eax
  105b98:	89 44 24 04          	mov    %eax,0x4(%esp)
  105b9c:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  105ba3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ba6:	ff d0                	call   *%eax
            putch('x', putdat);
  105ba8:	8b 45 0c             	mov    0xc(%ebp),%eax
  105bab:	89 44 24 04          	mov    %eax,0x4(%esp)
  105baf:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  105bb6:	8b 45 08             	mov    0x8(%ebp),%eax
  105bb9:	ff d0                	call   *%eax
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  105bbb:	8b 45 14             	mov    0x14(%ebp),%eax
  105bbe:	8d 50 04             	lea    0x4(%eax),%edx
  105bc1:	89 55 14             	mov    %edx,0x14(%ebp)
  105bc4:	8b 00                	mov    (%eax),%eax
  105bc6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bc9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
            base = 16;
  105bd0:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
            goto number;
  105bd7:	eb 1f                	jmp    105bf8 <vprintfmt+0x35c>

        // (unsigned) hexadecimal
        case 'x':
            num = getuint(&ap, lflag);
  105bd9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  105bdc:	89 44 24 04          	mov    %eax,0x4(%esp)
  105be0:	8d 45 14             	lea    0x14(%ebp),%eax
  105be3:	89 04 24             	mov    %eax,(%esp)
  105be6:	e8 ea fb ff ff       	call   1057d5 <getuint>
  105beb:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105bee:	89 55 f4             	mov    %edx,-0xc(%ebp)
            base = 16;
  105bf1:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
        number:
            printnum(putch, putdat, num, base, width, padc);
  105bf8:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  105bfc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105bff:	89 54 24 18          	mov    %edx,0x18(%esp)
  105c03:	8b 55 e8             	mov    -0x18(%ebp),%edx
  105c06:	89 54 24 14          	mov    %edx,0x14(%esp)
  105c0a:	89 44 24 10          	mov    %eax,0x10(%esp)
  105c0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105c11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105c14:	89 44 24 08          	mov    %eax,0x8(%esp)
  105c18:	89 54 24 0c          	mov    %edx,0xc(%esp)
  105c1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c23:	8b 45 08             	mov    0x8(%ebp),%eax
  105c26:	89 04 24             	mov    %eax,(%esp)
  105c29:	e8 a5 fa ff ff       	call   1056d3 <printnum>
            break;
  105c2e:	eb 38                	jmp    105c68 <vprintfmt+0x3cc>

        // escaped '%' character
        case '%':
            putch(ch, putdat);
  105c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c33:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c37:	89 1c 24             	mov    %ebx,(%esp)
  105c3a:	8b 45 08             	mov    0x8(%ebp),%eax
  105c3d:	ff d0                	call   *%eax
            break;
  105c3f:	eb 27                	jmp    105c68 <vprintfmt+0x3cc>

        // unrecognized escape sequence - just print it literally
        default:
            putch('%', putdat);
  105c41:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c44:	89 44 24 04          	mov    %eax,0x4(%esp)
  105c48:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  105c4f:	8b 45 08             	mov    0x8(%ebp),%eax
  105c52:	ff d0                	call   *%eax
            for (fmt --; fmt[-1] != '%'; fmt --)
  105c54:	ff 4d 10             	decl   0x10(%ebp)
  105c57:	eb 03                	jmp    105c5c <vprintfmt+0x3c0>
  105c59:	ff 4d 10             	decl   0x10(%ebp)
  105c5c:	8b 45 10             	mov    0x10(%ebp),%eax
  105c5f:	48                   	dec    %eax
  105c60:	0f b6 00             	movzbl (%eax),%eax
  105c63:	3c 25                	cmp    $0x25,%al
  105c65:	75 f2                	jne    105c59 <vprintfmt+0x3bd>
                /* do nothing */;
            break;
  105c67:	90                   	nop
    while (1) {
  105c68:	e9 37 fc ff ff       	jmp    1058a4 <vprintfmt+0x8>
                return;
  105c6d:	90                   	nop
        }
    }
}
  105c6e:	83 c4 40             	add    $0x40,%esp
  105c71:	5b                   	pop    %ebx
  105c72:	5e                   	pop    %esi
  105c73:	5d                   	pop    %ebp
  105c74:	c3                   	ret    

00105c75 <sprintputch>:
 * sprintputch - 'print' a single character in a buffer
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
  105c75:	55                   	push   %ebp
  105c76:	89 e5                	mov    %esp,%ebp
    b->cnt ++;
  105c78:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c7b:	8b 40 08             	mov    0x8(%eax),%eax
  105c7e:	8d 50 01             	lea    0x1(%eax),%edx
  105c81:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c84:	89 50 08             	mov    %edx,0x8(%eax)
    if (b->buf < b->ebuf) {
  105c87:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c8a:	8b 10                	mov    (%eax),%edx
  105c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c8f:	8b 40 04             	mov    0x4(%eax),%eax
  105c92:	39 c2                	cmp    %eax,%edx
  105c94:	73 12                	jae    105ca8 <sprintputch+0x33>
        *b->buf ++ = ch;
  105c96:	8b 45 0c             	mov    0xc(%ebp),%eax
  105c99:	8b 00                	mov    (%eax),%eax
  105c9b:	8d 48 01             	lea    0x1(%eax),%ecx
  105c9e:	8b 55 0c             	mov    0xc(%ebp),%edx
  105ca1:	89 0a                	mov    %ecx,(%edx)
  105ca3:	8b 55 08             	mov    0x8(%ebp),%edx
  105ca6:	88 10                	mov    %dl,(%eax)
    }
}
  105ca8:	90                   	nop
  105ca9:	5d                   	pop    %ebp
  105caa:	c3                   	ret    

00105cab <snprintf>:
 * @str:        the buffer to place the result into
 * @size:       the size of buffer, including the trailing null space
 * @fmt:        the format string to use
 * */
int
snprintf(char *str, size_t size, const char *fmt, ...) {
  105cab:	55                   	push   %ebp
  105cac:	89 e5                	mov    %esp,%ebp
  105cae:	83 ec 28             	sub    $0x28,%esp
    va_list ap;
    int cnt;
    va_start(ap, fmt);
  105cb1:	8d 45 14             	lea    0x14(%ebp),%eax
  105cb4:	89 45 f0             	mov    %eax,-0x10(%ebp)
    cnt = vsnprintf(str, size, fmt, ap);
  105cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105cba:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105cbe:	8b 45 10             	mov    0x10(%ebp),%eax
  105cc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  105cc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  105ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  105ccf:	89 04 24             	mov    %eax,(%esp)
  105cd2:	e8 0a 00 00 00       	call   105ce1 <vsnprintf>
  105cd7:	89 45 f4             	mov    %eax,-0xc(%ebp)
    va_end(ap);
    return cnt;
  105cda:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105cdd:	89 ec                	mov    %ebp,%esp
  105cdf:	5d                   	pop    %ebp
  105ce0:	c3                   	ret    

00105ce1 <vsnprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  105ce1:	55                   	push   %ebp
  105ce2:	89 e5                	mov    %esp,%ebp
  105ce4:	83 ec 28             	sub    $0x28,%esp
    struct sprintbuf b = {str, str + size - 1, 0};
  105ce7:	8b 45 08             	mov    0x8(%ebp),%eax
  105cea:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105ced:	8b 45 0c             	mov    0xc(%ebp),%eax
  105cf0:	8d 50 ff             	lea    -0x1(%eax),%edx
  105cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  105cf6:	01 d0                	add    %edx,%eax
  105cf8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  105cfb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if (str == NULL || b.buf > b.ebuf) {
  105d02:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  105d06:	74 0a                	je     105d12 <vsnprintf+0x31>
  105d08:	8b 55 ec             	mov    -0x14(%ebp),%edx
  105d0b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105d0e:	39 c2                	cmp    %eax,%edx
  105d10:	76 07                	jbe    105d19 <vsnprintf+0x38>
        return -E_INVAL;
  105d12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  105d17:	eb 2a                	jmp    105d43 <vsnprintf+0x62>
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  105d19:	8b 45 14             	mov    0x14(%ebp),%eax
  105d1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  105d20:	8b 45 10             	mov    0x10(%ebp),%eax
  105d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  105d27:	8d 45 ec             	lea    -0x14(%ebp),%eax
  105d2a:	89 44 24 04          	mov    %eax,0x4(%esp)
  105d2e:	c7 04 24 75 5c 10 00 	movl   $0x105c75,(%esp)
  105d35:	e8 62 fb ff ff       	call   10589c <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  105d3a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  105d3d:	c6 00 00             	movb   $0x0,(%eax)
    return b.cnt;
  105d40:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  105d43:	89 ec                	mov    %ebp,%esp
  105d45:	5d                   	pop    %ebp
  105d46:	c3                   	ret    

00105d47 <strlen>:
 * @s:      the input string
 *
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
  105d47:	55                   	push   %ebp
  105d48:	89 e5                	mov    %esp,%ebp
  105d4a:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105d4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (*s ++ != '\0') {
  105d54:	eb 03                	jmp    105d59 <strlen+0x12>
        cnt ++;
  105d56:	ff 45 fc             	incl   -0x4(%ebp)
    while (*s ++ != '\0') {
  105d59:	8b 45 08             	mov    0x8(%ebp),%eax
  105d5c:	8d 50 01             	lea    0x1(%eax),%edx
  105d5f:	89 55 08             	mov    %edx,0x8(%ebp)
  105d62:	0f b6 00             	movzbl (%eax),%eax
  105d65:	84 c0                	test   %al,%al
  105d67:	75 ed                	jne    105d56 <strlen+0xf>
    }
    return cnt;
  105d69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105d6c:	89 ec                	mov    %ebp,%esp
  105d6e:	5d                   	pop    %ebp
  105d6f:	c3                   	ret    

00105d70 <strnlen>:
 * The return value is strlen(s), if that is less than @len, or
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
  105d70:	55                   	push   %ebp
  105d71:	89 e5                	mov    %esp,%ebp
  105d73:	83 ec 10             	sub    $0x10,%esp
    size_t cnt = 0;
  105d76:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105d7d:	eb 03                	jmp    105d82 <strnlen+0x12>
        cnt ++;
  105d7f:	ff 45 fc             	incl   -0x4(%ebp)
    while (cnt < len && *s ++ != '\0') {
  105d82:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105d85:	3b 45 0c             	cmp    0xc(%ebp),%eax
  105d88:	73 10                	jae    105d9a <strnlen+0x2a>
  105d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  105d8d:	8d 50 01             	lea    0x1(%eax),%edx
  105d90:	89 55 08             	mov    %edx,0x8(%ebp)
  105d93:	0f b6 00             	movzbl (%eax),%eax
  105d96:	84 c0                	test   %al,%al
  105d98:	75 e5                	jne    105d7f <strnlen+0xf>
    }
    return cnt;
  105d9a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  105d9d:	89 ec                	mov    %ebp,%esp
  105d9f:	5d                   	pop    %ebp
  105da0:	c3                   	ret    

00105da1 <strcpy>:
 * To avoid overflows, the size of array pointed by @dst should be long enough to
 * contain the same string as @src (including the terminating null character), and
 * should not overlap in memory with @src.
 * */
char *
strcpy(char *dst, const char *src) {
  105da1:	55                   	push   %ebp
  105da2:	89 e5                	mov    %esp,%ebp
  105da4:	57                   	push   %edi
  105da5:	56                   	push   %esi
  105da6:	83 ec 20             	sub    $0x20,%esp
  105da9:	8b 45 08             	mov    0x8(%ebp),%eax
  105dac:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105daf:	8b 45 0c             	mov    0xc(%ebp),%eax
  105db2:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_STRCPY
#define __HAVE_ARCH_STRCPY
static inline char *
__strcpy(char *dst, const char *src) {
    int d0, d1, d2;
    asm volatile (
  105db5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  105db8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  105dbb:	89 d1                	mov    %edx,%ecx
  105dbd:	89 c2                	mov    %eax,%edx
  105dbf:	89 ce                	mov    %ecx,%esi
  105dc1:	89 d7                	mov    %edx,%edi
  105dc3:	ac                   	lods   %ds:(%esi),%al
  105dc4:	aa                   	stos   %al,%es:(%edi)
  105dc5:	84 c0                	test   %al,%al
  105dc7:	75 fa                	jne    105dc3 <strcpy+0x22>
  105dc9:	89 fa                	mov    %edi,%edx
  105dcb:	89 f1                	mov    %esi,%ecx
  105dcd:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  105dd0:	89 55 e8             	mov    %edx,-0x18(%ebp)
  105dd3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        "stosb;"
        "testb %%al, %%al;"
        "jne 1b;"
        : "=&S" (d0), "=&D" (d1), "=&a" (d2)
        : "0" (src), "1" (dst) : "memory");
    return dst;
  105dd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    char *p = dst;
    while ((*p ++ = *src ++) != '\0')
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
  105dd9:	83 c4 20             	add    $0x20,%esp
  105ddc:	5e                   	pop    %esi
  105ddd:	5f                   	pop    %edi
  105dde:	5d                   	pop    %ebp
  105ddf:	c3                   	ret    

00105de0 <strncpy>:
 * @len:    maximum number of characters to be copied from @src
 *
 * The return value is @dst
 * */
char *
strncpy(char *dst, const char *src, size_t len) {
  105de0:	55                   	push   %ebp
  105de1:	89 e5                	mov    %esp,%ebp
  105de3:	83 ec 10             	sub    $0x10,%esp
    char *p = dst;
  105de6:	8b 45 08             	mov    0x8(%ebp),%eax
  105de9:	89 45 fc             	mov    %eax,-0x4(%ebp)
    while (len > 0) {
  105dec:	eb 1e                	jmp    105e0c <strncpy+0x2c>
        if ((*p = *src) != '\0') {
  105dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  105df1:	0f b6 10             	movzbl (%eax),%edx
  105df4:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105df7:	88 10                	mov    %dl,(%eax)
  105df9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  105dfc:	0f b6 00             	movzbl (%eax),%eax
  105dff:	84 c0                	test   %al,%al
  105e01:	74 03                	je     105e06 <strncpy+0x26>
            src ++;
  105e03:	ff 45 0c             	incl   0xc(%ebp)
        }
        p ++, len --;
  105e06:	ff 45 fc             	incl   -0x4(%ebp)
  105e09:	ff 4d 10             	decl   0x10(%ebp)
    while (len > 0) {
  105e0c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e10:	75 dc                	jne    105dee <strncpy+0xe>
    }
    return dst;
  105e12:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105e15:	89 ec                	mov    %ebp,%esp
  105e17:	5d                   	pop    %ebp
  105e18:	c3                   	ret    

00105e19 <strcmp>:
 * - A value greater than zero indicates that the first character that does
 *   not match has a greater value in @s1 than in @s2;
 * - And a value less than zero indicates the opposite.
 * */
int
strcmp(const char *s1, const char *s2) {
  105e19:	55                   	push   %ebp
  105e1a:	89 e5                	mov    %esp,%ebp
  105e1c:	57                   	push   %edi
  105e1d:	56                   	push   %esi
  105e1e:	83 ec 20             	sub    $0x20,%esp
  105e21:	8b 45 08             	mov    0x8(%ebp),%eax
  105e24:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105e27:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e2a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    asm volatile (
  105e2d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  105e30:	8b 45 f0             	mov    -0x10(%ebp),%eax
  105e33:	89 d1                	mov    %edx,%ecx
  105e35:	89 c2                	mov    %eax,%edx
  105e37:	89 ce                	mov    %ecx,%esi
  105e39:	89 d7                	mov    %edx,%edi
  105e3b:	ac                   	lods   %ds:(%esi),%al
  105e3c:	ae                   	scas   %es:(%edi),%al
  105e3d:	75 08                	jne    105e47 <strcmp+0x2e>
  105e3f:	84 c0                	test   %al,%al
  105e41:	75 f8                	jne    105e3b <strcmp+0x22>
  105e43:	31 c0                	xor    %eax,%eax
  105e45:	eb 04                	jmp    105e4b <strcmp+0x32>
  105e47:	19 c0                	sbb    %eax,%eax
  105e49:	0c 01                	or     $0x1,%al
  105e4b:	89 fa                	mov    %edi,%edx
  105e4d:	89 f1                	mov    %esi,%ecx
  105e4f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  105e52:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  105e55:	89 55 e4             	mov    %edx,-0x1c(%ebp)
    return ret;
  105e58:	8b 45 ec             	mov    -0x14(%ebp),%eax
    while (*s1 != '\0' && *s1 == *s2) {
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
#endif /* __HAVE_ARCH_STRCMP */
}
  105e5b:	83 c4 20             	add    $0x20,%esp
  105e5e:	5e                   	pop    %esi
  105e5f:	5f                   	pop    %edi
  105e60:	5d                   	pop    %ebp
  105e61:	c3                   	ret    

00105e62 <strncmp>:
 * they are equal to each other, it continues with the following pairs until
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
  105e62:	55                   	push   %ebp
  105e63:	89 e5                	mov    %esp,%ebp
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105e65:	eb 09                	jmp    105e70 <strncmp+0xe>
        n --, s1 ++, s2 ++;
  105e67:	ff 4d 10             	decl   0x10(%ebp)
  105e6a:	ff 45 08             	incl   0x8(%ebp)
  105e6d:	ff 45 0c             	incl   0xc(%ebp)
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
  105e70:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e74:	74 1a                	je     105e90 <strncmp+0x2e>
  105e76:	8b 45 08             	mov    0x8(%ebp),%eax
  105e79:	0f b6 00             	movzbl (%eax),%eax
  105e7c:	84 c0                	test   %al,%al
  105e7e:	74 10                	je     105e90 <strncmp+0x2e>
  105e80:	8b 45 08             	mov    0x8(%ebp),%eax
  105e83:	0f b6 10             	movzbl (%eax),%edx
  105e86:	8b 45 0c             	mov    0xc(%ebp),%eax
  105e89:	0f b6 00             	movzbl (%eax),%eax
  105e8c:	38 c2                	cmp    %al,%dl
  105e8e:	74 d7                	je     105e67 <strncmp+0x5>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
  105e90:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105e94:	74 18                	je     105eae <strncmp+0x4c>
  105e96:	8b 45 08             	mov    0x8(%ebp),%eax
  105e99:	0f b6 00             	movzbl (%eax),%eax
  105e9c:	0f b6 d0             	movzbl %al,%edx
  105e9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ea2:	0f b6 00             	movzbl (%eax),%eax
  105ea5:	0f b6 c8             	movzbl %al,%ecx
  105ea8:	89 d0                	mov    %edx,%eax
  105eaa:	29 c8                	sub    %ecx,%eax
  105eac:	eb 05                	jmp    105eb3 <strncmp+0x51>
  105eae:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105eb3:	5d                   	pop    %ebp
  105eb4:	c3                   	ret    

00105eb5 <strchr>:
 *
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
  105eb5:	55                   	push   %ebp
  105eb6:	89 e5                	mov    %esp,%ebp
  105eb8:	83 ec 04             	sub    $0x4,%esp
  105ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ebe:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ec1:	eb 13                	jmp    105ed6 <strchr+0x21>
        if (*s == c) {
  105ec3:	8b 45 08             	mov    0x8(%ebp),%eax
  105ec6:	0f b6 00             	movzbl (%eax),%eax
  105ec9:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105ecc:	75 05                	jne    105ed3 <strchr+0x1e>
            return (char *)s;
  105ece:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed1:	eb 12                	jmp    105ee5 <strchr+0x30>
        }
        s ++;
  105ed3:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105ed6:	8b 45 08             	mov    0x8(%ebp),%eax
  105ed9:	0f b6 00             	movzbl (%eax),%eax
  105edc:	84 c0                	test   %al,%al
  105ede:	75 e3                	jne    105ec3 <strchr+0xe>
    }
    return NULL;
  105ee0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  105ee5:	89 ec                	mov    %ebp,%esp
  105ee7:	5d                   	pop    %ebp
  105ee8:	c3                   	ret    

00105ee9 <strfind>:
 * The strfind() function is like strchr() except that if @c is
 * not found in @s, then it returns a pointer to the null byte at the
 * end of @s, rather than 'NULL'.
 * */
char *
strfind(const char *s, char c) {
  105ee9:	55                   	push   %ebp
  105eea:	89 e5                	mov    %esp,%ebp
  105eec:	83 ec 04             	sub    $0x4,%esp
  105eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  105ef2:	88 45 fc             	mov    %al,-0x4(%ebp)
    while (*s != '\0') {
  105ef5:	eb 0e                	jmp    105f05 <strfind+0x1c>
        if (*s == c) {
  105ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  105efa:	0f b6 00             	movzbl (%eax),%eax
  105efd:	38 45 fc             	cmp    %al,-0x4(%ebp)
  105f00:	74 0f                	je     105f11 <strfind+0x28>
            break;
        }
        s ++;
  105f02:	ff 45 08             	incl   0x8(%ebp)
    while (*s != '\0') {
  105f05:	8b 45 08             	mov    0x8(%ebp),%eax
  105f08:	0f b6 00             	movzbl (%eax),%eax
  105f0b:	84 c0                	test   %al,%al
  105f0d:	75 e8                	jne    105ef7 <strfind+0xe>
  105f0f:	eb 01                	jmp    105f12 <strfind+0x29>
            break;
  105f11:	90                   	nop
    }
    return (char *)s;
  105f12:	8b 45 08             	mov    0x8(%ebp),%eax
}
  105f15:	89 ec                	mov    %ebp,%esp
  105f17:	5d                   	pop    %ebp
  105f18:	c3                   	ret    

00105f19 <strtol>:
 * an optional "0x" or "0X" prefix.
 *
 * The strtol() function returns the converted integral number as a long int value.
 * */
long
strtol(const char *s, char **endptr, int base) {
  105f19:	55                   	push   %ebp
  105f1a:	89 e5                	mov    %esp,%ebp
  105f1c:	83 ec 10             	sub    $0x10,%esp
    int neg = 0;
  105f1f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
    long val = 0;
  105f26:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

    // gobble initial whitespace
    while (*s == ' ' || *s == '\t') {
  105f2d:	eb 03                	jmp    105f32 <strtol+0x19>
        s ++;
  105f2f:	ff 45 08             	incl   0x8(%ebp)
    while (*s == ' ' || *s == '\t') {
  105f32:	8b 45 08             	mov    0x8(%ebp),%eax
  105f35:	0f b6 00             	movzbl (%eax),%eax
  105f38:	3c 20                	cmp    $0x20,%al
  105f3a:	74 f3                	je     105f2f <strtol+0x16>
  105f3c:	8b 45 08             	mov    0x8(%ebp),%eax
  105f3f:	0f b6 00             	movzbl (%eax),%eax
  105f42:	3c 09                	cmp    $0x9,%al
  105f44:	74 e9                	je     105f2f <strtol+0x16>
    }

    // plus/minus sign
    if (*s == '+') {
  105f46:	8b 45 08             	mov    0x8(%ebp),%eax
  105f49:	0f b6 00             	movzbl (%eax),%eax
  105f4c:	3c 2b                	cmp    $0x2b,%al
  105f4e:	75 05                	jne    105f55 <strtol+0x3c>
        s ++;
  105f50:	ff 45 08             	incl   0x8(%ebp)
  105f53:	eb 14                	jmp    105f69 <strtol+0x50>
    }
    else if (*s == '-') {
  105f55:	8b 45 08             	mov    0x8(%ebp),%eax
  105f58:	0f b6 00             	movzbl (%eax),%eax
  105f5b:	3c 2d                	cmp    $0x2d,%al
  105f5d:	75 0a                	jne    105f69 <strtol+0x50>
        s ++, neg = 1;
  105f5f:	ff 45 08             	incl   0x8(%ebp)
  105f62:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)
    }

    // hex or octal base prefix
    if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x')) {
  105f69:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105f6d:	74 06                	je     105f75 <strtol+0x5c>
  105f6f:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  105f73:	75 22                	jne    105f97 <strtol+0x7e>
  105f75:	8b 45 08             	mov    0x8(%ebp),%eax
  105f78:	0f b6 00             	movzbl (%eax),%eax
  105f7b:	3c 30                	cmp    $0x30,%al
  105f7d:	75 18                	jne    105f97 <strtol+0x7e>
  105f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  105f82:	40                   	inc    %eax
  105f83:	0f b6 00             	movzbl (%eax),%eax
  105f86:	3c 78                	cmp    $0x78,%al
  105f88:	75 0d                	jne    105f97 <strtol+0x7e>
        s += 2, base = 16;
  105f8a:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  105f8e:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  105f95:	eb 29                	jmp    105fc0 <strtol+0xa7>
    }
    else if (base == 0 && s[0] == '0') {
  105f97:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105f9b:	75 16                	jne    105fb3 <strtol+0x9a>
  105f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  105fa0:	0f b6 00             	movzbl (%eax),%eax
  105fa3:	3c 30                	cmp    $0x30,%al
  105fa5:	75 0c                	jne    105fb3 <strtol+0x9a>
        s ++, base = 8;
  105fa7:	ff 45 08             	incl   0x8(%ebp)
  105faa:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  105fb1:	eb 0d                	jmp    105fc0 <strtol+0xa7>
    }
    else if (base == 0) {
  105fb3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  105fb7:	75 07                	jne    105fc0 <strtol+0xa7>
        base = 10;
  105fb9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

    // digits
    while (1) {
        int dig;

        if (*s >= '0' && *s <= '9') {
  105fc0:	8b 45 08             	mov    0x8(%ebp),%eax
  105fc3:	0f b6 00             	movzbl (%eax),%eax
  105fc6:	3c 2f                	cmp    $0x2f,%al
  105fc8:	7e 1b                	jle    105fe5 <strtol+0xcc>
  105fca:	8b 45 08             	mov    0x8(%ebp),%eax
  105fcd:	0f b6 00             	movzbl (%eax),%eax
  105fd0:	3c 39                	cmp    $0x39,%al
  105fd2:	7f 11                	jg     105fe5 <strtol+0xcc>
            dig = *s - '0';
  105fd4:	8b 45 08             	mov    0x8(%ebp),%eax
  105fd7:	0f b6 00             	movzbl (%eax),%eax
  105fda:	0f be c0             	movsbl %al,%eax
  105fdd:	83 e8 30             	sub    $0x30,%eax
  105fe0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  105fe3:	eb 48                	jmp    10602d <strtol+0x114>
        }
        else if (*s >= 'a' && *s <= 'z') {
  105fe5:	8b 45 08             	mov    0x8(%ebp),%eax
  105fe8:	0f b6 00             	movzbl (%eax),%eax
  105feb:	3c 60                	cmp    $0x60,%al
  105fed:	7e 1b                	jle    10600a <strtol+0xf1>
  105fef:	8b 45 08             	mov    0x8(%ebp),%eax
  105ff2:	0f b6 00             	movzbl (%eax),%eax
  105ff5:	3c 7a                	cmp    $0x7a,%al
  105ff7:	7f 11                	jg     10600a <strtol+0xf1>
            dig = *s - 'a' + 10;
  105ff9:	8b 45 08             	mov    0x8(%ebp),%eax
  105ffc:	0f b6 00             	movzbl (%eax),%eax
  105fff:	0f be c0             	movsbl %al,%eax
  106002:	83 e8 57             	sub    $0x57,%eax
  106005:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106008:	eb 23                	jmp    10602d <strtol+0x114>
        }
        else if (*s >= 'A' && *s <= 'Z') {
  10600a:	8b 45 08             	mov    0x8(%ebp),%eax
  10600d:	0f b6 00             	movzbl (%eax),%eax
  106010:	3c 40                	cmp    $0x40,%al
  106012:	7e 3b                	jle    10604f <strtol+0x136>
  106014:	8b 45 08             	mov    0x8(%ebp),%eax
  106017:	0f b6 00             	movzbl (%eax),%eax
  10601a:	3c 5a                	cmp    $0x5a,%al
  10601c:	7f 31                	jg     10604f <strtol+0x136>
            dig = *s - 'A' + 10;
  10601e:	8b 45 08             	mov    0x8(%ebp),%eax
  106021:	0f b6 00             	movzbl (%eax),%eax
  106024:	0f be c0             	movsbl %al,%eax
  106027:	83 e8 37             	sub    $0x37,%eax
  10602a:	89 45 f4             	mov    %eax,-0xc(%ebp)
        }
        else {
            break;
        }
        if (dig >= base) {
  10602d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106030:	3b 45 10             	cmp    0x10(%ebp),%eax
  106033:	7d 19                	jge    10604e <strtol+0x135>
            break;
        }
        s ++, val = (val * base) + dig;
  106035:	ff 45 08             	incl   0x8(%ebp)
  106038:	8b 45 f8             	mov    -0x8(%ebp),%eax
  10603b:	0f af 45 10          	imul   0x10(%ebp),%eax
  10603f:	89 c2                	mov    %eax,%edx
  106041:	8b 45 f4             	mov    -0xc(%ebp),%eax
  106044:	01 d0                	add    %edx,%eax
  106046:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (1) {
  106049:	e9 72 ff ff ff       	jmp    105fc0 <strtol+0xa7>
            break;
  10604e:	90                   	nop
        // we don't properly detect overflow!
    }

    if (endptr) {
  10604f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  106053:	74 08                	je     10605d <strtol+0x144>
        *endptr = (char *) s;
  106055:	8b 45 0c             	mov    0xc(%ebp),%eax
  106058:	8b 55 08             	mov    0x8(%ebp),%edx
  10605b:	89 10                	mov    %edx,(%eax)
    }
    return (neg ? -val : val);
  10605d:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  106061:	74 07                	je     10606a <strtol+0x151>
  106063:	8b 45 f8             	mov    -0x8(%ebp),%eax
  106066:	f7 d8                	neg    %eax
  106068:	eb 03                	jmp    10606d <strtol+0x154>
  10606a:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  10606d:	89 ec                	mov    %ebp,%esp
  10606f:	5d                   	pop    %ebp
  106070:	c3                   	ret    

00106071 <memset>:
 * @n:      number of bytes to be set to the value
 *
 * The memset() function returns @s.
 * */
void *
memset(void *s, char c, size_t n) {
  106071:	55                   	push   %ebp
  106072:	89 e5                	mov    %esp,%ebp
  106074:	83 ec 28             	sub    $0x28,%esp
  106077:	89 7d fc             	mov    %edi,-0x4(%ebp)
  10607a:	8b 45 0c             	mov    0xc(%ebp),%eax
  10607d:	88 45 d8             	mov    %al,-0x28(%ebp)
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
  106080:	0f be 55 d8          	movsbl -0x28(%ebp),%edx
  106084:	8b 45 08             	mov    0x8(%ebp),%eax
  106087:	89 45 f8             	mov    %eax,-0x8(%ebp)
  10608a:	88 55 f7             	mov    %dl,-0x9(%ebp)
  10608d:	8b 45 10             	mov    0x10(%ebp),%eax
  106090:	89 45 f0             	mov    %eax,-0x10(%ebp)
#ifndef __HAVE_ARCH_MEMSET
#define __HAVE_ARCH_MEMSET
static inline void *
__memset(void *s, char c, size_t n) {
    int d0, d1;
    asm volatile (
  106093:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  106096:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  10609a:	8b 55 f8             	mov    -0x8(%ebp),%edx
  10609d:	89 d7                	mov    %edx,%edi
  10609f:	f3 aa                	rep stos %al,%es:(%edi)
  1060a1:	89 fa                	mov    %edi,%edx
  1060a3:	89 4d ec             	mov    %ecx,-0x14(%ebp)
  1060a6:	89 55 e8             	mov    %edx,-0x18(%ebp)
        "rep; stosb;"
        : "=&c" (d0), "=&D" (d1)
        : "0" (n), "a" (c), "1" (s)
        : "memory");
    return s;
  1060a9:	8b 45 f8             	mov    -0x8(%ebp),%eax
    while (n -- > 0) {
        *p ++ = c;
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
  1060ac:	8b 7d fc             	mov    -0x4(%ebp),%edi
  1060af:	89 ec                	mov    %ebp,%esp
  1060b1:	5d                   	pop    %ebp
  1060b2:	c3                   	ret    

001060b3 <memmove>:
 * @n:      number of bytes to copy
 *
 * The memmove() function returns @dst.
 * */
void *
memmove(void *dst, const void *src, size_t n) {
  1060b3:	55                   	push   %ebp
  1060b4:	89 e5                	mov    %esp,%ebp
  1060b6:	57                   	push   %edi
  1060b7:	56                   	push   %esi
  1060b8:	53                   	push   %ebx
  1060b9:	83 ec 30             	sub    $0x30,%esp
  1060bc:	8b 45 08             	mov    0x8(%ebp),%eax
  1060bf:	89 45 f0             	mov    %eax,-0x10(%ebp)
  1060c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  1060c5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  1060c8:	8b 45 10             	mov    0x10(%ebp),%eax
  1060cb:	89 45 e8             	mov    %eax,-0x18(%ebp)

#ifndef __HAVE_ARCH_MEMMOVE
#define __HAVE_ARCH_MEMMOVE
static inline void *
__memmove(void *dst, const void *src, size_t n) {
    if (dst < src) {
  1060ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060d1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  1060d4:	73 42                	jae    106118 <memmove+0x65>
  1060d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  1060d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  1060dc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  1060df:	89 45 e0             	mov    %eax,-0x20(%ebp)
  1060e2:	8b 45 e8             	mov    -0x18(%ebp),%eax
  1060e5:	89 45 dc             	mov    %eax,-0x24(%ebp)
        "andl $3, %%ecx;"
        "jz 1f;"
        "rep; movsb;"
        "1:"
        : "=&c" (d0), "=&D" (d1), "=&S" (d2)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  1060e8:	8b 45 dc             	mov    -0x24(%ebp),%eax
  1060eb:	c1 e8 02             	shr    $0x2,%eax
  1060ee:	89 c1                	mov    %eax,%ecx
    asm volatile (
  1060f0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  1060f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  1060f6:	89 d7                	mov    %edx,%edi
  1060f8:	89 c6                	mov    %eax,%esi
  1060fa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  1060fc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  1060ff:	83 e1 03             	and    $0x3,%ecx
  106102:	74 02                	je     106106 <memmove+0x53>
  106104:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  106106:	89 f0                	mov    %esi,%eax
  106108:	89 fa                	mov    %edi,%edx
  10610a:	89 4d d8             	mov    %ecx,-0x28(%ebp)
  10610d:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  106110:	89 45 d0             	mov    %eax,-0x30(%ebp)
        : "memory");
    return dst;
  106113:	8b 45 e4             	mov    -0x1c(%ebp),%eax
        return __memcpy(dst, src, n);
  106116:	eb 36                	jmp    10614e <memmove+0x9b>
        : "0" (n), "1" (n - 1 + src), "2" (n - 1 + dst)
  106118:	8b 45 e8             	mov    -0x18(%ebp),%eax
  10611b:	8d 50 ff             	lea    -0x1(%eax),%edx
  10611e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106121:	01 c2                	add    %eax,%edx
  106123:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106126:	8d 48 ff             	lea    -0x1(%eax),%ecx
  106129:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10612c:	8d 1c 01             	lea    (%ecx,%eax,1),%ebx
    asm volatile (
  10612f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  106132:	89 c1                	mov    %eax,%ecx
  106134:	89 d8                	mov    %ebx,%eax
  106136:	89 d6                	mov    %edx,%esi
  106138:	89 c7                	mov    %eax,%edi
  10613a:	fd                   	std    
  10613b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10613d:	fc                   	cld    
  10613e:	89 f8                	mov    %edi,%eax
  106140:	89 f2                	mov    %esi,%edx
  106142:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  106145:	89 55 c8             	mov    %edx,-0x38(%ebp)
  106148:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    return dst;
  10614b:	8b 45 f0             	mov    -0x10(%ebp),%eax
            *d ++ = *s ++;
        }
    }
    return dst;
#endif /* __HAVE_ARCH_MEMMOVE */
}
  10614e:	83 c4 30             	add    $0x30,%esp
  106151:	5b                   	pop    %ebx
  106152:	5e                   	pop    %esi
  106153:	5f                   	pop    %edi
  106154:	5d                   	pop    %ebp
  106155:	c3                   	ret    

00106156 <memcpy>:
 * it always copies exactly @n bytes. To avoid overflows, the size of arrays pointed
 * by both @src and @dst, should be at least @n bytes, and should not overlap
 * (for overlapping memory area, memmove is a safer approach).
 * */
void *
memcpy(void *dst, const void *src, size_t n) {
  106156:	55                   	push   %ebp
  106157:	89 e5                	mov    %esp,%ebp
  106159:	57                   	push   %edi
  10615a:	56                   	push   %esi
  10615b:	83 ec 20             	sub    $0x20,%esp
  10615e:	8b 45 08             	mov    0x8(%ebp),%eax
  106161:	89 45 f4             	mov    %eax,-0xc(%ebp)
  106164:	8b 45 0c             	mov    0xc(%ebp),%eax
  106167:	89 45 f0             	mov    %eax,-0x10(%ebp)
  10616a:	8b 45 10             	mov    0x10(%ebp),%eax
  10616d:	89 45 ec             	mov    %eax,-0x14(%ebp)
        : "0" (n / 4), "g" (n), "1" (dst), "2" (src)
  106170:	8b 45 ec             	mov    -0x14(%ebp),%eax
  106173:	c1 e8 02             	shr    $0x2,%eax
  106176:	89 c1                	mov    %eax,%ecx
    asm volatile (
  106178:	8b 55 f4             	mov    -0xc(%ebp),%edx
  10617b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  10617e:	89 d7                	mov    %edx,%edi
  106180:	89 c6                	mov    %eax,%esi
  106182:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  106184:	8b 4d ec             	mov    -0x14(%ebp),%ecx
  106187:	83 e1 03             	and    $0x3,%ecx
  10618a:	74 02                	je     10618e <memcpy+0x38>
  10618c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
  10618e:	89 f0                	mov    %esi,%eax
  106190:	89 fa                	mov    %edi,%edx
  106192:	89 4d e8             	mov    %ecx,-0x18(%ebp)
  106195:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  106198:	89 45 e0             	mov    %eax,-0x20(%ebp)
    return dst;
  10619b:	8b 45 f4             	mov    -0xc(%ebp),%eax
    while (n -- > 0) {
        *d ++ = *s ++;
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
  10619e:	83 c4 20             	add    $0x20,%esp
  1061a1:	5e                   	pop    %esi
  1061a2:	5f                   	pop    %edi
  1061a3:	5d                   	pop    %ebp
  1061a4:	c3                   	ret    

001061a5 <memcmp>:
 *   match in both memory blocks has a greater value in @v1 than in @v2
 *   as if evaluated as unsigned char values;
 * - And a value less than zero indicates the opposite.
 * */
int
memcmp(const void *v1, const void *v2, size_t n) {
  1061a5:	55                   	push   %ebp
  1061a6:	89 e5                	mov    %esp,%ebp
  1061a8:	83 ec 10             	sub    $0x10,%esp
    const char *s1 = (const char *)v1;
  1061ab:	8b 45 08             	mov    0x8(%ebp),%eax
  1061ae:	89 45 fc             	mov    %eax,-0x4(%ebp)
    const char *s2 = (const char *)v2;
  1061b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  1061b4:	89 45 f8             	mov    %eax,-0x8(%ebp)
    while (n -- > 0) {
  1061b7:	eb 2e                	jmp    1061e7 <memcmp+0x42>
        if (*s1 != *s2) {
  1061b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061bc:	0f b6 10             	movzbl (%eax),%edx
  1061bf:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1061c2:	0f b6 00             	movzbl (%eax),%eax
  1061c5:	38 c2                	cmp    %al,%dl
  1061c7:	74 18                	je     1061e1 <memcmp+0x3c>
            return (int)((unsigned char)*s1 - (unsigned char)*s2);
  1061c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  1061cc:	0f b6 00             	movzbl (%eax),%eax
  1061cf:	0f b6 d0             	movzbl %al,%edx
  1061d2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  1061d5:	0f b6 00             	movzbl (%eax),%eax
  1061d8:	0f b6 c8             	movzbl %al,%ecx
  1061db:	89 d0                	mov    %edx,%eax
  1061dd:	29 c8                	sub    %ecx,%eax
  1061df:	eb 18                	jmp    1061f9 <memcmp+0x54>
        }
        s1 ++, s2 ++;
  1061e1:	ff 45 fc             	incl   -0x4(%ebp)
  1061e4:	ff 45 f8             	incl   -0x8(%ebp)
    while (n -- > 0) {
  1061e7:	8b 45 10             	mov    0x10(%ebp),%eax
  1061ea:	8d 50 ff             	lea    -0x1(%eax),%edx
  1061ed:	89 55 10             	mov    %edx,0x10(%ebp)
  1061f0:	85 c0                	test   %eax,%eax
  1061f2:	75 c5                	jne    1061b9 <memcmp+0x14>
    }
    return 0;
  1061f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  1061f9:	89 ec                	mov    %ebp,%esp
  1061fb:	5d                   	pop    %ebp
  1061fc:	c3                   	ret    
