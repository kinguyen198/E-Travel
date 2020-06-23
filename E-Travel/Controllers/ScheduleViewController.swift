//
//  ScheduleViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/23/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftOverlays
class ScheduleViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arraySchedule.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScheduleTableViewCell
        let item = arraySchedule[indexPath.row]
        cell.lblDay.text = "Day \(indexPath.row + 1)"
        cell.lblTimeStart.text = "\(mins2Timestamp(mins: item.timeStart))  -"
        cell.lblTimeEnd.text = mins2Timestamp(mins: item.timeEnd)
        cell.lblDistance.text = "\(String(Int(item.distances))) km"
        cell.lblNumOfSpot.text = "\(String(item.numOfSpot)) spots"
        cell.contentCell.layer.cornerRadius = 10
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: self.dateStart)
        var dayComponent =  DateComponents()
        dayComponent.day = indexPath.row
        let theCalendar = Calendar.current
        let theNextDate = theCalendar.date(byAdding: dayComponent, to: date!)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: theNextDate!)
        cell.lblDate.text = String(dateString)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "TripViewController") as! TripViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.arrayTrip = self.arraySpotDay[indexPath.row]
        vc.titleNav = String("Day \(indexPath.row + 1) - Weather")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        let date = dateFormatter.date(from: self.dateStart)
        var dayComponent = DateComponents()
        dayComponent.day = indexPath.row
        let theCalendar = Calendar.current
        let nextDate = theCalendar.date(byAdding: dayComponent, to: date!)
        vc.dateTime = nextDate! as NSDate
    }

    
    @IBOutlet weak var tableView: UITableView!
    var index = Int()
    var idTrip = String()
    var nameTrip = String()
    //Mang so ngay cua chuyen di
    var arraySchedule = [Schedule]()
    //mang dia diem cua cac ngay
    var arraySpotDay = [[Spot]]()

    //mang image price cua spots
    var arrayPlace = [Place]()
    var arrayInfo = [[Place]]()
    //Get ngay bat dau`
    var dateStart = String()


    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = nameTrip
        navigationItem.backBarButtonItem = UIBarButtonItem()
        tableView.delegate = self
        tableView.dataSource = self
        DispatchQueue.main.async {
             self.getTrip()
        }
    }

    func mins2Timestamp(mins:Double)->String {
        let hours:Int = Int(mins/60)
        let minutes:Int = Int(mins)%60
        let strTimestamp:String = ((hours<10) ? "0" : "") + String(hours) + ":" + ((minutes<10) ? "0" : "") + String(minutes)
        return strTimestamp
    }
    func getTrip(){
        SwiftOverlays.showBlockingWaitOverlayWithText("Waiting")
        let API = APIGetTrip+"\(self.idTrip)"
        Alamofire.request(API, encoding: JSONEncoding.default).responseJSON{
            (response) in
            print("\(response.result) Trip")
            switch response.result{
            case .success(let paypload):
                if let x = paypload as? Dictionary<String,AnyObject>{
                    let result = x as NSDictionary
                    let code = result["code"] as! Int
                    let message = result["message"] as! String
                    if(code == 200){
                        let data = result["data"] as! Dictionary<String,AnyObject>
                        DispatchQueue.main.async{
                            self.dateStart = data["date_start"] as! String
                            let schedule = data["schedules"] as! Array<Dictionary<String,AnyObject>>
                            for schedules in schedule{
                                let timestart = schedules["time_start"] as! Double
                                let timeend = schedules["time_end"] as! Double
                                var distances:Double = 0.0
                                var numOfSpot:Int = 0
                                print(timestart)
                                var arraySpot = [Spot]()
                                let array = schedules["spots"] as! Array<Dictionary<String,AnyObject>>
                                for a in array{
                                    let dictionary = a as NSDictionary
                                    let name = dictionary["name"] as! String
                                    let description = dictionary["description"] as! String
                                    var address:String?
                                    if  dictionary["address"] == nil
                                    {
                                        address = "No address"
                                    }
                                    else{
                                        address = dictionary["address"] as? String
                                    }
                                    let lat = dictionary["latitude"] as! Double
                                    let long = dictionary["longtitude"] as! Double
                                    let currentTime = dictionary["current_time"] as! Double
                                    let movingtime = dictionary["moving_time"] as! Double
                                    let distance = dictionary["distance"] as! Double
                                    distances += distance
                                    numOfSpot += 1
                                    let images = dictionary["images"] as! Array<String>
                                    let category = dictionary["category"] as! NSDictionary
                                    let categoryName = category["name"] as! String
                                    let subcategory = category["sub_categories"] as! Array<NSDictionary>
                                    var subcategoryName = String()
                                    for a in subcategory{
                                        subcategoryName += "\(a["name"] as! String),"
                                    }
                                    let price = String(dictionary["price"] as! Double)
                                    let newSpot = Spot(name: name, description: description, address: address!, latitude: lat, longtitude:long , currentTime: currentTime, distance: distance,movingTime:movingtime,image:images,price:price,category:categoryName,subCategory:subcategoryName)
                                    arraySpot.append(newSpot)
                                }
                                print(distances)
                                self.arraySpotDay.append(arraySpot)
                                self.arraySchedule.append(Schedule(timeStart: timestart, timeEnd: timeend, distances: distances, numOfSpot: numOfSpot))
                            }
                        }
                        DispatchQueue.main.async {
                            print("Reload")
                            self.tableView.reloadData()
                        }
                        SwiftOverlays.removeAllBlockingOverlays()
                    }
                    else{
                        SwiftOverlays.removeAllBlockingOverlays()
                        let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: .alert)
                        let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                            action in
                            print("Close")
                        })
                        alert.addAction(closeAction)
                        self.present(alert,animated: true,completion: nil)
                    }

                }
            case .failure( let error):
                print(error)
                SwiftOverlays.removeAllBlockingOverlays()
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
