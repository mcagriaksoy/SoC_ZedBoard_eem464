/* This file is automatically generated based on your hardware design. */
#include "memory_config.h"

struct memory_range_s memory_ranges[] = {
	{
		"ps7_ddr_0",
		"ps7_ddr_0",
		0x00100000,
		535822336,
	},
	/* ps7_ram_0 memory will not be tested since application resides in the same memory */
	{
		"ps7_ram_1",
		"ps7_ram_1",
		0xFFFF0000,
		65024,
	},
};

int n_memory_ranges = 2;
