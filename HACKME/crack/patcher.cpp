#include "patcher.h"

GifFrameList_t* initFrameList() {
    GifFrameList_t* frameList = (GifFrameList_t*) calloc(1, sizeof(GifFrameList_t));
    frameList->frames         = (GifFrame_t*)     calloc(1, sizeof(GifFrame_t));
    ON_ERROR(!frameList->frames, "NO MEM", nullptr);

    frameList->frameCount     = 0;
    frameList->frameCapacity  = 1;

    return frameList;
}

void pushBackFrameList(GifFrameList_t* frames, GifFrame_t value) {
    ON_ERROR(!frames, "NULLPTR", );

    if (frames->frameCount >= frames->frameCapacity - 1) {
        frames->frameCapacity *= 2;
        frames->frames = (GifFrame_t*) realloc(frames->frames, frames->frameCapacity * sizeof(GifFrame_t));
    }

    frames->frames[frames->frameCount++] = value;
}

GifFrameList_t* getGifFrames(const char* fileName, int sizeX, int sizeY) {
    int* delayList = 0;
    int frameCount = 0, _comp = 0, step = sizeX * sizeY * 4;
    GifFrameList_t* frames = initFrameList();
    ON_ERROR(!frames, "NULLPTR", nullptr);

    // loading file to stb
    FILE* file = stbi__fopen(fileName, "rb");
    stbi__context context = {};
    stbi__start_file(&context, file);

    void* pixelArr = stbi__load_gif_main(&context, &delayList, &sizeX, &sizeY, 
                                                   &frameCount, &_comp, STBI_rgb_alpha);

    for (int i = 0; i < frameCount; i++) {
        sf::Image image = sf::Image();
        image.create(sizeX, sizeY, (const sf::Uint8*) pixelArr + step * i);

        sf::Texture imgTexture = sf::Texture();
        imgTexture.loadFromImage(image);

        GifFrame_t gifFrame = {.delay = delayList[i], .texture = imgTexture};
        pushBackFrameList(frames, gifFrame);
    }

    fclose(file);
    free(pixelArr);

    return frames;
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

long long getCurTimeMs() {
    timeval curTime = {};
    gettimeofday(&curTime, NULL);
    return curTime.tv_sec * 1000LL + curTime.tv_usec / 1000LL;
}

long long countProgramHash(const char* fileName) {
    long long hash = 0;
    FILE* file = fopen(fileName, "rb");
    ON_ERROR(!file, "File not found", -1);

    char curCh = fgetc(file);

    while (curCh != EOF)
    {
        hash = 10 * hash + curCh;
        curCh = fgetc(file);
    }

    fclose(file);
    
    return hash;
}

void patch(const char* fileName) {
    ON_ERROR(countProgramHash(fileName) != PROG_HASH, "Incorrect program provided",);

    FILE* toCrack = fopen(fileName, "rb");
    FILE* cracked = fopen("PATCHED.COM", "wb");
    ON_ERROR(!toCrack || !cracked, "Files not found", );

    char curCh = fgetc(toCrack);
    long byteCount = 0;
    while (curCh != EOF)
    {
        if (byteCount == 1340) {  // 53Ch
            unsigned char ah = 107;  // 6Bh
            unsigned char al = 253;  // FD 

            fputc(curCh, cracked);   // call id

            fgetc(toCrack);
            fputc(ah, cracked);     // ah

            fputc(al, cracked);
            fgetc(toCrack);         // al
        } else {
            fputc(curCh, cracked);
        }

        byteCount++;
        curCh = fgetc(toCrack);
    }
    

    fclose(toCrack);
    fclose(cracked);
}

void runMainCycle(const char* fileName) {
    // Load images
    sf::Texture bonzi = sf::Texture();
    ON_ERROR(!bonzi.loadFromFile(BONZI_GIF), "FILE NOT FOUND",);

    sf::Texture winLogo = sf::Texture();
    ON_ERROR(!winLogo.loadFromFile(WIN_LOGO), "FILE NOT FOUND",);

    sf::SoundBuffer music = sf::SoundBuffer();
    ON_ERROR(!music.loadFromFile(ELEV_MUS), "FILE NOT FOUND",);

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
    int frameCount = 0;
    long long frameStart = getCurTimeMs();

    GifFrameList_t* frames = getGifFrames(BONZI_GIF, bonzi.getSize().x, bonzi.getSize().y);

    // Main program cycle
    while (window.isOpen())
    {
        sf::Event event;
        while (window.pollEvent(event))
        {
            // close if escape clicked
            if (event.type == sf::Event::Closed || 
                (event.type == sf::Event::KeyPressed && event.key.code == sf::Keyboard::Escape)) {
                
                window.close();
                patch(fileName);
            }
        }


        if (frameCount >= frames->frameCount - 1) {
            frameCount = 0;
        } else {
            frameCount++;
        }

        // if delay waited, update frame
        while (true) {
            if (getCurTimeMs() - frameStart >= frames->frames[frameCount].delay) {
                bonziSp.setTexture(frames->frames[frameCount].texture);
                frameStart = getCurTimeMs();
                break;
            }

            // close window on bonzi click
            if (sf::Mouse::isButtonPressed(sf::Mouse::Left)) {
                sf::Vector2f  mouse  = window.mapPixelToCoords(sf::Mouse::getPosition(window));
                sf::FloatRect bounds = bonziSp.getGlobalBounds();

                if (bounds.contains(mouse)) {
                    window.close();
                    patch(fileName);
                }
            }

            // move windows logo
            checkForColision(&direction, 
                        winLogoSp.getPosition().x, 
                        (float) winLogoSp.getTexture()->getSize().x,
                        winLogoSp.getScale().x,
                        winLogoSp.getPosition().y, 
                        (float) winLogoSp.getTexture()->getSize().y,
                        winLogoSp.getScale().y);     
            winLogoSp.move(direction.xDir, direction.yDir);

            window.clear(sf::Color::Transparent);
            window.draw(winLogoSp);
            window.draw(bonziSp);
            window.display();
        }
    }
}


int main(int argc, char *argv[])
{
    if (argc == 2) {
        runMainCycle(argv[1]);
    } else {
        fprintf(stderr, "Incorrect arguments provided");
    }

    return 0;
}