//
//  DebugWindowController.m
//  NESEmulator
//
//  Created by Cosme Jordan on 25.08.21.
//


#import "AppDelegate.h"

#import "DebugWindowController.h"

#import <AppKit/NSTextFieldCell.h>
#import <SpriteKit/SKView.h>
#import <SpriteKit/SKScene.h>
#import <SpriteKit/SKTexture.h>
#import <SpriteKit/SKSpriteNode.h>

#import "Emulator/FileManager.h"

#import "Views/DataGrid.h"

#import "Emulator/Cartridge.h"

@interface NSTextFieldCell(Centered)
@end

@implementation NSTextFieldCell(Centered)

- (NSRect) titleRectForBounds:(NSRect)frame {
    CGFloat stringHeight = self.attributedStringValue.size.height;
    NSRect titleRect = [super titleRectForBounds:frame];
    titleRect.origin.y = frame.origin.y +
    (frame.size.height - stringHeight) / 2.0;
    return titleRect;
}

- (void) drawInteriorWithFrame:(NSRect)cFrame inView:(NSView*)cView {
    [super drawInteriorWithFrame:[self titleRectForBounds:cFrame] inView:cView];
}

@end

@interface DebugWindowController ()
@property(nonatomic, strong) FileManager* fileManager;


// First columns
@property(nonatomic, strong) NSArray* arrayRegisters;


// First columns
@property(nonatomic, strong) NSStackView* stackViewRegisters;


@property(nonatomic, strong) NSGridView* gridView;


@property(nonatomic, strong) NSView* view;

@property(nonatomic, strong) DataGrid* dataGrid;


@end

#define SAMPLE_WIDTH 16*25
#define SAMPLE_HEIGHT 4*25

@implementation DebugWindowController

- (instancetype)init {
    return [super initWithWindowNibName:@""];
}

- (void)loadWindow {
    NSWindowStyleMask mask = NSWindowStyleMaskTitled;
    mask |= NSWindowStyleMaskMiniaturizable;
    mask |= NSWindowStyleMaskClosable;
    NSRect rect = NSMakeRect(20, 20, 1000, 400);
    NSWindow* window = [[NSWindow alloc] initWithContentRect:rect styleMask: mask backing:NSBackingStoreBuffered defer:NO];

    self.window = window;
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];

    _view = self.window.contentView;
    _fileManager = [[FileManager alloc] init];
    _dataGrid = [[DataGrid alloc] initWithFrame: NSMakeRect(0, 0, 415, 16*20)
                                              h: 0xFFF];

    [self createInterface];
}

- (void)loadNES {
    AppDelegate* ap = (AppDelegate*)[[NSApplication sharedApplication] delegate];
    Cartridge* temp = ap.cartridge;

    NES_u8* pgrROM = [temp getPGRRom];

    for(int i = 0; i < 10; ++i) {
        printf("%d ", pgrROM[i]);
    }

    NES_u8 full[0xFFFF];
    memset(full, 0, 16*0xFFF*sizeof(NES_u8));

    memcpy(full+0x8000, pgrROM, (0xFFFF-0x8000)*sizeof(NES_u8));
    [_dataGrid updateWitData:full];
}

- (void)createInterface {
    [self addSubview:self.dataGrid];

    NSArray* loadedPixels = [_fileManager getPalette:@"nespalette"];
    uint32_t* pixels = buffedPixels(loadedPixels, 16, 4, 25, 25);
    NSStackView* s = [self createSKScene:pixels];
    [s setFrame:NSMakeRect(500, 200, SAMPLE_WIDTH, SAMPLE_HEIGHT)];
    [self addSubview:s];
}

- (void)addSubview:(nonnull NSView*)view {
    [self.view addSubview:view];
}

- (NSStackView*)createSKScene:(void*)array {
    NSData* data = [NSData dataWithBytes:array
                                  length:SAMPLE_HEIGHT*SAMPLE_WIDTH*sizeof(uint32_t)];
    CGSize size;
    size.height = SAMPLE_HEIGHT;
    size.width = SAMPLE_WIDTH;

    SKScene* scene = [[SKScene alloc] initWithSize:size];
    SKTexture* texture = [SKTexture textureWithData:data size:size flipped:YES];

    CGPoint p = {0.5, 0.5};
    scene.anchorPoint = p;

    SKSpriteNode* node = [SKSpriteNode spriteNodeWithTexture:texture];
    [scene addChild:node];

    NSStackView* stack = [[NSStackView alloc] init];

    SKView* view = [[SKView alloc] initWithFrame:NSMakeRect(0, 0,
                                                            SAMPLE_WIDTH,
                                                            SAMPLE_HEIGHT)];
    [view presentScene:scene];

    [stack addSubview:view];

    return stack;
}

