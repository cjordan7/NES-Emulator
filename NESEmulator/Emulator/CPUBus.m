//
//  CPUBus.m
//  NESEmulator
//
//  Created by Cosme Jordan on 26.08.21.
//

#import "CPUBus.h"

@implementation CPUBus

-(NES_u8)read:(NES_u16)address {
    return [super read:address];
}

- (void)write:(NES_u16)address value:(NES_u8)value {
    if(0x0000 <= address && address <= 0x1FFF) {
        // TODO: Better ?
        NES_u16 temp = address % 0x0800;

        ram[0x0000 + temp] = value;
        ram[0x0800 + temp] = value;
        ram[0x1000 + temp] = value;
    } else if(0x2000 <= address && address <= 0x3FFF) {
        NES_u16 temp = address % 0x08;

        for(NES_u16 i = 0x2000; i < 0x3fff-8; ++i) {
            ram[i + temp] = value;
        }
    } else {
        ram[address] = value;
    }
}

@end
