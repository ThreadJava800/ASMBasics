#include "patcher.h"

GifFrameList_t* initFrameList() {
    GifFrameList_t* frameList = (GifFrameList_t*) calloc(1, sizeof(GifFrameList_t));
    frameList->frames         = (GifFrame_t*)     calloc(1, sizeof(GifFrame_t));
}

void pushBackFrameList(GifFrameList_t* frames, GifFrame_t value) {

}

GifFrameList_t* getGifFrames(const char* fileName) {
    int* delayList = 0;
    int _z = 0, _comp = 0;
    GifFrameList_t* frames = initFrameList();

    // loading file to stb
    FILE* file = stbi__fopen(fileName, "rb");
    stbi__context context = {};
    stbi__start_file(&context, file);


}


bool compareFloats(const float value1, const float value2) {
    return fabs(value1 - value2) < EPSILON;
}

void checkForColision(Direction_t* direction, float x, float xSize, float xScale, 
                                              float y, float ySize, float yScale) {
    if (compareFloats(x, 0) || compareFloats(x, WINDOW_LENGTH - xSize * xScale)) {
        direction->xDir *= -1;
    }
    if (compareFloats(y, 0) || compareFloats(y, WINDOW_HEIGHT - ySize * yScale)) {
        direction->yDir *= -1;
    }
}

void runMainCycle() {
    // Load images
    sf::Texture bonzi = sf::Texture();
    ON_ERROR(!bonzi.loadFromFile("bonzi.gif"), "FILE NOT FOUND",);

    sf::Texture winLogo = sf::Texture();
    ON_ERROR(!winLogo.loadFromFile("newxp.png"), "FILE NOT FOUND",);

    sf::SoundBuffer music = sf::SoundBuffer();
    ON_ERROR(!music.loadFromFile("elev.wav"), "FILE NOT FOUND",);

    // play music
    sf::Sound sound = sf::Sound();
    sound.setBuffer(music);
    sound.play();
    sound.setLoop(true);

    // Define sprites (object with images)
    sf::Sprite winLogoSp = sf::Sprite();        // winLogoSprite
    winLogoSp.setTexture(winLogo);
    winLogoSp.setScale(0.25, 0.25);
    winLogoSp.setPosition(WINDOW_LENGTH - (float) winLogo.getSize().x, 
                           WINDOW_HEIGHT - (float) winLogo.getSize().y);

    sf::Sprite bonziSp = sf::Sprite();          // bonzi sprite
    bonziSp.setTexture(bonzi);

    // Init main window and set it's position to hegher left point
    sf::RenderWindow window(sf::VideoMode(WINDOW_LENGTH, WINDOW_HEIGHT), "", sf::Style::None);
    window.setPosition(sf::Vector2i(0, 0));

    Direction_t direction = {};

    // Main program cycle
    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))         // on something happened
        {
            // close if escape clicked
            if (event.type == sf::Event::Closed || 
                (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Escape))
                window.close();
        }

        checkForColision(&direction, 
                        winLogoSp.getPosition().x, 
                        (float) winLogoSp.getTexture()->getSize().x,
                        winLogoSp.getScale().x,
                        winLogoSp.getPosition().y, 
                        (float) winLogoSp.getTexture()->getSize().y,
                        winLogoSp.getScale().y);
                        
        winLogoSp.move(direction.xDir, direction.yDir);
        
        // setting window color and sprite
        window.clear(sf::Color::Transparent);
        window.draw(winLogoSp);
        window.draw(bonziSp);
        window.display();
    }
}


int main()
{
    runMainCycle();
    
    return 0;
}