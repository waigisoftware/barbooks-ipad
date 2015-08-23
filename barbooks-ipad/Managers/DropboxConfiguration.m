//
//  DropboxConfiguration.m
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "DropboxConfiguration.h"
#import "DateTimeUtility.h"
#import <Dropbox/Dropbox.h>
#import "ParcelKit.h"
#import "BBSyncManager.h"
#import "Account.h"
#import "BBAccountManager.h"
#import "BBManagedObject.h"
#import "Account.h"
#import "Address.h"
#import "Attachment.h"
#import "BASReport.h"
#import "CAReport.h"
#import "Contact.h"
#import "CostsAgreement.h"
#import "Disbursement.h"
#import "Discount.h"
#import "Expense.h"
#import "Firm.h"
#import "GeneralExpense.h"
#import "GeneralReceipt.h"
#import "Invoice.h"
#import "RegularInvoice.h"
#import "InterestInvoice.h"
//#import "InterestRate.h"
#import "Matter.h"
#import "OutstandingAmount.h"
#import "OutstandingFees.h"
#import "Payment.h"
#import "Rate.h"
#import "Receipt.h"
#import "ReceiptAllocation.h"
#import "Report.h"
#import "ReportDetail.h"
#import "ReportDetailItem.h"
#import "Solicitor.h"
#import "Task.h"
#import "TaxExpense.h"
#import "TaxRefund.h"
#import "VariationOfFees.h"
#import "WriteOff.h"
#import "YETReport.h"
#import "YETReportItem.h"
//#import "Template.h"

#define kDropboxAppKey @"8c3rcgeh7gym6kd"
#define kDropboxAppSecret @"zsghrv8kyt8ipps"

#define kDropboxDataStorePrefix @"fy_"

#define NSUserDefaultsCompletedMigratedDatastores @"NSUserDefaultsCompletedMigratedDatastores"
#define kDropboxLastDayLinksChecked @"kDropboxLastDayLinksChecked"

#define DropboxCurrentFyMigrationCorrected @"DropboxCurrentFyMigrationCorrected"


@interface DropboxConfiguration ()

@property (nonatomic, strong) DBDatastore *contactsDatastore;

@property (nonatomic, strong) PKSyncManager *contactsSyncManager;

@property (nonatomic, strong) NSMutableDictionary *syncManagers;

@property (nonatomic, assign) BOOL repairLock;
@property (nonatomic, assign) BOOL repairAttempt;
@property (nonatomic, assign) BOOL initialBatchUpload;

@property (nonatomic, strong) NSTimer *restoreTimeout;
@property (nonatomic, strong) NSTimer *recheckTimer;

@property (assign) BOOL inRestoreProcess;
@property (assign) BOOL wantsDisable;

@end

@implementation DropboxConfiguration


- (id)init
{
    self = [super init];
    if (self) {
        
        if (![DBAccountManager sharedManager]) {
            DBAccountManager *accountManager =
            [[DBAccountManager alloc] initWithAppKey:kDropboxAppKey secret:kDropboxAppSecret];
            [DBAccountManager setSharedManager:accountManager];
        }
        self.inRestoreProcess = NO;
    }
    return self;
}


- (void)linkInViewController:(UIViewController *)viewController
{
    // Set up the datastore manager
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        // Use Dropbox datastores
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
            
//            //[self.delegate linkSuccessful];
            
            [self enable];
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Link to Dropbox
            [[DBAccountManager sharedManager] linkFromController:viewController];
        });
        
        // Use local datastores
        
        // pop up screen from dropbox
/*        NSWindowController *windowController = [[NSWindowController alloc] init];
        [windowController showWindow:nil];
        
        [[DBAccountManager sharedManager] linkFromWindow:windowController.window
                                     withCompletionBlock:^(DBAccount *account) {
                                         if (account) {
                                             // Migrate any local datastores to the linked account
                                             DBDatastoreManager *localManager = [DBDatastoreManager localManagerForAccountManager:
                                                                                 [DBAccountManager sharedManager]];
                                             
                                             [localManager migrateToAccount:account error:nil];
                                             // Now use Dropbox datastores
                                             [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
                                             //[self.delegate linkSuccessful];
                                             
                                             [self enable];
                                             
                                         } else {
                                             //[self.delegate linkFailed];
                                         }
                                     }];
 */
    }
}


