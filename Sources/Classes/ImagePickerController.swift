//
//  ImagePickerController.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import Foundation
import UIKit
import Photos

public protocol ImagePickerControllerDelegate: class {
    func imagePickerDidSpreadToEntire(pickerController: ImagePickerController)
    func imagePickerDidSelectPhotoAsset(pickerController: ImagePickerController, asset: PHAsset)
    func imagePickerDidMovetToDefaultPosition(pickerController: ImagePickerController)
    func imagePickerCloseButtonWillTap(pickerController: ImagePickerController)
    func imagePickerCloseButtonDidTap(pickerController: ImagePickerController)

}

public final class ImagePickerController {
    public weak var delegate: ImagePickerControllerDelegate?
    
    public var contentsNavigationController: ContentsNavigationController!
    public var navigationBarViewController: NavigationBarViewController!
    public var containerController: UIViewController!
    private var parentNavigationController: UINavigationController!
    public var visibleHeight: CGFloat = 0 {
        didSet {
            contentsNavigationController.visibleHeight = visibleHeight
        }
    }
    
    struct Constant {
        struct AllowPhoto {
            static var title = L10n.localize("allowPhoto.allowPhoto.title")
            static var message = L10n.localize("allowPhoto.allowPhoto.message")
        }
    }
    
    public init(parentNavigationController: UINavigationController?) {
        let storyboard = UIStoryboard(name: "ContentsNavigationController", bundle: Bundle(for: ContentsNavigationController.self))
        guard let contentsNavigationController = storyboard.instantiateInitialViewController() as? ContentsNavigationController else {
            fatalError("Need the ContentsNavigationController")
        }
        
        let storyboard2 = UIStoryboard(name: "NavigationBarViewController", bundle: Bundle(for: NavigationBarViewController.self))
        guard let navigationBarViewController = storyboard2.instantiateInitialViewController() as? NavigationBarViewController else {
            fatalError("Need the NavigationBarViewController")
        }
        
        guard let topViewController = contentsNavigationController.topViewController as? ModalCollectionViewController else {
            fatalError("Need the NavigationBarViewController")
        }
        topViewController.delegate = self
        
        self.contentsNavigationController = contentsNavigationController
        self.contentsNavigationController.si_delegate = self
        self.contentsNavigationController.navigationBarViewController = navigationBarViewController
        self.navigationBarViewController = navigationBarViewController
        self.navigationBarViewController.delegate = self
        self.parentNavigationController = parentNavigationController
    }
    
    public func present(animated: Bool = true) {
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async { [weak self] in
                    if status == .authorized {
                        self?.presentControllers(containerController: self?.parentNavigationController, animated: animated)
                    } else if status == .denied {
                        
                        let alertController = UIAlertController(
                            title: Constant.AllowPhoto.title,
                            message: Constant.AllowPhoto.message,
                            preferredStyle: .alert
                        )
                        let settingsAction = UIAlertAction(title: L10n.localize("allowPhoto.allowPhoto.action.1"), style: .default, handler: { (_) -> Void in
                            guard let settingsURL = URL(string: UIApplication.openSettingsURLString ) else {
                                return
                            }
                            UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                        })
                        let closeAction: UIAlertAction = UIAlertAction(title: L10n.localize("allowPhoto.allowPhoto.action.cancel"), style: .cancel, handler: nil)
                        alertController.addAction(settingsAction)
                        alertController.addAction(closeAction)
                        self?.parentNavigationController?.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.presentControllers(containerController: self?.parentNavigationController, animated: animated)
            }
        }
        
    }
    
    private var isPresented: Bool {
        guard let parentNavitionController = contentsNavigationController.parentNavigationController else {
            return false
        }
        let viewControllers = parentNavitionController.viewControllers.map { $0 == contentsNavigationController }
        if viewControllers.count > 0 {
            return true
        }
        return false
    }
    
    private func presentControllers(containerController: UINavigationController?, animated: Bool = true) {
        contentsNavigationController.view.isHidden = false
        contentsNavigationController.parentNavigationController = containerController
        containerController?.present(contentsNavigationController, animated: animated)
        containerController?.presentNavigationBar(navigationBarViewController, contentsNavigationController: contentsNavigationController)

        parentNavigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    public func dismissIfPresented(completion: (() -> Void)? = nil) {
        if isPresented {
            dismiss(completion: completion)
        }
    }
    
    public func dismiss(completion: (() -> Void)? = nil) {
        guard let modalCollectionViewController = contentsNavigationController.topViewController as? ModalCollectionViewController else { return }
        modalCollectionViewController.scrollToTop()
        
        guard let parentNavigationController = contentsNavigationController.parentNavigationController else { return }
        parentNavigationController.dismissNavigationBar()
        parentNavigationController.dismiss { [weak self] in
            completion?()
            self?.contentsNavigationController.view.isHidden = false
        }
        
        parentNavigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension ImagePickerController: ContentsNavigationControllerDelegate {
    public func navigationControllerDidSpreadToEntire(navigationController: UINavigationController) {
        delegate?.imagePickerDidSpreadToEntire(pickerController: self)
    }
    
    public func navigationControllerDidMovetToDefaultPosition(navigationController: UINavigationController) {
        delegate?.imagePickerDidMovetToDefaultPosition(pickerController: self)
    }
}

extension ImagePickerController: PhotoCollectionViewControllerDelegate {
    func photoCollectionViewControllerDidSelectPhotoAsset(viewController: ModalCollectionViewController, asset: PHAsset) {
        guard let parentNavigationController = contentsNavigationController.parentNavigationController else { return }
        parentNavigationController.dismissNavigationBar()
        delegate?.imagePickerDidSelectPhotoAsset(pickerController: self, asset: asset)

        parentNavigationController.interactivePopGestureRecognizer?.isEnabled = true
    }
}

extension ImagePickerController: NavigationBarViewControllerDelegate {
    public func navigationBarViBarViewControllerCloseButtonDidTap(navigationBarViewController: NavigationBarViewController) {
        delegate?.imagePickerCloseButtonWillTap(pickerController: self)

        dismiss { [weak self] in
            guard let self = self else { return }
            self.delegate?.imagePickerCloseButtonDidTap(pickerController: self)
        }
    }
}
