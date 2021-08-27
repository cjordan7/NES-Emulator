//
//  DataGrid.h
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import <Cocoa/Cocoa.h>
#import "../Utils.h"
NS_ASSUME_NONNULL_BEGIN

@interface DataGrid : NSView

- (instancetype)initWithFrame:(NSRect)frame h:(uint32_t)h;
- (void)updateWitData:(NES_u8*)data;

@end

NS_ASSUME_NONNULL_END
