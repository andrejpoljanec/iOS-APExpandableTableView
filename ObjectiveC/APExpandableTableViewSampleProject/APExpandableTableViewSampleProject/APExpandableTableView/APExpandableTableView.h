//
//  APExpandableTableView.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

/*
 To convert a normal table into an expandable table, there are multiple solutions. The idea in this implementation is to have two types of cells, 
 group cells and child cells. Group cells are normal cells just like in any other table. Child cells are each actually a complete table within 
 which we define the real child cells. So child cells are actually another UITableView inside a UITableViewCell. The expandable table view then 
 functions in a way that when a group cell is clicked, a table is inserted as a child cell. When a group cell is clicked again, the child table 
 is removed to make the group collapse. The idea has its pros and cons, but I like it because it groups up the child cells together and keeps 
 them separate from group cells. Reordering also makes much more sense in this way.
 */

#import <UIKit/UIKit.h>
#import "APExpandableTableViewChildTableView.h"
#import "APExpandableTableViewGroupCell.h"

@protocol APExpandableTableViewDelegate;

@interface APExpandableTableView : UITableView <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate, APExpandableTableViewChildTableViewDelegate>

@property(nonatomic,strong) id<APExpandableTableViewDelegate> expandableTableViewDelegate;

// Returns group index for row. For example if the row is actually the one of the children in the group, the returned number will be the group within
// which that child resides. If it's called with a group, the same index is returned.
- (NSUInteger)groupIndexForRow:(NSUInteger)row;


// Each child table can be reloaded separately
- (void)reloadChildAtGroupIndex:(NSInteger)groupIndex animate:(BOOL)animate;
// Or the whole table can be reloaded
- (void)reloadData;

// Collapse all groups
- (void)collapseAllGroups;

@end

@protocol APExpandableTableViewDelegate <NSObject>

@optional

// All groups by default are expandable. To make it non expandable, implement this method.
- (BOOL)expandableTableView:(APExpandableTableView *)tableView isGroupExpandableAtIndex:(NSInteger)groupIndex;

// Reacting to cell clicks. Group can only react if it's non expandable.
- (void)expandableTableView:(APExpandableTableView *)tableView didSelectChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView didSelectGroupAtIndex:(NSInteger)groupIndex;

// Moving cells
- (BOOL)expandableTableView:(APExpandableTableView *)tableView canMoveGroupAtIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView moveGroupAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex;
- (BOOL)expandableTableView:(APExpandableTableView *)tableView canMoveChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex;

// Deleting cells
- (BOOL)expandableTableView:(APExpandableTableView *)tableView canDeleteGroupAtIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView deleteGroupAtIndex:(NSInteger)groupIndex;
- (BOOL)expandableTableView:(APExpandableTableView *)tableView canDeleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableView:(APExpandableTableView *)tableView deleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

// Visual stuff

// Cell heights
- (CGFloat)expandableTableView:(APExpandableTableView *)tableView heightForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (CGFloat)expandableTableView:(APExpandableTableView *)tableView heightForGroupAtIndex:(NSInteger)groupIndex;
// Indicator position
- (BOOL)indicatorOnLeftInExpandableTableView:(APExpandableTableView *)tableView;
// Indicator icon
- (UIImage *)expandIndicatorForExpandableTableView:(APExpandableTableView *)tableView;
// Accessory views
- (UIView *)expandableTableView:(APExpandableTableView *)tableView groupAccessoryViewForGroupIndex:(NSInteger)groupIndex;
- (UIView *)expandableTableView:(APExpandableTableView *)tableView childAccessoryViewForChildIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@required

// Similar to UITableViewDataSource, separately for group and child cells
- (NSInteger)numberOfGroupsInExpandableTableView:(APExpandableTableView *)tableView;
- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForGroupAtIndex:(NSInteger)groupIndex;
- (NSInteger)expandableTableView:(APExpandableTableView *)tableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex;
- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@end
