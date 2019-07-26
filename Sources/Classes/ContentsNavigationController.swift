//
//  ContentsNavigationController.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

@objc public protocol ContentsNavigationControllerDelegate {
    @objc optional func navigationControllerDidSpreadToEntire(navigationController: UINavigationController)
    @objc optional func navigationControllerDidMovetToDefaultPosition(navigationController: UINavigationController)
}

public class ContentsNavigationController: UINavigationController {
    
    public weak var si_delegate: ContentsNavigationControllerDelegate?
    public var parentNavigationController: UINavigationController?
    public var parentTabBarController: UITabBarController?
    public weak var navigationBarViewController: NavigationBarViewController?
    
    public static var upScrollingArea: CGFloat = 10
    public var minDeltaUpSwipe: CGFloat = 100
    public var minDeltaDownSwipe: CGFloat = 100
    
    public var dismissControllSwipeDown = false
    public var fullScreenSwipeUp = true
    public var cornerRadius: CGFloat = 0
    public var visibleHeight: CGFloat = 0
    
    private var previousLocation: CGPoint = .zero
    private var originalLocation: CGPoint = .zero

    public var isFullScreen = false
    public var isTransiting = false
    public var startYPosition: CGFloat = 0
    
    override public func viewDidLoad() {

        if cornerRadius > 0 {
            view.layer.cornerRadius = cornerRadius
            view.clipsToBounds = true
            ModalAnimator.cornerRadius = cornerRadius
        }
        
        navigationBar.isHidden = true

        // setting the default height
        let height = visibleHeight
        let y = UIScreen.main.bounds.height - height
        startYPosition = y
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        guard let overlayView = ModalAnimator.overlayView(fromView: view) else { return }
        overlayView.frame = view.bounds
    }
    
