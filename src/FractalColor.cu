#include "FractalColor.cuh"
#include <iostream>

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


__host__ __device__ RGB_Color InterpColorSpectrum(const RGB_ColorSpectrum *rgbColorSpectrum, double value, InterpolationKind interpolationKind, bool wrapAround){

    RGB_Color rgbColor;
    
    double startPoint   = 0.0;
    double endPoint     = rgbColorSpectrum->positionOfColors[rgbColorSpectrum->numberOfColors - 1];
    int startIndex      = 0;
    int endIndex        = rgbColorSpectrum->numberOfColors - 1;
    if (wrapAround){
        for (int i = 0; i < rgbColorSpectrum->numberOfColors; i++){
            if (rgbColorSpectrum->positionOfColors[i] > rgbColorSpectrum->positionOfColors[startIndex]){
                startIndex = i;
                startPoint = rgbColorSpectrum->positionOfColors[i];
            }

            if (rgbColorSpectrum->positionOfColors[i] < rgbColorSpectrum->positionOfColors[endIndex]){
                endIndex = i;
                endPoint = rgbColorSpectrum->positionOfColors[i];
            }
        }
    }
    else{
        for (int i = 0; i < rgbColorSpectrum->numberOfColors; i++){
            if (rgbColorSpectrum->positionOfColors[i] < rgbColorSpectrum->positionOfColors[startIndex]){
                startIndex = i;
            }

            if (rgbColorSpectrum->positionOfColors[i] > rgbColorSpectrum->positionOfColors[endIndex]){
                endIndex = i;
            }
        }
    }
    

    for (int i = 0; i < rgbColorSpectrum->numberOfColors; i++){
        if (rgbColorSpectrum->positionOfColors[i] <= value && 
            (rgbColorSpectrum->positionOfColors[i] >= startPoint || startPoint > value)) {
                startPoint = rgbColorSpectrum->positionOfColors[i];  
                startIndex = i;
            }
        if (rgbColorSpectrum->positionOfColors[i] >= value && 
            (rgbColorSpectrum->positionOfColors[i] <= endPoint || endPoint < value)) {
                endPoint = rgbColorSpectrum->positionOfColors[i]; 
                endIndex = i;
            } 
    }

    if (startPoint > endPoint && (value >= 0.0 && value <= endPoint || value <= 1.0 && value >= startPoint)){

        if (value <= endPoint){
            value = 1.0 - startPoint + value;
        } 
        else{
            value = value - startPoint;
        }

        endPoint = endPoint + 1.0 - startPoint;
        startPoint = 0.0;

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

    return rgbColor;
}