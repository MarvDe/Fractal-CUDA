#include "Julia.cuh"

__host__ __device__ Julia::Julia(double cx, double cy): cx(cx), cy(cy){}

double Julia::calculate(double x, double y) const{
    int index = 0;

    double z0 = x;
    double z1 = y;

    while (index < iterations && (z0*z0 + z1*z1) < 4){
        double z0_ = z0 * z0 - z1 * z1 + cx;
        double z1_ = 2 * z0 * z1 + cy;

        z0 = z0_;
        z1 = z1_;
        
        index++;
    }
    double output = static_cast<double>(index) / static_cast<double>(iterations); 
    return output;
} 

FRACTAL_TYPES Julia::getType() const{
    return FRACTAL_TYPES::JULIA;
}