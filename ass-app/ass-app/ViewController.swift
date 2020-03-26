//
//  ViewController.swift
//  ass-app
//
//  Created by Vendula Švastalová on 26/03/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import Photos
import SnapKit

class ViewController: UIViewController, PHPhotoLibraryChangeObserver {
    
    private weak var imageView: UIImageView!
    private weak var sendButton: UIButton!
    
    private var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        registerToPhotoLibrary()
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
    }
    
    func registerToPhotoLibrary() {
        PHPhotoLibrary.shared().register(self)
    }
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        print("photos did change")
        
        guard let fetchResultChangeDetails = changeInstance.changeDetails(for: fetchResult) else {
            print("No change in fetch result")
            return
        }
        
        print("Contains changes")
        
        fetchResult = fetchResultChangeDetails.fetchResultAfterChanges
        
        let inserted = fetchResultChangeDetails.insertedObjects
        let changed = fetchResultChangeDetails.changedObjects
        
        print("inserted count \(inserted.count)")
        print("changed count \(changed.count)")
    }
}

