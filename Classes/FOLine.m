//
//  CWLine.m
//  ResaISkane
//
//  Copyright 2009-2010 Fredrik Olsson. All rights reserved.
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

#import "FOLine.h"
#import "CWXMLTranslator.h"
#import "FOModel.h"
#import "NSDate+CWExtentions.h"
#import "CWTranslatedString.h"
#import <objc/runtime.h>

@interface FOLineParser : NSObject <CWXMLTranslatorDelegate> {
@private
    NSURL* url;
    FOModel* sharedModel;
    NSDate* futureDate;
}

-(id)initWithPoint:(FOPoint*)point at:(NSDate*)time;
-(NSArray*)parseLines;

@end


@implementation FOLine

@synthesize name = _name;
@synthesize number = _number;
@synthesize departure = _departure;
@synthesize stopPoint = _stopPoint;
@synthesize towards = _towards;
@synthesize deviations = _deviations;

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWLine", 0);
	objc_registerClassPair(cls);
}

-(NSString*)fullName;
{
	NSString* fullName = self.typeName;
    if ([self.name intValue] != 0) {
        fullName = [fullName stringByAppendingFormat:@" %@", self.name];
    } else if (self.number != nil) {
        fullName = [fullName stringByAppendingFormat:@" %@", self.number];
    }
    return fullName;
}

-(NSString*)typeName;
{
	if ([[FOModel sharedModel] typeIdForTypeName:_typeName] == 0) {
        return NSLocalizedString(@"Walk", nil);
    }
    return _typeName;
}

-(NSDate*)deviatedDeparture;
{
	if (_departureDeviation == 0) {
		return nil;
    } else {
        return [_departure addTimeInterval:_departureDeviation * 60];
    }
}

-(NSDate*)actualDeparture;
{
	if (_departureDeviation != 0) {
        return self.deviatedDeparture;
    } else {
        return self.departure;
    }
}

-(NSString*)deviationsAsString;
{
	NSMutableArray* strings = [NSMutableArray array];
    if (![self.departure isEqualToDate:self.actualDeparture]) {
		[strings addObject:[NSString stringWithFormat:NSLocalizedString(@"ActualDeviationTimeDeparture", nil), [self.actualDeparture localizedShortTimeString]]];
    }
    for (FODeviation* deviation in self.deviations) {
        if (deviation.header) {
			[strings addObject:deviation.header];
        }
        if (deviation.shortText) {
            [strings addObject:deviation.shortText];
        }
    }
    return [strings count] ? [strings componentsJoinedByString:@"\n"] : nil;
}

-(UIColor*)color;
{
    switch ([[FOModel sharedModel] typeIdForTypeName:self.typeName]) {
        case 1:
            return [UIColor colorWithRed:0.0f green:1.0f blue:0.0f alpha:0.7f];
        case 2:
        case 4:
        case 8:
            return [UIColor colorWithRed:2.0f green:1.5f blue:0.0f alpha:0.7f];
        case 16:
            return [UIColor colorWithRed:5.0f green:0.1f blue:0.0f alpha:0.7f];
        case 32:
            return [UIColor colorWithRed:5.0f green:0.0f blue:0.5f alpha:0.7f];
        case 64:
            return [UIColor colorWithRed:0.0f green:0.0f blue:7.0f alpha:0.7f];
        case 128:
            return [UIColor colorWithWhite:0.0f alpha:0.7f];
        default:
            return [UIColor colorWithWhite:0.1f alpha:0.7f];
    }
}


+(NSArray*)linesFromPoint:(FOPoint*)point at:(NSDate*)time;
{
    FOLineParser* lineParser = [[FOLineParser alloc] initWithPoint:point at:time];
    NSArray* lines = [lineParser parseLines];
    NSLog(@"Points: %@", [lines description]);
	[lineParser release];
    return lines;
}

-(BOOL)isDeviated;
{
	return _departureDeviation != 0 || [self.deviations count];
}



-(BOOL)isTrain;
{
	switch ([[FOModel sharedModel] typeIdForTypeName:_typeName]) {
        case 16:
        case 32:
			return YES;
        default:
			return NO;
    }
}

-(BOOL)isBus;
{
	switch ([[FOModel sharedModel] typeIdForTypeName:_typeName]) {
        case 1:
        case 2:
        case 4:
        case 8:
			return YES;
        default:
			return NO;
    }
}

