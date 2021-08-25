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

#define BUTTON_A_INDEX 0
#define BUTTON_B_INDEX 1

#define BUTTON_SELECT_INDEX 0
#define BUTTON_START_INDEX 1
#define BUTTON_PLUS_INDEX 2

// Views for non debug columns
@property (nonatomic, strong) NSArray* columnSelStPlus;
@property (nonatomic, strong) NSView* columnScreen;
@property (nonatomic, strong) NSArray* columnOfAB;

@property (nonatomic, strong) NSStackView* columnOne;
@property (nonatomic, strong) NSStackView* columnTwo;
@property (nonatomic, strong) NSStackView* columnThree;

// Views for debug column
@property (nonatomic, strong) NSArray* debug;

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    skSceneSize.height = SK_SCENE_HEIGHT;
    skSceneSize.width = SK_SCENE_WIDTH;
    _scene = [SKScene sceneWithSize:skSceneSize];
    fullSize = skSceneSize.height*skSceneSize.width;
    [self test];


    [self buildPlusSelectStartButtons];
    [self buildNSImage];
    [self buildABButtons];

    [self buildAppInterface];

    [self loadNES];
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

- (void)buildPlusSelectStartButtons {
    _columnSelStPlus = [[NSArray alloc] initWithObjects:
                      [self imageViewButton:NSColor.redColor],
                      [self imageViewButton:NSColor.blueColor],
                      [self imageViewButton:NSColor.brownColor],
                      nil];

    _columnOne = [NSStackView stackViewWithViews:_columnSelStPlus];
    _columnOne.orientation = NSUserInterfaceLayoutOrientationVertical;
    _columnOne.distribution = NSStackViewDistributionFillEqually;
    _columnOne.translatesAutoresizingMaskIntoConstraints = NO;
    NSPoint p = {0, 0};
    [_columnOne setFrameOrigin:p];
}

// TODO: Replace by SKScene
- (void)buildNSImage {
    _columnScreen = [self imageViewSKScene:NSColor.blackColor];

    _columnTwo = [[NSStackView alloc] init];
    _columnTwo.orientation = NSUserInterfaceLayoutOrientationHorizontal;
    _columnTwo.distribution = NSStackViewDistributionFillEqually;
    _columnTwo.translatesAutoresizingMaskIntoConstraints = NO;

    [_columnTwo addSubview:_columnScreen];
}

- (void)buildABButtons {
    _columnOfAB = [[NSArray alloc] initWithObjects:
                   [self imageViewButton:NSColor.cyanColor],
                   [self imageViewButton:NSColor.greenColor],
                   nil];

    _columnThree = [NSStackView stackViewWithViews:_columnOfAB];

    _columnThree.orientation = NSUserInterfaceLayoutOrientationVertical;
    _columnThree.distribution = NSStackViewDistributionFillEqually;
    _columnThree.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)buildAppInterface {
    NSStackView* plusSelectStartButtons = _columnOne;
    [self.view addSubview:plusSelectStartButtons];

    NSStackView* image = _columnTwo;
    NSLog(@"%f", image.frame.origin.x);
    NSLog(@"%f", image.frame.origin.y);

    [self.view addSubview:image];

    NSStackView* abButtons = _columnThree;
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