- (void)restoreInViewController:(UIViewController *)viewController
{
    self.inRestoreProcess = YES;
    // remove full data
    // Set up the datastore manager
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDropboxLastDayLinksChecked];
    
    DBAccount *account = [[DBAccountManager sharedManager] linkedAccount];
    if (account) {
        // Use Dropbox datastores
        [DBDatastoreManager setSharedManager:[DBDatastoreManager managerForAccount:account]];
        
        //        //[self.delegate linkSuccessful];
        [self enable];
        
    } else {
        [[DBAccountManager sharedManager] linkFromController:viewController];
    }
}


- (void)unlink
{
    self.wantsDisable = YES;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kDropboxLastDayLinksChecked];
    
    if (self.recheckTimer.valid) {
        [self.recheckTimer invalidate];
        self.recheckTimer = nil;
    }
    
    for (PKSyncManager *manager in [self allSyncManagers]) {
        [manager stopObserving];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    [accountManager removeObserver:self];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:NSUserDefaultsCompletedMigratedDatastores];
    
    //[[DBDatastoreManager sharedManager] shutDown];
    self.wantsDisable = NO;
    
}

- (void)refreshDatastoresAndManagers
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy"];
    
    if (!self.syncManagers) {
        self.syncManagers = [NSMutableDictionary dictionary];
    }
    
    NSMutableDictionary *datastores = [NSMutableDictionary dictionary];
    
    // first check for already available datastores
    NSArray *datastoreInfos = [[DBDatastoreManager sharedManager] listDatastores:nil];
    for (DBDatastoreInfo *info in datastoreInfos) {
        if (![info.datastoreId hasPrefix:kDropboxDataStorePrefix] ||
            [self.syncManagers objectForKey:info.datastoreId]) {
            continue;
        }
        
        NSError *error;
        DBDatastore *datastore = [[DBDatastoreManager sharedManager] openDatastore:info.datastoreId error:&error];
        if (datastore && !error) {
            [datastores setObject:datastore forKey:info.datastoreId];
        }
    }
    
    BBManagedObject *oldestEntry = [BBManagedObject oldestEntryInManagedObjectContext:self.managedObjectContext];
    if (oldestEntry) {
        
        NSDate *firstFY = [DateTimeUtility financialYearEndingForDate:oldestEntry.createdAt];
        NSDate *lastFY = [DateTimeUtility financialYearEndingForDate:[NSDate date]];
        NSInteger yearsDifference = [DateTimeUtility yearsBetweenDate:firstFY andDate:lastFY];
        
        for (int i = 0; i <= yearsDifference; i++) {
            NSDate *curDate = [DateTimeUtility dateByAddingYears:-i toDate:lastFY];
            NSString *dateString = [dateFormatter stringFromDate:curDate];
            NSString *datastoreId = [NSString stringWithFormat:@"%@%@", kDropboxDataStorePrefix, dateString];
            
            if ([self.syncManagers objectForKey:datastoreId] || [datastores objectForKey:datastoreId]) {
                continue;
            }
            
            NSError *error;
            DBDatastore *datastore = [[DBDatastoreManager sharedManager] openOrCreateDatastore:datastoreId error:&error];
            if (datastore && !error) {
                [datastores setObject:datastore forKey:datastoreId];
            }
        }
    }
    
    
    NSArray *allobjects = datastores.allValues;
    
    
    NSDateComponents *fromComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                                                       fromDate:[NSDate date]];
    NSDateComponents *toComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit
                                                                     fromDate:[NSDate date]];
    
    
    
    NSInteger currentFy = [DateTimeUtility financialYearForDate:[NSDate date]];
    
    for (int i = 0; i < allobjects.count; i++) {
        DBDatastore *datastore = [allobjects objectAtIndex:i];
        if ([self.syncManagers objectForKey:datastore.datastoreId]) {
            continue;
        }
        
        NSString *yearFromDatastoreString = [datastore.datastoreId substringFromIndex:kDropboxDataStorePrefix.length];
        
        fromComponents.year = yearFromDatastoreString.intValue-1;
        toComponents.year = yearFromDatastoreString.intValue;
        
        fromComponents.day = 2;
        fromComponents.month = 7;
        
        toComponents.day = 1;
        toComponents.month = 7;
        
        NSDate *fromDate = [[NSCalendar currentCalendar] dateFromComponents:fromComponents];
        NSDate *toDate = [[NSCalendar currentCalendar] dateFromComponents:toComponents];
        
        BBSyncManager *syncManager = [[BBSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:datastore];
        [syncManager setFromDate:fromDate];
        [syncManager setToDate:toDate];
        [syncManager setTable:@"matters" forEntityName:@"Matter"];
        [syncManager setTable:@"tasks" forEntityName:@"Task"];
        [syncManager setTable:@"rates" forEntityName:@"Rate"];
        [syncManager setTable:@"interestinvoices" forEntityName:@"InterestInvoice"];
        [syncManager setTable:@"regularinvoices" forEntityName:@"RegularInvoice"];
        [syncManager setTable:@"receipts" forEntityName:@"Receipt"];
        [syncManager setTable:@"generalreceipts" forEntityName:@"GeneralReceipt"];
        [syncManager setTable:@"receiptallocations" forEntityName:@"ReceiptAllocation"];
        [syncManager setTable:@"writeoffs" forEntityName:@"WriteOff"];
        [syncManager setTable:@"taxrefunds" forEntityName:@"TaxRefund"];
        [syncManager setTable:@"taxexpenses" forEntityName:@"TaxExpense"];
        [syncManager setTable:@"generalexpenses" forEntityName:@"GeneralExpense"];
        [syncManager setTable:@"disbursements" forEntityName:@"Disbursement"];
        [syncManager setTable:@"discounts" forEntityName:@"Discount"];
        
        [self.syncManagers setObject:syncManager forKey:datastore.datastoreId];
        
        
        NSInteger managerYear = [DateTimeUtility financialYearForDate:fromDate];
        
        if (![[NSUserDefaults standardUserDefaults] objectForKey:DropboxCurrentFyMigrationCorrected] && currentFy >= managerYear-1) {
            NSMutableDictionary *migrations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsCompletedMigratedDatastores]];
            if (migrations) {
                [migrations setObject:@NO forKey:datastore.datastoreId];
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:DropboxCurrentFyMigrationCorrected];
    
    
    if (datastores.count) {
        [self datastoreChanged:nil];
    }
}

