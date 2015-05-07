//
//  APExpandableTableViewChildTableView.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol APExpandableTableViewChildTableViewDelegate;

@interface APExpandableTableViewChildTableView : UITableViewCell <UITableViewDataSource,UITableViewDelegate>

// Child table
@property(nonatomic,strong) UITableView *tableView;
// Group index to which the child table belongs
@property(nonatomic) NSInteger groupIndex;
@property(nonatomic,strong) id<APExpandableTableViewChildTableViewDelegate> delegate;

// Reload the child table
- (void) reloadDataWithAnimation:(BOOL)animate;

@end

@protocol APExpandableTableViewChildTableViewDelegate <NSObject>

@optional

// Callbacks for selecting, moving and deleting
- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView didSelectChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (BOOL)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView canMoveChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex;
- (BOOL)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView canDeleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView deleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

// Visual
- (CGFloat)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView heightForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;
- (UIView *)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView childAccessoryViewForChildIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@required

// DataSource stuff
- (NSInteger)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex;
- (UITableViewCell *)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex;

@end