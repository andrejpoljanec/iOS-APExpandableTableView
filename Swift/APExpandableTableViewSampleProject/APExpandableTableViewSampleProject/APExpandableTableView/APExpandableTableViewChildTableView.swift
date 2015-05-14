//
//  APExpandableTableViewChildTableView.swift
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

@objc protocol APExpandableTableViewChildTableViewDelegate {
    
    // UITableViewDataSource
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, numberOfChildrenForGroupIndex groupIndex: Int) -> Int
    func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, cellForChildAtIndex childIndex: Int, groupIndex: Int) -> UITableViewCell
    
    // Callbacks
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, didSelectChildAtIndex childIndex: Int, groupIndex: Int)
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, canMoveChildAtIndex childIndex: Int, groupIndex: Int) -> Bool
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, moveChildAtIndex sourceChildIndex: Int, toIndex destinationChildIndex: Int, groupIndex: Int)
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, canDeleteChildAtIndex childIndex: Int, groupIndex: Int) -> Bool
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, deleteChildAtIndex childIndex: Int, groupIndex: Int)
    
    // Visual
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, heightForChildAtIndex childIndex: Int, groupIndex: Int) -> CGFloat
    optional func expandableTableViewChildTableView(tableView: APExpandableTableViewChildTableView, childAccessoryViewForChildAtIndex childIndex: Int, groupIndex: Int) -> UIView
}

class APExpandableTableViewChildTableView: UITableViewCell, UITableViewDataSource, UITableViewDelegate {
   
    var groupIndex: Int?
    var delegate: APExpandableTableViewChildTableViewDelegate? {
        didSet {
            layoutSubviews()
        }
    }
    var tableView: UITableView = UITableView()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        backgroundColor = UIColor.clearColor()
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        tableView.scrollEnabled = false
        contentView.addSubview(tableView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var tableHeight: CGFloat = 0
        let childCount = delegate?.expandableTableViewChildTableView(self, numberOfChildrenForGroupIndex: groupIndex!) ?? 0
        for index in 0 ..< childCount {
            tableHeight += self.delegate?.expandableTableViewChildTableView?(self, heightForChildAtIndex: index, groupIndex: self.groupIndex!) ?? APExpandableTableViewConstants.DEFAULT_CHILD_CELL_HEIGHT
        }
        tableView.frame = CGRectMake(APExpandableTableViewConstants.INSET_CHILD_TABLE, 0, contentView.frame.size.width - APExpandableTableViewConstants.INSET_CHILD_TABLE, tableHeight)
    }
    
    func reloadDataWithAnimation(animate: Bool) {
        if (animate) {
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Fade)
        } else {
            tableView.reloadData()
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate!.expandableTableViewChildTableView(self, numberOfChildrenForGroupIndex: groupIndex!)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = delegate!.expandableTableViewChildTableView(self, cellForChildAtIndex: indexPath.row, groupIndex: groupIndex!)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = cell.backgroundColor
        cell.backgroundColor = UIColor.clearColor()
        cell.accessoryView = delegate?.expandableTableViewChildTableView?(self, childAccessoryViewForChildAtIndex: indexPath.row, groupIndex: groupIndex!)
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return delegate?.expandableTableViewChildTableView?(self, heightForChildAtIndex: indexPath.row, groupIndex: groupIndex!) ?? APExpandableTableViewConstants.DEFAULT_CHILD_CELL_HEIGHT
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        tableView.setEditing(editing, animated: animated)
    }
    
}
