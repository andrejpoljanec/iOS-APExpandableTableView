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
    
    // React to touches instantly
    self.delaysContentTouches = NO;
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
        
        NSString *childCellID = @"APExpandableTableViewChildCell";
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
        
        NSString *groupCellID = @"APExpandableTableViewGroupCell";
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
        
        cell.tag = groupIndex;
        
        return cell;
    }
}

// Table can still edit the row if the child table is editable and group is not
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL canEdit = NO;
    NSInteger groupIndex = [self groupIndexForRow:indexPath.row];
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canDeleteGroupAtIndex:)]) {
        canEdit = [self.expandableTableViewDelegate expandableTableView:self canDeleteGroupAtIndex:groupIndex];
    }
    if (!canEdit && [self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canMoveChildAtIndex:groupIndex:)]) {
        for (int i = 0; i < [self.expandableTableViewDelegate expandableTableView:self numberOfChildrenForGroupAtIndex:groupIndex]; i++) {
            if ([self.expandableTableViewDelegate expandableTableView:self canMoveChildAtIndex:i groupIndex:groupIndex]) {
                canEdit = YES;
                break;
            }
        }
    }
    if (!canEdit && [self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canDeleteChildAtIndex:groupIndex:)]) {
        for (int i = 0; i < [self.expandableTableViewDelegate expandableTableView:self numberOfChildrenForGroupAtIndex:groupIndex]; i++) {
            if ([self.expandableTableViewDelegate expandableTableView:self canDeleteChildAtIndex:i groupIndex:groupIndex]) {
                canEdit = YES;
                break;
            }
        }
    }
    return canEdit;
}

// If only child table is editable, then set editing style for the group to none
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canDeleteGroupAtIndex:)]) {
        if ([self.expandableTableViewDelegate expandableTableView:self canDeleteGroupAtIndex:[self groupIndexForRow:indexPath.row]]) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

// If only child table is editable, then don't indent
-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canDeleteGroupAtIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self canDeleteGroupAtIndex:[self groupIndexForRow:indexPath.row]];
    }
    return NO;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Can only move a group in the outer table
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canMoveGroupAtIndex:)]) {
        return (indexPath.row == 0 || [self groupIndexForRow:indexPath.row] != [self groupIndexForRow:indexPath.row - 1]) && [self.expandableTableViewDelegate expandableTableView:self canMoveGroupAtIndex:[self groupIndexForRow:indexPath.row]];
    } else {
        return NO;
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
    BOOL sourceExpanded = [expandedGroups objectAtIndex:sourceGroupIndex];
    BOOL destinationExpanded = [expandedGroups objectAtIndex:destinationGroupIndex];
    [expandedGroups replaceObjectAtIndex:sourceGroupIndex withObject:[NSNumber numberWithBool:destinationExpanded]];
    [expandedGroups replaceObjectAtIndex:destinationGroupIndex withObject:[NSNumber numberWithBool:sourceExpanded]];
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:moveGroupAtIndex:toIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self moveGroupAtIndex:sourceGroupIndex toIndex:destinationGroupIndex];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete && [self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:deleteGroupAtIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self deleteGroupAtIndex:[self groupIndexForRow:indexPath.row]];
        [self reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        [expandedGroups removeObjectAtIndex:[self groupIndexForRow:indexPath.row]];
    }
}

#pragma mark - UITableViewDelegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger groupIndex = [self groupIndexForRow:indexPath.row];
    BOOL childCell = [self isChildCell:indexPath.row];
    if (childCell) {
        NSInteger childCount = [self.expandableTableViewDelegate expandableTableView:self numberOfChildrenForGroupAtIndex:groupIndex];
        CGFloat height = 0;
        for (int i = 0; i < childCount; i++) {
            if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:heightForChildAtIndex:groupIndex:)]) {
                height += [self.expandableTableViewDelegate expandableTableView:self heightForChildAtIndex:i groupIndex:groupIndex];
            } else {
                height += DEFAULT_CHILD_CELL_HEIGHT;
            }        }
        return height;
    } else {
        if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:heightForGroupAtIndex:)]) {
            return [self.expandableTableViewDelegate expandableTableView:self heightForGroupAtIndex:groupIndex];
        } else {
            return DEFAULT_GROUP_CELL_HEIGHT;
        }
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
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canDeleteChildAtIndex:groupIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self canDeleteChildAtIndex:childIndex groupIndex:groupIndex];
    } else {
        return NO;
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
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:canMoveChildAtIndex:groupIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self canMoveChildAtIndex:childIndex groupIndex:groupIndex];
    } else {
        return NO;
    }
}

- (void)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView moveChildAtIndex:(NSInteger)sourceIndex toIndex:(NSInteger)destinationIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:moveChildAtIndex:toIndex:groupIndex:)]) {
        [self.expandableTableViewDelegate expandableTableView:self moveChildAtIndex:sourceIndex toIndex:destinationIndex groupIndex:groupIndex];
    }
}

