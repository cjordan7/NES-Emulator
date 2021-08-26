//
//  Utils.h
//  NESEmulator
//
//  Created by Cosme Jordan on 22.08.21.
//

#ifndef Utils_h
#define Utils_h

#define UNUSED __attribute__((unused))

#define BUTTON_HEIGHT APP_SIZE_HEIGHT
#define BUTTON_WIDTH (APP_SIZE_WIDTH-(NES_WIDTH*NES_WIDTH_PROPORTION))/2

#define NES_HEIGHT_PROPORTION 2
#define NES_WIDTH_PROPORTION 2

#define NES_HEIGHT 240
#define NES_WIDTH 256

#define APP_SIZE_HEIGHT NES_HEIGHT*NES_HEIGHT_PROPORTION
#define APP_SIZE_WIDTH 1000

#define SK_SCENE_HEIGHT NES_HEIGHT*NES_HEIGHT_PROPORTION
#define SK_SCENE_WIDTH NES_WIDTH*NES_WIDTH_PROPORTION

typedef uint8_t NES_u8;
typedef uint16_t NES_u16;
typedef NSString* NES_StrPtr;

UNUSED
static uint32_t* buffedPixels(NSArray* array,
                              int w, int h,
                              int buffedW, int buffedH) {
    uint32_t* pixels = calloc((w*buffedW)*(h*buffedH), sizeof(uint32_t));

    for(int j = 0; j < h; ++j) {
        for(int i = 0; i < w; ++i) {
            uint32_t value = [(NSNumber*)array[i+j*w] unsignedIntValue];
            for(int iB = 0; iB < buffedW; ++iB) {
                for(int jB = 0; jB < buffedH; ++jB) {
                    pixels[i*buffedW+j*(w*buffedW)*buffedH
                           + iB + jB*(w*buffedW)] = value;
                }
            }
        }
    }

    return pixels;
}

#endif /* Utils_h */
