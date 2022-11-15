#include <pmm.h>
#include <list.h>
#include <string.h>
#include <default_pmm.h>

/*  In the First Fit algorithm, the allocator keeps a list of free blocks
 * (known as the free list). Once receiving a allocation request for memory,
 * it scans along the list for the first block that is large enough to satisfy
 * the request. If the chosen block is significantly larger than requested, it
 * is usually splitted, and the remainder will be added into the list as
 * another free block.
 *  Please refer to Page 196~198, Section 8.2 of Yan Wei Min's Chinese book
 * "Data Structure -- C programming language".
*/
// LAB2 EXERCISE 1: YOUR CODE
// you should rewrite functions: `default_init`, `default_init_memmap`,
// `default_alloc_pages`, `default_free_pages`.
/*
 * Details of FFMA
 * (1) Preparation:
 *  In order to implement the First-Fit Memory Allocation (FFMA), we should
 * manage the free memory blocks using a list. The struct `free_area_t` is used
 * for the management of free memory blocks.
 *  First, you should get familiar with the struct `list` in list.h. Struct
 * `list` is a simple doubly linked list implementation. You should know how to
 * USE `list_init`, `list_add`(`list_add_after`), `list_add_before`, `list_del`,
 * `list_next`, `list_prev`.
 *  There's a tricky method that is to transform a general `list` struct to a
 * special struct (such as struct `page`), using the following MACROs: `le2page`
 * (in memlayout.h), (and in future labs: `le2vma` (in vmm.h), `le2proc` (in
 * proc.h), etc).
 * (2) `default_init`:
 *  You can reuse the demo `default_init` function to initialize the `free_list`
 * and set `nr_free` to 0. `free_list` is used to record the free memory blocks.
 * `nr_free` is the total number of the free memory blocks.
 * (3) `default_init_memmap`:
 *  CALL GRAPH: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager` --> `init_memmap`.
 *  This function is used to initialize a free block (with parameter `addr_base`,
 * `page_number`). In order to initialize a free block, firstly, you should
 * initialize each page (defined in memlayout.h) in this free block. This
 * procedure includes:
 *  - Setting the bit `PG_property` of `p->flags`, which means this page is
 * valid. P.S. In function `pmm_init` (in pmm.c), the bit `PG_reserved` of
 * `p->flags` is already set.
 *  - If this page is free and is not the first page of a free block,
 * `p->property` should be set to 0.
 *  - If this page is free and is the first page of a free block, `p->property`
 * should be set to be the total number of pages in the block.
 *  - `p->ref` should be 0, because now `p` is free and has no reference.
 *  After that, We can use `p->page_link` to link this page into `free_list`.
 * (e.g.: `list_add_before(&free_list, &(p->page_link));` )
 *  Finally, we should update the sum of the free memory blocks: `nr_free += n`.
 * (4) `default_alloc_pages`:
 *  Search for the first free block (block size >= n) in the free list and reszie
 * the block found, returning the address of this block as the address required by
 * `malloc`.
 *  (4.1)
 *      So you should search the free list like this:
 *          list_entry_t le = &free_list;
 *          while((le=list_next(le)) != &free_list) {
 *          ...
 *      (4.1.1)
 *          In the while loop, get the struct `page` and check if `p->property`
 *      (recording the num of free pages in this block) >= n.
 *              struct Page *p = le2page(le, page_link);
 *              if(p->property >= n){ ...
 *      (4.1.2)
 *          If we find this `p`, it means we've found a free block with its size
 *      >= n, whose first `n` pages can be malloced. Some flag bits of this page
 *      should be set as the following: `PG_reserved = 1`, `PG_property = 0`.
 *      Then, unlink the pages from `free_list`.
 *          (4.1.2.1)
 *              If `p->property > n`, we should re-calculate number of the rest
 *          pages of this free block. (e.g.: `le2page(le,page_link))->property
 *          = p->property - n;`)
 *          (4.1.3)
 *              Re-caluclate `nr_free` (number of the the rest of all free block).
 *          (4.1.4)
 *              return `p`.
 *      (4.2)
 *          If we can not find a free block with its size >=n, then return NULL.
 * (5) `default_free_pages`:
 *  re-link the pages into the free list, and may merge small free blocks into
 * the big ones.
 *  (5.1)
 *      According to the base address of the withdrawed blocks, search the free
 *  list for its correct position (with address from low to high), and insert
 *  the pages. (May use `list_next`, `le2page`, `list_add_before`)
 *  (5.2)
 *      Reset the fields of the pages, such as `p->ref` and `p->flags` (PageProperty)
 *  (5.3)
 *      Try to merge blocks at lower or higher addresses. Notice: This should
 *  change some pages' `p->property` correctly.
 */
