//
//  ScreenshotViewModel.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//  
//

import ReactiveSwift

protocol ScreenshotViewModelingActions {

}

protocol ScreenshotViewModeling {
	var actions: ScreenshotViewModelingActions { get }
}

extension ScreenshotViewModeling where Self: ScreenshotViewModelingActions {
    var actions: ScreenshotViewModelingActions { return self }
}

final class ScreenshotViewModel: BaseViewModel, ScreenshotViewModeling, ScreenshotViewModelingActions {
    typealias Dependencies = HasNoDependency

    // MARK: - Initialization

    init(dependencies: Dependencies) {
        super.init()

        setupBindings()
    }

    // MARK: - Helpers
    
    private func setupBindings() {

    }
}
