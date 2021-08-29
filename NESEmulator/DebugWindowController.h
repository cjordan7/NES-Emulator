//
//  DebugWindowController.h
//  NESEmulator
//
//  Created by Cosme Jordan on 25.08.21.
//

#import <Cocoa/Cocoa.h>
#import "NESLoadable.h"

NS_ASSUME_NONNULL_BEGIN

@interface DebugWindowController : NSWindowController<NESLoadable>

- (void)loadNES;

@end

NS_ASSUME_NONNULL_END
