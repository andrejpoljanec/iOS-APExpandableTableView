//
//  APExpandableTableViewGroupCell.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <UIKit/UIKit.h>

#define INDICATOR_WIDTH 40
#define INSET_INNER_CELL 15
#define DEFAULT_GROUP_CELL_HEIGHT 50

@interface APExpandableTableViewGroupCell : UITableViewCell

@property (nonatomic,strong) UIImageView *indicator;
@property (nonatomic,strong) UITableViewCell *cell;
@property (nonatomic) NSInteger groupIndex;
@property (nonatomic) BOOL expanded;
@property (nonatomic) BOOL indicatorOnLeft;
@property (nonatomic) BOOL expandable;

- (void)updateIndicatorToExpanded:(BOOL)expanded animate:(BOOL)animate;
- (void)attachInnerCell:(UITableViewCell *)innerCell;

@end
