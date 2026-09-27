cmake_minimum_required(VERSION 3.8.0...3.10)

set(CMAKE_CXX_STANDARD 11)

project(Fractal)
enable_language(CUDA)

# main project source directory
add_subdirectory(src)

set_target_properties(Fractal PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)