/* 在First Fit算法中，分配器保持一个空闲块的列表
 *（被称为空闲列表）。一旦收到对内存的分配请求。
 * 它沿着列表扫描，寻找第一个足够大的块，以满足
 * 的请求。如果所选择的块比请求的大得多，它通常会被分割开来。
 * 通常会被分割开来，剩下的部分会被添加到列表中作为
 * 另一个自由区块。
 * 请参考阎维文的中文书中的第196~198页，第8.2节
 * "数据结构--C编程语言"。
*/
// lab2练习1：你的代码
// 你应该重写函数。`default_init`, `default_init_memmap`,
// `default_alloc_pages`, `default_free_pages`.
/*
 * FFMA的细节
 * (1) 准备工作。
 * 为了实现先定内存分配（FFMA），我们应该
 * 用一个列表来管理空闲内存块。结构 "free_area_t "被用于
 * 用于管理空闲内存块。
 * 首先，你应该熟悉list.h中的struct `list`。
 * `list`是一个简单的双链表实现。你应该知道如何
 * 使用 `list_init`, `list_add`(`list_add_after`), `list_add_before`, `list_del`,
 * `list_next`, `list_prev`。
 * 有一个棘手的方法，就是将一般的`list`结构转化为一个
 * 特殊结构（例如`page`结构），使用以下MACRO： `le2page`.
 * (在memlayout.h中), (以及在未来的实验室中：`le2vma` (在vmm.h中), `le2proc` (在
 * proc.h），等等）。
 * (2) `default_init`:
 * 你可以重复使用演示的`default_init`函数来初始化`free_list`。
 * `free_list`是用来记录空闲内存块的。
 * `nr_free`是空闲内存块的总数。
 * (3) `default_init_memmap`:
 * 调用GRAPH: `kern_init` --> `pmm_init` --> `page_init` --> `init_memmap` -->
 * `pmm_manager`--> `init_memmap`.
 * 这个函数用来初始化一个自由块（参数为`addr_base`,
 * `page_number`）。为了初始化一个自由块，首先，你应该
 * 初始化这个自由块中的每个页面（定义在memlayout.h中）。这个
 * 过程包括
 * 设置`p->flags`的`PG_property`位，这意味着这个页面是
 * 有效。P.S. 在函数`pmm_init`（在pmm.c中）中，`PG_reserved`的位
 * `p->flags`已经被设置。
 * - 如果这个页面是空闲的，并且不是空闲块的第一页。
 * `p->property`应该被设置为0。
 * - 如果这个页面是空闲的，并且是空闲区块的第一页，`p->property`应该设置为0。
 * 应该被设置为该区块的总页数。
 * - `p->ref`应该是0，因为现在`p`是自由的，没有引用。
 * 之后，我们可以使用`p->page_link`将这个页面链接到`free_list`。
 * (例如。`list_add_before(&free_list, &(p->page_link)); ` )
 * 最后，我们应该更新空闲内存块的总和。`nr_free += n`。
 * (4) `default_alloc_pages`:
 * 在空闲列表中搜索第一个空闲块(块大小>=n)，并重新定位
 * 找到的块，并返回这个块的地址作为 "malloc "所需要的地址。
 * `malloc`.
 * (4.1)
 * 所以你应该像这样搜索自由列表。
 * list_entry_t le = &free_list;
 * while((le=list_next(le)) != &free_list) {
 * ...
 * (4.1.1)
 * 在while循环中，获取结构体`page`并检查`p->property`（记录空闲的数量）。
 * (记录这个区块中空闲页面的数量) >= n.
 * struct Page *p = le2page(le, page_link);
 * 如果(p->property >= n){ ...
 * (4.1.2)
 * 如果我们找到了这个`p`，就意味着我们找到了一个空闲块，其大小为
 * >= n，其前`n`页可以被malloced。这个页面的一些标志位
 * 应该被设置为以下内容。`PG_reserved = 1`, `PG_property = 0`.
 * 然后，将这些页面从`free_list`中取消链接。
 * (4.1.2.1)
 * 如果`p->property > n`，我们应该重新计算其余的
 * 这个自由块的页数。(例如: `le2page(le,page_link))->property
 * = p->property - n;`)
 * (4.1.3)
 * 重新计算`nr_free`（所有空闲块的其余部分的数量）。
 * (4.1.4)
 * 返回`p'。
 * (4.2)
 * 如果我们不能找到一个大小>=n的空闲块，那么就返回NULL。
 * (5) `default_free_pages`:
 * 将页面重新链接到空闲列表中，并可能将小的空闲块合并到
 * 大块的。
 * (5.1)
 * 根据被撤回区块的基址，在空闲列表中搜索
 * 列表的正确位置（地址从低到高），并插入
 * 页面。(可以使用`list_next`, `le2page`, `list_add_before`)
 * (5.2)
 * 重置页面的字段，如`p->ref`和`p->flags` (PageProperty)
 * (5.3)
 * 尝试合并较低或较高地址的块。注意。这应该
 * 正确改变一些页面的`p->property`。
 */
