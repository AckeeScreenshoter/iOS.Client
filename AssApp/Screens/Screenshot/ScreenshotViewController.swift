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
    
    private weak var loadingButton: LoadingButton!
    
    private weak var buttonContentView: UIView!
    
    /// Minimum Y value thet can be reached by the minY value of `infoView`'s frame
    var min: CGFloat = 0
    
    /// Maximum Y value thet can be reached by the minY value of `infoView`'s frame
    var max: CGFloat = 0
    
    /// Current value of Y translation from the begining of the pan gesture to the end
    var currentTranslationY: CGFloat = 0.0
    
    var buttonBottomConstraint: Constraint?
    
    var keyboardIsHidden: Bool = true
    
    var buttonBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            // doesn't have notch
            if view.safeAreaInsets.bottom == 0.0 {
                return 16
            } else {
                return view.safeAreaInsets.bottom
            }
        } else {
            return 16
        }
    }
    
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

        let imageView = ScreenshotImageView(frame: .zero)
        imageView.isHidden = false
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(safeArea).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.65)
        }
        imageView.isUserInteractionEnabled = true
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
        
        let buttonContentView = UIView()
        view.addSubview(buttonContentView)
        buttonContentView.backgroundColor = .white
        buttonContentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
        }
        self.buttonContentView = buttonContentView
        
        let loadingButton = LoadingButton()
        buttonContentView.addSubview(loadingButton)
        self.loadingButton = loadingButton
        loadingButton.addTarget(self, action: #selector(loadingButtonTapped), for: .touchUpInside)
        
        let infoView = InfoView()
        view.addSubview(infoView)
        infoView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
        }
        infoView.noteView.snp.makeConstraints { make in
            make.bottom.equalTo(buttonContentView.snp.top)
        }
        self.infoView = infoView
        
        view.bringSubviewToFront(buttonContentView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe for keyboard frame changes
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        infoView.addGestureRecognizer(gestureRecognizer)
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openPhotoGallery))
        imageView.addGestureRecognizer(imageTap)
    }
    
    @objc
    private func keyboardWillChangeFrame(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            if notification.name == UIResponder.keyboardWillHideNotification {
                keyboardIsHidden = true
                buttonBottomConstraint?.update(inset: buttonBottomInset)
            } else {
                keyboardIsHidden = false
                buttonBottomConstraint?.update(inset: keyboardSize.height + buttonBottomInset)
            }
            
            view.layoutIfNeeded()
        }
    }
    
    @objc
    private func openReadme() {
        guard let readmeURL = URL(string: "https://gitlab.ack.ee/iOS/ass/-/blob/master/README.md") else { return }
        UIApplication.shared.open(readmeURL)
    }
    
    @objc
    private func openPhotoGallery() {
        let alert = UIAlertController(title: "Open Gallery", message: "Do you want to open photo gallery to edit your screenshot?", preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let url = URL(string: "photos-redirect://") else { return }
            UIApplication.shared.open(url)
        }
        let noAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc
    private func loadingButtonTapped() {
        
        if loadingButton.customState == .backToApp {
            var components = URLComponents()
            components.scheme = viewModel.scheme
            guard let url = components.url else { return }
            UIApplication.shared.open(url)
            return
        }
        
        // Note is set right before send action occurs, so that we don't have to update the upload operation everytime the text changes but only with the final text
        viewModel.note = infoView.noteView.text
        viewModel.actions.upload.start()
        
        // disable note input
        infoView.noteView.isUserInteractionEnabled = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        infoView.scrollView.snp.updateConstraints { make in
            // TODO: compute value for greater view
            make.height.equalTo(infoView.scrollView.contentSize.height)
        }
        min = buttonContentView.frame.minY - infoView.frame.height
        max = infoView.frame.minY
        
        // layout loadingButton when safeAreaInsets are computed and valid
        if buttonBottomConstraint == nil {
            loadingButton.snp.makeConstraints { make in
                make.top.equalToSuperview().inset(16)
                make.leading.trailing.equalToSuperview().inset(16)
                buttonBottomConstraint = make.bottom.equalToSuperview().inset(buttonBottomInset).constraint
            }
        }
    }
    
    @objc
    private func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: infoView)
        
        if recognizer.state == .began {
            currentTranslationY = translation.y
        }
        
        var newTop: CGFloat = infoView.frame.minY + translation.y
        
        // Deal with too long translations
        if newTop > max {
            newTop = max
        } else if newTop < min {
            newTop = min
        }
        
        currentTranslationY += translation.y
        infoView.frame.origin = CGPoint(x: infoView.frame.origin.x, y: newTop)
        recognizer.setTranslation(CGPoint.zero, in: infoView)
        
        // dismiss keyboard when dragging down and keyboard is visible
        if newTop == max && !keyboardIsHidden {
            infoView.noteView.resignFirstResponder()
            return
        }

        // Value that distinguishes between accidential and intentional swipe
        let threshold: CGFloat = 60
        
        if recognizer.state == .ended {
            
            // animate to top when
            let shouldAnimateToTop =
                // swiping up and the translation is greater than threshold
                currentTranslationY < -threshold ||
                // swiping down and translation is in lower than threshold
                (currentTranslationY > 0 && currentTranslationY < threshold)
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.infoView.frame.origin = CGPoint(x: self.infoView.frame.origin.x, y: shouldAnimateToTop ? self.min : self.max)
            }, completion: nil)
        }
    }
    
    // MARK: - Private helpers
    private func startLoading() {
        loadingButton.startLoading()
    }
    
    private func stopLoading() {
        loadingButton.stopLoading()
    }
    
    private func setUploadProgress(_ progress: Double) {
        loadingButton.updateLoading(progress: progress)
    }
    
    private func setToInitialState() {
        loadingButton.setToInitialState()
        infoView.noteView.isUserInteractionEnabled = false
    }
}

extension ScreenshotViewController: ScreenshotViewModelingDelegate {
    
    func recordURLChanged(in viewModel: ScreenshotViewModeling) {
        guard let url = viewModel.recordURL else { return }
        DispatchQueue.main.async { [weak self] in
            let player = AVPlayer(url: url)
            self?.avPlayerController.player = player
            
            self?.setToInitialState()
        }
    }
    
    func screenshotChanged(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = self?.viewModel.screenshot
            
            self?.setToInitialState()
        }
    }
    
    func appInfoChanged(in viewModel: ScreenshotViewModeling) {
        DispatchQueue.main.async { [weak self] in
            self?.infoView.info.removeAll()
            
            // Split data to sections
            
            /// Filtered app info
            let appInfo = viewModel.appInfo.filter { AppInfo.Info(rawValue: $0.key)?.section == .appInfo }
            if appInfo.isNotEmpty {
                self?.infoView.info[AppInfo.Info.Section.appInfo.rawValue] = appInfo
            }
        
            /// Filtered device info
            let deviceInfo = viewModel.appInfo.filter { AppInfo.Info(rawValue: $0.key)?.section == .deviceInfo }
            if deviceInfo.isNotEmpty {
                self?.infoView.info[AppInfo.Info.Section.deviceInfo.rawValue] = deviceInfo
            }
            
            /// Filtered custom data
            let customData = viewModel.appInfo.filter { AppInfo.Info(rawValue: $0.key) == nil }
            if customData.isNotEmpty {
                self?.infoView.info[AppInfo.Info.Section.customData.rawValue] = customData
            }
            
            self?.setToInitialState()
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
