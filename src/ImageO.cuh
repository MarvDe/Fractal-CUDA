#ifndef IMAGE_O_H
#define IMAGE_O_H


#include <stdlib.h>

/* 
* @param 
*   @param width Width of image.
*   @param height Height of image.
*   @param channels Channels of image (1 = monochrome), (2 = monochrome with alpha), (3 = RGB), (4 = RGBA).
*   @param data Image data as byte array.
*   @param filename Name of file as C-String. Supports png, jpg, bmp and tga file types.
*
* @returns 
*   - Returns zero on success and non zero on failure. */
int WriteImageToFile(size_t width, size_t height, size_t channels, const unsigned char *data, const char *filename);    

#endif
