//
//  Pin.swift
//  VirtualTourist
//
//  Created by Moayad Makhdom on 05/11/1440 AH.
//  Copyright © 1440 Moayad Makhdom. All rights reserved.
//

import Foundation
import MapKit

extension Pin: MKAnnotation {
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
