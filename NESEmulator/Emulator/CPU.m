//
//  CPU.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <inttypes.h>
#import "Debug.h"

#import "CPU.h"
#import "../Utils.h"
#import "FileManager.h"
#import "OpcodeWrapper.h"
#import "../Container/Queue.h"

#define BOTTOM_STACK 0x0100

#define POTENTIAL_ADDITIONAL_CYCLE 1
#define NO_ADDITIONAL_CYCLE 0

#define DEBUGGING_BREAKPOINT

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

@interface CPU() {
    uint64 elapsedClock;
    NES_u8 cycles;

    NES_u8 opcode;

    // Status registers
    NES_u8 status;

    // Addresses
    NES_u16 addressAbsolute;
    NES_u16 addressRelative;

    // Get data according to addressing mode
    NES_u8 fetched;

    // MARK: List of registers
    NES_u8 accumulator;
    NES_u8 x;
    NES_u8 y;

    // Stack Pointer
    NES_u8 sp;

    // Program Counter
    NES_u16 pc;


    // TODO: Remove line RAM
    uint8_t disasembleTest[309];
}

@property(nonatomic) NES_u8 N; // Negative
@property(nonatomic) NES_u8 V; // Overflow
@property(nonatomic) NES_u8 DONT_CARE; // Ignored
@property(nonatomic) NES_u8 B; // Break
@property(nonatomic) NES_u8 D; // Decimal (use BCD for arithmetics)
@property(nonatomic) NES_u8 I; // Interrupt (IRQ disable)
@property(nonatomic) NES_u8 Z; // Zero
@property(nonatomic) NES_u8 C; // Carry

// To read opcodes
@property(nonatomic, strong) FileManager* fileReader;

// To read opcodes
@property(nonatomic, strong, readonly) NSArray* opcodeWrappers;

@end

@implementation CPU
// MARK: Status bit 7 to bit 0
static const NES_u8 N_BIT = 1 << 7; // Negative
static const NES_u8 V_BIT = 1 << 6; // Overflow
UNUSED static const NES_u8 DONT_CARE_BIT = 1 << 5; // Ignored
static const NES_u8 B_BIT = 1 << 4; // Break
static const NES_u8 D_BIT = 1 << 3; // Decimal (use BCD for arithmetics)
static const NES_u8 I_BIT = 1 << 2; // Interrupt (IRQ disable)
static const NES_u8 Z_BIT = 1 << 1; // Zero
static const NES_u8 C_BIT = 1 << 0; // Carry

