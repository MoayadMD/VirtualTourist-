//
//  ViewController.swift
//  VirtualTourist
//
//  Created by Moayad Makhdom on 05/11/1440 AH.
//  Copyright © 1440 Moayad Makhdom. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    var dataController: DataController!
     var pins: [Pin]?

    @IBOutlet weak var mapView: MKMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        longPressDetection()
        setupLastViewedMapRegion()
        loadAllPins()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showPhotos" {
            if let controller = segue.destination as? ImageCollectionViewController,
                let annotation = sender as? Pin {
                controller.pin = annotation
                controller.dataController = dataController
            }
        }
    }
    
    func longPressDetection() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(dropPin(_:)))
        mapView.addGestureRecognizer(longPress)
    }
    
    func setupLastViewedMapRegion() {
        if let lastViewedMapRegion = UserPreferences.lastViewedMapRegion {
            mapView.setRegion(lastViewedMapRegion, animated: true)
        }
    }
    
    @objc func dropPin(_ sender: UIGestureRecognizer) {
        if sender.state == .began {
            let point = sender.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = coordinate.latitude
            pin.longitude = coordinate.longitude
            try? dataController.viewContext.save()
            mapView.addAnnotation(pin)
        }
    }
    
    func loadAllPins() {
        let pinRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        
        if let result = try? dataController.viewContext.fetch(pinRequest) {
            pins = result
            mapView.addAnnotations(result)
        }
    }
    
    func updateLastViewedMapRegion(_ region: MKCoordinateRegion) {
        UserPreferences.lastViewedMapRegion = region
    }
    

}



