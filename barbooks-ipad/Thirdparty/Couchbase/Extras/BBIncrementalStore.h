//
//  BBIncrementalStore.h
//  BarBooks
//
//  Created by Eric on 4/09/2015.
//  Copyright (c) 2015 Censea Software Corporation Pty Limited. All rights reserved.
//

#import "CBLIncrementalStore.h"

@interface BBIncrementalStore : CBLIncrementalStore



@end

@interface NSManagedObjectID (CBLIncrementalStore)

/** Returns an internal representation of this objectID that is used as _id in Couchbase. */
- (NSString*) couchbaseLiteIDRepresentation;

@end