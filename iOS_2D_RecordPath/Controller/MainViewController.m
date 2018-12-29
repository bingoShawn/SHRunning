//
//  BaseMapViewController.m
//  SearchV3Demo
//
//  Created by songjian on 13-8-14.
//  Copyright (c) 2013年 songjian. All rights reserved.
//

#import "MainViewController.h"
#import "MAMutablePolyline.h"
#import "MAMutablePolylineRenderer.h"
#import "MAMutablePolylineRenderer.h"
#import "StatusView.h"
#import "TipView.h"
#import "Record.h"
#import "FileHelper.h"
#import "RecordViewController.h"
#import "SystemInfoView.h"
#import "SHTimeLabel.h"
#import "SHTimeManager.h"
#import "DisplayViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "SHHealthKitManager.h"

//屏幕宽高
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)

@interface MainViewController()<SHTimeManagerDelegate,AMapLocationManagerDelegate>{
    
}

@property (nonatomic, strong) MAMapView *mapView;
@property(nonatomic,strong)AMapLocationManager *locationManager;
@property (nonatomic, strong) TipView *tipView;



@property (nonatomic, strong) UIView *kmBackView;
@property (nonatomic, strong) UILabel *kmNum;
@property (nonatomic, strong) UILabel *km;

@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *middleOne;
@property (nonatomic, strong) UILabel *rateNum;
@property (nonatomic, strong) UILabel *rate;


@property (nonatomic, strong) UIView *middleTwo;
@property (nonatomic, strong) SHTimeLabel *timeLabel;
@property (nonatomic, strong) UILabel *time;

@property (nonatomic, strong) UIView *middleThree;
@property (nonatomic, strong) UILabel *killNum;
@property (nonatomic, strong) UILabel *kill;

@property (nonatomic, strong) UIButton *pauseBtn;
@property (nonatomic, strong) UIButton *endBtn;
@property (nonatomic, strong) UIButton *continueBtn;





@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) SHTimeManager *timeManager;
@property (nonatomic, strong) UIButton *locationBtn;
@property (nonatomic, strong) UIImage *imageLocated;
@property (nonatomic, strong) UIImage *imageNotLocate;
@property (nonatomic, strong) SystemInfoView *systemInfoView;

@property (nonatomic, assign) BOOL isRecording;
@property (nonatomic, assign) NSInteger updateuLocationTimes;   // 系统回调更新定位数据的次数


@property (nonatomic, strong) MAMutablePolyline *mutablePolyline;
@property (nonatomic, strong) MAMutablePolylineRenderer *render;

@property (nonatomic, strong) NSMutableArray *locationsArray;

@property (nonatomic, strong) NSMutableArray *recordsArray;
@property(nonatomic,assign)double totalDistance;

@property (nonatomic, strong) Record *currentRecord;



@end


@implementation MainViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.currentRecord = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showRoute];
    [self actionRecordAndStop];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.updateuLocationTimes = 0;

    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 2;
    self.locationManager.locatingWithReGeocode = YES;
    
    //iOS 9（不包含iOS 9） 之前设置允许后台定位参数，保持不会被系统挂起
    [self.locationManager setPausesLocationUpdatesAutomatically:NO];
    
    //iOS 9（包含iOS 9）之后新特性：将允许出现这种场景，同一app中多个locationmanager：一些只能在前台定位，另一些可在后台定位，并可随时禁止其后台定位。
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
        self.locationManager.allowsBackgroundLocationUpdates = YES;
    }
    //开始持续定位
    [self.locationManager setLocatingWithReGeocode:YES];

    [self.locationManager startUpdatingLocation];
    
    
    [self setTitle:@"跑步中"];
   
    [self initNavigationBar];
    //地图
    [self initMapView];
    
//    [self initTipView];
    //公里数
    [self setKmUI];
    //中间
    [self setMidlleUI];
    //底部
    [self setBottomUI];
    
    [self initOverlay];
    
    [self initTimeManager];
    
        [self initLocationButton];
}

