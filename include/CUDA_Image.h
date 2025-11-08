#ifndef _CUDA_IMAGE_H
    
    #define _CUDA_IMAGE_H


    #include <stdlib.h>
    #include <stdarg.h>

    #include "CUDA_Color.h"

    
    #ifdef __cplusplus
        extern "C" {
    #endif


    typedef enum{
        Gradient,
        FracMandelbrot,
        FracJulia,
    } DrawTarget;

    
    /*
    * GPU_Image is a type which encapsulates a memory block on the GPU.
    */
    struct {
        size_t width;
        size_t height;
        size_t channels;
        unsigned char *imageDevice;
    } typedef GPU_Image; 
    
    
    /*
    * @param
    *   @param width Width of the image.
    *   @param height Height of the image.
    *   @param channels Number of channels of the image.
    * 
    * @returns
    *   - Returns zero on success and non zero on failure.
    */
    int InitGPU_Image(size_t width, size_t height, size_t channels, GPU_Image *gpuImage);

    
    /*
    * @param
    *   @param gpuImage initialized GPU image.
    */
    void DeinitGPU_Image(GPU_Image *gpuImage);


    /*
    *
    */
    int DrawImage(unsigned char *imageHost, size_t width, size_t height, size_t channels, GPU_Image *gpuImage, RGB_ColorSpectrum *rgbColorSpectrum, DrawTarget drawTarget, ...);

    #ifdef __cplusplus
        }
    #endif

#endif