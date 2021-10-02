//
//  Constants.swift
//  GoogleMapsApplication
//
//  Created by Ahmad Berro on 01/10/2021.
//
import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
  
  let place: GooglePlace
  
  init(place: GooglePlace) {
    self.place = place
    super.init()
    
    position = place.coordinate
    icon = UIImage(named: "glow-marker")
    groundAnchor = CGPoint(x: 0.5, y: 1)
    appearAnimation = .pop
  }
}
