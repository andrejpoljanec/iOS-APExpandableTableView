//
//  APExpandableTableViewConstants.h
//  APExpandableTableViewSampleProject
//
//  Created by Andrej Poljanec on 5/1/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

#import <Foundation/Foundation.h>

// Some default values
#define DEFAULT_PADDING 8
#define DEFAULT_GROUP_CELL_HEIGHT 50
#define DEFAULT_CHILD_CELL_HEIGHT 50

// Width of the indicator image
#define INDICATOR_WIDTH 40

// Group cells have to be indented to make room for the indicator. This constant adjusts the position to not be indented too much.
// If it's indented for the full width of the indicator, then the extra padding within the cell makes it look ugly and disconnected.
#define INSET_INNER_CELL 16

// It makes sense to indent the child table a little bit, to make it more apparent that the cells are child cells.
#define INSET_CHILD_TABLE 40