- (instancetype)init {
    if(self = [super init]) {
        elapsedClock = 0;

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

        _fileReader = [[FileManager alloc] init];
        [self nullCheck:_fileReader name:@"fileReader"];

        _opcodeWrappers = [_fileReader getOpcodeWrappers];
        [self nullCheck:_opcodeWrappers name:@"opcodeWrappers"];


        uint8_t disasembleTest2[] = {0x20, 0x06, 0x06, 0x20, 0x38, 0x06, 0x20, 0x0d, 0x06, 0x20, 0x2a, 0x06, 0x60, 0xa9, 0x02, 0x85,
            0x02, 0xa9, 0x04, 0x85, 0x03, 0xa9, 0x11, 0x85, 0x10, 0xa9, 0x10, 0x85, 0x12, 0xa9, 0x0f, 0x85,
            0x14, 0xa9, 0x04, 0x85, 0x11, 0x85, 0x13, 0x85, 0x15, 0x60, 0xa5, 0xfe, 0x85, 0x00, 0xa5, 0xfe,
            0x29, 0x03, 0x18, 0x69, 0x02, 0x85, 0x01, 0x60, 0x20, 0x4d, 0x06, 0x20, 0x8d, 0x06, 0x20, 0xc3,
            0x06, 0x20, 0x19, 0x07, 0x20, 0x20, 0x07, 0x20, 0x2d, 0x07, 0x4c, 0x38, 0x06, 0xa5, 0xff, 0xc9,
            0x77, 0xf0, 0x0d, 0xc9, 0x64, 0xf0, 0x14, 0xc9, 0x73, 0xf0, 0x1b, 0xc9, 0x61, 0xf0, 0x22, 0x60,
            0xa9, 0x04, 0x24, 0x02, 0xd0, 0x26, 0xa9, 0x01, 0x85, 0x02, 0x60, 0xa9, 0x08, 0x24, 0x02, 0xd0,
            0x1b, 0xa9, 0x02, 0x85, 0x02, 0x60, 0xa9, 0x01, 0x24, 0x02, 0xd0, 0x10, 0xa9, 0x04, 0x85, 0x02,
            0x60, 0xa9, 0x02, 0x24, 0x02, 0xd0, 0x05, 0xa9, 0x08, 0x85, 0x02, 0x60, 0x60, 0x20, 0x94, 0x06,
            0x20, 0xa8, 0x06, 0x60, 0xa5, 0x00, 0xc5, 0x10, 0xd0, 0x0d, 0xa5, 0x01, 0xc5, 0x11, 0xd0, 0x07,
            0xe6, 0x03, 0xe6, 0x03, 0x20, 0x2a, 0x06, 0x60, 0xa2, 0x02, 0xb5, 0x10, 0xc5, 0x10, 0xd0, 0x06,
            0xb5, 0x11, 0xc5, 0x11, 0xf0, 0x09, 0xe8, 0xe8, 0xe4, 0x03, 0xf0, 0x06, 0x4c, 0xaa, 0x06, 0x4c,
            0x35, 0x07, 0x60, 0xa6, 0x03, 0xca, 0x8a, 0xb5, 0x10, 0x95, 0x12, 0xca, 0x10, 0xf9, 0xa5, 0x02,
            0x4a, 0xb0, 0x09, 0x4a, 0xb0, 0x19, 0x4a, 0xb0, 0x1f, 0x4a, 0xb0, 0x2f, 0xa5, 0x10, 0x38, 0xe9,
            0x20, 0x85, 0x10, 0x90, 0x01, 0x60, 0xc6, 0x11, 0xa9, 0x01, 0xc5, 0x11, 0xf0, 0x28, 0x60, 0xe6,
            0x10, 0xa9, 0x1f, 0x24, 0x10, 0xf0, 0x1f, 0x60, 0xa5, 0x10, 0x18, 0x69, 0x20, 0x85, 0x10, 0xb0,
            0x01, 0x60, 0xe6, 0x11, 0xa9, 0x06, 0xc5, 0x11, 0xf0, 0x0c, 0x60, 0xc6, 0x10, 0xa5, 0x10, 0x29,
            0x1f, 0xc9, 0x1f, 0xf0, 0x01, 0x60, 0x4c, 0x35, 0x07, 0xa0, 0x00, 0xa5, 0xfe, 0x91, 0x00, 0x60,
            0xa6, 0x03, 0xa9, 0x00, 0x81, 0x10, 0xa2, 0x00, 0xa9, 0x01, 0x81, 0x10, 0x60, 0xa2, 0x00, 0xea,
            0xea, 0xca, 0xd0, 0xfb, 0x60
        };

        memcpy(disasembleTest, disasembleTest2, 309*sizeof(uint8_t));

//        [self DEBUGDisassemble:0 end:309];

    }
    return self;
}

- (void)connectBus:(Bus*)bus {
    _bus = bus;
}

//==============================================================================
// Utils functions

- (void)nullCheck:(id)element name:(NSString*)name {
    if(!element) {
        NSString* format = [NSString stringWithFormat:@"The element: %@ was nil",
                            name];
        [NSException raise:@"Element is nil"
                    format:@"%@", format];
    }
}

- (NES_u8)addClockCycleOnPageChange:(NES_u8)temp {
    return addressAbsolute & 0x0100;
}

- (NES_u8)addressAbsoluteUtil:(NES_u8)xORy {
    addressAbsolute = [self read:pc];
    ++pc;
    ++pc;
    addressAbsolute += xORy;

    return [self addClockCycleOnPageChange:addressAbsolute >> 8];
}

- (void)setStatus:(NES_u8)statusBit bit:(NES_u8)bit; {
    if(bit) {
        status |= statusBit;
    } else  {
        status &= ~statusBit;
    }
}
- (void)setStatus {
    status = -1;
}

- (NES_u8)getValueOfFlag:(NES_u8)flag {
    return status & flag;
}

//==============================================================================
// Setters and getters override

- (void)setN:(NES_u8)N {
    [self setStatus:N_BIT bit:N];
}

- (NES_u8)N {
    return [self getValueOfFlag:N_BIT];
}

- (NES_u8)DONT_CARE {
    return [self getValueOfFlag:DONT_CARE_BIT];
}

- (void)setDONT_CARE:(NES_u8)DONT_CARE {
    [self setStatus:V_BIT bit:DONT_CARE];
}

