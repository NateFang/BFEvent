//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BFConnectionQueue : NSObject

@property(nonatomic, copy) NSString *appKey;
@property(nonatomic, copy) NSString *appHost;
@property(nonatomic, retain) NSURLConnection *connection;
@property(nonatomic, assign) UIBackgroundTaskIdentifier bgTask;

+ (instancetype)sharedInstance;

- (void)beginSession;

- (void)updateSessionWithDuration:(int)duration;

- (void)endSessionWithDuration:(int)duration;

- (void)recordEvents:(NSString *)events;

@end