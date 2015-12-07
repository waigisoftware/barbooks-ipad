//
//  BBAccountManager.m
//  BarBooks
//
//  Created by Eric on 28/04/2015.
//  Copyright (c) 2015 Censea Software Corporation Pty Limited. All rights reserved.
//

#import "BBAccountManager.h"

#if TARGET_OS_IPHONE

#import "Account.h"
#import "Rate.h"
#import "Address.h"

#else

#import "BBModels.h"
#import "BBDocumentsManager.h"

#endif


#define kActiveAccountEntryNumber @"account"

@implementation BBAccountManager

+ (instancetype) sharedManager
{
    __strong static id _sharedInstance = nil;
    static dispatch_once_t onlyOnce;
    dispatch_once(&onlyOnce, ^{
        _sharedInstance = [[self _alloc] _init];
    });
    return _sharedInstance;
}

+ (id) allocWithZone:(NSZone*)zone
{
    return [self sharedManager];
}

+ (id) alloc
{
    return [self sharedManager];
}

- (id) init
{
    return  self;
}

+ (id)_alloc
{
    return [super allocWithZone:NULL];
}

- (id)_init
{
    return [super init];
}



- (void)setActiveAccount:(Account *)activeAccount
{
    _activeAccount = activeAccount;
    if (activeAccount) {
        [[NSUserDefaults standardUserDefaults] setObject:self.activeAccount.entryNumber forKey:kActiveAccountEntryNumber];
    } else if([[NSUserDefaults standardUserDefaults] objectForKey:kActiveAccountEntryNumber]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kActiveAccountEntryNumber];
    }
}


- (BOOL)accountAvailable
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Account" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    // Execute the fetch
    NSError *error;
    NSArray *objects = [moc executeFetchRequest:request error:&error];
    
    return objects.count > 0;
}

- (void)setActiveAccountWithNumber:(NSNumber *)accountNumber
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"entryNumber == %@", accountNumber];
    
#if TARGET_OS_IPHONE

    NSArray *objects = [Account MR_findAllWithPredicate:predicate];
    
#else
    
    NSArray *objects = [Account allInstancesWithPredicate:predicate inManagedObjectContext:self.managedObjectContext];
    
#endif
    if (objects.count == 0) {
        self.activeAccount = [self getLatestAccount];
    } else {
        self.activeAccount = [objects objectAtIndex:0];
    }
    
    self.activeAccount.importedObject = @NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.activeAccount.entryNumber forKey:kActiveAccountEntryNumber];
}


