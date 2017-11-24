//
//  SecondViewController.swift
//  jMusic
//
//  Created by Jeevan on 22/07/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController,GIDSignInUIDelegate {

    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var signInButton: GIDSignInButton!
    @IBOutlet var emailId: UILabel!
    @IBOutlet var AccountName: UILabel!
    @IBOutlet var profilePic: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
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
    @IBAction func didTapSignOut(sender: AnyObject) {
        print("\(GIDSignIn.sharedInstance().currentUser.profile.givenName) signed out successfully")
        GIDSignIn.sharedInstance().signOut()
        signInButton.isHidden = false
        signOutButton.isHidden = true
        emailId.isHidden = true
        AccountName.text = "Guest Account"
        profilePic.image = UIImage(named:"Profile_avatar_placeholder_large")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

