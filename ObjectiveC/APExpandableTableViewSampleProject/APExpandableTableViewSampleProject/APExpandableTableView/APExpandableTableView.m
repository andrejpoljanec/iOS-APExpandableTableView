//
//  APExpandableTableView.m
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import "APExpandableTableView.h"

@implementation APExpandableTableView {
    NSMutableArray *expandedGroups;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        [self initialize];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self setDataSource:self];
    [self setDelegate:self];
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableFooterView = footer;
}

- (void)setExpandableTableViewDelegate:(id<APExpandableTableViewDelegate>)expandableTableViewDelegate {
    _expandableTableViewDelegate = expandableTableViewDelegate;
    [self initExpansionStates];
}

- (void)initExpansionStates
{
    NSInteger groupCount = [self.expandableTableViewDelegate numberOfGroupsInExpandableTableView:self];
    expandedGroups = [[NSMutableArray alloc] initWithCapacity:groupCount];
    for(int i = 0; i < groupCount; i++) {
        [expandedGroups addObject:[NSNumber numberWithBool:NO]];
    }
}

- (void)toggleGroupAtIndexPath:(NSIndexPath *)indexPath {
    [self beginUpdates];
    NSInteger groupIndex = [self groupIndexForRow:indexPath.row];
    BOOL expanded = [[expandedGroups objectAtIndex:groupIndex] boolValue];
    [expandedGroups replaceObjectAtIndex:groupIndex withObject:[NSNumber numberWithBool:!expanded]];
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:0];
    if (expanded) {
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    [self deselectRowAtIndexPath:indexPath animated:NO];
    [self endUpdates];
    APExpandableTableViewGroupCell *groupCell = (APExpandableTableViewGroupCell *)[self cellForRowAtIndexPath:indexPath];
    [groupCell updateIndicatorToExpanded:[[expandedGroups objectAtIndex:[groupCell groupIndex]] boolValue] animate:YES];
    if (!expanded) {
        [self scrollToRowAtIndexPath:nextIndexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (NSUInteger)rowForGroupIndex:(NSUInteger)groupIndex {
    NSUInteger row = 0;
    NSUInteger index = 0;
    
    while (index < groupIndex) {
        BOOL expanded = [[expandedGroups objectAtIndex:index] boolValue];
        if (expanded) {
            row++;
        }
        index++;
        row++;
    }
    NSLog(@"Group %lu, Row %lu", (unsigned long)groupIndex, (unsigned long)row);
    return row;
}

- (NSUInteger)groupIndexForRow:(NSUInteger)row {
    NSUInteger groupIndex = -1;
    NSUInteger index = 0;
    
    while (index <= row) {
        groupIndex ++;
        index++;
        if ([[expandedGroups objectAtIndex:groupIndex] boolValue]) {
            index++;
        }
    }
    return groupIndex;
}

- (BOOL)isChildCell:(NSUInteger)row {
    if (row == 0) {
        return NO;
    } else {
        return [self groupIndexForRow:row] == [self groupIndexForRow:row - 1];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger groupCount = [self.expandableTableViewDelegate numberOfGroupsInExpandableTableView:self];
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:expandedGroups];
    NSUInteger expandedGroupCount = [countedSet countForObject:[NSNumber numberWithBool:YES]];
    
    return groupCount + expandedGroupCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSUInteger groupIndex = [self groupIndexForRow:indexPath.row];
    if ([self isChildCell:indexPath.row]) {
        NSString *childCellID = @"ChildCell";
        APExpandableTableViewChildTableView *cell = (APExpandableTableViewChildTableView *)[self dequeueReusableCellWithIdentifier:childCellID];
        if (cell == nil) {
            cell = [[APExpandableTableViewChildTableView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:childCellID];
        }
        [cell setGroupIndex:groupIndex];
        [cell setDelegate:self];
        [cell reloadDataWithAnimation:NO];
        return cell;
    } else {
        NSString *groupCellID = @"GroupCell";
        UITableViewCell *innerCell;
        APExpandableTableViewGroupCell *cell = (APExpandableTableViewGroupCell *)[self dequeueReusableCellWithIdentifier:groupCellID];
        if (cell == nil) {
            cell = [[APExpandableTableViewGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCellID];
        }
        innerCell = [self.expandableTableViewDelegate expandableTableView:self cellForGroupAtIndex:indexPath.row];
        [cell setGroupIndex:groupIndex];
        [cell attachInnerCell:innerCell];
        BOOL expanded = [[expandedGroups objectAtIndex:groupIndex] boolValue];
        [cell updateIndicatorToExpanded:expanded animate:NO];
        cell.backgroundColor = innerCell.backgroundColor;
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(indicatorOnLeftInExpandableTableView:)]) {
            cell.indicatorOnLeft = [self.expandableTableViewDelegate indicatorOnLeftInExpandableTableView:self];
        }
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:isGroupExpandableAtIndex:)]) {
            cell.expandable = [self.expandableTableViewDelegate expandableTableView:self isGroupExpandableAtIndex:groupIndex];
        }
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandIndicatorForExpandableTableView:)]) {
            cell.indicator.image = [self.expandableTableViewDelegate expandIndicatorForExpandableTableView:self];
        }
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:groupAccessoryViewForGroupIndex:)]) {
            cell.accessoryView = [self.expandableTableViewDelegate expandableTableView:self groupAccessoryViewForGroupIndex:groupIndex];
        }
        
        
        return cell;
    }
}

