//
//  APExpandableTableViewGroupCell.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APExpandableTableViewGroupCell : UITableViewCell

@property (nonatomic,strong) UITableViewCell *cell;
@property (nonatomic) NSInteger groupIndex;
// Expansion properties
@property (nonatomic) BOOL expanded;
@property (nonatomic) BOOL expandable;
// Visual
@property (nonatomic) BOOL indicatorOnLeft;
@property (nonatomic,strong) UIImageView *indicator;

// Animate the indicator to expanded
- (void)updateIndicatorToExpanded:(BOOL)expanded animate:(BOOL)animate;

// Attach the delegate cell to the group cell
- (void)attachInnerCell:(UITableViewCell *)innerCell;

@end
