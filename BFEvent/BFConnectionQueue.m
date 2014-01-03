//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFConnectionQueue.h"
#import "BFEventDB.h"
#import "BFCommon.h"
#import "BFDeviceInfo.h"

@interface BFConnectionQueue () <NSURLConnectionDataDelegate>
@end

@implementation BFConnectionQueue {

}

+ (instancetype)sharedInstance {

    static BFConnectionQueue *sharedConnectionQueue = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedConnectionQueue = [self new];
    });

    return sharedConnectionQueue;
}

- (void)tick {
    NSArray *dataQueue = [[[BFEventDB sharedInstance] getQueue] copy];

    if (self.connection != nil || self.bgTask != UIBackgroundTaskInvalid || [dataQueue count] == 0) {
        return;
    }

    UIApplication *application = [UIApplication sharedApplication];
    self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];

    NSString *data = [[dataQueue firstObject] valueForKey:@"post"];

    NSString *urlString = [NSString stringWithFormat:@"%@/i?%@", self.appHost, data];
    NSLog(@"urlString -> %@", urlString);
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
}

- (void)beginSession {

    NSLog(@"beginSession");

    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&sdk_version="    BOXFISH_VERSION
                                                        "&begin_session=1&metrics=%@", self.appKey, [BFDeviceInfo udid], time(NULL), [BFDeviceInfo metrics]];

    [[BFEventDB sharedInstance] addToQueue:data];
    [self tick];
}

- (void)updateSessionWithDuration:(int)duration {
    NSLog(@"updateSessionWithDuration");


    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&session_duration=%d",
                                                self.appKey,
                                                [BFDeviceInfo udid],
                                                time(NULL),
                                                duration];

    [[BFEventDB sharedInstance] addToQueue:data];
    [self tick];
}

- (void)endSessionWithDuration:(int)duration {
    NSLog(@"endSessionWithDuration");

    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&end_session=1&session_duration=%d",
                                                self.appKey,
                                                [BFDeviceInfo udid],
                                                time(NULL),
                                                duration];

    [[BFEventDB sharedInstance] addToQueue:data];
    [self tick];

}

- (void)recordEvents:(NSString *)events {
    NSString *data = [NSString stringWithFormat:@"app_key=%@&device_id=%@&timestamp=%ld&events=%@", self.appKey, @"device_id", time(NULL), events];

    [[BFEventDB sharedInstance] addToQueue:data];
    [self tick];
}

#pragma mark -
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSArray *dataQueue = [[[BFEventDB sharedInstance] getQueue] copy];
    BOXFISH_LOG(@"ok -> %@", [dataQueue firstObject]);

    UIApplication *application = [UIApplication sharedApplication];
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }

    self.connection = nil;

    [[BFEventDB sharedInstance] removeFromQueue:[dataQueue firstObject]];

    [self tick];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
#if BOXFISH_DEBUG
    NSArray *dataQueue = [[[BFEventDB sharedInstance] getQueue] copy];
    BOXFISH_LOG(@"error -> %@: %@", [dataQueue firstObject], error);
#endif

    UIApplication *application = [UIApplication sharedApplication];
    if (self.bgTask != UIBackgroundTaskInvalid) {
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }
    self.connection = nil;
}

- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [[challenge sender] useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }
    [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end