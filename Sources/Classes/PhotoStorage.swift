//
//  PhotoStorage.swift
//  Ubaguruma
//
//  Created by Daichi Nakajima on 2019/06/16.
//  Copyright © 2019 Daichi Nakajima. All rights reserved.
//

import UIKit
import Photos

class PhotoStorage {
    
    fileprivate(set) var albums: [PHAssetCollection] = []
    fileprivate(set) var selectedAlbumAssets = PHFetchResult<AnyObject>()
    var selectedPhotos: [PHAsset] = []
    var selectedAlbumNumber = 0
    let maximumNumberOfSelection: Int
    
    let albumTypes: [PHAssetCollectionSubtype] = [
        .albumRegular,
        .albumSyncedEvent,
        .albumSyncedFaces,
        .albumSyncedAlbum,
        .albumImported,
        .albumMyPhotoStream,
        .albumCloudShared,
    ]
    
    let smartAlbumTypes: [PHAssetCollectionSubtype] = [
        .smartAlbumGeneric,
        .smartAlbumPanoramas,
        .smartAlbumVideos,
        .smartAlbumFavorites,
        .smartAlbumTimelapses,
        .smartAlbumRecentlyAdded,
        .smartAlbumBursts,
        .smartAlbumSlomoVideos,
    ]
    
    init(maximumNumberOfSelection maximumNumber: Int) {
        self.maximumNumberOfSelection = maximumNumber
        
        let cameraroll = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: nil)
        cameraroll.enumerateObjects({ (collection, _, _) in
            self.albums.append(collection)
            
            // カメラロールを初期アルバムにする
            //self.selectedAlbumAssets = PHAsset.fetchAssets(in: collection, options: PHFetchOptions.imageOnly()) as! PHFetchResult<AnyObject>
            self.selectedAlbumAssets = PHAsset.fetchAssets(in: collection, options: PHFetchOptions.imageOnly()) as! PHFetchResult<AnyObject>
        })
        
        // カメラロール以外のアルバムを取得
        let appendAlbum = { (collection: AnyObject, _: Int, _: UnsafeMutablePointer<ObjCBool>) in
            let contents = PHAsset.fetchAssets(in: collection as! PHAssetCollection, options: PHFetchOptions.imageOnly())
            if contents.count > 0 {
                self.albums.append(collection as! PHAssetCollection)
            }
        }
        
        smartAlbumTypes.forEach {
            PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: $0, options: nil)
                .enumerateObjects(appendAlbum)
        }
        
        albumTypes.forEach {
            PHAssetCollection.fetchAssetCollections(with: .album, subtype: $0, options: nil)
                .enumerateObjects(appendAlbum)
        }
        
    }
}

extension PHFetchOptions {
    class func imageOnly() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return fetchOptions
    }
}
