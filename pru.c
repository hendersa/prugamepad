/*
 * PRUSetup() and PRUShutdown() are based on PRU_memAccess_DDR_PRUsharedRAM.c 
 * from the PRUSS reference code provided by Texas Instruments. All other 
 * functions and firmware associated with this sample program were developed 
 * by Andrew Henderson (hendersa@icculus.org). All code in the project is made 
 * available under the BSD open source license.  
*/

#include <stdio.h>
#include <stdlib.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <string.h>

#include "prussdrv/prussdrv.h"
#include "prussdrv/pruss_intc_mapping.h"

#define PRU_NUM 	 	0
#define OFFSET_SHAREDRAM 	2048
#define PRUSS0_SHARED_DATARAM	4

static volatile void *sharedMem;
static volatile uint32_t *sharedMem_int;

void PRUSetup(const char *firmware)
{
    unsigned int ret;
    tpruss_intc_initdata pruss_intc_initdata = PRUSS_INTC_INITDATA;

    /* Initialize the PRU */
    prussdrv_init ();

    /* Open PRU Interrupt */
    ret = prussdrv_open(PRU_EVTOUT_0);
    if (ret)
    {
        fprintf(stderr, "PRU open failed, exiting...\n");
        exit(-1);
    }

    /* Get the interrupt initialized */
    prussdrv_pruintc_init(&pruss_intc_initdata);

    /* Execute gamepad firmware on PRU */
    prussdrv_exec_program (PRU_NUM, firmware);

    /* Allocate shared PRU memory */
    prussdrv_map_prumem(PRUSS0_SHARED_DATARAM, (void *)(&sharedMem));
    sharedMem_int = (uint32_t *) sharedMem;
}

uint32_t PRUState(void)
{
    return(sharedMem_int[OFFSET_SHAREDRAM]);
}

void PRUShutdown(void)
{
  /* Disable PRU and close memory mapping*/
  prussdrv_pru_disable(PRU_NUM);
  prussdrv_exit();
}