- (void)setKmUI{
    self.kmBackView = [[UIView alloc]
                       initWithFrame:CGRectMake((WIDTH-110)/2, HEIGHT*0.35, 110, 60)];
    [self.view addSubview:self.kmBackView];
    self.kmNum = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
    self.kmNum.text = @"0.0";
    self.kmNum.textAlignment = NSTextAlignmentCenter;
    self.kmNum.textColor = [UIColor blackColor];
    self.kmNum.adjustsFontSizeToFitWidth = YES;
    self.kmNum.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:50];
    [self.kmBackView addSubview:self.kmNum];
    self.km = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.kmNum.bounds)+2, CGRectGetMaxY(self.kmNum.bounds)-28, 60, 13)];
    self.km.text = @"KM";
    self.km.textAlignment = NSTextAlignmentCenter;
    self.km.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.00];
    self.km.adjustsFontSizeToFitWidth = YES;
    self.km.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13];
    [self.kmBackView addSubview:self.km];
}

- (void)setMidlleUI{
    self.middleView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT*0.5, WIDTH, 60)];
    [self.view addSubview:self.middleView];
    
    self.middleOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (WIDTH/7)*2, 60)];
    [self.middleView addSubview:self.middleOne];
    self.rateNum = [[UILabel alloc] initWithFrame:CGRectMake(5,0, (WIDTH/7)*2-10, 30)];
    self.rateNum.text = @"0'00\"";
    self.rateNum.textAlignment = NSTextAlignmentCenter;
    self.rateNum.textColor = [UIColor blackColor];
    self.rateNum.adjustsFontSizeToFitWidth = YES;
    self.rateNum.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
    [self.middleOne addSubview:self.rateNum];
    self.rate = [[UILabel alloc] initWithFrame:CGRectMake(5,30, (WIDTH/7)*2-10, 30)];
    self.rate.text = @"配速";
    self.rate.textAlignment = NSTextAlignmentCenter;
    self.rate.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.00];
    self.rate.adjustsFontSizeToFitWidth = YES;
    self.rate.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [self.middleOne addSubview:self.rate];
    
    self.middleTwo = [[UIView alloc] initWithFrame:CGRectMake((WIDTH/7)*2, 0, (WIDTH/7)*3, 60)];
    [self.middleView addSubview:self.middleTwo];
    self.timeLabel = [[SHTimeLabel alloc] init];
    self.timeLabel.userInteractionEnabled = NO;
    [self.timeLabel setBoldWithFontSize:30];
    self.timeLabel.frame = CGRectMake(5,0, (WIDTH/7)*3-10, 30);
    [self.middleTwo addSubview:self.timeLabel];
    self.time = [[UILabel alloc] initWithFrame:CGRectMake(5,30, (WIDTH/7)*3-10, 30)];
    self.time.text = @"时间";
    self.time.textAlignment = NSTextAlignmentCenter;
    self.time.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.00];
    self.time.adjustsFontSizeToFitWidth = YES;
    self.time.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [self.middleTwo addSubview:self.time];
    
    self.middleThree = [[UIView alloc] initWithFrame:CGRectMake((WIDTH/7)*5,0, (WIDTH/7)*2, 60)];
    [self.middleView addSubview:self.middleThree];
    self.killNum = [[UILabel alloc] initWithFrame:CGRectMake(5,0, (WIDTH/7)*2-10, 30)];
    self.killNum.text = @"0";
    self.killNum.textAlignment = NSTextAlignmentCenter;
    self.killNum.textColor = [UIColor blackColor];
    self.killNum.adjustsFontSizeToFitWidth = YES;
    self.killNum.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
    [self.middleThree addSubview:self.killNum];
    self.kill = [[UILabel alloc] initWithFrame:CGRectMake(5,30, (WIDTH/7)*2-10, 30)];
    self.kill.text = @"消耗";
    self.kill.textAlignment = NSTextAlignmentCenter;
    self.kill.textColor = [UIColor colorWithRed:0.600 green:0.600 blue:0.600 alpha:1.00];
    self.kill.adjustsFontSizeToFitWidth = YES;
    self.kill.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [self.middleThree addSubview:self.kill];
}

