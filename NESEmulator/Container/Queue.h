//
//  Queue.h
//  NESEmulator
//
//  Created by Cosme Jordan on 28.08.21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Queue : NSObject

- (void)push:(uint32_t)element;
- (uint32_t)pop;
- (uint32_t)size;

@end

NS_ASSUME_NONNULL_END
