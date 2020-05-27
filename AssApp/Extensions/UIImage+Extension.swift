//
//  UIImage+Extension.swift
//  ass-app
//
//  Created by Vendula Švastalová on 22/05/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

enum Asset: String {
    case background
    
    var image: UIImage {
        UIImage(named: rawValue)!
    }
}

extension UIImage {
    var view: UIImageView {
        UIImageView(image: self)
    }
}
