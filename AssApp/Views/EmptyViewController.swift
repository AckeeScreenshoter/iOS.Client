//
//  EmptyViewController.swift
//  ass-app
//
//  Created by Vendula Švastalová on 22/05/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import SnapKit
import AssCore

/// View that only directs the user to the project description
final class EmptyViewController: UIViewController {
    
    override func loadView() {
        super.loadView()
        
        // checked background
        let background = Asset.background.image.view
        view.addSubview(background)
        background.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let centerLabel = UILabel()
        centerLabel.textColor = UIColor.text
        centerLabel.numberOfLines = 0
        centerLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        centerLabel.text = """
            Just take a screenshot
            or record a screen in any app.
            It will automaticaly appear here.
        """
        
        centerLabel.textAlignment = .center
        view.addSubview(centerLabel)
        centerLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(52)
            make.centerY.equalToSuperview()
        }
        
        let gitlabLink = UIButton()
        gitlabLink.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        gitlabLink.titleLabel?.textAlignment = .center
        gitlabLink.titleLabel?.numberOfLines = 0
        gitlabLink.titleLabel?.textColor = UIColor.text
        gitlabLink.addTarget(self, action: #selector(openLink), for: .touchUpInside)
        
        let readmeText = """
            Go to GitLab Readme to find out
            more about ASS.
        """
        
        let attributedString = NSMutableAttributedString(string: readmeText)
        
        // Pink coloured text
        let gitlabRange = readmeText.range(of: "GitLab Readme")!
        
        attributedString.setAttributes([
            .foregroundColor: UIColor.ackeePink
        ], range: NSRange(gitlabRange, in: readmeText))
        
        gitlabLink.setAttributedTitle(attributedString, for: [])
        view.addSubview(gitlabLink)
        gitlabLink.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(60)
            make.bottom.equalToSuperview().inset(48)
        }
    }
    
    /// Opens ASS project Readme in GitLab
    ///
    /// https://gitlab.ack.ee/iOS/ass/-/blob/master/README.md
    @objc
    private func openLink() {
        let url = URL(string: "https://gitlab.ack.ee/iOS/ass/-/blob/master/README.md")!
        UIApplication.shared.open(url)
    }
}
