//
//  ViewController.m
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
        
    self.expandableTableView.expandableTableViewDelegate = self;
        
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.expandableTableView setEditing:editing animated:animated];
}

- (NSInteger)expandableTableView:(APExpandableTableView *)tableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex {
    return 2;
}

- (NSInteger)numberOfGroupsInExpandableTableView:(APExpandableTableView *)tableView {
    return 3;
}

- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    NSString *cellIdentifier = @"SampleChildCell";
    
    UITableViewCell *cell = [self.expandableTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Child cell #%ld", childIndex];
        
    return cell;
}

- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForGroupAtIndex:(NSInteger)groupIndex {
    NSString *cellIdentifier = @"SampleGroupCell";
    
    UITableViewCell *cell = [self.expandableTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"Parent cell #%ld", groupIndex];
    
    return cell;
}

- (BOOL)expandableTableView:(APExpandableTableView *)tableView canMoveChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    return YES;
}

- (BOOL)expandableTableView:(APExpandableTableView *)tableView canDeleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    return YES;
}

- (BOOL)expandableTableView:(APExpandableTableView *)tableView canMoveGroupAtIndex:(NSInteger)groupIndex {
    return YES;
}

- (IBAction)editAction:(id)sender {
    [self setEditing:!self.isEditing animated:YES];
    self.editButton.title = self.isEditing ? @"Done" : @"Edit";
}

@end
