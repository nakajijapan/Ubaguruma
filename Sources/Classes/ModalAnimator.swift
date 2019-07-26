//
//  ModalAnimator.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit

public class ModalAnimator {
    static var cornerRadius: CGFloat = 0
    
    public class func present(
        toView: UIView,
        fromView: UIView,
        visibleHeight: CGFloat?,
        animated: Bool,
        completion: @escaping () -> Void) {

        var toViewStartFrame = fromView.bounds.offsetBy(dx: 0, dy: fromView.bounds.size.height)
        toViewStartFrame.size.height = 0
        toView.frame = toViewStartFrame
        toView.tag = InternalStructureViewType.toView.rawValue
        fromView.addSubview(toView)
        
        if animated {
            UIView.animate(
                withDuration: 0.25,
                animations: { () -> Void in
                    toView.frame = self.visibleFrameForContainerView(fromViewFrame: fromView.bounds,
                                                                 visibleHeight: visibleHeight)
                    toView.alpha = 1.0
            }, completion: { _ -> Void in
                completion()
            })
        } else {
            toView.frame = self.visibleFrameForContainerView(fromViewFrame: fromView.bounds,
                                                             visibleHeight: visibleHeight)
            completion()
        }
    }

    public class func visibleFrameForContainerView(fromViewFrame: CGRect,
                                                   visibleHeight: CGFloat?) -> CGRect {
        var toViewFrame: CGRect = .zero
        if let visibleHeight = visibleHeight {
            toViewFrame = fromViewFrame.offsetBy(dx: 0, dy: fromViewFrame.size.height - visibleHeight)
            toViewFrame.size.height = visibleHeight
        } else {
            toViewFrame = fromViewFrame.offsetBy(dx: 0, dy: fromViewFrame.size.height / 2.0)
            toViewFrame.size.height -= toViewFrame.origin.y
        }
        return toViewFrame
    }
    
    public class func overlayView(fromView: UIView) -> UIView? {
        return fromView.viewWithTag(InternalStructureViewType.overlay.rawValue)
    }
    
    public class func modalView(fromView: UIView) -> UIView? {
        return fromView.viewWithTag(InternalStructureViewType.toView.rawValue)
    }
    
    public class func screenShotView(overlayView: UIView) -> UIImageView? {
        let tag = InternalStructureViewType.screenShot.rawValue
        guard let view = overlayView.viewWithTag(tag) as? UIImageView else {
            return nil
        }
        return view
    }
    
    public class func dismiss(fromView: UIView, presentingViewController: UIViewController?, completion: @escaping () -> Void) {
        
        let targetView = fromView
        let modalView = ModalAnimator.modalView(fromView: fromView)
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
            modalView?.frame = CGRect(
                x: (targetView.bounds.size.width - modalView!.frame.size.width) / 2.0,
                y: targetView.bounds.size.height,
                width: modalView!.frame.width,
                height: modalView!.frame.height)
        }, completion: { _ -> Void in
            modalView?.removeFromSuperview()
            completion()

        })

    }
    // MARK: - Private
    
    class func map(value: CGFloat, inMin: CGFloat, inMax: CGFloat, outMin: CGFloat, outMax: CGFloat) -> CGFloat {
        let inRatio = value / (inMax - inMin)
        let outRatio = (outMax - outMin) * inRatio + outMin
        
        return outRatio
    }
}
