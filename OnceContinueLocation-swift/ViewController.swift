//
//  ViewController.swift
//  OnceContinueLocation-swift
//
//  Created by hanxiaoming on 16/12/8.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

import UIKit

class ViewController: UIViewController, AMapLocationManagerDelegate {
    
    var locationManager: AMapLocationManager!
    var locateCount: Int = 0
    var locationgInfoLabel: UILabel!
    var singleLocInfoLabel: UILabel!
    var completionBlock: AMapLocatingCompletionBlock!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "单次&连续定位"
        
        
        configLocationManager()
        configSubview()
        configToolBar()
        configCompletionBlock()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setToolbarHidden(false, animated: false);
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Init
    
    func configLocationManager() {
        locationManager = AMapLocationManager()
        locationManager.delegate = self
        
        //设置不允许系统暂停定位
        locationManager.pausesLocationUpdatesAutomatically = false
        
        //设置允许在后台定位
        locationManager.allowsBackgroundLocationUpdates = true
        
        //开启带逆地理连续定位
        locationManager.locatingWithReGeocode = true
        
        //设置期望定位精度
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //设置定位超时时间
        locationManager.locationTimeout = 10
        
        //设置逆地理超时时间
        locationManager.reGeocodeTimeout = 5
    }
    
    func configSubview() {
        singleLocInfoLabel = UILabel(frame: CGRect(x: 20, y: 40, width: self.view.bounds.width / 2.0 - 40, height: self.view.bounds.height - 150))
        singleLocInfoLabel.backgroundColor = UIColor.clear
        singleLocInfoLabel.textColor = UIColor.black
        singleLocInfoLabel.font = UIFont.systemFont(ofSize: 14)
        singleLocInfoLabel.adjustsFontSizeToFitWidth = true
        singleLocInfoLabel.textAlignment = .left
        singleLocInfoLabel.numberOfLines = 0
        
        self.view.addSubview(singleLocInfoLabel)
        
        locationgInfoLabel = UILabel(frame: CGRect(x: self.view.bounds.width / 2.0 + 20, y: 40, width: self.view.bounds.width / 2.0 - 40, height: self.view.bounds.height - 150))
        locationgInfoLabel.backgroundColor = UIColor.clear
        locationgInfoLabel.textColor = UIColor.black
        locationgInfoLabel.font = UIFont.systemFont(ofSize: 14)
        locationgInfoLabel.adjustsFontSizeToFitWidth = true
        locationgInfoLabel.textAlignment = .left
        locationgInfoLabel.numberOfLines = 0
        
        self.view.addSubview(locationgInfoLabel)
        
    }
    
    func configToolBar() {
        let flexibleItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        let segmentControl = UISegmentedControl(items: ["进行单次定位",
                                                        "进行连续定位"])
        segmentControl.addTarget(self, action:#selector(self.locateAction(sender:)), for: UIControlEvents.valueChanged)
        let segmentItem = UIBarButtonItem(customView: segmentControl)
        self.toolbarItems = [flexibleItem, segmentItem, flexibleItem]
        
    }
    
    func configCompletionBlock() {
        self.completionBlock = { [weak self] (location, regeo, error) -> Void in
            if error != nil {
                print("locError: %@", error!.localizedDescription)
                self?.singleLocInfoLabel.text = String(format: "locError: %@", error!.localizedDescription)
                return
            }
            
            if location != nil {
                self?.updateLabelWithLocation(location, regeocode: regeo, isSerial: false)
            }
        }
    }
    
    //MARK: - Helpers
    
    func locateAction(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            // stop locating
            locationManager.stopUpdatingLocation()
            self.locateCount = 0
            
            // 进行单次定位
            locationManager.requestLocation(withReGeocode: true, completionBlock: self.completionBlock)
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateLabelWithLocation(_ location: CLLocation!, regeocode: AMapLocationReGeocode?, isSerial: Bool) {
        
        let locType: String = isSerial ? String(format: "连续定位完成:%d", self.locateCount) : "单次定位完成";
        
        var infoString = String(format: "%@\n\n回调时间:%@\n经 度:%.6f\n纬 度:%.6f\n精 度:%.3f米\n海 拔:%.3f米\n速 度:%.3f\n角 度:%.3f\n", locType, location.timestamp.description, location.coordinate.longitude, location.coordinate.latitude, location.horizontalAccuracy, location.altitude, location.speed, location.course)

        if regeocode != nil {
            let regeoString = String(format: "国 家:%@\n省:%@\n市:%@\n城市编码:%@\n区:%@\n区域编码:%@\n地 址:%@\n兴趣点:%@\n", regeocode!.country, regeocode!.province, regeocode!.city, regeocode!.citycode, regeocode!.district, regeocode!.adcode, regeocode!.formattedAddress, regeocode!.poiName)
            
            infoString = infoString + regeoString
        }
        
        if isSerial {
            self.locationgInfoLabel.text = infoString
        }
        else {
            self.singleLocInfoLabel.text = infoString
        }
        
    }
    
    //MARK: - AMapLocationManagerDelegate
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        print("Error:\(error)")
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        print("Location:\(location)")
        
        self.locateCount += 1
        updateLabelWithLocation(location, regeocode: reGeocode, isSerial: true)
        
    }
    
    
}

