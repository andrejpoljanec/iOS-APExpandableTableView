//
//  APExpandableTableView.swift
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

class APExpandableTableView: UITableView, UITableViewDataSource, UITableViewDelegate, APExpandableTableViewChildTableViewDelegate {
    
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
            if (expandedGroups[groupIndex] as NSNumber).boolValue {
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
            
            cell.tag = groupIndex
            
            return cell
            
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
    
}
