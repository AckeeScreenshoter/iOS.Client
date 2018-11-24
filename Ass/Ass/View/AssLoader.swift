//
//  AssLoader.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit

final class AssLoader: UIView {
    private weak var loadingAI: UIActivityIndicatorView!
    private weak var percentLabel: UILabel!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.6)
        
        let loadingAI = UIActivityIndicatorView(style: .gray)
        self.loadingAI = loadingAI
        
        let percentLabel = UILabel()
        percentLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        self.percentLabel = percentLabel
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightGray
        addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor)
            ])
        
        let vStack = UIStackView(arrangedSubviews: [loadingAI, percentLabel])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 10
        backgroundView.addSubview(vStack)
        NSLayoutConstraint.activate(vStack.equalEdges(to: backgroundView))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public interface
    
    func setProgress(_ progress: Double) {
        percentLabel.text = String(Int(progress * 100)) + " %"
    }
}
