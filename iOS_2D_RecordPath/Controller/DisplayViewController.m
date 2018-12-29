
//
//  DisplayViewController.m
//  iOS_2D_RecordPath
//
//  Created by PC on 15/8/3.
//  Copyright (c) 2015年 FENGSHENG. All rights reserved.
//

#import "DisplayViewController.h"
#import "Record.h"
#import "SHTimeLabel.h"
#import "RecordViewController.h"
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
//屏幕宽高
#define WIDTH ([UIScreen mainScreen].bounds.size.width)
#define HEIGHT ([UIScreen mainScreen].bounds.size.height)
@interface DisplayViewController()<MAMapViewDelegate>{
    NSMutableArray * _speedColors;
    CLLocationCoordinate2D * _runningCoords;
    NSUInteger _count;
    
    MAMultiPolyline * _polyline;
}

@property (nonatomic, strong) Record *record;

@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) MAPointAnnotation *myLocation;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) double averageSpeed;

@property (nonatomic, assign) NSInteger currentLocationIndex;

@property(nonatomic,strong)UIView *overView;

@property (nonatomic, strong) UIView *kmBackView;
@property (nonatomic, strong) UILabel *km;

@property (nonatomic, strong) UIView *middleView;
@property (nonatomic, strong) UIView *middleOne;
@property (nonatomic, strong) UILabel *rateNum;
@property (nonatomic, strong) UILabel *rate;


@property (nonatomic, strong) UIView *middleTwo;
@property (nonatomic, strong) SHTimeLabel *timeLabel;
@property (nonatomic, strong) UILabel *time;

@property (nonatomic, strong) UIView *middleThree;
@property (nonatomic, strong) UILabel *kill;

@property (nonatomic, strong) UILabel *kmNum;
@property (nonatomic, strong) UILabel *killNum;
@property(nonatomic,assign)NSInteger accumulatedTime;


@end


@implementation DisplayViewController



#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"跑步结束";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"重新开始" style:UIBarButtonItemStylePlain target:self action:@selector(reStart)];
    
    [self initMapView];
    
    [self initToolBar];
    
    [self showRoute];
    
    [self initVariates];
    
    [self showData];
}


- (void)reStart{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - Utility

- (UIView *)overView{
    if (!_overView) {
        _overView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _overView.backgroundColor = [UIColor blackColor];
        _overView.alpha = 0.5;
    }
    return _overView;
}

#pragma mark - init data
- (UIColor *)getColorForSpeed:(float)speed
{
    const float lowSpeedTh = 2.f;
    const float highSpeedTh = 3.5f;
    const CGFloat warmHue = 0.02f; //偏暖色
    const CGFloat coldHue = 0.4f; //偏冷色
    
    float hue = coldHue - (speed - lowSpeedTh)*(coldHue - warmHue)/(highSpeedTh - lowSpeedTh);
    return [UIColor colorWithHue:hue saturation:1.f brightness:1.f alpha:1.f];
}

- (void)showRoute
{
    if (self.record == nil || [self.record numOfLocations] == 0)
    {
        NSLog(@"invaled route");
    }
    _speedColors = [NSMutableArray array];
    
   
    
    NSMutableArray * indexes = [NSMutableArray array];
  
        
        _count = [self.record numOfLocations];
        _runningCoords = (CLLocationCoordinate2D *)malloc(_count * sizeof(CLLocationCoordinate2D));
        
        for (int i = 0; i < _count; i++)
        {
            @autoreleasepool
            {
                _runningCoords[i].latitude = self.record.coordinates[i].latitude;
                _runningCoords[i].longitude = self.record.coordinates[i].longitude;
                
                UIColor * speedColor = [self getColorForSpeed: [self.record totalDistance] / [self.record totalDuration]];
                [_speedColors addObject:speedColor];
                
                [indexes addObject:@(i)];
            }
        }
    
    _polyline = [MAMultiPolyline polylineWithCoordinates:_runningCoords count:_count drawStyleIndexes:@[@0,@(_count)]];
    [self.mapView addOverlay:_polyline];

    const CGFloat screenEdgeInset = 85;
    UIEdgeInsets inset = UIEdgeInsetsMake(screenEdgeInset, screenEdgeInset, screenEdgeInset, screenEdgeInset);
    [self.mapView setVisibleMapRect:_polyline.boundingMapRect edgePadding:inset animated:NO];
    
    MAPointAnnotation *startPoint = [[MAPointAnnotation alloc] init];
    startPoint.coordinate = [self.record startLocation].coordinate;
    startPoint.title = @"start";
    [self.mapView addAnnotation:startPoint];
    
    MAPointAnnotation *endPoint = [[MAPointAnnotation alloc] init];
    endPoint.coordinate = [self.record endLocation].coordinate;
    endPoint.title = @"end";
    [self.mapView addAnnotation:endPoint];
    
    self.averageSpeed = [self.record totalDistance] / [self.record totalDuration];
}

#pragma mark - Interface

- (void)setRecord:(Record *)record
{
    _record = record;
}

#pragma mark - mapViewDelegate

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if([annotation isEqual:self.myLocation]) {
        
        static NSString *annotationIdentifier = @"myLcoationIdentifier";
        
        MAAnnotationView *poiAnnotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        poiAnnotationView.image = [UIImage imageNamed:@"aeroplane.png"];
        poiAnnotationView.canShowCallout = NO;
        
        return poiAnnotationView;
    }
    
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *annotationIdentifier = @"lcoationIdentifier";
        
        MAPinAnnotationView *poiAnnotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:annotationIdentifier];
        
        if (poiAnnotationView == nil)
        {
            poiAnnotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationIdentifier];
        }
        
        poiAnnotationView.animatesDrop = YES;
        poiAnnotationView.canShowCallout = YES;
        return poiAnnotationView;
    }
    
    return nil;
}

