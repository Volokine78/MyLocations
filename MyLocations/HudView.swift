//
//  HudView.swift
//  MyLocations
//
//  Created by Tolga PIRTURK on 29.04.2021.
//

import Foundation
import UIKit

class hudView: UIView {
    var text = ""
    
    class func hud(inView view: UIView, animated: Bool) -> hudView {
        let hudView = hudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(
            x: round((bounds.size.width - boxWidth) / 2),
            y: round((bounds.size.height - boxHeight) / 2),
            width: boxWidth,
            height: boxHeight)
        
        let roundedRect = UIBezierPath(
            roundedRect: boxRect,
            cornerRadius: 10)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
    }
}
