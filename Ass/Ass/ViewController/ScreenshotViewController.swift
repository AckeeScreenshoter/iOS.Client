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
    private weak var loader: AssLoader!
    
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
        
        let loader = AssLoader()
        loader.isHidden = true
        view.addSubview(loader)
        NSLayoutConstraint.activate(view.equalEdges(to: loader))
        self.loader = loader
        
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
        viewModel.actions.upload.start()
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
    
    // MARK: - Private helpers
    
    private func startLoading() {
        loader.isHidden = false
    }
    
    private func setUploadProgress(_ progress: Double) {
        loader.setProgress(progress)
    }
    
    private func stopLoading() {
        loader.isHidden = true
        loader.setProgress(0)
    }
    
    private func uploadSucceeded() {
        let alertVC = UIAlertController(title: "Success", message: "Your screenshot was successfully uploaded", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true)
        }
        alertVC.addAction(ok)
        present(alertVC, animated: true)
    }
}

extension ScreenshotViewController: ScreenshotViewModelingDelegate {
    func screenshotChanged(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = viewModel.screenshot
        }
    }
    
    func appInfoChanged(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.debugInfoView.appInfo = viewModel.appInfo
        }
    }
    
    func uploadStarted(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.startLoading()
        }
    }
    
    func uploadProgressChanged(_ progress: Double, in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.setUploadProgress(progress)
        }
    }
    
    func uploadFinished(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.stopLoading()
            self?.uploadSucceeded()
        }
    }
    
    func uploadFailed(with error: RequestError, in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            let retry = UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
                self?.viewModel.actions.upload.start()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alertVC.addAction(retry)
            alertVC.addAction(cancel)
            self?.present(alertVC, animated: true)
        }
    }
}
