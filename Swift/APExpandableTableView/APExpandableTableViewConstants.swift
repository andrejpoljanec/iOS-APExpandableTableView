//
//  APExpandableTableViewConstants.swift
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

struct APExpandableTableViewConstants {
    
    // Some default values
    static let DEFAULT_PADDING: CGFloat = 8.0
    static let DEFAULT_GROUP_CELL_HEIGHT: CGFloat = 44.0
    static let DEFAULT_CHILD_CELL_HEIGHT: CGFloat = 44.0
    
    // Width of the indicator image
    static let INDICATOR_WIDTH: CGFloat = 40.0
    
    // Group cells have to be indented to make room for the indicator. This constant adjusts the position to not be indented too much.
    // If it's indented for the full width of the indicator, then the extra padding within the cell makes it look ugly and disconnected.
    static let INSET_INNER_CELL: CGFloat = 16.0
    
    // It makes sense to indent the child table a little bit, to make it more apparent that the cells are child cells.
    static let INSET_CHILD_TABLE: CGFloat = 40.0
   
}
