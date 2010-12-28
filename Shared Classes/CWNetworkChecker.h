//
//  CWNetworkChecker.h
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

#import <Foundation/Foundation.h>


/*!
 * @abstract Utility class for checking the availability of the network.
 *
 * @discussion DEPRECATED, use CWNetworkMonitor for asynchronious and 
 *             continious network monitoring.
 */
@interface CWNetworkChecker : NSObject {
}

/*!
 * @abstract Set the default host to query for availabilty, default is google.com.
 */
+(void)setDefaultHost:(NSString*)hostName;

/*!
 * @abstract Set the default availability caching time. Default time is 5 minutes.
 */
+(void)setDefaultCacheTimeInterval:(NSTimeInterval)timeInterval;

/*!
 * @abstract Query if network is available using the default host and cache time interval of 5 minutes.
 */
+(BOOL)isNetworkAvailable;

/*!
 * @abstract Is reached via a cellular connection, such as EDGE or GPRS.
 */
+(BOOL)isWWAN;

/*!
 * @abstract Query if network is available using a specific host, and use cached responses not older than specified time interval.
 */
+(BOOL)isHostAvailable:(NSString*)hostName sinceTimeInterval:(NSTimeInterval)timeInterval;

@end
