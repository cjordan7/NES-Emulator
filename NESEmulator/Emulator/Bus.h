//
//  Bus.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Bus : NSObject {
@private
    uint8_t ram[2*1024];
}

- (uint8_t)cpuRead:(uint16_t)address;

@end

NS_ASSUME_NONNULL_END
