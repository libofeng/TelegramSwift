//
//  TableAnimationInterface.swift
//  TGUIKit
//
//  Created by keepcoder on 02/10/2016.
//  Copyright © 2016 Telegram. All rights reserved.
//

import Cocoa

open class TableAnimationInterface: NSObject {
    
    weak var table:TableView?
    let scrollBelow:Bool
    public init(_ table:TableView, _ scrollBelow:Bool = true) {
        self.table = table
        self.scrollBelow = scrollBelow
    }

    public func animate(added:[TableRowItem], removed:[TableRowItem]) -> Void {
        
        var height:CGFloat = 0
        
        for item in added {
            height += item.height
        }
        
        if added.count == 0 {
            return
        }
        
        if let table = table {
            
           var contentView = table.contentView
            let bounds = contentView.bounds
            
            if scrollBelow {
                contentView.bounds = NSMakeRect(0, 0, contentView.bounds.width, contentView.bounds.height)
            }
            
            if bounds.minY > height && scrollBelow {
                height = bounds.minY
                
                var presentation = contentView.layer?.presentation()
                if let presentation = presentation, contentView.layer?.animation(forKey:"bounds") != nil {
                    height += presentation.bounds.minY
                }
                
                
                contentView.layer?.animateBounds(from: NSMakeRect(0, height, contentView.bounds.width, contentView.bounds.height), to: contentView.bounds, duration: 0.2, timingFunction: kCAMediaTimingFunctionEaseOut)
                
                
            } else if height - bounds.height < table.frame.height {
                
                var range:NSRange = table.visibleRows(height)
                
                for item in added {
                    if item.index < range.location || item.index > range.location + range.length {
                        return
                    }
                }
                
                CATransaction.begin()
                for idx in range.location ..< range.length {
                    
                    if let view = table.viewNecessary(at: idx), let layer = view.layer {
                        
                        var inset = layer.frame.minY - height;
                        if let presentLayer = layer.presentation(), presentLayer.animation(forKey: "position") != nil {
                            inset = presentLayer.position.y
                        }
                        layer.animatePosition(from: NSMakePoint(0, inset), to: NSMakePoint(0, layer.position.y), duration: 0.2, timingFunction: kCAMediaTimingFunctionEaseOut)
                    }
                    
                }
                
                CATransaction.commit()
                
            }
           
            
        }
    }

    
}