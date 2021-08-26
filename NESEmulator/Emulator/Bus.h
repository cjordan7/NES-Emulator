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
@private
    NES_u8 ram[2*1024];
}

- (NES_u8)read:(NES_u16)address;
- (void)write:(NES_u16)address value:(NES_u8)value;

@end

NS_ASSUME_NONNULL_END
