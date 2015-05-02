//
//  APExpandableTableViewChildTableView.m
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import "APExpandableTableViewChildTableView.h"
#import "APExpandableTableViewConstants.h"

@implementation APExpandableTableViewChildTableView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        [self.tableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
        self.tableView.scrollEnabled = NO;
        [self.contentView addSubview:self.tableView];
        
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = CGRectMake(INSET_CHILD_TABLE, 0, self.contentView.frame.size.width - INSET_CHILD_TABLE, [self tableView:self.tableView heightForRowAtIndexPath:nil] * [self.delegate expandableTableViewChildTableView:self numberOfChildrenForGroupAtIndex:self.groupIndex]);
}

- (void)setDelegate:(id<APExpandableTableViewChildTableViewDelegate>)delegate {
    _delegate = delegate;
    [self layoutSubviews];
}

- (void) reloadDataWithAnimation:(BOOL)animate {
    if (animate) {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.delegate expandableTableViewChildTableView:self numberOfChildrenForGroupAtIndex:self.groupIndex];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.delegate expandableTableViewChildTableView:self cellForChildAtIndex:indexPath.row groupIndex:self.groupIndex];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = cell.backgroundColor;
    cell.backgroundColor = [UIColor clearColor];
    if ([self.delegate respondsToSelector:@selector(expandableTableViewChildTableView:childAccessoryViewForChildIndex:groupIndex:)]) {
        cell.accessoryView = [self.delegate expandableTableViewChildTableView:self childAccessoryViewForChildIndex:indexPath.row groupIndex:self.groupIndex];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(heightForExpandableTableViewChildTableView:)]) {
        return [self.delegate heightForExpandableTableViewChildTableView:self];
    } else {
        return DEFAULT_CHILD_CELL_HEIGHT;
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(expandableTableViewChildTableView:didSelectChildAtIndex:groupIndex:)]) {
        [self.delegate expandableTableViewChildTableView:self didSelectChildAtIndex:indexPath.row groupIndex:self.groupIndex];
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(expandableTableViewChildTableView:canDeleteChildAtIndex:groupIndex:)]) {
        return [self.delegate expandableTableViewChildTableView:self canDeleteChildAtIndex:indexPath.row groupIndex:self.groupIndex];
    } else {
        return YES;
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(expandableTableViewChildTableView:canMoveChildAtIndex:groupIndex:)]) {
        return [self.delegate expandableTableViewChildTableView:self canMoveChildAtIndex:indexPath.row groupIndex:self.groupIndex];
    } else {
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if ([self.delegate respondsToSelector:@selector(expandableTableViewChildTableView:moveChildAtIndex:toIndex:groupIndex:)]) {
        [self.delegate expandableTableViewChildTableView:self moveChildAtIndex:sourceIndexPath.row toIndex:destinationIndexPath.row groupIndex:self.groupIndex];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [self.delegate respondsToSelector:@selector(expandableTableViewChildTableView:deleteChildAtIndex:groupIndex:)]) {
        [self.delegate expandableTableViewChildTableView:self deleteChildAtIndex:indexPath.row groupIndex:self.groupIndex];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}


@end
