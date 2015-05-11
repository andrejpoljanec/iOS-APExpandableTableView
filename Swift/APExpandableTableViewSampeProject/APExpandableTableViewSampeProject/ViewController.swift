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
        
        expandableTableView.expandableTableViewDelegate = self
        
        expandableTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "SampleCell")
        
        data.addObject(["Group 1", "A", "B"])
        data.addObject(["Group 2", "C", "D"])
        data.addObject(["Group 3", "D", "F"])
    }
    
    @IBAction func editAction(sender: AnyObject) {
        let isEditing = !self.editing
        self.setEditing(isEditing, animated: true)
        self.editButton.title = isEditing ? "Done" : "Edit"
    }
    
    func expandableTableView(tableView: APExpandableTableView, cellForGroupAtIndex groupIndex: Int) -> UITableViewCell {
        let cell = expandableTableView.dequeueReusableCellWithIdentifier("SampleCell") as UITableViewCell
        cell.textLabel?.text = "\(data[groupIndex][0])"
        return cell
    }
    
    func numberOfGroupsInExpandableTableView(tableView: APExpandableTableView) -> Int {
        return data.count
    }

}

