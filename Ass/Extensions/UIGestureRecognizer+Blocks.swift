//
//  UIGestureRecognizer+Blocks.swift
//  Ass
//
//  Created by Jakub Olejník on 24/11/2018.
//

import UIKit

private class ActionWrapper<T: UIGestureRecognizer> {
    let action: (T) -> Void
    
    init(action: @escaping (T) -> Void) {
        self.action = action
    }
    
    @objc
    func invokeAction(sender: UIGestureRecognizer) {
        action(sender as! T)
    }
}

private enum Keys {
    static var actionWrapper = UInt8(0)
}

protocol ActionWrapping: class {
    
}

extension ActionWrapping where Self: UIGestureRecognizer {
    private var actionWrapper: ActionWrapper<Self>? {
        get { return objc_getAssociatedObject(self, &Keys.actionWrapper) as? ActionWrapper<Self> }
        set { objc_setAssociatedObject(self, &Keys.actionWrapper, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    func onAction(_ action: @escaping (Self) -> Void) {
        if let oldWrapper = actionWrapper {
            removeTarget(oldWrapper, action: nil)
        }
        
        let newWrapper = ActionWrapper(action: action)
        actionWrapper = newWrapper
        addTarget(newWrapper, action: #selector(ActionWrapper.invokeAction(sender:)))
    }
}

extension UIGestureRecognizer: ActionWrapping { }
