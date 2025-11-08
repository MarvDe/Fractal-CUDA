#ifndef CUDA_COLOR_H

    #define CUDA_COLOR_H

    
    #include <stdlib.h>

    #ifdef __cplusplus
        extern "C" {
    #endif
    
    #ifdef __CUDACC__
        #define HD __host__ __device__
    #else
        #define HD
    #endif

    #define MAX_COLORS_IN_COLORSPECTRUM 16

    typedef enum{
        LinearInterp,
        CubicInterp
    } InterpolationKind;


    /*
    * A simple rgb color structure.
    */
    struct {
        unsigned char red;
        unsigned char green;
        unsigned char blue;
    } typedef RGB_Color;


    /*
    * RGB_ColorSpectrum is a type which.
    */
    struct {
        size_t numberOfColors;
        RGB_Color rgbColors[MAX_COLORS_IN_COLORSPECTRUM];
        double positionOfColors[MAX_COLORS_IN_COLORSPECTRUM];
    } typedef RGB_ColorSpectrum;

    
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
    inline HD RGB_Color InterpColorSpectrum(const RGB_ColorSpectrum *rgbColorSpectrum, double value, InterpolationKind interpolationKind);
    
    #ifdef __cplusplus
        }
    #endif

#endif