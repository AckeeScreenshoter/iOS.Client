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

class ScreenshotViewController: UIViewController {
    
    /// Displays lastly created or updated photo from gallery
    ///
    /// `isHidden == true` when `avPlayerController.view.isHidden == false` and vice versa.
    private weak var imageView: UIImageView!
    
    /// Displays last video from gallery
    ///
    /// `view.isHidden == true` when `imageView.isHidden == false` and vice versa.
    private weak var avPlayerController: AVPlayerViewController!
    
    /// Starts an operation to send all data from tableView and image or video to the server
    private weak var sendButton: UIButton!
    
    /// Shows all data sent from application
    private weak var tableView: UITableView!
    
    private weak var loader: AssLoader!
    
    private weak var readmeLink: UIButton!
    
    private var noteCell: UITableViewCell!
    
    private weak var noteTextField: UITextField!
    
    private let viewModel: ScreenshotViewModeling
    
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
        
        let noteCell = UITableViewCell(style: .default, reuseIdentifier: "noteCell")
        let textField = UITextField()
        self.noteTextField = textField
        if #available(iOS 13.0, *) {
            noteCell.backgroundColor = .systemGray6
            textField.backgroundColor = .systemGray6
        } else {
            noteCell.backgroundColor = .lightGray
            textField.backgroundColor = .lightGray
        }
        noteCell.addSubview(textField)
        textField.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        self.noteCell = noteCell
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.0))
        
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.isHidden = false
        imageView.contentMode = .scaleAspectFit
        
        header.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        let avPlayerController = AVPlayerViewController()
        self.avPlayerController = avPlayerController
        avPlayerController.view.isHidden = true
        header.addSubview(avPlayerController.view)
        avPlayerController.view.snp.makeConstraints { make in
            make.edges.equalTo(imageView)
        }
        addChild(avPlayerController)
    
        let tableView = UITableView()
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.tableHeaderView = header
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 300))
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview()
        }
        self.tableView = tableView
        
        let sendButton = UIButton(type: .system)
        view.addSubview(sendButton)
        sendButton.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            } else {
                make.trailing.bottom.equalToSuperview().inset(16)
            }
            make.width.height.equalTo(80)
        }
        sendButton.layer.cornerRadius = 30
        sendButton.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1)
        sendButton.tintColor = .white
        sendButton.isHidden = true
        sendButton.setTitle("Send", for: [])
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        self.sendButton = sendButton
        
        let loader = AssLoader()
        view.addSubview(loader)
        loader.isHidden = true
        loader.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.loader = loader
        
        let readmeLink = UIButton(type: .system)
        readmeLink.setTitle("Go to GitLab readme to find out more about Ass", for: [])
        readmeLink.isHidden = false
        readmeLink.titleLabel?.numberOfLines = 0
        readmeLink.titleLabel?.textAlignment = .center
        readmeLink.tintColor = .black
        readmeLink.addTarget(self, action: #selector(openReadme), for: .touchUpInside)
        view.addSubview(readmeLink)
        readmeLink.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.center.equalToSuperview()
        }
        self.readmeLink = readmeLink
        
        // TODO: Add Cancel Button
    }
    
    @objc
    private func openReadme() {
        guard let readmeURL = URL(string: "https://gitlab.ack.ee/iOS/ass/-/blob/master/README.md") else { return }
        UIApplication.shared.open(readmeURL)
    }
    
    @objc
    private func sendTapped() {
        
        // Note is set right before send action occurs, so that we don't have to update the upload operation everytime the text changes but only with the final text
        viewModel.note = noteTextField.text
        viewModel.actions.upload.start()
    }
    
    // MARK: - Private helpers
    private func startLoading() {
        loader.isHidden = false
    }
    
    private func stopLoading() {
        loader.isHidden = true
        loader.setProgress(0)
    }
    
    private func setUploadProgress(_ progress: Double) {
        loader.setProgress(progress)
    }
    
    private func uploadSucceeded() {
        let alertVC = UIAlertController(title: "Success", message: "Your screenshot was successfully uploaded", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) { _ in }
        alertVC.addAction(ok)
        present(alertVC, animated: true)
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
            let isEmpty = self?.viewModel.tableData.isEmpty ?? true
            self?.readmeLink.isHidden = !isEmpty
            self?.sendButton.isHidden = isEmpty
            self?.tableView.reloadData()
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
    
    func mediaTypeChanged(in viewModel: ScreenshotViewModeling) {
        imageView.isHidden = viewModel.mediaType == .recording
        avPlayerController.view.isHidden = viewModel.mediaType == .screenshot
    }
}

extension ScreenshotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.tableData.isEmpty { return 0 }
        return viewModel.tableData.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            return noteCell
        }
        
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .systemGray6
        } else {
            cell.backgroundColor = .lightGray
        }
        cell.textLabel?.text = viewModel.tableData[indexPath.row - 1].key
        cell.detailTextLabel?.text = viewModel.tableData[indexPath.row - 1].value
        return cell
    }
}
