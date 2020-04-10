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
        loadingAI.startAnimating()
        self.loadingAI = loadingAI
        
        let percentLabel = UILabel()
        percentLabel.textAlignment = .center
        percentLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        self.percentLabel = percentLabel
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = .lightGray
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.layer.cornerRadius = 5
        backgroundView.layer.masksToBounds = true
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        let vStack = UIStackView(arrangedSubviews: [loadingAI, percentLabel])
        vStack.axis = .vertical
        vStack.alignment = .center
        vStack.spacing = 10
        backgroundView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalTo(backgroundView).inset(20)
        }
        
        setProgress(0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public interface
    
    func setProgress(_ progress: Double) {
        percentLabel.text = String(Int(progress * 100)) + " %"
    }
}
