//
//  AppDelegate.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "AppDelegate.h"
#import "Utils.h"

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSWindow* main = [[NSApplication sharedApplication] mainWindow];
    [main setTitle:@"NES Emulator"];
    [main setFrame:NSMakeRect(50, 100, APP_SIZE_WIDTH, APP_SIZE_HEIGHT) display:YES];

    CGSize fixedSize;
    fixedSize.height = APP_SIZE_HEIGHT;
    fixedSize.width = APP_SIZE_WIDTH;
    [main setMinSize:fixedSize];
    [main setMaxSize:fixedSize];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
