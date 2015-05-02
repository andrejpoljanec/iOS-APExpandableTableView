//
//  APExpandableTableViewChildCell.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_CHILD_CELL_HEIGHT 50
#define INSET_CHILD_TABLE 20

@protocol APExpandableTableViewChildTableViewDelegate;

@interface APExpandableTableViewChildTableView : UITableViewCell <UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic) NSInteger groupIndex;

@property(nonatomic,strong) id<APExpandableTableViewChildTableViewDelegate> delegate;

- (void) reloadDataWithAnimation:(BOOL)animate;

@end

@protocol APExpandableTableViewChildTableViewDelegate <NSObject>

@optional
- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView didSelectChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView deleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (CGFloat)heightForExpandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView;
- (UIView *)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView childAccessoryViewForChildIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@required
- (NSInteger)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex;
- (UITableViewCell *)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@end