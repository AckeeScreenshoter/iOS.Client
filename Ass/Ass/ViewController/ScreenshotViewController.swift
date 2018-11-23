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
        self.title = "Debug"
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Controller lifecycle

    override func loadView() {
        super.loadView()

        let imageView = UIImageView(image: viewModel.screenshot)
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
        
        let debugInfoView = DebugInfoView(appInfo: viewModel.appInfo)
        view.addSubview(debugInfoView)
        NSLayoutConstraint.activate([
            debugInfoView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -15),
            debugInfoView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 15),
            debugInfoView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: -15)
            ])
        self.debugInfoView = debugInfoView
        
        
        toolbarItems = viewModel.canUseShareSheet ? [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
            ] : []
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(sendTapped))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.delegate = self
    }
    
    // MARK: - UI actions
    
    @objc
    private func sendTapped() {
        myImageUploadRequest(image: viewModel.screenshot, appInfo: viewModel.appInfo)
    }
    
    @objc
    private func shareTapped() {
        let shareVC = UIActivityViewController(activityItems: [viewModel.screenshot, viewModel.appInfo.description], applicationActivities: nil)
        present(shareVC, animated: true)
    }
    
    @objc
    private func cancelTapped() {
        dismiss(animated: true)
    }
    
    
}

extension ScreenshotViewController: ScreenshotViewModelingDelegate {
    func screenshotChanged(in viewModel: ScreenshotViewModeling) {
        imageView.image = viewModel.screenshot
    }
    
    func appInfoChanged(in viewModel: ScreenshotViewModeling) {
        debugInfoView.appInfo = viewModel.appInfo
    }
}
