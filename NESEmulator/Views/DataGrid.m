//
//  DataGrid.m
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import "DataGrid.h"

@interface DataGrid() {
    uint32_t w;
    uint32_t h;
}
@property(nonatomic, strong) NSTextView* textView;
@end

@implementation DataGrid

- (instancetype)initWithFrame:(NSRect)frame h:(uint32_t)h
{
    if(self = [super initWithFrame:frame]) {
        self->w = 16; // Always
        self->h = h;

        [self setUpScrollView];
    }

    return self;
}

- (void)setUpScrollView {
    CGFloat margin = 20;
    NSRect scrollViewRect = NSMakeRect(0, 0,
                                       self.bounds.size.width - 2*margin,
                                       self.bounds.size.height - 2*margin);

    NSScrollView* scrollview = [[NSScrollView alloc] initWithFrame:scrollViewRect];
    NSSize contentSize = [scrollview contentSize];
    scrollview.backgroundColor = NSColor.blackColor;
    scrollview.drawsBackground = YES;

    scrollview.hasVerticalScroller = YES;
    scrollview.hasHorizontalScroller = NO;

    scrollview.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

    [self setUpTextView:scrollview.bounds];
    _textView.drawsBackground = NO;

    _textView.minSize = NSMakeSize(0.0, contentSize.height);
    _textView.maxSize = NSMakeSize(contentSize.width, CGFLOAT_MAX);

    _textView.verticallyResizable = YES;
    _textView.horizontallyResizable = NO;

    _textView.autoresizingMask = NSViewWidthSizable;

    _textView.textContainer.containerSize = NSMakeSize(contentSize.width, CGFLOAT_MAX);
    _textView.textContainer.widthTracksTextView = YES;

    NSString *string = _textView.string;

    [_textView insertText:string replacementRange:NSMakeRange(0, 0)];

    scrollview.documentView = _textView;

    [self highlight];
    [self addSubview:scrollview];
}

- (void)highlight {
    NSRange range;
    range.length = 10;
    range.location = 0;

    NSColor* color = [NSColor colorWithSRGBRed:200
                                         green:200 blue:200 alpha:1];

    for(int i = 1; i <= h; ++i) {
        [self.textView.textStorage addAttribute: NSBackgroundColorAttributeName
                                          value: color
                                          range: NSMakeRange(7+56*i, 54-4)];
    }
}

- (void)setUpTextView:(NSRect)content {
    self.textView = [[NSTextView alloc] initWithFrame:content];

    NES_u8 array[w*h];

    memset(array, 0, w*h*sizeof(NES_u8));

    [self updateWitData:array];

    [self.textView setEditable:NO];
    [self.textView setSelectable:NO];

    [self.textView.textStorage setFont:[NSFont fontWithName:@"Monaco" size:11]];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)updateWitData:(NES_u8 *)data {
    NSMutableArray* array = [[NSMutableArray alloc] initWithCapacity: w*h];
    NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity: 16+2];

    [temp addObject:@"\n      "];

    for(int i = 0; i < w; ++i) {
        [temp addObject:[NSString stringWithFormat:@"%02X", i]];
    }

    [temp addObject:@"\n"];

    [array addObject:[temp componentsJoinedByString: @" "]];

    for(int i = 0; i < h; ++i) {
        temp[0] = [NSString stringWithFormat:@"%04X:", i*16];
        for(int j = 0; j < w; ++j) {
            temp[j + 1] = [NSString stringWithFormat:@"%02X", data[i*16+j]];
        }
            
        temp[17] = @"\n";
        NSLog(@"%lu", [temp componentsJoinedByString: @" "].length);
        [array addObject:[temp componentsJoinedByString: @" "]];
    }

    NSLog(@"%@", [array componentsJoinedByString: @" "]);
    [self.textView setString:[array componentsJoinedByString: @" "]];
}

@end
