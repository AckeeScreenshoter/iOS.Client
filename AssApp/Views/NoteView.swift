//
//  NoteView.swift
//  ass-app
//
//  Created by Vendula Švastalová on 10/06/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import AssCore

final class NoteView: UITextView {
    
    enum State {
        case disabled
        case active
        case inactiveEmpty
        case inactiveFull
        
        var backgroundColor: UIColor {
            switch self {
            case .active:           return .white
            default:                return .grey
            }
        }
        
        var placeholderColor: UIColor {
            switch self {
            case .disabled:         return UIColor.black.withAlphaComponent(0.3)
            case .active:           return .ackeePink
            case .inactiveEmpty:    return UIColor.black.withAlphaComponent(0.4)
            case .inactiveFull:     return UIColor.black.withAlphaComponent(0.9)
            }
        }
        
        var textColor: UIColor {
            switch self {
            case .active:           return UIColor.black
            case .disabled:         return UIColor.black.withAlphaComponent(0.3)
            default:                return UIColor.black.withAlphaComponent(0.7)
            }
        }
        
        var borderColor: UIColor? {
            switch self {
            case .active:           return .ackeePink
            default:                return nil
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .active:           return 2
            default:                return 0
            }
        }
    }
    
    private weak var largePlaceholder: UILabel!
    private weak var smallPlaceholder: UILabel!
    
    override var isUserInteractionEnabled: Bool {
        didSet {
            if !isUserInteractionEnabled {
                state = .disabled
            } else {
                state = text.isEmpty ? .inactiveEmpty : .inactiveFull
            }
        }
    }
    
    private var state: State = .inactiveEmpty {
        didSet {
            updateUI(with: state)
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        delegate = self
        tintColor = .ackeePink
        font = .systemFont(ofSize: 16, weight: .regular)
        textContainerInset = UIEdgeInsets(top: 36, left: 16, bottom: 16, right: 16)
        layer.cornerRadius = 6
        layer.borderWidth = 2
        snp.makeConstraints { make in
            make.height.equalTo(92)
        }
        
        let largePlaceholder = UILabel()
        largePlaceholder.text = "My Note"
        largePlaceholder.font = .systemFont(ofSize: 16, weight: .semibold)
        addSubview(largePlaceholder)
        largePlaceholder.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.largePlaceholder = largePlaceholder
        
        let smallPlaceholder = UILabel()
        smallPlaceholder.text = "My Note"
        smallPlaceholder.font = .systemFont(ofSize: 12, weight: .semibold)
        addSubview(smallPlaceholder)
        smallPlaceholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.equalTo(largePlaceholder)
        }
        self.smallPlaceholder = smallPlaceholder
        
        updateUI(with: .inactiveEmpty, animated: false)
    }
    
    private func updateUI(with state: State, animated: Bool = true) {
        let firstChangeBlock = { [weak self] in
            if state == .active || state == .inactiveFull  {
                self?.largePlaceholder.alpha = 0.0
            } else if state != .disabled {
                self?.smallPlaceholder.alpha = 0.0
            }
            self?.backgroundColor = state.backgroundColor
            self?.layer.borderColor = state.borderColor?.cgColor
            self?.layer.borderWidth = state.borderWidth
            self?.textColor = state.textColor
        }
        
        let secondChangeBlock = { [weak self] in
            if state == .active || state == .inactiveFull {
                self?.smallPlaceholder.textColor = state.placeholderColor
                self?.smallPlaceholder.alpha = 1.0
            } else if state == .disabled {
                self?.smallPlaceholder.textColor = state.placeholderColor
                self?.largePlaceholder.textColor = state.placeholderColor
            } else {
                self?.largePlaceholder.textColor = state.placeholderColor
                self?.largePlaceholder.alpha = 1.0
            }
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: firstChangeBlock) { _ in
                UIView.animate(withDuration: 0.25, animations: secondChangeBlock)
            }
            return
        }
        
        firstChangeBlock()
        secondChangeBlock()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NoteView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        state = .active
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if isUserInteractionEnabled {
            state = textView.text.isEmpty ? .inactiveEmpty : .inactiveFull
        }
    }
}

