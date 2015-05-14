//
//  APExpandableTableViewGroupCell.swift
//
//  Created by Andrej Poljanec on 5/12/15.
//  Copyright (c) 2015 Andrej Poljanec. All rights reserved.
//

import UIKit

class APExpandableTableViewGroupCell: UITableViewCell {
    
    var indicator = UIImageView()
    var indicatorOnLeft = true
    var expandable = true
    var cell: UITableViewCell?
    var groupIndex: Int?
   
    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        autoresizingMask = UIViewAutoresizing.FlexibleWidth
        contentView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        
        selectionStyle = UITableViewCellSelectionStyle.None
        
        indicator = UIImageView(image: defaultIndicatorImage())
        indicator.contentMode = UIViewContentMode.Center
        contentView.addSubview(indicator)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.autoresizesSubviews = true
        
        if (!expandable) {
            
            // If not expandable, there is no need for an indicator and the inner cell can take up the whole space
            cell?.frame = CGRectMake(0, 0, contentView.bounds.size.width, contentView.bounds.size.height)
            indicator.hidden = true
            
        } else if (indicatorOnLeft) {
            
            // Layout if indicator is on the left
            indicator.frame = CGRectMake(0, 0, APExpandableTableViewConstants.INDICATOR_WIDTH, contentView.bounds.size.height)
            cell?.frame = CGRectMake(APExpandableTableViewConstants.INDICATOR_WIDTH - APExpandableTableViewConstants.INSET_INNER_CELL, 0, contentView.bounds.size.width - APExpandableTableViewConstants.INDICATOR_WIDTH + APExpandableTableViewConstants.INSET_INNER_CELL, contentView.bounds.size.height)
            indicator.hidden = false
            
        } else {
            
            // Layout if indicator is on the right
            indicator.frame = CGRectMake(contentView.bounds.size.width - APExpandableTableViewConstants.INDICATOR_WIDTH - APExpandableTableViewConstants.DEFAULT_PADDING, 0, APExpandableTableViewConstants.INDICATOR_WIDTH, contentView.bounds.size.height)
            cell?.frame = CGRectMake(0, 0, contentView.bounds.size.width - APExpandableTableViewConstants.INDICATOR_WIDTH, contentView.bounds.size.height)
            indicator.hidden = false
            
        }
    }
    
    // Attaches the inner cell obtained from the delegate
    func attachInnerCell(innerCell: UITableViewCell) {
        cell?.removeFromSuperview()
        cell = innerCell
        cell!.userInteractionEnabled = false
        contentView.addSubview(cell!)
    }
    
    // Update the indicator to show whether the group is expanded or collapsed
    func updateIndicatorToExpanded(expanded: Bool, animate: Bool) {
        
        if (animate) {
            UIView.beginAnimations("animateIndicator", context: nil)
            UIView.setAnimationDuration(0.2)
        }
        
        // Rotate the indicator by 180 degrees
        indicator.transform = CGAffineTransformMakeRotation(expanded ? CGFloat(M_PI) : 0)
        
        if (animate) {
            UIView.commitAnimations()
        }
        
    }
    
    // struct to hold type vars
    struct DefaultImage {
        static var indicatorImage = UIImage()
        static var onceToken: dispatch_once_t = 0
    }
    
    // Draw a default image if none is provided, just a black arrow
    private func defaultIndicatorImage() -> UIImage {
        dispatch_once(&DefaultImage.onceToken) {
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), false, 0)
            let ctx = UIGraphicsGetCurrentContext()
            CGContextSaveGState(ctx)
            CGContextSetStrokeColorWithColor(ctx, UIColor.blackColor().CGColor)
            CGContextSetLineWidth(ctx, 1)
            CGContextMoveToPoint(ctx, 2, 6)
            CGContextAddLineToPoint(ctx, 10, 14)
            CGContextAddLineToPoint(ctx, 18, 6)
            CGContextStrokePath(ctx)
            CGContextRestoreGState(ctx)
            DefaultImage.indicatorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        return DefaultImage.indicatorImage
    }
    
}
