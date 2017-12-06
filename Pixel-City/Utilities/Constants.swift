//
//  Constants.swift
//  Pixel-City
//
//  Created by Sadman Sakib Saumik on 12/2/17.
//  Copyright © 2017 Sadman Sakib Saumik. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ Success:Bool)->()

let API_KEY = "ae02c518a2bce373bd32d02144a81e2a"
func getApiUrl(apiKey: String, annotation: DroppablePin, perPage:Int)-> String{
    
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=mi&per_page=\(perPage)&page=1&format=json&nojsoncallback=1"
    
}
