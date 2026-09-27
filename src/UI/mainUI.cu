#include "mainUI.cuh"
#include "ColorGradient.h"
//#include "ProgramControl.h"


MainUI::MainUI(std::size_t width, std::size_t height, int argc, char **argv){

    int colorChannels = 3;
    unsigned char *dataUI = new unsigned char[height * width * colorChannels];
    for (int i = 0; i < height; i++){
        for (int j = 0; j < width; j++){
            dataUI[i * width * colorChannels + j * colorChannels] = 0;
            dataUI[i * width * colorChannels + j * colorChannels + 1] = i % 256;
            dataUI[i * width * colorChannels + j * colorChannels + 2] = 0;
        }
    }

    imageData = new Image(width, height, colorChannels, dataUI);

    // create the main ui thread
    setup(argc, argv);

}

MainUI::~MainUI(){

}

void MainUI::setup(int argc, char **argv){

    // initialization (creation of label has to be done in this thread)
    app = new QApplication(argc, argv);
    window = new QMainWindow();
    mainWidget = new QWidget();
    window->setCentralWidget(mainWidget);
    layout = new QGridLayout(mainWidget);
    button = new QPushButton();
    zoomText = new QLineEdit();
    posXText = new QLineEdit();
    posYText = new QLineEdit();
    fracLabel = new FractalLabel();

    ColorGradientSlider slider(nullptr);

    programControl = new ProgramControl(imageData, slider.getColorSpectrum());

    slider.addColorHandle(ColorHandle(QColor(1,255,3), 0.0));
    slider.addColorHandle(ColorHandle(QColor(1,2,255), 0.5));
    slider.addColorHandle(ColorHandle(QColor(255,0,0), 1.0));

    button->setText(QString("Render"));

    QObject::connect(
        button, &QPushButton::clicked,
        programControl, &ProgramControl::onCalculateClicked
    );

    fracLabel->setImage(imageData);

    QObject::connect(
        programControl, &ProgramControl::rendered,
        fracLabel, &FractalLabel::setImage
    );

    QObject::connect(
        zoomText, &QLineEdit::textChanged,
        programControl, static_cast<void (ProgramControl::*)(const QString&)>(&ProgramControl::setZoom)
    );

    QObject::connect(
        posXText, &QLineEdit::textChanged,
        programControl, static_cast<void (ProgramControl::*)(const QString&)>(&ProgramControl::setPosX)
    );

    QObject::connect(
        posYText, &QLineEdit::textChanged,
        programControl, static_cast<void (ProgramControl::*)(const QString&)>(&ProgramControl::setPosY)
    );

    layout->addWidget(button, 0, 0);
    layout->addWidget(zoomText, 0, 1);
    layout->addWidget(posXText, 0, 2);
    layout->addWidget(posYText, 0, 3);
    layout->addWidget(&slider, 1, 0, 1, 4);
    layout->addWidget(fracLabel, 2, 0, 1, 4);
    
    window->resize(320, 240);
    window->show();

    window->setWindowTitle(QApplication::translate("toplevel", "Top-level widget"));

    // ui loop
    app->exec();

    app->exit();

    // clean up
    delete[] imageData->data;
    delete imageData;
    // delete app;
    // app = nullptr;
    // delete window;
    // window = nullptr;
    // delete layout;
    // layout = nullptr;
    // delete button;
    // button = nullptr;
    // delete label;
    // label = nullptr;
    // delete image;
    // image = nullptr;

}