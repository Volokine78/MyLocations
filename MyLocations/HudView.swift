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
        
        hudView.backgroundColor = UIColor(
            red: 1,
            green: 0,
            blue: 0,
            alpha: 0.5)
        return hudView
    }
}
