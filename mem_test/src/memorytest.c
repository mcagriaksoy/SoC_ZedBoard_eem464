// Mehmet_Cagri_Aksoy

#include <stdio.h>
#include "xparameters.h"
#include "xil_types.h"
#include "xstatus.h"
#include "xil_testmem.h"

#include "platform.h"
#include "memory_config.h"
#include "xil_printf.h"


void putnum(unsigned int num);
void read(u32 *Addr);
void write(u32 *Addr);

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

    status = Xil_TestMem32((u32*)range->base,1024, 0xAAAA5555, XIL_TESTMEM_ALLMEMTESTS);
    print("          32-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); print("\n\r");

    status = Xil_TestMem16((u16*)range->base, 2048, 0xAA55, XIL_TESTMEM_ALLMEMTESTS);
    print("          16-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); print("\n\r");

    status = Xil_TestMem8((u8*)range->base, 4096, 0xA5, XIL_TESTMEM_ALLMEMTESTS);
    print("           8-bit test: "); print(status == XST_SUCCESS? "PASSED!":"FAILED!"); print("\n\r");

}
void read(u32 *Addr){

	u32 arr1_res[2][3];
	u32 arr2_res[3][2];
	int i,j,k = 0;
	u32 I, I2;
	u32 Words = 512;
	u32 result[2][2];
	I=0U;

	//for (I = 0U; I < Words; I++) {
			for(i = 0; i < 2; i++){

				for (j = 0; j < 3; j++) {
					 arr1_res[i][j]=*(Addr+I);
					 xil_printf("\n\rarr1_res red[%d][%d]=%d\r\n",i,j,arr1_res[i][j]);
					 I = I + 4;
				}

			}
		//}
			I2 = I ;
	//for (I2 = I ; I2 < Words*2; I2++) {
			for(i = 0; i < 3; i++){

				for (j = 0; j < 2; j++) {
					arr2_res[i][j]=*(Addr+I2);
					xil_printf("\n\rarr2_res read[%d][%d]=%d\r\n",i,j,arr2_res[i][j]);
					I2= I2 + 4;
				}

			}
		//}

	  for (i = 0; i < 2; i++) {
		 for (j = 0; j < 2; j++) {
		    result[i][j] = 0;
		       for (k = 0; k < 3; k++) {
		         result[i][j] += arr1_res[i][k]*arr2_res[k][j];
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
void write(u32 *Addr){
	xil_printf("\nArrays are writing to DDR memory...%p", *Addr);
	u32 arr1[ 2 ][ 3 ] = { { 5, 6, 7 }, { 10, 20, 30 } };
	u32 arr2[ 3 ][ 2 ] = { { 1, 2 }, { 2,  1 }, {1 , 1} };

	u32 I,I2 ;
	int i, j = 0;
	u32 Words = 1024 ;

	//write arr1 into the DDR:
	//for (I = 0U; I < Words; I++) {
	I=0U;
		for(i = 0; i < 2; i++){

			for (j = 0; j < 3; j++) {
				*(Addr+I) = arr1[i][j];
				I=I+4;
			}

		}
	//}

	//write arr2 into the DDR:
	//for (I2 = I; I2 < Words*2; I2++) {
		I2 = I;
			for(i = 0; i < 3; i++){

				for (j = 0; j < 2; j++) {
					*(Addr+I2) = arr2[i][j];
					xil_printf("\n\rarr2_res write[%d][%d]=%d\r\n",i,j,*(Addr+I2));
					I2 = I2 + 4 ;
				}

			}
		//}
	printf("\nwriting process is finished");
	//read(*Addr);

}

int main()
{
	init_platform();
	int i;

	for (i = 0; i < 1; i++) {
	   //test_memory_range(&memory_ranges[i]);
	   write((u32*)&(memory_ranges[i].base));
	   read((u32*)&(memory_ranges[i].base));
	}



    cleanup_platform();
    return 0;
}
