//
//  InfoView.swift
//  ass-app
//
//  Created by Vendula Švastalová on 16/06/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import SnapKit

final class InfoView: UIView {
    
    private weak var scrollView: UIScrollView!
    
    /// Shows information passed from the opening application
    private weak var VStack: UIStackView!
    private weak var notchView: UIView!
    weak var loadingButton: LoadingButton!
    
    /// User input view
    weak var noteView: NoteView!
    
    // TODO
    var height: Constraint?
    var currentHeight: CGFloat = 0
    let maxHeight: CGFloat = 300
    
    var info: [String: [String: String]] = [:] {
        didSet {
            updateList(with: info)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let notchView = UIView()
        notchView.backgroundColor = .gray
        addSubview(notchView)
        notchView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(4)
            make.width.equalTo(100)
        }
        self.notchView = notchView

        let noteView = NoteView()
        addSubview(noteView)
        noteView.snp.makeConstraints { make in
            make.top.equalTo(notchView.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        self.noteView = noteView
        
        let loadingButton = LoadingButton()
            addSubview(loadingButton)
            loadingButton.snp.makeConstraints { make in
                make.leading.trailing.equalToSuperview().inset(16)
                make.bottom.equalTo(safeArea)
            }
        self.loadingButton = loadingButton

        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        addSubview(scrollView)
        self.scrollView = scrollView
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(noteView.snp.bottom).offset(24)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(loadingButton.snp.top)
            height = make.height.equalTo(0).constraint
        }

        let VStack = UIStackView()
        VStack.spacing = 8.0
        VStack.axis = .vertical
        VStack.alignment = .fill
        VStack.distribution = .fill
        scrollView.addSubview(VStack)
        VStack.snp.makeConstraints { make in
            make.edges.width.equalToSuperview()
        }
        self.VStack = VStack
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        addGestureRecognizer(gestureRecognizer)
    }
    
    @objc
    func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self)
        let change = currentHeight - translation.y

        // TODO: add animation, restrict pan gesture area, fix behavior
        if change >= 0 && change <= 300 {
            self.height?.update(offset: change)
            currentHeight = change
        }
    }
    
    private func updateList(with items: [String: [String: String]]) {
        VStack.removeAllArrangedSubviews()
        
        for (section, values) in items {
            
            // Do not create sectionLabel when there are no values in the section
            guard !values.isEmpty else { continue }
            
            let sectionLabel = UILabel()
            sectionLabel.font = .systemFont(ofSize: 14, weight: .bold)
            sectionLabel.textColor = UIColor.black.withAlphaComponent(0.9)
            sectionLabel.text = section
            VStack.addArrangedSubview(sectionLabel)
            
            if #available(iOS 11.0, *) {
                VStack.setCustomSpacing(16, after: sectionLabel)
            }
            
            values.forEach { (key, value) in
                let HStack = UIStackView()
                let keyLabel = UILabel()
                keyLabel.font = .systemFont(ofSize: 14, weight: .semibold)
                keyLabel.textColor = UIColor.black.withAlphaComponent(0.7)
                keyLabel.textAlignment = .left
                keyLabel.text = key
                HStack.addArrangedSubview(keyLabel)
                
                let valueLabel = UILabel()
                valueLabel.font = .overpassMonoRegular(size: 14)
                valueLabel.textColor = UIColor.black.withAlphaComponent(0.7)
                valueLabel.textAlignment = .right
                valueLabel.text = value
                HStack.addArrangedSubview(valueLabel)
                
                VStack.addArrangedSubview(HStack)
                
                let line = UIView()
                line.backgroundColor = .gray
                line.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
                VStack.addArrangedSubview(line)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

