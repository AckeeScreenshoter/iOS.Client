//
//  EmptyView.swift
//  ass-app
//
//  Created by Vendula Švastalová on 22/05/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import SnapKit

final class EmptyView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let background = Asset.background.image.view
        addSubview(background)
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let centerLabel = UILabel()
        centerLabel.numberOfLines = 0
        centerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        centerLabel.text = """
            Just take a screenshot
            or record a screen in any app.
            It will automaticaly appear here.
        """
        
        centerLabel.textAlignment = .center
        addSubview(centerLabel)
        centerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(52)
            make.centerY.equalToSuperview()
        }
        
        let gitlabLink = UILabel()
        gitlabLink.isUserInteractionEnabled = true
        gitlabLink.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        gitlabLink.textAlignment = .center
        
        let readmeText = """
            Go to GitLab Readme to find out
            more about ASS.
        """
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(openReadme))
        gitlabLink.addGestureRecognizer(tap)
        
        let attributedString = NSMutableAttributedString(string: readmeText)
        
        let gitlabRange = readmeText.range(of: "GitLab Readme")!
        
        attributedString.setAttributes([
            .foregroundColor: UIColor.ackeePink
        ], range: NSRange(gitlabRange, in: readmeText))
        
        gitlabLink.attributedText = attributedString
        addSubview(gitlabLink)
        gitlabLink.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(60)
            make.bottom.equalToSuperview().inset(48)
        }
    }
    
    @objc
    private func openReadme() {
        let url = URL(string: "https://gitlab.ack.ee/iOS/ass/-/blob/master/README.md")!
        UIApplication.shared.open(url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
