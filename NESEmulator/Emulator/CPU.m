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

#define POTENTIAL_ADDITIONAL_CYCLE 1
#define NO_ADDITIONAL_CYCLE 0


#define UNUSED __attribute__((unused))


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
    NES_u8 opcode;
    NES_u8 cycles;

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
}

@property(nonatomic) NES_u8 N; // Negative
@property(nonatomic) NES_u8 V; // Overflow
@property(nonatomic) NES_u8 DONT_CARE; // Ignored
@property(nonatomic) NES_u8 B; // Break
@property(nonatomic) NES_u8 D; // Decimal (use BCD for arithmetics)
@property(nonatomic) NES_u8 I; // Interrupt (IRQ disable)
@property(nonatomic) NES_u8 Z; // Zero
@property(nonatomic) NES_u8 C; // Carry

@property(nonatomic, strong) FileManager* fileReader; // To read opcodes

@property(nonatomic, strong, readonly) NSArray* opcodeWrappers; // To read opcodes

@end

@implementation CPU
// MARK: Status bit 7 to bit 0
static const NES_u8 N_BIT = 1 << 7; // Negative
static const NES_u8 V_BIT = 1 << 6; // Overflow
UNUSED static const NES_u8 DONT_CARE = 1 << 5; // Ignored
static const NES_u8 B_BIT = 1 << 4; // Break
static const NES_u8 D_BIT = 1 << 3; // Decimal (use BCD for arithmetics)
static const NES_u8 I_BIT = 1 << 2; // Interrupt (IRQ disable)
static const NES_u8 Z_BIT = 1 << 1; // Zero
static const NES_u8 C_BIT = 1 << 0; // Carry
//static const int V = 6; // Overflow
//static const int DONT_CARE = 5; // Ignored
//static const int B = 4; // Break
//static const int D = 3; // Decimal (use BCD for arithmetics)
//static const int I = 2; // Interrupt (IRQ disable)
//static const int Z = 1; // Zero
//static const int C = 0; // Carry

- (instancetype)init {
    if(self = [super init]) {
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
    }
    return self;
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
    return addressAbsolute & 0x0100;//(addressAbsolute >> 8) == temp ? 0: 1;
}