- (void)enable
{
    DBAccountManager *accountManager = [DBAccountManager sharedManager];
    
    if (!self.contactsSyncManager) {
        DBAccount *account = [accountManager linkedAccount];
        
        if (account) {
            __weak typeof(self) weakSelf = self;
            [accountManager addObserver:self block:^(DBAccount *account) {
                typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
                if (![account isLinked]) {
                    [strongSelf unlink];
                    NSLog(@"Unlinked account: %@", account);
                }
            }];
            
            DBError *dberror = nil;
            
            if (!self.contactsDatastore) { // prevent re-initialization
                self.contactsDatastore = [[DBDatastoreManager sharedManager] openOrCreateDatastore:@"contacts" error:&dberror];
            }
            
            if (self.contactsDatastore) {
                
                self.contactsSyncManager = [[PKSyncManager alloc] initWithManagedObjectContext:self.managedObjectContext datastore:self.contactsDatastore];
                [self.contactsSyncManager setTable:@"accounts" forEntityName:@"Account"];
                [self.contactsSyncManager setTable:@"solicitors" forEntityName:@"Solicitor"];
                [self.contactsSyncManager setTable:@"firms" forEntityName:@"Firm"];
                [self.contactsSyncManager setTable:@"addresses" forEntityName:@"Address"];
                [self.contactsSyncManager setTable:@"templates" forEntityName:@"Template"];
                
                
            } else {
                NSLog(@"Error opening default datastore: %@", dberror);
            }
        }
    }
    
    
    if (self.inRestoreProcess) {
        __block int tries = 3;
        __weak typeof(self) weakSelf = self;
        [self.contactsDatastore addObserver:self block:^{
            typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
            DBDatastoreStatus *status = strongSelf.contactsDatastore.status;
            [strongSelf.contactsSyncManager syncDatastore];
            
            if (status.incoming) {
                [strongSelf.contactsDatastore removeObserver:strongSelf];
                
                DBTable *accountTable = [strongSelf.contactsDatastore getTable:@"accounts"];
                NSArray *accounts = [accountTable query:nil error:nil];
                if (!accountTable || (accountTable && accounts.count == 0)) {
                    [strongSelf.delegate restoreFailedWithInfo:@"No account found."];
                } else {
                    [strongSelf beginSyncProcess];
                    [strongSelf.delegate restoreUpdatedWithInfo:@"Restoring initial batch of data, please wait..."];
                }
            } else if(tries == 0){
                [strongSelf.delegate restoreFailedWithInfo:@"No account found or the first system has not finished backing up your data."];
            }
        }];
    } else {
        [self beginSyncProcess];
    }
    
}

