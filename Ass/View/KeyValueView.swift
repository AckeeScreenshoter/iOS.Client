//
//  KeyValueView.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

final class KeyValueView: UIView {
    private(set) weak var keyLabel: UILabel!
    private(set) weak var valueLabel: UILabel!
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let keyLabel = UILabel()
        keyLabel.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        keyLabel.numberOfLines = 0
        keyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.keyLabel = keyLabel
        
        let valueLabel = UILabel()
        valueLabel.font = .systemFont(ofSize: UIFont.systemFontSize)
        valueLabel.numberOfLines = 0
        valueLabel.translatesAutoresizingMaskIntoConstraints = false
        self.valueLabel = valueLabel
        
        let hStack = UIStackView(arrangedSubviews: [keyLabel, valueLabel])
        hStack.distribution = .fill
        hStack.spacing = 10
        addSubview(hStack)
        NSLayoutConstraint.activate(hStack.equalEdges(to: self, inset: 5))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}