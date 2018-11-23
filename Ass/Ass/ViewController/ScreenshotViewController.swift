//
//  ScreenshotViewController.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//  
//

import UIKit
import ReactiveSwift

protocol ScreenshotFlowDelegate: class {

}

final class ScreenshotViewController: BaseViewController {

    weak var flowDelegate: ScreenshotFlowDelegate?

    private let viewModel: ScreenshotViewModeling

    // MARK: - Initialization

    init(viewModel: ScreenshotViewModeling) {
        self.viewModel = viewModel

        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle

    override func loadView() {
        super.loadView()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupBindings()
    }

    // MARK: - Helpers

    private func setupBindings() {

    }

}
