//
//  Mapper000.m
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import "Mapper000.h"

@implementation Mapper000

- (uint32_t)mapAddress:(NES_u16)address {
    if(0x0000 < address && address < 0x1FFF) {
        // PPU
        return address;
    } else if(0x8000 <= address && address <= 0xFFFF) {
        // CPU
        return (address - 0x8000);
    }

    NSLog(@"This should not happen");
    return -1;
}

@end