-(UIImage*)typeImage;
{
	return [UIImage imageNamed:[NSString stringWithFormat:@"type-%d.png", [[FOModel sharedModel] typeIdForTypeName:_typeName]]];
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [self init];
    if (self) {
        _name = [[aDecoder decodeObjectForKey:@"name"] retain];
        _number = [[aDecoder decodeObjectForKey:@"number"] retain];
        _departure = [[aDecoder decodeObjectForKey:@"departure"] retain];
        _departureDeviation = [aDecoder decodeIntegerForKey:@"departureDeviation"];
        _stopPoint = [[aDecoder decodeObjectForKey:@"stopPoint"] retain];
        _typeName = [[aDecoder decodeObjectForKey:@"typeName"] retain];
        _towards = [[aDecoder decodeObjectForKey:@"towards"] retain];
        _deviations = [[aDecoder decodeObjectForKey:@"deviations"] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.number forKey:@"number"];
    [aCoder encodeObject:self.departure forKey:@"departure"];
	[aCoder encodeInteger:_departureDeviation forKey:@"departureDeviation"];
    [aCoder encodeObject:self.stopPoint forKey:@"stopPoint"];
    [aCoder encodeObject:self.typeName forKey:@"typeName"];
    [aCoder encodeObject:self.towards forKey:@"towards"];
    [aCoder encodeObject:self.deviations forKey:@"deviations"];
}

-(void)dealloc;
{
	[_name release];
    [_number release];
	[_typeName release];
    [_towards release];
    [super dealloc];
}

-(BOOL)isEqual:(id)anObject;
{
    if (self == anObject) {
        return YES;
    } else if ([anObject isKindOfClass:[FOLine class]]) {
        FOLine* otherLine = anObject;
        return ([self.name isEqualToString:otherLine.name] &&
                [self.number isEqualToString:otherLine.number] &&
                [self.towards isEqualToString:otherLine.towards]);
    }
    return NO;
}

-(NSString*)description;
{
    return [NSString stringWithFormat:@"<CWLine: '%@', %@, %@, '%@' %@>", self.name, self.number, self.typeName, self.towards, self.actualDeparture];
}

@end



@implementation FOLineParser

+(NSURL*)queryURLForPoint:(FOPoint*)point at:(NSDate*)time;
{
    static NSString* queryFormat = @"stationresults.asp?inpDate=%@&selDirection=0&selpointfrkey=%d&inpTime=%@";
    NSString* query = [NSString stringWithFormat:queryFormat, [time compactISODate], point.ID, [time compactISOTime]];
    query = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerURL"] stringByAppendingString:query];
    NSURL* url = [NSURL URLWithString:query];
    NSLog(@"%@", url);
    return url;
}

-(id)initWithPoint:(FOPoint*)point at:(NSDate*)time;
{
    self = [super init];
    if (self) {
        url = [[FOLineParser queryURLForPoint:point at:time] retain];
        sharedModel = [FOModel sharedModel];
        futureDate = [[time addTimeInterval:60*60*2] retain];
    }
    return self;
}

-(void)dealloc;
{
    [url release];
    [futureDate release];
    [super dealloc];
}

-(NSArray*)parseLines;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDate* delayDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    NSDictionary* translation = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FOLineParser" ofType:@"plist"]];
	CWXMLTranslator* translater = [[CWXMLTranslator alloc] initWithTranslationPropertyList:translation delegate:self];
	NSError* error = nil;
    NSArray* lines = [translater translateContentsOfURL:url error:&error];
    NSString* errorMessage = NSLocalizedString(@"FailedNetworkMessage", nil);
    if ([lines count] > 0 && [[lines objectAtIndex:0] isKindOfClass:[NSString class]]) {
		errorMessage = [lines objectAtIndex:0];
        if (sharedModel.translateTexts) {
            errorMessage = CWTranslatedString(errorMessage, @"sv");
        }
        lines = nil;
    }
    if (lines == nil) {
        NSLog(@"Error: %@", [error description]);
        NSLog(@"URL: %@", [url description]);
        //NSLog(@"XML: %@", [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL]);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FailedNetwork", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        lines = nil;
    } else {
        [NSThread sleepUntilDate:delayDate];
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	return lines;
}

-(id)xmlTranslator:(CWXMLTranslator *)translator didTranslateObject:(id)anObject forKey:(NSString*)key;
{
	if ([key isEqual:@"Message"] && [anObject length] == 0) {
        return nil;
    } else if ([anObject isKindOfClass:[FOLine class]] && [[anObject departure] compare:futureDate] > NSOrderedSame) {
        [translator abortTranslation];
        return nil;
    }
    return anObject;
}

-(id)xmlTranslator:(CWXMLTranslator *)translator primitiveObjectInstanceOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;
{
	if (aClass == [NSDate class]) {
        return [NSDate dateWithISODateString:aString];
    } else if (sharedModel.translateTexts && ([key isEqualToString:@"header"] || [key isEqualToString:@"shortText"])) {
		return CWTranslatedString(aString, @"sv");
    }
    return nil;
}

@end