- (MAOverlayRenderer*)mapView:(MAMapView *)mapView rendererForOverlay:(id<MAOverlay>)overlay
{
    if (overlay == _polyline)
    {
        MAMultiColoredPolylineRenderer * polylineRenderer = [[MAMultiColoredPolylineRenderer alloc] initWithMultiPolyline:overlay];
        
        polylineRenderer.lineWidth = 8.f;
        polylineRenderer.strokeColors = @[[UIColor colorWithRed:1.000 green:0.784 blue:0.000 alpha:1.00], [UIColor colorWithRed:0.894 green:0.522 blue:0.000 alpha:1.00]];
        polylineRenderer.gradient = YES;
        
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - Action

- (void)actionPlayAndStop
{
    if (self.record == nil)
    {
        return;
    }
    
    self.isPlaying = !self.isPlaying;
    if (self.isPlaying)
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_stop.png"];
        if (self.myLocation == nil)
        {
            self.myLocation = [[MAPointAnnotation alloc] init];
            self.myLocation.title = @"AMap";
            self.myLocation.coordinate = [self.record startLocation].coordinate;
            
            [self.mapView addAnnotation:self.myLocation];
        }
        
        [self animateToNextCoordinate];
    }
    else
    {
        self.navigationItem.rightBarButtonItem.image = [UIImage imageNamed:@"icon_play.png"];
        
        MAAnnotationView *view = [self.mapView viewForAnnotation:self.myLocation];
        
        if (view != nil)
        {
            [view.layer removeAllAnimations];
        }
    }
}

- (void)animateToNextCoordinate
{
    if (self.myLocation == nil)
    {
        return;
    }
    
    CLLocationCoordinate2D *coordinates = [self.record coordinates];
    if (self.currentLocationIndex == [self.record numOfLocations] )
    {
        self.currentLocationIndex = 0;
        [self actionPlayAndStop];
        return;
    }
    
    CLLocationCoordinate2D nextCoord = coordinates[self.currentLocationIndex];
    CLLocationCoordinate2D preCoord = self.currentLocationIndex == 0 ? nextCoord : self.myLocation.coordinate;
    
    double heading = [self coordinateHeadingFrom:preCoord To:nextCoord];
    CLLocationDistance distance = MAMetersBetweenMapPoints(MAMapPointForCoordinate(nextCoord), MAMapPointForCoordinate(preCoord));
    NSTimeInterval duration = distance / (self.averageSpeed * 100);
    
    [UIView animateWithDuration:duration
                     animations:^{
                        self.myLocation.coordinate = nextCoord;}
                     completion:^(BOOL finished){
                         self.currentLocationIndex++;
                         if (finished)
                         {
                             [self animateToNextCoordinate];
                         }}];
    MAAnnotationView *view = [self.mapView viewForAnnotation:self.myLocation];
    if (view != nil)
    {
        view.transform = CGAffineTransformMakeRotation((CGFloat)(heading/180.0*M_PI));
    }
}

- (double)coordinateHeadingFrom:(CLLocationCoordinate2D)head To:(CLLocationCoordinate2D)rear
{
    if (!CLLocationCoordinate2DIsValid(head) || !CLLocationCoordinate2DIsValid(rear))
    {
        return 0.0;
    }

    double delta_lat_y = rear.latitude - head.latitude;
    double delta_lon_x = rear.longitude - head.longitude;
    
    if (fabs(delta_lat_y) < 0.000001)
    {
        return delta_lon_x < 0.0 ? 270.0 : 90.0;
    }
    
    double heading = atan2(delta_lon_x, delta_lat_y) / M_PI * 180.0;
    
    if (heading < 0.0)
    {
        heading += 360.0;
    }
    return heading;
}

#pragma mark - Initialazation

- (void)initToolBar
{
    UIBarButtonItem *listItem = [[UIBarButtonItem alloc] initWithTitle:@"运动记录" style:UIBarButtonItemStylePlain target:self action:@selector(showList)];
//    UIBarButtonItem *playItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_play.png"] style:UIBarButtonItemStylePlain target:self action:@selector(actionPlayAndStop)];
    self.navigationItem.rightBarButtonItem = listItem;
}

- (void)showList{
    RecordViewController *recordController = [[RecordViewController alloc] init];
     [self.navigationController pushViewController:recordController animated:YES];
    
}

- (void)initMapView
{
    self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.mapView.showsScale = NO;
    self.mapView.showsCompass = NO;
    self.mapView.delegate = self;
//    [self.mapView setCustomMapStyleEnabled:YES];
//    for (UIView *subview in self.mapView.subviews) {
//        if ([subview isKindOfClass:[MAAnnotationView class]]) {
//            subview.backgroundColor = [UIColor redColor];
//        }
//    }
    [self.mapView addSubview:self.overView];
    [self.view addSubview:self.mapView];
    
}

- (void)initVariates
{
    self.isPlaying = NO;
    self.currentLocationIndex = 0;
    self.averageSpeed = 2;
}

- (void)showData{
    self.kmBackView = [[UIView alloc]
                       initWithFrame:CGRectMake((WIDTH-110)/2, HEIGHT*0.68, 110, 60)];
    [self.view addSubview:self.kmBackView];
    self.kmNum = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 60, 60)];
    self.kmNum.text = self.record.kmNumText;
    self.kmNum.textAlignment = NSTextAlignmentCenter;
    self.kmNum.textColor = [UIColor whiteColor];
    self.kmNum.adjustsFontSizeToFitWidth = YES;
    self.kmNum.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:50];
    [self.kmBackView addSubview:self.kmNum];
    self.km = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.kmNum.bounds)+2, CGRectGetMaxY(self.kmNum.bounds)-28, 60, 13)];
    self.km.text = @"KM";
    self.km.textAlignment = NSTextAlignmentCenter;
    self.km.textColor = [UIColor whiteColor];
    self.km.adjustsFontSizeToFitWidth = YES;
    self.km.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:13];
    [self.kmBackView addSubview:self.km];
    
    self.middleView = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT*0.83, WIDTH, 60)];
    [self.view addSubview:self.middleView];
    
    self.middleOne = [[UIView alloc] initWithFrame:CGRectMake(0, 0, (WIDTH/7)*2, 60)];
    [self.middleView addSubview:self.middleOne];
    self.rateNum = [[UILabel alloc] initWithFrame:CGRectMake(5,0, (WIDTH/7)*2-10, 30)];
    self.rateNum.text = self.record.ratNumText;
    self.rateNum.textAlignment = NSTextAlignmentCenter;
    self.rateNum.textColor = [UIColor whiteColor];
    self.rateNum.adjustsFontSizeToFitWidth = YES;
    self.rateNum.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
    [self.middleOne addSubview:self.rateNum];
    self.rate = [[UILabel alloc] initWithFrame:CGRectMake(5,30, (WIDTH/7)*2-10, 30)];
    self.rate.text = @"配速";
    self.rate.textAlignment = NSTextAlignmentCenter;
    self.rate.textColor = [UIColor whiteColor];
    self.rate.adjustsFontSizeToFitWidth = YES;
    self.rate.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [self.middleOne addSubview:self.rate];
    
    self.middleTwo = [[UIView alloc] initWithFrame:CGRectMake((WIDTH/7)*2, 0, (WIDTH/7)*3, 60)];
    [self.middleView addSubview:self.middleTwo];
    self.timeLabel = [[SHTimeLabel alloc] init];
    [self.timeLabel setTextColor:[UIColor whiteColor]];
    self.timeLabel.userInteractionEnabled = NO;
    [self.timeLabel setBoldWithFontSize:30];
    self.timeLabel.frame = CGRectMake(5,0, (WIDTH/7)*3-10, 30);
    [self.timeLabel resetTimeLabelWithTotalSeconds:self.record.accumulatedTime];
    [self.middleTwo addSubview:self.timeLabel];
    self.time = [[UILabel alloc] initWithFrame:CGRectMake(5,30, (WIDTH/7)*3-10, 30)];
    self.time.text = @"时间";
    self.time.textAlignment = NSTextAlignmentCenter;
    self.time.textColor = [UIColor whiteColor];
    self.time.adjustsFontSizeToFitWidth = YES;
    self.time.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [self.middleTwo addSubview:self.time];
    
    self.middleThree = [[UIView alloc] initWithFrame:CGRectMake((WIDTH/7)*5,0, (WIDTH/7)*2, 60)];
    [self.middleView addSubview:self.middleThree];
    self.killNum = [[UILabel alloc] initWithFrame:CGRectMake(5,0, (WIDTH/7)*2-10, 30)];
    self.killNum.text = self.record.killNumText;
    self.killNum.textAlignment = NSTextAlignmentCenter;
    self.killNum.textColor = [UIColor whiteColor];
    self.killNum.adjustsFontSizeToFitWidth = YES;
    self.killNum.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:30];
    [self.middleThree addSubview:self.killNum];
    self.kill = [[UILabel alloc] initWithFrame:CGRectMake(5,30, (WIDTH/7)*2-10, 30)];
    self.kill.text = @"消耗";
    self.kill.textAlignment = NSTextAlignmentCenter;
    self.kill.textColor = [UIColor whiteColor];
    self.kill.adjustsFontSizeToFitWidth = YES;
    self.kill.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    [self.middleThree addSubview:self.kill];
}


- (void)dealloc
{
    if (_runningCoords)
    {
        free(_runningCoords);
        _count = 0;
    }
}

@end
