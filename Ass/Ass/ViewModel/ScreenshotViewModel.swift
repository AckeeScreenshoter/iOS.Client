//
//  ScreenshotViewModel.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//  
//

import UIKit

protocol ScreenshotViewModelingActions {

}

protocol ScreenshotViewModelingDelegate: class {
    func screenshotChanged(in viewModel: ScreenshotViewModeling)
    func appInfoChanged(in viewModel: ScreenshotViewModeling)
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
    typealias Dependencies = HasNoDependency
    
    weak var delegate: ScreenshotViewModelingDelegate?
    
    let screenshot: UIImage
    let appInfo = AppInfo.default
    var canUseShareSheet: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription")
            .flatMap { $0 as? String }
            .map { $0.count > 0 } ?? false
    }

    // MARK: - Initialization

    init(dependencies: Dependencies, screenshot: UIImage) {
        self.screenshot = screenshot
        super.init()
    }
}
