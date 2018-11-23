//
//  DebugInfoView.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

final class DebugInfoView: UIView {
    
    var appInfo: AppInfo {
        didSet {
            guard oldValue != appInfo else { return }
            updateAppInfo()
        }
    }
    
    private weak var vStack: UIStackView!
    
    // MARK: - Initializers
    
    init(appInfo: AppInfo) {
        self.appInfo = appInfo
        super.init(frame: .zero)
        
        let scrollView = UIScrollView()
        addSubview(scrollView)
        NSLayoutConstraint.activate(scrollView.equalEdges(to: self))
        
        let vStack = UIStackView()
        scrollView.addSubview(vStack)
        NSLayoutConstraint.activate(vStack.equalEdges(to: scrollView) + [vStack.widthAnchor.constraint(equalTo: widthAnchor)])
        self.vStack = vStack
        
        updateAppInfo()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private helpers
    
    private func updateAppInfo() {
        vStack.removeAllArrangedSubviews()
        appInfo.keyValueItems.forEach { key, value in
            let keyValueView = KeyValueView()
            keyValueView.keyLabel.text = key
            keyValueView.valueLabel.text = value
            vStack.addArrangedSubview(keyValueView)
        }
    }
}
