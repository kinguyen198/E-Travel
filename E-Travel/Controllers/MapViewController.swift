//
//  MapViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/19/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import Alamofire
import SwiftOverlays
import iOSDropDown
import RSSelectionMenu
import HandyJSON
import Foundation
import Photos
import OpalImagePicker

class MapViewController: UIViewController,UITextFieldDelegate, CLLocationManagerDelegate , GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate,HandyJSON,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource {

    //search location
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        getAddressForLatLng(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        googleMapsView.clear()
        showSpot()
        let camera = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude, longitude: place.coordinate.longitude, zoom: 15)
        self.googleMapsView.camera = camera
        //let marker=GMSMarker()
        markerTap.position = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        markerTap.map = googleMapsView
        run(after: 1){
            let newPlace = Place(id: "", name: "Marker create Spot", description: "", address: self.formatted_address, latitude: place.coordinate.latitude, longtitude: place.coordinate.longitude, category: "",subcategory:"", price: "0",image:[""])
            self.markerTap.userData = newPlace
        }
        self.dismiss(animated: true, completion: nil) // dismiss after select place
    }
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("ERROR AUTO COMPLETE \(error)")
    }
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil) // when cancel search
    }


    //Collection Image
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayImageCollection.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ImageSpotCollectionViewCell
        cell.imageContent.image = arrayImageCollection[indexPath.row]
        cell.deleteButtonBackground.layer.cornerRadius = cell.deleteButtonBackground.frame.width / 2.0
        cell.deleteButtonBackground.layer.masksToBounds = true
        cell.delegate = self
        return cell
    }

    //Choose Image from libary
    @IBAction func chooseImage(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            print("NO source")
            return
        }
        //Example Instantiating OpalImagePickerController with Closures
        let imagePicker = OpalImagePickerController()

        //Present Image Picker
        presentOpalImagePickerController(imagePicker, animated: true, select: { (assets) in
            let requestOptions = PHImageRequestOptions()
            requestOptions.resizeMode = PHImageRequestOptionsResizeMode.none
            requestOptions.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
            requestOptions.isSynchronous = true
            for a in assets{
                if (a.mediaType == PHAssetMediaType.image)
                {
                    PHImageManager.default().requestImage(for: a , targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: requestOptions, resultHandler: { (pickedImage, info) in
                        self.arrayImageCollection.append(pickedImage!)
                    })
                }
            }
            self.postImage(images: self.arrayImageCollection)
            self.ImageSpotCollection.reloadData()
            //Dismiss Controller
            imagePicker.dismiss(animated: true, completion: nil)
        }, cancel: {
            imagePicker.dismiss(animated: true, completion: nil)

        })
    }

    func postImage(images:[UIImage]){
        SwiftOverlays.showBlockingWaitOverlayWithText("Wait upload images")
        Alamofire.upload(multipartFormData: { (multipartFormData : MultipartFormData) in
            for image in images{
                let imageData = image.jpegData(compressionQuality: 0.6)
                multipartFormData.append(imageData!, withName: "images", fileName: "photo.jpeg" , mimeType: "image/jpeg")
            }
        }, to: APIUploadImage) { (result) in
            switch result {
            case .success(let upload, _ , _):
                upload.responseJSON{response in
                    switch response.result{
                    case .success(let json):
                        let data  = json as! Dictionary<String,AnyObject>
                        let code = data["code"] as! Int
                        if(code == 200 ) {
                            DispatchQueue.main.async {
                                let linkImages = data["data"] as! Array<String>
                                for a in linkImages{
                                    self.linkImageSpot.append(a)
                                    print(a)
                                }
                                print("Upload image successs")
                                SwiftOverlays.removeAllBlockingOverlays()
                            }
                        }else{
                            SwiftOverlays.removeAllBlockingOverlays()
                            print("Have Problem")
                        }
                    case .failure(let error):
                        SwiftOverlays.removeAllBlockingOverlays()
                        print(error)
                    }
                }
            case .failure(let encodingError):
                print("failed")
                print(encodingError)
            }
        }

    }



    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnAdd: UIView!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var AddNewSpotView: UIView!
    @IBOutlet weak var dropDownCategory: DropDown!
    @IBOutlet weak var btnSelectSub: UIButton!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var btnChooseImage: UIButton!
    @IBOutlet weak var btnSelectPartofDay: UIButton!
    @IBOutlet weak var ImageSpotCollection: UICollectionView!









    var arrayImageCollection = [UIImage]()
    var locationManager = CLLocationManager()
    var markerTap = GMSMarker()
    var idCategory:String = ""
    public var arraySubCategory = [SubCategory] ()
    var preSelectedValues : [String] = []
    var selectedDataArray = [SubCategory]()
    var arrayResultName = [String]()
    var arrayResultId = [String]()
    var idSubCategory:String = ""
    var arrayPartID = [String]()
    var arraySpot = [Spot]()
    var arrayS = [[String:Any]] ()
    var arrayPlace = [Place]()
    var city = String()
    var district = String()
    var street = String()
    var streetNumber = String()
    var formatted_address = String()

    var customInfoWindow : CustomInfoWindow?
    var tappedMarker = GMSMarker()
    var image = [String]()
    var name = String()
    var address = String()
    var price = String()
    var category = String()
    var subcategory = String()
    var des = String()
    var imageSpot = UIImage()
    var linkImageSpot = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        btnSelectPartofDay.layer.cornerRadius = btnSelectPartofDay.frame.height/2
        btnSelectSub.layer.cornerRadius = btnSelectSub.frame.height/2
        lblAddress.layer.cornerRadius = 8
        AddNewSpotView.isHidden = true
        self.view.bringSubviewToFront(AddNewSpotView)
        self.view.addSubview(btnRefresh)
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        initGoogleMaps()
        dropdownCategory()
        getSpot()
        showSpot()
        self.customInfoWindow = CustomInfoWindow().loadView()
    }
    func showSpot(){
        run(after: 1){
            for place in self.arrayPlace{
                var icon:UIImage?
                switch place.category{
                case "special":
                    icon = #imageLiteral(resourceName: "icons8-camera-50")
                case "food":
                    icon = #imageLiteral(resourceName: "icons8-meal-50")
                case "stay":
                    icon = #imageLiteral(resourceName: "icons8-apartment-50")
                default:
                    break
                }
                let marker = GMSMarker()
                let placeLat = place.latitude
                let placeLon = place.longtitude
                marker.position = CLLocationCoordinate2D(latitude: CLLocationDegrees(placeLat), longitude: CLLocationDegrees(placeLon))
                marker.icon = icon
                marker.appearAnimation = .pop
                marker.map = self.googleMapsView
                marker.userData = place
            }
        }
    }
    func run(after seconds:Int , completion: @escaping () -> Void){
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline ) {
            completion()
        }
    }
    func initGoogleMaps() {

        let camera = GMSCameraPosition.camera(withLatitude: 16.07, longitude: 108.17, zoom: 12)
        let mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.googleMapsView.camera = camera
        self.googleMapsView.delegate = self
        self.googleMapsView.isMyLocationEnabled = true
        self.googleMapsView.settings.myLocationButton = true
    }

    @objc func buttonTapped(sender :UIButton){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "DetailSpotViewController") as! DetailSpotViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.hidesBottomBarWhenPushed = true
        vc.address = self.address
        vc.category = self.category
        vc.name = self.name
        vc.images = self.image
        vc.price = self.price
        vc.des = self.des
        vc.subcategory = self.subcategory
    }
    @objc func buttonClose(sender: UIButton){
        customInfoWindow?.removeFromSuperview()
    }
    @IBAction func refreshMap(_ sender: Any) {
        googleMapsView.clear()
        lblAddress.text = ""
        markerTap.position.latitude = -180
        markerTap.position.longitude = -180
        getSpot()
        showSpot()
    }

    //Search location
    @IBAction func openSearchAddress(_ sender: Any) {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self

        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter

        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
    }


    // MARK: GMSMapview Delegate
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.googleMapsView.isMyLocationEnabled = true
    }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.googleMapsView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        tappedMarker = marker
        let position = marker.position
        mapView.animate(toLocation: position)
        let point = mapView.projection.point(for: position)
        let newpoint = mapView.projection.coordinate(for: point)
        let camera = GMSCameraUpdate.setTarget(newpoint)
        mapView.animate(with: camera)
        customInfoWindow?.layer.cornerRadius = 10
        customInfoWindow?.btnInfo.layer.cornerRadius = 10
        customInfoWindow?.center = mapView.projection.point(for: position)
        customInfoWindow?.btnInfo.addTarget(self, action:  #selector(buttonTapped), for: .touchUpInside)
        customInfoWindow?.btnClose.addTarget(self, action: #selector(buttonClose), for: .touchUpInside)
        mapView.addSubview(customInfoWindow!)
        return false
    }
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("\(coordinate.latitude) , \(coordinate.longitude)")
        markerTap.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        getAddressForLatLng(latitude: coordinate.latitude, longitude: coordinate.longitude)
        markerTap.appearAnimation = GMSMarkerAnimation.pop
        markerTap.map = self.googleMapsView
        run(after: 1){
            let newPlace = Place(id: "", name: "Marker create Spot", description: "", address: self.formatted_address, latitude: coordinate.latitude, longtitude: coordinate.longitude, category: "",subcategory:"", price: "0",image:[""])
            self.markerTap.userData = newPlace
        }

    }
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        self.address = (marker.userData as! Place).address
        self.name = (marker.userData as! Place).name
        self.price = (marker.userData as! Place).price
        self.image = (marker.userData as! Place).image
        self.category = (marker.userData as! Place).category
        self.des = (marker.userData as! Place).description
        self.subcategory = (marker.userData as! Place).subcategory
        customInfoWindow?.lblAddressSpot.text = nonAccentVietnamese(str: address)
        customInfoWindow?.lblNameSpot.text = nonAccentVietnamese(str: name)
        customInfoWindow?.lblPriceSpot.text = "\(df2so(Double(price)!)) VND"
        return UIView()
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let position = tappedMarker.position
        customInfoWindow?.center = mapView.projection.point(for: position)
        customInfoWindow?.center.y -= 140
    }
    // MARK: CLLocation Manager Delegate

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while get location \(error)")
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
        self.googleMapsView.animate(to: camera)
        self.locationManager.stopUpdatingLocation()

    }



    //Add new Spot

    @IBAction func AddButton(_ sender: Any) {
        //AddNewSpotView.isHidden = false
        UIView.transition(with: AddNewSpotView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.AddNewSpotView.isHidden = false
        })
        print(self.formatted_address)
    }
    @IBAction func CancelButton(_ sender: Any) {
        self.resetData()
    }
    @IBAction func SelectSubButton(_ sender: Any) {
        for a in selectedDataArray {
            print(a.name!)
        }
        arrayResultName.removeAll()
        arrayResultId.removeAll()
        print(arrayResultId.joined(separator: ",") + "Remove")
        print(arrayResultName.joined(separator: ",") + "Remove Sub")
        let selectionMenu = RSSelectionMenu( selectionType: .Multiple, dataSource: arraySubCategory, cellType: .Basic) { (cell, SubCategory, indexPath) in
            cell.textLabel?.text = SubCategory.name
        }


        selectionMenu.onDismiss = { [weak self] items in
            self?.selectedDataArray = items
            for a in (self?.selectedDataArray)!{
                self?.arrayResultName.append(a.name!)
                self?.arrayResultId.append(a.id!)
            }
            if self!.selectedDataArray.isEmpty{
                self?.btnSelectSub.setTitle("Select Sub Category", for: .normal)
            }else{
                self?.btnSelectSub.setTitle(self?.arrayResultName.joined(separator: ","), for: .normal)
            }
            selectionMenu.tableView?.reloadData()
        }

        selectionMenu.showSearchBar { (searchtext) -> ([SubCategory]) in

            // return filtered array based on any condition
            // here let's return array where name starts with specified search text
            return self.arraySubCategory.filter({ $0.name!.lowercased().hasPrefix(searchtext.lowercased()) })
        }
        selectionMenu.show(style: .Alert(title: "Select Sub Category", action: nil, height: nil), from: self)

    }
    @IBAction func AddNewSpotButton(_ sender: Any) {
        print("\(self.markerTap.position.latitude), \(self.markerTap.position.longitude)")
        arrayResultId.append(contentsOf: arrayPartID)
        for a in arrayResultId{
            print(a)
        }
        if self.markerTap.position.latitude == -180  && self.markerTap.position.longitude == -180 {
            let alert = UIAlertController(title: "", message: "You must select a location on the map", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                action in
                UIView.transition(with: self.AddNewSpotView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                    self.AddNewSpotView.isHidden = true
                })
                print("Close")
               //self.resetData()
            })
            alert.addAction(closeAction)
            self.present(alert,animated: true,completion: nil)
        }
        else if arrayPartID.isEmpty {
            let alert = UIAlertController(title: "", message: "You must choose at least one Part of day", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                action in
                print("Close")
            })
            alert.addAction(closeAction)
            self.present(alert,animated: true,completion: nil)
        }
        else{
            SwiftOverlays.showBlockingTextOverlay("Waiting")
            let param = [
                "name": self.txtName.text!,
                "address": "\(self.streetNumber) \(self.street), \(self.district), \(self.city)",
                "city": self.city,
                "district": self.district,
                "street": self.street,
                "description": self.txtDescription.text!,
                "price": self.txtPrice.text!,
                "latitude":self.markerTap.position.latitude,
                "longtitude":self.markerTap.position.longitude,
                "time_duration": 60,
                "main_category": "\(self.idCategory)",
                "sub_categories": self.arrayResultId,
                "cover_image":self.linkImageSpot[1],
                "images": self.linkImageSpot
                ] as [String: Any]
            let authtoken = UserDefaults.standard.object(forKey: "Token")! as Any
            let header:HTTPHeaders = [
                "auth-token": "\(authtoken)"
            ]
            Alamofire.request(APIPostSpot, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON { (response) in
                print(response)
                print("\(response.result) Add Spot")
                switch response.result{
                case .success(let payload):
                    if let x = payload as? Dictionary<String,AnyObject>{
                        print(x)
                        let resultValue = x as NSDictionary
                        let code = resultValue["code"] as! Int
                        let message = resultValue ["message"] as! String
                        if(code == 200){
                            // Thong bao
                            SwiftOverlays.removeAllBlockingOverlays()
                            let alert = UIAlertController(title: "", message: "Submitted Spot Successfully", preferredStyle: .alert)
                            let closeAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                action in
                                print("OK")
                                UIView.transition(with: self.AddNewSpotView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                                    self.AddNewSpotView.isHidden = true
                                })
                                self.resetData()
                            })
                            alert.addAction(closeAction)
                            self.present(alert,animated: true,completion: nil)

                        }else{
                            SwiftOverlays.removeAllBlockingOverlays()
                            let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: .alert)
                            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                                action in
                                print("Close")
                                self.resetData()
                                self.AddNewSpotView.isHidden = true
                            })
                            alert.addAction(closeAction)
                            self.present(alert,animated: true,completion: nil)
                        }
                    }
                case .failure( let error):
                   SwiftOverlays.removeAllBlockingOverlays()
                    print(error)
                    let alert = UIAlertController(title: "", message: "Can't connect to server ", preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                        action in
                        print("Close")
                    })
                    alert.addAction(closeAction)
                    self.present(alert,animated: true,completion: nil)
                }
            }
        }
    }


    @IBAction func SelectPartOfDayButton(_ sender: Any) {
        let arrayData = ["Morning","Afternoon","Night"]

        arrayPartID.removeAll()
        print(arrayPartID.joined(separator: ",") + "Remove Part of day")
        let selectionMenu = RSSelectionMenu(selectionType: .Multiple, dataSource: arrayData)  { (cell, name, indexPath) in
            cell.textLabel?.text = name
        }
        selectionMenu.onDismiss = { [weak self] selectedItems in
            for a in selectedItems{
                if(a == "Morning"){
                    print(a)
                    self!.arrayPartID.append("5ea6b29ce8ccc02fc4af7428")
                }
                else if (a == "Afternoon"){
                    print(a)
                    self!.arrayPartID.append("5ea6b2afe8ccc02fc4af7429")
                }else if(a == "Night"){
                    print(a)
                    self!.arrayPartID.append("5ea6b2f5e8ccc02fc4af742a")
                }
            }
            if selectedItems.isEmpty{
                self!.btnSelectPartofDay.setTitle("Select Parts of Day", for: .normal)
            }
            else{
                self!.btnSelectPartofDay.setTitle(selectedItems.joined(separator: ","), for: .normal)
            }
        }
        selectionMenu.show(style: .Alert(title: "Select Parts of Day", action: nil, height: nil), from: self)
    }
    func resetData(){
        //AddNewSpotView.isHidden = true
        UIView.transition(with: AddNewSpotView, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.AddNewSpotView.isHidden = true
        })
        markerTap.position.latitude = -180
        markerTap.position.longitude = -180
        txtName.text = ""
        txtPrice.text = ""
        txtDescription.text = ""
        dropDownCategory.text = ""
        lblAddress.text = ""
        btnSelectSub.setTitle("Select Sub Category", for: .normal)
        //lblAddress.text = ""
        linkImageSpot = [""]
        arrayPartID.removeAll()
        arrayResultId.removeAll()
        btnSelectPartofDay.setTitle("Select Parts of Day", for: .normal)
        arrayImageCollection.removeAll()
        ImageSpotCollection.reloadData()
    }
}

