//
//  AssemblyView.m
//  NESEmulator
//
//  Created by Cosme Jordan on 27.08.21.
//

#import "AssemblyView.h"

@interface AssemblyView() {
    uint32_t previousLine;
}

@property(nonatomic, strong) NSTextView* textView;
@end

@implementation AssemblyView

- (instancetype)initWithFrame:(NSRect)frame h:(uint32_t)h {
    if(self = [super initWithFrame:frame]) {
        _textView = [[NSTextView alloc] initWithFrame:frame];
    }

    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

// Line number starts at zero
- (void)highlightLine:(uint32_t)lineNumber {
    [self updateLine:lineNumber alpha:1];
    [self updateLine:previousLine alpha:0];
    previousLine = lineNumber;
}

- (void)updateLine:(uint32_t)lineNumber alpha:(CGFloat)alpha{
    NSRange range;
    range.length = self.frame.size.width;
    range.location = range.length*lineNumber;
    NSMutableAttributedString* mAS = [[NSMutableAttributedString alloc] initWithString:self.textView.textStorage.string];
    NSColor* color = [NSColor colorWithSRGBRed:200 green:200 blue:200 alpha:alpha];
    [mAS addAttribute:NSBackgroundColorAttributeName value:color range:range];
    [self.textView.textStorage setAttributedString:mAS];
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

    [self addSubview:scrollview];
}

- (void)setUpTextView:(NSRect)content {
    self.textView = [[NSTextView alloc] initWithFrame:content];

    [self.textView setEditable:NO];
    [self.textView setSelectable:NO];
    [self.textView.textStorage setFont:[NSFont fontWithName:@"Monaco" size:11]];
}


@end
