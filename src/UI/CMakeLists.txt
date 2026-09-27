cmake_minimum_required(VERSION 3.8.0...3.10)

list(APPEND SOURCE_FILES
    ${CMAKE_CURRENT_SOURCE_DIR}/mainUI.cu
    ${CMAKE_CURRENT_SOURCE_DIR}/ColorGradient.h
    ${CMAKE_CURRENT_SOURCE_DIR}/ProgramControl.h
    ${CMAKE_CURRENT_SOURCE_DIR}/ProgramControl.cu
    ${CMAKE_CURRENT_SOURCE_DIR}/FractalLabel.h
)

set(SOURCE_FILES ${SOURCE_FILES} PARENT_SCOPE)
