//
//  Bus.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "Bus.h"

@implementation Bus

- (id)init {
    self = [super init];

    for(int i = 0; i < 2*1024; ++i) {
        ram[i] = 0;
    }

    return self;
}

- (uint8_t)cpuRead:(uint16_t)address {
    return ram[address];
}

@end
