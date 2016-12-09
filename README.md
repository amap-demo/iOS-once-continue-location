本工程为基于高德地图iOS 定位SDK进行封装，实现了单次定位功能和连续定位功能。
## 前述 ##
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[开发指南](http://lbs.amap.com/api/ios-location-sdk/summary/).
- 工程基于iOS 定位SDK实现.

## 功能描述 ##
演示定位SDK的单次定位功能和连续定位功能。

## 核心类/接口 ##
| 类    | 接口  | 说明   | 版本  |
| -----|:-----:|:-----:|:-----:|
| AMapLocationManager	| - (BOOL)requestLocationWithReGeocode:(BOOL)withReGeocode completionBlock:(AMapLocatingCompletionBlock)completionBlock; | 单次定位接口 | v2.0.0 |
| AMapLocationManager	| - (void)startUpdatingLocation; | 连续定位接口 | v2.0.0 |

## 核心难点 ##

`Objective-C`

```
/* 单次定位. */
- (void)initCompleteBlock
{
    __weak SingleSerialLocaitonViewController *weakSelf = self;
    self.completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
    {
        if (error)
        {
            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            [weakSelf.singleLocInfoLabel setText:[NSString stringWithFormat:@"locError:{%ld - %@};", (long)error.code, error.localizedDescription]];
            
            return;
        }
        
        //得到定位信息
        if (location)
        {
            [weakSelf updateLabelTextWithLocation:location regeocode:regeocode serial:NO];
        }
    };
}

/* 进行单次定位 */
[self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];

/* 连续定位回调. */
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    //记录定位次数
    self.locateCount += 1;
    
    [self updateLabelTextWithLocation:location regeocode:reGeocode serial:YES];
}
```

`Swift`
```
/* 单次定位. */
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

/* 连续定位回调. */
func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        print("Location:\(location)")
        
        self.locateCount += 1
        updateLabelWithLocation(location, regeocode: reGeocode, isSerial: true)
        
}


```
