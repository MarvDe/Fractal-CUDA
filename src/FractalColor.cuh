#ifndef CUDA_COLOR_H
#define CUDA_COLOR_H

#include <stdlib.h>

#ifdef __CUDACC__
    #define CUDA_HOST_DEVICE __host__ __device__
#else
    #define CUDA_HOST_DEVICE
#endif

#define MAX_COLORS_IN_COLORSPECTRUM 16

CUDA_HOST_DEVICE enum InterpolationKind{
    LinearInterp,
    CubicInterp
};


/*
* A simple rgb color structure.
*/
CUDA_HOST_DEVICE struct {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
} typedef RGB_Color;


/*
* RGB_ColorSpectrum is a type which.
*/
CUDA_HOST_DEVICE struct RGB_ColorSpectrum{
    RGB_ColorSpectrum() : numberOfColors(0) {}
    RGB_ColorSpectrum(size_t numberOfColors, RGB_Color *rgbColors, double *positionOfColors) : 
        numberOfColors(numberOfColors)
    {  
        for (int i = 0; i < numberOfColors; i++){
            this->rgbColors[i].red = rgbColors[i].red;
            this->rgbColors[i].green = rgbColors[i].green;
            this->rgbColors[i].blue = rgbColors[i].blue;

            this->positionOfColors[i] = positionOfColors[i]; 
        }
    }
    size_t numberOfColors;
    RGB_Color rgbColors[MAX_COLORS_IN_COLORSPECTRUM];
    double positionOfColors[MAX_COLORS_IN_COLORSPECTRUM];
};


/*
* @param 
*   @param numberOfColors Number of colors inside the rbgColors array.
*   @param rgbColors Array of colors.
*   @param positionOfColors Array of 
*/
int InitRGB_ColorSpectrum(size_t numberOfColors, RGB_Color *rgbColors, double *positionOfColors, RGB_ColorSpectrum *rgbColorSpectrum);


/*
* @param
*   @param rgbColorSpectrum A initialized RGB_ColorSpectrum.
* 
* @note
*   - Do not use rgbColorSpectrum after calling this function
*/
void DeinitRGB_ColorSpectrum(RGB_ColorSpectrum *rgbColorSpectrum);


/*
* @param 
*   @param rgbColorSpectrum
*   @param value 
*   @param interpolationType
*
* @returns
*   - Returns the interpolated color of the color spectrum.
*/
CUDA_HOST_DEVICE RGB_Color InterpColorSpectrum(const RGB_ColorSpectrum *rgbColorSpectrum, double value, InterpolationKind interpolationKind, bool wrapAround = false);

#undef CUDA_HOST_DEVICE

#endif