//
//  ViewController.swift
//  APExpandableTableViewSampeProject
//
//  Created by Andrej Poljanec on 5/2/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit
import APExpandableTableView

class ViewController: UIViewController, APExpandableTableViewDelegate {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var expandableTableView: APExpandableTableView!
    
    var data = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        data.addObject(["Group 1", "A", "B"])
        data.addObject(["Group 2", "C", "D"])
        data.addObject(["Group 3", "D", "F"])

        expandableTableView.expandableTableViewDelegate = self
        
        expandableTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "GroupCell")
        expandableTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "ChildCell")
        
    }
    
    @IBAction func editAction(sender: AnyObject) {
        let editing = !expandableTableView.editing
        expandableTableView.setEditing(editing, animated: true)
        editButton.title = editing ? "Done" : "Edit"
    }
    
    func expandableTableView(tableView: APExpandableTableView, cellForChildAtIndex childIndex: Int, groupIndex: Int) -> UITableViewCell {
        let cell = expandableTableView.dequeueReusableCellWithIdentifier("ChildCell") as UITableViewCell
        cell.textLabel?.text = "\(data[groupIndex][groupIndex + 1])"
        return cell
    }
    
    func expandableTableView(tableView: APExpandableTableView, numberOfChildrenForGroupAtIndex groupIndex: Int) -> Int {
        return data.objectAtIndex(groupIndex).count - 1
    }
    
    func expandableTableView(tableView: APExpandableTableView, cellForGroupAtIndex groupIndex: Int) -> UITableViewCell {
        let cell = expandableTableView.dequeueReusableCellWithIdentifier("GroupCell") as UITableViewCell
        cell.textLabel?.text = "\(data[groupIndex][0])"
        return cell
    }
    
    func numberOfGroupsInExpandableTableView(tableView: APExpandableTableView) -> Int {
        return data.count
    }
    

}

