//
//  SubscriptionManager.m
//  BarBooks
//
//  Created by Eric on 4/11/2014.
//  Copyright (c) 2014 Censea Software Corporation Pty Limited. All rights reserved.
//

#include <SystemConfiguration/SystemConfiguration.h>
#import "BBCloudManager.h"
#import "AFNetworking.h"
#import "DateTimeUtility.h"
#import "Lockbox.h"
#import "BBAccountManager.h"
#import "Account.h"

#define kWordpressService @"barbooks-wordpress"
#define kSubscriptionEndDate @"subscriptionEndDate"
#define kSubscriptionActive @"subscriptionActive"
#define kSubscriptionLastChecked @"subscriptionLastChecked"

#define kBarBooksSubscriptionUserID @"barbooks-sub-userid"
#define kBarBooksSubscriptionUserToken @"barbooks-sub-token"
#define kBarBooksSubscriptionUsername @"barbooks-user"
#define kBarBooksSubscriptionUserPassword @"barbooks-secret"


#define kAPIURL @"https://www.barbooksaustralia.com/api/userplus/"
#define kWooCommerceAPI @"https://www.barbooksaustralia.com/wc-api/v2/"
#define kNONCEURL @"nonce/get_nonce/?controller=user&method=generate_auth_cookie"
#define kGenerateCookieURL @"generate_auth_cookie/?"
#define kAuthWithCookieURL @"validate_auth_cookie/?cookie="
#define kGetCustomerURL @"customers/"

#define kWoocommerceKey @"ck_ef918f20c8bacc4700a4befc5a6ef365"
#define kWoocommerceSecret @"cs_f080069717f4ee0b8cd5f809889820ea"
#define kWordpressApiKey @"76CCD5E8334BE2DDCD9E55FAF1959"
#define kWordpressApiParameter @"&key=76CCD5E8334BE2DDCD9E55FAF1959"


@interface BBCloudManager () <CBLIncrementalStoreDelegate>

@property (strong) NSString *activeuser;
@property (strong) NSMutableData *responseData;
@property (assign) BOOL syncActive;

@end

@implementation BBCloudManager


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
    self = [super init];
    if (self) {
        self.syncStatus = kCBLReplicationStopped;
        self.activeuser = [Lockbox stringForKey:kBarBooksSubscriptionUsername];
        self.syncActive = NO;
        if (self.activeuser && [Lockbox stringForKey:kBarBooksSubscriptionUserPassword]) {
            self.isLoggedIn = YES;
            [self startSync];
        }
    }
    
    return self;
}




static BOOL isInternetConnection()
{
    BOOL returnValue = NO;
    
    
    struct sockaddr zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sa_len = sizeof(zeroAddress);
    zeroAddress.sa_family = AF_INET;
    
    SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr*)&zeroAddress);
    
    
    if (reachabilityRef != NULL)
    {
        SCNetworkReachabilityFlags flags = 0;
        
        if(SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
        {
            BOOL isReachable = ((flags & kSCNetworkFlagsReachable) != 0);
            //BOOL connectionRequired = ((flags & kSCNetworkFlagsConnectionRequired) != 0);
            returnValue = isReachable;//(isReachable && !connectionRequired) ? YES : NO;
        }
        
        CFRelease(reachabilityRef);
    }
    
    return returnValue;
}

- (void) startCouchbaseUserRequestWithURL:(NSURL*)url
                               httpMethod:(NSString*)method
                                     data:(NSData*)data
                             onCompletion:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    if ([method isEqualToString:@"POST"] || [method isEqualToString:@"PUT"]) {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%lu", [data length]] forHTTPHeaderField:@"Content-Length"];
        request.HTTPBody = data;
    }
    [request setHTTPMethod:method];
    
    NSString *password = [Lockbox stringForKey:kBarBooksSubscriptionUserPassword];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.activeuser, password];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    
    //Capturing server response
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:handler];
}

