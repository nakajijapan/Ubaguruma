//
//  CollectionViewCell.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit
import Photos

class CollectionViewCell: UICollectionViewCell {
    var representedAssetIdentifier: String!
    var requestImageID: PHImageRequestID?
    
    @IBOutlet weak var tappableImageView: TappableImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        for gs in gestureRecognizers ?? [] {
            gs.delegate = self
        }
    }
    
    func update(with asset: PHAsset) {
        representedAssetIdentifier = asset.localIdentifier
        requestImageID = PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: frame.width, height: frame.width), contentMode: .aspectFill, options: nil) { (image, _) in
            
            if self.representedAssetIdentifier == asset.localIdentifier {
                self.tappableImageView.setImage(with: image)

            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        tappableImageView.setImage(with: nil)

        if let imageID = requestImageID {
            PHImageManager.default().cancelImageRequest(imageID)
            requestImageID = nil
        }
    }
}

extension CollectionViewCell: UIGestureRecognizerDelegate {

    
}
