#ifndef COMPUTE_FRACTALS_CUDA_H
#define COMPUTE_FRACTALS_CUDA_H

#include <iostream>
#include <stdlib.h>
#include "IFractalCompute.h"
#include "FractalColor.cuh"
#include "Formulas/FractalFormula.cuh"
#include "Formulas/Mandelbrot.cuh"
#include "Formulas/Julia.cuh"
#include "Image.cuh"

class FractalCompute: public IFractalCompute{

    private:
        Image *image;
        Image *deviceImage;
        unsigned char *deviceData;
        bool isError = false;
        bool updateHostImage = false; 
        RGB_ColorSpectrum *spectrum;
        RGB_ColorSpectrum *deviceSpectrum;
        bool updateDeviceSpectrum = false;
        IFractalFormula *deviceFractalFormula;

    public:
        FractalCompute(int width, int height, int channels = 3);
        ~FractalCompute();

        void calculate(double zoom, double posX, double posY);

        Image *getImage();

        void setSpectrum(const RGB_ColorSpectrum &i_specturm);

        RGB_ColorSpectrum *getSpectrum();

        void setFractalFormula(const IFractalFormula &formula);

};

#endif