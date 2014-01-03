//
// Created by undancer on 14-1-2.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFEventQueue.h"
#import "BFEventEntity.h"
#import "BFCommon.h"
#import "BFEventDB.h"

@implementation BFEventQueue {

}
- (NSUInteger)count {
    @synchronized (self) {
        return [[BFEventDB sharedInstance] getEventCount];
    }
}

- (NSString *)events {
    NSMutableArray *result = [NSMutableArray array];

    @synchronized (self) {
        NSArray *events = [[[BFEventDB sharedInstance] getEvents] copy];

        for (NSManagedObject *managedEventObject in events) {
            BFEventEntity *event = [BFEventEntity objectWithManagedObject:managedEventObject];
            [result addObject:[event serializedData]];

            [[BFEventDB sharedInstance] deleteEvent:managedEventObject];
        }
    }
    return BFURLEscapedString(BFJSONFromObject(result));
}

- (void)recordEvent:(NSString *)key count:(int)count {
    @synchronized (self) {
        NSArray *events = [[[BFEventDB sharedInstance] getEvents] copy];
        for (NSManagedObject *obj in events) {
            BFEventEntity *event = [BFEventEntity objectWithManagedObject:obj];
            if ([event.key isEqualToString:key]) {
                event.count += count;
                event.timestamp += (event.timestamp + time(NULL)) / 2;

                [obj setValue:@(event.count) forKey:@"count"];
                [obj setValue:@(event.timestamp) forKey:@"timestamp"];

                [[BFEventDB sharedInstance] saveContext];
                return;
            }
        }

        BFEventEntity *event = [BFEventEntity new];

        event.key = key;
        event.count = count;
        event.timestamp = time(NULL);

        [[BFEventDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

- (void)recordEvent:(NSString *)key count:(int)count sum:(double)sum {
    @synchronized (self) {
        NSArray *events = [[[BFEventDB sharedInstance] getEvents] copy];

        for (NSManagedObject *obj in events) {
            BFEventEntity *event = [BFEventEntity objectWithManagedObject:obj];
            if ([event.key isEqualToString:key]) {
                event.count += count;
                event.sum += sum;
                event.timestamp += (event.timestamp + time(NULL)) / 2;

                [obj setValue:@(event.count) forKey:@"count"];
                [obj setValue:@(event.sum) forKey:@"sum"];
                [obj setValue:@(event.timestamp) forKey:@"timestamp"];

                [[BFEventDB sharedInstance] saveContext];
                return;
            }
        }

        BFEventEntity *event = [BFEventEntity new];

        event.key = key;
        event.count = count;
        event.sum = sum;
        event.timestamp = time(NULL);

        [[BFEventDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count {
    @synchronized (self) {
        NSArray *events = [[[BFEventDB sharedInstance] getEvents] copy];

        for (NSManagedObject *obj in events) {
            BFEventEntity *event = [BFEventEntity objectWithManagedObject:obj];
            if ([event.key isEqualToString:key] && event.segmentation && [event.segmentation isEqualToDictionary:segmentation]) {
                event.count += count;
                event.timestamp += (event.timestamp + time(NULL)) / 2;

                [obj setValue:@(event.count) forKey:@"count"];
                [obj setValue:@(event.timestamp) forKey:@"timestamp"];

                [[BFEventDB sharedInstance] saveContext];
                return;
            }
        }

        BFEventEntity *event = [BFEventEntity new];

        event.key = key;
        event.count = count;
        event.segmentation = segmentation;
        event.timestamp = time(NULL);

        [[BFEventDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

- (void)recordEvent:(NSString *)key segmentation:(NSDictionary *)segmentation count:(int)count sum:(double)sum {
    @synchronized (self) {
        NSArray *events = [[[BFEventDB sharedInstance] getEvents] copy];

        for (NSManagedObject *obj in events) {
            BFEventEntity *event = [BFEventEntity objectWithManagedObject:obj];
            if ([event.key isEqualToString:key] && event.segmentation && [event.segmentation isEqualToDictionary:segmentation]) {
                event.count += count;
                event.sum += sum;
                event.timestamp += (event.timestamp + time(NULL)) / 2;

                [obj setValue:@(event.count) forKey:@"count"];
                [obj setValue:@(event.sum) forKey:@"sum"];
                [obj setValue:@(event.timestamp) forKey:@"timestamp"];

                [[BFEventDB sharedInstance] saveContext];
                return;
            }
        }

        BFEventEntity *event = [BFEventEntity new];

        event.key = key;
        event.count = count;
        event.sum = sum;
        event.segmentation = segmentation;
        event.timestamp = time(NULL);

        [[BFEventDB sharedInstance] createEvent:event.key count:event.count sum:event.sum segmentation:event.segmentation timestamp:event.timestamp];
    }
}

@end