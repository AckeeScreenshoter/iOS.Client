//
//  ScreenshotImageView.swift
//  ass-app
//
//  Created by Vendula Švastalová on 18/06/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

/// Resizes its width according to the ratio of its the heights of this view and the image while using `contentMode .scaleAcpectFit`
class ScreenshotImageView: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentMode = .scaleAspectFit
        layer.cornerRadius = 10
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        
        if let image = self.image {
            let imageWidth = image.size.width
            let imageHeight = image.size.height
            let viewHeight = self.frame.size.height

            let ratio = viewHeight/imageHeight
            let scaledWidth = imageWidth * ratio

            return CGSize(width: scaledWidth, height: viewHeight)
        }

        return CGSize(width: -1.0, height: -1.0)
    }
}
