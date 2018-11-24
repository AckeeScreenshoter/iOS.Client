//
//  UIViewExtensions.swift
//  Ass
//
//  Created by Jakub Olejník on 23/11/2018.
//

import UIKit

extension UIView {
    func equalEdges(to view: UIView, inset: CGFloat = 0) -> [NSLayoutConstraint] {
        translatesAutoresizingMaskIntoConstraints = false
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return [
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            topAnchor.constraint(equalTo: view.topAnchor, constant: inset),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset),
        ]
    }
}
