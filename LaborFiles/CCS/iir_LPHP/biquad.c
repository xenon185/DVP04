/*
 * biquad.c
 *
 *  Created on: 11.12.2017
 *      Author: ddp
 */

#include <stdio.h>
#include <stdint.h>
#include "biquad.h"

void biquad(int16_t* b,int16_t* a,int32_t W[],int16_t x,int16_t* y)
{
	(*y)=(int16_t)(((b[0]*x)+W[0])>>15);

	W[0]=b[1]*(x)+(*y)*(-a[0])+W[1];
	W[1]=b[2]*(x)+(*y)*(-a[1]);
}

void biquad_2T(int16_t* b,int16_t* a,int32_t W[],int16_t x,int16_t* y)
{
	(*y)=(int16_t)(((b[0]*x)+W[0])>>15);

	W[0]=W[1];
	W[1]=b[1]*(x)+(*y)*(-a[0])+W[2];
	W[2]=W[3];
	W[3]=b[2]*(x)+(*y)*(-a[1]);
}


