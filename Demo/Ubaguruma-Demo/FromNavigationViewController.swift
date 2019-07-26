//
//  FromNavigationViewController.swift
//  Ubaguruma-Demo
//
//  Created by Daichi Nakajima on 2019/05/26.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit
import Ubaguruma
import Photos

class FromNavigationViewController: UIViewController {
    
    @IBOutlet weak var chatToolbarView: ChatToolbarView! {
        didSet {
            chatToolbarView.delegate = self
        }
    }
    @IBOutlet weak var chatToolbarViewBottomConstraint: NSLayoutConstraint!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var imagePickerController: Ubaguruma.ImagePickerController?
    var items: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillHideNotification(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardWillShowNotification(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidHideNotification(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidShowNotification(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)

        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Button Actions
    @objc func handleTapGesture(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
        
        hideKeyboard()
        imagePickerController?.dismiss()
    }
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.rowHeight = 150
            tableView.estimatedRowHeight = UITableView.automaticDimension
        }
    }
    
}

// MARK: - Notification

extension FromNavigationViewController {
    
    func hideKeyboard() {
        chatToolbarView.status = .default
        chatToolbarViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func handleKeyboardWillHideNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let keyboardCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let animationCurve = UIView.AnimationOptions(rawValue: keyboardCurve << 16)
     
        if chatToolbarView.status == .selectingPhoto {
        } else {
            imagePickerController?.dismissIfPresented()
            chatToolbarViewBottomConstraint.constant = 0
            UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)

        }
        
    }
    
    @objc func handleKeyboardDidHideNotification(_ notification: Notification) {
    }
    
    @objc func handleKeyboardWillShowNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        let duration: TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let keyboardCurve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let animationCurve = UIView.AnimationOptions(rawValue: keyboardCurve << 16)

        let safeAreaInsetBottom = view.safeAreaInsets.bottom
        chatToolbarViewBottomConstraint.constant = keyboardFrame.size.height - safeAreaInsetBottom
        if chatToolbarView.status == .selectingPhoto {
            self.view.layoutIfNeeded()
            imagePickerController?.dismiss()
        } else {
            UIView.animate(withDuration: duration, delay: 0.0, options: animationCurve, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
        
    @objc func handleKeyboardDidShowNotification(_ notification: Notification) {
    }
}

// MARK: - ChatToolbarViewDelegate

extension FromNavigationViewController: ChatToolbarViewDelegate {
    func chatToolbarViewDidTapImage(chatToolbarView: ChatToolbarView) {

        if imagePickerController == nil {
            imagePickerController = Ubaguruma.ImagePickerController()
        }
        imagePickerController?.delegate = self
        

        let animated: Bool
        if chatToolbarViewBottomConstraint.constant == 0 {
            let safeAreaInsetBottom = view.safeAreaInsets.bottom
            let defaultKeyboardMinY: CGFloat = 346
            chatToolbarViewBottomConstraint.constant = defaultKeyboardMinY - safeAreaInsetBottom
            imagePickerController?.visibleHeight = defaultKeyboardMinY

            UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
                self.view.layoutIfNeeded()
            })
            
            animated = true
        } else {
            let safeAreaInsetBottom = view.safeAreaInsets.bottom
            let height = chatToolbarViewBottomConstraint.constant
            imagePickerController?.visibleHeight = height + safeAreaInsetBottom

            animated = false
        }
        imagePickerController?.present(containerController: navigationController, animated: animated)

    }
}

// MARK: - Ubaguruma.ImagePickerControllerDelegate

extension FromNavigationViewController: Ubaguruma.ImagePickerControllerDelegate {
    
    func imagePickerCloseButtonDidTap(pickerController: ImagePickerController) {
        
    }
    func imagePickerCloseButtonWillTap(pickerController: ImagePickerController) {

        chatToolbarViewBottomConstraint.constant = 0
        UIView.animate(withDuration: 0.25, delay: 0.0, options: [], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func imagePickerDidSpreadToEntire(pickerController: ImagePickerController) {
    }
    
    func imagePickerDidSelectPhotoAsset(pickerController: ImagePickerController, asset: PHAsset) {
        hideKeyboard()
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
            self.items.append(image!)
            let indexPath = IndexPath(row: self.items.count - 1, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)

        }
    }
    
    func imagePickerDidMovetToDefaultPosition(pickerController: ImagePickerController) {
    }
    
}
extension FromNavigationViewController: UIDropInteractionDelegate {
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnter session: UIDropSession) {
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidEnd session: UIDropSession) {
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        hideKeyboard()
        imagePickerController?.dismissIfPresented()
        
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            let images = imageItems as! [UIImage]
            self.items.append(images.first!)
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.insertRows(at: [indexPath], with: UITableView.RowAnimation.fade)
            print("\(#function), \(#line) images: \(images.first!) size: \(images.first!.size)")
        }
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: UIDropOperation.copy)
    }

}


extension FromNavigationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ImageTableViewCell", for: indexPath) as? ImageTableViewCell else {
            fatalError("Invalid Cell")
        }

        let image = items[indexPath.row]
        cell.contentImageView?.image = image
        
        return cell
    }
    
    
}

extension FromNavigationViewController: UITableViewDelegate {

}
