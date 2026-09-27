#ifndef FRACTAL_LABEL_H
#define FRACTAL_LABEL_H

#include <qt6/QtWidgets/QLabel>
#include <iostream>

#include "../Image.cuh"

class FractalLabel: public QLabel{
    Q_OBJECT

    public:
        FractalLabel(QWidget *parent = nullptr) : QLabel(parent){}

    public slots:
        void setImage(Image *image){

            this->setPixmap(
                QPixmap::fromImage(
                    QImage(image->data, image->width, image->height, QImage::Format::Format_RGB888, nullptr, nullptr)
                )
            );
        }
};

#endif