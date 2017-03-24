//
//  AWSMobileAnalyticsCustomUserDefaultEventStore.m
//  AWStvOSSDKv2
//
//  Created by Zensis Ltd on 24/3/2017.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import "AWSMobileAnalyticsCustomUserDefaultEventStore.h"

#define AWSMobileAnalyticsCustomUserDefaultKey @"AWSMobileAnalyticsCustomUserDefault"

@implementation AWSMobileAnalyticsCustomUserDefaultEventStore

+ (AWSMobileAnalyticsCustomUserDefaultEventStore *)fileStoreWithContext:(id<AWSMobileAnalyticsContext>)theContext {
    NSAssert(theContext != nil, @"The context cannot be nil");
    NSAssert(theContext.identifier != nil, @"The context identifier cannot be nil");
    NSAssert(theContext.configuration != nil, @"The configuration cannot be nil");
    NSAssert(theContext.system != nil, @"The system cannot be nil");

    if (theContext == nil) {
        AWSLogError(@"Could not construct the AWSMobileAnalyticsFileEventStore because the context was nil");
        return nil;
    }

    return [[AWSMobileAnalyticsCustomUserDefaultEventStore alloc] initWithContext:theContext];
}
-(id) initWithContext:(id<AWSMobileAnalyticsContext>) theContext {
    if(self = [super init])
    {
        self.context = theContext;
    }
    return self;
}

-(BOOL) put:(NSString *) theEvent withError:(NSError**) theError {
    BOOL success = NO;
    @synchronized (self) {
        NSMutableArray *eventArray = [[[NSUserDefaults standardUserDefaults] arrayForKey:AWSMobileAnalyticsCustomUserDefaultKey] mutableCopy];

        if (eventArray == nil) {
            eventArray = [[NSMutableArray alloc] init];
        }

        [eventArray addObject:theEvent];

        [[NSUserDefaults standardUserDefaults] setObject:eventArray forKey:AWSMobileAnalyticsCustomUserDefaultKey];
        success = [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    return success;
}

-(id<AWSMobileAnalyticsEventIterator>) iterator {
    return [[AWSUserDefaultEventIterator alloc] initFileStore:self];
}


@end

@interface AWSUserDefaultEventIterator ()

@property (strong, nonatomic) NSArray<NSString *> *eventArray;
@property (assign, nonatomic) NSInteger readArrayIndex;

@property (weak, nonatomic) AWSMobileAnalyticsCustomUserDefaultEventStore *theEventStore;

@end

@implementation AWSUserDefaultEventIterator

- (id)initFileStore:(AWSMobileAnalyticsCustomUserDefaultEventStore *)theEventStore {
    if (self = [super init]) {
        self.eventArray = [[NSUserDefaults standardUserDefaults] arrayForKey:AWSMobileAnalyticsCustomUserDefaultKey];
        self.readArrayIndex = -1;
    }
    return self;
}

- (void)removeReadEvents {
    @synchronized (self.theEventStore) {
        NSMutableArray *mutableEventArray = [self.eventArray mutableCopy];
        [mutableEventArray removeObjectsInRange:NSMakeRange(0, self.readArrayIndex + 1)];

        [[NSUserDefaults standardUserDefaults] setObject:mutableEventArray forKey:AWSMobileAnalyticsCustomUserDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];

        self.eventArray = mutableEventArray;
        self.readArrayIndex = -1;
    }
}

- (NSString *)peek {
    @synchronized(self.theEventStore) {
        if (self.readArrayIndex + 1 < self.eventArray.count) {
            return [self.eventArray objectAtIndex:self.readArrayIndex + 1];
        }
        return nil;
    }
}

- (BOOL)hasNext {
    @synchronized(self.theEventStore) {
        return (self.readArrayIndex + 1 < self.eventArray.count);
    }
}

- (NSString *)next {
    @synchronized(self.theEventStore) {

        if (self.readArrayIndex + 1 < self.eventArray.count) {
            self.readArrayIndex++;
            return [self.eventArray objectAtIndex:self.readArrayIndex];
        }
        return nil;
    }
}

@end
