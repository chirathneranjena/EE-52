
#if defined(INTEL_LIB_V3)
	#pragma title("Using Pre-Production Libs")
#endif

#if defined(SCREEN)
	#pragma pagelength(24)
	#pragma pagewidth(80)
	#pragma tabwidth(3)
#else
	#if defined(NPAPER)
		#pragma pagelength(40)
		#pragma pagewidth(75)
		#pragma tabwidth(2)
	#endif
#endif

#define PASS 1              /* Subroutine status */
#define FAIL 0              /* Subroutine status */
#define BLOCK_SIZE 0x2000   /* One EMM block is 8K integers */

#include <stdio.h>

/*
 * External assembly language routines to interface to Expanded Memory Manager.
 */
extern int EMM_get_status(void);
extern int EMM_get_pg_frame(unsigned int *);
extern int EMM_get_unalloc_pg_count(int *, int *);
extern int EMM_alloc_pgs(int, int *);
extern int EMM_map_handle_pg(int, int, int);
extern int EMM_dealloc_pgs(int);

/*
 * Sequence of events:
 *      1. Test for the presence of an expanded memory manager (EMM) driver.
 *      2. Find out how many pages of expanded memory are available.
 *      3. Allocate a new page of memory.
 *      4. Map new memory into address space.
 *      5. Get the page frame base address.
 *      6. Test the memory.
 *      7. Deallocate the expanded memory page.
 */

static int
verify_installation()
{
    int sts;

    printf("Testing for the Expanded Memory Manager (EMM)\n");
    if ((sts = EMM_get_status()) == 0)
        printf("EMM is installed\n");
    else
    {
        printf("EMM is not installed (EMM_get_status returned %04X)\n", sts);
        return FAIL;
    }
    return PASS;
}

static int
allocate_memory(num, handle_ptr, page_ptr)
int num;
int *handle_ptr;
unsigned int *page_ptr;
{
    int sts;
    int unalloc_pg_count = 0;
    int total_pg_count = 0;

    if ((sts = EMM_get_unalloc_pg_count(&unalloc_pg_count, &total_pg_count)) == 0)
        printf("EMM page count unalloc %d out of %d\n", unalloc_pg_count,
            total_pg_count);
    else
    {
        printf("EMM page count problem (EMM_get_unalloc_pg_count returned %04X)\n", sts);
        return FAIL;
    }
    if (unalloc_pg_count < num)
    {
        printf("Insufficient memory available to test\n");
        return FAIL;
    }

    if ((sts = EMM_alloc_pgs(num, handle_ptr)) == 0)
        printf("EMM memory page handle %d returned\n", *handle_ptr);
    else
    {
        printf("EMM allocation problem (EMM_alloc_pgs returned %04X)\n", sts);
        return FAIL;
    }

    if ((sts = EMM_map_handle_pg(*handle_ptr, 0, 0)) == 0)
        printf("EMM handle %d mapped into 0:0\n", *handle_ptr);
    else
    {
        printf("EMM mapping problem (EMM_map_handle_pg returned %04X)\n", sts);
        return FAIL;
    }

    if ((sts = EMM_get_pg_frame(page_ptr)) == 0)
        printf("EMM page frame is %X\n", *page_ptr);
    else
    {
        printf("EMM page frame not defined (EMM_get_pg_frame returned %04X)\n", sts);
        return FAIL;
    }
    return PASS;
}

static int
deallocate_memory(handle)
int handle;
{
    int sts;

    if ((sts = EMM_dealloc_pgs(handle)) == 0)
        printf("EMM memory page handle %d deallocated\n", handle);
    else
    {
        printf("EMM deallocation problem (EMM_dealloc_pgs returned %04X)\n", sts);
        return FAIL;
    }
    return PASS;
}

int
main()
{
    unsigned int pg;                    /* EMM page segment             */
    int handle;                         /* EMM memory block handle      */
    unsigned int far *emm_ptr;          /* Long pointer to memory block */
    unsigned int pattern;               /* Pattern for memory test      */
    int emm_index;                      /* Index into memory block      */

    if (verify_installation() != PASS)
        return FAIL;

    if (allocate_memory(1, &handle, &pg) != PASS)
        return FAIL;

    /*
     * Convert the EMM page segment to a far pointer.
     */
    emm_ptr = (unsigned int far *)((long) pg << 16);

    /*
     * Walk a one across all bits of every integer in the memory block.
     */
    for (emm_index = 0; emm_index < BLOCK_SIZE; emm_index++)
    {
        for (pattern = 1; pattern != 0; pattern <<= 1)
        {
            emm_ptr[emm_index] = pattern;
            if (emm_ptr[emm_index] != pattern)
            {
                printf("RAM test FAILED: expected %04X, received %04X\n",
                    pattern, emm_ptr[emm_index]);
                return FAIL;
            }
        }
    }
    printf("RAM test PASSED\n");

    if (deallocate_memory(handle) != PASS)
        return FAIL;

    return PASS;
}
