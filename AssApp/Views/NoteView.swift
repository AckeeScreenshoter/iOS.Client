//
//  NoteView.swift
//  ass-app
//
//  Created by Vendula Švastalová on 10/06/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit

final class NoteView: UITextView {
    
    enum State {
        case active
        case inactive
    }
    
    private weak var placeholder: UILabel!
    
    private var state: State = .inactive {
        didSet {
            print("state is set")
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        font = .systemFont(ofSize: 16, weight: .regular)
        textColor = .black
        tintColor = .ackeePink
        
        textContainerInset = UIEdgeInsets(top: 36, left: 16, bottom: 16, right: 16)
        layer.cornerRadius = 6
        layer.borderColor = UIColor.ackeePink.cgColor
        layer.borderWidth = 2
        snp.makeConstraints { make in
            make.height.equalTo(92)
        }
        
        let placeholder = UILabel()
        placeholder.text = "My Note"
        placeholder.font = .systemFont(ofSize: 12, weight: .semibold)
        placeholder.textColor = .ackeePink
        addSubview(placeholder)
        placeholder.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        self.placeholder = placeholder
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

