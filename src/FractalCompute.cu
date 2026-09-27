#include "FractalCompute.cuh"
#include "Formulas/FractalFormula.cuh"
#include <stdio.h>
#include <cuda.h>

__device__ void ApplyColor(unsigned char *pixel, size_t channels, double value, const RGB_ColorSpectrum *rgbColorSpectrum){

    // clip value to [0,1]
    value = max(0.0, min(1.0, value));

    RGB_Color rgbColor = InterpColorSpectrum(rgbColorSpectrum, value, LinearInterp);

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


__global__ void DrawFractal(
    Image *image, 
    IFractalFormula *fractalFormula,
    double zoom, 
    double moveX, 
    double moveY, 
    const RGB_ColorSpectrum *rgbColorSpectrum){

    int uniqueId = threadIdx.x + blockIdx.x * blockDim.x;

    if (uniqueId < image->width * image->height){

        int row =       uniqueId / (int) image->width;
        int column =    uniqueId % (int) image->width;

        double value = fractalFormula->calculate(
            ((double) column - (double) image->width / 2.0) / zoom - moveX, 
            ((double) row - (double) image->height / 2.0) / zoom - moveY
        );

        ApplyColor(
            image->data + (row * (int) image->width + column) * image->channels, 
            image->channels, value, rgbColorSpectrum
        );

    }

}

__host__ int DrawImage(
    Image *image,
    RGB_ColorSpectrum *rgbColorSpectrum, 
    IFractalFormula *deviceFractalFormula,
    double zoom,
    double moveX,
    double moveY){
    
    int returnCode = 0;

    int blockSize = 256;
    int gridSize = (image->width * image->height + blockSize - 1) / blockSize;
    
    unsigned char *deviceData = nullptr;
    Image hostImage = {image->width, image->height, image->channels, NULL};
    RGB_ColorSpectrum *deviceRgbColorSpectrum = nullptr;
     Image *deviceImage = nullptr;

    // initialize color spectrum
    if (cudaMalloc(&deviceData, image->width * image->height * image->channels * sizeof(unsigned char)) != cudaError::cudaSuccess){
        returnCode = 1;
        goto FreeData;
    }

    hostImage.data = deviceData;
   
    if (cudaMalloc(&deviceImage, sizeof(Image)) != cudaError::cudaSuccess || 
        cudaMemcpy(deviceImage, &hostImage, sizeof(Image), cudaMemcpyHostToDevice) != cudaError::cudaSuccess){
        returnCode = 1;
        goto FreeImage;
    }

    if (cudaMalloc(&deviceRgbColorSpectrum, sizeof(RGB_ColorSpectrum)) != cudaError::cudaSuccess ||
        cudaMemcpy(deviceRgbColorSpectrum, rgbColorSpectrum, sizeof(RGB_ColorSpectrum), cudaMemcpyHostToDevice) != cudaError::cudaSuccess) {
        returnCode = 1;
        goto FreeSpectrum;
    }

    std::cout << "starting kernel" << std::endl;

    // Call kernel function
    DrawFractal <<< gridSize, blockSize >>> (
        deviceImage,
        deviceFractalFormula,
        zoom,
        moveX, 
        moveY, 
        deviceRgbColorSpectrum);

    
    cudaDeviceSynchronize();
    
    std::cout << "finished kernel" << std::endl;

    // Copy device image data to host image
    if (cudaMemcpy(image->data, deviceData, image->width * image->height * image->channels, cudaMemcpyDeviceToHost) != cudaError::cudaSuccess)  {
        returnCode = 1;   
    }

    FreeSpectrum:
    cudaFree(deviceRgbColorSpectrum);
    FreeImage:
    cudaFree(deviceImage);
    FreeData:
    cudaFree(deviceData);

    return returnCode;
}