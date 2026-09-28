#ifndef COLOR_GRADIENT_SLIDER_H
#define COLOR_GRADIENT_SLIDER_H

#include <qt6/QtWidgets/QtWidgets>
#include "../FractalColor.cuh"

struct ColorHandle{
    ColorHandle(QColor color, double pos): 
        color(color), 
        pos(std::clamp(pos, 0.0, 1.0)){

    }
    QColor color;
    double pos;
};

class ColorGradientSlider: public QWidget{
    
    Q_OBJECT

    private:

        RGB_ColorSpectrum *spectrum;
        int selectedHandle = -1;

        int handleWidth = 16;
        int handleHeightMargin = 10;

        bool wrapAround = true;

    public:
        ColorGradientSlider(RGB_ColorSpectrum *spectrum, QWidget *parent = nullptr) : QWidget(parent), spectrum(spectrum){
            setMinimumSize(100, 20);
        }

        void addColorHandle(const ColorHandle &handle){
            if (spectrum->numberOfColors < MAX_COLORS_IN_COLORSPECTRUM){

                spectrum->positionOfColors[spectrum->numberOfColors] = handle.pos;
                spectrum->rgbColors[spectrum->numberOfColors].red = handle.color.red();
                spectrum->rgbColors[spectrum->numberOfColors].green = handle.color.green();
                spectrum->rgbColors[spectrum->numberOfColors].blue = handle.color.blue();
                spectrum->numberOfColors++;
                update();
            }
        }

        RGB_ColorSpectrum *getColorSpectrum(){
            return spectrum;
        }
    
    protected:
        void paintEvent(QPaintEvent *event) override{

            Q_UNUSED(event);

            QPainter painter(this);

            QRect rect{this->rect()};

            // draw gradient on image
            QImage image(rect.width(), 1, QImage::Format_RGB32);
            for (int x = 0; x < rect.width(); ++x) {
                RGB_Color color = InterpColorSpectrum(
                    spectrum,
                    std::clamp(getValueFromPosition(x), 0.0, 1.0)
                );

                image.setPixel(
                    x, 0,
                    qRgb(color.red, color.green, color.blue)
                );
            }
            
            // draw the gradient image
            QRect rectDraw(
                rect.x() + handleWidth / 2, 
                rect.y() + handleHeightMargin / 2, 
                rect.width() - handleWidth, 
                rect.height() - handleHeightMargin
            );
            painter.drawImage(rectDraw, image);

            // draw the color handles
            painter.setPen(Qt::black);
            for (int i = 0; i < spectrum->numberOfColors; i++){
                
                painter.setBrush(QColor(
                    spectrum->rgbColors[i].red, 
                    spectrum->rgbColors[i].green, 
                    spectrum->rgbColors[i].blue)
                );

                if (i == selectedHandle){
                    painter.setPen(Qt::green);
                }

                QRect rectHandle(
                    static_cast<int>(spectrum->positionOfColors[i] * (rect.width() - handleWidth)), 
                    static_cast<int>(rect.y()), 
                    handleWidth - 1, 
                    rect.height() - 1);
                
                painter.drawRect(rectHandle);

                if (i == selectedHandle){
                    painter.setPen(Qt::black);
                }
            }

        }

        void mousePressEvent(QMouseEvent *event) override{
            Qt::MouseButton button = event->button();
            if (button == Qt::MouseButton::LeftButton){
                int x = event->position().x();

                for (int i = 0; i < spectrum->numberOfColors; i++){
                    if (
                        spectrum->positionOfColors[i] >= getValueFromPosition(x - static_cast<double>(handleWidth) / 2) &&
                        spectrum->positionOfColors[i] <  getValueFromPosition(x + static_cast<double>(handleWidth) / 2) 
                    ){
                        selectedHandle = i;
                        update();
                    }
                }

            }
        }

        void mouseReleaseEvent(QMouseEvent *event) override{
            if (event->button() == Qt::MouseButton::LeftButton){
                selectedHandle = -1;
                update(); 
            }
        }

        void mouseMoveEvent(QMouseEvent *event){
            if (selectedHandle >= 0){
                int x = event->pos().x();
                double value = std::clamp(
                    getValueFromPosition(x),
                    0.0,
                    1.0
                );
                spectrum->positionOfColors[selectedHandle] = value;
                update();
            }
        }

    private:

        double getValueFromPosition(int xPos){
            return 
                (static_cast<double>(xPos) - static_cast<double>(handleWidth) / 2.0) / 
                (static_cast<double>(this->rect().width()) - handleWidth); 
        }

};

#endif 