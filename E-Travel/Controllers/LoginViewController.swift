//
//  LoginViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/9/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftOverlays
class LoginViewController: UIViewController {

    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var btnRegister: UIButton!

    var reachability:Reachability?
    var tokenDaysAdded:NSDate = NSDate()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        do{
            if UserDefaults.standard.object(forKey: "UserID") != nil
            {
                print(UserDefaults.standard.object(forKey: "nameUser") as Any)
                print("Is Login")
                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let newViewController = mainstoryboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                self.navigationController?.pushViewController(newViewController, animated: true)
            }
            else{
                print("Not Login")
            }

        }
        catch{
            print("Not Login")
        }
        self.tabBarController?.tabBar.isHidden = true
    }


    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //showNavigationBar()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        designPart()
        // Do any additional setup after loading the view.
    }



    @IBAction func LoginButton(_ sender: Any) {
        if txtUserName.text != "" && txtPassword.text != ""{
            apiCalling()
        }
        else{
            let alert = UIAlertController(title: "", message: "You must enter your username and password", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                action in
                print("Close")
            })
            alert.addAction(closeAction)
            self.present(alert,animated: true,completion: nil)
        }
    }
    @IBAction func RegisterButton(_ sender: Any) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = mainstoryboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    func designPart() {
        //txtUserName.layer.cornerRadius = txtUserName.frame.height/2
        //txtUserName.clipsToBounds = true

        //txtPassword.layer.cornerRadius = txtPassword.frame.height/2
        //txtPassword.clipsToBounds = true

        btnLogin.layer.cornerRadius = btnLogin.frame.height/2
        //btnLogin.clipsToBounds = true
    }
    func apiCalling()  {
        do{
            self.reachability = try Reachability.init()
        }
        catch{
            print( "Unable to start notifier " )
        }
        if ((self.reachability!.connection) != .unavailable ){
            SwiftOverlays.showBlockingWaitOverlayWithText("Waiting")
            let param = [
                "username":self.txtUserName.text!,
                "password":self.txtPassword.text!,
                ] as [String : Any]
            let encodeURL = APILogin
            Alamofire.request(encodeURL, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                //print(response.request)
                print("\(response.result) Login")
                //print(response.response)

                switch response.result{
                case .success(let payload):
                    SwiftOverlays.removeAllBlockingOverlays()
                    if let x = payload as? Dictionary<String,AnyObject>{
                        print(x)
                        let resultValue = x as NSDictionary
                        let code = resultValue["code"] as! Int
                        let message = resultValue ["message"] as! String

                        if(code == 200){
                            //Lay data tu response
                            do{
                                let data = resultValue["data"] as! NSDictionary
                                DispatchQueue.main.async {
                                let token = data["token"] as! String
                                let refreshToken = data["refreshToken"] as! String
                                let user = data["user"] as! NSDictionary
                                let _id = user["_id"] as! String
                                let nameUser = user["full_name"] as! String

                                //Luu token cua user
                                UserDefaults.standard.set(_id, forKey: "UserID")
                                UserDefaults.standard.set(token, forKey:"Token")
                                UserDefaults.standard.set(refreshToken, forKey: "RefreshToken")
                                UserDefaults.standard.set(nameUser,forKey:"nameUser")
                                UserDefaults.standard.set(self.tokenDaysAdded, forKey: "tokenDaysAdded")
                                }
                                // Thong bao dang nhap thanh cong
                                let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: .alert)
                                let closeAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                                    action in
                                    print("OK")
                                    let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                    let newViewController = mainstoryboard.instantiateViewController(withIdentifier: "TabBarController") as! UITabBarController
                                    self.navigationController?.pushViewController(newViewController, animated: true)
                                })
                                alert.addAction(closeAction)
                                self.present(alert,animated: true,completion: nil)
                            }catch{}


                        }else{
                            let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: .alert)
                            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                                action in
                                self.txtPassword.text = ""
                                print("Close")
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
        else{
            let alert = UIAlertController(title: "", message: "Please check your Internet", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                action in
                print("Close")
            })
            alert.addAction(closeAction)
            self.present(alert,animated: true,completion: nil)
        }
    }
}
