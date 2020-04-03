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
    
    private weak var imageView: UIImageView!
    private weak var avPlayerController: AVPlayerViewController!
    private weak var sendButton: UIButton!
    private weak var tableView: UITableView!
    private weak var loader: AssLoader!
    
    
    private let viewModel: ScreenshotViewModeling
    
    init(viewModel: ScreenshotViewModeling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.0))
        
        let imageView = UIImageView()
        self.imageView = imageView
        imageView.isHidden = true
        imageView.contentMode = .scaleAspectFit
        
        header.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(20)
        }
        
        let avPlayerController = AVPlayerViewController()
        self.avPlayerController = avPlayerController
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
        
        // TODO: Add Cancel Button
    }
    
    @objc
    private func sendTapped() {
        viewModel.actions.upload.start()
    }
    
    // MARK: - Private helpers
    private func startLoading() {
        loader.isHidden = false
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func stopLoading() {
        navigationItem.rightBarButtonItem?.isEnabled = true
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
        imageView.isHidden = !viewModel.isScreenshot
        avPlayerController.view.isHidden = viewModel.isScreenshot
    }
}

extension ScreenshotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.tableData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        if #available(iOS 13.0, *) {
            cell.backgroundColor = .systemGray6
        } else {
            cell.backgroundColor = .lightGray
        }
        cell.textLabel?.text = viewModel.tableData[indexPath.row].key
        cell.detailTextLabel?.text = viewModel.tableData[indexPath.row].value
        return cell
    }
}
