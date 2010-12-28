//
//  NSDate+CWExtentions.m
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

#import "NSDate+CWExtentions.h"

@implementation NSLocale (CWISOLocale) 

+(NSLocale*)ISOLocale;
{
	static NSLocale* isoLocale = nil;
  @synchronized(self) {
    // Sweden is close enough for ISO.
    isoLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"sv_SE"];
  }
  return isoLocale;
}

@end


@implementation NSCalendar (CWGregorianCalendar)

+(NSCalendar*)gregorianCalendar;
{
	static NSCalendar* gregorianCalendar = nil;
  @synchronized(self) {
    if (gregorianCalendar == nil) {
      gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    }
  }
  return gregorianCalendar;
}

@end


@implementation NSDate (CWISOAdditions)

+(NSDate*)dateWithISODateString:(NSString*)isoDate;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized(self) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
      [dateFormatter setLocale:[NSLocale ISOLocale]];
      [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    }
  }
  return [dateFormatter dateFromString:isoDate];
}

-(NSString*)ISODate;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
      [dateFormatter setLocale:[NSLocale ISOLocale]];
      [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    }
  }
  return [dateFormatter stringFromDate:self];
}

-(NSString*)ISOTime;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
      [dateFormatter setLocale:[NSLocale ISOLocale]];
      [dateFormatter setDateFormat:@"HH:mm:ss"];
    }
  }
  return [dateFormatter stringFromDate:self];
}

-(NSString*)compactISODate;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
      [dateFormatter setLocale:[NSLocale ISOLocale]];
      [dateFormatter setDateFormat:@"yyMMdd"];
    }
  }
  return [dateFormatter stringFromDate:self];
}

-(NSString*)compactISOTime;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setCalendar:[NSCalendar gregorianCalendar]];
      [dateFormatter setLocale:[NSLocale ISOLocale]];
      [dateFormatter setDateFormat:@"HHmm"];
    }
  }
  return [dateFormatter stringFromDate:self];
}

@end

@interface CWRelativeDate : NSDate {
@private
  NSTimeInterval _timeIntervalSinceNow;
}

-(id)initWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;

@end

@implementation CWRelativeDate

-(id)initWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;
{
  self = [super init];
  if (self) {
    _timeIntervalSinceNow = timeInterval;
  }
  return self;
}

-(Class)classForCoder;
{
  return [self class];
}

-(id)initWithCoder:(NSCoder*)aDecoder;
{
  self = [super init];
  if (self) {
    _timeIntervalSinceNow = [aDecoder decodeDoubleForKey:@"timeIntervalSinceNow"];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder*)aCoder;
{
  [aCoder encodeDouble:_timeIntervalSinceNow forKey:@"timeIntervalSinceNow"];
}

-(NSTimeInterval)timeIntervalSinceNow;
{
	return _timeIntervalSinceNow;  
}

-(NSTimeInterval)timeIntervalSinceReferenceDate;
{
  return [[NSDate date] timeIntervalSinceReferenceDate] + _timeIntervalSinceNow;
}


-(NSString*)localizedShortString;
{
  NSString* key = nil;
  if (_timeIntervalSinceNow == 0.0) {
    key = @"Now";
  } else if (_timeIntervalSinceNow == 60.0 * 15) {
    key = @"QuarterHour";
  } else if (_timeIntervalSinceNow == 60.0 * 30) {
    key = @"HalfHour";
  } else if (_timeIntervalSinceNow == 60.0 * 60) {
    key = @"Hour";
  } else {
    // TODO: This is no good, since a relative time is constantly moving in time.
    return [super localizedShortString];
  }
  return NSLocalizedString(key, nil);
}

-(BOOL)isRelativeDate;
{
  return YES;
}

-(BOOL)isEqualToDate:(NSDate *)otherDate;
{
	if ([otherDate isKindOfClass:[CWRelativeDate class]]) {
    return _timeIntervalSinceNow == ((CWRelativeDate*)otherDate)->_timeIntervalSinceNow;
  } else {
		return [super isEqualToDate:otherDate];    
  }
}

@end


@implementation NSDate (CWRelativeDate)

+(NSDate*)relativeDateWithTimeIntervalSinceNow:(NSTimeInterval)timeInterval;
{
  return [[[CWRelativeDate alloc] initWithTimeIntervalSinceNow:timeInterval] autorelease];
}

-(NSString*)localizedShortString;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setDateStyle:NSDateFormatterShortStyle];
      [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
  }
  return [dateFormatter stringFromDate:self];
}


-(NSString*)localizedShortDateString;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setDateStyle:NSDateFormatterShortStyle];
      [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    }
  }
  return [dateFormatter stringFromDate:self];
}

-(NSString*)localizedShortTimeString;
{
  static NSDateFormatter* dateFormatter = nil;
  @synchronized([self class]) {
    if (dateFormatter == nil) {
      dateFormatter = [NSDateFormatter new];
      [dateFormatter setDateStyle:NSDateFormatterNoStyle];
      [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
  }
  return [dateFormatter stringFromDate:self];
}

-(BOOL)isRelativeDate;
{
  return NO;
}

@end