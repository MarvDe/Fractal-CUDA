#ifndef IFRACTAL_FORMULA_H
#define IFRACTAL_FORMULA_H

#ifdef __CUDACC__
    #define CUDA_HOST_DEVICE __host__ __device__
#else
    #define CUDA_HOST_DEVICE
#endif

#include <string>
#include <stdexcept>

enum FRACTAL_TYPES{
    MANDELBROT,
    JULIA
};

class IFractalFormula{
 
    public:
        CUDA_HOST_DEVICE virtual double calculate(double x, double y) const = 0;
        CUDA_HOST_DEVICE virtual FRACTAL_TYPES getType() const = 0;
        CUDA_HOST_DEVICE virtual ~IFractalFormula() = default;

};

#undef CUDA_HOST_DEVICE

#endif