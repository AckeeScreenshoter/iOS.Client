//
//  PHAsset.swift
//  ass-app
//
//  Created by Vendula Švastalová on 27/03/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import Photos
import UIKit

extension PHAsset {
    
    /// Creates a UIImage from PHAsset.
    var image: UIImage? {
        let manager = PHImageManager.default()
        let option = PHImageRequestOptions()
        var img: UIImage?
        option.isSynchronous = true
        manager.requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: { result, info in
            img = result
        })
        return img
    }
}
