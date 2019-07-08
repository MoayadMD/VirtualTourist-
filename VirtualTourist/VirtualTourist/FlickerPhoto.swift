//
//  FlickerPhoto.swift
//  VirtualTourist
//
//  Created by Moayad Makhdom on 05/11/1440 AH.
//  Copyright © 1440 Moayad Makhdom. All rights reserved.
//

import Foundation

struct FlickrPhotos: Codable {
    let page: Int
    let pages: Int
    let photo: [FlickrPhoto]
}

struct FlickrPhoto: Codable {
    let id: String
    let farm: Int
    let server: String
    let secret: String
}

extension FlickrPhoto {
    func url() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_z.jpg"
    }
}