- (void)setV:(NES_u8)V {
    [self setStatus:V_BIT bit:V];
}

- (NES_u8)V {
    return [self getValueOfFlag:V_BIT];
}

- (void)setB:(NES_u8)B {
    [self setStatus:B_BIT bit:B];
}

- (NES_u8)B {
    return [self getValueOfFlag:B_BIT];
}

- (void)setD:(NES_u8)D {
    [self setStatus:D_BIT bit:D];
}

- (NES_u8)D {
    return [self getValueOfFlag:D_BIT];
}

- (void)setI:(NES_u8)I {
    [self setStatus:I_BIT bit:I];
}

- (NES_u8)I {
    return [self getValueOfFlag:I_BIT];
}

- (void)setZ:(NES_u8)Z {
    [self setStatus:Z_BIT bit:Z];
}

- (NES_u8)Z {
    return [self getValueOfFlag:Z_BIT];
}

- (void)setC:(NES_u8)C {
    [self setStatus:C_BIT bit:C];
}

- (NES_u8)C {
    return [self getValueOfFlag:C_BIT];
}

//==============================================================================
// Set flags

// Set Negative Flag
- (NES_u8)calculateN:(NES_u16)value {
    return value & 0x080;
}

// Set Overflow Flag
- (NES_u8)calculateV:(NES_u8)accumulator fetched:(NES_u8)fetched c:(NES_u16)c {
    return ((NES_u16)accumulator ^ c) & ((NES_u16)fetched ^ c) & 0x0080;
}

// Set Zero flag
- (NES_u8)calculateZ:(NES_u8)value {
    return !value;
}

// Set Carry flag
- (NES_u8)calculateC:(NES_u16)value {
    return value & 0xFF00;
}

//==============================================================================
// CPU Processing Methods

- (void)clock {
#ifdef DEBUGGING_BREAKPOINT
    if(dMode != DPause) {
#endif

        if(cycles == 0) {
#ifdef DEBUGGING_BREAKPOINT
            if(dMode == DStep) {
                dMode = DPause;
                return;
            }
#endif

            opcode = [self read:pc];
            // TODO...
        }

        ++elapsedClock;
        --cycles;
#ifdef DEBUGGING_BREAKPOINT
    }
#endif

}

- (NES_u8)fetch {
    PRINT_ADDRESS("");

    // TODO: If is not implicit !!
    fetched = [self read:addressAbsolute];

    return fetched;
}

//==============================================================================
// Read and Write functions

- (NES_u16)read16:(NES_u16)address {
    NES_u16 lo = [self read:address];
    NES_u16 hi = [self read:address+1];

    return (hi << 8) | lo;
}

- (void)write16:(NES_u16)address value:(NES_u16)value {
    [self write:address value:value & 0x00FF];
    [self write:address+1 value:value >> 8];
}

- (NES_u8)read:(NES_u16)address {
    return [self.bus read:address];
}

- (void)write:(NES_u16)address value:(NES_u8)value {
    [self.bus write:address value:value];
}

- (NES_u8)pop {
    NES_u8 temp = [self.bus read:BOTTOM_STACK + sp];
    ++sp;
    return temp;
}

- (void)push:(NES_u8)value {
    [self.bus write:BOTTOM_STACK + sp value:value];
    --sp;
}

- (NES_u16)pop16 {
    NES_u16 temp = (NES_u16)[self pop];
    temp |= (NES_u16)[self pop] << 8;
    return temp;
}

- (void)push16:(NES_u16)value {
    [self push:(value >> 8) & 0x00FF];
    [self push:value & 0x00FF];
}

//==============================================================================
// Absolute Addressing Modes

- (NES_u8)addressAbsolute {
    PRINT_ADDRESS("");
    addressAbsolute = [self read16:pc];
    ++pc;
    ++pc;
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)addressAbsoluteX {
    PRINT_ADDRESS("");
    return [self addressAbsoluteUtil:x];
}

- (NES_u8)addressAbsoluteY {
    PRINT_ADDRESS("");
    return [self addressAbsoluteUtil:y];
}

//==============================================================================
// Accumulator Addressing Mode

- (NES_u8)addressAccumulator {
    PRINT_ADDRESS("");
    fetched = accumulator;
    return NO_ADDITIONAL_CYCLE;
}

//==============================================================================
// Immediate Addressing Mode

