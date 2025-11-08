#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <time.h>

#include "Image_O.h"
#include "CUDA_ComputeFractals.h"

int WriteImageToFileWithTimestamp(size_t width, size_t height, size_t channels, const char *data, const char *filename){

    
    int i = 0;
    for (;filename[i] != 0 && i < 100; i++){}
   
    printf("i: %d", i);

    time_t rawtime;
    struct tm * timeinfo;
    printf("size of time_t: %llu", sizeof(time_t));
    time ( &rawtime );   
    char *timestamp = malloc(20);
    sprintf(timestamp, "%lld", rawtime);
    int j = 0;
    for (;timestamp[j] != 0 && j < 100; j++){}

    

    char *filenameTimestamp = malloc(i + j + 1);

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

    int width = 1000;
    int height = 1000;
    int channels = 3;
    double zoom = 100;
    int iterations = 100;

    if (argc > 4){
        
        width = atoi(argv[1]);
        height = atoi(argv[2]);
        zoom = atof(argv[3]);
        iterations = atoi(argv[4]);

    }

    char *image = (char *) calloc(width * height, channels);
    GPU_Image gpuImage;
    InitGPU_Image(width, height, channels, &gpuImage);
    
    RGB_Color rgbColors[6];

    rgbColors[0].red = 0;
    rgbColors[0].green = 7;
    rgbColors[0].blue = 100;

    rgbColors[1].red = 32;
    rgbColors[1].green = 107;
    rgbColors[1].blue = 203;

    rgbColors[2].red = 237;
    rgbColors[2].green = 255;
    rgbColors[2].blue = 255;

    rgbColors[3].red = 255;
    rgbColors[3].green = 170;
    rgbColors[3].blue = 0;

    rgbColors[4].red = 255;
    rgbColors[4].green = 170;
    rgbColors[4].blue = 0;

    rgbColors[5].red = 0;
    rgbColors[5].green = 2;
    rgbColors[5].blue = 0;
                                            //0.6425
    double positionsOfColors[] = {0, 0.1, 0.2, 0.5, 0.8575, 1.0};

    RGB_ColorSpectrum rgbColorspectrum;
    InitRGB_ColorSpectrum(6, rgbColors, positionsOfColors, &rgbColorspectrum);

    printf("Drawing Fractal\n");
    DrawImage(image, width, height, channels, &gpuImage, &rgbColorspectrum, FracMandelbrot, zoom, 0.0, 0.0, iterations);
    
    printf("Saving Image\n");
    WriteImageToFile(width, height, channels, image, "Images\\Fract.png");

    printf("Finished!\n");

    DeinitGPU_Image(&gpuImage);
    free(image);

    return 0;
}