- (void) startRequestWithURL:(NSURL*)url
//objectClass:(Class)class
//mappingDictionary:(NSDictionary*)dictionary
  completionBlockWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:success failure:failure];
    [operation start];
}

/*
- (void) signinWithToken:(NSString*)token
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@%@",kAPIURL,kAuthWithCookieURL,token,kWordpressApiParameter];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    [self startRequestWithURL:url
   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
       BBTokenAuthResponse *response = [BBTokenAuthResponse new];
       response.valid = [[responseObject objectForKey:@"valid"] boolValue];
       
       if (response.valid)
       {
           [self checkSubscriptionForUser:self.activeuser];
       } else {
           //[self signinWithUsername:[Lockbox stringForKey:kBarBooksSubscriptionUsername] password:[Lockbox stringForKey:kBarBooksSubscriptionUserPassword]];
 
            [self displayError:@"Authentication Error" message:@"Please sign in again."];
            self.isLoggedIn = NO;
 
       }
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       NSLog(@"%@",error.localizedDescription);
   }];
}
*/



- (void) signinWithUsername:(NSString*)username password:(NSString*)password
{
    NSString *requestUsername = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)username, NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    NSString *requestPassword = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)password, NULL, (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    NSString *cookieURL = [NSString stringWithFormat:@"%@&username=%@&password=%@%@&profile=%@",kGenerateCookieURL,requestUsername,requestPassword,kWordpressApiParameter,[[BBAccountManager sharedManager].activeAccount.objectID couchbaseLiteIDRepresentation]];
    
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@",kAPIURL,cookieURL];
    
    
    [self startRequestWithURL:[NSURL URLWithString:urlString]
   completionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
       if ([responseObject objectForKey:@"cookie"])
       {
           NSString *userID = [NSString stringWithFormat:@"%i",[[[responseObject objectForKey:@"user"] objectForKey:@"id"] intValue]];
           
           self.isLoggedIn = YES;
           self.activeuser = username;
           
           [Lockbox setString:username forKey:kBarBooksSubscriptionUsername];
           [Lockbox setString:password forKey:kBarBooksSubscriptionUserPassword];
           
           [self checkSubscriptionForUser:userID];
           [[BBAccountManager sharedManager] createAccountIfNotExist];
           if (!self.syncActive) {
               [self activateReplication];
           }
           
           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginSuccessfulNotification object:nil];
       } else {
           self.isLoggedIn = NO;
//           [self displayError:@"Authentication Error" message:@"Please check your username and password."];
           
           [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedNotification object:nil];
       }
       
   } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
       //[self displayError:@"Connection Error" message:error.description];
       [[NSNotificationCenter defaultCenter] postNotificationName:kLoginFailedNotification object:error];
   }];
}

- (void) checkSubscriptionStatus
{
    BOOL internetAvailable = isInternetConnection();
    
    if (internetAvailable && self.activeuser && ([self daysOverdue] || [self subscriptionStatus] != BBSubscriptionStatusActive) ) {
        NSString *exists = [Lockbox stringForKey:kBarBooksSubscriptionUserPassword];
        if (exists) {
            self.isLoggedIn = YES;
            [self signinWithUsername:[Lockbox stringForKey:kBarBooksSubscriptionUsername] password:[Lockbox stringForKey:kBarBooksSubscriptionUserPassword]];
        }
    }
}

- (void) checkSubscriptionForUser:(NSString*)userID
{
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(checkSubscriptionForUser:) withObject:userID waitUntilDone:NO];
        return;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@%@%@",kWooCommerceAPI,kGetCustomerURL,userID];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", kWoocommerceKey, kWoocommerceSecret];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];
    
    [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    
    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    if (urlConnection) {
        self.responseData = [NSMutableData data];
    }
    
}


- (NSDate *)subscriptionEndDate
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionEndDate];
}

- (NSDate *)lastDateChecked
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionLastChecked];
}

