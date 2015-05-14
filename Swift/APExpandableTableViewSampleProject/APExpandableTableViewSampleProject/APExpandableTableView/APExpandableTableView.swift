//
//  APExpandableTableView.swift
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

class APExpandableTableView: UITableView, UITableViewDataSource, UITableViewDelegate, APExpandableTableViewChildTableViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: instance constants
    
    private let CHILD_CELL = "APExpandableTableViewChildCell"
    private let GROUP_CELL = "APExpandableTableViewGroupCell"
    
    // MARK: instance variables
    
    var expandableTableViewDelegate : APExpandableTableViewDelegate? {
        didSet {
            // As soon as we have the delegate, we can initialize the expansion states.
            initExpansionStates()
            // Adding a table footer view triggers UITableViewDataSource methods which need delegates, so adding it here.
            tableFooterView = UIView(frame: CGRectZero)
        }
    }
    private var expandedGroups = [AnyObject]()
    
    // MARK: initializers
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize();
    }
    
    override init(frame aFrame: CGRect) {
        super.init(frame: aFrame)
        initialize()
    }
    
    private func initialize() {
        delegate = self
        dataSource = self
        
        registerClass(APExpandableTableViewGroupCell.self, forCellReuseIdentifier: GROUP_CELL)
        registerClass(APExpandableTableViewChildTableView.self, forCellReuseIdentifier: CHILD_CELL)
        
        separatorStyle = UITableViewCellSeparatorStyle.SingleLine
        delaysContentTouches = false
    }
    
    private func initExpansionStates() {
        let groupCount = expandableTableViewDelegate!.numberOfGroupsInExpandableTableView(self)
        expandedGroups.removeAll()
        for _ in 0..<groupCount {
            expandedGroups.append(NSNumber(bool: false))
        }
    }
    
    // MARK: expandable table methods
    
    func toggleGroupAtIndexPath(indexPath: NSIndexPath) {
        beginUpdates()
        let groupIndex = groupIndexForRow(indexPath.row)
        let expanded = (expandedGroups[groupIndex] as NSNumber).boolValue
        expandedGroups[groupIndex] = NSNumber(bool: !expanded)
        let nextIndexPath = NSIndexPath(forRow: indexPath.row + 1, inSection: 0)
        if (expanded) {
            deleteRowsAtIndexPaths([nextIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            insertRowsAtIndexPaths([nextIndexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
        endUpdates()
        
        let groupCell = cellForRowAtIndexPath(indexPath) as APExpandableTableViewGroupCell
        groupCell.updateIndicatorToExpanded(!expanded, animate: true)
    }
    
    func collapseAllGroups() {
        for (index, expanded) in enumerate(expandedGroups) {
            if (expanded as NSNumber).boolValue {
                toggleGroupAtIndexPath(NSIndexPath(forRow: index, inSection: 0))
            }
        }
    }
    
    override func reloadData() {
        let groupCount = expandableTableViewDelegate?.numberOfGroupsInExpandableTableView(self)
        var currentIndex = expandedGroups.count - 1
        while (groupCount > expandedGroups.count) {
            currentIndex++
            expandedGroups.append(NSNumber(bool: false))
        }
        while (groupCount < expandedGroups.count) {
            expandedGroups.removeLast()
        }
        super.reloadData()
    }
    
    func reloadChildAtIndex(groupIndex: Int, animate: Bool) {
        if (!(expandedGroups[groupIndex] as NSNumber).boolValue) {
            return
        }
        let row = rowForGroupIndex(groupIndex) + 1
        let cell = cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as APExpandableTableViewChildTableView
        cell.reloadDataWithAnimation(animate)
        reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
    }
    
    // MARK: helper methods
    
    private func rowForGroupIndex(groupIndex: Int) -> Int {
        var row = 0
        var index = 0
        
        while (index < groupIndex) {
            if (expandedGroups[index] as NSNumber).boolValue {
                row++
            }
            index++
            row++
        }
        return row
    }
    
    private func groupIndexForRow(row: Int) -> Int {
        var groupIndex = -1
        var index = 0
        
        while (index <= row) {
            groupIndex++
            index++
            if (expandedGroups[groupIndex] as NSNumber).boolValue {
                index++
            }
        }
        return groupIndex
    }
    
    private func isChildCellAtRow(row: Int) -> Bool {
        return row > 0 && groupIndexForRow(row) == groupIndexForRow(row - 1)
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let groupCount = expandableTableViewDelegate!.numberOfGroupsInExpandableTableView(self)
        let countedSet = NSCountedSet()
        countedSet.addObjectsFromArray(expandedGroups)
        let expandedGroupCount = countedSet.countForObject(NSNumber(bool: true))
        
        return groupCount + expandedGroupCount
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let groupIndex = groupIndexForRow(indexPath.row)
        
        if (isChildCellAtRow(indexPath.row)) {
            
            let cell = dequeueReusableCellWithIdentifier(CHILD_CELL) as? APExpandableTableViewChildTableView ?? APExpandableTableViewChildTableView(style: UITableViewCellStyle.Default, reuseIdentifier: CHILD_CELL)
            
            cell.groupIndex = groupIndex
            cell.delegate = self
            cell.reloadDataWithAnimation(false)
            
            return cell
            
        } else {
            
            let cell = dequeueReusableCellWithIdentifier(GROUP_CELL) as? APExpandableTableViewGroupCell ?? APExpandableTableViewGroupCell(style: UITableViewCellStyle.Default, reuseIdentifier: GROUP_CELL)
            
            let innerCell = expandableTableViewDelegate!.expandableTableView(self, cellForGroupAtIndex: indexPath.row)
            cell.groupIndex = groupIndex
            cell.attachInnerCell(innerCell)
            
            let expanded = (expandedGroups[groupIndex] as NSNumber).boolValue
            cell.updateIndicatorToExpanded(expanded, animate: false)
            
            cell.backgroundColor = innerCell.backgroundColor
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.indicatorOnLeft = expandableTableViewDelegate?.indicatorOnLeftForExpandableTableView?(self) ?? true
            cell.indicator.image = expandableTableViewDelegate?.expandIndicatorForExpandableTableView?(self) ?? cell.indicator.image
            cell.accessoryView = expandableTableViewDelegate?.expandableTableView?(self, groupAccessoryViewForGroupIndex: groupIndex)
            
            cell.tag = groupIndex
            
            return cell
            
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let groupIndex = groupIndexForRow(indexPath.row)
        if expandableTableViewDelegate?.expandableTableView?(self, canDeleteGroupAtIndex: groupIndex) ?? false {
            return true
        }
        let childCount = expandableTableViewDelegate?.expandableTableView(self, numberOfChildrenForGroupAtIndex: groupIndex) ?? 0
        for index in 0 ..< childCount {
            if (expandableTableViewDelegate?.expandableTableView?(self, canMoveChildAtIndex: index, groupIndex: groupIndex) ?? false)
                || (expandableTableViewDelegate?.expandableTableView?(self, canDeleteChildAtIndex: index, groupIndex: groupIndex) ?? false)
            {
                return true
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if expandableTableViewDelegate?.expandableTableView?(self, canDeleteGroupAtIndex: groupIndexForRow(indexPath.row)) ?? false {
            return UITableViewCellEditingStyle.Delete
        } else {
            return UITableViewCellEditingStyle.None
        }
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if expandableTableViewDelegate?.expandableTableView?(self, canDeleteGroupAtIndex: groupIndexForRow(indexPath.row)) ?? false {
            return true
        } else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let canmove = (expandableTableViewDelegate?.expandableTableView?(self, canMoveGroupAtIndex: groupIndexForRow(indexPath.row)) ?? false)
        return (expandableTableViewDelegate?.expandableTableView?(self, canMoveGroupAtIndex: groupIndexForRow(indexPath.row)) ?? false)
            && !isChildCellAtRow(indexPath.row)
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        return !isChildCellAtRow(proposedDestinationIndexPath.row) ? proposedDestinationIndexPath : sourceIndexPath
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let sourceCell = cellForRowAtIndexPath(sourceIndexPath) as APExpandableTableViewGroupCell
        let destinationCell = cellForRowAtIndexPath(destinationIndexPath) as APExpandableTableViewGroupCell
        let sourceGroupIndex = sourceCell.groupIndex!
        let destinationGroupIndex = destinationCell.groupIndex!
        sourceCell.groupIndex = destinationGroupIndex
        destinationCell.groupIndex = sourceGroupIndex
        let sourceExpanded = (expandedGroups[sourceGroupIndex] as NSNumber).boolValue
        let destinationExpanded = (expandedGroups[destinationGroupIndex] as NSNumber).boolValue
        expandedGroups[sourceGroupIndex] = NSNumber(bool: destinationExpanded)
        expandedGroups[destinationGroupIndex] = NSNumber(bool: sourceExpanded)
        expandableTableViewDelegate?.expandableTableView?(self, moveGroupAtIndex: sourceGroupIndex, toIndex: destinationGroupIndex)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let groupIndex = groupIndexForRow(indexPath.row)
            expandableTableViewDelegate?.expandableTableView?(self, deleteGroupAtIndex: groupIndex)
            reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
            expandedGroups.removeAtIndex(groupIndex)
        }
    }

    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let groupIndex = groupIndexForRow(indexPath.row)
        let childCell = isChildCellAtRow(indexPath.row)
        if (childCell) {
            let childCount = expandableTableViewDelegate?.expandableTableView(self, numberOfChildrenForGroupAtIndex: groupIndex) ?? 0
            var tableHeight: CGFloat = 0
            for index in 0 ..< childCount {
                tableHeight += expandableTableViewDelegate?.expandableTableView?(self, heightForChildAtIndex: index, groupIndex: groupIndex) ?? APExpandableTableViewConstants.DEFAULT_CHILD_CELL_HEIGHT
            }
            return tableHeight
        } else {
            return expandableTableViewDelegate?.expandableTableView?(self, heightForGroupAtIndex: groupIndex) ?? APExpandableTableViewConstants.DEFAULT_GROUP_CELL_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let groupIndex = groupIndexForRow(indexPath.row)
        let cell = cellForRowAtIndexPath(indexPath)
        if (cell is APExpandableTableViewGroupCell) {
            toggleGroupAtIndexPath(indexPath)
        }
    }
    
    // MARK: UITableViewChildTableViewDelegate
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, numberOfChildrenForGroupIndex groupIndex: Int) -> Int {
        return expandableTableViewDelegate!.expandableTableView(self, numberOfChildrenForGroupAtIndex: groupIndex)
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, cellForChildAtIndex childIndex: Int, groupIndex: Int) -> UITableViewCell {
        return expandableTableViewDelegate!.expandableTableView(self, cellForChildAtIndex: childIndex, groupIndex: groupIndex)
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, canDeleteChildAtIndex childIndex: Int, groupIndex: Int) -> Bool {
        return expandableTableViewDelegate?.expandableTableView?(self, canDeleteChildAtIndex: childIndex, groupIndex: groupIndex) ?? false
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, deleteChildAtIndex childIndex: Int, groupIndex: Int) {
        expandableTableViewDelegate!.expandableTableView!(self, deleteChildAtIndex: childIndex, groupIndex: groupIndex)
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, didSelectChildAtIndex childIndex: Int, groupIndex: Int) {
        expandableTableViewDelegate?.expandableTableView?(self, didSelectChildAtIndex: childIndex, groupIndex: groupIndex)
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, canMoveChildAtIndex childIndex: Int, groupIndex: Int) -> Bool {
        return expandableTableViewDelegate?.expandableTableView?(self, canMoveChildAtIndex: childIndex, groupIndex: groupIndex) ?? false
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, moveChildAtIndex sourceChildIndex: Int, toIndex destinationChildIndex: Int, groupIndex: Int) {
        expandableTableViewDelegate!.expandableTableView!(self, moveChildAtIndex: sourceChildIndex, toIndex: destinationChildIndex, groupIndex: groupIndex)
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, heightForChildAtIndex childIndex: Int, groupIndex: Int) -> CGFloat {
        return expandableTableViewDelegate?.expandableTableView?(self, heightForChildAtIndex: childIndex, groupIndex: groupIndex) ?? APExpandableTableViewConstants.DEFAULT_CHILD_CELL_HEIGHT
    }
    
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, childAccessoryViewForChildAtIndex childIndex: Int, groupIndex: Int) -> UIView? {
        return expandableTableViewDelegate?.expandableTableView?(self, childAccessoryViewForChildIndex: childIndex, groupIndex: groupIndex)
    }
    
    // MARK: Reordering
    
    struct Reordering {
        static var snapshot: UIView?
        static var sourceIndexPath: NSIndexPath?
        static var gripY: CGFloat?
        static var sourceHasChild: Bool?
        static var reorderX: CGFloat?
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if (editing) {
            for index in 0 ..< expandableTableViewDelegate!.numberOfGroupsInExpandableTableView(self) {
                if let reorderView = findReorderControlForView(self, groupIndex: index) {
                    reorderView.userInteractionEnabled = false
                    Reordering.reorderX = reorderView.frame.origin.x
                    let fakeView = UIView(frame: reorderView.frame)
                    let gestureRecognizer = UIPanGestureRecognizer(target: self, action: "reorderControlPanned:")
                    gestureRecognizer.delegate = self
                    fakeView.addGestureRecognizer(gestureRecognizer)
                    reorderView.superview?.addSubview(fakeView)
                }
            }
        }
    }
    
    private func findReorderControlForView(view: UIView, groupIndex: Int) -> UIView? {
        if ((view.classForCoder.description().rangeOfString("Reorder")) != nil) {
            return view
        }
        if (view.classForCoder.description().rangeOfString("APExpandableTableViewGroupCell") != nil && view.tag != groupIndex) {
            return nil
        }
        if ((view.classForCoder.description().rangeOfString("APExpandableTableViewChildTableView")) != nil) {
            return nil
        }
        for subview in view.subviews {
            if let foundView = findReorderControlForView(subview as UIView, groupIndex: groupIndex) {
                return foundView
            }
        }
        return nil
    }
    
    func reorderControlPanned(gestureRecognizer: UIGestureRecognizer) {
        let location = gestureRecognizer.locationInView(self)
        let indexPath = indexPathForRowAtPoint(location)
        if (indexPath != nil && Reordering.sourceIndexPath != nil) {
            switch gestureRecognizer.state {
            case UIGestureRecognizerState.Changed:
                dragCellToIndexPath(indexPath!, location: location)
            case UIGestureRecognizerState.Ended:
                dropCell()
            default:
                break
            }
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        let location = touches.anyObject()!.locationInView!(self)
        if (!editing || location.x < Reordering.reorderX) {
            super.touchesBegan(touches, withEvent: event)
            return
        }
        if let indexPath = indexPathForRowAtPoint(location) {
            gripCellAtIndexPath(indexPath, location: location)
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        if (Reordering.sourceIndexPath == nil) {
            super.touchesEnded(touches, withEvent: event)
            return
        }
        dropCell()
    }
    
    private func gripCellAtIndexPath(indexPath: NSIndexPath, location: CGPoint) {
        let cell = cellForRowAtIndexPath(indexPath)!
        Reordering.sourceIndexPath = indexPath
        Reordering.snapshot = snapshotOfGroupCell(cell, groupIndex: groupIndexForRow(indexPath.row))
        let origin = cell.frame.origin
        let frame = Reordering.snapshot!.frame as CGRect
        Reordering.snapshot!.frame = CGRectMake(origin.x, origin.y, frame.size.width, frame.size.height)
        Reordering.snapshot!.alpha = 0.0
        addSubview(Reordering.snapshot!)
        Reordering.gripY = location.y - origin.y
        var childCell: UITableViewCell?
        if (expandedGroups[groupIndexForRow(indexPath.row)] as NSNumber).boolValue {
            childCell = cellForRowAtIndexPath(getNextIndexPath(indexPath))
            Reordering.sourceHasChild = true
        } else {
            Reordering.sourceHasChild = false
        }
        UIView.animateWithDuration(0.1, animations: {
            Reordering.snapshot!.alpha = 1.0
            cell.alpha = 0.0
            if (childCell != nil) {
                childCell!.alpha = 0.0
            }
            }, completion: {
                (value: Bool) in
                cell.hidden = true
                if (childCell != nil) {
                    childCell!.hidden = true
                }
        })
    }
    
    private func dragCellToIndexPath(indexPath: NSIndexPath, location: CGPoint) {
        let frame = Reordering.snapshot!.frame
        Reordering.snapshot!.frame = CGRectMake(frame.origin.x, location.y - Reordering.gripY!, frame.size.width, frame.size.height)
        if (indexPath != Reordering.sourceIndexPath! && !isChildCellAtRow(indexPath.row)) {
            var destinationIndexPath = indexPath
            let destinationHasChild = (expandedGroups[groupIndexForRow(indexPath.row)] as NSNumber).boolValue
            if (destinationHasChild && Reordering.sourceIndexPath!.row < indexPath.row) {
                destinationIndexPath = getNextIndexPath(destinationIndexPath)
            }
            let sourceGroupIndex = groupIndexForRow(Reordering.sourceIndexPath!.row)
            let destinationGroupIndex = groupIndexForRow(destinationIndexPath.row)
            let sourceExpanded = (expandedGroups[sourceGroupIndex] as NSNumber).boolValue
            let destinationExpanded = (expandedGroups[destinationGroupIndex] as NSNumber).boolValue
            expandedGroups[sourceGroupIndex] = NSNumber(bool: destinationExpanded)
            expandedGroups[destinationGroupIndex] = NSNumber(bool: sourceExpanded)
            moveRowAtIndexPath(Reordering.sourceIndexPath!, toIndexPath: destinationIndexPath)
            expandableTableViewDelegate?.expandableTableView!(self, moveGroupAtIndex: sourceGroupIndex, toIndex: destinationGroupIndex)
            if (Reordering.sourceHasChild!) {
                let sourceChildIndexPath = Reordering.sourceIndexPath!.row < indexPath.row ? Reordering.sourceIndexPath! : getNextIndexPath(Reordering.sourceIndexPath!)
                let destinationChildIndexPath = Reordering.sourceIndexPath!.row < indexPath.row ? destinationIndexPath : getNextIndexPath(destinationIndexPath)
                moveRowAtIndexPath(sourceChildIndexPath, toIndexPath: destinationChildIndexPath)
            }
            Reordering.sourceIndexPath = Reordering.sourceHasChild! && Reordering.sourceIndexPath!.row < indexPath.row ? getPreviousIndexPath(destinationIndexPath) : destinationIndexPath
        }
    }
    
    private func dropCell() {
        var childCell: UITableViewCell?
        if (Reordering.sourceHasChild!) {
            childCell = cellForRowAtIndexPath(getNextIndexPath(Reordering.sourceIndexPath!))
            childCell!.hidden = false
            childCell!.alpha = 0.0
        }
        let cell = cellForRowAtIndexPath(Reordering.sourceIndexPath!)!
        cell.hidden = false
        cell.alpha = 0.0
        UIView.animateWithDuration(0.1, animations: {
            Reordering.snapshot!.transform = CGAffineTransformIdentity
            Reordering.snapshot!.alpha = 0.0
            cell.alpha = 1.0
            if (childCell != nil) {
                childCell!.alpha = 1.0
            }
            }, completion: {
                (value: Bool) in
                Reordering.sourceIndexPath = nil
                Reordering.snapshot!.removeFromSuperview()
                Reordering.snapshot = nil
        })
    }
    
    private func getNextIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)
    }
    
    private func getPreviousIndexPath(indexPath: NSIndexPath) -> NSIndexPath {
        return NSIndexPath(forRow: indexPath.row - 1, inSection: indexPath.section)
    }
    
    private func snapshotOfGroupCell(cell: UITableViewCell, groupIndex: Int) -> UIView {
        var childCell: UITableViewCell?
        var height = cell.frame.size.height
        if (expandedGroups[groupIndex] as NSNumber).boolValue {
            childCell = cellForRowAtIndexPath(NSIndexPath(forRow: rowForGroupIndex(groupIndex) + 1, inSection: 0))
            height += childCell!.frame.size.height
        }
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(cell.frame.size.width, height), false, 0)
        let context = UIGraphicsGetCurrentContext()
        cell.layer.renderInContext(context)
        if (childCell != nil) {
            CGContextTranslateCTM(context, 0, cell.frame.size.height)
            childCell!.layer.renderInContext(context)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let snapshot = UIImageView(image: image)
        snapshot.layer.masksToBounds = false
        snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        snapshot.layer.shadowRadius = 5.0
        snapshot.layer.shadowOpacity = 0.25
        
        return snapshot
    }
    
}
