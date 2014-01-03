//
// Created by undancer on 14-1-3.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFEventEntity.h"


@implementation BFEventEntity {

}

+ (BFEventEntity *)objectWithManagedObject:(NSManagedObject *)managedObject {
    BFEventEntity *event = [BFEventEntity new];

    event.key = [managedObject valueForKey:@"key"];
    event.count = [[managedObject valueForKey:@"count"] intValue];
    event.sum = [[managedObject valueForKey:@"sum"] doubleValue];
    event.timestamp = [[managedObject valueForKey:@"timestamp"] doubleValue];
    event.segmentation = [managedObject valueForKey:@"segmentation"];

    return event;
}

- (NSDictionary *)serializedData {
    NSMutableDictionary *eventData = [NSMutableDictionary dictionary];
    [eventData setObject:self.key forKey:@"key"];
    if (self.segmentation) {
        [eventData setObject:self.segmentation forKey:@"segmentation"];
    }
    [eventData setObject:@(self.count) forKey:@"count"];
    [eventData setObject:@(self.sum) forKey:@"sum"];
    [eventData setObject:@(self.timestamp) forKey:@"timestamp"];

    return eventData;
}
@end