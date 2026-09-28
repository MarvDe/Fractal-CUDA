#include "FractalCompute.cuh"
#include "Formulas/FractalFormula.cuh"
#include <stdio.h>
#include <cuda.h>

__device__ void ApplyColor(unsigned char *pixel, size_t channels, double value, const RGB_ColorSpectrum *rgbColorSpectrum){

    // clip value to [0,1]
    value = max(0.0, min(1.0, value));

    RGB_Color rgbColor = InterpColorSpectrum(rgbColorSpectrum, value);

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

/*
* @param
*   @param image
*   @param fractalFormula
*   @param rgbColorSpecturm
*   @param zoom Zoom factor of fractal.
*   @param moveX X position of fractal.
*   @param moveY Y position of fractal.
*   @param colorSpectrum
*
* @returns
*   - Returns zero on success and non zero on failure.
*/
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


FractalCompute::FractalCompute(int width, int height, int channels){
    unsigned char *data = new unsigned char[width * height * channels];
    image = new Image(width, height, channels, data);
    
    spectrum = new RGB_ColorSpectrum();
    spectrum->numberOfColors = 2;
    spectrum->positionOfColors[0] = 0.0;
    spectrum->positionOfColors[0] = 1.0;
    spectrum->rgbColors[0] = RGB_Color{
        static_cast<unsigned char>(0), 
        static_cast<unsigned char>(0),
        static_cast<unsigned char>(0)
    };
    spectrum->rgbColors[0] = RGB_Color{
        static_cast<unsigned char>(255),
        static_cast<unsigned char>(255),
        static_cast<unsigned char>(255)
    };
    updateDeviceSpectrum = true;

    Image hostImage = {width, height, channels, NULL};
    if (cudaMalloc(&deviceData, image->width * image->height * image->channels * sizeof(unsigned char)) != cudaError::cudaSuccess){
        isError = true; 
        return;
    }
    hostImage.data = deviceData;
    if (cudaMalloc(&deviceImage, sizeof(Image)) != cudaError::cudaSuccess || 
        cudaMemcpy(deviceImage, &hostImage, sizeof(Image), cudaMemcpyHostToDevice) != cudaError::cudaSuccess){
        isError = true;
        return;
    }

    if (cudaMalloc(&deviceSpectrum, sizeof(RGB_ColorSpectrum)) != cudaError::cudaSuccess) {
        isError = true;
        return;
    }

    setFractalFormula(Mandelbrot());

}
FractalCompute::~FractalCompute(){

    delete image->data;
    delete image;
    delete spectrum;
    destroyFormula(deviceFractalFormula);
    cudaFree(deviceSpectrum);
    cudaFree(deviceImage);
    cudaFree(deviceData);
}

void FractalCompute::calculate(double zoom, double posX, double posY){
    
    int returnCode = 0;
    int blockSize = 256;
    int gridSize = (image->width * image->height + blockSize - 1) / blockSize;

    if (updateDeviceSpectrum){
        if (cudaMemcpy(deviceSpectrum, spectrum, sizeof(RGB_ColorSpectrum), cudaMemcpyHostToDevice) != cudaError::cudaSuccess) {
            isError = true;
            return;
        }
        updateDeviceSpectrum = false;
    }

    std::cout << "Starting Kernel, zoom: " << zoom << " x: " << posX << " y: " << posY << std::endl;

    DrawFractal <<< gridSize, blockSize >>> (
        deviceImage,
        deviceFractalFormula,
        zoom,
        posX, 
        posY, 
        deviceSpectrum);

    cudaDeviceSynchronize();
    
    updateHostImage = true;
    std::cout << "Error state: " << isError << std::endl;
}

Image *FractalCompute::getImage(){

    if (updateHostImage){
        if (cudaMemcpy(image->data, deviceData, image->width * image->height * image->channels, cudaMemcpyDeviceToHost) != cudaError::cudaSuccess)  {
            isError = true;
            return NULL;   
        }
        updateHostImage = false;
    }

    return image;
}

void FractalCompute::setSpectrum(const RGB_ColorSpectrum &i_specturm){
    spectrum->interpolationKind = i_specturm.interpolationKind;
    spectrum->numberOfColors = i_specturm.numberOfColors;
    spectrum->wrapAround = i_specturm.wrapAround;
    for (int i = 0; i < i_specturm.numberOfColors; i++){

        spectrum->positionOfColors[i] = i_specturm.positionOfColors[i];
        spectrum->rgbColors[i].red = i_specturm.rgbColors[i].red;
        spectrum->rgbColors[i].green = i_specturm.rgbColors[i].green;
        spectrum->rgbColors[i].blue = i_specturm.rgbColors[i].blue;

    }
    updateDeviceSpectrum = true;
}

RGB_ColorSpectrum *FractalCompute::getSpectrum(){
    return spectrum;
}

void FractalCompute::setFractalFormula(const IFractalFormula &i_formula){

    switch (i_formula.getType())
    {
    case FRACTAL_TYPES::MANDELBROT:
        deviceFractalFormula = createFormula<Mandelbrot>();
        break;
    case FRACTAL_TYPES::JULIA:
        deviceFractalFormula = createFormula<Julia>();
        break;
    default:
        std::cout << "Formula Not Implemented" << std::endl;
        break;
    }

}