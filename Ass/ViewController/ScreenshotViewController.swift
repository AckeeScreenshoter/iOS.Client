//
//  ScreenshotViewController.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//  
//

import UIKit

final class ScreenshotViewController: BaseViewController {
    var closeCallback = { }
    
    private weak var noteTextView: UITextView!
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
        
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        let noteTitleLabel = createTitleLabel()
        noteTitleLabel.text = "Note"
        
        let noteTextView = UITextView()
        noteTextView.font = .systemFont(ofSize: UIFont.systemFontSize)
        noteTextView.isScrollEnabled = false
        noteTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        self.noteTextView = noteTextView
        
        let imageTitleLabel = createTitleLabel()
        imageTitleLabel.text = "Screenshot"
        
        let imageView = UIImageView(image: viewModel.screenshot)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        NSLayoutConstraint.activate([imageView.heightAnchor.constraint(equalToConstant: 200)])
        self.imageView = imageView
        
        let debugInfoTitle = createTitleLabel()
        debugInfoTitle.text = "Debug info"
        
        let debugInfoView = DebugInfoView(appInfo: viewModel.appInfo)
        view.addSubview(debugInfoView)
        self.debugInfoView = debugInfoView
        
        let vStack = UIStackView(arrangedSubviews: [noteTitleLabel, noteTextView,
                                                    imageTitleLabel, imageView,
                                                    debugInfoTitle, debugInfoView])
        vStack.axis = .vertical
        vStack.spacing = 10
        scrollView.addSubview(vStack)
        NSLayoutConstraint.activate(vStack.equalEdges(to: scrollView, inset: 15) + [vStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -30)])
        
        let loader = AssLoader()
        loader.isHidden = true
        view.addSubview(loader)
        NSLayoutConstraint.activate(loader.equalEdges(to: scrollView))
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
        
        noteTextView.delegate = self
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
        viewModel.actions.upload.operation.cancel()
        dismiss(animated: true, completion: closeCallback)
    }
    
    // MARK: - Private helpers
    
    private func startLoading() {
        loader.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setUploadProgress(_ progress: Double) {
        loader.setProgress(progress)
    }
    
    private func stopLoading() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        loader.isHidden = true
        loader.setProgress(0)
    }
    
    private func uploadSucceeded() {
        let alertVC = UIAlertController(title: "Success", message: "Your screenshot was successfully uploaded", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.dismiss(animated: true, completion: self?.closeCallback)
        }
        alertVC.addAction(ok)
        present(alertVC, animated: true)
    }
    
    private func createTitleLabel() -> UILabel {
        let titleLabel = UILabel()
        titleLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        titleLabel.numberOfLines = 0
        return titleLabel
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

extension ScreenshotViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.note = textView.text ?? ""
    }
}
