//
//  ViewController.swift
//  AltitudeLongtitude
//
//  Created by Nick Slobodsky on 26/10/2018.
//  Copyright © 2018 Nick Slobodsky. All rights reserved.
//


import UIKit
import CoreLocation
import CoreMotion

class ViewController: UIViewController {
    
    @IBOutlet weak var gradientView: GradientView!
    
    @IBOutlet weak var gpsAltitudeLabel: UILabel!
    
    @IBOutlet weak var altitudeMarginOfErrorLabel: UILabel!
    
    @IBOutlet weak var altimiterLabel: UILabel!
    
    private var backgroundImageview = UIImageView()
    
    let locationManager = CLLocationManager()
    
    let altimeter = CMAltimeter()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setBackground()
        
        checkLocationServices()
        
        startTrackingAltitudeChanges()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        gradientView.setupGradient()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        altimeter.stopRelativeAltitudeUpdates()
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle
        {
            return .lightContent
        }
    
    deinit
    {
        altimeter.stopRelativeAltitudeUpdates()
    }
    
    func setupLocationManager()
    {
        locationManager.delegate = self
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func checkLocationServices()
    {
        if CLLocationManager.locationServicesEnabled()
        {
            setupLocationManager()
            
            checkLocationAuthorization()
        }
        else
        {
            let alert = UIAlertController(title: "alert", message: "Turn on your location service !", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Alert !", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
    }
    
    func checkLocationAuthorization()
    {
        switch CLLocationManager.authorizationStatus()
        {
            case .authorizedWhenInUse :
            
            locationManager.startUpdatingLocation()
            
            break
            
            case .denied :
            
                let alert = UIAlertController(title: "alert", message: "Turn on permissions !", preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Alert !", style: .default, handler: nil))
                
                self.present(alert, animated: true)
            
                break
            
            case .notDetermined :
            
            locationManager.requestWhenInUseAuthorization()
            
            break
            
            case .restricted :
            
            break
            
            case .authorizedAlways :
            
            break
        }
    }
    
    func setBackground()
    {
        backgroundImageview = UIImageView(frame: CGRect.zero)
        
        backgroundImageview.image = #imageLiteral(resourceName: "altitude-background.jpeg")
        
        backgroundImageview.contentMode = .scaleAspectFill
        
        view.addSubview(backgroundImageview)
        
        view.sendSubviewToBack(backgroundImageview)
        
        backgroundImageview.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundImageview.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        
        backgroundImageview.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        backgroundImageview.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        backgroundImageview.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func startTrackingAltitudeChanges()
    {
        guard CMAltimeter.isRelativeAltitudeAvailable() else
        {
            let alert = UIAlertController(title: "alert", message: "Data isn't available !", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Alert !", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            
            return
        }
        
        let queue = OperationQueue()
        
        queue.qualityOfService = .background
        
        altimeter.startRelativeAltitudeUpdates(to: queue) { (altimeterData, error) in
            
            if let altimeterData = altimeterData
            {
                DispatchQueue.main.async {
                    
                    let relativeAltitude = altimeterData.relativeAltitude as! Double
                    
                    let roundedAltitude = Int(relativeAltitude.rounded(toDecimalPlaces: 0))
                    
                    self.altimiterLabel.text = "\(roundedAltitude)m"
                    
                }
            }
            
        }
        
    }


}

extension ViewController : CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {return}
        
        let altitude = location.altitude.rounded(toDecimalPlaces: 0)
        
        gpsAltitudeLabel.text = "+/-   \(location.verticalAccuracy)m"
        
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        checkLocationAuthorization()
        
    }
}
