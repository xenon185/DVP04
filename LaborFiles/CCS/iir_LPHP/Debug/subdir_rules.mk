################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Each subdirectory must supply rules for building sources it contributes
DSK_vectors_AIC23.obj: ../DSK_vectors_AIC23.ASM $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000_7.4.21/bin/cl6x" -mv6710 --abi=coffabi -g --include_path="C:/ti/ccsv5/tools/compiler/c6000_7.4.21/include" --define=CHIP_6713 --display_error_number --diag_warning=225 --diag_wrap=off --mem_model:data=far --preproc_with_compile --preproc_dependency="DSK_vectors_AIC23.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

biquad.obj: ../biquad.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000_7.4.21/bin/cl6x" -mv6710 --abi=coffabi -g --include_path="C:/ti/ccsv5/tools/compiler/c6000_7.4.21/include" --define=CHIP_6713 --display_error_number --diag_warning=225 --diag_wrap=off --mem_model:data=far --preproc_with_compile --preproc_dependency="biquad.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '

get_started.obj: ../get_started.c $(GEN_OPTS) $(GEN_HDRS)
	@echo 'Building file: $<'
	@echo 'Invoking: C6000 Compiler'
	"C:/ti/ccsv5/tools/compiler/c6000_7.4.21/bin/cl6x" -mv6710 --abi=coffabi -g --include_path="C:/ti/ccsv5/tools/compiler/c6000_7.4.21/include" --define=CHIP_6713 --display_error_number --diag_warning=225 --diag_wrap=off --mem_model:data=far --preproc_with_compile --preproc_dependency="get_started.pp" $(GEN_OPTS__FLAG) "$<"
	@echo 'Finished building: $<'
	@echo ' '


