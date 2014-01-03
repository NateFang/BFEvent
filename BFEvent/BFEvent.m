//
// Created by undancer on 14-1-2.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFEvent.h"
#import "BFEventDB.h"
#import "BFEventQueue.h"
#import "BFConnectionQueue.h"

@implementation BFEvent {

}

+ (instancetype)sharedInstance {
    static BFEvent *sharedEvent = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedEvent = [self new];
    });
    return sharedEvent;
}

- (id)init {
    if (self = [super init]) {
        timer = nil;
        isSuspended = NO;
        unsentSessionLength = 0;
        eventQueue = [[BFEventQueue alloc] init];

        NSLog(@"INIT");

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundCallBack:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForegroundCallBack:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willTerminateCallBack:) name:UIApplicationWillTerminateNotification object:nil];

    }
    return self;
}

- (void)start:(NSString *)appKey withHost:(NSString *)appHost {
    timer = [NSTimer scheduledTimerWithTimeInterval:BOXFISH_DEFAULT_UPDATE_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
    lastTime = CFAbsoluteTimeGetCurrent();
    [[BFConnectionQueue sharedInstance] setAppKey:appKey];
    [[BFConnectionQueue sharedInstance] setAppHost:appHost];
    [[BFConnectionQueue sharedInstance] beginSession];
}

- (void)recordEvent:(NSString *)key count:(int)count {
    [eventQueue recordEvent:key count:count];

//    if ([eventQueue count] >= BOXFISH_EVENT_SEND_THRESHOLD) {
//        [[BFConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
//    }
}

- (void)recordEvent:(NSString *)key count:(int)count sum:(double)sum {
    [eventQueue recordEvent:key count:count sum:sum];

    if ([eventQueue count] >= BOXFISH_EVENT_SEND_THRESHOLD) {
        [[BFConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
    }
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count {
    [eventQueue recordEvent:key segmentation:segmentation count:count];

    if ([eventQueue count] >= BOXFISH_EVENT_SEND_THRESHOLD) {
        [[BFConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
    }
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count sum:(double)sum {
    [eventQueue recordEvent:key segmentation:segmentation count:count sum:sum];

    if ([eventQueue count] >= BOXFISH_EVENT_SEND_THRESHOLD) {
        [[BFConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
    }
}

- (void)onTimer:(NSTimer *)timer {
    if (isSuspended == YES) {
        return;
    }

    double currTime = CFAbsoluteTimeGetCurrent();
    unsentSessionLength += currTime - lastTime;
    lastTime = currTime;

    int duration = unsentSessionLength;
    [[BFConnectionQueue sharedInstance] updateSessionWithDuration:duration];
    unsentSessionLength -= duration;

    if ([eventQueue count] > 0) {
        [[BFConnectionQueue sharedInstance] recordEvents:[eventQueue events]];
    }
}

- (void)suspend {
    isSuspended = YES;
    if ([eventQueue count] > 0) {
        [[BFConnectionQueue sharedInstance] recordEvents:[eventQueue events]];

        double currTime = CFAbsoluteTimeGetCurrent();
        unsentSessionLength += currTime - lastTime;


        int duration = unsentSessionLength;
        [[BFConnectionQueue sharedInstance] endSessionWithDuration:duration];
        unsentSessionLength -= duration;
    }
}

- (void)resume {

    lastTime = CFAbsoluteTimeGetCurrent();

    [[BFConnectionQueue sharedInstance] beginSession];

    isSuspended = NO;
}

- (void)exit {

}

- (void)didEnterBackgroundCallBack:(NSNotification *)notification {
    BOXFISH_LOG(@"didEnterBackgroundCallBack");
    [self suspend];
}

- (void)willEnterForegroundCallBack:(NSNotification *)notification {
    BOXFISH_LOG(@"willEnterForegroundCallBack");
    [self resume];
}

- (void)willTerminateCallBack:(NSNotification *)notification {
    BOXFISH_LOG(@"willTerminateCallBack");
    [[BFEventDB sharedInstance] saveContext];
    [self exit];
}
@end