- (NES_u8)addressImmediate {
    PRINT_ADDRESS("");
    addressAbsolute = pc++;
    return NO_ADDITIONAL_CYCLE;
}

//==============================================================================
// Implicit Addressing Mode

- (NES_u8)addressImplicit {
    PRINT_ADDRESS("");
    return NO_ADDITIONAL_CYCLE;
}

//==============================================================================
// Indirect Addressing Modes

- (NES_u8)addressIndirect {
    PRINT_ADDRESS("");
    NES_u16 lower = [self read:pc++];

    NES_u16 value = ([self read:pc++] << 8) | lower;

    if(lower != 0x00FF) {
        addressAbsolute = [self read:value + 1] << 8;
    } else {
        addressAbsolute = [self read:value & 0xFF00] << 8;
    }

    addressAbsolute |= [self read:value];

    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)addressIndexedXIndirect {
    PRINT_ADDRESS("");
    NES_u16 lo = [self read:(NES_u16)[self read:pc] + x] & 0x00FF;
    NES_u16 hi = [self read:(NES_u16)[self read:pc] + x + 1] & 0x00FF;

    addressAbsolute = (hi << 8) | lo;

    ++pc;

    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)addressIndexedYIndirect {
    PRINT_ADDRESS("");
    // TODO: Check this
    NES_u16 temp = [self read:(pc + 1) & 0x00FF];
    addressAbsolute = [self read:[self read:pc & 0x00FF] | (temp << 8) + y];

    ++pc;
    return [self addClockCycleOnPageChange:temp];
}

//==============================================================================
// Relative Addressing Mode

- (NES_u8)addressRelative {
    PRINT_ADDRESS("");
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)addressZero {
    PRINT_ADDRESS("");
    addressAbsolute = [self read:pc++] & 0x0FF;
    return NO_ADDITIONAL_CYCLE;
}

// TODO: Get rid of return and use it on the cycle variable
- (NES_u8) addressZeroX {
    PRINT_ADDRESS("");
    addressAbsolute = ([self read:pc] + x) & 0x0FF;
    ++pc;
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)addressZeroY {
    PRINT_ADDRESS("");
    addressAbsolute = ([self read:pc] + y) & 0x0FF;
    ++pc;
    return NO_ADDITIONAL_CYCLE;
}

//==============================================================================
// Official Opcodes

// ADC - Add with Carry
- (void)opcodeADC {
    PRINT_OPCODE("");
    //    [self fetch];

    NES_u16 sum = self.C + accumulator + [self fetch];

    self.N = [self calculateN:sum];
    self.V = [self calculateV:accumulator fetched:fetched c:sum];

    accumulator = sum & 0x0FF;
    self.Z = [self calculateZ:sum & 0x0FF];
    self.C = [self calculateC:sum];
}

// AND - Logical AND
- (void)opcodeAND {
    PRINT_OPCODE("");
    //    [self fetch];
    accumulator = accumulator & [self fetch];
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];
}

// ASL - Arithmetic Left Shift
- (void)opcodeASL {
    PRINT_OPCODE("");
    //    [self fetch];

    NES_u16 shift = [self fetch] << 1;

    self.N = [self calculateN:shift];
    self.Z = [self calculateZ:shift & 0x0FF];
    self.C = [self calculateC:shift];
}

// Branching instructions
- (void)branchOn:(NES_u8)flag set:(NES_u8)set {
    // Check flag is equal to the set value
    if(flag == set) {
        addressAbsolute = pc + addressRelative;

        // Crosses page boundary
        if((pc & 0xFF00) != (addressAbsolute & 0xFF00)) {
            ++cycles;
        }

        pc = addressAbsolute;
        ++cycles;
    }
}

- (void)branchOnSet:(NES_u8)flag {
    [self branchOn:flag set:1];
}

- (void)branchOnClear:(NES_u8)flag {
    [self branchOn:flag set:0];
}

// BMI
- (void)opcodeBMI {
    PRINT_OPCODE("");
    [self branchOnSet:self.N];
}

// BPL - Branch if Positive
- (void)opcodeBPL {
    PRINT_OPCODE("");
    [self branchOnClear:self.N];
}

// BVS - Branch if Overflow Set
- (void)opcodeBVS {
    PRINT_OPCODE("");
    [self branchOnSet:self.V];
}

// BVC - Branch if Overflow Clear
- (void)opcodeBVC {
    PRINT_OPCODE("");
    [self branchOnClear:self.V];
}

