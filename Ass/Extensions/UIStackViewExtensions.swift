//
//  UIStackViewExtensions.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

extension UIStackView {
    /// Remove all arranged subviews
    func removeAllArrangedSubviews() {
        arrangedSubviews.forEach { removeArrangedSubview($0); $0.removeFromSuperview() }
    }
}
