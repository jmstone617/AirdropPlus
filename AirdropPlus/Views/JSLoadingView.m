//
//  JSLoadingView.m
//  TurboRoster
//
//  Created by Stone, Jordan Matthew (US - Denver) on 5/3/13.
//  Copyright (c) 2013 Shotdrum Studios, LLC. All rights reserved.
//

#import "JSLoadingView.h"

@interface JSLoadingView ()

@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

@implementation JSLoadingView

- (id)initWithLoadingText:(NSString *)text {
    self = [super initWithFrame:CGRectMake(45, 120, 230, 150)];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];
        _loadingText = text;
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        CGRect spinnerFrame = CGRectMake(CGRectGetMidX(self.bounds) - 10, CGRectGetMaxY(self.bounds) - 60, 20, 20);
        [_spinner setFrame:spinnerFrame];
        [self addSubview:_spinner];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithLoadingText:@"Loading..."];
}

- (void)setLoadingText:(NSString *)loadingText {
    if ([_loadingText isEqualToString:loadingText]) {
        return;
    }
    
    _loadingText = loadingText;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Need a context to draw into
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Determine the size we have to work with
    rect = self.bounds;
    
    // Set the color
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] setFill];
    [[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] setStroke];
    
    CGContextSaveGState(context);
    CGContextSetLineWidth(context, 1.0);
    // We want rounded corners!
    CGMutablePathRef roundedCornerPath = CGPathCreateMutable();
    CGPathMoveToPoint(roundedCornerPath, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect)); // Top middle
    CGPathAddArcToPoint(roundedCornerPath, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), 6.0); // Top right curve
    CGPathAddArcToPoint(roundedCornerPath, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), 6.0); // Bottom right
    CGPathAddArcToPoint(roundedCornerPath, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), 6.0); // Bottom left
    CGPathAddArcToPoint(roundedCornerPath, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), 6.0); // Top left
    CGPathCloseSubpath(roundedCornerPath);
    
    // Add this path
    CGContextAddPath(context, roundedCornerPath);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextRestoreGState(context);
    
    CGContextSaveGState(context);
    {
        CGRect textRect = CGRectMake(rect.origin.x, rect.origin.y + 20, rect.size.width, 70);
        UIFont *textFont = [UIFont boldSystemFontOfSize:22.0];
        [[UIColor whiteColor] setFill];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentCenter];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        
        [_loadingText drawInRect:textRect withAttributes:@{ NSParagraphStyleAttributeName : paragraphStyle, NSFontAttributeName : textFont, NSForegroundColorAttributeName : [UIColor whiteColor] }];
    }
    CGContextRestoreGState(context);
    
}

- (void)startAnimating {
    [self.spinner startAnimating];
}

- (void)stopAnimating {
    [self.spinner stopAnimating];
}

@end
