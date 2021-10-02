//
//  Constants.swift
//  GoogleMapsApplication
//
//  Created by Ahmad Berro on 01/10/2021.
//
import UIKit
import GoogleMaps
import GoogleMobileAds
let googleApiKey = "AIzaSyAiAir1uMz3NwJDd9vjIhqeEuTUgw2S7VM"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,GADFullScreenContentDelegate {
  var window: UIWindow?
  var interstitial: GADInterstitial!
  var gViewController = UIViewController()
  
  var appOpenAd: GADAppOpenAd?
  var loadTime = Date()
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    GADMobileAds.sharedInstance().start(completionHandler: nil)
    GMSServices.provideAPIKey(googleApiKey)
    return true
  }
  func requestAppOpenAd() {
    let request = GADRequest()
    GADAppOpenAd.load(withAdUnitID: "ca-app-pub-3940256099942544/5662855259",
                      request: request,
                      orientation: UIInterfaceOrientation.portrait,
                      completionHandler: { (appOpenAdIn, error) in
      self.appOpenAd = appOpenAdIn
      self.appOpenAd?.fullScreenContentDelegate = self
      self.loadTime = Date()
      if let rwc = self.window?.rootViewController {
        self.appOpenAd!.present(fromRootViewController: rwc)
      }
    })
  }
  func applicationDidBecomeActive(_ application: UIApplication) {
    self.requestAppOpenAd()
  }
}

