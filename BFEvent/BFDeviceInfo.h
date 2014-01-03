//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BFDeviceInfo : NSObject

+ (NSString *)udid;

+ (NSString *)device;

+ (NSString *)osVersion;

+ (NSString *)carrier;

+ (NSString *)resolution;

+ (NSString *)locale;

+ (NSString *)appVersion;

+ (NSString *)metrics;

@end