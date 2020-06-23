//
//  DirectionViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/12/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON
class DirectionViewController: UIViewController,CLLocationManagerDelegate , GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    var arrayTrip = [Spot]()
    var locationSpot:Spot!
    var locationManager = CLLocationManager()
    var start  = CLLocation()
    var end = CLLocation()
    var startCam = CLLocationCoordinate2D()
    var endCam = CLLocationCoordinate2D()
    let dispatchGroup = DispatchGroup()
    var index = 0
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        locationManager = CLLocationManager()
//        locationManager.delegate = self
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//        locationManager.startMonitoringSignificantLocationChanges()
        initGoogleMaps()
        if arrayTrip.count > 1{
            for a in arrayTrip{
                index += 1
                MarkerMap(title: a.name, snippet: a.address, lat: a.latitude, long: a.longtitude, index: index)
            }
            directiopTrip()
            updateCam()
        }
        else{
            let markerSpot = GMSMarker()
            markerSpot.position = CLLocationCoordinate2D(latitude: locationSpot.latitude, longitude: locationSpot.longtitude)
            markerSpot.title = locationSpot.name
            markerSpot.snippet = locationSpot.address
            markerSpot.appearAnimation = GMSMarkerAnimation.pop
            markerSpot.map = self.mapView
            let Location = locationManager.location?.coordinate
            let mylocation = CLLocation(latitude: (Location?.latitude)!, longitude: (Location?.longitude)!)
            print(Location?.latitude)
            print(Location?.longitude)
            print(locationSpot.latitude)
            print(locationSpot.longtitude)
            getRouteSteps(from: mylocation, to: CLLocation(latitude: locationSpot.latitude, longitude: locationSpot.longtitude))
            let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: Location!, coordinate: markerSpot.position))
            self.mapView.moveCamera(cameraUpdate)
            let currentZoom = self.mapView.camera.zoom
            self.mapView.animate(toZoom: currentZoom - 1.4)
        }

    }

    func directiopTrip(){
        self.dispatchGroup.enter()
            for i in 0...arrayTrip.count-2{
                start = CLLocation(latitude: arrayTrip[i].latitude, longitude: arrayTrip[i].longtitude)
                end = CLLocation(latitude: arrayTrip[i+1].latitude, longitude: arrayTrip[i+1].longtitude)
                getRouteSteps(from: start, to: end)
                if(i==0){
                    startCam = CLLocationCoordinate2D(latitude: start.coordinate.latitude, longitude: start.coordinate.longitude)
                }
                if(i==arrayTrip.count-2){
                    endCam = CLLocationCoordinate2D(latitude: end.coordinate.latitude, longitude:     end.coordinate.longitude)
                }
            }
            print("\(startCam.latitude) - \(startCam.longitude)" )
            print("\(endCam.latitude) - \(endCam.longitude)" )
        self.dispatchGroup.leave()
    }
    func updateCam(){
        self.dispatchGroup.enter()
            run(after: 1 ){
                let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: self.startCam, coordinate: self.endCam))
                self.mapView.moveCamera(cameraUpdate)
                let currentZoom = self.mapView.camera.zoom
                self.mapView.animate(toZoom: currentZoom - 1.5)
            }
        self.dispatchGroup.leave()
    }
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 16.07, longitude: 108.17, zoom: 12)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
        self.mapView.settings.myLocationButton = true
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 20.0)
        //self.mapView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()

    }
    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.mapView.isMyLocationEnabled = true
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.mapView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.selectedMarker = marker;
        return true;
    }
    
    func MarkerMap(title:String ,snippet:String,lat:Double,long:Double,index:Int){
        let markerSpot = GMSMarker()
        markerSpot.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
        markerSpot.title = title
        markerSpot.snippet = snippet
        markerSpot.icon = drawText(text: String(index) as NSString, inImage: UIImage.init(imageLiteralResourceName: "markermap")  )
        markerSpot.appearAnimation = GMSMarkerAnimation.pop
        markerSpot.map = self.mapView

    }
    //Draw route
    func getRouteSteps(from source: CLLocation, to destination: CLLocation) {

        let session = URLSession.shared

        let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.coordinate.latitude),\(source.coordinate.longitude)&destination=\(destination.coordinate.latitude),\(destination.coordinate.longitude)&sensor=false&mode=driving&key=AIzaSyBlXCNlN-uVTgN71kDx8FzpF2fCz7yk40U")!

        let task = session.dataTask(with: url, completionHandler: {
            (data, response, error) in

            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let jsonResult = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: Any] else {

                print("error in JSONSerialization")
                return

            }
            //print(response)

            guard let routes = jsonResult!["routes"] as? [Any] else {
                return
            }

            guard let route = routes[0] as? [String: Any] else {
                return
            }

            guard let legs = route["legs"] as? [Any] else {
                return
            }

            guard let leg = legs[0] as? [String: Any] else {
                return
            }

            guard let steps = leg["steps"] as? [Any] else {
                return
            }
            for item in steps {

                guard let step = item as? [String: Any] else {
                    return
                }

                guard let polyline = step["polyline"] as? [String: Any] else {
                    return
                }

                guard let polyLineString = polyline["points"] as? String else {
                    return
                }

                //Call this method to draw path on map
                DispatchQueue.main.async {
                    self.drawPath(from: polyLineString)
                }

            }
        })
        task.resume()
    }
    func drawPath(from polyStr: String){
        let path = GMSPath(fromEncodedPath: polyStr)
        let polyline = GMSPolyline(path: path)
        polyline.strokeColor = UIColor.init(red: 0/255.0, green: 155/255.0, blue: 255/255.0, alpha: 0.5)
        polyline.strokeWidth = 7.0
        polyline.map = mapView

    }
    func run(after seconds:Int , completion: @escaping () -> Void){
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline ) {
            completion()
        }
    }

    //Text to image for marker
    func drawText(text:NSString, inImage:UIImage) -> UIImage? {

        let font = UIFont.systemFont(ofSize: 11)
        //let size = inImage.size
        let newSize = CGSize(width: 33, height: 48)
        //UIGraphicsBeginImageContext(size)
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        inImage.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let style : NSMutableParagraphStyle = NSMutableParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        style.alignment = .center
        let attributes:NSDictionary = [ NSAttributedString.Key.font : font, NSAttributedString.Key.paragraphStyle : style, NSAttributedString.Key.foregroundColor : UIColor.black]
        let textSize = text.size(withAttributes: attributes as? [NSAttributedString.Key : Any])
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let textRect = CGRect(x: (rect.size.width - textSize.width)/2, y: (rect.size.height - textSize.height)/2 - 6 , width: textSize.width, height: textSize.height)
        text.draw(in: textRect.integral, withAttributes: attributes as? [NSAttributedString.Key : Any])
        let resultImage = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return resultImage
    }

}
