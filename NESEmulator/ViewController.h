//
//  ViewController.h
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import <Cocoa/Cocoa.h>
#import <SpriteKit/SKScene.h>
#import "NESLoadable.h"

@interface ViewController : NSViewController<NESLoadable>

@property(nonatomic, strong) SKScene* scene;

- (void)loadNES;

@end

