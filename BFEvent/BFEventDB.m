//
// Created by undancer on 14-1-2.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

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


}

- (NSUInteger)getEventCount {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSLog(@"%@", context);
    return 0;
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

        if (![persistentStoreCoordinator addPersistentStoreWithType:EncryptedStoreType configuration:nil URL:storeURL options:options error:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    });

    return persistentStoreCoordinator;
}

@end