// BCS - Branch if Carry Set
- (void)opcodeBCS {
    PRINT_OPCODE("");
    [self branchOnSet:self.C];
}

// BCC - Branch if Carry Clear
- (void)opcodeBCC {
    PRINT_OPCODE("");
    [self branchOnClear:self.C];
}

// BEQ - Branch if Equal
- (void)opcodeBEQ {
    PRINT_OPCODE("");
    [self branchOnSet:self.Z];
}

// BNE - Branch if Not Equal
- (void)opcodeBNE {
    PRINT_OPCODE("");
    [self branchOnClear:self.Z];
}

// BIT - Bit Test
- (void)opcodeBIT {
    PRINT_OPCODE("");
    [self fetch];

    NES_u8 bit = accumulator & fetched;

    self.N = fetched & 0x080;
    self.V = fetched & 0x040;
    self.Z = [self calculateZ:bit];
}

// BRK - Force Interrupt
- (void)opcodeBRK {
    PRINT_OPCODE("");
    // TODO
}

// CLC - Clear Carry (C) Flag
- (void)opcodeCLC {
    PRINT_OPCODE("");
    self.C = 0;
}

// CLD - Clear Decimal Mode (D)
- (void)opcodeCLD {
    PRINT_OPCODE("");
    self.D = 0;
}

// CLI - Clear Interrupt Disable (I) Flag
- (void)opcodeCLI {
    PRINT_OPCODE("");
    self.I = 0;
}

// CLV - Clear Overflow (V) Flag
- (void)opcodeCLV {
    PRINT_OPCODE("");
    self.V = 0;
}

// Comparison Opcodes
- (void)compareOpcodes:(NES_u8)value {
    [self fetch];
    NES_u16 substraction = value - fetched;
    self.N = [self calculateN:substraction];
    self.Z = [self calculateZ:substraction & 0x0FF];
    self.C = [self calculateC:value >= fetched];
}

// CMP - Compare Accumulator
- (void)opcodeCMP {
    PRINT_OPCODE("");
    [self compareOpcodes:accumulator];
}

// CPX - Compare X Register
- (void)opcodeCPX {
    PRINT_OPCODE("");
    [self compareOpcodes:x];
}

// CPY - Compare Y Register
- (void) opcodeCPY {
    PRINT_OPCODE();
    [self compareOpcodes:y];
}

- (void)opcodeMemoryOp:(int)value {
    // TODO:...
}

// DEC - Decrement Memory
- (void)opcodeDEC {
    PRINT_OPCODE("");
    NES_u16 memory = [self fetch] - 1;

    self.N = [self calculateN:memory];
    self.Z = [self calculateZ:memory];

    [self write:addressAbsolute value:memory & 0x0FF];
}

// INC - Increment Memory
- (void)opcodeINC {
    PRINT_OPCODE("");
    [self fetch];
    NES_u16 value = fetched + 1;

    self.N = [self calculateN:fetched];
    self.Z = [self calculateZ:fetched];

    [self write:addressAbsolute value:value & 0x0FF];
}

- (NES_u8)decrementOpcode:(NES_u8)value {
    --value;

    self.N = [self calculateN:value];
    self.Z = [self calculateZ:value];
    return value;
}

// DEX - Decrement X Register
- (void)opcodeDEX {
    PRINT_OPCODE("");
    x = [self decrementOpcode:x];
}

// DEY - Decrement Y Register
- (void)opcodeDEY {
    PRINT_OPCODE("");
    y = [self decrementOpcode:y];
}

// EOR - Exclusive OR
- (void)opcodeEOR {
    PRINT_OPCODE("");
    [self fetch];
    accumulator ^= fetched;
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];

    // FIXME: TODO
}

- (NES_u8)incrementOpcode:(NES_u8)value {
    ++value;

    self.N = [self calculateN:value];
    self.Z = [self calculateZ:value];

    return value;
}

// INX - Increment X Register
- (void)opcodeINX {
    PRINT_OPCODE("");
    x = [self incrementOpcode:x];
}

// INY - Increment Y Register
- (void)opcodeINY {
    PRINT_OPCODE("");
    y = [self incrementOpcode:y];
}

// JMP - Jump
- (void)opcodeJMP {
    PRINT_OPCODE("");
    pc = addressAbsolute;
}

// JSR - Jump To Subroutine
- (void)opcodeJSR {
    --pc;
    [self push16:pc];
    pc = addressAbsolute;
}

