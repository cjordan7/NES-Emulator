//
//  Bus.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Foundation/Foundation.h>
#import "../Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bus : NSObject {
    NES_u8* ram;
}

@property(nonatomic, strong) Bus* connectedBus;

- (instancetype)init:(uint32_t)size;
- (NES_u8)read:(NES_u16)address;
- (void)write:(NES_u16)address value:(NES_u8)value;

- (uint8_t)readConnectedBus:(uint16_t)address;

- (void)writeConnectedBus:(NES_u16)address value:(NES_u8)value;
@end

NS_ASSUME_NONNULL_END
