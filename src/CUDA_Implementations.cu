#include <cuda.h>
#include <cuComplex.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdarg.h>

#include "CUDA_ComputeFractals.h"
#include "CUDA_Color.h"
#include "CUDA_Image.h"

#define Max(a,b)  ((a)>(b)) ? (a):(b)

/*
*                       CUDA COLOR IMPLEMENTATIONS
*/


int InitRGB_ColorSpectrum(size_t numberOfColors, RGB_Color *rgbColors, double *positionOfColors, RGB_ColorSpectrum *rgbColorSpectrum){

    if (rgbColorSpectrum == NULL || numberOfColors >= MAX_COLORS_IN_COLORSPECTRUM) return -1;

    rgbColorSpectrum->numberOfColors = numberOfColors;

    memcpy(rgbColorSpectrum->positionOfColors, positionOfColors, numberOfColors * sizeof(double));
    memcpy(rgbColorSpectrum->rgbColors, rgbColors, numberOfColors * sizeof(RGB_Color));

    return 0;

}


int InitRGB_ColorSpectrumBlackWhite(RGB_ColorSpectrum *rgbColorSpectrum){

    RGB_Color black = {0, 0, 0};
    RGB_Color white = {255, 255, 255};
    RGB_Color rgbColors[2] = {black, white};
    double positionOfColors[2] = {0, 1};
    InitRGB_ColorSpectrum(2, rgbColors, positionOfColors, rgbColorSpectrum);
    return 0;

} 


void DeinitRGB_ColorSpectrum(RGB_ColorSpectrum *rgbColorSpectrum){

    if (rgbColorSpectrum == NULL) return;
    
    return;

}


template <typename T>
__host__ __device__ T LinearInterpValue(T startPoint, T endPoint, 
                                        T startValue, T endValue, T variable){
                        
    return startValue + (variable - startPoint) * ((endValue - startValue) / (endPoint - startPoint));

}


template <typename T>
__host__ __device__ T CubicInterpValue(T startPoint, T endPoint, 
                                       T startValue, T endValue, T variable){

    T g0 = (endValue - startValue) / ((endPoint - startPoint) * 
                                      (endPoint - startPoint));
    T g1 = (2 * (startValue - endValue)) / ((endPoint - startPoint) * 
                                            (endPoint - startPoint) * 
                                            (endPoint - startPoint));
                                            
    return startValue + g0 * (variable - startPoint) * (variable - startPoint) + 
                        g1 * (variable - startPoint) * (variable - startPoint) * (variable - endPoint);

}


__host__ __device__ RGB_Color InterpColorSpectrum(const RGB_ColorSpectrum *rgbColorSpectrum, double value, InterpolationKind interpolationKind){

    RGB_Color rgbColor;
    
    double startPoint   = 0;
    double endPoint     = 1;
    int startIndex      = 0;
    int endIndex        = rgbColorSpectrum->numberOfColors - 1;

    for (int i = 0; i < rgbColorSpectrum->numberOfColors; i++){
        if (rgbColorSpectrum->positionOfColors[i] <= value && 
            rgbColorSpectrum->positionOfColors[i] >= startPoint) {
                startPoint = rgbColorSpectrum->positionOfColors[i];  
                startIndex = i;
            }
        if (rgbColorSpectrum->positionOfColors[i] >= value && 
            rgbColorSpectrum->positionOfColors[i] <= endPoint) {
                endPoint = rgbColorSpectrum->positionOfColors[i]; 
                endIndex = i;
            } 
    }

    double startRed      = (double) rgbColorSpectrum->rgbColors[startIndex].red;
    double startGreen    = (double) rgbColorSpectrum->rgbColors[startIndex].green;
    double startBlue     = (double) rgbColorSpectrum->rgbColors[startIndex].blue;

    double endRed        = (double) rgbColorSpectrum->rgbColors[endIndex].red;
    double endGreen      = (double) rgbColorSpectrum->rgbColors[endIndex].green;
    double endBlue       = (double) rgbColorSpectrum->rgbColors[endIndex].blue;

    if (startIndex == endIndex) {
        rgbColor.red    = (unsigned char) startRed;
        rgbColor.green  = (unsigned char) startGreen;
        rgbColor.blue   = (unsigned char) startBlue;
    } 
    else {
        switch (interpolationKind)
        {
        case InterpolationKind::LinearInterp:
            
            rgbColor.red    = (unsigned char) LinearInterpValue<double>(
                startPoint, endPoint, 
                startRed, endRed, value);
            
            rgbColor.green  = (unsigned char) LinearInterpValue<double>(
                startPoint, endPoint, 
                startGreen, endGreen, value);
            
            rgbColor.blue   = (unsigned char) LinearInterpValue<double>(
                startPoint, endPoint, 
                startBlue, endBlue, value);
            
            break;
        
        case InterpolationKind::CubicInterp:
            
            rgbColor.red    = (unsigned char) CubicInterpValue<double>(
                startPoint, endPoint, 
                startRed, endRed, value);
            
            rgbColor.green  = (unsigned char) CubicInterpValue<double>(
                startPoint, endPoint, 
                startGreen, endGreen, value);
            
            rgbColor.blue   = (unsigned char) CubicInterpValue<double>(
                startPoint, endPoint, 
                startBlue, endBlue, value);

            break;
            
        default:
            break;
        }
    }

    //printf("Start: %d, End: %d, Value: %lf, Red: %d, Green: %d, Blue: %d\n", startIndex, endIndex, value, rgbColor.red, rgbColor.green, rgbColor.blue);

    return rgbColor;

}


