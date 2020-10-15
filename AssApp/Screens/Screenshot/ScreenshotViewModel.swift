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
    func startUploading()
    func checkAuthorization()
}

protocol ScreenshotViewModelingDelegate: class {
    func appInfoChanged(in viewModel: ScreenshotViewModeling)
    func uploadStarted(in viewModel: ScreenshotViewModeling)
    func uploadProgressChanged(_ progress: Double, in viewModel: ScreenshotViewModeling)
    func uploadFinished(in viewModel: ScreenshotViewModeling)
    func uploadFailed(with error: RequestError, in viewModel: ScreenshotViewModeling)
    func mediaChanged(in viewModel: ScreenshotViewModeling)
    func openSettings(in viewModel: ScreenshotViewModeling)
}

protocol ScreenshotViewModeling: class {
    var actions: ScreenshotViewModelingActions { get }
    
    var delegate: ScreenshotViewModelingDelegate? { get set }
    
    /// Indicates whether the last screenshot is being displayer od the last scren record
    var media: Media { get set }
    
    /// Used as data source for tableview
    var tableData: [(key: String, value: String)] { get }
    
    var appInfo: [String: String] { get set }
    
    /// Custom user note
    var note: String? { get set }
    
    var scheme: String? { get }
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

    var media: Media = .screenshot(nil) {
        didSet {
            delegate?.mediaChanged(in: self)
        }
    }
    
    var appInfo: [String:String] = [:] {
        didSet {
            tableData = Array(appInfo)
        }
    }
    
    var tableData: [(key: String, value: String)] = [] {
        didSet {
            delegate?.appInfoChanged(in: self)
        }
    }
    
    var note: String?
    
    var scheme: String?
    var baseURL: URL?
    var authorization: String?
    
    private let screenshotAPIService: ScreenshotAPIServicing
    
    private var imageFetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    private var videoFetchResult: PHFetchResult<PHAsset> = PHFetchResult<PHAsset>()
    
    private var uploadAction: Action<UploadMultipartDataOperation>? = nil
    
    private var currentAsset: PHAsset?
    
    // MARK: - Initialization

    init(dependencies: Dependencies) {
        self.screenshotAPIService = dependencies.screenshotAPI
        super.init()
        
        // Photo Library setup, fetching last image and last record
        PHPhotoLibrary.shared().register(self)
        
        updateMedia()
    }
    
    private func updateRecordURL(with asset: PHAsset?) {
        guard let asset = asset else { return }
        PHImageManager.default().requestAVAsset(forVideo: asset, options: nil) { [weak self] (avAsset, _, _) in
            guard let urlAsset = avAsset as? AVURLAsset else { return }
            self?.media = .record(asset, urlAsset.url)
        }
    }
    
    private func updateScreenshot(with asset: PHAsset?) {
        media = .screenshot(asset)
    }
    
    private func updateMedia() {
        switch media {
        case .record:
            let videoFetchOptions = PHFetchOptions()
            videoFetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            videoFetchResult = PHAsset.fetchAssets(with: .video, options: videoFetchOptions)
            updateRecordURL(with: videoFetchResult.firstObject)
        case .screenshot:
            guard let screenshotAssetCollection = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumScreenshots, options: nil).firstObject else {
                return
            }
            
            let imageFetchOptions = PHFetchOptions()
            // Photos are fetched by modification date because when the user edits an image in the Photo Library, that asset is likely to be the one that the user wants to use.
            imageFetchOptions.sortDescriptors = [ NSSortDescriptor(key: "modificationDate", ascending: false) ]
            
            imageFetchResult = PHAsset.fetchAssets(in: screenshotAssetCollection, options: imageFetchOptions)
            updateScreenshot(with: imageFetchResult.firstObject)
        }
    }

    /// TODO: if at any time access can be `.limited` by the user to only certain folders in the gallery
    /// update the logic to require access to the screenshot folder
    /// until then the app requires `.authorized` access
    func checkAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            updateMedia()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                if status == .authorized {
                    self?.updateMedia()
                }
            }
        case .denied, .restricted, .limited:
            delegate?.openSettings(in: self)
        @unknown default:
            delegate?.openSettings(in: self)
        }
    }
    
    func startUploading() {
        
        // update appInfo with current note
        var appInfo = self.appInfo
        appInfo["note"] = note
        
        guard let operation = screenshotAPIService.createUploadOperation(media: media, appInfo: appInfo, baseURL: baseURL, authorization: authorization) else { return }
        
        uploadAction = Action(operation: operation)
        
        uploadAction?.operation.startBlock = { [weak self] in
            guard let self = self else { return }
            self.delegate?.uploadStarted(in: self)
        }

        uploadAction?.operation.progressBlock = { [weak self] in
            self?.delegate?.uploadProgressChanged($0, in: self!)
        }
        
        uploadAction?.operation.completionBlock = { [weak self] in
            guard let self = self, let result = self.uploadAction?.operation.result else { return }
            
            switch result {
            case .success:
                if UserDefaults.standard.bool(forKey: "delete_screenshot") {
                    self.deleteFromLibrary(media: self.media)
                }
                self.delegate?.uploadFinished(in: self)
            case .failure(let error):
                self.delegate?.uploadFailed(with: error, in: self)
            }
        }
        
        uploadAction?.start()
    }
    
    private func deleteFromLibrary(media: Media) {
        let assetsToRemove: [PHAsset]
        
        switch media {
        case let .record(asset, _):
            assetsToRemove = [asset].compactMap { $0 }
        case let .screenshot(asset):
            assetsToRemove = [asset].compactMap { $0 }
        }
        
        PHPhotoLibrary.shared().performChanges {
            let assets = NSMutableArray(array: assetsToRemove)
            PHAssetChangeRequest.deleteAssets(assets)
        } completionHandler: { (success, error) in
            print(success ? "Successfully deleted screenshot" : error)
        }
    }
}

extension ScreenshotViewModel: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        if let fetchResultChangeDetails = changeInstance.changeDetails(for: imageFetchResult) {
            imageFetchResult = fetchResultChangeDetails.fetchResultAfterChanges
            
            // When a screenshot is created it is firstly inserted and updated right after that so taking a changed PHAsset gives us the just taken screenshot.
            // When the screenshot is updated by drawing into it this also retrieves the just editted screenshot.
            guard let changed = fetchResultChangeDetails.changedObjects.first else { return }
            
            /// Update UI on main thread
            updateScreenshot(with: changed)
            return
        }
        
        if let fetchResultChangeDetails = changeInstance.changeDetails(for: videoFetchResult) {
 
            guard let inserted = fetchResultChangeDetails.insertedObjects.first else { return }
            
            /// Update UI on main thread
            updateRecordURL(with: inserted)
            
            return
        }
    }
}
