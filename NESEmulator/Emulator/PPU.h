//
//  PPU.h
//  NESEmulator
//
//  Created by Cosme Jordan on 26.08.21.
//

#import <Foundation/Foundation.h>
#import "../Utils.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    // PPU Registers
    NES_u8 ppuCtrl;
    NES_u8 ppuMask;
    NES_u8 ppuStatus;

    NES_u8 oamaddr;
    NES_u8 oamdata;
    NES_u8 ppuscroll;
    NES_u8 ppuData;
    NES_u8 oamdma;

    uint32_t cycle;

    uint32_t elapsedCycle;

} PPUState;

typedef enum {
    VERTICAL_MIRRORING,
    HORIZONTAL_MIRRORING,
    SINGLE_SCREEN,
    FOUR_SCREEN

} Mirroring;

@interface PPU : NSObject

- (void)clock;

- (PPUState)getPPUState;
- (void)notify:(NES_u16)modifiedRegister;

-(uint32_t*)getScreenPixels;

@end

NS_ASSUME_NONNULL_END