- (NES_u8)LDFunctions {
    [self fetch];

    NES_u8 value = fetched;
    self.N = [self calculateN:value];
    self.Z = [self calculateZ:value];

    return value;
}

// LDA - Load Accumulator
- (void)opcodeLDA {
    accumulator = [self LDFunctions];
}

// LDX - Load X Register
- (void)opcodeLDX {
    x = [self LDFunctions];
}

// LDY - Load Y Register
- (void)opcodeLDY {
    y = [self LDFunctions];
}

// LSR - Logical Shift Right
- (void)opcodeLSR {
    [self fetch];

    self.C = [self calculateC:fetched];
    uint16_t shifted = fetched >> 1;

    self.N = [self calculateN:shifted];
    self.Z = [self calculateZ:shifted];

    // TODO: Implied
}

// ORA - Logical Inclusive OR
- (void)opcodeORA {
    [self fetch];

    accumulator |= fetched;
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];
}

// PHA - Push Accumulator
- (void)opcodePHA {
    [self push:accumulator];
}

// PHP - Push Processor Status
- (void)opcodePHP {
    [self push:status | self.DONT_CARE | self.B];
    self.B = 0;
    self.DONT_CARE = 0;
}

// PLA - Pull Accumulator
- (void)opcodePLA {
    accumulator = [self pop];

    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];
}

// PLP - Pull Processor Status
- (void)opcodePLP {
    status = [self pop];
    self.DONT_CARE = 1;
}

// ROL - Rotate Left
- (void)opcodeROL {
    [self fetch];

    uint16_t temp = (fetched << 1) | self.C;
    self.N = [self calculateN:temp];
    self.Z = [self calculateZ:temp];
    self.C = [self calculateC:temp];

    // TODO: implied
}

// ROR - Rotate Right
- (void)opcodeROR {
    [self fetch];

    uint16_t temp = (self.C << 7) | (fetched >> 1);

    self.N = [self calculateN:temp];
    self.Z = [self calculateZ:temp];
    self.C = [self calculateC:temp];

    // TODO: implied
}

// RTI - Return from Interrupt
- (void)opcodeRTI {
    status = [self pop];

    status &= ~B_BIT;
    status &= ~DONT_CARE_BIT;

    pc = [self pop16];
}

// RTS - Return from Subroutine
- (void)opcodeRTS {
    pc = [self pop16];
}

// SBC - Subtract with Carry
- (void)opcodeSBC {
    // FIXME: TODO
}

// SEC - Set Carry Flag
- (void)opcodeSEC {
    self.C = 1;
}

// SEC - Set Decimal Flag
- (void)opcodeSED {
    self.D = 1;
}

// SEC - Set Interrupt Flag
- (void)opcodeSEI {
    self.I = 1;
}

// STA - Store Accumulator
- (void)opcodeSTA {
    [self write:addressAbsolute value:accumulator];
}

// STX - Store X
- (void)opcodeSTX {
    [self write:addressAbsolute value:x];
}

// STY - Store Y
- (void)opcodeSTY {
    [self write:addressAbsolute value:y];
}

// TAX - Transfer A to X
- (void)opcodeTAX {
    x = accumulator;
    self.N = [self calculateN:x];
    self.Z = [self calculateZ:x];
}

// TAY - Transfer A to Y
- (void)opcodeTAY {
    y = accumulator;
    self.N = [self calculateN:y];
    self.Z = [self calculateZ:y];
}

// TSX - Transfer SP to X
- (void)opcodeTSX {
    x = sp;
    self.N = [self calculateN:x];
    self.Z = [self calculateZ:x];
}

// TXA - Transfer X to Accumulator
- (void)opcodeTXA {
    accumulator = x;
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];
}

// TXA - Transfer SP to X
- (void)opcodeTXS {
    sp = x;
}

// TXA - Transfer Y to AccumulatoX
- (void)opcodeTYA {
    accumulator = y;
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];
}

- (void)interruptNMI {
    [self push:(pc >> 8) & 0x00FF];
    [self push:pc & 0x00FF];

    self.B = 0;
    self.DONT_CARE = 1;
    self.I = 1;

    [self push:status];

    addressAbsolute = 0xFFFA;
    pc = [self read16:addressAbsolute];

    cycles = 8;
}

