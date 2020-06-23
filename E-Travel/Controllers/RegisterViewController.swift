//
//  RegisterViewController.swift
//  e-Travel
//
//  Created by Kii Nguyen on 3/5/20.
//  Copyright © 2020 Kii Nguyen. All rights reserved.
//

import UIKit
import Alamofire
import SwiftOverlays

class RegisterViewController: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnRegister: UIButton!

    var reachability:Reachability?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        designPart()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func LoginButton(_ sender: Any) {
        let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let newViewController = mainstoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        self.navigationController?.pushViewController(newViewController, animated: true)
    }
    @IBAction func ButtonRegister(_ sender: Any) {
        if txtUsername.text != "" && txtPassword.text != "" && txtEmail.text != ""{
            apiCalling()
        }
        else{
            let alert = UIAlertController(title: "", message: "Please all field are required", preferredStyle: .alert)
            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                action in
                print("Close")
            })
            alert.addAction(closeAction)
            self.present(alert,animated: true,completion: nil)
        }

    }

    func designPart() {
        //txtUsername.layer.cornerRadius = txtUsername.frame.height/2
        //txtUsername.clipsToBounds = true

        //txtPassword.layer.cornerRadius = txtPassword.frame.height/2
        //txtPassword.clipsToBounds = true

        //txtName.layer.cornerRadius = txtName.frame.height/2
        //txtName.clipsToBounds = true

        //txtPhoneNumber.layer.cornerRadius = txtPhoneNumber.frame.height/2
        //txtPhoneNumber.clipsToBounds = true

        //txtEmail.layer.cornerRadius = txtEmail.frame.height/2
        //txtEmail.clipsToBounds = true

        btnRegister.layer.cornerRadius = btnRegister.frame.height/2
       // btnRegister.clipsToBounds = true

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
                "username":self.txtUsername.text!,
                "password":self.txtPassword.text!,
                //"full_name":txtName.text!,
                "gender": 1,
                "email": self.txtEmail.text! ,
                "phone_num":self.txtPhoneNumber.text!,
                ] as [String : Any]
            let encodeURL = APIRegister
            Alamofire.request(encodeURL, method: .post, parameters: param, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
                //print(response.request)
                print("\(response.result) register")
                //print(response.response)

                switch response.result{
                case .success(let payload):
                    self.removeAllOverlays()
                    if let x = payload as? Dictionary<String,AnyObject>{
                        print(x)
                        let resultValue = x as NSDictionary
                        let code = resultValue["code"] as! Int
                        let message = resultValue ["message"] as! String

                        if(code == 200){
                            //let data = resultValue["data"] as! NSDictionary
                            //let token = data["token"] as! String
                            //let user = data["user"] as! [NSDictionary]
                            let alert = UIAlertController(title: "", message: "\(message)", preferredStyle: .alert)
                            let closeAction = UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler:{
                                action in
                                print("Close")
                                let mainstoryboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let newViewController = mainstoryboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                                self.navigationController?.pushViewController(newViewController, animated: true)
                            })
                            alert.addAction(closeAction)
                            self.present(alert,animated: true,completion: nil)

                        }else{
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