- (void)beginSyncProcess
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkDatastoreRelationships:) name:PKSyncManagerDatastoreLastSyncDateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(datastoreChanged:) name:PKSyncManagerDatastoreStatusDidChangeNotification object:nil];
    
    
    __weak typeof(self) weakSelf = self;
    DBObserver dsmBlock = ^() {
        typeof(self) strongSelf = weakSelf; if (!strongSelf) return;
        [strongSelf refreshDatastoresAndManagers];
    };
    
    [dsmBlock invoke];
    [[DBDatastoreManager sharedManager] addObserver:self block:dsmBlock];
    
}


- (BOOL)addMissingSyncAttributeValueToCoreDataObjects:(NSError **)error
{
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    [managedObjectContext setUndoManager:nil];
    
    return error != nil;
}

- (void)syncManagedObjectContextDidSave:(NSNotification *)notification
{
    if ([NSThread isMainThread]) {
        [self.managedObjectContext mergeChangesFromContextDidSaveNotification:notification];
        
        if (self.inRestoreProcess) {
            self.inRestoreProcess = NO;
            
//            [(NSObject*)self.delegate performSelector:@selector(restoreSuccesful) withObject:nil afterDelay:10.0];
            //TODO:
        }
        
        if (self.repairAttempt) {
            self.repairLock = NO;
            
            self.repairAttempt = NO;
            [self checkDatastoreRelationships:nil];
        } else if (self.repairLock) {
            self.repairLock = NO;
            
            [self sync];
        }
        
        
    } else {
        [self performSelectorOnMainThread:@selector(syncManagedObjectContextDidSave:) withObject:notification waitUntilDone:YES];
    }
}

- (NSArray*)allSyncManagers
{
    if (!self.contactsSyncManager) {
        return nil;
    }
    
    NSMutableArray *array = [NSMutableArray new];
    
    [array addObjectsFromArray:[self.syncManagers.allValues sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"datastore.datastoreId" ascending:YES]]]];
    
    [array addObject:self.contactsSyncManager];
    
    return array;
}

- (BOOL)updateDropboxFromCoreData:(NSError **)error withSyncManager:(PKSyncManager*)syncManager
{
    if (![[BBAccountManager sharedManager] activeAccount]) {
        return NO;
    }
    self.initialBatchUpload = YES;
    
    NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:[self.managedObjectContext persistentStoreCoordinator]];
    [managedObjectContext setUndoManager:nil];
    
    [managedObjectContext performBlockAndWait:^{
        
        if (self.wantsDisable || ![syncManager.datastore isOpen]) {
            return;
        }
        
        [self updateDropboxFromCoreDataWithManagedObjectContext:managedObjectContext syncManager:syncManager error:error];
        
        if (self.wantsDisable) {
            return;
        }
        
        if ([managedObjectContext hasChanges]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
            [managedObjectContext save:error];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:managedObjectContext];
        }
    }];
    
    return error != nil;
}

