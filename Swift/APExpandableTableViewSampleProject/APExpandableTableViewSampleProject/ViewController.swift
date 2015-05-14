//
//  ViewController.swift
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

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
        cell.textLabel?.text = "\(data[groupIndex][childIndex + 1])"
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
    
    func expandableTableView(tableView: APExpandableTableView, canDeleteGroupAtIndex groupIndex: Int) -> Bool {
        return true
    }
    
    func expandableTableView(tableView: APExpandableTableView, deleteGroupAtIndex groupIndex: Int) {
        data.removeObjectAtIndex(groupIndex)
    }
    
    func expandableTableView(tableView: APExpandableTableView, canMoveGroupAtIndex groupIndex: Int) -> Bool {
        return true
    }
    
    func expandableTableView(tableView: APExpandableTableView, moveGroupAtIndex sourceGroupIndex: Int, toIndex destinationGroupIndex: Int) {
        let moveObject: AnyObject = data[sourceGroupIndex]
        data.removeObjectAtIndex(sourceGroupIndex)
        data.insertObject(moveObject, atIndex: destinationGroupIndex)
    }
    
    func expandableTableView(tableView: APExpandableTableView, canMoveChildAtIndex childIndex: Int, groupIndex: Int) -> Bool {
        return true
    }
    
    func expandableTableView(tableView: APExpandableTableView, moveChildAtIndex sourceChildIndex: Int, toIndex destinationChildIndex: Int, groupIndex: Int) {
        var groupArray = data[groupIndex] as [String]
        let moveObject: String = groupArray[sourceChildIndex + 1]
        groupArray.removeAtIndex(sourceChildIndex + 1)
        groupArray.insert(moveObject, atIndex: destinationChildIndex + 1)
        data[groupIndex] = groupArray
    }
    
    func expandableTableView(tableView: APExpandableTableView, canDeleteChildAtIndex childIndex: Int, groupIndex: Int) -> Bool {
        return true
    }
    
    func expandableTableView(tableView: APExpandableTableView, deleteChildAtIndex childIndex: Int, groupIndex: Int) {
        data[groupIndex].removeObjectAtIndex(childIndex + 1)
    }
    
}

