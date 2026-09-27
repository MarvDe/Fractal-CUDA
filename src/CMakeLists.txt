cmake_minimum_required(VERSION 3.8.0...3.10)

set(CMAKE_AUTOMOC ON)

find_package(Qt6 REQUIRED COMPONENTS Widgets)
find_package(Threads REQUIRED)

set(SOURCE_FILES
    main.cu
    ImageO.cu
    FractalColor.cu
    FractalCompute.cu
)

add_subdirectory(Formulas)
add_subdirectory(UI)



add_executable(Fractal ${SOURCE_FILES})

set_target_properties(Fractal PROPERTIES
    CUDA_SEPARABLE_COMPILATION ON
)

target_link_libraries(Fractal PRIVATE
    Qt6::Widgets
    Threads::Threads
)