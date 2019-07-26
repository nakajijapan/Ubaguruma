//
//  UINavigationController+Extension.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit

enum InternalStructureViewType: Int {
    case toView = 900, screenShot = 910, overlay = 920, navigationBar = 930
}

public extension UINavigationController {
    var currentViewController: UIViewController? {
        return visibleViewController
    }
    
    func present(_ viewControllerToPresent: UIViewController, animated: Bool = true) {
        
        var visibleHeight: CGFloat? = nil
        if let contentsNavigationController = viewControllerToPresent as? ContentsNavigationController {
            visibleHeight = contentsNavigationController.visibleHeight
        }
        
        addChild(viewControllerToPresent)
        viewControllerToPresent.beginAppearanceTransition(true, animated: true)
        ModalAnimator.present(
            toView: viewControllerToPresent.view,
            fromView: view,
            visibleHeight: visibleHeight,
            animated: animated,
            completion: {
                viewControllerToPresent.endAppearanceTransition()
                viewControllerToPresent.didMove(toParent: self)
        })
        
    }
    
    func presentNavigationBar(_ viewControllerToPresent: NavigationBarViewController, contentsNavigationController: ContentsNavigationController) {
        addChild(viewControllerToPresent)
        viewControllerToPresent.beginAppearanceTransition(true, animated: true)
        
        let navigationViewControllerHeight: CGFloat = NavigationBarViewController.Constant.height
        let toView = viewControllerToPresent.view!
        let fromView = view!
        let visibleY = contentsNavigationController.view.frame.minY
        
        var toViewStartFrame = fromView.bounds.offsetBy(dx: 0, dy: fromView.bounds.size.height)
        toViewStartFrame.size.height = 0
        toView.frame = CGRect(
            x: 0,
            y: visibleY - navigationViewControllerHeight,
            width: fromView.frame.width,
            height: navigationViewControllerHeight)
        toView.tag = InternalStructureViewType.navigationBar.rawValue
        toView.alpha = 0
        fromView.addSubview(toView)
        viewControllerToPresent.endAppearanceTransition()
        viewControllerToPresent.didMove(toParent: self)
    }
    
    func dismissNavigationBar(completion: (() -> Void)? = nil) {
        
        weak var sourceViewController : UIViewController?
        
        for vc in children {
            if vc is NavigationBarViewController {
                sourceViewController = vc
            }
        }
        
        sourceViewController?.willMove(toParent: nil)
        willMove(toParent: nil)
        
        
        sourceViewController?.beginAppearanceTransition(false, animated: true)
        
        let targetView = view
        let modalView = view.viewWithTag(InternalStructureViewType.navigationBar.rawValue)
        
        UIView.animate(withDuration: 0.23, animations: { () -> Void in
            modalView?.alpha = 0
            modalView?.frame = CGRect(
                x: (targetView!.bounds.size.width - modalView!.frame.size.width) / 2.0,
                y: targetView!.bounds.size.height,
                width: modalView!.frame.width,
                height: modalView!.frame.height)
        }, completion: { _ -> Void in
            
            modalView?.removeFromSuperview()
            sourceViewController?.endAppearanceTransition()
            sourceViewController?.removeFromParent()
            completion?()
            
        })
        
    }
    
    func dismiss(completion: (() -> Void)? = nil) {
        
        weak var sourceViewController: UIViewController?
        weak var destinationViewController: UIViewController?
        
        for vc in children {
            if vc is ContentsNavigationController {
                sourceViewController = vc
            }
        }
        guard let visibleViewController = self.currentViewController, let index = children.firstIndex(of: visibleViewController) else {
            return
        }
        destinationViewController = children[index - 1]
        
        sourceViewController?.willMove(toParent: nil)
        willMove(toParent: nil)
        
        sourceViewController?.beginAppearanceTransition(false, animated: true)
        destinationViewController?.beginAppearanceTransition(true, animated: true)
        
        ModalAnimator.dismiss(
            fromView: view,
            presentingViewController: visibleViewController) {
                
                sourceViewController?.endAppearanceTransition()
                destinationViewController?.endAppearanceTransition()
                
                sourceViewController?.removeFromParent()
                
        }
    }
}
