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

    [self setStatus];

    addressAbsolute = 0;
    addressRelative = 0;

    fetched = 0;

    sp = 0;
    pc = 0;

    accumulator = 0;
    x = 0;
    y = 0;

    return self;
}

- (void)setStatus:(uint8_t)statusBit bit:(uint8_t)bit; {
    if(bit == 1) {
        status |= 1 << statusBit;
    } else if(bit == 0) {
        status &= ~(1 << statusBit);
    } else {
        [NSException raise:@"ShouldNotHappen"
                    format:@"This should not happen in function @setStatus"];

    }
}

- (void)setStatus {
    status = -1;
}

- (uint8_t)getValueOfFlag:(uint8_t)flag {
    return (status >> flag) & 0x01;
}

- (void)setNegativeFlag:(uint16_t)value {
    [self setStatus:N bit:value & 0x080];
}

- (void)setOverflowFlag:(uint8)accumulator memory:(uint8)memory c:(uint16)c {
    [self setStatus:V bit:((uint16)accumulator ^ c) & ((uint16)memory ^ c) & 0x0080];
}

- (uint8_t)setZeroFlag:(uint8_t)value {
    return !value;
}

- (uint8_t)setCarryFlag:(uint16_t)value {
    return value & 0xFF00;
}

- (void)clock {
    if(cycles == 0) {
        opcode = [self read:pc];
        // TODO...
    }

    --cycles;
}

- (uint8_t)read:(uint16_t)address {
    return [_bus cpuRead:address];
}

- (uint8_t)fetch {
    PRINT_ADDRESS("fetch");

    // TODO: If is not implicit !!
    fetched = [self read:addressAbsolute];

    return fetched;
}

- (uint8_t)addressAccumulator {
    PRINT_ADDRESS("addressAccumulator");
    fetched = accumulator;
    return 0;
}

- (uint8_t)addressImmediate {
    PRINT_ADDRESS("addressImmediate");
    addressAbsolute = pc++;
    return 0;
}

- (uint8_t)addressAbsolute {
    PRINT_ADDRESS("addressAbsolute");
    addressAbsolute = [self read:pc++];
    addressAbsolute |= [self read:pc++] << 8;
    return 0;
}

- (uint8_t)addressZero {
    PRINT_ADDRESS("addressZero");
    addressAbsolute = [self read:pc++] & 0x0FF;
    return 0;
}

- (uint8_t)addressImplicit {
    PRINT_ADDRESS("addressImplicit");
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
        addressAbsolute = [self read:value + 1] << 8;
    } else {
        addressAbsolute = [self read:value & 0xFF00] << 8;
    }

    addressAbsolute |= [self read:value];

    return 0;
}

- (uint8_t)addressIndexedXIndirect {
    uint16_t lo = [self read:(uint16_t)[self read:pc] + x] & 0x00FF;
    uint16_t hi = [self read:(uint16_t)[self read:pc] + x + 1] & 0x00FF;

    addressAbsolute = (hi << 8) | lo;

    ++pc;

    return 0;
}

- (uint8_t)addClockCycleOnPageChange:(uint8_t)temp {
    return (addressAbsolute >> 8) == temp ? 0: 1;
}

- (uint8_t)addressIndexedYIndirect {
    // TODO: Check this
    uint16_t temp = [self read:(pc + 1) & 0x00FF];
    addressAbsolute = [self read:[self read:pc & 0x00FF] | (temp << 8) + y];

    ++pc;
    return [self addClockCycleOnPageChange:temp];
}

// TODO: Get rid of return and use it on the cycle variable
- (uint8_t) addressZeroX {
    addressAbsolute = ([self read:pc] + x) & 0x0FF;
    ++pc;
    return 0;
}

- (uint8_t)addressZeroY {
    addressAbsolute = ([self read:pc] + y) & 0x0FF;
    ++pc;
    return 0;
}

- (uint8_t)addressAbsoluteUtil:(uint8_t)xORy {
    addressAbsolute = [self read:pc++];
    uint8_t temp = [self read:pc++];
    addressAbsolute |= temp << 8;
    addressAbsolute += xORy;

    return [self addClockCycleOnPageChange:temp];
}

- (uint8_t)addressAbsoluteX {
    return [self addressAbsoluteUtil:x];
}

- (uint8_t)addressAbsoluteY {
    return [self addressAbsoluteUtil:y];
}

// Opcodes
- (uint8_t)opcodeADC {
    [self fetch];

    uint16_t sum = [self getValueOfFlag:C] + accumulator + fetched;

    [self setNegativeFlag:sum];
    [self setOverflowFlag:accumulator memory:fetched c:sum];

    accumulator = sum & 0x0FF;
    [self setZeroFlag:sum];
    [self setCarryFlag:sum];

    return 0;
}

- (uint8_t)opcodeAND {
    [self fetch];
    accumulator = accumulator & fetched;
    [self setNegativeFlag:accumulator];
    [self setZeroFlag:accumulator];
    return 1;
}

- (uint8_t)opcodeASL {
    [self fetch];

    uint16_t shift = fetched << 1;

    uint8_t temp = shift & 0x0FF;

    [self setNegativeFlag:shift];
    [self setZeroFlag:temp];
    [self setCarryFlag:shift];

    return 0;
}

- (void)branchOnSet:(int)flag set:(int)set {
    // Check flag is equal to the set value
    if([self getValueOfFlag:flag] == set) {
        addressAbsolute = pc + addressRelative;

        if((pc & 0xFF00) != (addressAbsolute & 0xFF00)) {
            ++cycles;
        }

        pc = addressAbsolute;
        ++cycles;
    }
}

- (uint8_t)opcodeBCC {
    [self branchOnSet:C set:0];
    return 0;
}

- (uint8_t)opcodeBCS {
    [self branchOnSet:C set:1];
    return 0;
}

@end
