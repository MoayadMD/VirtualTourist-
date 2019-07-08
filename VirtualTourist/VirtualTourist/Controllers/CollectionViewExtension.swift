//
//  CollectionViewExtension.swift
//  VirtualTourist
//
//  Created by Moayad Makhdom on 05/11/1440 AH.
//  Copyright © 1440 Moayad Makhdom. All rights reserved.
//

import Foundation
import UIKit


extension ImageCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        let numberOfItemsInSection: Int = pin.photo?.count ?? 0
        return numberOfItemsInSection
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotosAlbumCellReuseIdentifier, for: indexPath)
        let activityIndicator = UIActivityIndicatorView(style: .gray)
        activityIndicator.center = collectionView.center
        cell.backgroundView = activityIndicator
        activityIndicator.startAnimating()
        
        return cell
    }
    
}

extension ImageCollectionViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_:))))
        
        if let photo = pin.photo?.allObjects[indexPath.row] as? Photo {
            if let imageData = photo.image {
                let image = UIImage(data: imageData)
                cell.backgroundView = UIImageView(image: image)
                
            } else {
                let imageView = UIImageView(image: UIImage(named: "placeholder.png"))
                cell.backgroundView = imageView
                if let urlString = photo.url {
                    let imageURL = URL(string: urlString)!
                    
                    URLSession.shared.dataTask(with: imageURL) { (data, _, _) in
                        if let data = data {
                            let image = UIImage(data: data)
                            self.storeImageData(data, photo: photo)
                            
                            DispatchQueue.main.async {
                                imageView.image = image
                            }
                        }
                        }.resume()
                }
            }
        }
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self.collectionView)
        let indexPath = self.collectionView.indexPathForItem(at: location)!
        let index = (indexPath.section * 3) + indexPath.row
        self.removePhoto(index)
        self.collectionView.deleteItems(at: [indexPath])
    }
}

enum CollectionViewState {
    case loading
    case populated([FlickrPhoto])
    case empty
    case error(NSError)
}
