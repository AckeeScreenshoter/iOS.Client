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
    
    enum State {
        
        /// Currently loading
        case loading
        
        /// Loading has been finished
        case backToApp
        
        /// Initial state
        case base
    }
    
    /// View whose width is being updated to demonstrate the current loading percentage
    private weak var loadingView: UIView!
    
    private weak var delegate: LoadingButtonDelegate?
    
    var customState: State = .base {
        didSet {
            isEnabled = customState == .backToApp || customState == .base
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
    }
    
    /// Updates the loading view to cover the defined percentage area of the button
    /// Uses animation when set to `true`
    ///
    /// Used to update the current state of loading.
    /// Is animated by default.
    /// `isLoading` must be `true` to perform any updates
    func updateLoading(progress: Double, animated: Bool = true) {
        guard customState == .loading else { return }
        
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
        guard customState == .base else { return }
        customState = .loading
    }
    
    /// Calling this method results in changing of the appearance and functionality of this button
    ///
    ///
    /// After calling this method this button will be in such state so that when tapped the user is taken back to the initial app (app from which ASS was opened)
    func stopLoading() {
        guard customState == .loading else { return }
        setTitle("BACK TO APP", for: [])
        setTitleColor(.ackeePink, for: [])
        setBackgroundImage(nil, for: [])
        loadingView.isHidden = true
        customState = .backToApp
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
