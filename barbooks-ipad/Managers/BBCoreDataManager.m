//
//  BBCoreDataManager.m
//  barbooks-ipad
//
//  Created by Can on 11/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "BBCoreDataManager.h"
#import <CouchbaseLite/CouchbaseLite.h>
#import "CBLIncrementalStore.h"

@implementation BBCoreDataManager

+ (instancetype)sharedInstance {
    static BBCoreDataManager* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[BBCoreDataManager alloc] init];
    });
    return instance;
}

#pragma mark - Core Data stack

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.companyname.Bar_Book" in the user's Application Support directory.
    NSURL *appSupportURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.censea.BarBooks"];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"BarBooks" withExtension:@"momd"];
    _managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    
    [CBLIncrementalStore updateManagedObjectModel:_managedObjectModel];
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSString *databaseName = @"barbooks";
    NSURL *storeUrl = [NSURL URLWithString:databaseName];
    
    CBLIncrementalStore *store;
    store = (CBLIncrementalStore*)[_persistentStoreCoordinator addPersistentStoreWithType:[CBLIncrementalStore type]
                                                                            configuration:nil
                                                                                      URL:storeUrl options:nil error:&error];
    
    NSURL *remoteDbURL = [NSURL URLWithString:COUCHBASE_SYNC_URL];
    
    CBLReplication *pull = [store.database createPullReplication:remoteDbURL];
    CBLReplication *push = [store.database createPushReplication:remoteDbURL];
    //    pull.channels = @[@"admin"];
//    id<CBLAuthenticator> auth = [CBLAuthenticator basicAuthenticatorWithName:@"admin" password:@"bbadmin"];
//    
//    [push setAuthenticator:auth];
//    [pull setAuthenticator:auth];
    
    [self startReplication:pull];
    [self startReplication:push];
    
    
    return _persistentStoreCoordinator;
}

/**
 * Utility method to configure, start and observe a replication.
 */
- (void)startReplication:(CBLReplication *)repl {
    repl.continuous = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(replicationProgress:)
                                                 name:kCBLReplicationChangeNotification object:repl];
    [repl start];
}

/**
 Observer method called when the push or pull replication's progress or status changes.
 */
- (void)replicationProgress:(NSNotification *)notification {
    CBLReplication *repl = notification.object;
    NSError* error = repl.lastError;
    NSLog(@"%@ replication: status = %d, progress = %u / %u, err = %@",
          (repl.pull ? @"Pull" : @"Push"), repl.status, repl.changesCount, repl.completedChangesCount,
          error.localizedDescription);
    
    if (error) {
        NSString* msg = [NSString stringWithFormat: @"Sync failed with an error: %@", error.localizedDescription];
        NSLog(@"%@",msg);
        
    }
}

@end
