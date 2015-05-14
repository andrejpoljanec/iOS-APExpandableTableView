//
//  APExpandableTableViewGroupCell.m
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import "APExpandableTableViewGroupCell.h"
#import "APExpandableTableViewConstants.h"

@implementation APExpandableTableViewGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

        // Visual
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.indicator = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.indicator.image = [APExpandableTableViewGroupCell defaultIndicatorImage];
        self.indicator.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.indicator];
        
        // Set defaults
        self.indicatorOnLeft = YES;
        self.expandable = YES;
    }
    
    return self;
    
}

-(void)attachInnerCell:(UITableViewCell *)innerCell {
    
    if (self.cell != nil) {
        [self.cell removeFromSuperview];
    }
    self.cell = innerCell;
    self.cell.userInteractionEnabled = NO;
    [self.contentView addSubview:self.cell];
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.contentView setAutoresizesSubviews:YES];
    
    if (!self.expandable) {
        
        // If not expandable, there is no need for an indicator and the inner cell can take up the whole space
        
        self.cell.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        self.indicator.hidden = YES;
        
    } else if (self.indicatorOnLeft) {
      
        // Layout if indicator is on the left
        
        self.indicator.frame = CGRectMake(0,
                                          0,
                                          INDICATOR_WIDTH,
                                          self.contentView.bounds.size.height);
        self.cell.frame = CGRectMake(INDICATOR_WIDTH - INSET_INNER_CELL,
                                     0,
                                     self.contentView.bounds.size.width - INDICATOR_WIDTH + INSET_INNER_CELL,
                                     self.contentView.bounds.size.height);
        self.indicator.hidden = NO;
        
    } else {
        
        // Layout if indicator is on the right
        
        self.indicator.frame = CGRectMake(self.contentView.bounds.size.width - INDICATOR_WIDTH - DEFAULT_PADDING,
                                          0,
                                          INDICATOR_WIDTH,
                                          self.contentView.bounds.size.height);
        self.cell.frame = CGRectMake(0,
                                     0,
                                     self.contentView.bounds.size.width - INDICATOR_WIDTH,
                                     self.contentView.bounds.size.height);
        self.indicator.hidden = NO;
        
    }
}

// Update the indicator to show whether the group is expanded or collapsed
- (void)updateIndicatorToExpanded:(BOOL)expanded animate:(BOOL)animate{
    
    if (animate) {
        [UIView beginAnimations:@"animateIndicator" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    
    // Rotate the indicator by 180 degrees
    if (expanded) {
        self.indicator.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.indicator.transform = CGAffineTransformMakeRotation(0);
    }
    
    if (animate) {
        [UIView commitAnimations];
    }
    
}

// Draw a default image if none is provided, just a black arrow
+ (UIImage *)defaultIndicatorImage {
    static UIImage *indicatorImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(20.f, 20.f), NO, 0.0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSaveGState(ctx);
        CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
        CGContextSetLineWidth(ctx, 1.0f);
        CGContextMoveToPoint(ctx, 2, 6);
        CGContextAddLineToPoint(ctx, 10, 14);
        CGContextAddLineToPoint(ctx, 18, 6);
        CGContextStrokePath(ctx);
        CGContextRestoreGState(ctx);
        indicatorImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    return indicatorImage;
}

@end
