//
//  TripViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/10/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftOverlays

class TripViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    struct Object {
        var sectionName:String!
        var array:[Spot]!
        init(sectionName:String,array:[Spot]) {
            self.sectionName = sectionName
            self.array = array
        }
    }
    var arrayObject = [Object]()
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrayObject.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return arrayObject[section].sectionName
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayObject[section].array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableTrip.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        let item = arrayObject[indexPath.section].array[indexPath.row]
        cell.lblNameTrip.text = nonAccentVietnamese(str: item.name) 
        cell.lblTimeTrip.text = String(mins2Timestamp(mins: item.currentTime))
        cell.lblAddressTrip.text = nonAccentVietnamese(str: item.address)
        cell.lblTemperature.text = item.temperature+"ºC"
        cell.lblWeatherDescription.text = item.sumary
        cell.lblDistance.text = "\(String(format:"%.1f",item.distance)) Km"
        cell.lblMovingTime.text = "\(Int(item.movingTime)) minutes"
        cell.contentCell.layer.cornerRadius = 10
        cell.btnInfoSpot.addTarget(self, action: #selector(buttonInfo), for: .touchUpInside)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.locationSpot = arrayObject[indexPath.section].array[indexPath.row]


    }
    @objc func buttonInfo(sender :UIButton){
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "DetailSpotViewController") as! DetailSpotViewController
        self.navigationController?.pushViewController(vc, animated: true)
        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to: self.tableTrip)
        let index = self.tableTrip.indexPathForRow(at: buttonPosition)
        let item = arrayObject[(index?.section)!].array![(index?.row)!]
        vc.address = item.address
        vc.name = item.name
        vc.images = item.images
        vc.des = item.description
        vc.price = item.price
        vc.category = item.category
        vc.subcategory = item.subcategory
    }

    @IBOutlet weak var tableTrip: UITableView!
    @IBOutlet weak var btnDirection: UIButton!


    var dateTime = NSDate()
    var titleNav = String()
    var arrayTrip = [Spot]()
    var morning = [Spot]()
    var afternoon = [Spot]()
    var evening = [Spot]()
    var temperature = String()
    var descriptionWeather = String()
    var icon = String()
    var forecastService:ForecastService!
    let forecastAPIKey = "a9509c4bb50a664c5f7270ef948fbd6b"
    let dispatchGroup = DispatchGroup()
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .blue
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        return refreshControl
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            for a in self.arrayTrip{
                print(a.name)
                if(a.currentTime >= 0 && a.currentTime <= 719 ){
                    self.morning.append(a)
                }
                else if(a.currentTime >= 720 && a.currentTime <= 1139){
                    self.afternoon.append(a)
                }
                else if (a.currentTime >= 1140 && a.currentTime < 1440){
                    self.evening.append(a)
                }
            }
            self.arrayObject.append(Object(sectionName: "Morning", array: self.morning))
            self.arrayObject.append(Object(sectionName: "Afternoon", array: self.afternoon))
            self.arrayObject.append(Object(sectionName: "Evening", array: self.evening))
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        tableTrip.delegate = self
        tableTrip.dataSource = self
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = titleNav
        navigationItem.backBarButtonItem = UIBarButtonItem()
        showNavigationBar()
        btnDirection.layer.cornerRadius = btnDirection.frame.height/2
        addWeather()
        tableTrip.refreshControl = refresh

        let myTimeStamp = self.dateTime.timeIntervalSince1970
        print(myTimeStamp)
    }
    func display(){
        dispatchGroup.enter()
        run(after: 3){
            print("Reload")
            self.tableTrip.reloadData()
        }
        dispatchGroup.leave()
    }
    func run(after seconds:Int , completion: @escaping () -> Void){
        let deadline = DispatchTime.now() + .seconds(seconds)
        DispatchQueue.main.asyncAfter(deadline: deadline ) {
            completion()
        }
    }
    @IBAction func DirectionButton(_ sender: Any) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "DirectionViewController") as! DirectionViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.hidesBottomBarWhenPushed = true
        vc.arrayTrip = arrayTrip
    }
    func nonAccentVietnamese(str:String) -> String {
        var a = str
        a = a.replacingOccurrences(of: "đ", with: "d")
        a = a.replacingOccurrences(of: "Đ", with: "D")
        return a.folding(options: .diacriticInsensitive, locale:NSLocale.current)
    }
    @objc func refreshTable(){
        DispatchQueue.main.async {
            self.addWeather()
        }
        let deadline = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline: deadline){
            self.refresh.endRefreshing()
        }
    }
}

extension TripViewController{
    func mins2Timestamp(mins:Double)->String {
        let hours:Int = Int(mins/60)
        let minutes:Int = Int(mins)%60
        let strTimestamp:String = ((hours<10) ? "0" : "") + String(hours) + ":" + ((minutes<10) ? "0" : "") + String(minutes)
        return strTimestamp
    }
    func addWeather(){

        DispatchQueue.global(qos: .background).async {
            if(self.arrayTrip.count<0){
                let alert = UIAlertController(title: "", message: "Can't connect to server ", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                    action in
                    print("Close")
                })
                alert.addAction(closeAction)
                self.present(alert,animated: true,completion: nil)
            }
            else{
                self.run(after: 0){
                    for i in 0...self.arrayTrip.count-1{
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        let stringTime = formatter.string(from: self.dateTime as Date)
                        let timeCurrentSpot = "\(stringTime)T\(self.mins2Timestamp(mins: self.arrayTrip[i].currentTime)):00"
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        formatter.timeZone = TimeZone.current
                        formatter.locale = Locale.current
                        let date = formatter.date(from: timeCurrentSpot)
                        print(date!)
                        let timeStamp = date?.timeIntervalSince1970
                        print(Int(timeStamp!))
                        let URL:String = "https://api.darksky.net/forecast/a9509c4bb50a664c5f7270ef948fbd6b/\(self.arrayTrip[i].latitude),\(self.arrayTrip[i].longtitude),\(Int(timeStamp!))"
                        Alamofire.request(URL).responseJSON{
                            (response) in
                            print("\(response.result) weather")
                            switch response.result{
                            case .success(let paypload):
                                if let x = paypload as? Dictionary<String,AnyObject>{
                                    let data = x as NSDictionary
                                    DispatchQueue.main.async {
                                        let currently = data["currently"] as! Dictionary<String,AnyObject>
                                        self.arrayTrip[i].temperature = String(Int((currently["temperature"] as! Double-32)/1.8))
                                        self.arrayTrip[i].sumary = currently["summary"] as! String
                                    }
                                    DispatchQueue.main.async {
                                        print("Reload table")
                                        self.tableTrip.reloadData()

                                    }

                                }
                            case .failure(let error):
                                DispatchQueue.main.async{
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }

        }
    }
}
