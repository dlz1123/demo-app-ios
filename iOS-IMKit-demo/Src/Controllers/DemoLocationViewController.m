//
//  DemoLocationViewController.m
//  iOS-IMKit-demo
//
//  Created by YangZigang on 14/11/7.
//  Copyright (c) 2014年 RongCloud. All rights reserved.
//

#import "DemoLocationViewController.h"
#import "BMapKit.h"

@interface DemoAnnotationForBaidu : NSObject <BMKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;


@end

@implementation DemoAnnotationForBaidu


@end

@interface DemoLocationViewController ()
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, strong) NSString *locationName;
@end

@implementation DemoLocationViewController

- (instancetype)initWithLocation:(CLLocationCoordinate2D)location locationName:(NSString*)locationName {
    if (self = [super init]) {
        self.location = location;
        self.locationName = locationName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    BMKCoordinateRegion region;
    region.center = self.location;
    region.span.longitudeDelta = 0.001;
    region.span.latitudeDelta = self.mapView.frame.size.height / self.mapView.frame.size.width * 0.001;
    [self.mapView setRegion:region];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.title = self.locationName;
    DemoAnnotationForBaidu *annotation = [[DemoAnnotationForBaidu alloc] init];
    annotation.title = self.locationName;
    [annotation setCoordinate:self.location];
    [self.mapView addAnnotation:annotation];
    [self.mapView selectAnnotation:annotation animated:NO];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    if (!self.title) {
        self.title = @"位置信息";
    }
    [self configureNavigationBar];
}


- (void)configureNavigationBar {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 6, 42, 23);
    NSString *filePath = [[NSBundle mainBundle].bundlePath stringByAppendingString:@"/RongCloud.bundle/navigator_btn_back"];
    UIImage *backImg = [[UIImage alloc] initWithContentsOfFile:filePath];
    UIImageView* backImgView = [[UIImageView alloc] initWithImage:backImg];
    backImgView.frame = CGRectMake(-10, 0, 22, 22);
    [backBtn addSubview:backImgView];
    UILabel* backText = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, 40, 22)];
    backText.text = @"返回";
    backText.font = [UIFont systemFontOfSize:15];
    [backText setBackgroundColor:[UIColor clearColor]];
    [backText setTextColor:[UIColor whiteColor]];
    [backBtn addSubview:backText];
    [backBtn addTarget:self action:@selector(leftBarButtonItemPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [self.navigationItem setLeftBarButtonItem:leftButton];
    
    UILabel* titleLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    titleLab.font = [UIFont systemFontOfSize:18];
    [titleLab setBackgroundColor:[UIColor clearColor]];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.tag = 1000;
    self.navigationItem.titleView=titleLab;
    titleLab.text = self.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
