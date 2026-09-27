#include "ProgramControl.h"

#include "../Formulas/Mandelbrot.cuh"
#include "../FractalCompute.cuh"

void ProgramControl::onCalculateClicked(){
    std::cout << "click" << std::endl;

    int ret = callDrawImage<Mandelbrot>(
        image, 
        spectrum,
        zoom,
        posX,
        posY
    );

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