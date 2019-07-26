//
//  ModalCollectionViewController.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit
import Photos

protocol PhotoCollectionViewControllerDelegate: class {
    func photoCollectionViewControllerDidSelectPhotoAsset(viewController: ModalCollectionViewController, asset: PHAsset)
}

class ModalCollectionViewController: UIViewController {
    weak var delegate: PhotoCollectionViewControllerDelegate?
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dragDelegate = self
            collectionView.dragInteractionEnabled = true
            collectionView.bouncesZoom = false
            collectionView.bounces = true
            collectionView.alwaysBounceVertical = true
            collectionView.alwaysBounceHorizontal = false
        }
    }
    public var photoStorage: PhotoStorage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let nc = navigationController as? ContentsNavigationController {
            nc.fullScreenSwipeUp = true
            nc.dismissControllSwipeDown = true
        }
        
        view.backgroundColor = .white
        
        photoStorage = PhotoStorage(maximumNumberOfSelection: 0)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    // MARK: - Button Actions
    
    @IBAction func closeButtonDidTap(button: UIBarButtonItem) {
        
        guard let currentController = navigationController as? ContentsNavigationController else {
            fatalError("Need the ContentsNavigationController")
        }
        
        if let parentController = currentController.parentNavigationController {
            parentController.dismiss(completion: nil)
        } else if let parentController = currentController.parentTabBarController {
            parentController.dismiss(completion: nil)
        }
    }
    
    var previousOffset: CGPoint = .zero
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
      
        guard let contentsNavigationController = navigationController as? ContentsNavigationController else {
            return
        }
        let location = scrollView.panGestureRecognizer.location(in: navigationController!.view)
        if contentsNavigationController.isFullScreen {
            contentsNavigationController.handleScrollView(scrollView: scrollView)
        } else {
            
            if location.y < ContentsNavigationController.upScrollingArea {
                collectionView.contentOffset = previousOffset
                contentsNavigationController.handleScrollView(scrollView: scrollView)
                return
            } else {
                contentsNavigationController.handleScrollView(scrollView: scrollView)
            }
            
        }
        previousOffset = collectionView.contentOffset
        contentsNavigationController.updatePreviousLocation(scrollView: scrollView)
        
        
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if let contentsNavigationController = navigationController as? ContentsNavigationController {
            contentsNavigationController.handleScrollView(scrollView: scrollView)
        }
    }
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if let contentsNavigationController = navigationController as? ContentsNavigationController {
            contentsNavigationController.handleScrollView(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
    }
}
extension ModalCollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoStorage.selectedAlbumAssets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            fatalError("invalid cell")
        }
        cell.update(with: photoStorage.selectedAlbumAssets[indexPath.item] as! PHAsset)
        
        return cell
    }
}

extension ModalCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let currentController = navigationController as? ContentsNavigationController else {
            fatalError("Need the ContentsNavigationController")
        }
        
        if let parentController = currentController.parentNavigationController {
            parentController.dismiss(completion: nil)
        } else if let parentController = currentController.parentTabBarController {
            parentController.dismiss(completion: nil)
        }
        
        scrollToTop()
        
        let asset = photoStorage.selectedAlbumAssets[indexPath.item] as! PHAsset
        delegate?.photoCollectionViewControllerDidSelectPhotoAsset(viewController: self, asset: asset)
    }
}

extension ModalCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = (UIScreen.main.bounds.width - 4) / 3
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension ModalCollectionViewController {
   
    func scrollToTop() {
        guard let collectionView = collectionView else { return }
        collectionView.contentOffset = .zero
    }
}

extension ModalCollectionViewController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        guard let asset = photoStorage.selectedAlbumAssets[indexPath.item] as? PHAsset else { return [] }
        var thumbnailImage: UIImage?

        let requestOptions = PHImageRequestOptions()
        requestOptions.version = .current
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFill, options: requestOptions) { (image, _) in
            thumbnailImage = image
        }

        var imageItemProvider: NSItemProvider
        imageItemProvider = NSItemProvider(object: thumbnailImage ?? UIImage())

        let dragItem = UIDragItem(itemProvider: imageItemProvider)
        return [dragItem]
    }
    

}
