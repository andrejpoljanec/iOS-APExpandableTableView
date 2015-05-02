//
//  APExpandableTableViewGroupCell.m
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import "APExpandableTableViewGroupCell.h"

@implementation APExpandableTableViewGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.indicator = [[UIImageView alloc] initWithFrame:CGRectZero];
//        self.indicator.image = IMAGE_ARROW_DOWN;
        self.indicator.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:self.indicator];
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
        self.cell.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        self.indicator.hidden = YES;
    } else if (self.indicatorOnLeft) {
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
//        self.indicator.frame = CGRectMake(self.contentView.bounds.size.width - INDICATOR_WIDTH - DEFAULT_PADDING,
//                                          0,
//                                          INDICATOR_WIDTH,
//                                          self.contentView.bounds.size.height);
        self.indicator.frame = CGRectMake(self.contentView.bounds.size.width - INDICATOR_WIDTH - 8,
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

- (void)updateIndicatorToExpanded:(BOOL)expanded animate:(BOOL)animate{
    if (animate) {
        [UIView beginAnimations:@"animateIndicator" context:nil];
        [UIView setAnimationDuration:0.2];
    }
    if (expanded) {
        self.indicator.transform = CGAffineTransformMakeRotation(M_PI);
    } else {
        self.indicator.transform = CGAffineTransformMakeRotation(0);
    }
    if (animate) {
        [UIView commitAnimations];
    }
}


@end
