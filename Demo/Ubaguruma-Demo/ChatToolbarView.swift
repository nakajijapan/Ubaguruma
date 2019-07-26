//
//  ChatToolbarView.swift
//  Ubaguruma-Demo
//
//  Created by Daichi Nakajima on 2019/06/02.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit

protocol ChatToolbarViewDelegate: class {
    func chatToolbarViewDidTapImage(chatToolbarView: ChatToolbarView)
}

class ChatToolbarView: XIBView {
    
    enum Status {
        case selectingPhoto
        case `default`
    }
    var status: Status = .default

    @IBOutlet weak var textView: GrowingTextView! {
        didSet {
            textView.layer.cornerRadius = 8
            textView.layer.borderColor = UIColor.black.cgColor
            textView.layer.borderWidth = 0.5
            textView.delegate = self
        }
    }

    @IBAction func photoViewerButtonDidTap(_ sender: UIButton) {
        status = .selectingPhoto

        if textView.isFirstResponder {
            UIView.setAnimationsEnabled(false)
            textView.resignFirstResponder()
            UIView.setAnimationsEnabled(true)
        }
        
        delegate?.chatToolbarViewDidTapImage(chatToolbarView: self)
    }
    
    weak var delegate: ChatToolbarViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleKeyboardDidShowNotification(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)

    }
    
    deinit {
         NotificationCenter.default.removeObserver(self)
    }
}

extension ChatToolbarView: UITextViewDelegate {
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if status == .selectingPhoto {
            UIView.setAnimationsEnabled(false)
        }
        status = .default

        return true
    }
   
}

// MARK: - Notification

extension ChatToolbarView {
    @objc func handleKeyboardDidShowNotification(_ notification: Notification) {
        UIView.setAnimationsEnabled(true)
    }
}
