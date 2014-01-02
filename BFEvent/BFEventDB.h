//
// Created by undancer on 14-1-2.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BFEventDB : NSObject

+ (instancetype)sharedInstance;

- (void)createEvent:(NSString *)eventKey count:(double)count sum:(double)sum segmentation:(NSDictionary *)segmentation timestamp:(NSTimeInterval)timestamp;

- (void)addToQueue:(NSString *)postData;

- (void)deleteEvent:(NSManagedObject *)eventObj;

- (void)removeFromQueue:(NSManagedObject *)postDataObj;

- (NSArray *)getEvents;

- (NSArray *)getQueue;

- (NSUInteger)getEventCount;

- (NSUInteger)getQueueCount;

- (void)saveContext;

@end