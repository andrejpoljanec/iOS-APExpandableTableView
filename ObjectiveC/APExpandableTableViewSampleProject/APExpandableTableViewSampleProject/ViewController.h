//
//  ViewController.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "APExpandableTableView.h"

@interface ViewController : UIViewController <APExpandableTableViewDelegate>

@property (weak, nonatomic) IBOutlet APExpandableTableView *expandableTableView;

@end

