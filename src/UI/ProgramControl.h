#ifndef PROGRAM_CONTROL_H
#define PROGRAM_CONTROL_H

#include <iostream>

#include "../Image.cuh"

#include <qt6/QtCore/QObject>


class ProgramControl: public QObject{
    Q_OBJECT

    public:

        ProgramControl(Image *image, RGB_ColorSpectrum *specturm) : image(image), spectrum(specturm){}
        ProgramControl(){

            unsigned char *data = new unsigned char[500 * 500 * 3];

            image = new Image(
                500, 
                500, 
                3, 
                data
            );
        }

        ~ProgramControl(){
            delete[] image->data;
            delete image;
        }

        Image *getImage(){
            return image;
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
        
        Image *image;
        RGB_ColorSpectrum *spectrum;
        double zoom = 1.0;
        double posX = 0.0;
        double posY = 0.0;



};

#endif