// Mehmet Cagri Aksoy

#include <stdio.h>
#include "xparameters.h"
#include "xil_types.h"
#include "xstatus.h"
#include "xil_testmem.h"

#include "platform.h"
#include "memory_config.h"
#include "xil_printf.h"


void putnum(unsigned int num);

void test_memory_range(struct memory_range_s *range) {
    XStatus status;

    print("Testing memory region: "); print(range->name);  print("\n\r");
    print("    Memory Controller: "); print(range->ip);  print("\n\r");
    #ifdef __MICROBLAZE__
        print("         Base Address: 0x"); putnum(range->base); print("\n\r");
        print("                 Size: 0x"); putnum(range->size); print (" bytes \n\r");
    #else
        xil_printf("         Base Address: 0x%lx \n\r",range->base);
        xil_printf("                 Size: 0x%lx bytes \n\r",range->size);
    #endif

    status = Xil_TestMem32((u32*)range->base, 1024, 0xAAAA5555, XIL_TESTMEM_ALLMEMTESTS);
    print("          32-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); print("\n\r");

    status = Xil_TestMem16((u16*)range->base, 2048, 0xAA55, XIL_TESTMEM_ALLMEMTESTS);
    print("          16-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); print("\n\r");

    status = Xil_TestMem8((u8*)range->base, 4096, 0xA5, XIL_TESTMEM_ALLMEMTESTS);
    print("           8-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); print("\n\r");

}

void mult(int arr1[2][3], int arr2[3][2], int result[2][2]){

	 int i, j, k = 0;

	        for (i = 0; i < 2; i++) {
	          for (j = 0; j < 2; j++) {
	            result[i][j] = 0;
	            for (k = 0; k < 3; k++) {
	              result[i][j] += arr1[i][k]*arr2[k][j];
	            }
	          }
	        }

	        printf("Product of the matrices:\n a.b = \n");

	        for (i = 0; i < 2; i++) {
	          for (j = 0; j < 2; j++)
	            printf("%d\t", result[i][j]);

	          printf("\n");
	        }
}


int main()
{
	init_platform();
	int i;

	//Multiplication Part:
	int arr1[ 2 ][ 3 ] = { { 5, 6, 7 }, { 10, 20, 30 } };
	int arr2[ 3 ][ 2 ] = { { 1, 2 }, { 2,  1 }, {4 , 0} };
	int result[2][2];
	mult(arr1, arr2, result);


    print("--Starting Memory Test Application--\n\r");
    print("NOTE: This application runs with D-Cache disabled.");
    print("As a result, cacheline requests will not be generated\n\r");

    for (i = 0; i < n_memory_ranges; i++) {
        test_memory_range(&memory_ranges[i]);
    }

    print("--Memory Test Application Complete--\n\r");

    cleanup_platform();
    return 0;
}
