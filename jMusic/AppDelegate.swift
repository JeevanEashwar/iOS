//
//  AppDelegate.swift
//  jMusic
//
//  Created by Jeevan on 22/07/17.
//  Copyright © 2017 personal. All rights reserved.
//

import UIKit
import GoogleSignIn
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    enum appThemeStyles:String {
        case ApplicationThemeStyleDark
        case ApplicationThemeStyleDefault
    }
    var appTheme:appThemeStyles = .ApplicationThemeStyleDefault
    let ApplicationThemeStyleDark="Dark"
    let ApplicationThemeStyleDefault="Default"
    let darkThemeBGColor=UIColor.darkGray
    let defaultThemeBGColor=UIColor.white
    let darkThemeTextColor=UIColor.white
    let defaultThemeTextColor=UIColor.darkText
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Initialize sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().shouldFetchBasicProfile=true
        return true
    }
    func application(_ application: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool{
        return GIDSignIn.sharedInstance().handle(url as URL!,
                                                 sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String!,
                                                 annotation: options[UIApplicationOpenURLOptionsKey.annotation])
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            // user.userID & user.authentication.idToken are For client-side use only!
            // Safe to send to the server
            print("\(user.profile.givenName) is signed in")
            if let wd = UIApplication.shared.delegate?.window {
                var vc = wd!.rootViewController
                if(vc is UITabBarController){
                    vc = (vc as! UITabBarController).selectedViewController
                }
                if(vc is SecondViewController){
                    //update the UI after log in success
                    let controller = vc as! SecondViewController
                    controller.emailId.isHidden = false
                    controller.emailId.text = user.profile.email
                    controller.AccountName.text = user.profile.name
                    if user.profile.hasImage{
                        let picUrl = user.profile.imageURL(withDimension: UInt(controller.profilePic.frame.size.height))
                        
                        DispatchQueue.global().async {
                            let data = try? Data(contentsOf: picUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                            DispatchQueue.main.async {
                                controller.profilePic.image = UIImage(data: data!)
                            }
                        }
                        
                    }
                    controller.signInButton.isHidden = true
                    controller.signOutButton.isHidden = false
                }
            }
            
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...

    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        let tabBarController = self.window?.rootViewController as! UITabBarController
//        tabBarController.selectedIndex = 2
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}


