#ifndef FRACTAL_JULIA_CUH
#define FRACTAL_JULIA_CUH

#include "IFractalFormula.cuh"

#ifdef __CUDACC__
    #define CUDA_HOST_DEVICE __host__ __device__
#else
    #define CUDA_HOST_DEVICE
#endif

class Julia: public IFractalFormula{

    private:
        int iterations = 100;
        double cx = 0.0;
        double cy = 0.0;

    public:
        CUDA_HOST_DEVICE Julia(double cx, double cy);
        CUDA_HOST_DEVICE virtual double calculate(double x, double y) const override;

};

#undef CUDA_HOST_DEVICE

#endif 