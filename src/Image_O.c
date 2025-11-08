#include <stdlib.h>
#include <stdio.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"


#define PNG 0
#define JPG 1
#define BMP 2
#define TGA 3
#define UNDEFINED 4


int GetImageType(const char *filename){

    int i = 0;
    for (; filename[i] != 0 && i < 100; i++) {}
    if (!memcmp(filename + i - 3, "png", 3)) return PNG;
    if (!memcmp(filename + i - 3, "jpg", 3)) return JPG;
    if (!memcmp(filename + i - 3, "bmp", 3)) return BMP;
    if (!memcmp(filename + i - 3, "tga", 3)) return TGA;
    return UNDEFINED;

}


int WriteImageToFile(size_t width, size_t height, size_t channels, const unsigned char *data, const char *filename){

    int success;
    switch (GetImageType(filename)){
        case PNG:
            success = stbi_write_png(filename, width, height, channels, data, 0)    == 0;
            break;
        case JPG:
            success = stbi_write_bmp(filename, width, height, channels, data)       == 0;
            break;
        case BMP:
            success = stbi_write_tga(filename, width, height, channels, data)       == 0;
            break;
        case TGA:
            success = stbi_write_jpg(filename, width, height, channels, data, 100)  == 0;
            break;
        default:
            success = -1;
            break;
    }
        
    return success;

}