- (void)powerUp {
    addressAbsolute = 0xFFFC;

    pc = [self read16:addressAbsolute];

    accumulator = 0;
    x = 0;
    y = 0;
    sp = 0xFD;

    status = 0;
    self.DONT_CARE = 1;

    fetched = 0;
    addressAbsolute = 0;

    cycles = 8;
}

// Interrupt Request
- (void)interruptIRQ {
    // TODO Refactor and understand that

    if(self.I == 0) {
        [self push16:pc];

        self.I = 1;
        self.DONT_CARE = 1;
        self.B = 0;

        [self push:status];

        addressAbsolute = 0xFFFE;
        pc = [self read16:addressAbsolute];

        cycles = 7;
    }
}

- (void)opcodeNOP {
}

// =============================================================================
// Illegal Opcodes
- (void)opcodeSKB {
}

- (void)opcodeIGN {
}

- (void)opcodeALR {
}

- (void)opcodeANC {
}

- (void)opcodeARR {
}

- (void)opcodeAXS {
}

- (void)opcodeLAX {
}

- (void)opcodeSAX {
}

- (void)opcodeDCP {
}

- (void)opcodeISC {
}

- (void)opcodeRLA {
}

- (void)opcodeRRA {
}

- (void)opcodeSLO {
}

- (void)opcodeSRE {
}

- (void)opcodeXAA {
}

- (void)opcodeAHX {
}

- (void)opcodeSHX {
}

- (void)opcodeTAS {
}

- (void)opcodeSHY {
}

- (void)opcodeLAS {
}



// =============================================================================
// Debugging functions

- (CPUState)DEBUGgetCPUState {
    CPUState cpuState;

    cpuState.elapsedClock = elapsedClock;
    cpuState.cycles = cycles;
    cpuState.opcode = opcode;

    // Status Register
    cpuState.status = status;
    cpuState.N = self.N;
    cpuState.V = self.V;
    cpuState.B = self.B;
    cpuState.D = self.D;
    cpuState.I_ = self.I;
    cpuState.Z = self.Z;
    cpuState.C = self.C;

    // Addresses
    cpuState.addressAbsolute = addressAbsolute;
    cpuState.addressRelative = addressRelative;

    // Get data according to addressing mode
    cpuState.fetched = fetched;

    // MARK: List of registers
    cpuState.accumulator = accumulator;
    cpuState.x = x;
    cpuState.y = y;

    // Stack Pointer
    cpuState.sp = sp;

    // Program Counter
    cpuState.pc = pc;
    return cpuState;
}

- (NSArray*)DEBUGDisassemble:(int)begin end:(int)end
                       array:(NES_u8*)array size:(uint32_t)size {
    NSMutableArray* disassembleArray = [[NSMutableArray alloc]init];

    pc = ([self read16:0xFFFC]);
    pc -= -0x8000;
    NSArray* a = [self calculateReachableInstructions:array start:pc%size count:size];

    uint32_t i = pc;
    NSString* instruction = nil;
    NSString* addressingMode = nil;
    NSString* comment = nil;

    uint32_t index = 0;

    NES_u16 value = 0;
    while(i < end) {
        index = array[i];
        OpcodeWrapper* opcodeWrapper = _opcodeWrappers[index];
        addressingMode = opcodeWrapper.addressingModeName;

        // Reading opcode
        instruction = opcodeWrapper.name;
        instruction = [instruction stringByAppendingString:@" "];
        // Ready to read next element
        ++i;

        comment = @" ; The addressing mode is: ";
        comment = [comment stringByAppendingFormat:@"%@", addressingMode];

        // TODO: Add comments for each instruction ?
        if([addressingMode isEqual:@"Accumulator"]) {
            instruction = [instruction stringByAppendingString:@" A"];
        } else if([addressingMode isEqual:@"Implied"]) {
            instruction = [instruction stringByAppendingString:@""];
        } else if([addressingMode isEqual:@"Immediate"]) {
            value = array[i];
            ++i;
            instruction = [instruction stringByAppendingFormat:@"#$%02x", value];
        } else if([addressingMode isEqual:@"Relative"]) {
            value = array[i];
            ++i;
            instruction = [instruction stringByAppendingFormat:@"$%04x", (value+i)];
        } else if([addressingMode isEqual:@"Absolute"]) {
            value = array[i];
            ++i;
            value = (array[i] << 8) + value;
            ++i;

            instruction = [instruction stringByAppendingFormat:@"$%04x", value];
        } else if([addressingMode isEqual:@"Absolute-X"]) {
            value = array[i];
            ++i;
            value = (array[i] << 8) + value;
            ++i;

            instruction = [instruction stringByAppendingFormat:@"$%04x, X", value];
        } else if([addressingMode isEqual:@"Absolute-Y"]) {
            value = array[i];
            ++i;
            value = (array[i] << 8) + value;
            ++i;

            instruction = [instruction stringByAppendingFormat:@"$%04x, Y", value];
        } else if([addressingMode isEqual:@"Indirect"]) {
            value = array[i];
            ++i;
            value = (array[i] << 8) + value;
            ++i;

            instruction = [instruction stringByAppendingFormat:@"($%04x)", value];
        } else if([addressingMode isEqual:@"Indirect-X"]) {
            value = array[i];
            ++i;

            instruction = [instruction stringByAppendingFormat:@"($%02x)", value];
        } else if([addressingMode isEqual:@"Indirect-Y"]) {
            value = array[i];
            ++i;

            instruction = [instruction stringByAppendingFormat:@"($%02x)", value];
        } else if([addressingMode isEqual:@"Zero Page"]) {
            value = array[i];
            ++i;

            instruction = [instruction stringByAppendingFormat:@"$%02x", value];
        } else if([addressingMode isEqual:@"Zero Page-X"]) {
            value = array[i];
            ++i;

            instruction = [instruction stringByAppendingFormat:@"$%02x", value];
        } else if([addressingMode isEqual:@"Zero Page-Y"]) {
            value = array[i];
            ++i;

            instruction = [instruction stringByAppendingFormat:@"$%02x", value];
        }

        NSLog(@"%@", instruction);
        // TODO: Comments
//        instruction = [instruction stringByAppendingString:comment];
        [disassembleArray addObject:instruction];
    }


    return [disassembleArray copy];
}

