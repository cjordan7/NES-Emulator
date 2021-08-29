//
//  AppDelegate.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Cocoa/Cocoa.h>
#import "Emulator/Cartridge.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property(nonatomic, strong) Cartridge* cartridge;
@end

