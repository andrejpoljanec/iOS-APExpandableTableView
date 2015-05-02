//
//  APExpandableTableView.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APExpandableTableViewChildTableView.h"
#import "APExpandableTableViewGroupCell.h"

@protocol APExpandableTableViewDelegate;

@interface APExpandableTableView : UITableView <UITableViewDataSource, UITableViewDelegate, APExpandableTableViewChildTableViewDelegate>

@property(nonatomic,strong) id<APExpandableTableViewDelegate> expandableTableViewDelegate;

- (NSUInteger)groupIndexForRow:(NSUInteger)row;
- (void)reloadChildAtGroupIndex:(NSInteger)groupIndex animate:(BOOL)animate;
- (void)collapseAllGroups;
- (void)reloadData;

@end

@protocol APExpandableTableViewDelegate <NSObject>

@optional
- (void)expandableTableView:(APExpandableTableView *)tableView didSelectChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView moveGroupAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView deleteGroupAtIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView deleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (CGFloat)heightForChildCellInExpandableTableView:(APExpandableTableView *)tableView;
- (BOOL)indicatorOnLeftInExpandableTableView:(APExpandableTableView *)tableView;
- (BOOL)expandableTableView:(APExpandableTableView *)tableView isGroupExpandableAtIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView didSelectGroupAtIndex:(NSInteger)groupIndex;
- (UIImage *)expandIndicatorForExpandableTableView:(APExpandableTableView *)tableView;
- (UIView *)expandableTableView:(APExpandableTableView *)tableView groupAccessoryViewForGroupIndex:(NSInteger)groupIndex;
- (UIView *)expandableTableView:(APExpandableTableView *)tableView childAccessoryViewForChildIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@required
- (NSInteger)numberOfGroupsInExpandableTableView:(APExpandableTableView *)tableView;
- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForGroupAtIndex:(NSInteger)groupIndex;
- (NSInteger)expandableTableView:(APExpandableTableView *)tableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex;
- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@end
