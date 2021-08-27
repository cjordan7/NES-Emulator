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
    uint32_t* screenPixels;
}

@property(nonatomic, strong) FileManager* fileManager;

@property(nonatomic, strong) NSArray* palette;

@property(nonatomic) NES_u8 ppuCtrl;
@property(nonatomic) NES_u8 ppuMask;
@property(nonatomic) NES_u8 ppuStatus;
@property(nonatomic) NES_u8 oamaddr;
@property(nonatomic) NES_u8 oamdata;
@property(nonatomic) NES_u8 ppuscroll;
@property(nonatomic) NES_u8 ppuAddress;
@property(nonatomic) NES_u8 ppuData;
@property(nonatomic) NES_u8 oamdma;



// TODO:...................................
@property(nonatomic) NES_u8 ppuDataBuffer;
@property(nonatomic) NES_u8 addressLatch;
// ........................................

// VRAM Address
@property(nonatomic) NES_u16 vramAddress;

// Temp VRAM Address
@property(nonatomic) NES_u16 tVRAMaddress;
@property(nonatomic) NES_u8 fineXScroll;
@property(nonatomic) NES_u8 FirstOrSecondWriteToggle;

@property(nonatomic, strong) Bus* mainBus;
@property(nonatomic, strong) Bus* ppuBus;

@end

@implementation PPU

- (instancetype)init {
    if(self = [super init]) {
        _fileManager = [[FileManager alloc] init];
        _palette = [_fileManager getPalette:@"nespalette"];
        self.oamaddr = 0;
        self.oamdata = 0;
        self.ppuscroll = 0;
        self.ppuAddress = 0;
        self.oamdma = 0;

        self.ppuDataBuffer = 0;
        self.addressLatch = 0;

        self.tVRAMaddress = 0;

        screenPixels = calloc(256*240, sizeof(uint32_t));
    }

    return self;
}

- (void)dealloc {
    free(screenPixels);
}

- (void)connectMainBus:(Bus*)bus {
    self.mainBus = bus;
}

- (void)connectPPUBus:(Bus*)bus {
    self.ppuBus = bus;
}

-(uint32_t*)getScreenPixels {
    return screenPixels;
}

// Some data may need changes
// TODO: Change name of function
- (void)notify:(NES_u16)modifiedRegister {
    if(modifiedRegister == 0x06) {
        if(self.addressLatch) {
            self.addressLatch = !self.addressLatch;
            self.tVRAMaddress = ((NES_u16)self.ppuAddress << 8) | (self.tVRAMaddress & 0x00FF);
        } else {
            self.addressLatch = !self.addressLatch;
            self.tVRAMaddress = (self.tVRAMaddress & 0xFF00) | self.ppuAddress;
            self.vramAddress = self.tVRAMaddress;
        }
    } else if(modifiedRegister == 0x07) {
        [self.ppuBus write:self.vramAddress value:self.ppuData];
    }
}

- (NES_u8)ppuCtrl {
    return [self.mainBus read:PPUCTRL];
}

- (void)setPpuCtrl:(NES_u8)ppuCtrl {
    [self.mainBus write:PPUCTRL value:ppuCtrl];
}

- (NES_u8)ppuMask {
    return [self.mainBus read:PPUMASK];
}

- (void)setPpuMask:(NES_u8)ppuMask {
    [self.mainBus write:PPUMASK value:ppuMask];
}

- (NES_u8)ppuStatus {
    return [self.mainBus read:PPUMASK];
}

- (void)setPpuStatus:(NES_u8)ppuStatus {
    [self.mainBus write:PPUSTATUS value:ppuStatus];
}

- (NES_u8)oamaddr {
    return [self.mainBus read:OAMADDR];
}

- (void)setOamaddr:(NES_u8)oamaddr {
    [self.mainBus write:OAMADDR value:oamaddr];
}

- (NES_u8)oamdata {
    return [self.mainBus read:OAMDATA];
}

- (void)setOamdata:(NES_u8)oamdata {
    [self.mainBus write:OAMDATA value:oamdata];
}

- (NES_u8)ppuscroll {
    return [self.mainBus read:PPUSCROLL];
}

- (void)setPpuscroll:(NES_u8)ppuscroll {
    [self.mainBus write:PPUSCROLL value:ppuscroll];
}

- (NES_u8)ppuData {
    return [self.mainBus read:PPUDATA];
}

- (void)setPpuData:(NES_u8)ppuData {
    [self.mainBus write:PPUDATA value:ppuData];
}

- (NES_u8)oamdma {
    return [self.mainBus read:OAMDMA];
}

- (void)setOamdma:(NES_u8)oamdma {
    [self.mainBus write:OAMDMA value:oamdma];
}

- (NES_u8)coarseXScroll:(NES_u16)tempOrVRAMAddress {
    return tempOrVRAMAddress & 0b011111;
}

- (NES_u8)coarseYScroll:(NES_u16)tempOrVRAMAddress {
    return (tempOrVRAMAddress >> 5) & 0b011111;
}

- (NES_u8)nametableSelect:(NES_u16)tempOrVRAMAddress {
    return (tempOrVRAMAddress >> 10) & 0b011;
}

- (NES_u8)fineYScroll:(NES_u16)tempOrVRAMAddress {
    return (tempOrVRAMAddress >> 12) & 0b0111;
}

#define V 8
#define P 7
#define H 6
#define B 5
#define S 3
#define I 2
#define NN 0
// VPHB SINN
- (NES_u8)ppuCtrlGetFlag:(NES_u8)flag {
    switch(flag) {
        case V:
        case P:
        case H:
        case B:
        case S:
            return (self.ppuCtrl >> flag) & 0b01;
        case NN:
            return self.ppuCtrl & 0b011;
        default:
            break;
    }

    return -1;
}

#define BGR 6
#define s 5
#define b 3
#define M 2
#define m 1
#define G 0
// BGRs bMmG
- (NES_u8)ppuMaskGetFlag:(NES_u8)flag {
    switch(flag) {
        case BGR:
            return (self.ppuMask >> flag) & 0b011;
        case s:
        case b:
        case M:
        case m:
        case G:
            return (self.ppuMask >> flag) & 0b01;
        default:
            break;
    }

    return -1;
}

#define V_St 7
#define S_St 6
#define O_St 5
// VSO- ----
- (NES_u8)ppuStatusGetFlag:(NES_u8)flag {
    switch(flag) {
        case V_St:
        case S_St:
        case O_St:
            return (self.ppuStatus >> flag) & 0b01;
        default:
            break;
    }

    return -1;
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
    ppuState.ppuData = self.ppuData;
    ppuState.oamdma = self.oamdma;

    ppuState.cycle = cycle;
    ppuState.elapsedCycle = elapsedCycle;

    return ppuState;
}

@end
