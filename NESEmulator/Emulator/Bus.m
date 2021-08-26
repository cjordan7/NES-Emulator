//
//  Bus.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "Bus.h"
#import "../Utils.h"

@interface Bus()

@end

@implementation Bus

- (instancetype)init:(uint32_t)size {
    if(self = [super init]) {
        ram = calloc(size, sizeof(NES_u8));
    }

    return self;

}

- (void)connectBus:(Bus*)bus {
    self.connectedBus = bus;
}

- (void)dealloc {
    free(ram);
}

- (uint8_t)read:(uint16_t)address {
    return ram[address];
}

- (void)write:(NES_u16)address value:(NES_u8)value {
    ram[address] = value;
}

- (uint8_t)readConnectedBus:(uint16_t)address {
    return [self.connectedBus read:address];
}

- (void)writeConnectedBus:(NES_u16)address value:(NES_u8)value {
    [self.connectedBus write:address value:value];
}

@end
