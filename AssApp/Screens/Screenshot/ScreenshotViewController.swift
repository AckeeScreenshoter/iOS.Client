//
//  ScreenshotViewController.swift
//  ass-app
//
//  Created by Vendula Švastalová on 26/03/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import Photos
import SnapKit
import AVKit

final class ScreenshotViewController: UIViewController {
    
    /// Displays lastly created or updated photo from gallery
    ///
    /// `isHidden == true` when `avPlayerController.view.isHidden == false` and vice versa.
    private weak var imageView: UIImageView!
    
    /// Displays last video from gallery
    ///
    /// `view.isHidden == true` when `imageView.isHidden == false` and vice versa.
    private weak var avPlayerController: AVPlayerViewController!
    
    private let viewModel: ScreenshotViewModeling
    
    private var keyboardHeight: CGFloat = 0
    
    /// Displays all the information passed from the opening app. Also contains NoteView and LoadingButton
    private weak var infoView: InfoView!
    
    init(viewModel: ScreenshotViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        viewModel.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        let backgroundImage = UIImageView()
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.image = Asset.background.image
        view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.isHidden = false
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.height.equalToSuperview().multipliedBy(0.5)
            make.top.equalTo(safeArea).offset(16)
            make.centerX.equalToSuperview()
        }
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        self.imageView = imageView
        
        
        let avPlayerController = AVPlayerViewController()
        self.avPlayerController = avPlayerController
        avPlayerController.view.layer.cornerRadius = 10
        avPlayerController.view.clipsToBounds = true
        avPlayerController.view.isHidden = true
        view.addSubview(avPlayerController.view)
        avPlayerController.view.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        addChild(avPlayerController)
        
        let infoView = InfoView()
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
        }
        infoView.loadingButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        self.infoView = infoView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe for keyboard changes
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc
    private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            keyboardHeight = keyboardSize.height
            // TODO: manage show-hide keyboard
            //self.sendButton.frame.origin.y -= keyboardHeight
        }
    }
    
    @objc
    private func keyboardWillHide(notification: NSNotification) {
        //self.sendButton.frame.origin.y += keyboardHeight
    }
    
    @objc
    private func openReadme() {
        guard let readmeURL = URL(string: "https://gitlab.ack.ee/iOS/ass/-/blob/master/README.md") else { return }
        UIApplication.shared.open(readmeURL)
    }
    
    @objc
    private func sendTapped() {
        
        // Note is set right before send action occurs, so that we don't have to update the upload operation everytime the text changes but only with the final text
        viewModel.note = infoView.noteView.text
        viewModel.actions.upload.start()
        
        // disable note input
        infoView.noteView.isUserInteractionEnabled = false
    }
    
    // MARK: - Private helpers
    private func startLoading() {
        infoView.loadingButton.startLoading()
    }
    
    private func stopLoading() {
        infoView.loadingButton.stopLoading()
    }
    
    private func setUploadProgress(_ progress: Double) {
        infoView.loadingButton.updateLoading(progress: progress)
    }
}

extension ScreenshotViewController: ScreenshotViewModelingDelegate {
    
    func recordURLChanged(in viewModel: ScreenshotViewModeling) {
        guard let url = viewModel.recordURL else { return }
        DispatchQueue.main.async { [weak self] in
            let player = AVPlayer(url: url)
            self?.avPlayerController.player = player
        }
    }
    
    func screenshotChanged(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = self?.viewModel.screenshot
        }
    }
    
    func appInfoChanged(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            // TODO: add support for section titles
            self?.infoView.info = ["": self?.viewModel.appInfo ?? [:]]
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
    
    func mediaTypeChanged(in viewModel: ScreenshotViewModeling) {
        imageView.isHidden = viewModel.mediaType == .recording
        avPlayerController.view.isHidden = viewModel.mediaType == .screenshot
    }
}
