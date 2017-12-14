//-----------------------------------------------------------
// Digital Signal Processing  Lab
// Testprogram read/write
//
// AIC23 version
//
// Filename : get_started.c
//
// Author Svg 8-Jan-07
//
// version 1 : modified 27-Nov-08, Kup
// version 2 : 31-Jan-10, JR


//#define SIMULATOR

// for usage of input MIC_IN and output HEADPHONE with DC coupling: 
//#define MIC_IN

#include "c6713dskinit.h"		//codec-DSK support file
#include "dsk6713.h"
#include <math.h>				//math library
#include <stdint.h>

#include "biquad.h"
#include "IIR_LP_ellip_cheby1.h"
#include "IIR_ellip_HP.h"

#define LEFT 1
#define RIGHT 0
#define BUFLEN 1000

//  external beim DSK-Board, hier zu deklarieren für Simulator:
#ifdef SIMULATOR
	MCBSP_Handle DSK6713_AIC23_DATAHANDLE;
#else
	extern MCBSP_Handle DSK6713_AIC23_DATAHANDLE;
#endif

	static Uint32 CODECEventId;
	Uint32 fs=DSK6713_AIC23_FREQ_8KHZ;     //for sampling frequency
	//Uint32 fs;            			     //for sampling frequency

// two buffers for input and output samples with two counters
	short int inBuf_L[BUFLEN];
	short int inBuf_R[BUFLEN];
	short int count_INT=0;

	union {
		Uint32 both; 
		short channel[2];
	} AIC23_data;

	int32_t W_cheby1_LP[CASCADELENGTH_CHEBY1_LP][CASCADE_PART_ORDER_CHEBY1_LP]={0};
	int32_t W_ellip_LP[CASCADELENGTH_ELLIP_LP][CASCADE_PART_ORDER_ELLIP_LP]={0};
	int32_t W_ellip_HP[CASCADELENGTH_ELLIP_HP][CASCADE_PART_ORDER_ELLIP_HP]={0};

	int32_t W_ellip_LP_2T[CASCADELENGTH_ELLIP_LP][2*CASCADE_PART_ORDER_ELLIP_LP]={0};

	int16_t output_LEFT=0;
	int16_t output_RIGHT=0;

	uint8_t cascadeCounter=0;
	uint8_t switch_filters=2;

interrupt void intser_McBSP1() 
{
	AIC23_data.both = MCBSP_read(DSK6713_AIC23_DATAHANDLE); //input data

// buffer monitoring input signal, reset count if BUFLEN is reached, 
// then input buffer is full
	inBuf_L[count_INT] = AIC23_data.channel[LEFT];
	inBuf_R[count_INT] = AIC23_data.channel[RIGHT];

// buffer full ??
	count_INT++;
    if (count_INT >= BUFLEN) 
    	count_INT = 0;

    //do stuff

    output_LEFT=inBuf_L[count_INT];
    output_RIGHT=inBuf_R[count_INT];

    switch(switch_filters)
    {
    	case 0:

    		for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_CHEBY1_LP;cascadeCounter++)
    		{
    			biquad(num_IIR_cheby1_LP[cascadeCounter],denum_IIR_cheby1_LP[cascadeCounter],W_cheby1_LP[cascadeCounter],output_RIGHT,&output_RIGHT);
    		}

    		for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_LP;cascadeCounter++)
    		{
    			biquad(num_IIR_ellip_LP[cascadeCounter],denum_IIR_ellip_LP[cascadeCounter],W_ellip_LP[cascadeCounter],output_LEFT,&output_LEFT);
    		}

    	break;


    	case 1:

    		for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_LP;cascadeCounter++)
    		{
    		  	biquad(num_IIR_ellip_LP[cascadeCounter],denum_IIR_ellip_LP[cascadeCounter],W_ellip_LP[cascadeCounter],output_LEFT,&output_LEFT);
    		}

    		for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_HP;cascadeCounter++)
    		{
    			biquad(num_IIR_ellip_HP[cascadeCounter],denum_IIR_ellip_HP[cascadeCounter],W_ellip_HP[cascadeCounter],output_RIGHT,&output_RIGHT);
    		}

    	break;

    	case 2:

    	   for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_LP;cascadeCounter++)
    	   {
    		   biquad(num_IIR_ellip_LP[cascadeCounter],denum_IIR_ellip_LP[cascadeCounter],W_ellip_LP[cascadeCounter],output_LEFT,&output_LEFT);
    	   }

    	   for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_HP;cascadeCounter++)
    	   {
    		   biquad_2T(num_IIR_ellip_HP[cascadeCounter],denum_IIR_ellip_HP[cascadeCounter],W_ellip_LP_2T[cascadeCounter],output_RIGHT,&output_RIGHT);
    	   }

    	break;
    }

    AIC23_data.channel[LEFT]=output_LEFT;
    AIC23_data.channel[RIGHT]=output_RIGHT;
    //end do stuff

	MCBSP_write(DSK6713_AIC23_DATAHANDLE, AIC23_data.both);   //output 32 bit data, LEFT and RIGHT 

	return;
}
///////////////////////////////////////////////////////////////////

void main()
{
	IRQ_globalDisable();           		//disable interrupts

	/*initialisation with 0
	 */
	for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_CHEBY1_LP;cascadeCounter++)
	{
		W_cheby1_LP[cascadeCounter][0]=0;
		W_cheby1_LP[cascadeCounter][1]=0;

	}

	for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_LP;cascadeCounter++)
	{
		W_ellip_LP[cascadeCounter][0]=0;
		W_ellip_LP[cascadeCounter][1]=0;
	}


	for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_HP;cascadeCounter++)
	{
		W_ellip_HP[cascadeCounter][0]=0;
		W_ellip_HP[cascadeCounter][1]=0;
	}

	for(cascadeCounter=0;cascadeCounter<CASCADELENGTH_ELLIP_LP;cascadeCounter++)
	{
		W_ellip_LP_2T[cascadeCounter][0]=0;
		W_ellip_LP_2T[cascadeCounter][1]=0;
	}

#ifndef SIMULATOR
	DSK6713_init();                   	//call BSL to init DSK-EMIF,PLL)
#ifdef MIC_IN
	config.regs[4] = 0x14;
	config.regs[5] = 0x1;
#endif

	hAIC23_handle=DSK6713_AIC23_openCodec(0, &config);//handle(pointer) to codec
	DSK6713_AIC23_setFreq(hAIC23_handle, fs);  //set sample rate

#else	// Nur für Simulator:
    DSK6713_AIC23_DATAHANDLE= MCBSP_open(MCBSP_DEV1, MCBSP_OPEN_RESET);
#endif

	MCBSP_config(DSK6713_AIC23_DATAHANDLE,&AIC23CfgData);//interface 32 bits toAIC23

	MCBSP_start(DSK6713_AIC23_DATAHANDLE, MCBSP_XMIT_START | MCBSP_RCV_START |
		MCBSP_SRGR_START | MCBSP_SRGR_FRAMESYNC, 220);//start data channel again

	CODECEventId= MCBSP_getXmtEventId(DSK6713_AIC23_DATAHANDLE);//McBSP1 Xmit


	IRQ_map(CODECEventId, 5);			//map McBSP1 Xmit to INT5
	IRQ_reset(CODECEventId);    		//reset codec INT5
	IRQ_globalEnable();       			//globally enable interrupts
	IRQ_nmiEnable();          			//enable NMI interrupt
	IRQ_enable(CODECEventId);			//enable CODEC eventXmit INT5
	IRQ_set(CODECEventId);              //manually start the first interrupt


    while(1);                	        //infinite loop
}
 
