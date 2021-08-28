//
//  Mapper.m
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import "Mapper.h"
#import "../../Utils.h"

@implementation Mapper

- (instancetype)initWithBanks:(uint32_t)numberBanks {
    self->numberBanks = numberBanks;
}

- (uint32_t)mapAddress:(NES_u16)address {
    return address;
}

@end
