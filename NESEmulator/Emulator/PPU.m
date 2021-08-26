//
//  PPU.m
//  NESEmulator
//
//  Created by Cosme Jordan on 26.08.21.
//

#import "PPU.h"
#import "FileManager.h"

@interface PPU() {
    NES_u8 ppuCtrl;
    NES_u8 ppuMask;
    NES_u8 ppuStatus;

    NES_u8 oamaddr;
    NES_u8 oamdatta;
    NES_u8 ppuscroll;
    NES_u8 ppudata;
    NES_u8 oamdma;

    uint32_t cycle;
    uint32_t elapsedCycle;
}

@property(nonatomic, strong) FileManager* fileManager;

@property(nonatomic, strong) NSArray* palette;


@end

@implementation PPU

- (instancetype)init {
    if(self = [super init]) {
        _fileManager = [[FileManager alloc] init];
        _palette = [_fileManager getPalette:@"nespalette"];
    }

    return self;
}

- (void)clock {

}

- (PPUState)getPPUState {
    PPUState ppuState;

    ppuState.ppuCtrl = ppuCtrl;
    ppuState.ppuMask = ppuMask;
    ppuState.ppuStatus = ppuStatus;

    ppuState.oamaddr = oamaddr;
    ppuState.oamdatta = oamdatta;
    ppuState.ppuscroll = ppuscroll;
    ppuState.ppudata = ppudata;
    ppuState.oamdma = oamdma;

    ppuState.cycle = cycle;
    ppuState.elapsedCycle = elapsedCycle;

    return ppuState;
}

@end
