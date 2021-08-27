//
//  CPUBus.h
//  NESEmulator
//
//  Created by Cosme Jordan on 26.08.21.
//

#import "Bus.h"
#import "PPU.h"

NS_ASSUME_NONNULL_BEGIN

@interface CPUBus : Bus

@property(nonatomic, strong) PPU* ppu;

@end

NS_ASSUME_NONNULL_END
