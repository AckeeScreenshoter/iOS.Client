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

class ViewController: UIViewController {
    
    private weak var imageView: UIImageView!
    private weak var sendButton: UIButton!
    
    private var fetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    let info = Array(["barva": "modra", "jmeno": "Cameron", "prijmeni": "Diaz", "status": "Married", "age": "50"])
    
    override func loadView() {
        super.loadView()
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.0))
        
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.contentMode = .scaleAspectFit
        
        header.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
    
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.bottom.equalTo(view.safeAreaLayoutGuide)
            } else {
                make.top.bottom.equalToSuperview()
            }
        }
        
        let sendButton = UIButton(type: .system)
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            } else {
                make.trailing.bottom.equalToSuperview().inset(16)
            }
            make.width.height.equalTo(80)
        }
        sendButton.layer.cornerRadius = 30
        sendButton.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        sendButton.tintColor = .white
        sendButton.setTitle("Send", for: [])
        self.sendButton = sendButton
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PHPhotoLibrary.shared().register(self)
        
        let fetchOptions = PHFetchOptions()
        // Photos are fetched by modification date because when the user edits an image in the Photo Library, that asset is likely to be the one that the user wants to use.
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "modificationDate", ascending: false)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        
        guard let image = fetchResult.firstObject?.image else { return }
        imageView.image = image
    }
}

extension ViewController: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        guard let fetchResultChangeDetails = changeInstance.changeDetails(for: fetchResult) else {
            return
        }
        
        fetchResult = fetchResultChangeDetails.fetchResultAfterChanges
        
        // When a screenshot is created it is firstly inserted and updated right after that so taking a changed PHAsset gives us the just taken screenshot.
        // When the screenshot is updated by drawing into it this also retrieves the just editted screenshot.
        guard let changed = fetchResultChangeDetails.changedObjects.first?.image else { return }
        
        /// Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = changed
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        info.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .systemGray6
        } else {
            cell.backgroundColor = .lightGray
        }
        cell.textLabel?.text = info[indexPath.row].key
        cell.detailTextLabel?.text = info[indexPath.row].value
        return cell
    }
}
