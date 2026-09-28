#ifndef FRACTAL_MANDELBROT_CUH
#define FRACTAL_MANDELBROT_CUH

#include "IFractalFormula.cuh"

#ifdef __CUDACC__
    #define CUDA_HOST_DEVICE __host__ __device__
#else
    #define CUDA_HOST_DEVICE
#endif

class Mandelbrot: public IFractalFormula{

    private:
        int iterations = 100;

    public:
        CUDA_HOST_DEVICE Mandelbrot();
        CUDA_HOST_DEVICE virtual FRACTAL_TYPES getType() const override;
        CUDA_HOST_DEVICE virtual double calculate(double x, double y) const override;

};

#undef CUDA_HOST_DEVICE

#endif 