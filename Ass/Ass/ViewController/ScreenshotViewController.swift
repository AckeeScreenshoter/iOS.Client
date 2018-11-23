//
//  ScreenshotViewController.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//  
//

import UIKit

final class ScreenshotViewController: BaseViewController {
    private weak var imageView: UIImageView!
    private weak var debugInfoView: DebugInfoView!
    
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

        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        self.imageView = imageView
        
        let debugInfoView = DebugInfoView(appInfo: .default)
        view.addSubview(debugInfoView)
        NSLayoutConstraint.activate([
            debugInfoView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15),
            debugInfoView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 15),
            debugInfoView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -15)
            ])
        self.debugInfoView = debugInfoView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
        
        imageView.image = viewModel.screenshot
    }
}

extension ScreenshotViewController: ScreenshotViewModelingDelegate {
    func screenshotChanged(in viewModel: ScreenshotViewModeling) {
        imageView.image = viewModel.screenshot
    }
}
