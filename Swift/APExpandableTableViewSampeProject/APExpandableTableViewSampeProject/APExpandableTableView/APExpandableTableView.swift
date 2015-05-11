//
//  APExpandableTableView.swift
//  APExpandableTableViewSampeProject
//
//  Created by Andrej Poljanec on 5/3/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

protocol APExpandableTableViewDelegate {
    func expandableTableView(tableView: APExpandableTableView, cellForGroupAtIndex groupIndex: Int) -> UITableViewCell
    func numberOfGroupsInExpandableTableView(tableView: APExpandableTableView) -> Int
}

class APExpandableTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var expandableTableViewDelegate : APExpandableTableViewDelegate?

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.delegate = self
        self.dataSource = self
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return expandableTableViewDelegate!.expandableTableView(self, cellForGroupAtIndex: indexPath.row)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandableTableViewDelegate!.numberOfGroupsInExpandableTableView(self)
    }

}
