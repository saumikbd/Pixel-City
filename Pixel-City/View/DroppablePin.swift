//
//  DroppablePin.swift
//  Pixel-City
//
//  Created by Sadman Sakib Saumik on 12/4/17.
//  Copyright © 2017 Sadman Sakib Saumik. All rights reserved.
//

import UIKit
import MapKit

class DroppablePin: NSObject, MKAnnotation{
    dynamic var coordinate: CLLocationCoordinate2D
    var identifier: String
    init(coordinate: CLLocationCoordinate2D, identifier: String) {
        self.coordinate = coordinate
        self.identifier = identifier
        super.init()
    }
}
