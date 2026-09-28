#ifndef ICOMPUTE_FRACTALS_CUDA_H
#define ICOMPUTE_FRACTALS_CUDA_H


#include "Formulas/IFractalFormula.cuh"
#include "FractalColor.cuh"
#include "Image.cuh"


class IFractalCompute{

    public:
        virtual ~IFractalCompute() = default;

        virtual void calculate(double zoom, double posX, double posY) = 0;
        virtual Image *getImage() = 0;
        virtual void setSpectrum(const RGB_ColorSpectrum &i_specturm) = 0;
        virtual RGB_ColorSpectrum *getSpectrum() = 0;
        virtual void setFractalFormula(const IFractalFormula& formula) = 0;

};

#endif