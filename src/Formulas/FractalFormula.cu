#include "FractalFormula.cuh"

__global__ void _destroyFormula(IFractalFormula *fractalFormula){
    delete fractalFormula;
}

void destroyFormula(IFractalFormula *fractalFormula){
    
    _destroyFormula<<<1, 1>>>(fractalFormula);

    cudaError_t error = cudaDeviceSynchronize();
    if (error != cudaSuccess) {
        throw std::runtime_error(
            std::string("Destroy formula error: ") +
            cudaGetErrorString(error)
        );
    }
}