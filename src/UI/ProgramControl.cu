#include "ProgramControl.h"
#include "../ImageO.cuh"

#include "../Formulas/Mandelbrot.cuh"

void ProgramControl::onCalculateClicked(){

    fractalCompute->calculate(zoom, posX, posY);
    Image *image = fractalCompute->getImage();

    // WriteImageToFile(
    //     image->width,
    //     image->height,
    //     image->channels,
    //     image->data,
    //     "image.png"
    // );

    emit rendered(image);

}

void ProgramControl::setZoom(double zoom){
    this->zoom = zoom;
}

void ProgramControl::setPosX(double posX){
    this->posX = posX;
}

void ProgramControl::setPosY(double posY){
    this->posY = posY;
}

void ProgramControl::setZoom(const QString &zoomText){
    zoom = zoomText.toDouble();
}

void ProgramControl::setPosX(const QString &posXText){
    posX = posXText.toDouble();
}

void ProgramControl::setPosY(const QString &posYText){
    posY = posYText.toDouble();
}