    public var startSize: CGSize = .zero
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSize = self.view.bounds.size
    }
    
    private func animateMoveToTopPosition(gestureRecognizer: UIPanGestureRecognizer, backgroundView: UIView) {
        let modalView = ModalAnimator.modalView(fromView: parentTargetView)
        
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                guard let strongSelf = self else { return }
                
                var frame = backgroundView.frame
                let statusBarHeight = self?.statusBarHeight ?? 0
                let navigationBarHeight = self?.navigationBarHeight ?? 0
                frame.origin.y = statusBarHeight + navigationBarHeight
                frame.size.height -= statusBarHeight
                frame.size.height = strongSelf.parentTargetView.bounds.height - navigationBarHeight - statusBarHeight
                strongSelf.view.frame = frame
                modalView?.layoutIfNeeded()
                
                strongSelf.navigationBarViewController?.moveToTop(contentFrame: frame)
                
            },
            completion: { _ -> Void in
                self.isFullScreen = true
                
                UIView.animate(
                    withDuration: 0.1,
                    delay: 0.0,
                    options: .curveLinear,
                    animations: {
                        // none
                },
                    completion: { [weak self] _ in
                        guard let strongslef = self else { return }
                        strongslef.si_delegate?.navigationControllerDidSpreadToEntire?(navigationController: strongslef)
                    }
                )
        })
    }
    
    
    
    private var navigationBarHeight: CGFloat {
        return navigationController?.navigationBar.bounds.height ?? 0
    }
    
    private var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    private func animateMoveToDefaultPosition(gestureRecognizer: UIPanGestureRecognizer, backgroundView: UIView) {
        UIView.animate(
            withDuration: 0.2,
            animations: { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                var frame = self!.parentTargetView.frame.offsetBy(dx: 0, dy: self!.startYPosition)
                frame.size.height -= frame.origin.y
                strongSelf.view.frame = frame
                strongSelf.view.layoutIfNeeded()
                strongSelf.navigationBarViewController?.moveToStart(contentFrame: frame)
                strongSelf.si_delegate?.navigationControllerDidMovetToDefaultPosition?(navigationController: strongSelf)
            },
            completion: { _ -> Void in
                self.isFullScreen = false
                
                
        })
    }
    
    
    private func animateBackToBeginPosition(gestureRecognizer: UIPanGestureRecognizer, backgroundView: UIView) {
        UIView.animate(
            withDuration: 0.6,
            delay: 0.0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.1,
            options: .curveLinear,
            animations: { [weak self] in
                guard let strongslef = self else { return }
                
                var frame = backgroundView.frame
                frame.origin.y = strongslef.originalLocation.y
                frame.size.height = strongslef.originalLocation.y
                strongslef.view.frame = frame
            },
            
            completion: { _ in
                gestureRecognizer.isEnabled = true
        })
    }
    
    private var prefiousOffsetForScrollView: CGPoint!
    public func updatePreviousLocation(scrollView: UIScrollView) {
        previousLocation = scrollView.panGestureRecognizer.location(in: parent!.view)
        prefiousOffsetForScrollView = scrollView.contentOffset
    }

    public func handleScrollView(scrollView: UIScrollView) {
        
        if isFullScreen {
            if scrollView.contentOffset.y <= 0 && !scrollView.isDecelerating {
                scrollView.contentOffset = .zero
            }
        }
        
        if prefiousOffsetForScrollView == nil {
            prefiousOffsetForScrollView = scrollView.contentOffset
        }

        let gestureRecognizer = scrollView.panGestureRecognizer
        let location = gestureRecognizer.location(in: parent!.view)
        let degreeY = location.y - previousLocation.y
        let fullScreenYPosition = navigationBarHeight + statusBarHeight
        
        switch gestureRecognizer.state {
        case .began:
            originalLocation = view.frame.origin
        case .changed:
            
            if view.frame.origin.y < statusBarHeight + navigationBarHeight && degreeY < 0 {
                
                var frame = view.frame
                frame.origin.y = fullScreenYPosition
                view.frame = frame
                
                var navigationBarViewControllerFrame = navigationBarViewController?.view.frame ?? .zero
                navigationBarViewControllerFrame.origin.y = 0
                navigationBarViewController?.view.frame = navigationBarViewControllerFrame
                break
            }
            
            if isFullScreen {
                if scrollView.contentOffset.y > 0 {
                    if view.frame.origin.y > fullScreenYPosition {
                        scrollView.contentOffset = .zero
                    } else {
                        break
                    }
                }
            } else {
                let locationInContentsNavigation = scrollView.panGestureRecognizer.location(in: view)
                if isTransiting {
                    scrollView.contentOffset = prefiousOffsetForScrollView
                } else if locationInContentsNavigation.y <= ContentsNavigationController.upScrollingArea {
                    isTransiting = true
                    scrollView.contentOffset = prefiousOffsetForScrollView
                } else if scrollView.contentOffset.y < 0 {
                    break
                } else if view.frame.height > startYPosition && degreeY > 0 {
                    scrollView.contentOffset = prefiousOffsetForScrollView
                } else {
                    break
                }
            }

            var frame = view.frame
            if frame.height < fullScreenYPosition {
                
                frame.origin.y = fullScreenYPosition

            } else {
                if isFullScreen {
                    frame.origin.y += degreeY
                } else {
                    frame.origin.y = frame.origin.y + (location.y - view.frame.origin.y - ContentsNavigationController.upScrollingArea)
                }
                frame.size.height = parent!.view.frame.height - frame.origin.y
            }
            
            view.frame = frame

            var navigationBarViewControllerFrame = navigationBarViewController?.view.frame ?? .zero
            navigationBarViewControllerFrame.origin.y = frame.origin.y - navigationBarViewControllerFrame.height
            navigationBarViewController?.view.frame = navigationBarViewControllerFrame
            
            let navigationBarAlpha = ModalAnimator.map(value: navigationBarViewControllerFrame.origin.y, inMin: 0, inMax: startYPosition * 0.7, outMin: 0, outMax: 1)
            if navigationBarAlpha <= 1 {
                navigationBarViewController?.view.alpha = 1.0 - navigationBarAlpha
            } else {
                navigationBarViewController?.view.alpha = 0
            }

        case .ended:
            if isFullScreen {
                if statusBarHeight + navigationBarHeight <= view.frame.origin.y && view.frame.origin.y < statusBarHeight + navigationBarHeight + 100 {
                    animateMoveToTopPosition(gestureRecognizer: gestureRecognizer, backgroundView: self.view)
                } else {
                    animateMoveToDefaultPosition(gestureRecognizer: gestureRecognizer, backgroundView: self.view)
                }
            } else {
                if originalLocation.y - view.frame.minY > minDeltaUpSwipe {
                    animateMoveToTopPosition(gestureRecognizer: gestureRecognizer, backgroundView: self.view)
                } else if view.frame.minY - originalLocation.y > minDeltaDownSwipe {
                    animateMoveToDefaultPosition(gestureRecognizer: gestureRecognizer, backgroundView: self.view)
                    
                } else {
                    animateMoveToDefaultPosition(gestureRecognizer: gestureRecognizer, backgroundView: self.view)
                }
            }
            isTransiting = false

        default:
            break
        }
        
        previousLocation = location
        
    }
    
    public var parentTargetView: UIView {
        if tabBarController != nil {
            return tabBarController!.view
        }
        
        return navigationController!.view
    }
    
    public var parentController: UIViewController {
        if let tabBarController = tabBarController {
            return tabBarController
        }
        
        return navigationController!
    }
    
}
