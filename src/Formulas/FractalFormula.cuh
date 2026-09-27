#ifndef FRACTAL_FORMULA_H
#define FRACTAL_FORMULA_H

#include "IFractalFormula.cuh"

template <typename T, typename ...Args>
__global__ void _createFormula(IFractalFormula **fractalFormula, Args... args){
    *fractalFormula = new T(args...);
}

template <typename T, typename... Args>
IFractalFormula* createFormula(Args... args)
{
    IFractalFormula** deviceFormula = nullptr;

    cudaError_t error = cudaMalloc(
        &deviceFormula,
        sizeof(IFractalFormula*)
    );

    if (error != cudaSuccess) {
        throw std::runtime_error(
            std::string("Formula pointer allocation error: ") +
            cudaGetErrorString(error)
        );
    }

    _createFormula<T><<<1, 1>>>(deviceFormula, args...);

    error = cudaGetLastError();
    if (error != cudaSuccess) {
        cudaFree(deviceFormula);

        throw std::runtime_error(
            std::string("Create formula launch error: ") +
            cudaGetErrorString(error)
        );
    }

    error = cudaDeviceSynchronize();
    if (error != cudaSuccess) {
        cudaFree(deviceFormula);

        throw std::runtime_error(
            std::string("Create formula error: ") +
            cudaGetErrorString(error)
        );
    }

    IFractalFormula* formula = nullptr;

    error = cudaMemcpy(
        &formula,
        deviceFormula,
        sizeof(IFractalFormula*),
        cudaMemcpyDeviceToHost
    );

    cudaFree(deviceFormula);

    if (error != cudaSuccess) {
        throw std::runtime_error(
            std::string("Formula pointer copy error: ") +
            cudaGetErrorString(error)
        );
    }

    return formula;
}

//__global__ void _destroyFormula(IFractalFormula *fractalFormula);

void destroyFormula(IFractalFormula *fractalFormula);

#endif