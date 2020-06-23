//
//  MyTripViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 4/22/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftOverlays
class MyTripViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    func convertDate(date:String)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: date!)
        return dateString
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayMyTrip.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableMyTrip.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyTripTableViewCell
        let item = arrayMyTrip[indexPath.row]
        cell.lblNameTrip.text = item.nameTrip
        cell.lblDateStart.text = convertDate(date:item.dateStart)
        cell.lblDateEnd.text = convertDate(date:item.dateEnd)
        cell.lblNumberOfDay.text = String(item.numberOfday) + " Day"
        cell.lblNumOfPeople.text = String(item.numberOfKid+item.numberOfAdult)
        cell.lblBudget.text = df2so(Double(item.budget)) + " VND"
        cell.contentCell.layer.cornerRadius = 10
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = mainstoryboard.instantiateViewController(withIdentifier: "ScheduleViewController") as! ScheduleViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.idTrip = arrayMyTrip[indexPath.row].idTrip
        vc.nameTrip = arrayMyTrip[indexPath.row].nameTrip
    }
   

    @IBOutlet weak var tableMyTrip: UITableView!

    @IBOutlet weak var nameUser: UIBarButtonItem!

    @IBOutlet weak var btnLogout: UIBarButtonItem!

    var arrayMyTrip = [Trip]()
    let dispatchGroup = DispatchGroup()
    lazy var refresh: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .blue
        refreshControl.addTarget(self, action: #selector(refreshTable), for: .valueChanged)
        return refreshControl
    }()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.hidesBackButton = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        showNavigationBar()
        navigationItem.backBarButtonItem = UIBarButtonItem()
        tableMyTrip.delegate = self
        tableMyTrip.dataSource = self
        tableMyTrip.refreshControl = refresh
        getMyTrip()
    }

    @IBAction func logoutButton(_ sender: Any) {
        print("Logout")
        UserDefaults.standard.set(nil, forKey: "UserID")
        UserDefaults.standard.set(nil, forKey: "Token")
        UserDefaults.standard.set(nil, forKey: "nameUser")
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = mainstoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    func getMyTrip() {
        SwiftOverlays.showBlockingWaitOverlayWithText("Waiting")
        let header:HTTPHeaders = [
            "auth-token": UserDefaults.standard.object(forKey: "Token")
            ] as! [String:String]
        Alamofire.request(APIGetMyTrip, method:.get, parameters: nil, encoding: JSONEncoding.default, headers: header).responseJSON{ (response) in
            print("\(response.result) My Trip")
            switch response.result{
            case .success(let paypload):
                if let x = paypload as? Dictionary<String,AnyObject>{
                    let result = x as NSDictionary
                    let code = result["code"] as! Int
                    let message = result["mesage"] as! String
                    if(code == 200){
                        let data = result["data"] as! Array<Dictionary<String,AnyObject>>
                        DispatchQueue.main.async{
                            self.arrayMyTrip.removeAll()
                            for a in data{
                                let id = a["_id"] as! String
                                let name = a["name"] as! String
                                let dateStart = a["date_start"] as!String
                                let dateEnd = a["date_end"] as! String
                                let numberOfDay = a["number_of_day"] as! Int
                                let numberOfAdult = a["adult"] as! Int
                                let numberOfKid = a["kid"] as! Int
                                let budget = a["budget"] as! Int
                                self.arrayMyTrip.append(Trip(id: id, nameTrip: name, dateStart: dateStart, dateEnd: dateEnd, numberOfDay: numberOfDay, numberOfAdult: numberOfAdult, numberOfKid: numberOfKid, budget: budget))
                            }
                        }
                        DispatchQueue.main.async {
                            print("Reload")
                            self.tableMyTrip.reloadData()
                        }
                    }
                    else{
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
                let alert = UIAlertController(title: "", message: "Can't connect to server ", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                    action in
                    print("Close")

                })
                alert.addAction(closeAction)
                self.present(alert,animated: true,completion: nil)
            }

        }
        SwiftOverlays.removeAllBlockingOverlays()
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
    @objc func refreshTable(){
        DispatchQueue.main.async {
            self.getMyTrip()
        }
        let deadline = DispatchTime.now() + .milliseconds(1000)
        DispatchQueue.main.asyncAfter(deadline:deadline) {
            self.refresh.endRefreshing()
        }
    }
}