extension MapViewController:ImageCellDelegate,UICollectionViewDelegateFlowLayout{
    func dropdownCategory() {
        dropDownCategory.optionArray = ["Special","Food","Stay"]
        dropDownCategory.optionIds = [1,2,3]
        dropDownCategory.didSelect{(selectedText , index ,id) in
            self.dropDownCategory.text = "\(selectedText)"
            self.arraySubCategory.removeAll()
            self.btnSelectSub.setTitle("Select Subcategory", for: .normal)
            print(selectedText)
            switch id{
            case 1:
                self.idCategory = "5ea69c8d3f3b270f908e2cb6"
                let url = APIGetSub + self.idCategory
                self.getSub(url: url)

            case 2:
                self.idCategory = "5ea69cce3f3b270f908e2cb7"
                let url = APIGetSub + self.idCategory
                self.getSub(url: url)
            case 3:
                self.idCategory = "5ea69cda3f3b270f908e2cb8"
                let url = APIGetSub + self.idCategory
                self.getSub(url:url)
            default :
                break
            }
        }
    }
    //Get spot
    func getSpot(){
        Alamofire.request(APIGetSpot, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil).responseJSON{ (response) in
            print("\(response.result) Get Spot")
            switch response.result{
            case .success(let json):
                if let x = json as? Dictionary <String,AnyObject>{
                    let resultValue = x as [String:Any]?
                    let code = resultValue!["code"] as! Int
                    let message = resultValue!["message"] as! String
                    if(code == 200){
                        let data = resultValue!["data"] as![[String:Any]]?
                        for a in data! {
                            let dictionary = a as NSDictionary
                            //print(dictionary["name"]!)
                            DispatchQueue.main.async {
                                let id = dictionary["_id"] as! String
                                let name = dictionary["name"] as! String
                                let description = dictionary["description"] as! String
                                let price = dictionary["price"] as! Int
                                let lat = dictionary["latitude"] as! Double
                                let long = dictionary["longtitude"] as! Double
                                let image = dictionary["images"] as! Array<String>
                                let category = dictionary["category"] as! NSDictionary
                                let categoryName = category["name"] as! String
                                let subcategory = category["sub_categories"] as! Array<NSDictionary>
                                var subcategoryName = String()
                                for a in subcategory{
                                    subcategoryName += "\(a["name"] as! String),"
                                }
                                print(subcategoryName)
                                var address:String?
                                if dictionary["address"] == nil {
                                    address = "No address"
                                }
                                else{
                                    address = dictionary["address"] as? String
                                }
                                self.arrayPlace.append(Place(id: id, name: name, description: description, address: address!, latitude: lat, longtitude: long, category: categoryName,subcategory:subcategoryName, price: String(price),image:image))
                            }
                        }
                        //self.MarkerMap(title: name, snippet: description, lat: lat , long: long,icon:iconMarker!)
                    }
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "", message: "Can't connect to server ", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                    action in
                    print("Close")
                })
                alert.addAction(closeAction)
                self.present(alert,animated: true,completion: nil)
            }
        }

    }
    //Get Address on marker
    func getAddressForLatLng(latitude: Double, longitude: Double){
        let url:String = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(latitude),\(longitude)&key=AIzaSyCYZ2TdApvfduh9q_za94Ju-xcots8rhNU"
        Alamofire.request(url ).responseJSON{ (response) in
            print("\(response.result) Get Address")
            switch response.result{
            case .success(let json):
                if let x = json as? Dictionary <String,AnyObject>{
                    let dictionary = x as [String:Any]?
                    let status = dictionary!["status"] as! String
                    if status == "OK"{
                        var allResults = dictionary!["results"] as?  Array<Dictionary<String, Any>>
                        DispatchQueue.main.async {
                            self.formatted_address = allResults![0]["formatted_address"] as! String
                            let address_components = allResults![0]["address_components"] as? Array<Dictionary<String,Any>>
                            self.streetNumber = (address_components![0]["long_name"] as! String)
                            self.street = self.nonAccentVietnamese(str: (address_components![1]["long_name"] as! String))
                            self.district = self.nonAccentVietnamese(str: (address_components![2]["long_name"] as! String))
                            self.city = self.nonAccentVietnamese(str:(address_components![3]["long_name"] as! String))
                            self.lblAddress.text = "\(self.streetNumber) \(self.street), \(self.district), \(self.city)"
                        }
                    }
                    else{
                        let alert = UIAlertController(title: "", message: "Have problem", preferredStyle: .alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                            action in
                            print("Close")
                        })
                        alert.addAction(closeAction)
                        self.present(alert,animated: true,completion: nil)
                    }

                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "", message: "Can't connect to server ", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                    action in
                    print("Close")
                })
                alert.addAction(closeAction)
                self.present(alert,animated: true,completion: nil)
            }
        }
    }

    func df2so(_ price: Double) -> String{
        let numberFormatter = NumberFormatter()
        numberFormatter.groupingSeparator = ","
        numberFormatter.groupingSize = 3
        numberFormatter.usesGroupingSeparator = true
        numberFormatter.decimalSeparator = "."
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: price as NSNumber)!
    }
    //Get subcategory
    func getSub(url:String){
        Alamofire.request(url).responseJSON{
            (response) in
            print("\(response.result) Get sub")
            switch response.result{
            case .success(let json):
                if let x = json as? Dictionary <String,AnyObject>{
                    let data = x["data"] as! [[String:AnyObject]]
                    for a in data {
                        DispatchQueue.main.async {
                            let id = a["_id"] as! String
                            let name = a["name"] as! String
                            self.arraySubCategory.append(SubCategory(id: id, name: name, parent_id: self.idCategory))
                        }
                    }
                }
            case .failure(let error):
                print(error)
                let alert = UIAlertController(title: "", message: "Can't connect to server ", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                    action in
                    print("Close")
                })
                alert.addAction(closeAction)
                self.present(alert,animated: true,completion: nil)
            }
        }
    }

    func nonAccentVietnamese(str:String) -> String {
        var a = str
        a = a.replacingOccurrences(of: "đ", with: "d")
        a = a.replacingOccurrences(of: "Đ", with: "D")
        return a.folding(options: .diacriticInsensitive, locale:NSLocale.current)
    }
    func delete(cell: ImageSpotCollectionViewCell) {
        if let indexPath = ImageSpotCollection.indexPath(for:cell){
            arrayImageCollection.remove(at: indexPath.item)
            ImageSpotCollection.deleteItems(at: [indexPath])
            linkImageSpot.remove(at: indexPath.item)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = ImageSpotCollection.frame.size
        return CGSize(width: size.width/2, height: size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


