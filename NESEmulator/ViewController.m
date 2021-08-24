//
//  ViewController.m
//  NESEmulator
//
//  Created by Cosme Jordan on 19.08.21.
//

#import "ViewController.h"

#import "Emulator/FileManager.h"
#import <SpriteKit/SKTexture.h>
#import "Utils.h"

@interface ViewController() {
    CGSize skSceneSize;
    uint32_t fullSize;
}

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
    [self loadNES];
    skSceneSize.height = SK_SCENE_HEIGHT;
    skSceneSize.width = SK_SCENE_WIDTH;
    _scene = [SKScene sceneWithSize:skSceneSize];
    fullSize = skSceneSize.height*skSceneSize.width;
    [self test];

    [self buildAppInterface];
}

- (void)test {
    uint32_t* ap = malloc(2*sizeof(uint32_t));
    for(int i = 0; i < 2; ++i)  {
        ap[i] = 0xFF333333;
    }

    NSData* data = [NSData dataWithBytes:ap length:2];
    free(ap);
    CGSize e = {1, 1};
    [SKTexture textureWithData:data size:e flipped:YES];
}

- (NSView*)imageViewButton:(NSColor*)color {
    return [self imageView:color w:BUTTON_WIDTH h:BUTTON_HEIGHT];
}

- (NSView*)imageViewSKScene:(NSColor*)color {
    return [self imageView:color w:SK_SCENE_WIDTH h:SK_SCENE_HEIGHT];
}

- (NSView*)imageView:(NSColor*)color w:(CGFloat)w h:(CGFloat)h {
    NSRect rect = NSMakeRect(0, 0, w, h);
    NSView* view = [[NSView alloc]initWithFrame:rect];
    NSImageView* iv = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 0, w, h)];
    NSImage *blackImage = [[NSImage alloc]initWithSize:NSMakeSize(w, h)];
    [blackImage lockFocus];
    NSColor *blackColor = color;
    [blackColor set];
    NSRectFill(rect);
    [blackImage unlockFocus];

    [iv setImage:blackImage];
    [view addSubview:iv];
    return view;
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (NSStackView*)buildPlusSelectStartButtons {
    NSArray* array = [[NSArray alloc] initWithObjects:
                      [self imageViewButton:NSColor.redColor],
                      [self imageViewButton:NSColor.blueColor],
                      [self imageViewButton:NSColor.brownColor],
                      nil];

    NSStackView* stack = [NSStackView stackViewWithViews:array];
    stack.orientation = NSUserInterfaceLayoutOrientationVertical;
    stack.distribution = NSStackViewDistributionFillEqually;
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    NSPoint p = {0, 0};
    [stack setFrameOrigin:p];

    return stack;
}

// TODO: Replace by SKScene
- (NSStackView*)buildNSImage {
    NSView* imagView = [self imageViewSKScene:NSColor.blackColor];

    NSStackView* stack = [[NSStackView alloc] init];
    stack.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    stack.distribution = NSStackViewDistributionFillEqually;
    stack.translatesAutoresizingMaskIntoConstraints = NO;

    [stack addSubview:imagView];
    return stack;
}

- (NSStackView*)buildABButtons {
    NSArray* array = [[NSArray alloc] initWithObjects:
                      [self imageViewButton:NSColor.cyanColor],
                      [self imageViewButton:NSColor.greenColor],
                      nil];

    NSStackView* stack = [NSStackView stackViewWithViews:array];

    stack.orientation = NSUserInterfaceLayoutOrientationVertical;
    stack.distribution = NSStackViewDistributionFillEqually;
    stack.translatesAutoresizingMaskIntoConstraints = NO;


    return stack;
}

- (void)buildAppInterface {
    NSStackView* plusSelectStartButtons = [self buildPlusSelectStartButtons];
    [self.view addSubview:plusSelectStartButtons];

    NSStackView* image = [self buildNSImage];
    NSLog(@"%f", image.frame.origin.x);
    NSLog(@"%f", image.frame.origin.y);

    [self.view addSubview:image];

    NSStackView* abButtons = [self buildABButtons];
    [self.view addSubview:abButtons];
    NSLog(@"%f", abButtons.frame.origin.x);
    NSLog(@"%f", abButtons.frame.origin.y);

    NSDictionary* dictio = @{
        @"pSB": plusSelectStartButtons,
        @"image": image,
        @"abButtons": abButtons
    };

    NSArray* pSBV = [NSLayoutConstraint
                     constraintsWithVisualFormat:@"V:|-0-[pSB]-0-|"
                     options:0
                     metrics:nil
                     views:dictio];

    NSArray* imageV = [NSLayoutConstraint
                       constraintsWithVisualFormat:@"V:|-0-[image]-0-|"
                       options:0
                       metrics:nil
                       views:dictio];

    NSArray* abButtonsV = [NSLayoutConstraint
                           constraintsWithVisualFormat:@"V:|-0-[abButtons]-0-|"
                           options:0
                           metrics:nil
                           views:dictio];

    [self.view addConstraints:pSBV];
    [self.view addConstraints:imageV];
    [self.view addConstraints:abButtonsV];

    NSString* constraintsString = [NSString
                                   stringWithFormat:@"H:|-0-[pSB(==%d)]-0-[image(==%d)]-0-[abButtons(==%d)]|",
                                   BUTTON_WIDTH, SK_SCENE_WIDTH, BUTTON_WIDTH];

    NSArray* horizontal = [NSLayoutConstraint
                           constraintsWithVisualFormat:constraintsString
                           options:0
                           metrics:nil
                           views:dictio];

    [self.view addConstraints:horizontal];
}


- (void)loadNES {
}

- (void)renderScreen {

}

@end
