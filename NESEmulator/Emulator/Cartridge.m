//
//  Cartridge.m
//  NESEmulator
//
//  Created by Cosme Jordan on 20.08.21.
//

#import "Cartridge.h"
#import "FileManager.h"
#import "Mappers/Mapper.h"
#import "Mappers/Mapper000.h"

@interface Cartridge() {
    NES_u8* chrMemory;
    NES_u8* pgrROM;

    NES_u8* trainer;

    uint32_t* grayscalePtr;
}


@property(nonatomic, strong) FileManager* fileManager;
@property(nonatomic, strong) Mapper* mapper;

@property(nonatomic, readwrite, getter=hasRAM) BOOL hasRAM;
@property(nonatomic, readwrite, getter=isValid) BOOL isValid;
@end

@implementation Cartridge

- (instancetype)initName:(NSString*)name type:(NSString*)type {
    // TODO: Allow user interface

    if(self = [super init]) {
        chrMemory = NULL;
        pgrROM = NULL;

        grayscalePtr = NULL;

        _fileManager = [[FileManager alloc] init];

        ByteArray byteArray = [_fileManager readFileBytes:name type:type];

        [self parseFile:byteArray];

        self.isValid = NO;
        self.hasRAM = NO;
    }

    return self;
}

- (void)dealloc {
    free(chrMemory);
    free(pgrROM);
    free(grayscalePtr);
}

- (void)parseFile:(ByteArray)byteArray {
    // Bytes 0-3: $4E $45 $53 $1A ("NES" and MS-DOS (aka end-of-file))
    if(byteArray.bytePtr[0] == 0x4E &&
       byteArray.bytePtr[1] == 0x45 &&
       byteArray.bytePtr[2] == 0x53 &&
       byteArray.bytePtr[3] == 0x1A) {
        // Check what format it is: either a NES2.0 or iNES
        if(byteArray.bytePtr[4] == 0x08) {
            [self handleNES2Dot0Format:byteArray];
        } else {
            [self handleINESFormat:byteArray];
        }
    }

    //
    // TODO: Handle Error
}

- (void)handleINESFormat:(ByteArray)byteArray {
    // Byte 4: Size of PRG ROM (16 KB units)
    uint32_t prgROMSize = byteArray.bytePtr[4];

    pgrROM = calloc(prgROMSize*16384, sizeof(NES_u8));

    // Byte 5: Size of CHR ROM (8 KB units). If 0, then uses CHR RAM.
    uint32_t chrSize = byteArray.bytePtr[5];

    if(!chrSize) {
        // This is a RAM now
        chrSize = byteArray.bytePtr[8];
        self.hasRAM = YES;
    }

    chrMemory = calloc(chrSize*8192, sizeof(NES_u8));
    grayscalePtr = calloc(chrSize*8192, sizeof(chrMemory));


    // Byte 6: Mapper, mirroring, battery, trainer: ()
    uint32_t mapperNumber = (byteArray.bytePtr[6] >> 4) | (byteArray.bytePtr[7] &0xF0);
    [self setMapperWithInt:mapperNumber];

    uint32_t flagSix = byteArray.bytePtr[6];
    self.mirroring = flagSix & 0x01 ? VERTICAL_MIRRORING: HORIZONTAL_MIRRORING;
    self.mirroring = (flagSix >> 3) & 0x01 ? FOUR_SCREEN: self.mirroring;
    BOOL isTrainerPresent = byteArray.bytePtr[6] & 0x04;

    uint32_t index = 16;
    if(isTrainerPresent) {
        trainer = calloc(512, sizeof(NES_u8));
        memcpy(trainer, &byteArray.bytePtr[index], 512*sizeof(NES_u8));
        index += 512;
    } else {
        trainer = nil;
    }

    // TODO: flag 7, 9 and 10 ???

    memcpy(pgrROM, &byteArray.bytePtr[index], prgROMSize*16384*sizeof(NES_u8));
    index += prgROMSize*16384;

    memcpy(chrMemory, &byteArray.bytePtr[index], chrSize*8192*sizeof(NES_u8));

    self.isValid = YES;
}

- (void)handleNES2Dot0Format:(ByteArray)byteArray {

}

- (void)setMapperWithInt:(uint32_t)mapperNumber {
    switch(mapperNumber) {
        case 0:
            self.mapper = [[Mapper000 alloc] init];
            break;
        default:
            // TODO: Error
            NSLog(@"This should not happen");
            break;
    }
}

- (NES_u8)read:(NES_u16)address {
    uint32_t mapped = [self.mapper mapAddress:address];

    if(0x0000 < address && address < 0x1FFF) {
        // PPU
        return chrMemory[mapped];
    } else if(0x8000 <= address && address <= 0xFFFF) {
        // CPU
        return pgrROM[mapped];
    }

    NSLog(@"This should not happen");
    return -1;
}

- (void)write:(NES_u16)address value:(NES_u8)value {
    if(!self.hasRAM) {
        assert(false);
        // TODO: Handle error. Or throw exception
        NSLog(@"Error");
    }

    uint32_t mapped = [self.mapper mapAddress:address];

    if(0x0000 < address && address < 0x1FFF) {
        // PPU
        chrMemory[mapped] = value;
    } else if(0x8000 <= address && address <= 0xFFFF) {
        // CPU
        pgrROM[mapped] = value;
    }
}

- (NES_u8*)getCHRMemory {
    return chrMemory;
}

- (NES_u8*)getPGRRom {
    return pgrROM;
}

- (uint32_t*)grayscaleCHR {
    int size = sizeof(chrMemory)/chrMemory[0];
    grayscalePtr = calloc(size, sizeof(chrMemory));
    for(int i = 0; i < size; ++i) {
        grayscalePtr[i] = 0xFF000000 | chrMemory[i] | chrMemory[i] | chrMemory[i];
    }

    return grayscalePtr;
}

@end
