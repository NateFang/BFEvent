//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BFEventEntity : NSObject


@property(nonatomic, copy) NSString *key;
@property(nonatomic, retain) NSDictionary *segmentation;
@property(nonatomic, assign) int count;
@property(nonatomic, assign) double sum;
@property(nonatomic, assign) NSTimeInterval timestamp;

+ (BFEventEntity *)objectWithManagedObject:(NSManagedObject *)managedObject;

- (NSDictionary *)serializedData;

@end