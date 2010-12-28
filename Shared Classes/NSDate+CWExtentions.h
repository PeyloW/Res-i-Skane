//
//  NSDate+CWExtentions.h
//  SharedComponents
//
//  Copyright 2008-2010 Jayway. All rights reserved.
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

@interface NSLocale (CWISOLocale) 

/*!
 * @abstract Get a locale mathcing the ISO standard.
 */
+(NSLocale*)ISOLocale;

@end

@interface NSCalendar (CWGregorianCalendar)

/*!
 * @abstract Get a Gregorian calendar.
 */
+(NSCalendar*)gregorianCalendar;

@end

/*!
 * @abstract Category for working with proper ISO dates.
 */
@interface NSDate (CWISOAdditions)

/*!
 * @abstract Get a date from a string with a proper ISO date.
 */
+(NSDate*)dateWithISODateString:(NSString*)isoDate;

-(NSString*)ISODate;         //! Full ISO date, "2010-01-12".
-(NSString*)ISOTime;         //! Full ISO time, "13:52"
-(NSString*)compactISODate;  //! Compact ISO date, "100112".
-(NSString*)compactISOTime;  //! Comapct ISO date, "1352".

@end

/*!
 * @abstract Category for managing dates relative to the current date and time.
 */
@interface NSDate (CWRelativeDate)

/*!
 * @abstract Get a date that is relative to the current date and time.
 */
+(NSDate*)relativeDateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;

-(NSString*)localizedShortString;
-(NSString*)localizedShortDateString;
-(NSString*)localizedShortTimeString;

/*!
 * @abstract Query if date is relative to current date and time.
 */ 
-(BOOL)isRelativeDate;

@end