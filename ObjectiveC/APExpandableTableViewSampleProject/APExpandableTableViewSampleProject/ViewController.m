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
    
    self.expandableTableView.expandableTableViewDelegate = self;
}

- (NSInteger)expandableTableView:(APExpandableTableView *)tableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex {
    return 2;
}

- (NSInteger)numberOfGroupsInExpandableTableView:(APExpandableTableView *)tableView {
    return 2;
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


@end
