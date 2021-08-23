//
//  Bus.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "Bus.h"
#import "../Utils.h"

@implementation Bus

- (id)init {
    if(self = [super init]) {

        for(int i = 0; i < 2*1024; ++i) {
            ram[i] = 0;
        }
    }

    return self;
}

- (uint8_t)cpuRead:(uint16_t)address {
    return ram[address];
}

- (void)cpuWrite:(NES_u16)address value:(NES_u8)value {
    ram[address] = value;
}

@end
