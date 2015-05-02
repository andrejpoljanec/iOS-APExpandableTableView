//
//  APExpandableTableView.m
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import "APExpandableTableView.h"
#import "APExpandableTableViewConstants.h"

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
    // Set UITableView callbacks
    [self setDataSource:self];
    [self setDelegate:self];
    
    // Add separators to the table
    self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    // Add a footer view so that the visual part of the table ends with the last cell
    UIView *footer = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableFooterView = footer;
}

// Setter for the delegate. When we have the delegate, we can initialize the expansion states.
- (void)setExpandableTableViewDelegate:(id<APExpandableTableViewDelegate>)expandableTableViewDelegate {
    _expandableTableViewDelegate = expandableTableViewDelegate;
    [self initExpansionStates];
}

// Set all the expansion states to collapsed.
- (void)initExpansionStates
{
    NSInteger groupCount = [self.expandableTableViewDelegate numberOfGroupsInExpandableTableView:self];
    expandedGroups = [[NSMutableArray alloc] initWithCapacity:groupCount];
    for(int i = 0; i < groupCount; i++) {
        [expandedGroups addObject:[NSNumber numberWithBool:NO]];
    }
}

// Collapses or expands a single group at specified indexPath. indexPath can be one of the child, it will recalculate to get the group index.
- (void)toggleGroupAtIndexPath:(NSIndexPath *)indexPath {
    
    [self beginUpdates];
    
    // Make sure we have the index of the group, not of the child
    NSInteger groupIndex = [self groupIndexForRow:indexPath.row];
    
    // Check if the cell is expanded or collapsed
    BOOL expanded = [[expandedGroups objectAtIndex:groupIndex] boolValue];
    
    // Collapse or expand as necessary
    [expandedGroups replaceObjectAtIndex:groupIndex withObject:[NSNumber numberWithBool:!expanded]];
    
    // Get the index path of the child table, so the next cell after the group cell
    NSIndexPath *nextIndexPath = [NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:0];
    
    if (expanded) {
        // If it's expanded, we remove the child table
        [self deleteRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        // If it's collapsed, we insert the child table
        [self insertRowsAtIndexPaths:[NSArray arrayWithObject:nextIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    [self endUpdates];
    
    // Visual change on the group cell. Update the indicator to show that the group is expanded.
    APExpandableTableViewGroupCell *groupCell = (APExpandableTableViewGroupCell *)[self cellForRowAtIndexPath:indexPath];
    [groupCell updateIndicatorToExpanded:[[expandedGroups objectAtIndex:[groupCell groupIndex]] boolValue] animate:YES];
}

// Collapses all groups
-(void)collapseAllGroups {
    for (int i = 0; i < expandedGroups.count; i++) {
        if ([[expandedGroups objectAtIndex:i] boolValue]) {
            [self toggleGroupAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        }
    }
}

// Reload data, together with adjusting the expanded groups set
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

// Reload a child table
-(void)reloadChildAtGroupIndex:(NSInteger)groupIndex animate:(BOOL)animate {
    NSInteger index = [self rowForGroupIndex:groupIndex] + 1;
    APExpandableTableViewChildTableView *cell = (APExpandableTableViewChildTableView *)[self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell reloadDataWithAnimation:animate];
    [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark - helper methods

// Convert group index to the row that a group is in.
// For example if we have 3 groups and 0 is expanded, then group 2 is in row 3. If none are expanded, then group 2 is in row 2.
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
    return row;
}

// Find the corresponding group index for a row.
// For example if we have 3 groups and 0 is expanded, then row 2 is group 1 (row 1 is the child table). If none are expanded, then row 2 is group 2.
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

// Check if the row contains a group cell or a child table.
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
    // For now we only have 1 section. Can be expanded to more if needed.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Count the groups that are expanded and combine them to get the number of all rows
    NSInteger groupCount = [self.expandableTableViewDelegate numberOfGroupsInExpandableTableView:self];
    NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:expandedGroups];
    NSUInteger expandedGroupCount = [countedSet countForObject:[NSNumber numberWithBool:YES]];
    
    return groupCount + expandedGroupCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger groupIndex = [self groupIndexForRow:indexPath.row];
    
    if ([self isChildCell:indexPath.row]) {
        
        // Set up child cell
        
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
        
        // Set up group cell
        // Group cell consists of an expand indicator and the cell provided by the delegate, which here is called innerCell
        
        NSString *groupCellID = @"GroupCell";
        UITableViewCell *innerCell;
        APExpandableTableViewGroupCell *cell = (APExpandableTableViewGroupCell *)[self dequeueReusableCellWithIdentifier:groupCellID];
        if (cell == nil) {
            cell = [[APExpandableTableViewGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:groupCellID];
        }
        
        // Attach the inner cell
        innerCell = [self.expandableTableViewDelegate expandableTableView:self cellForGroupAtIndex:indexPath.row];
        [cell setGroupIndex:groupIndex];
        [cell attachInnerCell:innerCell];
        
        // Expand state
        BOOL expanded = [[expandedGroups objectAtIndex:groupIndex] boolValue];
        [cell updateIndicatorToExpanded:expanded animate:NO];
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:isGroupExpandableAtIndex:)]) {
            cell.expandable = [self.expandableTableViewDelegate expandableTableView:self isGroupExpandableAtIndex:groupIndex];
        }
        
        // Visual design of the cell
        cell.backgroundColor = innerCell.backgroundColor;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(indicatorOnLeftInExpandableTableView:)]) {
            cell.indicatorOnLeft = [self.expandableTableViewDelegate indicatorOnLeftInExpandableTableView:self];
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canDeleteGroupAtIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self canDeleteGroupAtIndex:[self groupIndexForRow:indexPath.row]];
    } else {
        return YES;
    }
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Can only move a group in the outer table
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canMoveGroupAtIndex:)]) {
        return (indexPath.row == 0 || [self groupIndexForRow:indexPath.row] != [self groupIndexForRow:indexPath.row - 1]) && [self.expandableTableViewDelegate expandableTableView:self canMoveGroupAtIndex:[self groupIndexForRow:indexPath.row]];
    } else {
        return indexPath.row == 0 || [self groupIndexForRow:indexPath.row] != [self groupIndexForRow:indexPath.row - 1];
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    // Can only move to a position of a group cell in the outer table
    if (proposedDestinationIndexPath.row == 0 || [self groupIndexForRow:proposedDestinationIndexPath.row - 1] != [self groupIndexForRow:proposedDestinationIndexPath.row]) {
        return proposedDestinationIndexPath;
    } else {
        return sourceIndexPath;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    APExpandableTableViewGroupCell *sourceCell = (APExpandableTableViewGroupCell *)[self cellForRowAtIndexPath:sourceIndexPath];
    APExpandableTableViewGroupCell *destinationCell = (APExpandableTableViewGroupCell *)[self cellForRowAtIndexPath:destinationIndexPath];
    NSUInteger sourceGroupIndex = sourceCell.groupIndex;
    NSUInteger destinationGroupIndex = destinationCell.groupIndex;
    sourceCell.groupIndex = destinationGroupIndex;
    destinationCell.groupIndex = sourceGroupIndex;
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:moveGroupAtIndex:toIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self moveGroupAtIndex:sourceGroupIndex toIndex:destinationGroupIndex];
    }
    // Collapse the group for now
    // TODO: if expanded, move the child table with it
    if ([[expandedGroups objectAtIndex:sourceGroupIndex] boolValue]) {
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
            // If it's not expandable, we can react to a click in a different way than toggling
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

- (BOOL)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView canDeleteChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableViewChildTableView:canDeleteChildAtIndex:groupIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self canDeleteChildAtIndex:childIndex groupIndex:groupIndex];
    } else {
        return YES;
    }
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

- (BOOL)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView canMoveChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableViewChildTableView:canMoveChildAtIndex:groupIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self canMoveChildAtIndex:childIndex groupIndex:groupIndex];
    } else {
        return YES;
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
