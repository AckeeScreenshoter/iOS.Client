//
//  ScreenshotViewModel.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//
//

import UIKit
import Photos

protocol ScreenshotViewModelingActions {
    var upload: Action<UploadMultipartDataOperation> { get }
}

protocol ScreenshotViewModelingDelegate: class {
    func appInfoChanged(in viewModel: ScreenshotViewModeling)
    func uploadStarted(in viewModel: ScreenshotViewModeling)
    func uploadProgressChanged(_ progress: Double, in viewModel: ScreenshotViewModeling)
    func uploadFinished(in viewModel: ScreenshotViewModeling)
    func uploadFailed(with error: RequestError, in viewModel: ScreenshotViewModeling)
    func mediaTypeChanged(in viewModel: ScreenshotViewModeling)
    func recordURLChanged(in viewModel: ScreenshotViewModeling)
    func screenshotChanged(in viewModel: ScreenshotViewModeling)
}

protocol ScreenshotViewModeling: class {
    var actions: ScreenshotViewModelingActions { get }
    
    var delegate: ScreenshotViewModelingDelegate? { get set }
    
    /// Indicates whether the last screenshot is being displayer od the last scren record
    var mediaType: MediaType { get set }
    
    /// Last updated image from the gallery
    var screenshot: UIImage? { get set }
    
    /// Last video from the gallery
    var recordURL: URL? { get set }
    
    /// Used as data source for tableview
    var tableData: [(key: String, value: String)] { get }
    
    var appInfo: [String: String] { get set }
    
    /// Custom user note
    var note: String? { get set }
}

extension ScreenshotViewModeling {
    var canUseShareSheet: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription")
            .flatMap { $0 as? String }
            .map { $0.count > 0 } ?? false
    }
}

extension ScreenshotViewModeling where Self: ScreenshotViewModelingActions {
    var actions: ScreenshotViewModelingActions { return self }
}

final class ScreenshotViewModel: BaseViewModel, ScreenshotViewModeling, ScreenshotViewModelingActions {
    
    typealias Dependencies = HasScreenshotAPI
    
    weak var delegate: ScreenshotViewModelingDelegate?

    var mediaType: MediaType = .screenshot {
        didSet {
            delegate?.mediaTypeChanged(in: self)
        }
    }

    var screenshot: UIImage? {
        didSet {
            delegate?.screenshotChanged(in: self)
            upload.operation.recordURL = nil
            upload.operation.screenshot = screenshot
        }
    }
    
    var recordURL: URL? {
        didSet {
            delegate?.recordURLChanged(in: self)
            upload.operation.screenshot = nil
            upload.operation.recordURL = recordURL
        }
    }
    
    var baseURL: URL? {
        didSet {
            upload.operation.baseURL = baseURL
        }
    }
    
    var authorization: String? {
        didSet {
            upload.operation.authorization = authorization
        }
    }
    
    var appInfo: [String:String] = [:] {
        didSet {
            upload.operation.appInfo = appInfo
            tableData = Array(appInfo)
        }
    }
    
    var tableData: [(key: String, value: String)] = [] {
        didSet {
            delegate?.appInfoChanged(in: self)
        }
    }
    
    var note: String? {
        didSet {
            upload.operation.appInfo?["note"] = note
        }
    }
    
    let upload: Action<UploadMultipartDataOperation>
    
    private var imageFetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    private var videoFetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.upload = Action(operation: dependencies.screenshotAPI.uploadOperation)
        super.init()
        
        upload.operation.startBlock = { [weak self] in
            print("start block on")
            self?.delegate?.uploadStarted(in: self!) }
        upload.operation.progressBlock = { [weak self] in
            print("progress block on \($0)")
            self?.delegate?.uploadProgressChanged($0, in: self!) }
        upload.operation.completionBlock = { [weak self] in
            print("completion block on")
            guard let self = self, let result = self.upload.operation.result else { return }
            
            switch result {
            case .success: self.delegate?.uploadFinished(in: self)
            case .failure(let error): self.delegate?.uploadFailed(with: error, in: self)
            }
        }
        
        // Photo Library setup, fetching last image and last record
        PHPhotoLibrary.shared().register(self)
        
        let imageFetchOptions = PHFetchOptions()
        // Photos are fetched by modification date because when the user edits an image in the Photo Library, that asset is likely to be the one that the user wants to use.
        imageFetchOptions.sortDescriptors = [ NSSortDescriptor(key: "modificationDate", ascending: false) ]
        imageFetchResult = PHAsset.fetchAssets(with: .image, options: imageFetchOptions)
        updateScreenshot(with: imageFetchResult.firstObject)
        
        let videoFetchOptions = PHFetchOptions()
        videoFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        videoFetchResult = PHAsset.fetchAssets(with: .video, options: videoFetchOptions)
        updateRecordURL(with: videoFetchResult.firstObject)
    }
    
    private func updateRecordURL(with asset: PHAsset?) {
        guard let asset = asset else { return }
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { [weak self] (asset, _, _) in
            guard let asset = asset as? AVURLAsset else { return }
            self?.recordURL = asset.url
        }
    }
    
    private func updateScreenshot(with asset: PHAsset?) {
        screenshot = asset?.image
    }
}

extension ScreenshotViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let fetchResultChangeDetails = changeInstance.changeDetails(for: imageFetchResult) {
            imageFetchResult = fetchResultChangeDetails.fetchResultAfterChanges
            
            print("changed \(fetchResultChangeDetails.changedObjects.count)")
            print("inserted \(fetchResultChangeDetails.insertedObjects.count)")
            print("removed \(fetchResultChangeDetails.removedObjects.count)")
            
            // When a screenshot is created it is firstly inserted and updated right after that so taking a changed PHAsset gives us the just taken screenshot.
            // When the screenshot is updated by drawing into it this also retrieves the just editted screenshot.
            guard let changed = fetchResultChangeDetails.changedObjects.first else { return }
            
            /// Update UI on main thread
            updateScreenshot(with: changed)
            return
        }
        
        if let fetchResultChangeDetails = changeInstance.changeDetails(for: videoFetchResult) {
            print("changed \(fetchResultChangeDetails.changedObjects.count)")
            print("inserted \(fetchResultChangeDetails.insertedObjects.count)")
            print("removed \(fetchResultChangeDetails.removedObjects.count)")
            
            guard let inserted = fetchResultChangeDetails.insertedObjects.first else { return }
            
            /// Update UI on main thread
            updateRecordURL(with: inserted)
            
            return
        }
    }
}

