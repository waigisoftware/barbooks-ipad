//
//  Payment.m
//  barbooks-ipad
//
//  Created by Can on 9/06/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "Payment.h"
#import "Account.h"


@implementation Payment

@dynamic affiliationDescription;
@dynamic amountExGst;
@dynamic amountGst;
@dynamic date;
@dynamic info;
@dynamic paymentType;
@dynamic printoutGenerateable;
@dynamic printoutViewable;
@dynamic relatedAccount;
@dynamic totalAmount;
@dynamic account;


- (void)awakeFromInsert
{
    [super awakeFromInsert];
    self.date = [NSDate date];
    self.entryNumber = [self generateIdentifier];
}

- (NSNumber*)generateIdentifier
{
    if (self.importedObject.boolValue) {
        return nil;
    }
    
    //NSPredicate * filterPredicate = [NSPredicate predicateWithFormat:@"account == %@", self.account];
    NSSortDescriptor *descending = [[NSSortDescriptor alloc] initWithKey:@"entryNumber" ascending:NO];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Payment" inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setSortDescriptors:@[descending]];
    //[request setPredicate:filterPredicate];
    
    [request setEntity:entityDescription];
    
    // Execute the fetch
    NSError *error;
    NSArray *objects = [self.managedObjectContext executeFetchRequest:request error:&error];
    int lastID = 1;
    if (objects.count > 0) {
        
        lastID = MAX(lastID, [[objects objectAtIndex:0] entryNumber].intValue);
        lastID++;
    }
    
    return [NSNumber numberWithInt:lastID];
}

@end
