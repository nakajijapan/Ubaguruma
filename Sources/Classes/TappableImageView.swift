//
//  TappableImageView.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/07/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit
import Photos

protocol TappableImageViewDelegate: class {
    func tappableImageViewDidTap(view: TappableImageView)
    func tappableImageViewDidLongPress(view: TappableImageView)
}

open class TappableImageView: UIView {
    
    open var isHighlightEnabled = true
    open var image: UIImage? {
        return imageView.image
    }
    open lazy var highlitedView: UIView = {
        let view = UIView(frame: self.bounds)
        view.backgroundColor = .black
        view.alpha = 0.3
        view.isHidden = true
        view.isUserInteractionEnabled = true
        return view
    }()
    weak var delegate: TappableImageViewDelegate?
    
    open var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    open func configureAppearanceNormal() {
        highlitedView.isHidden = true
    }
    
    open func configureAppearanceOnTouch() {
        highlitedView.isHidden = false
    }
    
    override open func awakeFromNib() {
        super.awakeFromNib()
        setupLayout()
        backgroundColor = .clear
        isUserInteractionEnabled = true
        setupGestures()
    }
    
    open func setupLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
        
        highlitedView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(highlitedView)
        
        NSLayoutConstraint.activate([
            highlitedView.topAnchor.constraint(equalTo: topAnchor),
            highlitedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            highlitedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            highlitedView.trailingAnchor.constraint(equalTo: trailingAnchor)
            ])
    }
    
    open func setupGestures() {
        let longPressForHightlightedGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressForHighlightedAction(_:)))
        longPressForHightlightedGestureRecognizer.delegate = self
        longPressForHightlightedGestureRecognizer.minimumPressDuration = 0.15
        addGestureRecognizer(longPressForHightlightedGestureRecognizer)
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(_:)))
        longPressGestureRecognizer.delegate = self
        addGestureRecognizer(longPressGestureRecognizer)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tapGestureRecognizer.cancelsTouchesInView = false
        tapGestureRecognizer.delegate = self
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func longPressAction(_ sender: UILongPressGestureRecognizer) {
        if isHighlightEnabled {
            delegate?.tappableImageViewDidLongPress(view: self)
        }
    }

    @objc private func longPressForHighlightedAction(_ sender: UILongPressGestureRecognizer) {
        
        switch sender.state {
        case .began:
            configureAppearanceOnTouch()
        case .ended:
            fallthrough
        case .cancelled, .failed:
            configureAppearanceNormal()
        default: break
        }
    }
    
    @objc private func tapAction(_ sender: UITapGestureRecognizer) {
        delegate?.tappableImageViewDidTap(view: self)
    }
    
    open func setImage(with image: UIImage?) {
        imageView.image = image
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension TappableImageView: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return isHighlightEnabled
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return isHighlightEnabled
    }
}