- (NSInteger)daysOverdue
{
    NSInteger daysOverdue = 0;
    if ([self subscriptionEndDate]) {
        NSDate *subscriptionEndDate = [DateTimeUtility dateByAddingDays:14 toDate:[self subscriptionEndDate]] ;
        
        NSComparisonResult result = [DateTimeUtility compareDate:subscriptionEndDate toDate:[NSDate date]];
        
        if (result == NSOrderedAscending) {
            daysOverdue = [DateTimeUtility daysBetweenDate:[NSDate date] andDate:[self subscriptionEndDate]];
        } else if (result == NSOrderedDescending)
        {
            daysOverdue = -[DateTimeUtility daysBetweenDate:[NSDate date] andDate:[self subscriptionEndDate]];
        }
    }
    
    return daysOverdue;
}

- (BBSubscriptionStatus)subscriptionStatus
{
    NSNumber *status = [[NSUserDefaults standardUserDefaults] objectForKey:kSubscriptionActive];
    
    if (status) {
        return status.intValue;
    }
    
    return 0;
}

- (void) logout
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriptionEndDate];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriptionActive];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kSubscriptionLastChecked];
    
    [Lockbox setString:nil forKey:kBarBooksSubscriptionUsername];
    [Lockbox setString:nil forKey:kBarBooksSubscriptionUserPassword];
    [self stopSync];

    self.isLoggedIn = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSubscriptionUpdatedNotification object:nil];
}

- (void)startSubscriptionProcess
{
    // Just open the URL to start the subscription process
}


#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:self.responseData
                                                         options:kNilOptions
                                                           error:&error];
    
    if ([json objectForKey:@"customer"]) {
//        BBSubscriptionObject *status = [BBSubscriptionObject new];
//        NSInteger timestamp = [[[json objectForKey:@"customer"] objectForKey:@"subscription_expiration_timestamp"] integerValue] ;
//        status.expiration = [NSDate dateWithTimeIntervalSince1970:timestamp];
//        status.status = [[[json objectForKey:@"customer"] objectForKey:@"subscription_status"] intValue];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:status.expiration forKey:kSubscriptionEndDate];
//        [[NSUserDefaults standardUserDefaults] setObject:@(status.status) forKey:kSubscriptionActive];
//        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kSubscriptionLastChecked];
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:kSubscriptionUpdatedNotification object:nil];
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

#pragma mark - Couchbase

