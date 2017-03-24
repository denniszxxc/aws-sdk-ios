//
//  AWSMobileAnalyticsCustomUserDefaultEventStore.h
//  AWStvOSSDKv2
//
//  Created by Zensis Ltd on 24/3/2017.
//  Copyright © 2017 Amazon Web Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AWSMobileAnalyticsContext.h"
#import "AWSMobileAnalyticsEventStore.h"

@interface AWSMobileAnalyticsCustomUserDefaultEventStore : NSObject<AWSMobileAnalyticsEventStore>

+(AWSMobileAnalyticsCustomUserDefaultEventStore *) fileStoreWithContext:(id<AWSMobileAnalyticsContext>) theContext;

-(id) initWithContext: (id<AWSMobileAnalyticsContext>) theContext;

-(BOOL) put:(NSString *) theEvent withError:(NSError**) theError;
-(id<AWSMobileAnalyticsEventIterator>) iterator;

@property (nonatomic, readwrite) id<AWSMobileAnalyticsContext> context;


@end

@interface AWSUserDefaultEventIterator : NSObject<AWSMobileAnalyticsEventIterator>

-(id) initFileStore:(AWSMobileAnalyticsCustomUserDefaultEventStore *) theEventStore;

-(void) removeReadEvents;

-(NSString *) peek;

-(BOOL) hasNext;

-(NSString *) next;

@end
