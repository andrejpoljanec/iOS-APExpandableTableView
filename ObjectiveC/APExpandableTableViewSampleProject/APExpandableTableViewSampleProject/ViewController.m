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

@implementation ViewController {
    NSMutableArray *data;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    data = [[NSMutableArray alloc] init];
    NSMutableArray *group1 = [[NSMutableArray alloc] initWithObjects:@"Group 1", @"A", @"B", nil];
    NSMutableArray *group2 = [[NSMutableArray alloc] initWithObjects:@"Group 2", @"C", @"D", nil];
    NSMutableArray *group3 = [[NSMutableArray alloc] initWithObjects:@"Group 3", @"E", @"F", nil];
    [data addObject:group1];
    [data addObject:group2];
    [data addObject:group3];
    
    self.expandableTableView.expandableTableViewDelegate = self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.expandableTableView setEditing:editing animated:animated];
}

- (NSInteger)expandableTableView:(APExpandableTableView *)tableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex {
    return [[data objectAtIndex:groupIndex] count] - 1;
}

- (NSInteger)numberOfGroupsInExpandableTableView:(APExpandableTableView *)tableView {
    return [data count];
}

- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    NSString *cellIdentifier = @"SampleChildCell";
    
    UITableViewCell *cell = [self.expandableTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[data objectAtIndex:groupIndex] objectAtIndex:childIndex + 1];
        
    return cell;
}

- (UITableViewCell *)expandableTableView:(APExpandableTableView *)tableView cellForGroupAtIndex:(NSInteger)groupIndex {
    NSString *cellIdentifier = @"SampleGroupCell";
    
    UITableViewCell *cell = [self.expandableTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [[data objectAtIndex:groupIndex] objectAtIndex:0];
    
    return cell;
}

- (void)expandableTableView:(APExpandableTableView *)tableView deleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    [[data objectAtIndex:groupIndex] removeObjectAtIndex:childIndex + 1];
}

- (void)expandableTableView:(APExpandableTableView *)tableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex {
    NSString *moveObject = [[data objectAtIndex:groupIndex] objectAtIndex:sourceIndex + 1];
    [[data objectAtIndex:groupIndex] removeObjectAtIndex:sourceIndex + 1];
    [[data objectAtIndex:groupIndex] insertObject:moveObject atIndex:destinationIndex + 1];
}

- (void)expandableTableView:(APExpandableTableView *)tableView moveGroupAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex {
    NSMutableArray *moveObject = [data objectAtIndex:sourceIndex];
    [data removeObjectAtIndex:sourceIndex];
    [data insertObject:moveObject atIndex:destinationIndex];
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
