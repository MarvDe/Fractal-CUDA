#ifndef PROGRAM_CONTROL_H
#define PROGRAM_CONTROL_H

#include <iostream>

#include "../Image.cuh"
#include "../IFractalCompute.h"

#include <qt6/QtCore/QObject>


class ProgramControl: public QObject{
    Q_OBJECT

    public:

        ProgramControl(IFractalCompute *fractalCompute) : fractalCompute(fractalCompute){}

        Image *getImage(){
            return fractalCompute->getImage();
        }

    public slots:
        void onCalculateClicked();
        void setZoom(double zoom);
        void setPosX(double posX);
        void setPosY(double posY);
        void setZoom(const QString &zoomText);
        void setPosX(const QString &posXText);
        void setPosY(const QString &posYText);
    
    signals:
        void rendered(Image *image);

    private:
        
        IFractalCompute *fractalCompute;
        double zoom = 1.0;
        double posX = 0.0;
        double posY = 0.0;



};

#endif