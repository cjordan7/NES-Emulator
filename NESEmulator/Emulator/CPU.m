//
//  CPU.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <inttypes.h>

#import "CPU.h"

@interface CPU ()
- (void)setStatus:(int)statusBit bit:(int)bit;

- (uint8_t) read:(uint16_t)address;

@end


@implementation CPU
    // MARK: Status bit 7 to bit 0
    static const int N = 7; // Negative
    static const int V = 6; // Overflow
    static const int DONT_CARE = 5; // ignored
    static const int B = 4; // Break
    static const int D = 3; // Decimal (use BCD for arithmetics)
    static const int I = 2; // Interrupt (IRQ disable)
    static const int Z = 1; // Zero
    static const int C = 0; // Carry

- (instancetype)init {
    self = [super init];

    memory = 0;
    opcode = 0;
    cycles = 0;

    status = 0;

    return self;
}

- (void)setStatus:(int)statusBit bit:(int)bit; {
    if(bit == 1) {
        status |= 1 << bit;
    } else if(bit == 0) {
        status &= ~(1 << bit);
    }
}

- (void)clock {
    if(cycles == 0) {
        opcode = [self read:pc];
        
    }

    --cycles;
}

- (uint8_t) read:(uint16_t)address {
    return [_bus cpuRead:address];
}


@end
