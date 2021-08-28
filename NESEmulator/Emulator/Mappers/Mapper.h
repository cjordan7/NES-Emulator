//
//  Mapper.h
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import <Foundation/Foundation.h>
#import "../../Utils.h"

NS_ASSUME_NONNULL_BEGIN

@interface Mapper : NSObject {
    uint32_t numberBanks;
}

- (instancetype)initWithBanks:(uint32_t)numberBanks;

- (uint32_t)mapAddress:(NES_u16)address;

@end

NS_ASSUME_NONNULL_END
