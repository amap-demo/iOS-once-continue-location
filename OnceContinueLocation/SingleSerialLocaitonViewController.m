//
//  SingleSerialLocaitonViewController.m
//  OnceContinueLocation
//
//  Created by liubo on 11/4/16.
//  Copyright © 2016 AutoNavi. All rights reserved.
//

#import "SingleSerialLocaitonViewController.h"

#define DefaultLocationTimeout 10
#define DefaultReGeocodeTimeout 5

@interface SingleSerialLocaitonViewController ()<AMapLocationManagerDelegate>

@property (nonatomic, copy) AMapLocatingCompletionBlock completionBlock;

@property (nonatomic, strong) UISegmentedControl *showSegment;

@property (nonatomic, assign) NSInteger locateCount;
@property (nonatomic, strong) UILabel *singleLocInfoLabel;
@property (nonatomic, strong) UILabel *locationgInfoLabel;

@end

@implementation SingleSerialLocaitonViewController

#pragma mark - Action Handle

- (void)configLocationManager
{
    self.locationManager = [[AMapLocationManager alloc] init];
    
    [self.locationManager setDelegate:self];
    
    //设置期望定位精度
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyKilometer];
    
    //设置不允许系统暂停定位
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //设置允许在后台定位
    [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    
    //开启带逆地理连续定位
    [self.locationManager setLocatingWithReGeocode:YES];
    
    //设置定位超时时间
    [self.locationManager setLocationTimeout:DefaultLocationTimeout];
    
    //设置逆地理超时时间
    [self.locationManager setReGeocodeTimeout:DefaultReGeocodeTimeout];
}

- (void)showsSegmentAction:(UISegmentedControl *)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        //停止连续定位
        [self.locationManager stopUpdatingLocation];
        
        self.locateCount = 0;
        
        //进行单次定位
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:self.completionBlock];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        //开始进行连续定位
        [self.locationManager startUpdatingLocation];
    }
}

- (void)updateLabelTextWithLocation:(CLLocation *)location regeocode:(AMapLocationReGeocode *)regeocode serial:(BOOL)isSerial
{
    NSString *locType = isSerial ? [NSString stringWithFormat:@"连续定位完成:%d", (int)self.locateCount] : @"单次定位完成";
    
    NSMutableString *infoString = [NSMutableString stringWithFormat:@"%@\n\n回调时间:%@\n经 度:%f\n纬 度\t:%f\n精 度:%f米\n海 拔:%f米\n速 度:%f\n角 度:%f\n", locType, location.timestamp, location.coordinate.longitude, location.coordinate.latitude, location.horizontalAccuracy, location.altitude, location.speed, location.course];
    
    if (regeocode)
    {
        NSString *regeoString = [NSString stringWithFormat:@"国 家:%@\n省:%@\n市:%@\n城市编码:%@\n区:%@\n区 域:%@\n地 址:%@\n兴趣点:%@\n", regeocode.country, regeocode.province, regeocode.city, regeocode.citycode, regeocode.district, regeocode.adcode, regeocode.formattedAddress, regeocode.POIName];
        [infoString appendString:regeoString];
    }
    
    if (isSerial)
    {
        [self.locationgInfoLabel setText:infoString];
    }
    else
    {
        [self.singleLocInfoLabel setText:infoString];
    }
}

#pragma mark - AMapLocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s, amapLocationManager = %@, error = %@", __func__, [manager class], error);
}

- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    
    self.locateCount += 1;
    
    [self updateLabelTextWithLocation:location regeocode:reGeocode serial:YES];
}

#pragma mark - Initialization

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

- (void)initToolBar
{
    UIBarButtonItem *flexble = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                             target:nil
                                                                             action:nil];
    
    self.showSegment = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"进行单次定位", @"进行连续定位", nil]];
    [self.showSegment addTarget:self action:@selector(showsSegmentAction:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *showItem = [[UIBarButtonItem alloc] initWithCustomView:self.showSegment];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexble, showItem, flexble, nil];
}

- (void)configSubview
{
    self.locationgInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds)/2+20, 40, CGRectGetWidth(self.view.bounds)/2.0-40, CGRectGetHeight(self.view.bounds)-150)];
    [self.locationgInfoLabel setBackgroundColor:[UIColor clearColor]];
    [self.locationgInfoLabel setTextColor:[UIColor blackColor]];
    [self.locationgInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.locationgInfoLabel setAdjustsFontSizeToFitWidth:YES];
    [self.locationgInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.locationgInfoLabel setNumberOfLines:0];
    
    [self.view addSubview:self.locationgInfoLabel];
    
    self.singleLocInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, CGRectGetWidth(self.view.bounds)/2.0-40, CGRectGetHeight(self.view.bounds)-150)];
    [self.singleLocInfoLabel setBackgroundColor:[UIColor clearColor]];
    [self.singleLocInfoLabel setTextColor:[UIColor blackColor]];
    [self.singleLocInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [self.singleLocInfoLabel setAdjustsFontSizeToFitWidth:YES];
    [self.singleLocInfoLabel setTextAlignment:NSTextAlignmentLeft];
    [self.singleLocInfoLabel setNumberOfLines:0];
    
    [self.view addSubview:self.singleLocInfoLabel];
}

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.title = @"单次和连续定位";
    
    self.locateCount = 0;
    
    [self initToolBar];
    
    [self initCompleteBlock];
    
    [self configSubview];
    
    [self configLocationManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.toolbar.translucent       = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.toolbarHidden             = NO;
    self.navigationController.toolbar.translucent       = NO;
}

@end
