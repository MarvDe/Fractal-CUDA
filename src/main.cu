#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "UI/mainUI.cuh"
#include "ImageO.cuh"
#include "Formulas/FractalFormula.cuh"
#include "Formulas/Julia.cuh"
#include "Formulas/Mandelbrot.cuh"
#include "Image.cuh"
#include "FractalCompute.cuh"

int WriteImageToFileWithTimestamp(size_t width, size_t height, size_t channels, const char *data, const char *filename){
    
    int i = 0;
    for (;filename[i] != 0 && i < 100; i++){}
   
    printf("i: %d", i);

    time_t rawtime;
    struct tm * timeinfo;
    printf("size of time_t: %llu", sizeof(time_t));
    time ( &rawtime );   
    char *timestamp = (char *)malloc(20);
    sprintf(timestamp, "%lld", rawtime);
    int j = 0;
    for (;timestamp[j] != 0 && j < 100; j++){}

    char *filenameTimestamp = (char *)malloc(i + j + 1);

    memcpy(filenameTimestamp, filename, i - 4);
    memcpy(filenameTimestamp + i - 4, timestamp, j);
    memcpy(filenameTimestamp + j + i - 4, filename + i - 4, 4);
    filenameTimestamp[i + j] = 0;

    printf("FilenameTimestamp: %s\n", filenameTimestamp);
    free(timestamp);
    free(filenameTimestamp);
    return 0;
}

int main(int argc, char* argv[]){

    int width = 500;
    int height = 500;
    int channels = 3;
    double zoom = 100;
    int iterations = 100;

    if (argc > 4){
        
        width = atoi(argv[1]);
        height = atoi(argv[2]);
        zoom = atof(argv[3]);
        iterations = atoi(argv[4]);

    }

    // create ui
    MainUI mainUI(width, height, argc, argv);

    return 0;
}
