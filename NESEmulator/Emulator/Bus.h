//
//  Bus.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Foundation/Foundation.h>
#import "../Utils.h"
#import "Cartridge.h"

#import "ReadWriteProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface Bus : NSObject<ReadWriteProtocol> {
    NES_u8* ram;
}

@property(nonatomic, strong) Cartridge* cartridge;

- (instancetype)init:(uint32_t)size;
- (NES_u8)read:(NES_u16)address;
- (void)write:(NES_u16)address value:(NES_u8)value;

- (void)insertCartridge:(Cartridge*)cartridge;

@end

NS_ASSUME_NONNULL_END
