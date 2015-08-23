//
//  BBSyncManager.h
//  barbooks-ipad
//
//  Created by Can on 17/08/2015.
//  Copyright (c) 2015 Censea. All rights reserved.
//

#import "PKSyncManager.h"

@interface BBSyncManager : PKSyncManager

/**
 BBSyncManager is using datastores per financial year
 */
@property (strong) NSDate *fromDate;
@property (strong) NSDate *toDate;

@property (strong) id delegate;

@end