- (NSArray*)calculateReachableInstructions:(NES_u8*)arrayInstruction
                                     start:(uint32_t)start
                                     count:(uint32_t)count {
    NSMutableArray* isReachableArray = [[NSMutableArray alloc] init];

    NSMutableArray* stack = [[NSMutableArray alloc] init];

    for(int j = 0; j < count; ++j) {
        [isReachableArray addObject:[[NSNumber alloc] initWithBool:NO]];
    }

    OpcodeWrapper* opcodeWrapper;
    uint32_t i = start;
    while(i < count) {
        if([isReachableArray[i] boolValue]) {
            i = [(NSNumber*)[stack lastObject] unsignedIntValue];
            [stack removeObject:[stack lastObject]];
        }

        opcodeWrapper = _opcodeWrappers[arrayInstruction[i]];
        NSLog(@"Name: %@ at address %d", opcodeWrapper.name, i+1);
        for(int k = 0; k < opcodeWrapper.lengthInBytes; ++k) {
            isReachableArray[i+k] = [[NSNumber alloc] initWithBool:YES];
        }

        if([self isBranch:opcodeWrapper.name]) {
            [stack addObject:[NSNumber numberWithUnsignedInt:i+opcodeWrapper.lengthInBytes]];
            i += arrayInstruction[i+1]+opcodeWrapper.lengthInBytes;
        } else if([opcodeWrapper.name isEqual:@"JMP"]
                  || [opcodeWrapper.name isEqual:@"JSR"]) {
            [stack addObject:[NSNumber numberWithUnsignedInt:i+opcodeWrapper.lengthInBytes]];
            ++i;
            NES_u16 value = arrayInstruction[i];
            ++i;
            NES_u16 value2 = (arrayInstruction[i] << 8);

            i = (value + value2) - 0x8000;
        } else if([opcodeWrapper.name isEqual:@"RTS"]) {
            i = [(NSNumber*)[stack lastObject] unsignedIntValue];
            [stack removeObject:[stack lastObject]];
        } else {
            i += opcodeWrapper.lengthInBytes;
        }

        if(i == count && [stack count] != 0) {
            i = [(NSNumber*)[stack lastObject] unsignedIntValue];
            [stack removeObject:[stack lastObject]];
        }
    }

    return isReachableArray;
}

- (BOOL)isBranch:(NSString*)string {
    NSSet* branches = [[NSSet alloc] initWithObjects:
                       @"BCC", @"BCS", @"BEQ",
                       @"BMI", @"BNE", @"BPL",
                       @"BVC", @"BVS", nil];

    for(NSString* s in branches) {
        if([string isEqual:s]) {
            return YES;
        }
    }

    return NO;
}

@end
