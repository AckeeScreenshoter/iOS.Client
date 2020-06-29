//
//  SplashScreen.swift
//  ass-app
//
//  Created by Vendula Švastalová on 29/06/2020.
//  Copyright © 2020 Vendula Švastalová. All rights reserved.
//

import UIKit
import Lottie

// Should be layouted to cover the whole screen
final class SplashScreen: UIView {
    private weak var animationView: AnimationView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        
        let animationView = AnimationView(name: "splash_animation")
        addSubview(animationView)
        animationView.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(0.78)
            make.centerX.equalToSuperview()
            make.size.equalTo(140)
        }
        animationView.contentMode = .scaleAspectFit
        animationView.animationSpeed = 0.7
        self.animationView = animationView
        
        let ackeeSignature = UIImageView(image: Asset.ackeeSignature.image)
        ackeeSignature.contentMode = .scaleAspectFit
        addSubview(ackeeSignature)
        ackeeSignature.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(50)
        }
    }
    
    func animateAfterLaunch(in parentView: UIView?) {
        guard let parentView = parentView else { return }
        parentView.addSubview(self)
        
        snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        animationView.play { finished in
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.alpha = 0.0
            }) { [weak self] _ in
                self?.removeFromSuperview()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("splash screen deinitialized")
    }
}