- (BOOL)updateDropboxFromCoreDataWithManagedObjectContext:(NSManagedObjectContext*)managedObjectContext
                                              syncManager:(PKSyncManager*)syncManager
                                                    error:(NSError **)error
{
    __block BOOL result = YES;
    
    NSString *syncAttributeName = syncManager.syncAttributeName;
    //NSManagedObjectContext *managedObjectContext = syncManager.managedObjectContext;
    
    NSDictionary *tablesByEntityName = [syncManager tablesByEntityName];
    
    [tablesByEntityName enumerateKeysAndObjectsUsingBlock:^(NSString *entityName, NSString *tableId, BOOL *stop) {
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:NO],
                                           [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
        
        fetchRequest.includesSubentities = NO;
        
        if ([syncManager isKindOfClass:[BBSyncManager class]]) {
            
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"createdAt >= %@ AND createdAt <= %@",
                                        [(BBSyncManager*)syncManager fromDate],
                                        [(BBSyncManager*)syncManager toDate]]];
        }
        
        [fetchRequest setFetchBatchSize:25];
        
        NSArray *managedObjects = [managedObjectContext executeFetchRequest:fetchRequest error:error];
        if (managedObjects) {
            
            for (BBManagedObject *managedObject in managedObjects) {
                
                if (self.wantsDisable) {
                    [managedObjectContext rollback];
                    return;
                }
                
                if (!managedObject.syncID) {
                    managedObject.syncID = [PKSyncManager syncID];
                }
                
                DBError *dberror = nil;
                
                DBTable *table = [syncManager.datastore getTable:tableId];
                DBRecord *record = [table getOrInsertRecord:[managedObject valueForKey:syncAttributeName] fields:nil inserted:NULL error:&dberror];
                
                if (record) {
                    [record pk_setFieldsWithManagedObject:managedObject syncAttributeName:syncAttributeName];
                    
                } else {
                    if (error) {
                        *error = [NSError errorWithDomain:[dberror domain] code:[dberror code] userInfo:[dberror userInfo]];
                    }
                    result = NO;
                    *stop = YES;
                }
                
                if (syncManager.datastore.unsyncedChangesSize >= DBDatastoreUnsyncedChangesSizeLimit*0.90) {
                    [syncManager.datastore sync:nil];
                }
            }
            
        } else {
            *stop = YES;
        }
    }];
    
    
    if (result) {
        [syncManager startObserving];
        [syncManager syncDatastore];
        
        NSMutableDictionary *migrations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsCompletedMigratedDatastores]];
        if (!migrations) {
            migrations = [NSMutableDictionary dictionary];
        }
        [migrations setObject:@NO forKey:syncManager.datastore.datastoreId];
        [[NSUserDefaults standardUserDefaults] setObject:migrations forKey:NSUserDefaultsCompletedMigratedDatastores];
        
    }
    
    return error != nil;
}

- (void)sync
{
    if (self.initialBatchUpload) {
        return;
    }
    
    NSMutableDictionary *migrations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsCompletedMigratedDatastores]];
    
    for (PKSyncManager *manager in [self allSyncManagers]) {
        if (manager.isObserving) {
            [manager syncDatastore];
        } else if([migrations objectForKey:manager.datastore.datastoreId]) {
            [manager startObserving];
        }
    }
}

#pragma mark - Notifications