// TODO
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

// TODO
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if (proposedDestinationIndexPath.row == 0 || [self groupIndexForRow:proposedDestinationIndexPath.row - 1] != [self groupIndexForRow:proposedDestinationIndexPath.row]) {
        return proposedDestinationIndexPath;
    } else {
        return sourceIndexPath;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    APExpandableTableViewGroupCell *sourceCell = (APExpandableTableViewGroupCell *)[self cellForRowAtIndexPath:sourceIndexPath];
    APExpandableTableViewGroupCell *destinationCell = (APExpandableTableViewGroupCell *)[self cellForRowAtIndexPath:destinationIndexPath];
    NSUInteger groupIndex = sourceCell.groupIndex;
    NSUInteger destinationGroupIndex = destinationCell.groupIndex;
    sourceCell.groupIndex = destinationGroupIndex;
    destinationCell.groupIndex = groupIndex;
    [self.expandableTableViewDelegate expandableTableView:self moveGroupAtIndex:groupIndex toIndex:destinationGroupIndex];
    if ([[expandedGroups objectAtIndex:groupIndex] boolValue]) {
        [self toggleGroupAtIndexPath:[NSIndexPath indexPathForRow:sourceIndexPath.row inSection:0]];
        [self reloadSections:[NSIndexSet indexSetWithIndex:sourceIndexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:deleteGroupAtIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self deleteGroupAtIndex:[self groupIndexForRow:indexPath.row]];
        [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [expandedGroups removeObjectAtIndex:indexPath.row];
    }
}

-(void)collapseAllGroups {
    for (int i = 0; i < expandedGroups.count; i++) {
        if ([[expandedGroups objectAtIndex:i] boolValue]) {
            [self toggleGroupAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
}

-(void)reloadData {
    NSInteger groupCount = [self.expandableTableViewDelegate numberOfGroupsInExpandableTableView:self];
    NSInteger currentIndex = expandedGroups.count - 1;
    while (groupCount > expandedGroups.count) {
        currentIndex++;
        [expandedGroups addObject:[NSNumber numberWithBool:NO]];
    }
    while (groupCount < expandedGroups.count) {
        [expandedGroups removeObjectAtIndex:expandedGroups.count - 1];
    }
    [super reloadData];
}

-(void)reloadChildAtGroupIndex:(NSInteger)groupIndex animate:(BOOL)animate {
    NSInteger index = [self rowForGroupIndex:groupIndex] + 1;
    APExpandableTableViewChildTableView *cell = (APExpandableTableViewChildTableView *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell reloadDataWithAnimation:animate];
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL childCell = [self isChildCell:indexPath.row];
    if (childCell) {
        NSInteger groupIndex = [self groupIndexForRow:indexPath.row];
        NSInteger childCount = [self.expandableTableViewDelegate expandableTableView:self numberOfChildrenForGroupAtIndex:groupIndex];
        return [self heightForExpandableTableViewChildCell] * childCount;
    } else {
        return DEFAULT_GROUP_CELL_HEIGHT;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger groupIndex = [self groupIndexForRow:indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell isKindOfClass:[APExpandableTableViewGroupCell class]]) {
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:isGroupExpandableAtIndex:)] && ![self.expandableTableViewDelegate expandableTableView:self isGroupExpandableAtIndex:groupIndex]) {
            if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:didSelectGroupAtIndex:)]) {
                [self.expandableTableViewDelegate expandableTableView:self didSelectGroupAtIndex:groupIndex];
            }
        } else {
            [self toggleGroupAtIndexPath:indexPath];
        }
    }
}

#pragma mark - Child Cells

- (NSInteger)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView numberOfChildrenForGroupAtIndex:(NSInteger)groupIndex {
    return [self.expandableTableViewDelegate expandableTableView:self numberOfChildrenForGroupAtIndex:groupIndex];
}

- (UITableViewCell *)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView cellForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    return [self.expandableTableViewDelegate expandableTableView:self cellForChildAtIndex:childIndex groupIndex:groupIndex];
}

- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView deleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:deleteChildAtIndex:groupIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self deleteChildAtIndex:childIndex groupIndex:groupIndex];
    }
}

- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView didSelectChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:didSelectChildAtIndex:groupIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self didSelectChildAtIndex:childIndex groupIndex:groupIndex];
    }
}

- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:moveChildAtIndex:toIndex:groupIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self moveChildAtIndex:sourceIndex toIndex:destinationIndex groupIndex:groupIndex];
    }
}

- (CGFloat)heightForExpandableTableViewChildCell {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(heightForChildCellInExpandableTableView:)]) {
        return [self.expandableTableViewDelegate heightForChildCellInExpandableTableView:self];
    } else {
        return DEFAULT_CHILD_CELL_HEIGHT;
    }
}

- (UIView *)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView childAccessoryViewForChildIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:childAccessoryViewForChildIndex:groupIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self childAccessoryViewForChildIndex:childIndex groupIndex:groupIndex];
    } else {
        return nil;
    }
}

@end
