#include <SFML/Graphics.hpp>
#include <SFML/Audio.hpp>
#include <math.h>
#include <sys/time.h>

#define STB_IMAGE_IMPLEMENTATION
#define STBI_ONLY_GIF
#include </home/vladimir/Projects/DOSBox/Projects/HACKME/crack/stb/stb_image.h>



#define ON_ERROR(expr, errStr, retVal) {                 \
    if (expr) {                                           \
        fprintf(stderr, "FATAL ERROR: %s\n", errStr);      \
        return retVal;                                      \
    }                                                        \
}                                                             \


const int WINDOW_HEIGHT = 1080;
const int WINDOW_LENGTH = 1920;
const float EPSILON = 1e-12f;

struct Direction_t {
    float xDir = -0.125f * 0.25f;
    float yDir = -0.0625f * 0.25f;
};

struct GifFrame_t {
    int delay = 0;
    sf::Texture texture = sf::Texture();
};

struct GifFrameList_t {
    GifFrame_t* frames = nullptr;
    int frameCount    = 0;
    int frameCapacity = 1;
};

GifFrameList_t* initFrameList();
void pushBackFrameList(GifFrameList_t* frames, GifFrame_t value);
GifFrameList_t* getGifFrames(const char* fileName, int sizeX, int sizeY);

bool compareFloats(const float value1, const float value2);
void checkForColision(Direction_t* direction, float x, float xSize, float xScale, 
                                              float y, float ySize, float yScale);

long long getCurTimeMs();
void patch();
void runMainCycle();