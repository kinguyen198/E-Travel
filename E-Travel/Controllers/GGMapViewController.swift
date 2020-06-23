//
//  GGMapViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/16/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
class GGMapViewController: UIViewController,UISearchBarDelegate,LocateOnTheMap,GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        //self.resultsArray.count + 1

        for prediction in predictions {

            if let prediction = prediction as GMSAutocompletePrediction!{
                self.resultsArray.append(prediction.attributedFullText.string)
            }
        }
        self.searchResultController.reloadDataWithArray(self.resultsArray)
        //   self.searchResultsTable.reloadDataWithArray(self.resultsArray)
        print(resultsArray)
    }

    func didFailAutocompleteWithError(_ error: Error) {
            //        resultText?.text = error.localizedDescription
    }



    @IBOutlet weak var mapView: GMSMapView!


    var searchResultController:SearchResultsController!
    var resultsArray = [String]()
    var gmsFetcher: GMSAutocompleteFetcher!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = GMSCameraPosition.camera(withLatitude: 16.04, longitude: 108.17, zoom: 10)
        self.mapView.camera = camera
        addMarker()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
        gmsFetcher = GMSAutocompleteFetcher()
        gmsFetcher.delegate = self

    }
    func addMarker() {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 10.75, longitude: 106.41)
        marker.title = "SaiGon"
        marker.snippet = "VietNam"
        marker.appearAnimation = .pop
        marker.map = self.mapView
    }

    @IBAction func searchWithAddress(_ sender: Any) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated:true, completion: nil)
    }


    func locateWithLongitude(_ lon: Double, andLatitude lat: Double, andTitle title: String) {

        DispatchQueue.main.async { () -> Void in

            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10)
            self.mapView.camera = camera
            marker.title = "Address : \(title)"
            marker.map = self.mapView

        }

    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

            let placeClient = GMSPlacesClient()


            placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil)  {(results, error: Error?) -> Void in
            // NSError myerr = Error;
            print("Error @%",Error.self)

            self.resultsArray.removeAll()
                if results == nil {
                    return
                }

            for result in results! {
                if let result = result as? GMSAutocompletePrediction {
                    self.resultsArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWithArray(self.resultsArray)
            }
            self.resultsArray.removeAll()
            gmsFetcher?.sourceTextHasChanged(searchText)


    }



}
