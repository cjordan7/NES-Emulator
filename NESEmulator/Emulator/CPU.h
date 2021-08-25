//
//  CPU.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Foundation/Foundation.h>

#import "Bus.h"
#import "../Utils.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    uint64 elapsedClock;
    NES_u8 cycles;

    NES_u8 opcode;

    NES_u8 status;
    BOOL N;
    BOOL V;
    BOOL B;
    BOOL D;
    BOOL I;
    BOOL Z;
    BOOL C;

    NES_u16 addressAbsolute;
    NES_u16 addressRelative;

    // Get data according to addressing mode
    NES_u8 fetched;

    // MARK: List of registers
    NES_u8 accumulator;
    NES_u8 x;
    NES_u8 y;

    NES_u8 sp;
    NES_u16 pc;
} CPUState;

@interface CPU : NSObject

@property(nonatomic) Bus* bus;

- (void)clock;



- (CPUState)DEBUGgetCPUState;
- (NSArray*)DEBUGDisassemble;

@end

NS_ASSUME_NONNULL_END