- (void)setBottomUI{
    self.bottomView = [[UIView alloc] initWithFrame:CGRectMake(0,self.middleView.frame.origin.y+self.middleView.frame.size.height+40, WIDTH,120)];
    [self.view addSubview:self.bottomView];
    self.pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseBtn.frame = CGRectMake(WIDTH/2-40, 20, 80, 80);
    self.pauseBtn.layer.cornerRadius = 40;
    [self.pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
    self.pauseBtn.backgroundColor = [UIColor colorWithRed:1.000 green:0.816 blue:0.000 alpha:1.00];
    [self.pauseBtn addTarget:self action:@selector(actionRecordAndStop) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.pauseBtn];
    
    self.endBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.endBtn.frame = CGRectMake(self.pauseBtn.frame.origin.x-80, 20, 80, 80);
    self.endBtn.layer.cornerRadius = 40;
    [self.endBtn setTitle:@"结束" forState:UIControlStateNormal];
    self.endBtn.backgroundColor = [UIColor colorWithRed:1.000 green:0.259 blue:0.263 alpha:1.00];
    [self.endBtn addTarget:self action:@selector(actionClear) forControlEvents:UIControlEventTouchUpInside];
    self.endBtn.hidden = YES;
    self.endBtn.userInteractionEnabled = NO;
    [self.bottomView addSubview:self.endBtn];
    
    self.continueBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.continueBtn.frame = CGRectMake(self.pauseBtn.frame.origin.x+80, 20, 80, 80);
    self.continueBtn.layer.cornerRadius = 40;
    [self.continueBtn setTitle:@"继续" forState:UIControlStateNormal];
    self.continueBtn.backgroundColor = [UIColor colorWithRed:0.000 green:0.776 blue:0.420 alpha:1.00];
    [self.continueBtn addTarget:self action:@selector(actionRecordAndStop) forControlEvents:UIControlEventTouchUpInside];
    self.continueBtn.hidden = YES;
    self.continueBtn.userInteractionEnabled = NO;
    [self.bottomView addSubview:self.continueBtn];
    
    }


#pragma mark - AMapLocationManagerDelegate
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location reGeocode:(AMapLocationReGeocode *)reGeocode
{
    
    if (self.isRecording)
    {
//        [[SHHealthKitManager shareInstance] authorizeHealthKit:^(BOOL success, NSError *error) {
//            if (success) {
//                [[SHHealthKitManager shareInstance] getBodyMassIndexFromHealthKitWithUnit:nil withCompltion:^(double value, NSError *error) {
//                    NSLog(@"体重指数:%.2f",value);
//                }];
//            } else {
//                NSLog(@"获取失败 error: %@",error);
//            }
//        }];
        //忽略前几个飘忽不定点
        self.updateuLocationTimes++;
        NSInteger ignoreTimes = 4;
        if (self.updateuLocationTimes <= ignoreTimes)
        {
            return;
        }
        
        if (location.horizontalAccuracy < 80 && location.horizontalAccuracy > 0)
        {
            [self.locationsArray addObject:location];
            
            [self.tipView showTip:[NSString stringWithFormat:@"has got %lu locations",(unsigned long)self.locationsArray.count]];
            
            [self.currentRecord addLocation:location];
            
            double km = [self.currentRecord totalDistance]/1000;
            
            double minute = [self.currentRecord totalDuration]/60;
            //计算配速
            double rate = minute/km;
            
            int intMinute = floor(rate);
            
            int intSecond =  round((floor(rate*100) / 100-intMinute)*60);
            
            self.currentRecord.kmNumText = [NSString stringWithFormat:@"%.2f", km];
            self.kmNum.text = self.currentRecord.kmNumText;
            //刚开始位置有小距离波动，大于一定距离时才进行配速计算，否则配速得到的值会很大
            if ([self.currentRecord totalDistance] < 70) {
                self.currentRecord.ratNumText = @"0'00\"";
            }else{
                if (intMinute>60) {
                    self.currentRecord.ratNumText = @">60'00\"";
                }else{
                    self.currentRecord.ratNumText = [NSString stringWithFormat:@"%i'%i\"",intMinute,intSecond];
                }
            }
            self.rateNum.text = self.currentRecord.ratNumText;

            
            
            //计算卡路里
            
            NSString *weightRecord = [[NSUserDefaults standardUserDefaults] objectForKey:@"userWeight"];
            //跑步运动系数
            double k = 1.036;
            
            double calorieValue = [weightRecord intValue]*km*k;
            
            self.currentRecord.killNumText = [NSString stringWithFormat:@"%.1f",calorieValue];
            self.killNum.text = self.currentRecord.killNumText;
            
            [self.mutablePolyline appendPoint: MAMapPointForCoordinate(location.coordinate)];
            
            [self.mapView setCenterCoordinate:location.coordinate animated:YES];
            
            [self.render invalidatePath];
        }
    }
    
    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", location.coordinate.latitude, location.coordinate.longitude, location.horizontalAccuracy);
    if (reGeocode)
    {
        NSLog(@"reGeocode:%@", reGeocode);
    }
}



- (MAOverlayPathRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MAMutablePolyline class]])
    {
        MAMutablePolylineRenderer *renderer = [[MAMutablePolylineRenderer alloc] initWithOverlay:overlay];
        renderer.lineWidth = 8.f;
        
        renderer.strokeColor = [UIColor colorWithRed:0.000 green:0.992 blue:0.839 alpha:1.00];
        self.render = renderer;
        
        return renderer;
    }
    
    return nil;
}

