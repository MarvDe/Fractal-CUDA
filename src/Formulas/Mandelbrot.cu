#include "Mandelbrot.cuh"

__host__ __device__ Mandelbrot::Mandelbrot(){}

double Mandelbrot::calculate(double x, double y) const{
    int index = 0;

    double z0 = 0.0;
    double z1 = 0.0;

    while (index < iterations && (z0*z0 + z1*z1) < 4){
        double z0_ = z0 * z0 - z1 * z1 + x;
        double z1_ = 2 * z0 * z1 + y;

        z0 = z0_;
        z1 = z1_;
        
        index++;
    }
    double output = static_cast<double>(index) / static_cast<double>(iterations); 
    return output;
}