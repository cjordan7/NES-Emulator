//
//  ReadWriteProtocol.h
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import <Foundation/Foundation.h>
#import "../Utils.h"
NS_ASSUME_NONNULL_BEGIN

@protocol ReadWriteProtocol <NSObject>
@required
- (NES_u8)read:(NES_u16)address;

@required
- (void)write:(NES_u16)address value:(NES_u8)value;

@end

NS_ASSUME_NONNULL_END
