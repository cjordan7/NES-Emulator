//
//  Cartridge.h
//  NESEmulator
//
//  Created by Cosme Jordan on 20.08.21.
//

#import <Foundation/Foundation.h>
#import "ReadWriteProtocol.h"
#import "PPU.h"

NS_ASSUME_NONNULL_BEGIN

@interface Cartridge : NSObject<ReadWriteProtocol>

@property(nonatomic) Mirroring mirroring;
@property(nonatomic, readonly, getter=hasRAM) BOOL hasRAM;
@property(nonatomic, readonly, getter=isValid) BOOL isValid;



- (instancetype)initName:(NSString*)name type:(NSString*)type;

- (NES_u8*)getCHRMemory;
- (NES_u8*)getPGRRom;

- (uint32_t*)grayscaleCHR;

@end

NS_ASSUME_NONNULL_END
