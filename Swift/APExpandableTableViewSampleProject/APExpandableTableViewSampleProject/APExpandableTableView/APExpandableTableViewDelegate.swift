//
//  APExpandableTableViewDelegate.swift
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/13/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

@objc protocol APExpandableTableViewDelegate {
    
    // Similar to UITableViewDataSource, separately for group and child cells
    func numberOfGroupsInExpandableTableView(tableView: APExpandableTableView) -> Int
    func expandableTableView(tableView: APExpandableTableView, cellForGroupAtIndex groupIndex: Int) -> UITableViewCell
    func expandableTableView(tableView: APExpandableTableView, numberOfChildrenForGroupAtIndex groupIndex:Int) -> Int
    func expandableTableView(tableView: APExpandableTableView, cellForChildAtIndex childIndex: Int, groupIndex: Int) -> UITableViewCell
    
    // All groups by default are expandable. To make it non expandable, implement this method.
    optional func expandableTableView(tableView: APExpandableTableView, isGroupExpandableAtIndex groupIndex: Int) -> Bool
    
    // Reacting to cell clicks. Group can only react if it's non expandable.
    optional func expandableTableView(tableView: APExpandableTableView, didSelectChildAtIndex childIndex: Int, groupIndex: Int)
    optional func expandableTableView(tableView: APExpandableTableView, didSelectGroupAtIndex groupIndex: Int)
    
    // Moving cells.
    optional func expandableTableView(tableView: APExpandableTableView, canMoveGroupAtIndex groupIndex: Int) -> Bool
    optional func expandableTableView(tableView: APExpandableTableView, moveGroupAtIndex sourceGroupIndex: Int, toIndex destinationGroupIndex: Int)
    optional func expandableTableView(tableView: APExpandableTableView, canMoveChildAtIndex childIndex: Int, groupIndex: Int) -> Bool
    optional func expandableTableView(tableView: APExpandableTableView, moveChildAtIndex sourceChildIndex: Int, toIndex destinationChildIndex: Int, groupIndex: Int)
    
    // Deleting cells.
    optional func expandableTableView(tableView: APExpandableTableView, canDeleteGroupAtIndex groupIndex: Int) -> Bool
    optional func expandableTableView(tableView: APExpandableTableView, deleteGroupAtIndex groupIndex: Int)
    optional func expandableTableView(tableView: APExpandableTableView, canDeleteChildAtIndex childIndex: Int, groupIndex: Int) -> Bool
    optional func expandableTableView(tableView: APExpandableTableView, deleteChildAtIndex childIndex: Int, groupIndex: Int)
    
    // Visual stuff.
    // Cell heights.
    optional func expandableTableView(tableView: APExpandableTableView, heightForChildAtIndex childIndex: Int, groupIndex: Int) -> CGFloat
    optional func expandableTableView(tableView: APExpandableTableView, heightForGroupAtIndex groupIndex: Int) -> CGFloat
    // Indicator.
    optional func indicatorOnLeftForExpandableTableView(tableView: APExpandableTableView) -> Bool
    optional func expandIndicatorForExpandableTableView(tableView: APExpandableTableView) -> UIImage
    // Accessorry view.
    optional func expandableTableView(tableView: APExpandableTableView, groupAccessoryViewForGroupIndex groupIndex: Int) -> UIView?
    optional func expandableTableView(tableView: APExpandableTableView, childAccessoryViewForChildIndex childIndex: Int, groupIndex: Int) -> UIView?
    
}