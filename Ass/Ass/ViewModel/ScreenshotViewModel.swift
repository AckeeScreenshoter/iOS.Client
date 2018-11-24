//
//  ScreenshotViewModel.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//  
//

import UIKit

protocol ScreenshotViewModelingActions {
    var upload: Action<UploadScreenshotOperation> { get }
}

protocol ScreenshotViewModelingDelegate: class {
    func screenshotChanged(in viewModel: ScreenshotViewModeling)
    func appInfoChanged(in viewModel: ScreenshotViewModeling)
    func uploadStarted(in viewModel: ScreenshotViewModeling)
    func uploadProgressChanged(_ progress: Double, in viewModel: ScreenshotViewModeling)
    func uploadFinished(in viewModel: ScreenshotViewModeling)
    func uploadFailed(with error: RequestError, in viewModel: ScreenshotViewModeling)
}

protocol ScreenshotViewModeling: class {
	var actions: ScreenshotViewModelingActions { get }
    
    var delegate: ScreenshotViewModelingDelegate? { get set }
    
    var screenshot: UIImage { get }
    var appInfo: AppInfo { get }
    var canUseShareSheet: Bool { get }
}

extension ScreenshotViewModeling where Self: ScreenshotViewModelingActions {
    var actions: ScreenshotViewModelingActions { return self }
}

final class ScreenshotViewModel: BaseViewModel, ScreenshotViewModeling, ScreenshotViewModelingActions {
    typealias Dependencies = HasScreenshotAPI
    
    weak var delegate: ScreenshotViewModelingDelegate?
    
    let screenshot: UIImage
    let appInfo = AppInfo.default
    var canUseShareSheet: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription")
            .flatMap { $0 as? String }
            .map { $0.count > 0 } ?? false
    }
    
    let upload: Action<UploadScreenshotOperation>

    // MARK: - Initialization

    init(dependencies: Dependencies, screenshot: UIImage) {
        self.screenshot = screenshot
        self.upload = Action(operation: dependencies.screenshotAPI.upload(screenshot: screenshot, appInfo: appInfo))
        super.init()
        
        upload.operation.startBlock = { [weak self] in self?.delegate?.uploadStarted(in: self!) }
        upload.operation.progressBlock = { [weak self] in self?.delegate?.uploadProgressChanged($0, in: self!) }
        upload.operation.completionBlock = { [weak self] in
            guard let self = self, let result = self.upload.operation.result else { return }
            
            switch result {
            case .success: self.delegate?.uploadFinished(in: self)
            case .failure(let error): self.delegate?.uploadFailed(with: error, in: self)
            }
        }
    }
}
