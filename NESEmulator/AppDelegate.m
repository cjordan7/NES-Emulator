//
//  AppDelegate.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "DebugWindowController.h"
#import "Emulator/Cartridge.h"

#import "ViewController.h"

@interface AppDelegate ()

@property (nonatomic, strong) DebugWindowController* dWC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    self.cartridge = [[Cartridge alloc] initName:@"name" type:@".nes"];

    [self createMainWindow];
    [self createDebugWindow];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (void)createMainWindow {
    NSWindow* main = [[NSApplication sharedApplication] mainWindow];
    [main setTitle:@"NES Emulator"];
    main.styleMask &= ~NSWindowStyleMaskResizable;
    [main setFrame:NSMakeRect(50, 100, APP_SIZE_WIDTH, APP_SIZE_HEIGHT) display:YES];

    [(ViewController*)main.contentViewController loadNES];
}

- (void)createDebugWindow {
    _dWC = [[DebugWindowController alloc] init];

    [_dWC.window setTitle:@"NES Debugger"];
    [_dWC showWindow:self];

    [_dWC loadNES];
}

@end
