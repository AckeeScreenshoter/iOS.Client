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
        
        var title: String {
            switch self {
            case .backToApp:    return "back to app".uppercased()
            default:            return "send".uppercased()
            }
        }
        
        var backgroundColor: UIColor? {
            switch self {
            case .backToApp:    return nil
            default:            return .ackeePink
            }
        }
        
        var titleColor: UIColor? {
            switch self {
            case .backToApp:    return .ackeePink
            default:            return .white
            }
        }
    }
    
    /// View whose width is being updated to demonstrate the current loading percentage
    private weak var loadingView: UIView!
    
    private(set) var customState: State = .base {
        didSet {
            updateUI(for: customState)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
    
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        layer.cornerRadius = 6
        clipsToBounds = true
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
        
        updateUI(for: .base)
    }
    
    /// Updates the loading view to cover the defined percentage area of the button
    /// Uses animation when set to `true`
    ///
    /// Used to update the current state of loading.
    /// Is animated by default.
    /// `isLoading` must be `true` to perform any updates
    func updateLoading(progress: Double, animated: Bool = true) {
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
    
    /// Brings the button to `.loading` state
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
        customState = .backToApp
    }
    
    func setToInitialState() {
        guard customState == .backToApp else { return }
        customState = .base
        updateLoading(progress: 0.0, animated: false)
    }
    
    private func updateUI(for state: State) {
        setTitle(state.title, for: [])
        setTitleColor(state.titleColor, for: [])
        setBackgroundImage(state.backgroundColor?.image(), for: [])
        loadingView.isHidden = state == .backToApp
        isEnabled = state != .loading
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
