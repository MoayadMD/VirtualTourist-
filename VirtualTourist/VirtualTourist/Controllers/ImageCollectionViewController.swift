//
//  ImageCollectionViewController.swift
//  VirtualTourist
//
//  Created by Moayad Makhdom on 05/11/1440 AH.
//  Copyright © 1440 Moayad Makhdom. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class ImageCollectionViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataController: DataController!
    
    var pin: Pin!
    
    
    var state = CollectionViewState.loading {
        didSet {
            pin.photo = NSSet()
            
            switch state {
            case .loading:
                newCollectionButton.isEnabled = false
                
                let activityIndicator = UIActivityIndicatorView(style: .gray)
                activityIndicator.center = collectionView.center
                collectionView.backgroundView  = activityIndicator
                activityIndicator.startAnimating()
                
            case .populated(let resultPhotos):
                newCollectionButton.isEnabled = true
                collectionView.backgroundView = nil
                
                for resultPhoto in resultPhotos {
                    let photo = Photo(context: dataController.viewContext)
                    photo.url = resultPhoto.url()
                    pin.addToPhoto(photo)
                }
                try? dataController.viewContext.save()
                
            case .empty:
                newCollectionButton.isEnabled = true
                let frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
                let noDataLabel = UILabel(frame: frame)
                noDataLabel.text = NSLocalizedString("No image", comment: "")
                noDataLabel.textAlignment = .center
                collectionView.backgroundView  = noDataLabel
                
            case .error(let error):
                newCollectionButton.isEnabled = true
                
                let frame = CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
                let errorLabel = UILabel(frame: frame)
                errorLabel.text = error.localizedDescription
                errorLabel.textAlignment = .center
                collectionView.backgroundView  = errorLabel
            }
            
            self.collectionView.reloadData()
        }
    }
    
    let PhotosAlbumCellReuseIdentifier = "Cell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
        setupCollectionView()
    }
    
    private func setupMapView() {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: pin.coordinate, span: span)
        mapView.setRegion(region, animated: false)
        
        let currentMapRect = mapView.visibleMapRect
        
        var topPadding: CGFloat = 0
        if let safeAreaTopInset = UIApplication.shared.keyWindow?.safeAreaInsets.top,
            let navigationBarHeight = navigationController?.navigationBar.frame.height {
            topPadding = safeAreaTopInset + navigationBarHeight
        }
        
        let padding = UIEdgeInsets(top: topPadding, left: 0.0, bottom: 0.0, right: 0.0)
        mapView.setVisibleMapRect(currentMapRect, edgePadding: padding, animated: true)
        mapView.addAnnotation(pin)
        
        mapView.isUserInteractionEnabled = false
    }
    
   func setupCollectionView() {
        collectionView.dataSource = self as UICollectionViewDataSource
        collectionView.delegate = self as UICollectionViewDelegate
        collectionView.allowsMultipleSelection = false
        setupCollectionViewLayout()
        
        if (pin.photo == nil || (pin.photo != nil && pin.photo!.count == 0)) {
            loadPhotos()
        }
    }
    
    func setupCollectionViewLayout() {
        let itemsPerRow: CGFloat = 3
        let itemsPadding: CGFloat = 5.0
        
        let paddingSpace = itemsPadding * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        flowLayout.itemSize = CGSize(width: widthPerItem, height: widthPerItem)
        flowLayout.minimumLineSpacing = itemsPadding
        flowLayout.minimumInteritemSpacing = itemsPadding
        
        collectionView.contentInset = UIEdgeInsets(top: itemsPadding,
                                                   left: itemsPadding,
                                                   bottom: itemsPadding,
                                                   right: itemsPadding)
    }
    
    func loadPhotos() {
        state = .loading
        
        let loadTask = FlickrClient.shared.taskForGetPhotos(latitude: pin.latitude, longitude: pin.longitude, page: Int(pin.page)) { (data, error) in
            DispatchQueue.main.async {
                guard error == nil else {
                    self.state = .error(error!)
                    return
                }
                
                if let data = data {
                    self.pin.maxPage = Int16(data.pages)
                    let result = data.photo
                    
                    if (result.count > 0) {
                        self.state = .populated(result)
                    } else {
                        self.state = .empty
                    }
                }
            }
        }
        
        loadTask?.resume()
    }
    
    @IBAction func newCollection(_ sender: Any) {
        if (pin.photo != nil) {
            for photo in pin.photo! {
                pin.removeFromPhoto(photo as! Photo)
                dataController.viewContext.delete(photo as! Photo)
            }
        }
        
        pin.page += 1
        if (pin.page > pin.maxPage) {
            pin.page = 1
        }
        
        loadPhotos()
    }
    
    func storeImageData(_ imageData: Data, photo: Photo) {
        photo.image = imageData
        try? dataController.viewContext.save()
    }
    
    func removePhoto(_ index: Int) {
        let photo = pin.photo?.allObjects[index] as! Photo
        pin.removeFromPhoto(photo)
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
    }
    
}

