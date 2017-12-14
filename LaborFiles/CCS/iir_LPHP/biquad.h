#ifndef BIQUAD_H_
#define BIQUAD_H_



void biquad(int16_t* b,int16_t* a,int32_t W[],int16_t x,int16_t* y);
void biquad_2T(int16_t* b,int16_t* a,int32_t W[],int16_t x,int16_t* y);

#endif /* BIQUAD_H_ */
