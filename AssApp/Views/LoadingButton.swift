//
//  LoadingButton.swift
//  ass-app
//
//  Created by Vendula Švastalová on 29/05/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import ACKategories_iOS
import SnapKit

protocol LoadingButtonDelegate: class {
    func goBackToApp()
    func sendTapped()
}

final class LoadingButton: UIButton {
    
    /// View whose width is being updated to demonstrate the current loading percentage
    private weak var loadingView: UIView!
    
    private weak var delegate: LoadingButtonDelegate?
    
    var isLoading = false {
        didSet {
            isEnabled = !isLoading
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    
        setTitleColor(.white, for: [])
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        layer.cornerRadius = 6
        clipsToBounds = true
        setBackgroundImage(UIColor.ackeePink.image(), for: [])
        setTitle("SEND", for: [])
        snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        let loadingView = UIView()
        loadingView.backgroundColor = UIColor.ackeePinkDim
        loadingView.layer.cornerRadius = 6
        loadingView.clipsToBounds = true
        addSubview(loadingView)
        loadingView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.height.equalToSuperview()
            make.width.equalTo(0)
        }
        self.loadingView = loadingView
        
        // After adding loadingView as a subview titleLabel gets covered by it so it needs to be brought to front
        bringSubviewToFront(titleLabel!)
        
        addTarget(self, action: #selector(handleTap), for: [.touchUpInside])
    }
    
    /// Updates the loading view to cover the defined percentage area of the button
    /// Uses animation when set to `true`
    ///
    /// Used to update the current state of loading.
    /// Is animated by default.
    /// `isLoading` must be `true` to perform any updates
    func updateLoading(progress: Double, animated: Bool = true) {
        guard isLoading else { return }
        
        let changeBlock = { [unowned self] in
            self.loadingView.snp.remakeConstraints { make in
                make.top.leading.bottom.equalToSuperview()
                make.height.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(progress)
            }
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: changeBlock)
        } else {
            changeBlock()
        }
    }
    
    func startLoading() {
        guard !isLoading else { return }
        isLoading = true
    }
    
    /// Calling this method results in changing of the appearance and functionality of this button
    ///
    ///
    /// After calling this method this button will be in such state so that when tapped the user is taken back to the initial app (app from which ASS was opened)
    func stopLoading() {
        guard isLoading else { return }
        setTitle("BACK TO APP", for: [])
        setTitleColor(.ackeePink, for: [])
        setBackgroundImage(nil, for: [])
        loadingView.isHidden = true
        isLoading = false
    }
    
    @objc
    private func handleTap() {
// TODO: manage taps in different states
//        if isLoading {
//            delegate?.goBackToApp()
//        } else {
//            delegate?.sendTapped()
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingButton.State {
    static let loading = UIControl.State(rawValue: 1 << 16)
}