- (id)getAnyAccount
{
    NSManagedObjectContext *moc = [self managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Account" inManagedObjectContext:moc];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setEntity:entityDescription];
    
    // Execute the fetch
    NSError *error;
    NSArray *objects = [moc executeFetchRequest:request error:&error];
    
    if (objects > 0) {
        return [objects objectAtIndex:0];
    }
    
    return nil; // NO ACCOUNT AVAILABLE
}


- (void)createAccountIfNotExist
{
    

    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Account"];
    NSArray *accounts = [self.managedObjectContext executeFetchRequest:request error:&error];
    
    if (accounts.count == 0) {
        
#if TARGET_OS_IPHONE

        Account *account = [Account MR_createEntityInContext:self.managedObjectContext];
        
        account.defaultDueDate = @(30);
        account.tax = [NSDecimalNumber ten];
        account.accountingType = @1;
        
        
        // hourly
        Rate *hourly = [NSEntityDescription insertNewObjectForEntityForName:@"Rate" inManagedObjectContext:self.managedObjectContext];
        hourly.rateType = [NSNumber numberWithInt:BBRateChargingTypeHourly];
        hourly.amount = [NSDecimalNumber decimalNumberWithString:@"200"];
        hourly.name = @"hourly";
        hourly.account = account;
        [account addRatesObject:hourly];
        
        // daily
        Rate *daily = [NSEntityDescription insertNewObjectForEntityForName:@"Rate" inManagedObjectContext:self.managedObjectContext];
        daily.rateType = [NSNumber numberWithInt:BBRateChargingTypeUnit];
        daily.amount = [NSDecimalNumber decimalNumberWithString:@"2000"];
        daily.name = @"daily";
        daily.account = account;
        
        [account addRatesObject:daily];
        
        // half day
        Rate *halfday = [NSEntityDescription insertNewObjectForEntityForName:@"Rate" inManagedObjectContext:self.managedObjectContext];
        halfday.rateType = [NSNumber numberWithInt:BBRateChargingTypeUnit];
        halfday.amount = [NSDecimalNumber decimalNumberWithString:@"1000"];
        halfday.name = @"half day";
        halfday.account = account;
        
        [account addRatesObject:halfday];
        
        // motion
        Rate *motion = [NSEntityDescription insertNewObjectForEntityForName:@"Rate" inManagedObjectContext:self.managedObjectContext];
        motion.rateType = [NSNumber numberWithInt:BBRateChargingTypeUnit];
        motion.amount = [NSDecimalNumber decimalNumberWithString:@"700"];
        motion.name = @"motion";
        motion.account = account;
        
        [account addRatesObject:motion];
        
        // directions
        Rate *directions = [NSEntityDescription insertNewObjectForEntityForName:@"Rate" inManagedObjectContext:self.managedObjectContext];
        directions.rateType = [NSNumber numberWithInt:BBRateChargingTypeUnit];
        directions.amount = [NSDecimalNumber decimalNumberWithString:@"700"];
        directions.name = @"directions / mention";
        directions.account = account;
        
        [account addRatesObject:directions];
        
        
        Address *address = [Address MR_createEntityInContext:self.managedObjectContext];
        account.address = address;
        
        
        [self.managedObjectContext MR_saveToPersistentStoreAndWait];
        
        self.activeAccount = account;
#else
        Account *account = [Account defaultAccountInManagedObjectContext:self.managedObjectContext];
        account.username = @"admin";
        BBDocumentsManager *manager = [BBDocumentsManager new];
        manager.managedObjectContext = self.managedObjectContext;
        
        for (int i = 0; i < BBTemplateNumberOfTemplates; i++) {
            Template *template = [manager newTemplateOfType:i];
            
            switch (i) {
                case BBTemplateTypeBlank:
                    template.name = @"Blank Template";
                    break;
                case BBTemplateTypeCostsAgreement:
                    template.name = @"Costs Agreement";
                    break;
                case BBTemplateTypeInterestInvoice:
                    template.name = @"Interest Invoice";
                    break;
                case BBTemplateTypeInvoice:
                    template.name = @"Invoice (Regular)";
                {
                    Template *template = [manager newTemplateOfType:i fromDocument:@"Default_Template_InvoiceAlternate"];
                    template.name = @"Invoice (Alternate Order)";
                    [account addTemplatesObject:template];
                }
                {
                    Template *template = [manager newTemplateOfType:i fromDocument:@"Default_Template_Memorandum"];
                    template.name = @"Memorandum";
                    [account addTemplatesObject:template];
                }
                    break;
                case BBTemplateTypeOutstandingFees:
                    template.name = @"Statement of Outstanding Fees";
                    break;
                case BBTemplateTypeVariationOfFees:
                    template.name = @"Variation of Fees";
                    break;
                case BBTemplateTypeReceipt:
                    template.name = @"Receipt";
                    break;
                default:
                    break;
            }
            
            [account addTemplatesObject:template];
        }
        
        [[BBAccountManager sharedManager] setActiveAccount:account];
#endif

    } else if(![[BBAccountManager sharedManager] activeAccount]) {
        [[BBAccountManager sharedManager] setActiveAccount:[accounts objectAtIndex:0]];
    }
    

}


- (id)getLatestAccount
{
#if TARGET_OS_IPHONE
    NSArray *accounts = [Account MR_findAllSortedBy:@"createdAt" ascending:YES];
#else

    NSArray *accounts = [[Account allInstancesInManagedObjectContext:self.managedObjectContext] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
#endif
    
    if (accounts.count > 0) {
        return [accounts lastObject];
    }
    
    return nil; // NO ACCOUNT AVAILABLE
}


- (void)setToLargestAccount
{
#if TARGET_OS_IPHONE
    NSArray *accounts = [[Account MR_findAll] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"matters.@count"
                                                                                                          ascending:NO],
                                                                            [NSSortDescriptor sortDescriptorWithKey:@"expenses.@count"
                                                                                                          ascending:NO]
                                                                                                       ]];

#else
    
    NSArray *accounts = [[Account allInstancesInManagedObjectContext:self.managedObjectContext] sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"matters.@count"
                                                                                                                                                            ascending:NO],
                                                                                                                              [NSSortDescriptor sortDescriptorWithKey:@"expenses.@count"
                                                                                                                                                            ascending:NO]
                                                                                                                              ]];

#endif
    
    if (accounts.count > 0) {
        self.activeAccount = [accounts objectAtIndex:0];
        [[NSUserDefaults standardUserDefaults] setObject:self.activeAccount.entryNumber forKey:kActiveAccountEntryNumber];
    }
}

- (void)setToLatestAccount
{
    self.activeAccount = [self getLatestAccount];
    [[NSUserDefaults standardUserDefaults] setObject:self.activeAccount.entryNumber forKey:kActiveAccountEntryNumber];
}

@end