free_area_t free_area;

#define free_list (free_area.free_list)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
}

static void
default_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;
    for (; p != base + n; p ++) {
        assert(PageReserved(p));
        p->flags = p->property = 0;
        set_page_ref(p, 0);
    }
    base->property = n;
    SetPageProperty(base);
    nr_free += n;
    list_add(&free_list, &(base->page_link));
}

// static struct Page *
// default_alloc_pages(size_t n) {
//     assert(n > 0);
//     if (n > nr_free) {
//         return NULL;
//     }
//     struct Page *page = NULL;
//     list_entry_t *le = &free_list;
//     while ((le = list_next(le)) != &free_list) {
//         struct Page *p = le2page(le, page_link);
//         if (p->property >= n) {
//             page = p;
//             break;
//         }
//     }
//     if (page != NULL) {
//         list_del(&(page->page_link));
//         if (page->property > n) {
//             struct Page *p = page + n;
//             p->property = page->property - n;
//             list_add(&free_list, &(p->page_link));
//         }
//         nr_free -= n;
//         ClearPageProperty(page);
//     }
//     return page;
// }
/**
 * 接受一个合法的正整数参数n，为其分配N个物理页面大小的连续物理内存空间.
 * 并以Page指针的形式，返回最低位物理页(最前面的)。
 * 
 * 如果分配时发生错误或者剩余空闲空间不足，则返回NULL代表分配失败
 * */
static struct Page *
default_alloc_pages(size_t n) {    assert(n > 0);
    if (n > nr_free) {
        return NULL;
    }
    struct Page *page = NULL;
    list_entry_t *le = &free_list;
    // TODO: optimize (next-fit)

    // 遍历空闲链表
    while ((le = list_next(le)) != &free_list) {
        // 将le节点转换为关联的Page结构
        struct Page *p = le2page(le, page_link);
        if (p->property >= n) {
            // 发现一个满足要求的，空闲页数大于等于N的空闲块
            page = p;
            break;
        }
    }
    // 如果page != null代表找到了，分配成功。反之则分配物理内存失败
    if (page != NULL) {
        if (page->property > n) {
            // 如果空闲块的大小不是正合适(page->property != n)
            // 按照指针偏移，找到按序后面第N个Page结构p
            struct Page *p = page + n;
            // p其空闲块个数 = 当前找到的空闲块数量 - n
            p->property = page->property - n;
            SetPageProperty(p);
            // 按对应的物理地址顺序，将p加入到空闲链表中对应的位置
            list_add_after(&(page->page_link), &(p->page_link));
        }
        // 在将当前page从空间链表中移除
        list_del(&(page->page_link));
        // 闲链表整体空闲页数量自减n
        nr_free -= n;
        // 清楚page的property(因为非空闲块的头Page的property都为0)
        ClearPageProperty(page);
    }
    return page;
}
// static void
// default_free_pages(struct Page *base, size_t n) {
//     assert(n > 0);
//     struct Page *p = base;
//     for (; p != base + n; p ++) {
//         assert(!PageReserved(p) && !PageProperty(p));
//         p->flags = 0;
//         set_page_ref(p, 0);
//     }
//     base->property = n;
//     SetPageProperty(base);
//     list_entry_t *le = list_next(&free_list);
//     while (le != &free_list) {
//         p = le2page(le, page_link);
//         le = list_next(le);
//         if (base + base->property == p) {
//             base->property += p->property;
//             ClearPageProperty(p);
//             list_del(&(p->page_link));
//         }
//         else if (p + p->property == base) {
//             p->property += base->property;
//             ClearPageProperty(base);
//             base = p;
//             list_del(&(p->page_link));
//         }
//     }
//     nr_free += n;
//     list_add(&free_list, &(base->page_link));
// }