- (void)mapView:(MAMapView *)mapView  didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated
{
    if (mode == MAUserTrackingModeNone)
    {
        [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    }
    else
    {
        [self.locationBtn setImage:self.imageLocated forState:UIControlStateNormal];
        [self.mapView setZoomLevel:17.2 animated:YES];
    }
}

#pragma mark - Handle Action

- (void)actionRecordAndStop
{
    self.isRecording = !self.isRecording;
    
    if (self.isRecording)
    {
        [self.tipView showTip:@"Start recording"];
        self.pauseBtn.hidden = NO;
        self.pauseBtn.userInteractionEnabled = YES;
        self.endBtn.hidden = YES;
        self.endBtn.userInteractionEnabled = NO;
        self.continueBtn.hidden = YES;
        self.continueBtn.userInteractionEnabled = NO;
        [self.timeManager start];
        if (self.currentRecord == nil)
        {
            self.currentRecord = [[Record alloc] init];
        }
    }
    else
    {
        self.pauseBtn.hidden = YES;
        self.pauseBtn.userInteractionEnabled = NO;
        self.endBtn.hidden = NO;
        self.endBtn.userInteractionEnabled = YES;
        self.continueBtn.hidden = NO;
        self.continueBtn.userInteractionEnabled = YES;
        [self.timeManager pause];
        [self.tipView showTip:@"has stoppod recording"];
    }
}

- (void)actionClear
{
    //记录少于3次返回重新开始
//    if (self.updateuLocationTimes < 3) {
//        [self.navigationController popToRootViewControllerAnimated:YES];
//        return;
//     }
    self.isRecording = NO;
    [self.timeManager stop];
    [self.locationsArray removeAllObjects];
    [self.tipView showTip:@"has stoppod recording"];
    [self saveRoute];

    [self.mutablePolyline.pointArray removeAllObjects];
    
    [self.render invalidatePath];
//    [self actionShowList];
        DisplayViewController *displayController = [[DisplayViewController alloc] initWithNibName:nil bundle:nil];
        [displayController setRecord:self.currentRecord];
        [self.navigationController pushViewController:displayController animated:YES];
    
}

- (void)actionLocation
{
    if (self.mapView.userTrackingMode == MAUserTrackingModeFollow)
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeNone];
    }
    else
    {
        [self.mapView setUserTrackingMode:MAUserTrackingModeFollow];
    }
}