/*
*                       CUDA IMAGE IMPLEMENTATIONS
*/


int InitGPU_Image(size_t width, size_t height, size_t channels, GPU_Image *gpuImage){

    if (gpuImage == NULL) return -1;

    if (cudaMalloc(&gpuImage->imageDevice, width * height * channels) != CUDA_SUCCESS)    return 1;

    gpuImage->width     = width;
    gpuImage->height    = height;
    gpuImage->channels  = channels;

    return 0;

}


void DeinitGPU_Image(GPU_Image *gpuImage){

    if (gpuImage == NULL) return;

    cudaFree(gpuImage->imageDevice);

    gpuImage->imageDevice = NULL;
    gpuImage->width     = 0;
    gpuImage->height    = 0;
    gpuImage->channels  = 0;

    return;

}


/*
*                       CUDA COMPUTE_FRACTALS IMPLEMENTATIONS
*/


/*
* @returns 
*  - z^2 + c
*/
__device__ cuDoubleComplex CalculateMandelbrot(const cuDoubleComplex &z, const cuDoubleComplex &c){
    return cuCadd( cuCmul(z, z), c);
}


__device__ void ApplyColor(unsigned char *pixel, size_t channels, int value, int maxValue, const RGB_ColorSpectrum *rgbColorSpectrum){

    double valueNormalized = (double) value / (double) maxValue;
    RGB_Color rgbColor = InterpColorSpectrum(rgbColorSpectrum, valueNormalized, LinearInterp);

    switch (channels)
    {
    case 1:
        
        pixel[0] = (rgbColor.red + rgbColor.green + rgbColor.blue) / 3;

        break;
    case 2:

        pixel[0] = (rgbColor.red + rgbColor.green + rgbColor.blue) / 3;
        pixel[1] = 255;
        
        break;
    case 3:
        
        pixel[0] = rgbColor.red;
        pixel[1] = rgbColor.green;
        pixel[2] = rgbColor.blue;
        
        break;
    case 4:
        
        pixel[0] = rgbColor.red;
        pixel[1] = rgbColor.green;
        pixel[2] = rgbColor.blue;
        pixel[3] = 255;

        break;
    default:
        break;
    }

}