- (NES_u8)addressAbsoluteUtil:(NES_u8)xORy {
    addressAbsolute = [self read:pc++];
    NES_u8 value = [self read:pc++];
    addressAbsolute |= value << 8;
    addressAbsolute += xORy;

    return [self addClockCycleOnPageChange:value];
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

- (NES_u8)read:(NES_u16)address {
    return [self.bus cpuRead:address];
}

- (void)write:(NES_u16)address value:(NES_u8)value {
    return [self.bus cpuWrite:address value:value];
}

//==============================================================================
// Absolute Addressing Modes

- (NES_u8)addressAbsolute {
    PRINT_ADDRESS("");
    addressAbsolute = [self read:pc++];
    addressAbsolute |= [self read:pc++] << 8;
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
    // fetched = accumulator;
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

- (NES_u8)opcodeADC {
    PRINT_OPCODE("");
//    [self fetch];

    NES_u16 sum = self.C + accumulator + [self fetch];

    self.N = [self calculateN:sum];
    self.V = [self calculateV:accumulator fetched:fetched c:sum];

    accumulator = sum & 0x0FF;
    self.Z = [self calculateZ:sum & 0x0FF];
    self.C = [self calculateC:sum];

    return POTENTIAL_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeAND {
    PRINT_OPCODE("");
//    [self fetch];
    accumulator = accumulator & [self fetch];
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];
    return POTENTIAL_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeASL {
    PRINT_OPCODE("");
//    [self fetch];

    NES_u16 shift = [self fetch] << 1;

    self.N = [self calculateN:shift];
    self.Z = [self calculateZ:shift & 0x0FF];
    self.C = [self calculateC:shift];

    return NO_ADDITIONAL_CYCLE;
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

- (NES_u8)opcodeBMI {
    PRINT_OPCODE("");
    [self branchOnSet:self.N];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBPL {
    PRINT_OPCODE("");
    [self branchOnClear:self.N];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBVS {
    PRINT_OPCODE("");
    [self branchOnSet:self.V];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBVC {
    PRINT_OPCODE("");
    [self branchOnClear:self.V];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBCS {
    PRINT_OPCODE("");
    [self branchOnSet:self.C];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBCC {
    PRINT_OPCODE("");
    [self branchOnClear:self.C];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBEQ {
    PRINT_OPCODE("");
    [self branchOnSet:self.Z];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBNE {
    PRINT_OPCODE("");
    [self branchOnClear:self.Z];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBIT {
    PRINT_OPCODE("");
    [self fetch];

    NES_u8 bit = accumulator & fetched;

    self.N = fetched & 0x080;
    self.V = fetched & 0x040;
    self.Z = [self calculateZ:bit];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeBRK {
    PRINT_OPCODE("");
    // TODO:
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeCLC {
    PRINT_OPCODE("");
    self.C = 0;
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeCLD {
    PRINT_OPCODE("");
    self.D = 0;
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeCLI {
    PRINT_OPCODE("");
    self.I = 0;
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeCLV {
    PRINT_OPCODE("");
    self.V = 0;
    return NO_ADDITIONAL_CYCLE;
}

// Comparison Opcodes
- (void)compareOpcodes:(NES_u8)value {
    [self fetch];
    NES_u16 substraction = value - fetched;
    self.N = [self calculateN:substraction];
    self.Z = [self calculateZ:substraction & 0x0FF];
    self.C = [self calculateC:value >= fetched];
}

- (NES_u8)opcodeCMP {
    PRINT_OPCODE("");
    [self compareOpcodes:accumulator];
    return POTENTIAL_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeCPX {
    PRINT_OPCODE("");
    [self compareOpcodes:x];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8) opcodeCPY {
    PRINT_OPCODE();
    [self compareOpcodes:y];
    return NO_ADDITIONAL_CYCLE;
}

- (void)opcodeMemoryOp:(int)value {
    // TODO:...
}

- (NES_u8)opcodeDEC {
    PRINT_OPCODE("");
//    [self fetch];

    NES_u16 memory = [self fetch] - 1;

    self.N = [self calculateN:memory];
    self.Z = [self calculateZ:memory];

    [self write:addressAbsolute value:memory & 0x0FF];

    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeINC {
    PRINT_OPCODE("");
    [self fetch];
    NES_u16 value = fetched + 1;

    self.N = [self calculateN:fetched];
    self.Z = [self calculateZ:fetched];

    [self write:addressAbsolute value:value & 0x0FF];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)decrementOpcode:(NES_u8)value {
    --value;

    self.N = [self calculateN:value];
    self.Z = [self calculateZ:value];
    return value;
}

- (NES_u8)opcodeDEX {
    PRINT_OPCODE("");
    x = [self decrementOpcode:x];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeDEY {
    PRINT_OPCODE("");
    y = [self decrementOpcode:y];
    return NO_ADDITIONAL_CYCLE;
}

- (NES_u8)opcodeEOR {
    PRINT_OPCODE("");
    [self fetch];
    accumulator ^= fetched;
    self.N = [self calculateN:accumulator];
    self.Z = [self calculateZ:accumulator];

    // FIXME: TODO
    return 0;
}

- (NES_u8)incrementOpcode:(NES_u8)value {
    ++value;

    self.N = [self calculateN:value];
    self.Z = [self calculateZ:value];
    return value;
}


- (NES_u8)opcodeINX {
    PRINT_OPCODE("");
    x = [self incrementOpcode:x];
    return 0;
}

- (NES_u8)opcodeINY {
    PRINT_OPCODE("");
    y = [self incrementOpcode:y];
    return 0;
}

- (NES_u8)opcodeJMP {
    PRINT_OPCODE("");
    pc = addressAbsolute;
    return 0;
}

- (NES_u8)opcodeNOP {
    return 0;
}
// =============================================================================
// Illegal Opcodes
- (NES_u8)opcodeSKB {
    return 0;
}

- (NES_u8)opcodeIGN {
    return 0;
}

- (NES_u8)opcodeALR {
    return 0;
}

- (NES_u8)opcodeANC {
    return 0;
}

- (NES_u8)opcodeARR {
    return 0;
}


- (NES_u8)opcodeAXS {
    return 0;
}

- (NES_u8)opcodeLAX {
    return 0;
}

- (NES_u8)opcodeSAX {
    return 0;
}

- (NES_u8)opcodeDCP {
    return 0;
}

- (NES_u8)opcodeISC {
    return 0;
}

- (NES_u8)opcodeRLA {
    return 0;
}

- (NES_u8)opcodeRRA {
    return 0;
}

- (NES_u8)opcodeSLO {
    return 0;
}

- (NES_u8)opcodeSRE {
    return 0;
}

- (NES_u8)opcodeXAA {
    return 0;
}

- (NES_u8)opcodeAHX {
    return 0;
}

- (NES_u8)opcodeSHX {
    return 0;
}

- (NES_u8)opcodeTAS {
    return 0;
}

- (NES_u8)opcodeSHY {
    return 0;
}

- (NES_u8)opcodeLAS {
    return 0;
}



// =============================================================================
// Debugging functions

- (CPUState)DEBUGgetCPUState {
    CPUState cpuState;

    cpuState.opcode = opcode;
    cpuState.cycles = cycles;

    // Status Register
    cpuState.status = status;
    cpuState.N = self.N;
    cpuState.V = self.V;
    cpuState.B = self.B;
    cpuState.D = self.D;
    cpuState.I = self.I;
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

- (NSArray*)DEBUGDisassemble {
    NSMutableArray* disassembleArray = [[NSMutableArray alloc]init];

    return [disassembleArray copy];
}

@end
