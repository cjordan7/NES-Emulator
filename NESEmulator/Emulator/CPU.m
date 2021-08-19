//
//  CPU.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <inttypes.h>

#import "CPU.h"

#define DEBUGGING_ADDRESSES 1
#define DEBUGGING_OPCODES 1
#define DEBUGGING_CLOCK 1

#ifndef DEBUGGING_ADDRESSES
#define DEBUGGING_ADDRESSES 0
#endif

#ifndef DEBUGGING_OPCODES
#define DEBUGGING_OPCODES 0
#endif

#ifndef DEBUGGING_CLOCK
#define DEBUGGING_CLOCK 0
#endif

#define PRINT_ADDRESS(message,...)\
PRINT(1, message, ##__VA_ARGS__)

#define PRINT_OPCODE(message,...)\
PRINT(2, message, ##__VA_ARGS__)

#define PRINT_CLOCK(message,...)\
PRINT(3, message, ##__VA_ARGS__)


#define PRINT(value, message, ...)\
do { if (DEBUGGING_ADDRESSES && value == 1)\
Log(@"Address", message, ## __VA_ARGS__);\
} while (0);\
\
do { if (DEBUGGING_OPCODES && value == 2)\
Log(@"Opcode", message, ## __VA_ARGS__);\
} while (0);\
\
do { if (DEBUGGING_CLOCK && value == 3)\
Log(@"CLOCK", message, ## __VA_ARGS__);\
} while (0)

#define Log(type, message, ...)\
NSLog((@"" type ": Function %s - Line: %d\n\t\t" message),\
__PRETTY_FUNCTION__, __LINE__, ## __VA_ARGS__);

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


    addrAbsolute = 0;
    addrRelative = 0;

    fetched = 0;

    sp = 0;
    pc = 0;

    accumulator;
    x;
    y;

    return self;
}

- (void)setStatus:(int)statusBit bit:(int)bit; {
    if(bit == 1) {
        status |= 1 << statusBit;
    } else if(bit == 0) {
        status &= ~(1 << statusBit);
    } else {
        [NSException raise:@"ShouldNotHappen"
                    format:@"This should not happen in function @setStatus"];

    }
}

- (void)clock {
    if(cycles == 0) {
        opcode = [self read:pc];

    }

    --cycles;
}

- (uint8_t)read:(uint16_t)address {
    return [_bus cpuRead:address];
}

- (uint8_t)fetch {
    PRINT_ADDRESS("fetch");
    fetched = [self read:addrAbsolute];

    return fetched;
}

- (uint8_t)addressAccumulator {
    PRINT_ADDRESS("addressAccumulator");
    fetched = accumulator;
    return 0;
}

- (uint8_t)addressImmediate {
    PRINT_ADDRESS("addressImmediate");
    addrAbsolute = pc++;
    return 0;
}

- (uint8_t)addressAbsolute {
    PRINT_ADDRESS("addressAbsolute");
    addrAbsolute = [self read:pc++];
    addrAbsolute |= [self read:pc++] << 8;
    return 0;
}

- (uint8_t)addressZero {
    PRINT_ADDRESS("addressAbsolute");
    addrAbsolute = [self read:pc++] & 0x0FF;
    return 0;
}

- (uint8_t)addressImplied {
    PRINT_ADDRESS("addressImplied");
    fetched = accumulator;
    return 0;
}

- (uint8_t)addressRelative {
    PRINT_ADDRESS("addressRelative");
    return 0;
}

- (uint8_t)addressIndirect {
    PRINT_ADDRESS("addressIndirect");
    uint16_t lower = [self read:pc++];

    uint16_t value = ([self read:pc++] << 8) | lower;

    if(lower != 0x00FF) {
        addrAbsolute = ([self read:value + 1] << 8) | [self read:value];
    } else {
        addrAbsolute = ([self read:value & 0xFF00] << 8) | [self read:value];
    }

    return 0;
}


@end
