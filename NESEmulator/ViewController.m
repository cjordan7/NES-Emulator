//
//  ViewController.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self load];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)load {
    NSLog(@"Hello");
}


@end
