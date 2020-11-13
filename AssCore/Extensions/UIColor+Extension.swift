//
//  UIColor+Extension.swift
//  ass-app
//
//  Created by Vendula Švastalová on 22/05/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

extension UIColor {
    public convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0xFF00) >> 8) / 255.0,
            blue: CGFloat(hex & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
    
    public static let ackeePink: UIColor       = UIColor(hex: 0xff00ff)
    public static let ackeePinkDim: UIColor    = UIColor(hex: 0xcc00cc)
    public static let grey: UIColor            = UIColor(hex: 0xeeeeee)
    public static let text: UIColor            = UIColor(hex: 0x000000)
}