- (void)activateReplication
{
    self.syncActive = YES;
    CBLIncrementalStore *store = (CBLIncrementalStore*)[[[NSManagedObjectContext MR_rootSavingContext] persistentStoreCoordinator] persistentStores][0];
    store.delegate = self;
    NSManagedObjectContext *context = [NSManagedObjectContext MR_rootSavingContext];

    Account *oldAccount = [[BBAccountManager sharedManager] activeAccount];
    NSString *docID = [NSString stringWithFormat:@"account:%@",self.activeuser];

    if (!oldAccount || ![[oldAccount.objectID couchbaseLiteIDRepresentation] isEqualToString:docID]) {
        NSString *remoteDbURL = [COUCHBASE_SYNC_URL stringByAppendingString:COUCHBASE_DEFAULT_BUCKET];
        NSString *urlString = [NSString stringWithFormat:@"%@/%@",remoteDbURL,docID];
        [[NSNotificationCenter defaultCenter] postNotificationName:kCouchbaseMigrationStartedNotification object:nil];

        [self startCouchbaseUserRequestWithURL:[NSURL URLWithString:urlString]
                                    httpMethod:@"GET"
                                          data:nil
                                  onCompletion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                      
                                      CBLDocument *doc = [store.database documentWithID:docID];

                                      CBLUnsavedRevision* revision = [doc newRevision];

                                      NSMutableDictionary *objectInfo = nil;
                                      if (data) {
                                          
                                          NSError *error = nil;
                                          NSDictionary* responseObject = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:kNilOptions
                                                                                                           error:&error];
                                          
                                          
                                          if ([responseObject objectForKey:@"owner"]) {
                                              error = nil;
                                              objectInfo = [responseObject mutableCopy];
                                              //revision.userProperties = objectInfo;
                                              
//                                              [objectInfo setObject:[@"p" stringByAppendingString:[objectInfo objectForKey:@"_id"]]
//                                                             forKey:@"_id"];
                                              revision.properties = objectInfo;
                                          } else {
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kCouchbaseProfileNotFoundNotification object:nil];
                                              if (!oldAccount) {
                                                  return;
                                              }
                                          }
                                      }
                                      
                                      if (!objectInfo) {
                                          revision.userProperties = @{@"type":@"Account", @"owner":self.activeuser};
                                      }
                                      
                                      NSError *error = nil;
                                      CBLSavedRevision *rev = [revision save: &error];
                                      BOOL result = rev != nil;
                                      
                                      if (result) {
                                          [doc putProperties:objectInfo error:&error];
                                          
                                          NSArray *accounts = [Account MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"SELF != %@ AND owner == %@", oldAccount, self.activeuser] inContext:context];
                                          
                                          if (oldAccount) {
                                          }
                                      
                                          if (accounts.count) {
                                              
                                              Account *account = [accounts objectAtIndex:0];
                                              NSLog(@"%@",account.owner);

                                              if (!objectInfo && oldAccount) {
                                                  NSDictionary *attributes = [[NSEntityDescription
                                                                               entityForName:NSStringFromClass(account.class)
                                                                               inManagedObjectContext:context] attributesByName];
                                                  for (NSString *attr in attributes) {
                                                      if([oldAccount valueForKey:attr]) {
                                                          [account setValue:[oldAccount valueForKey:attr] forKey:attr];
                                                      }
                                                  }
                                              }
                                              
                                              
                                              
                                              if (oldAccount) {
                                                  [account setTemplates:oldAccount.templates];
                                                  [account setMatters:oldAccount.matters];
                                                  [account setReceipts:oldAccount.receipts];
                                                  [account setReports:oldAccount.reports];
                                                  [account setRates:oldAccount.rates];
                                              }
                                              // also set solicitors and stuff
                                              [context save:nil];
                                              [[BBAccountManager sharedManager] setActiveAccount:account];
                                              if (oldAccount) {
                                                  [context deleteObject:oldAccount];
                                                  [context save:nil];
                                              }
                                              
                                              [[NSNotificationCenter defaultCenter] postNotificationName:kCouchbaseProfileFoundNotification object:nil];
                                              if (!objectInfo) {
                                                  [self uploadProfile:doc];
                                              }
                                          }
                                          
                                          [self performSelectorOnMainThread:@selector(prepareAndSync) withObject:nil waitUntilDone:NO];
                                      }
                                      
         }];
        
        
    } else if(store.database.allReplications.count == 0) {
        [self prepareAndSync];
    } else {
        for (CBLReplication *repl in store.database.allReplications) {
            [repl start];
        }
    }
}

- (void) prepareAndSync {
    NSManagedObjectContext *context = [NSManagedObjectContext MR_rootSavingContext];
    [context save:nil];

    NSManagedObjectContext *moc = [NSManagedObjectContext MR_newPrivateQueueContext];

    [moc performBlock:^{
        
        // Given some NSManagedObjectContext *context
        NSManagedObjectModel *model = [moc.persistentStoreCoordinator
                                       managedObjectModel];
        
        for(NSEntityDescription *entity in [model entities]) {
            if (entity.isAbstract) {
                continue;
            }
            NSFetchRequest *request = [[NSFetchRequest alloc] init];
            [request setEntity:entity];
            request.predicate = [NSPredicate predicateWithFormat:@"owner == nil"];
            NSError *error;
            NSArray *results = [moc executeFetchRequest:request error:&error];
            
            // Error-checking here...
            for(BBManagedObject *object in results) {
                
                // Do your updates here
                object.owner = self.activeuser;
            }
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kCouchbaseMigrationFinishedNotification object:nil];
        
        [moc processPendingChanges];
        [moc save:nil];
        
        
        [self performSelectorOnMainThread:@selector(startSync) withObject:nil waitUntilDone:NO];
    }];
}