- (CGFloat)expandableTableViewChildTableView:(APExpandableTableViewChildTableView *)expandableTableViewChildTableView heightForChildAtIndex:(NSInteger)childIndex groupIndex:(NSInteger)groupIndex {
    if ([self.expandableTableViewDelegate respondsToSelector:@selector(expandableTableView:heightForChildAtIndex:groupIndex:)]) {
        return [self.expandableTableViewDelegate expandableTableView:self heightForChildAtIndex:childIndex groupIndex:groupIndex];
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

#pragma mark - Reordering

// Snapshot of whatever we are dragging.
static UIView *snapshot = nil;
// Remember the current index path of whatever we are dragging.
static NSIndexPath *sourceIndexPath = nil;
// Vertical difference between the top of the cell and initial dragging position.
static CGFloat gripY = 0;
// Remember if we are also dragging a child table.
static BOOL sourceHasChild;

// x coordinate of a reorder view.
static CGFloat reorderX = 0;

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        // A bit hacky. Find the reorder view in the table, disable it, and add a placeholder view that will server as a handle with a gesture recognizer.
        for (int i = 0; i < [self.expandableTableViewDelegate numberOfGroupsInExpandableTableView:self]; i++) {
            UIView *reorderView = [self findReorderControlForView:self groupIndex:i];
            if (reorderView) {
                reorderView.userInteractionEnabled = NO;
                // Remember the x coordinate so that we can react to the touch.
                reorderX = reorderView.frame.origin.x;
                UIView *fakeView = [[UIView alloc] initWithFrame:reorderView.frame];
                UIGestureRecognizer *gestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(reorderControlPanned:)];
                gestureRecognizer.delegate = self;
                [fakeView addGestureRecognizer:gestureRecognizer];
                [reorderView.superview addSubview:fakeView];
            }
        }
    }
}

// Method to find the UITableViewCellReorderControl inside the given view in a cell with the groupIndex
- (UIView *)findReorderControlForView:(UIView *)view groupIndex:(NSInteger)groupIndex{
    // If found, return it.
    if ([NSStringFromClass([view class]) rangeOfString:@"Reorder"].location != NSNotFound) {
        return view;
    }
    // Don't go inside the group cell with the wrong group index.
    if ([view isKindOfClass:[APExpandableTableViewGroupCell class]] && view.tag != groupIndex) {
        return nil;
    }
    // Child table also give reorder views. We don't need those.
    if ([view isKindOfClass:[APExpandableTableViewChildTableView class]]) {
        return nil;
    }
    // Now just go recursively through all the subviews.
    for (UIView *subview in view.subviews) {
        UIView *foundView = [self findReorderControlForView:subview groupIndex:groupIndex];
        if (foundView) {
            return foundView;
        }
    }
    return nil;
}

// React to the pan (drag).
- (void)reorderControlPanned:(UIGestureRecognizer *)gestureRecognizer {
    
    CGPoint location = [gestureRecognizer locationInView:self];
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    
    // Only drag if we know where we are coming from and where we are going.
    if (indexPath && sourceIndexPath) {
        
        switch (gestureRecognizer.state) {
                
            case UIGestureRecognizerStateChanged:
                [self dragCellToIndexPath:indexPath toLocation:location];
                break;
                
            case UIGestureRecognizerStateEnded:
                [self dropCell];
                break;
                
            default:
                break;
                
        }
    }
}

// React to the touch down of our own reorder view.
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    CGPoint location = [[touches anyObject] locationInView:self];
    
    // We only need to listen for touches if we are in editing mode and if the x location is in the range of reorder view.
    if (![self isEditing] || location.x < reorderX) {
        [super touchesBegan:touches withEvent:event];
        return;
    }
    
    NSIndexPath *indexPath = [self indexPathForRowAtPoint:location];
    if (indexPath) {
        [self gripCellAtIndexPath:indexPath atLocation:location];
    }
}

// React to the drop.
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // If we weren't dragging, pass on the call.
    if (!sourceIndexPath) {
        [super touchesEnded:touches withEvent:event];
        return;
    }
    
    [self dropCell];

}