__global__ void DrawFractal(unsigned char *image, size_t width, size_t height, size_t channels, double zoom, double moveX, double moveY, int maxIterations, const RGB_ColorSpectrum *rgbColorSpectrum){

    int uniqueId = threadIdx.x + blockIdx.x * blockDim.x;

    if (uniqueId < width * height){

        int row =       uniqueId / (int) width;
        int column =    uniqueId % (int) width;

        cuDoubleComplex c = {
            ((double) column - moveX - (double) width / 2) / zoom, 
            ((double) row - moveY - (double) height / 2) / zoom};
        cuDoubleComplex z = {0.0, 0.0};

        int i = 0;
        while (i < maxIterations)
        {
            z = CalculateMandelbrot(z, c);

            if (cuCabs(z) > 2) break;

            i++;
        }

        ApplyColor(image + (row * (int) width + column) * channels, channels, i, maxIterations, rgbColorSpectrum);

    }

}


__global__ void DrawGradient(unsigned char *image, size_t width, size_t height, size_t channels, const RGB_ColorSpectrum *rgbColorSpectrum){

    int uniqueId = threadIdx.x + blockIdx.x * blockDim.x;

    if (uniqueId < width * height){

        int row =       uniqueId / (int) width;
        int column =    uniqueId % (int) width;

        ApplyColor(image + (row * (int) width + column) * channels, channels, column, width - 1, rgbColorSpectrum);
        
    }

}


__host__ int DrawImage(unsigned char *HostImage, size_t width, size_t height, size_t channels, GPU_Image *gpuImage, RGB_ColorSpectrum *rgbColorSpectrum, DrawTarget drawTarget, ...){

    int blockSize = 256;
    int gridSize = (width * height + blockSize - 1) / blockSize;

    bool useGPU_Image = 
        gpuImage != NULL && 
        width <= gpuImage->width && 
        height <= gpuImage->height && 
        gpuImage->channels == channels;

    bool useRGB_ColorSpectrum =
        rgbColorSpectrum != NULL &&
        rgbColorSpectrum->rgbColors != NULL &&
        rgbColorSpectrum->numberOfColors > 0;

    // initialize memory for device image
    unsigned char *DeviceImage;
    if (useGPU_Image){
        DeviceImage = gpuImage->imageDevice;
    }
    else{
        if (cudaMalloc(&DeviceImage, width * height * channels) != CUDA_SUCCESS)    return 1;
    }
    
    // initialize color spectrum
    RGB_ColorSpectrum *HostRgbColorSpectrum;
    RGB_ColorSpectrum *DeviceRgbColorSpectrum;
    
    if (cudaMalloc(&DeviceRgbColorSpectrum, sizeof(RGB_ColorSpectrum)) != CUDA_SUCCESS) return 1;

    if (useRGB_ColorSpectrum){

        HostRgbColorSpectrum = rgbColorSpectrum;

    }
    else{
        
        HostRgbColorSpectrum = (RGB_ColorSpectrum *) malloc(sizeof(RGB_ColorSpectrum));
        InitRGB_ColorSpectrumBlackWhite(HostRgbColorSpectrum);
        
    }

    if (cudaMemcpy(DeviceRgbColorSpectrum, HostRgbColorSpectrum, sizeof(RGB_ColorSpectrum), cudaMemcpyHostToDevice) != CUDA_SUCCESS) return 1;

    // Call kernel function
    switch (drawTarget)
    {
    case DrawTarget::Gradient:{
        DrawGradient <<< gridSize, blockSize >>> (DeviceImage, width, height, channels, DeviceRgbColorSpectrum);
        break;
    }
    case DrawTarget::FracMandelbrot:{
        va_list args;
        
        va_start(args, drawTarget);
        double zoom     = va_arg(args, double);
        double moveX    = va_arg(args, double);
        double moveY    = va_arg(args, double);
        unsigned int maxIterations = va_arg(args, unsigned int);
        printf("Zoom: %lf, MoveX: %lf, MoveY: %lf, Maxiterations: %d\n", zoom, moveX, moveY, maxIterations);
        va_end(args);

        DrawFractal <<< gridSize, blockSize >>> (DeviceImage, width, height, channels, 
                                                 zoom, moveX, moveY, maxIterations, DeviceRgbColorSpectrum);

        break;
    }
    case DrawTarget::FracJulia:{
        va_list args;
        
        va_start(args, drawTarget);
        double zoom     = va_arg(args, double);
        double moveX    = va_arg(args, double);
        double moveY    = va_arg(args, double);
        unsigned int maxIterations = va_arg(args, unsigned int);
        printf("Zoom: %lf, MoveX: %lf, MoveY: %lf, Maxiterations: %d\n", zoom, moveX, moveY, maxIterations);
        va_end(args);

        DrawFractal <<< gridSize, blockSize >>> (DeviceImage, width, height, channels, 
                                                 zoom, moveX, moveY, maxIterations, DeviceRgbColorSpectrum);    


        break;
    }
    default:{
        break;
    }
        
    }

    cudaDeviceSynchronize();

    // Copy device image data to host image
    if (cudaMemcpy(HostImage, DeviceImage, width * height * channels, cudaMemcpyDeviceToHost) != CUDA_SUCCESS)  {
        cudaError_t error = cudaGetLastError();
        const char *errStr = cudaGetErrorString(error); 
        printf("Error: %s\n", errStr);
        cudaFree(DeviceImage);
        return 2;
    }
    
    // Clean up
    if (!useGPU_Image){
        if (cudaFree(DeviceImage) != CUDA_SUCCESS)  return 3;
    }

    if (!useRGB_ColorSpectrum){
        DeinitRGB_ColorSpectrum(HostRgbColorSpectrum);
        free(HostRgbColorSpectrum);
    }

    cudaFree(DeviceRgbColorSpectrum);

    return 0;

}

