//
//  ViewController.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "ViewController.h"

#import "Emulator/FileManager.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self loadNES];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSStackView*)buildFirstColumn {
    NSStackView* stack = [[NSStackView alloc] init];

    return stack;
}

- (NSImageView*)buildNSImage {
    NSImageView* imagView = [[NSImageView alloc] init];

    return imagView;
}

- (NSStackView*)buildDebuggingColumn {
    NSStackView* stack = [[NSStackView alloc] init];

    return stack;
}

- (NSStackView*)buildAppInterface {
    NSStackView* stack = [[NSStackView alloc] init];

    return stack;
}


- (void)loadNES {
}

- (void)renderScreen {

}

@end