- (NSGridView*)createGridStrings:(int)w h:(int)h {
    NSGridView* gridView = [[NSGridView alloc] initWithFrame:NSMakeRect(10, 10,
                                                                        438, h*22)];

    for(int i = 0; i < h+1; ++i) {
        NSTextField* textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];

        textField.font = [NSFont fontWithName:@"Courier" size:11];

        NSString* string = @"";

        for(int j = 0; j < w+1; ++j) {
            if(j == 0) {
                if(i != 0) {
                    string = [string stringByAppendingFormat:@" %04X: ", ((i-1)*16+j)];
                } else {
                    string = [string stringByAppendingFormat:@"       "];
                }
            } else {
                if(i == 0) {
                    string = [string stringByAppendingFormat:@" %02X", i*16+j-1];
                } else {
                    string = [string stringByAppendingFormat:@" %02X", 0];
                }
            }
        }

        if(i == 5) {
            NSRange range;
            range.length = [string length];
            range.location = 0;
            NSMutableAttributedString* mAS = [[NSMutableAttributedString alloc] initWithString:string];
            NSColor* color = [NSColor colorWithSRGBRed:200 green:200 blue:200 alpha:1];
            [mAS addAttribute:NSBackgroundColorAttributeName value:color range:range];

            textField.attributedStringValue = mAS;
        } else {
            [textField setStringValue:string];
        }
        if(i == 0) {
            [textField setBezeled:NO];
            [textField setDrawsBackground:NO];
        } else {
            [textField setBezeled:NO];
            [textField setDrawsBackground:NO];
        }

        [textField setEditable:NO];
        [textField setSelectable:NO];

        [gridView addRowWithViews:[[NSArray arrayWithObject:textField] copy]];

        NSGridRow* gridRow = [gridView rowAtIndex:i];

        gridRow.height = 20;
    }

    gridView.columnSpacing = 0;
    gridView.rowSpacing = 0;
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    gridView.wantsLayer = YES;

    [gridView setContentHuggingPriority:600 forOrientation: NSLayoutConstraintOrientationVertical];
    [gridView setContentHuggingPriority:600 forOrientation: NSLayoutConstraintOrientationHorizontal];

    return gridView;
}

- (NSGridView*)createGridView:(int)w h:(int)h {
    NSGridView* gridView = [[NSGridView alloc] initWithFrame:NSMakeRect(10, 10,
                                                                        438, h*22)];

    for(int i = 0; i < h+1; ++i) {
        NSMutableArray* array = [[NSMutableArray alloc] init];

        for(int j = 0; j < w+1; ++j) {
            NSTextField* textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 1, 1)];

            textField.font = [NSFont fontWithName:@"Consolas" size:11];

            if(j == 0) {
                if(i != 0) {
                    [textField setStringValue:[NSString stringWithFormat:@"%04X", (i*16+j)]];
                }
            } else {
                if(i == 0) {
                    [textField setStringValue:[NSString stringWithFormat:@"%02X", i*16+j-1]];
                } else {
                    [textField setStringValue:[NSString stringWithFormat:@"%02X", (i*16+j)%0x0100]];
                }
            }

            if(i == 0 && j == 0) {
                [textField setBezeled:NO];
                [textField setDrawsBackground:NO];
            } else {
                [textField setBezeled:YES];
                [textField setDrawsBackground:NO];
            }
            [textField setEditable:NO];
            [textField setSelectable:NO];

            [array addObject:textField];
        }

        [gridView addRowWithViews:[array copy]];

        NSGridRow* gridRow = [gridView rowAtIndex:i];

        gridRow.height = 20;
    }

    gridView.columnSpacing = 0;
    gridView.rowSpacing = 0;
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    gridView.wantsLayer = YES;
    [gridView setContentHuggingPriority:600 forOrientation: NSLayoutConstraintOrientationVertical];
    [gridView setContentHuggingPriority:600 forOrientation: NSLayoutConstraintOrientationHorizontal];

    //    NSDictionary* dictio = @{
    //        @"gV": gridView,
    //    };

    //    NSArray* gV = [NSLayoutConstraint
    //                   constraintsWithVisualFormat:@"V:|-0-[g]-0-|"
    //                   options:0
    //                   metrics:nil
    //                   views:dictio];

    //    [self.view addConstraints:gV];
    //    NSString* constraintsString = [NSString stringWithFormat:@"H:|-0-[g]-0-|"];
    //
    //    NSArray* horizontal = [NSLayoutConstraint
    //                           constraintsWithVisualFormat:constraintsString
    //                           options:0
    //                           metrics:nil
    //                           views:dictio];
    //
    //    [self.view addConstraints:horizontal];
    //

    return gridView;
}

@end