- (void)datastoreChanged:(NSNotification*)notification
{
    NSMutableDictionary *migrations = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:NSUserDefaultsCompletedMigratedDatastores]];
    
    if (!migrations) {
        migrations = [NSMutableDictionary dictionary];
    }
    
    
    
    for (PKSyncManager *manager in [self allSyncManagers]) {
        
        if (self.inRestoreProcess) {
            
            [migrations setObject:@NO forKey:manager.datastore.datastoreId];
            [[NSUserDefaults standardUserDefaults] setObject:migrations forKey:NSUserDefaultsCompletedMigratedDatastores];
        }
        
        double progress = migrations.count/(double)[self allSyncManagers].count;
        NSString *progressInfo = @"";
        if (manager == self.contactsSyncManager) {
            progressInfo = @"...Uploading Contacts...";
        } else {
            progressInfo = [NSString stringWithFormat:@"...Uploading Financial Year %@...",[manager.datastore.datastoreId stringByReplacingOccurrencesOfString:kDropboxDataStorePrefix withString:@""]];
        }
        
//        //[self.delegate backupUpdatedWithProgress:progress info:progressInfo];
        
        // Progress == 1 equals being "in sync"
        if (manager.datastore.status.uploading && manager.datastore.recordCount != 0
            && progress < 1) {
            
            return;
        }
        
        if (![migrations objectForKey:manager.datastore.datastoreId]) {
            
            [self updateDropboxFromCoreData:nil withSyncManager:manager];
            return;
        } else if(!manager.isObserving) {
            [manager startObserving];
        }
    }
    
    self.initialBatchUpload = NO;
    
    //[self.delegate backupUpdatedWithProgress:1 info:@"Backup Successful!"];
    
    [self checkDatastoreRelationships:notification];
    
    
    DBTable *accounts = [self.contactsDatastore getTable:@"accounts"];
    for (DBRecord *account in [accounts query:nil error:nil]) {
        BOOL changes = NO;
        if ([account objectForKey:@"invoiceAdditionalInformation"]) {
            [account removeObjectForKey:@"invoiceAdditionalInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"variationOfFeesInformation"]) {
            [account removeObjectForKey:@"variationOfFeesInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"receiptInformation"]) {
            [account removeObjectForKey:@"receiptInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"costsAgreementInformation"]) {
            [account removeObjectForKey:@"costsAgreementInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"invoiceAdditionalInformationFootnote"]) {
            [account removeObjectForKey:@"invoiceAdditionalInformationFootnote"];
            changes = YES;
        }
        if ([account objectForKey:@"costsDisclosureInformation"]) {
            [account removeObjectForKey:@"costsDisclosureInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"invoiceInformation"]) {
            [account removeObjectForKey:@"invoiceInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"headerInformation"]) {
            [account removeObjectForKey:@"headerInformation"];
            changes = YES;
        }
        if ([account objectForKey:@"outstandingFeesInformation"]) {
            [account removeObjectForKey:@"outstandingFeesInformation"];
        }
        if (changes) [self.contactsSyncManager syncDatastore];
    }
}

#pragma mark - Repair Logic

- (void)checkBrokenInvoices:(NSManagedObjectContext*)moc datastore:(DBDatastore*)datastore items:(NSArray*)items
{
    DBTable *regularInvoiceTable = [datastore getTable:@"regularinvoices"];
    DBTable *interestInvoiceTable = [datastore getTable:@"interestinvoices"];
    NSMutableArray *remainingItems = [NSMutableArray arrayWithArray:items];
    
    // repair all broken links
    for (Invoice *item in items) {
        
        DBRecord *record = [regularInvoiceTable getRecord:item.syncID error:nil];
        if (!record) {
            record = [interestInvoiceTable getRecord:item.syncID error:nil];
        }
        
        if (record) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",[record objectForKey:@"matter"]];
            NSArray *linkedObject = [Matter MR_findAllWithPredicate:predicate inContext:moc];
//            NSArray *linkedObject = [Matter allInstancesWithPredicate:predicate inManagedObjectContext:moc];
            if (linkedObject.count) {
                item.matter = [linkedObject objectAtIndex:0];
            }
            
            
            if ([item isKindOfClass:[RegularInvoice class]] &&
                ([item.totalReceivedIncGst compare:item.totalAmount] == NSOrderedDescending ||
                 [item.totalWrittenOff compare:item.totalAmount] == NSOrderedDescending || [item.totalAmount compare:@0] == NSOrderedSame || [[(RegularInvoice*)item professionalFeeExGst] compare:item.totalAmountExGst] == NSOrderedAscending ))
            {
                int year = [[datastore.datastoreId substringFromIndex:kDropboxDataStorePrefix.length] intValue];
                for (int i = 0; i <= self.syncManagers.count; i++) {
                    
                    PKSyncManager *syncManager = [self.syncManagers objectForKey:[NSString stringWithFormat:@"%@%i",kDropboxDataStorePrefix,year-i]];
                    if (!syncManager) {
                        break;
                    }
                    DBTable *tasksTable = [syncManager.datastore getTable:@"tasks"];
                    
                    NSArray *dbtasks = [tasksTable query:@{@"invoice" : item.syncID} error:nil];
                    
                    for (DBRecord *taskRecord in dbtasks) {
                        NSArray * tasks = [Task MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"syncID == %@", taskRecord.recordId] inContext:moc];
                        if (tasks.count) {
                            Task *task = [tasks objectAtIndex:0];
                            [(RegularInvoice *)item addTasksObject:task];
                        }
                    }
                    
                    DBTable *disbursementsTable = [syncManager.datastore getTable:@"disbursements"];
                    
                    NSArray *dbdisbursements = [disbursementsTable query:@{@"invoice" : item.syncID} error:nil];
                    
                    for (DBRecord *disbursementRecord in dbdisbursements) {
                        NSArray * disbursements = [Disbursement MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"syncID == %@", disbursementRecord.recordId] inContext:moc];
                        if (disbursements.count) {
                            Disbursement *disbursement = [disbursements objectAtIndex:0];
                            disbursement.invoice = (RegularInvoice *)item;
                        }
                    }
                }
            }
            
            [remainingItems removeObject:item];
        }
    }
    items = [NSArray arrayWithArray:remainingItems];
}

- (void)checkBrokenReceiptAllocations:(NSManagedObjectContext*)moc datastore:(DBDatastore*)datastore items:(NSArray*)items
{
    DBTable *itemTable = [datastore getTable:@"receiptallocations"];
    NSMutableArray *remainingItems = [NSMutableArray arrayWithArray:items];
    
    for (ReceiptAllocation *item in items) {
        DBRecord *record = [itemTable getRecord:item.syncID error:nil];
        
        if (record) {
            if (item.invoice == nil) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",[record objectForKey:@"invoice"]];
                NSArray *invoices = [Invoice MR_findAllWithPredicate:predicate inContext:moc];
                if (invoices.count) {
                    item.invoice = [invoices objectAtIndex:0];
                }
            }
            
            if (item.receipt == nil) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",[record objectForKey:@"receipt"]];
                NSArray *receipts = [Receipt MR_findAllWithPredicate:predicate inContext:moc];
                if (receipts.count) {
                    item.receipt = [receipts objectAtIndex:0];
                }
            }
            
            [remainingItems removeObject:item];
        }
    }
    
    items = [NSArray arrayWithArray:remainingItems];
}

