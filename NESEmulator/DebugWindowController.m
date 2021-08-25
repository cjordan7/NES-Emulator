//
//  DebugWindowController.m
//  NESEmulator
//
//  Created by Cosme Jordan on 25.08.21.
//

#import "DebugWindowController.h"

#import <AppKit/NSTextFieldCell.h>

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
    NSLog(@"Callelled........");
    [super drawInteriorWithFrame:[self titleRectForBounds:cFrame] inView:cView];
}

@end

@interface DebugWindowController ()

// First columns
@property(nonatomic, strong) NSArray* arrayRegisters;


// First columns
@property(nonatomic, strong) NSStackView* stackViewRegisters;


@property(nonatomic, strong) NSGridView* gridView;


@property(nonatomic, strong) NSView* view;


@end

@implementation DebugWindowController

- (void)showWindow:(id)sender {
    [super showWindow:sender];

    _view = self.window.contentView;

    [self createInterface];
}

- (void)createInterface {
//    NSGridView* gridView = [self createGridView:16 h:0x07F];
    NSGridView* gridView = [self createGridStrings:16 h:0xFFF];
    NSScrollView* scrollView = [[NSScrollView alloc] initWithFrame:
                                NSMakeRect(10, 10,
                                           gridView.frame.size.width, 16*10)];


    [scrollView setDocumentView:gridView];

    [self addSubview:scrollView];
}

- (void)addSubview:(nonnull NSView*)view {
    [self.view addSubview:view];
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
                    string = [string stringByAppendingFormat:@" %04X: ", (i*16+j)];
                } else {
                    string = [string stringByAppendingFormat:@"       "];
                }
            } else {
                if(i == 0) {
                    string = [string stringByAppendingFormat:@" %02X", i*16+j];
                } else {
                    string = [string stringByAppendingFormat:@" %02X", (i*16+j)%0xFF];
                }
            }
        }

        [textField setStringValue:string];
        //textField.stringValue = string;
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
//        for(int k = 0; k < 16; ++k) {
//            NSGridCell* cell = [gridRow cellAtIndex:k];
//            [cell.contentView setWantsLayer:YES];
////            cell.contentView.layer.backgroundColor = NSColor.brownColor.CGColor;
//        }

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

//            textField.drawsBackground = YES;

            [array addObject:textField];
        }

        [gridView addRowWithViews:[array copy]];

        NSGridRow* gridRow = [gridView rowAtIndex:i];
//        for(int k = 0; k < 16; ++k) {
//            NSGridCell* cell = [gridRow cellAtIndex:k];
//            [cell.contentView setWantsLayer:YES];
////            cell.contentView.layer.backgroundColor = NSColor.brownColor.CGColor;
//        }

        gridRow.height = 20;
    }

    gridView.columnSpacing = 0;
    gridView.rowSpacing = 0;
    gridView.translatesAutoresizingMaskIntoConstraints = NO;

    gridView.wantsLayer = YES;
//    gridView.layer.backgroundColor = NSColor.redColor.CGColor;

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

