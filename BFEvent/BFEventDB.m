//
// Created by undancer on 14-1-2.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "BFCommon.h"
#import "BFEventDB.h"
#import "EncryptedStore.h"

@implementation BFEventDB {

}

+ (instancetype)sharedInstance {
    static BFEventDB *sharedDB;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDB = [self new];
    });
    return sharedDB;
}

- (void)createEvent:(NSString *)eventKey count:(double)count sum:(double)sum segmentation:(NSDictionary *)segmentation timestamp:(NSTimeInterval)timestamp {

    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:context];

    [newManagedObject setValue:eventKey forKey:@"key"];
    [newManagedObject setValue:@(count) forKey:@"count"];
    [newManagedObject setValue:@(sum) forKey:@"sum"];
    [newManagedObject setValue:@(timestamp) forKey:@"timestamp"];
    [newManagedObject setValue:segmentation forKey:@"segmentation"];

    [self saveContext];
}

- (void)deleteEvent:(NSManagedObject *)eventObj {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:eventObj];

    [self saveContext];
}

- (void)addToQueue:(NSString *)postData {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:@"Data" inManagedObjectContext:context];

    [newManagedObject setValue:postData forKey:@"post"];

    [self saveContext];
}

- (void)removeFromQueue:(NSManagedObject *)postDataObj {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:postDataObj];

    [self saveContext];
}

- (NSArray *)getEvents {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];

    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];

    if (error) {
        BOXFISH_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }

    return result;
}

- (NSArray *)getQueue {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Data"];

    NSError *error = nil;
    NSArray *result = [[self managedObjectContext] executeFetchRequest:fetchRequest error:&error];

    if (error) {
        BOXFISH_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }

    return result;
}

- (NSUInteger)getEventCount {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Event"];

    NSError *error = nil;
    NSInteger *count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];

    if (error) {
        BOXFISH_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }

    return count;
}

- (NSUInteger)getQueueCount {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Data"];

    NSError *error = nil;
    NSInteger *count = [[self managedObjectContext] countForFetchRequest:fetchRequest error:&error];

    if (error) {
        BOXFISH_LOG(@"CoreData error %@, %@", error, [error userInfo]);
    }

    return count;
}

- (void)saveContext {
    NSError *error = nil;

    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            BOXFISH_LOG(@"CoreData error %@, %@", error, [error userInfo]);
        }
    }
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Core Data Instance

- (NSManagedObjectContext *)managedObjectContext {

    static NSManagedObjectContext *managedObjectContext;

    if (managedObjectContext != nil) {
        return managedObjectContext;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil) {
            managedObjectContext = [[NSManagedObjectContext alloc] init];
            [managedObjectContext setPersistentStoreCoordinator:coordinator];
        }
    });

    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {

    static NSManagedObjectModel *managedObjectModel;

    if (managedObjectModel != nil) {
        return managedObjectModel;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"event" withExtension:@"momd"];
        managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    });

    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {

    static NSPersistentStoreCoordinator *persistentStoreCoordinator;

    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"event.sqlite"];
        NSDictionary *options = @{
                EncryptedStorePassphraseKey : @"boxfish",
                NSMigratePersistentStoresAutomaticallyOption : @YES,
                NSInferMappingModelAutomaticallyOption : @YES
        };

        NSError *error = nil;

        persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];

        if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(@"CoreData error %@, %@", error, [error userInfo]);
        }

//        if (![persistentStoreCoordinator addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:options error:&error]) {
//            NSLog(@"persistentStoreCoordinator Unresolved error %@, %@", error, [error userInfo]);
//        }
    });

    return persistentStoreCoordinator;
}

@end