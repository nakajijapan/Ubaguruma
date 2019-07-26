//
//  NavigationBarViewController.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit

@objc public protocol NavigationBarViewControllerDelegate {
    @objc optional func navigationBarViBarViewControllerCloseButtonDidTap(navigationBarViewController: NavigationBarViewController)
}

public final class NavigationBarViewController: UIViewController {
    public weak var delegate: NavigationBarViewControllerDelegate?

    public struct Constant {
        static let height: CGFloat = 88
    }
    
    @IBOutlet weak var closeButton: UIButton! {
        didSet {
            closeButton.setTitle(L10n.localize("closeButton"), for: .normal)
        }
    }
    
    @IBAction func closeButtonDidTap(_ sender: UIButton) {
        delegate?.navigationBarViBarViewControllerCloseButtonDidTap?(navigationBarViewController: self)
    }
    
    public func moveToStart(contentFrame: CGRect) {
        var navigationBarViewControllerFrame = view.frame
        navigationBarViewControllerFrame.origin.y = contentFrame.origin.y - navigationBarViewControllerFrame.height
        view.frame = navigationBarViewControllerFrame
        view.alpha = 0
    }
    
    public func moveToTop(contentFrame: CGRect) {
        var navigationBarViewControllerFrame = view.frame
        navigationBarViewControllerFrame.origin.y = contentFrame.origin.y - navigationBarViewControllerFrame.height
        view.frame = navigationBarViewControllerFrame
        view.alpha = 1
    }
}
