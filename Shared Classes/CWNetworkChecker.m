//
//  CWNetworkChecker.m
//  CWFoundationAdditions
//
//  Copyright 2008 Jayway. All rights reserved.
//  Created by Fredrik Olsson.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CWNetworkChecker.h"
#import <SystemConfiguration/SystemConfiguration.h>


@implementation CWNetworkChecker

static NSString* defaultHost = @"google.com";
static NSTimeInterval defaultCacheTime = 60.0 * 5;
static BOOL isWWAN = NO;

+(void)setDefaultHost:(NSString*)hostName;
{
	defaultHost = [hostName copy];
}

+(void)setDefaultCacheTimeInterval:(NSTimeInterval)timeInterval;
{
    defaultCacheTime = timeInterval;
}

+(BOOL)isNetworkAvailable;
{
	return [self isHostAvailable:defaultHost 
               sinceTimeInterval:defaultCacheTime];
}

+(BOOL)isWWAN;
{
	return [self isNetworkAvailable] && isWWAN;   
}

+(BOOL)isHostAvailable:(NSString*)hostName sinceTimeInterval:(NSTimeInterval)timeInterval;
{
	static NSMutableDictionary* hosts = nil;
    if (hosts == nil) {
        hosts = [NSMutableDictionary new];
    }
    NSDate* now = [NSDate date];
	NSArray* checker = [hosts objectForKey:hostName];
    if (checker != nil && -([[checker objectAtIndex:0] timeIntervalSinceNow]) > timeInterval) {
		checker = nil;
    }
	if (checker == nil) {
        Boolean success;    
		const char *host_name = [hostName cStringUsingEncoding:NSASCIIStringEncoding];
		
		SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host_name);
		SCNetworkReachabilityFlags flags;
		success = SCNetworkReachabilityGetFlags(reachability, &flags);
		BOOL available = success && (flags & kSCNetworkFlagsReachable) ; // && !(flags & kSCNetworkFlagsConnectionRequired);
		isWWAN = (flags & kSCNetworkReachabilityFlagsIsWWAN) != 0;
		CFRelease(reachability);
        checker = [NSArray arrayWithObjects:now, [NSNumber numberWithBool:available], nil];
        [hosts setValue:checker forKey:hostName];
    }
    return [[checker objectAtIndex:1] boolValue];
}

@end
