//
//  PPU.m
//  NESEmulator
//
//  Created by Cosme Jordan on 26.08.21.
//

#import "PPU.h"
#import "FileManager.h"
#import "Bus.h"

#define PPUCTRL	0x2000
#define PPUMASK	0x2001
#define PPUSTATUS 0x2002
#define OAMADDR	0x2003
#define OAMDATA	0x2004
#define PPUSCROLL 0x2005
#define PPUADDR	0x2006
#define PPUDATA	0x2007
#define OAMDMA	0x4014

@interface PPU() {
    uint32_t cycle;
    uint32_t elapsedCycle;
}

@property(nonatomic, strong) FileManager* fileManager;

@property(nonatomic, strong) NSArray* palette;

@property(nonatomic) NES_u8 ppuCtrl;
@property(nonatomic) NES_u8 ppuMask;
@property(nonatomic) NES_u8 ppuStatus;
@property(nonatomic) NES_u8 oamaddr;
@property(nonatomic) NES_u8 oamdata;
@property(nonatomic) NES_u8 ppuscroll;
@property(nonatomic) NES_u8 ppudata;
@property(nonatomic) NES_u8 oamdma;

@property(nonatomic, strong) Bus* bus;

@end

@implementation PPU

- (instancetype)init {
    if(self = [super init]) {
        _fileManager = [[FileManager alloc] init];
        _palette = [_fileManager getPalette:@"nespalette"];

        self.ppuCtrl = 0;
        self.ppuMask = 0;
        self.ppuStatus = 0;
        self.oamaddr = 0;
        self.oamdata = 0;
        self.ppuscroll = 0;
        self.ppudata = 0;
        self.oamdma = 0;
    }

    return self;
}

- (void)connectBus:(Bus*)bus {
    _bus = bus;
}

- (NES_u8)ppuCtrl {
    return [self.bus readConnectedBus:PPUCTRL];
}

- (void)setPpuCtrl:(NES_u8)ppuCtrl {
    [self.bus writeConnectedBus:PPUCTRL value:ppuCtrl];
}

- (NES_u8)ppuMask {
    return [self.bus readConnectedBus:PPUMASK];
}

- (void)setPpuMask:(NES_u8)ppuMask {
    [self.bus writeConnectedBus:PPUMASK value:ppuMask];
}

- (NES_u8)ppuStatus {
    return [self.bus readConnectedBus:PPUMASK];
}

- (void)setPpuStatus:(NES_u8)ppuStatus {
    [self.bus writeConnectedBus:PPUSTATUS value:ppuStatus];
}

- (NES_u8)oamaddr {
    return [self.bus readConnectedBus:OAMADDR];
}

- (void)setOamaddr:(NES_u8)oamaddr {
    [self.bus writeConnectedBus:OAMADDR value:oamaddr];
}

- (NES_u8)oamdata {
    return [self.bus readConnectedBus:OAMDATA];
}

- (void)setOamdata:(NES_u8)oamdata {
    [self.bus writeConnectedBus:OAMDATA value:oamdata];
}

- (NES_u8)ppuscroll {
    return [self.bus readConnectedBus:PPUSCROLL];
}

- (void)setPpuscroll:(NES_u8)ppuscroll {
    [self.bus writeConnectedBus:PPUSCROLL value:ppuscroll];
}

- (NES_u8)ppudata {
    return [self.bus readConnectedBus:PPUDATA];
}

- (void)setPpudata:(NES_u8)ppudata {
    [self.bus writeConnectedBus:PPUDATA value:ppudata];
}

- (NES_u8)oamdma {
    return [self.bus readConnectedBus:OAMDMA];
}

- (void)setOamdma:(NES_u8)oamdma {
    [self.bus writeConnectedBus:OAMDMA value:oamdma];
}

- (void)clock {

}

- (PPUState)getPPUState {
    PPUState ppuState;

    ppuState.ppuCtrl = self.ppuCtrl;
    ppuState.ppuMask = self.ppuMask;
    ppuState.ppuStatus = self.ppuStatus;

    ppuState.oamaddr = self.oamaddr;
    ppuState.oamdata = self.oamdata;
    ppuState.ppuscroll = self.ppuscroll;
    ppuState.ppudata = self.ppudata;
    ppuState.oamdma = self.oamdma;

    ppuState.cycle = cycle;
    ppuState.elapsedCycle = elapsedCycle;

    return ppuState;
}

@end
