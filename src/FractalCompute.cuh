#ifndef COMPUTE_FRACTALS_CUDA_H
#define COMPUTE_FRACTALS_CUDA_H


#ifdef __CUDACC__
    #define CUDA_HOST __host__
#else
    #define CUDA_HOST
#endif


#include <iostream>
#include <stdlib.h>
#include "FractalColor.cuh"
#include "Formulas/FractalFormula.cuh"
#include "Image.cuh"

/*
* @param
*   @param image
*   @param rgbColorSpecturm
*   @param fractalFormula
*   @param zoom Zoom factor of fractal.
*   @param moveX X position of fractal.
*   @param moveY Y position of fractal.
*
* @returns
*   - Returns zero on success and non zero on failure.
*/
CUDA_HOST int DrawImage(
    Image *image,
    RGB_ColorSpectrum *rgbColorSpectrum, 
    IFractalFormula *fractalFormula,
    double zoom,
    double moveX,
    double moveY
);

template <typename Formula, typename ...Args>
CUDA_HOST int callDrawImage(
    Image *image,
    RGB_ColorSpectrum *rgbColorSpectrum,
    double zoom,
    double moveX,
    double moveY,
    Args... args
){

    IFractalFormula *formula = createFormula<Formula, Args...>(args...);

    return DrawImage(
        image,
        rgbColorSpectrum,
        formula,
        zoom,
        moveX,
        moveY
    );

}

#undef CUDA_HOST

#endif