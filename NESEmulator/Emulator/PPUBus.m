//
//  PPUBus.m
//  NESEmulator
//
//  Created by Cosme Jordan on 26.08.21.
//

#import "PPUBus.h"

@implementation PPUBus

-(NES_u8)read:(NES_u16)address {
    return [super read:address];
}

- (void)write:(NES_u16)address value:(NES_u8)value {
    if((0x2000 <= address && address <= 0x2EFF) ||
       (0x3000 <= address && address <= 0x3EFF)) {
        NES_u16 temp = (address-0x2000) % 0x0F00;

        ram[0x2000 + temp] = value;
        ram[0x3000 + temp] = value;
    } else if((0x3F00 <= address && address <= 0x3F1F) ||
        (0x3F20 <= address && address <= 0x3FFF)) {
        NES_u16 temp = (address-0x3F00) % 0x00E0;

        ram[0x3F00 + temp] = value;
        ram[0x3F20 + temp] = value;
    } else {
        ram[address] = value;
    }
}

@end