- (void)checkBrokenTasks:(NSManagedObjectContext*)moc datastore:(DBDatastore*)datastore items:(NSArray*)items
{
    DBTable *itemTable = [datastore getTable:@"tasks"];
    NSMutableArray *remainingItems = [NSMutableArray arrayWithArray:items];
    for (Task *item in items) {
        DBRecord *record = [itemTable getRecord:item.syncID error:nil];
        
        if (record) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",[record objectForKey:@"matter"]];
            NSArray *linkedObject = [Matter MR_findAllWithPredicate:predicate inContext:moc];
            if (linkedObject.count) {
                Matter *matter = [linkedObject objectAtIndex:0];
                
                item.matter = matter;
            }
            [remainingItems removeObject:item];
        }
    }
    items = [NSArray arrayWithArray:remainingItems];
}

- (void)checkBrokenDisbursements:(NSManagedObjectContext*)moc datastore:(DBDatastore*)datastore items:(NSArray*)items
{
    DBTable *itemTable = [datastore getTable:@"disbursements"];
    NSMutableArray *remainingItems = [NSMutableArray arrayWithArray:items];
    for (Disbursement *item in items) {
        DBRecord *record = [itemTable getRecord:item.syncID error:nil];
        
        if (record) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",[record objectForKey:@"matter"]];
            NSArray *linkedObject = [Matter MR_findAllWithPredicate:predicate inContext:moc];
            if (linkedObject.count) {
                Matter *matter = [linkedObject objectAtIndex:0];
                
                item.matter = matter;
            }
            [remainingItems removeObject:item];
        }
    }
    items = [NSArray arrayWithArray:remainingItems];
}

- (void)checkBrokenRates:(NSManagedObjectContext*)moc datastore:(DBDatastore*)datastore items:(NSArray*)items
{
    DBTable *ratesTable = [datastore getTable:@"rates"];
    NSMutableArray *remainingItems = [NSMutableArray arrayWithArray:items];
    
    for (Rate *item in items) {
        DBRecord *record = [ratesTable getRecord:item.syncID error:nil];
        
        if (record) {
            NSString *syncID = [record objectForKey:@"account"];
            if (!syncID) {
                syncID = [record objectForKey:@"matter"];
            }
            if (!syncID) {
                syncID = [record objectForKey:@"task"];
            }
            if (!syncID) {
                continue;
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",syncID];
            NSArray *objects = [BBManagedObject MR_findAllWithPredicate:predicate inContext:moc];
            if (objects.count) {
                Account *object = [objects objectAtIndex:0];
                BOOL rateExists = NO;
                
                for (Rate *curRate in [object rates]) {
                    if ([item.amount compare:curRate.amount] == NSOrderedSame &&
                        item.type.intValue == curRate.type.intValue) {
                        [record deleteRecord];
                        [moc deleteObject:item];
                        rateExists = YES;
                    }
                }
                
                if (rateExists) {
                    continue;
                }
                
                [object addRatesObject:item];
            }
            [remainingItems removeObject:item];
        }
    }
    
    items = [NSArray arrayWithArray:remainingItems];
}


- (void)checkBrokenMatters:(NSManagedObjectContext*)moc datastore:(DBDatastore*)datastore items:(NSArray*)items
{
    DBTable *mattersTable = [datastore getTable:@"matters"];
    NSMutableArray *remainingItems = [NSMutableArray arrayWithArray:items];
    
    for (Matter *item in items) {
        DBRecord *record = [mattersTable getRecord:item.syncID error:nil];
        
        if (record) {
            if ([record objectForKey:@"solicitor"]) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"syncID == %@",[record objectForKey:@"solicitor"]];
                NSArray *solicitors = [Matter MR_findAllWithPredicate:predicate inContext:self.managedObjectContext];
                if (solicitors.count) {
                    item.solicitor = [solicitors objectAtIndex:0];
                }
            }
            [remainingItems removeObject:item];
        }
    }
    items = [NSArray arrayWithArray:remainingItems];
}

