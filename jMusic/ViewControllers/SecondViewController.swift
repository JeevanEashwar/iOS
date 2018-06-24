//
//  SecondViewController.swift
//  jMusic
//
//  Created by Jeevan on 22/07/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,GIDSignInUIDelegate {

    @IBOutlet weak var superViewBackGroundImageView: UIImageView!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var appThemeLabel: UILabel!
    @IBOutlet var AppThemeStyle: UISegmentedControl!
    @IBOutlet var signInButton: GIDSignInButton!
    @IBOutlet var emailId: UILabel!
    @IBOutlet var AccountName: UILabel!
    @IBOutlet var profilePic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradientToBackGround()
        profilePic.layoutIfNeeded()
        profilePic.layer.cornerRadius = profilePic.frame.height / 2.0
        profilePic.layer.masksToBounds = true
        emailId.isHidden = true
        signOutButton.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
        GIDSignIn.sharedInstance().uiDelegate = self
        signInButton.colorScheme=GIDSignInButtonColorScheme.dark
        signInButton.style=GIDSignInButtonStyle.wide
        var googleServicesDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") {
            googleServicesDict = NSDictionary(contentsOfFile: path)
        }
        if let dict = googleServicesDict {
            // Use your dict here
            GIDSignIn.sharedInstance().clientID = dict["CLIENT_ID"] as! String
        }
        
    }
    private func addGradientToBackGround(){
        let view = UIView(frame: self.view.frame)
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
//        let firstColor = UIColor(red: 207/255, green: 217/255, blue: 223/255, alpha: 0.7).cgColor
        let lastColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        let firstColor = UIColor.clear.cgColor
        //let lastColor = UIColor.black.cgColor
        gradient.colors = [lastColor,firstColor,lastColor,firstColor,lastColor]
        gradient.locations = [0.0,0.3,0.5,0.8,1.0]
        view.layer.insertSublayer(gradient, at: 0)
        superViewBackGroundImageView.addSubview(view)
        superViewBackGroundImageView.bringSubview(toFront: view)
        // 1
        let darkBlur = UIBlurEffect(style: UIBlurEffectStyle.regular)
        // 2
        let blurView = UIVisualEffectView(effect: darkBlur)
        blurView.frame = view.bounds
        blurView.alpha = 0.9
        // 3
        superViewBackGroundImageView.addSubview(blurView)
    }
    @IBAction func didTapSignOut(sender: AnyObject) {
        print("\(GIDSignIn.sharedInstance().currentUser.profile.givenName) signed out successfully")
        GIDSignIn.sharedInstance().signOut()
        signInButton.isHidden = false
        signOutButton.isHidden = true
        emailId.isHidden = true
        AccountName.text = "Guest Account"
        profilePic.image = UIImage(named:"Profile_avatar_placeholder_large")
    }

    
    @IBAction func AppThemeStyleValueChanged(_ sender: UISegmentedControl) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let selectedTitle=sender.titleForSegment(at: sender.selectedSegmentIndex)
        var vcBGColor:UIColor
        var vcTextColor:UIColor
        vcBGColor=appDelegate.defaultThemeBGColor
        vcTextColor=appDelegate.defaultThemeTextColor
        if(selectedTitle==appDelegate.ApplicationThemeStyleDark){
            vcBGColor=appDelegate.darkThemeBGColor
            vcTextColor=appDelegate.darkThemeTextColor
            appDelegate.appTheme = .ApplicationThemeStyleDark
        }
        else if(selectedTitle==appDelegate.ApplicationThemeStyleDefault){
            vcBGColor=appDelegate.defaultThemeBGColor
            vcTextColor=appDelegate.defaultThemeTextColor
            appDelegate.appTheme = .ApplicationThemeStyleDefault
        }
        self.view.backgroundColor = vcBGColor
        self.emailId.textColor = vcTextColor
        self.AccountName.textColor = vcTextColor
        self.appThemeLabel.textColor = vcTextColor
        //update home view controller theme
        if let wd = appDelegate.window {
            let rvc = wd.rootViewController
            if(rvc is UITabBarController){
                for vc in (rvc as! UITabBarController).viewControllers!{
                    if(vc is UINavigationController){
                        let navController = vc as! UINavigationController
                        if navController.topViewController is HomeViewController {
                            let homeVC = navController.topViewController as! HomeViewController
                            homeVC.updateViewTheme(themeStyle: selectedTitle!)
                        }
                        
                    }
                    else if(vc is RecordingsViewController){
                        let controller = vc as! RecordingsViewController
                        controller.updateViewTheme(themeStyle: selectedTitle!)
                    }
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

