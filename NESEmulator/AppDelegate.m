//
//  AppDelegate.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "AppDelegate.h"
#import "Utils.h"
#import "DebugWindowController.h"

@interface AppDelegate ()

@property (nonatomic, strong) DebugWindowController* dWC;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

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

//    CGSize fixedSize;
//    fixedSize.height = APP_SIZE_HEIGHT;
//    fixedSize.width = APP_SIZE_WIDTH;
//    [main setMinSize:fixedSize];
//    [main setMaxSize:fixedSize];
}

- (void)createDebugWindow {
    NSWindowStyleMask mask = NSWindowStyleMaskTitled;
    mask |= NSWindowStyleMaskMiniaturizable;
    mask |= NSWindowStyleMaskClosable;
    NSRect rect = NSMakeRect(20, 20, 1000, 400);
    NSWindow* window = [[NSWindow alloc] initWithContentRect:rect styleMask: mask backing:NSBackingStoreBuffered defer:NO];
    _dWC = [[DebugWindowController alloc] initWithWindow:window];

    [_dWC.window setTitle:@"NES Debugger"];
    [_dWC showWindow:self];

    NSLog(@"%@", _dWC.window.contentView);
}

@end
