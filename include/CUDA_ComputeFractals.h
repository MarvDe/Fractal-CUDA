#ifndef COMPUTE_FRACTALS_CUDA_H

    #define COMPUTE_FRACTALS_CUDA_H

    
    #include <stdlib.h>
    #include "CUDA_Image.h"
    #include "CUDA_Color.h"

    #ifdef __cplusplus
        extern "C" {
    #endif
    

    /*
    * @param
    *   @param imageHost Byte array in which the fractal will be drawn.
    *   @param width Width of the image.
    *   @param height Height of the image.
    *   @param channels Number of channels of the image.
    *   @param zoom Zoom factor of fractal.
    *   @param moveX X position of fractal.
    *   @param moveY Y position of fractal.
    *   @param maxIterations Maximum number of iterations.
    *   @param gpuImage If a valid GPU_Image is passed to the function it will not allocate memory on the GPU.
    *                   Instead it uses already allocated memory of GPU_Image to draw the fractal.
    *   @param rgbColorSpectrum 
    *
    * @returns
    *   - Returns zero on success and non zero on failure.
    */
    int DrawFractalImage(unsigned char *imageHost ,size_t width, size_t height, size_t channels, double zoom, double moveX, double moveY, int maxIterations, GPU_Image *gpuImage, RGB_ColorSpectrum *rgbColorSpectrum);
    
    
    #ifdef __cplusplus
        }
    #endif

#endif