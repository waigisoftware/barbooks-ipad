//
//  BackupConfiguration.h
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    BackupLocationTypeNotSet = -1,
    BackupLocationTypeDropbox = 1,
}BackupLocationType;

#define kObjectGroupMatters @"kObjectGroupMatters";
#define kObjectGroupReceipts @"kObjectGroupReceipts";
#define kObjectGroupExpenses @"kObjectGroupExpenses";
#define kObjectGroupReports @"kObjectGroupReports";


@protocol BackupConfigurationDelegate;

@interface BackupConfiguration : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong) id<BackupConfigurationDelegate> delegate;

- (void)unlink;
- (void)link;
- (BackupLocationType)backgroundLocationType;
- (void)sync;
- (void)restore;
- (void)deleteStore;

@end

@protocol BackupConfigurationDelegate <NSObject>

- (void) linkSuccessful;
- (void) linkFailed;
- (void) syncStarted;
- (void) syncFinished;
- (void) restoreSuccesful;
- (void) restoreFailedWithInfo:(NSString*)message;
- (void) restoreUpdatedWithInfo:(NSString*)message;

- (void) backupUpdatedWithProgress:(double)progress info:(NSString*)info;


@end