//
//  AppDelegate.h
//  iOS-IMKit-Demo
//
//  Created by Heq.Shinoda on 14-4-30.
//  Copyright (c) 2014年 iOS-IMKit-Demo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "RCHttpRequest.h"
#import "RCIM.h"
#import "BMapKit.h"


@interface AppDelegate : UIResponder <UIApplicationDelegate, BMKGeneralDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BMKMapManager *mapManager;

@property (strong, nonatomic) NSMutableArray *friendList;
@end