- (NSDictionary *)storeWillSaveDocument:(NSDictionary *)document
{
    if (self.activeuser) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:document];
        [dict setObject:self.activeuser forKey:@"owner"];
        
        return dict;
    }
    
    return document;
}

- (void)startSync
{
    CBLIncrementalStore *store = (CBLIncrementalStore*)[[[NSManagedObjectContext MR_rootSavingContext] persistentStoreCoordinator] persistentStores][0];
    
    NSString *password = [Lockbox stringForKey:kBarBooksSubscriptionUserPassword];
    
    NSURL *remoteDbURL = [NSURL URLWithString:[COUCHBASE_SYNC_URL stringByAppendingString:COUCHBASE_DEFAULT_BUCKET]];
    
    CBLReplication *pull = [store.database createPullReplication:remoteDbURL];
    CBLReplication *push = [store.database createPushReplication:remoteDbURL];
    id<CBLAuthenticator> auth = [CBLAuthenticator basicAuthenticatorWithName:self.activeuser password:password];
    
    [push setAuthenticator:auth];
    [pull setAuthenticator:auth];
    
    [self startReplication:pull];
    [self startReplication:push];
    
    
}

- (void)uploadProfile:(CBLDocument*)accountDoc {
    
    NSMutableDictionary *properties = [accountDoc.properties mutableCopy];
    [properties removeObjectForKey:@"_rev"];
    [properties setObject:self.activeuser forKey:@"owner"];
    
    NSString *remoteDbURL = [COUCHBASE_SYNC_URL stringByAppendingString:COUCHBASE_DEFAULT_BUCKET];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:properties
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    
    [self startCouchbaseUserRequestWithURL:[NSURL URLWithString:[remoteDbURL stringByAppendingString:@"/"]]
                                httpMethod:@"POST"
                                      data:jsonData
                              onCompletion:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                  
                              }];
    
}

- (void)stopSync
{
    self.syncActive = NO;
    CBLIncrementalStore *store = (CBLIncrementalStore*)[[[NSManagedObjectContext MR_rootSavingContext] persistentStoreCoordinator] persistentStores][0];
    for (CBLReplication *repl in store.database.allReplications) {
        [repl stop];
    }
}

/**
 * Utility method to configure, start and observe a replication.
 */
- (void)startReplication:(CBLReplication *)repl {
    repl.continuous = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector: @selector(replicationProgress:)
                                                 name:kCBLReplicationChangeNotification object:repl];
    [repl start];
}

/**
 Observer method called when the push or pull replication's progress or status changes.
 */
- (void)replicationProgress:(NSNotification *)notification {
    
    CBLReplication *repl = notification.object;
    NSError* error = repl.lastError;
    
    if (repl.status != self.syncStatus) {
        self.syncStatus = repl.status;
        [[NSNotificationCenter defaultCenter] postNotificationName:kSyncStatusUpdatedNotification object:nil];
    }
    
    self.changes = repl.changesCount;
    self.changesCompleted = repl.completedChangesCount;
    
    self.progress = (CGFloat)repl.completedChangesCount/(CGFloat)repl.changesCount;
    if (self.progress == 1 || repl.changesCount == 0) {
        self.progress = 0;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncStatusProgressedNotification object:nil];
    NSLog(@"Pending = %lu",repl.documentIDs.count);
    NSLog(@"%@ replication: status = %d, progress = %u / %u, err = %@",
          (repl.pull ? @"Pull" : @"Push"), repl.status, repl.changesCount, repl.completedChangesCount,
          error.localizedDescription);
    
    
    if (error) {
        NSString* msg = [NSString stringWithFormat: @"Sync failed with an error: %@", error.localizedDescription];
        NSLog(@"%@",msg);
    }
}


@end