- (void)actionShowList
{
    UIViewController *recordController = [[RecordViewController alloc] initWithNibName:nil bundle:nil];    
    [self.navigationController pushViewController:recordController animated:YES];
}

#pragma mark - Utility

- (void)saveRoute
{
    if (self.currentRecord == nil)
    {
        return;
    }
    
    NSString *name = self.currentRecord.title;
    NSString *path = [FileHelper filePathWithName:name];
    
    [NSKeyedArchiver archiveRootObject:self.currentRecord toFile:path];
    
//    self.currentRecord = nil;
}

#pragma mark - Initialization


- (void)initSystemInfoView
{
    self.systemInfoView = [[SystemInfoView alloc] initWithFrame:CGRectMake(5, 35 + 150 + 10, 150, 140)];
    
    [self.view addSubview:self.systemInfoView];
}

- (void)initTipView
{
    self.locationsArray = [[NSMutableArray alloc] init];
    
    self.tipView = [[TipView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height*0.95, self.view.bounds.size.width, self.view.bounds.size.height*0.05)];
    
    [self.view addSubview:self.tipView];
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, HEIGHT*0.4)];
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    //使地图开始时显示当前定位
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
            /* set the mapview location config */
    self.mapView.showsUserLocation = true;
    self.mapView.distanceFilter = 10;
    self.mapView.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    self.mapView.pausesLocationUpdatesAutomatically = NO;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];

}

- (void)initTimeManager
{
    self.timeManager = [[SHTimeManager alloc] init];
    self.timeManager.delegate = self;
}


#pragma mark - YSTimeManagerDelegate

- (void)tickWithAccumulatedTime:(NSUInteger)time
{
    self.currentRecord.accumulatedTime = time;
    [self.timeLabel resetTimeLabelWithTotalSeconds:time];
}


- (void)initNavigationBar
{
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
   
    
    
    
//    UIBarButtonItem *listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location_no"] style:UIBarButtonItemStylePlain target:self action:@selector(ShareCounte)];

    
//    NSArray *array = [[NSArray alloc] initWithObjects:listButton, clearButton, nil];
//    self.navigationItem.rightBarButtonItems = array;
//    self.navigationItem.rightBarButtonItem = listButton;
    
    self.isRecording = NO;
}

- (void)ShareCounte{
    NSLog(@"ShareCounte");
}


- (void)initOverlay
{
    self.mutablePolyline = [[MAMutablePolyline alloc] initWithPoints:@[]];
}

- (void)initLocationButton
{
    self.imageLocated = [UIImage imageNamed:@"location_yes.png"];
    self.imageNotLocate = [UIImage imageNamed:@"location_no.png"];
    
    self.locationBtn = [[UIButton alloc] initWithFrame:CGRectMake(WIDTH-52, CGRectGetMaxY(self.mapView.frame)-52, 50, 50)];
    self.locationBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.locationBtn.backgroundColor = [UIColor clearColor];
    self.locationBtn.layer.cornerRadius = 5;
    [self.locationBtn addTarget:self action:@selector(actionLocation) forControlEvents:UIControlEventTouchUpInside];
    [self.locationBtn setImage:self.imageNotLocate forState:UIControlStateNormal];
    
    [self.mapView addSubview:self.locationBtn];
}



- (void)showRoute{
    [self.mapView addOverlay:self.mutablePolyline];
    //设定map初始缩放水平
    [self.mapView setZoomLevel:17.2 animated:YES];
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
}



@end
