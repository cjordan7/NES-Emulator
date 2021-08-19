//
//  CPU.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Foundation/Foundation.h>

#import "Bus.h"


NS_ASSUME_NONNULL_BEGIN

@interface CPU : NSObject {
@private
    uint8_t memory;
    uint8_t opcode;
    uint8_t cycles;

    uint8_t status;

    uint16_t addrAbsolute;
    uint16_t addrRelative;

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

@end

NS_ASSUME_NONNULL_END