- (void)checkDatastoreTimerEnded
{
    if (self.recheckTimer.valid) {
        [self.recheckTimer invalidate];
    }
    [self checkDatastoreRelationships:nil];
}

- (void)checkDatastoreRelationships:(NSNotification*)notification
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] objectForKey:kDropboxLastDayLinksChecked];
    
    if (date) {
        NSInteger fy = [DateTimeUtility financialYearForDate:date];
        NSInteger lastCheckedFy = [DateTimeUtility financialYearForDate:[NSDate date]];
        if (fy == lastCheckedFy) {
            return;
        }
    }
    
    if (self.initialBatchUpload) {
        return;
    }
    
    if (self.recheckTimer.valid || self.recheckTimer == nil) {
        [self.recheckTimer invalidate];
        
        self.recheckTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(checkDatastoreTimerEnded) userInfo:nil repeats:NO];
        return;
    }
    
    self.recheckTimer = nil;
    
    if (self.repairLock) {
        self.repairAttempt = YES;
        return;
    }
    
    self.repairLock = YES;
    
    NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    moc.persistentStoreCoordinator = self.managedObjectContext.persistentStoreCoordinator;
    
    
    if (self.inRestoreProcess) {
        //[self.delegate restoreUpdatedWithInfo:@"Mending Database..."];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kDropboxLastDayLinksChecked];
    
    for (PKSyncManager *manager in [self allSyncManagers]) {
        
        [manager stopObserving];
    }
    
    //moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy;
    
    [moc performBlock:^{
        NSArray *rates = [Rate allUnlinkedAllocationsInManagedObjectContext:moc];
        NSArray *receiptAllocations = [ReceiptAllocation allUnlinkedAllocationsInManagedObjectContext:moc];
        NSArray *invoices = [Invoice allUnlinkedInvoicesInManagedObjectContext:moc];
        NSArray *matters = [Matter allUnlinkedInvoicesInManagedObjectContext:moc];
        NSArray *tasks = [Task allUnlinkedObjectsInManagedObjectContext:moc];
        NSArray *disbursements = [Disbursement allUnlinkedObjectsInManagedObjectContext:moc];
        
        for (PKSyncManager *manager in [self allSyncManagers]) {
            if (manager == self.contactsSyncManager) {
                continue;
            }
            
            DBDatastore *datastore = manager.datastore;
            
            [self checkBrokenRates:moc datastore:datastore items:rates];
            [self checkBrokenInvoices:moc datastore:datastore items:invoices];
            [self checkBrokenReceiptAllocations:moc datastore:datastore items:receiptAllocations];
            [self checkBrokenMatters:moc datastore:datastore items:matters];
            [self checkBrokenTasks:moc datastore:datastore items:tasks];
            [self checkBrokenDisbursements:moc datastore:datastore items:disbursements];
        }
        
        
        if ([moc hasChanges]) {
            NSError *error;
            
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncManagedObjectContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:moc];
            [moc save:&error];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:NSManagedObjectContextDidSaveNotification object:moc];
            
            if (error) {
                [moc rollback];
                self.repairLock = NO;
                [self performSelectorOnMainThread:@selector(checkDatastoreRelationships:) withObject:notification waitUntilDone:NO];
            }
        } else {
            
            if (self.inRestoreProcess) {
                self.inRestoreProcess = NO;
                
                //[self.delegate restoreSuccesful];
                //TODO: once restore success, set key into userdefault, only do link afterwards
            }
            
            self.repairLock = NO;
            [self sync];
        }
        
    }];
}


@end