__host__ int DrawFractalImage(unsigned char *imageHost, size_t width, size_t height, size_t channels, 
                              double zoom, double moveX, double moveY, int maxIterations, 
                              GPU_Image *gpuImage = NULL, RGB_ColorSpectrum *rgbColorSpectrum = NULL){

    int blockSize = 256;
    int gridSize = (width * height + blockSize - 1) / blockSize;

    bool useGPU_Image = 
        gpuImage != NULL && 
        width <= gpuImage->width && 
        height <= gpuImage->height && 
        gpuImage->channels == channels;

    bool useRGB_ColorSpectrum =
        rgbColorSpectrum != NULL &&
        rgbColorSpectrum->rgbColors != NULL &&
        rgbColorSpectrum->numberOfColors > 0;

    unsigned char *imageDevice;
    if (useGPU_Image){
        imageDevice = gpuImage->imageDevice;
    }
    else{
        if (cudaMalloc(&imageDevice, width * height * channels) != CUDA_SUCCESS)    return 1;
    }


    RGB_ColorSpectrum *h_rgbColorSpectrum;
    RGB_ColorSpectrum *d_rgbColorSpectrum;
    
    if (cudaMalloc(&d_rgbColorSpectrum, sizeof(RGB_ColorSpectrum)) != CUDA_SUCCESS) return 1;

    if (useRGB_ColorSpectrum){

        h_rgbColorSpectrum = rgbColorSpectrum;

    }
    else{
        
        h_rgbColorSpectrum = (RGB_ColorSpectrum *) malloc(sizeof(RGB_ColorSpectrum));
        InitRGB_ColorSpectrumBlackWhite(h_rgbColorSpectrum);
        
    }

    if (cudaMemcpy(d_rgbColorSpectrum, h_rgbColorSpectrum, sizeof(RGB_ColorSpectrum), cudaMemcpyHostToDevice) != CUDA_SUCCESS) return 1;
    printf("Process Start\n");
    DrawFractal <<< gridSize, blockSize >>> (imageDevice, width, height, channels, zoom, moveX, moveY, maxIterations, d_rgbColorSpectrum);
    printf("Process End\n");
    cudaDeviceSynchronize();
    if (cudaMemcpy(imageHost, imageDevice, width * height * channels, cudaMemcpyDeviceToHost) != CUDA_SUCCESS)  {
        cudaFree(imageDevice);
        return 2;
    }
    
    if (!useGPU_Image){
        if (cudaFree(imageDevice) != CUDA_SUCCESS)  return 3;
    }

    if (!useRGB_ColorSpectrum){
        DeinitRGB_ColorSpectrum(h_rgbColorSpectrum);
    }

    cudaFree(d_rgbColorSpectrum);

    return 0;
}