/**
 * 释放掉自base起始的连续n个物理页,n必须为正整数
 * */
static void
default_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    struct Page *p = base;

    // 遍历这N个连续的Page页，将其相关属性设置为空闲
    for (; p != base + n; p ++) {
        assert(!PageReserved(p) && !PageProperty(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }

    // 由于被释放了N个空闲物理页，base头Page的property设置为n
    base->property = n;
    SetPageProperty(base);

    // 下面进行空闲链表相关操作
    list_entry_t *le = list_next(&free_list);
    // 迭代空闲链表中的每一个节点
    while (le != &free_list) {
        // 获得节点对应的Page结构
        p = le2page(le, page_link);
        le = list_next(le);
        // TODO: optimize
        if (base + base->property == p) {
            // 如果当前base释放了N个物理页后，尾部正好能和Page p连上，则进行两个空闲块的合并
            base->property += p->property;
            ClearPageProperty(p);
            list_del(&(p->page_link));
        }
        else if (p + p->property == base) {
            // 如果当前Page p能和base头连上，则进行两个空闲块的合并
            p->property += base->property;
            ClearPageProperty(base);
            base = p;
            list_del(&(p->page_link));
        }
    }
    // 空闲链表整体空闲页数量自增n
    nr_free += n;
    le = list_next(&free_list);

    // 迭代空闲链表中的每一个节点
    while (le != &free_list) {
        // 转为Page结构
        p = le2page(le, page_link);
        if (base + base->property <= p) {
            // 进行空闲链表结构的校验，不能存在交叉覆盖的地方
            assert(base + base->property != p);
            break;
        }
        le = list_next(le);
    }
    // 将base加入到空闲链表之中
    list_add_before(le, &(base->page_link));
}


static size_t
default_nr_free_pages(void) {
    return nr_free;
}

static void
basic_check(void) {
    struct Page *p0, *p1, *p2;
    p0 = p1 = p2 = NULL;
    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(p0 != p1 && p0 != p2 && p1 != p2);
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);

    assert(page2pa(p0) < npage * PGSIZE);
    assert(page2pa(p1) < npage * PGSIZE);
    assert(page2pa(p2) < npage * PGSIZE);

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    assert(alloc_page() == NULL);

    free_page(p0);
    free_page(p1);
    free_page(p2);
    assert(nr_free == 3);

    assert((p0 = alloc_page()) != NULL);
    assert((p1 = alloc_page()) != NULL);
    assert((p2 = alloc_page()) != NULL);

    assert(alloc_page() == NULL);

    free_page(p0);
    assert(!list_empty(&free_list));

    struct Page *p;
    assert((p = alloc_page()) == p0);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    free_list = free_list_store;
    nr_free = nr_free_store;

    free_page(p);
    free_page(p1);
    free_page(p2);
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
        count ++, total += p->property;
    }
    assert(total == nr_free_pages());

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
    assert(p0 != NULL);
    assert(!PageProperty(p0));

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
    assert(alloc_pages(4) == NULL);
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
    assert((p1 = alloc_pages(3)) != NULL);
    assert(alloc_page() == NULL);
    assert(p0 + 2 == p1);

    p2 = p0 + 1;
    free_page(p0);
    free_pages(p1, 3);
    assert(PageProperty(p0) && p0->property == 1);
    assert(PageProperty(p1) && p1->property == 3);

    assert((p0 = alloc_page()) == p2 - 1);
    free_page(p0);
    assert((p0 = alloc_pages(2)) == p2 + 1);

    free_pages(p0, 2);
    free_page(p2);

    assert((p0 = alloc_pages(5)) != NULL);
    assert(alloc_page() == NULL);

    assert(nr_free == 0);
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
        assert(le->next->prev == le && le->prev->next == le);
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
    }
    assert(count == 0);
    assert(total == 0);
}

const struct pmm_manager default_pmm_manager = {
    .name = "default_pmm_manager",
    .init = default_init,
    .init_memmap = default_init_memmap,
    .alloc_pages = default_alloc_pages,
    .free_pages = default_free_pages,
    .nr_free_pages = default_nr_free_pages,
    .check = default_check,
};

