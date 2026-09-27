#ifndef _CUDA_IMAGE_H
#define _CUDA_IMAGE_H

#ifdef __CUDACC__
    #define CUDA_HOST_DEVICE __host__ __device__
#else
    #define CUDA_HOST_DEVICE
#endif

#include <stdlib.h>
#include <stdarg.h>

#include "FractalColor.cuh"

#define IMAGE_CHECK_INPUT(image, x, y) (x >= 0 && x < image.width && y >= 0 && y < image.height)
#define READ_IMAGE(image, x, y) (IMAGE_CHECK_INPUT(image, x, y) ? (image.data + x * image.channels + y * image.width * image.channels) : NULL)

/*
* Image is a type which encapsulates a memory block on the CPU or GPU.
*/
struct Image{
    size_t width;
    size_t height;
    size_t channels;
    unsigned char *data;
    
    Image(size_t width, size_t height, size_t channels, unsigned char *data):
        width(width), height(height), channels(channels), data(data){}
    
};

#undef CUDA_HOST_DEVICE

#endif