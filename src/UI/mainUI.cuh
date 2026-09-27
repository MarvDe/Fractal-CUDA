#ifndef FRACTAL_MAIN_UI_H
#define FRACTAL_MAIN_UI_H

#include <thread>

#include "../Image.cuh"
#include "FractalLabel.h"
#include "ProgramControl.h"

#include <qt6/QtWidgets/QtWidgets>
#include <qt6/QtWidgets/QApplication>
#include <qt6/QtWidgets/QPushButton>
#include <qt6/QtWidgets/QLabel>
#include <qt6/QtWidgets/QLineEdit>
#include <qt6/QtWidgets/QMainWindow>

class MainUI{

    private:
        QApplication *app;
        QMainWindow *window;
        QWidget *mainWidget;
        QGridLayout *layout;
        QPushButton *button;
        QLineEdit *zoomText;
        QLineEdit *posXText;
        QLineEdit *posYText;
        FractalLabel *fracLabel;
        QImage *image;
        Image *imageData;
        ProgramControl *programControl;

        void setup(int argc, char **argv);

    public:
        MainUI(std::size_t width, std::size_t height, int argc, char **argv);
        ~MainUI();

        //void updateImage(Image *newImage);

};

#endif