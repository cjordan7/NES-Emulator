//
//  CPU.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Foundation/Foundation.h>

#import "Bus.h"


NS_ASSUME_NONNULL_BEGIN

typedef struct {
    uint8_t memory;
    uint8_t opcode;
    uint8_t cycles;

    uint8_t status;
    bool N;
    bool V;
    bool B;
    bool D;
    bool I;
    bool Z;
    bool C;

    uint16_t addressAbsolute;
    uint16_t addressRelative;

    // Get data according to addressing mode
    uint8_t fetched;

    // MARK: List of registers
    uint8_t accumulator;
    uint8_t x;
    uint8_t y;

    uint8_t sp;
    uint16_t pc;
} CPUState;

@interface CPU : NSObject {
@private
    uint8_t memory;
    uint8_t opcode;
    uint8_t cycles;

    uint8_t status;

    uint16_t addressAbsolute;
    uint16_t addressRelative;

    // Get data according to addressing mode
    uint8_t fetched;

    // MARK: List of registers
    uint8_t accumulator;
    uint8_t x;
    uint8_t y;

    uint8_t sp;
    uint16_t pc;
}

@property(nonatomic) Bus* bus;

- (void)clock;



- (CPUState)DEBUGgetCPUState;
- (NSArray*)DEBUGDisassemble;

@end

NS_ASSUME_NONNULL_END
