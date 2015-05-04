//
//  ViewController.swift
//  APExpandableTableViewSampeProject
//
//  Created by Andrej Poljanec on 5/2/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit
import APExpandableTableView

class ViewController: UIViewController {

    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var expandableTableView: APExpandableTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func editAction(sender: AnyObject) {
        let isEditing = !self.editing
        self.setEditing(isEditing, animated: true)
        self.editButton.title = isEditing ? "Done" : "Edit"
    }

}