// Grip the cell to start dragging.
- (void)gripCellAtIndexPath:(NSIndexPath *)indexPath atLocation:(CGPoint)location {
    
    UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
    
    sourceIndexPath = indexPath;
    
    // Make the snapshot of whatever we will be dragging and position it where the cell is.
    snapshot = [self snapshotOfGroupCell:cell groupIndex:[self groupIndexForRow:indexPath.row]];
    CGPoint origin = cell.frame.origin;
    CGRect frame = snapshot.frame;
    frame.origin = origin;
    snapshot.frame = frame;
    snapshot.alpha = 0.0;
    [self addSubview:snapshot];
    
    // Remember the relative location inside the cell where we are dragging.
    gripY = location.y - origin.y;
    
    UITableViewCell *childCell = nil;
    if ([[expandedGroups objectAtIndex:[self groupIndexForRow:indexPath.row]] boolValue]) {
        childCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
        sourceHasChild = YES;
    }
    
    // Animate to hide the real cell and display the snapshot.
    [UIView animateWithDuration:0.1f
                     animations:^{
                         snapshot.alpha = 1.0;
                         cell.alpha = 0.0;
                         if (childCell) {
                             childCell.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         cell.hidden = YES;
                         if (childCell) {
                             childCell.hidden = YES;
                         }
                     }];

}

// Drag the cell.
- (void)dragCellToIndexPath:(NSIndexPath *)indexPath toLocation:(CGPoint)location {
    
    // Reposition the snapshot.
    CGRect frame = snapshot.frame;
    frame.origin.y = location.y - gripY;
    snapshot.frame = frame;
    
    // Only swap rows if we are in a row with a different group index.
    if (![indexPath isEqual:sourceIndexPath] && (indexPath.row == 0  || ([self groupIndexForRow:indexPath.row] != [self groupIndexForRow:indexPath.row - 1]))) {
        
        // Calculate where we are moving the group cell.
        NSIndexPath *destinationIndexPath = indexPath;
        BOOL destinationHasChild = [[expandedGroups objectAtIndex:[self groupIndexForRow:indexPath.row]] boolValue];
        if (destinationHasChild && sourceIndexPath.row < indexPath.row) {
            destinationIndexPath = [self getNextIndexPath:destinationIndexPath];
        }
        
        // Make sure the set of expanded groups is in synch with data shown.
        NSInteger sourceGroupIndex = [self groupIndexForRow:sourceIndexPath.row];
        NSInteger destinationGroupIndex = [self groupIndexForRow:destinationIndexPath.row];
        BOOL sourceExpanded = [[expandedGroups objectAtIndex:sourceGroupIndex] boolValue];
        BOOL destinationExpanded = [[expandedGroups objectAtIndex:destinationGroupIndex] boolValue];
        [expandedGroups replaceObjectAtIndex:sourceGroupIndex withObject:[NSNumber numberWithBool:destinationExpanded]];
        [expandedGroups replaceObjectAtIndex:destinationGroupIndex withObject:[NSNumber numberWithBool:sourceExpanded]];
        
        // Move the rows to make room for the dragging cell.
        [self moveRowAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
        if (sourceHasChild) {
            NSIndexPath *sourceChildIndexPath = sourceIndexPath.row < indexPath.row ? sourceIndexPath : [self getNextIndexPath:sourceIndexPath];
            NSIndexPath *destinationChildIndexPath = sourceIndexPath.row < indexPath.row ? destinationIndexPath : [self getNextIndexPath:destinationIndexPath];
            [self moveRowAtIndexPath:sourceChildIndexPath toIndexPath:destinationChildIndexPath];
        }
        
        // Remember where we are now.
        sourceIndexPath = sourceHasChild && sourceIndexPath.row < indexPath.row ? [self getPreviousIndexPath:destinationIndexPath] : destinationIndexPath;
        
    }
}

// Drop the call back in the table.
- (void)dropCell {
    
    // Make the cell visible again and get ready to animate them to full alpha.
    UITableViewCell *childCell = nil;
    if (sourceHasChild) {
        childCell = [self cellForRowAtIndexPath:[self getNextIndexPath:sourceIndexPath]];
        childCell.hidden = NO;
        childCell.alpha = 0.0;
    }
    UITableViewCell *cell = [self cellForRowAtIndexPath:sourceIndexPath];
    cell.hidden = NO;
    cell.alpha = 0.0;
    
    // Animate to hide the snapshot and show back the cell.
    [UIView animateWithDuration:0.1f
                     animations:^{
                         snapshot.center = cell.center;
                         snapshot.transform = CGAffineTransformIdentity;
                         snapshot.alpha = 0.0;
                         cell.alpha = 1.0;
                         if (childCell) {
                             childCell.alpha = 1.0;
                         }
                     }
                     completion:^(BOOL finished) {
                         sourceIndexPath = nil;
                         [snapshot removeFromSuperview];
                         snapshot = nil;
                     }];
}

// Helper method to get the index path for the next row.
- (NSIndexPath *)getNextIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
}

// Helper method to get the index path for the previous row.
- (NSIndexPath *)getPreviousIndexPath:(NSIndexPath *)indexPath {
    return [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
}

// Helper method to get the snapshot of a dragging cell.
- (UIView *)snapshotOfGroupCell:(UITableViewCell *)cell groupIndex:(NSInteger)groupIndex {
    
    UITableViewCell *childCell = nil;
    CGFloat height = cell.frame.size.height;
    if ([[expandedGroups objectAtIndex:groupIndex] boolValue]) {
        childCell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:([self rowForGroupIndex:groupIndex] + 1) inSection:0]];
        height += childCell.frame.size.height;
    }
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(cell.frame.size.width, height), NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Draw the group cell
    [cell.layer renderInContext:context];
    
    // Draw the child table if needed
    if (childCell) {
        CGContextTranslateCTM(context, 0, cell.frame.size.height);
        [childCell.layer renderInContext:context];        
    }
    
    // Create the imade.
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create the snapshot.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.25;
    
    return snapshot;
}

@end
