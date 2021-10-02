//
//  Constants.swift
//  GoogleMapsApplication
//
//  Created by Ahmad Berro on 01/10/2021.
//
import UIKit
import GoogleMaps
import GoogleMobileAds

class MapViewController: UIViewController, UISearchBarDelegate {
  
  // MARK: - Initializers
  lazy   var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 20))
  private let myArray: NSArray = ["Grand Kadri Hotel By Cristal Lebanon","Germanos - Pastry","Malak el Tawook","Z Burger House","Collège Oriental","VERO MODA"]
  private var myTableView: UITableView!
  var searchedTypes = ["restaurant"]
  var showNearPlaces = true
  var arrayPolyline = [GMSPolyline]()
  var selectedRought:String!
  private let locationManager = CLLocationManager()
  private let dataProvider = GoogleDataProvider()
  private let searchRadius: Double = 10000
  var time = Double()
  var sourceLocation = CLLocationCoordinate2D()
  var destinationLocation = CLLocationCoordinate2D()
  
  // MARK: - Outlets
  @IBOutlet private weak var mapView: GMSMapView!
  @IBOutlet weak var nearButton: UIButton!
  @IBOutlet private weak var mapCenterPinImage: UIImageView!
  @IBOutlet private weak var pinImageVerticalConstraint: NSLayoutConstraint!
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var showDirectionButton: UIButton!
  @IBOutlet weak var timeLabel: UILabel!
  @IBOutlet weak var distanceTimeLabel: UILabel!
  @IBOutlet weak var detailsImage: UIImageView!
  @IBOutlet weak var detailsView: UIView!
  
  
  
  // MARK: - Setup View
  override func viewDidLoad() {
    super.viewDidLoad()
    AppDelegate().requestAppOpenAd()
    
    searchBar.placeholder = "Search"
    searchBar.backgroundColor = .white
    searchBar.delegate = self
    let leftNavBarButton = UIBarButtonItem(customView:searchBar)
    self.navigationItem.leftBarButtonItem = leftNavBarButton
    
    locationManager.delegate = self
    mapView.delegate = self
    locationManager.requestWhenInUseAuthorization()
    self.mapView?.isMyLocationEnabled = true
    self.locationManager.startUpdatingLocation()
    
    addDefaultMarkers()
    
    let buttonHeight = self.nearButton.intrinsicContentSize.height
    self.mapView.padding = UIEdgeInsets(top: self.view.safeAreaInsets.top, left: 0, bottom: buttonHeight + 30, right: 0)
    detailsView.isHidden = true
    NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardAppears), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
  }
  
  
  // MARK: - Setup Control Functions
  @objc func keyboardAppears() -> Void {
    searchBar.resignFirstResponder()
    if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
      cancelButton.isEnabled = true
    }
  }
  func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
    searchBar.setShowsCancelButton(true, animated: true)
    let barHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
    let displayWidth: CGFloat = self.view.frame.width
    let displayHeight: CGFloat = self.view.frame.height
    
   
    myTableView = UITableView(frame: CGRect(x: 0, y: barHeight, width: displayWidth, height: displayHeight - barHeight))
    myTableView.register(UITableViewCell.self, forCellReuseIdentifier: "TypeCell")
    myTableView.dataSource = self
    myTableView.delegate = self
    myTableView.backgroundColor = .white
    self.view.addSubview(myTableView)
    searchBar.resignFirstResponder()
    return true
  }
  func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
    searchBar.setShowsCancelButton(false, animated: true)
    searchBar.resignFirstResponder()
    myTableView.removeFromSuperview()
  }
  func addDefaultMarkers() {
    
    let GrandKadri = GMSMarker(
      position: Constants.GrandKadriHotelByCristalLebanonLoc)
    GrandKadri.title = "Grand Kadri Hotel By Cristal Lebanon"
    GrandKadri.icon = UIImage(named: "glow-marker")
    GrandKadri.map = mapView
    
    let Germanos = GMSMarker(
      position:  Constants.GermanosPastryLoc)
    Germanos.title = "Germanos - Pastry"
    Germanos.icon = UIImage(named: "glow-marker")
    Germanos.map = mapView
    
    let MalakElTawok = GMSMarker(
      position:  Constants.MalakElTawookLoc)
    MalakElTawok.title = "Malak el Tawook"
    MalakElTawok.icon = UIImage(named: "glow-marker")
    MalakElTawok.map = mapView
    
    let ZBurgerHous = GMSMarker(
      position:  Constants.ZBurgerHouseLoc)
    ZBurgerHous.title = "Z Burger House"
    ZBurgerHous.icon = UIImage(named: "glow-marker")
    ZBurgerHous.map = mapView
    
    let CollegeOrientel = GMSMarker(
      position:  Constants.CollegeOrientalLoc)
    CollegeOrientel.title = "Collège Oriental"
    CollegeOrientel.icon = UIImage(named: "glow-marker")
    CollegeOrientel.map = mapView
    
    let VEROMODa = GMSMarker(
      position:  Constants.VEROMODALoc)
    VEROMODa.title = "VERO MODA"
    VEROMODa.icon = UIImage(named: "glow-marker")
    VEROMODa.map = mapView
  }
  
  // MARK: - API Calls
  private func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    mapView.clear()
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:searchRadius, types: searchedTypes) { places in
      places.forEach {
        let marker = PlaceMarker(place: $0)
        marker.map = self.mapView
      }
    }
  }
  
  private func fetchDummyData(coordinate: CLLocationCoordinate2D, name: String) {
    mapView.clear()
    dataProvider.fetchDummyPlacesNearCoordinate(coordinate,name: name, radius:2, types: searchedTypes) { places in
      places.forEach {
        let marker = PlaceMarker(place: $0)
        marker.map = self.mapView
      }
    }
  }
  
  func fetchRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
    
    let session = URLSession.shared
    let url = URL(string:"https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=\(googleApiKey)")!
    
    let task = session.dataTask(with: url, completionHandler: {
      (data, response, error) in
      
      guard error == nil else {
        print(error!.localizedDescription)
        return
      }
      
      guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any], let jsonResponse = jsonResult else {
        print("error in JSONSerialization")
        return
      }
      
      guard let routes = jsonResponse["routes"] as? [Any] else {
        return
      }
      
      guard let route = routes[0] as? [String: Any] else {
        return
      }
      
      guard let overview_polyline = route["overview_polyline"] as? [String: Any] else {
        return
      }
      
      guard let polyLineString = overview_polyline["points"] as? String else {
        return
      }
      
      //Call this method to draw path on map
      self.drawPath(from: polyLineString)
    })
    task.resume()
  }
  
  func drawPath(from polyStr: String){
    let path = GMSPath(fromEncodedPath: polyStr)
    let polyline = GMSPolyline(path: path)
    polyline.strokeColor = .orange
    polyline.strokeWidth = 3.0
    polyline.map = mapView // Google MapView
  }
  
  
  // MARK: - Action Outlets
  
  @IBAction func nearResturantsAction(_ sender: Any) {
    detailsView.isHidden = true
    fetchNearbyPlaces(coordinate: mapView.camera.target)
  }
  
  
  @IBAction func showDirectionAction(_ sender: Any) {
    if showNearPlaces {
      fetchNearbyPlaces(coordinate: mapView.camera.target)
    }
    fetchRoute(from: CLLocationCoordinate2D(latitude: sourceLocation.latitude, longitude: sourceLocation.longitude), to: CLLocationCoordinate2D(latitude: destinationLocation.latitude, longitude:  destinationLocation.longitude))
    showNearPlaces = true
  }
  
}
// MARK: Table View Delegate
extension MapViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if myArray[indexPath.row] as! String == Constants.GrandKadri {
      fetchDummyData(coordinate: Constants.GrandKadriHotelByCristalLebanonLoc, name: Constants.GrandKadri)
      let camera = GMSCameraPosition.camera(withLatitude: Constants.GrandKadriHotelByCristalLebanonLoc.latitude, longitude: Constants.GrandKadriHotelByCristalLebanonLoc.longitude, zoom: 12.0)
      self.mapView?.animate(to: camera)
    }
    if myArray[indexPath.row] as! String == Constants.Germanos {
      fetchDummyData(coordinate: Constants.GermanosPastryLoc, name: Constants.Germanos)
      let camera = GMSCameraPosition.camera(withLatitude: Constants.GermanosPastryLoc.latitude, longitude: Constants.GermanosPastryLoc.longitude, zoom: 12.0)
      self.mapView?.animate(to: camera)
    }
    if myArray[indexPath.row] as! String == Constants.MalakElTawok {
      fetchDummyData(coordinate: Constants.MalakElTawookLoc, name: Constants.MalakElTawok)
      let camera = GMSCameraPosition.camera(withLatitude: Constants.MalakElTawookLoc.latitude, longitude: Constants.MalakElTawookLoc.longitude, zoom: 12.0)
      self.mapView?.animate(to: camera)
    }
    if myArray[indexPath.row] as! String == Constants.ZBurgerHous {
      fetchDummyData(coordinate: Constants.ZBurgerHouseLoc, name: Constants.ZBurgerHous)
      let camera = GMSCameraPosition.camera(withLatitude: Constants.ZBurgerHouseLoc.latitude, longitude: Constants.ZBurgerHouseLoc.longitude, zoom: 12.0)
      self.mapView?.animate(to: camera)
    }
    if myArray[indexPath.row] as! String == Constants.CollegeOrientel {
      fetchDummyData(coordinate: Constants.CollegeOrientalLoc, name: Constants.CollegeOrientel)
      let camera = GMSCameraPosition.camera(withLatitude: Constants.CollegeOrientalLoc.latitude, longitude: Constants.CollegeOrientalLoc.longitude, zoom: 12.0)
      self.mapView?.animate(to: camera)
    }
    if myArray[indexPath.row] as! String == Constants.VEROMODa {
      fetchDummyData(coordinate: Constants.VEROMODALoc, name: Constants.VEROMODa)
      let camera = GMSCameraPosition.camera(withLatitude: Constants.VEROMODALoc.latitude, longitude: Constants.VEROMODALoc.longitude, zoom: 12.0)
      self.mapView?.animate(to: camera)
    }
    showNearPlaces = false
    myTableView.removeFromSuperview()
    
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return myArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "TypeCell", for: indexPath as IndexPath)
    cell.backgroundColor = .white
    cell.textLabel?.textColor = .black
    cell.textLabel!.text = "\(myArray[indexPath.row])"
    return cell
  }
}

// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
  
  func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
    mapCenterPinImage.fadeIn(0.25)
    mapView.selectedMarker = nil
    return false
  }
  
  func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
    
    if (gesture) {
      mapCenterPinImage.fadeIn(0.25)
      mapView.selectedMarker = nil
    }
  }
  
  func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    reverseGeocodeCoordinate(position.target)
  }
  
  private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
  
    let geocoder = GMSGeocoder()
    geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
      guard let address = response?.firstResult(), let lines = address.lines else {
        return
      }
      self.nearButton.titleLabel!.text = lines.joined(separator: "\n")
      UIView.animate(withDuration: 0.25) {
        self.pinImageVerticalConstraint.constant = ((self.nearButton.intrinsicContentSize.height - self.view.safeAreaInsets.top) * 0.5)
        self.view.layoutIfNeeded()
      }
    }
  }
  
  func mapView(_ mapView: GMSMapView, markerInfoContents marker: GMSMarker) -> UIView? {
    
    guard let placeMarker = marker as? PlaceMarker else {
      return nil
    }
    
    guard let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView else {
      return nil
    }
    infoView.nameLabel.text = placeMarker.place.name
    
    if let photo = placeMarker.place.photo {
      infoView.placePhoto.image = photo
      detailsImage.image = photo
    } else {
      infoView.placePhoto.image = UIImage(named: "logo")
    }
    nameLabel.text = placeMarker.place.name
    if placeMarker.place.openHours == true{
      timeLabel.textColor = .orange
      timeLabel.text = "Open"
      
    }else{
      timeLabel.textColor = .red
      timeLabel.text = "Closed"
    }
    if time > 60 {
      let minutes = time / 60
      distanceTimeLabel.text = "\(minutes.rounded(toPlaces: 1)) Hour by walk"
    }else{
      distanceTimeLabel.text = "\(Int(time)) minutes by walk"
    }
    detailsView.isHidden = false
    return infoView
  }
  
  func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
    mapCenterPinImage.fadeOut(0.25)
    let distance = GMSGeometryDistance(sourceLocation, CLLocationCoordinate2D(latitude:  marker.position.latitude, longitude:   marker.position.longitude))
    time =  (distance)/84
    destinationLocation = CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude)
    return false
  }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    
    guard status == .authorizedWhenInUse else {
      return
    }
    
    locationManager.startUpdatingLocation()
    
    mapView.isMyLocationEnabled = true
    mapView.settings.myLocationButton = true
  }
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    
    let location = locations.last
    
    let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 10.0)
    sourceLocation = CLLocationCoordinate2D(latitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!)
    self.mapView?.animate(to: camera)
    self.locationManager.stopUpdatingLocation()
  }
}

