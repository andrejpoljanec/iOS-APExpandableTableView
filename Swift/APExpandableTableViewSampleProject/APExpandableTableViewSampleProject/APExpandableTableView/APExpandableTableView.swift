//
//  APExpandableTableView.swift
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

protocol APExpandableTableViewDelegate {
    
    // Similar to UITableViewDataSource, separately for group and child cells
    func numberOfGroupsInExpandableTableView(tableView: APExpandableTableView) -> Int
    func expandableTableView(tableView: APExpandableTableView, cellForGroupAtIndex groupIndex: Int) -> UITableViewCell
    func expandableTableView(tableView: APExpandableTableView, numberOfChildrenForGroupAtIndex groupIndex:Int) -> Int
    func expandableTableView(tableView: APExpandableTableView, cellForChildAtIndex childIndex: Int, groupIndex: Int) -> UITableViewCell
    
}

class APExpandableTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: instance constants
    
    private let CHILD_CELL = "ChildCell"
    private let GROUP_CELL = "GroupCell"
    
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
        
        registerClass(UITableViewCell.self, forCellReuseIdentifier: GROUP_CELL)
        registerClass(UITableViewCell.self, forCellReuseIdentifier: CHILD_CELL)
        
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
            let cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: CHILD_CELL)
            return cell
        } else {
            let innerCell = expandableTableViewDelegate!.expandableTableView(self, cellForGroupAtIndex: indexPath.row)
            return innerCell
        }
    }
    
}
