//
//  CWJourney.m
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

#import "FOJourney.h"
#import "CWXMLTranslator.h"
#import "FOPoint.h"
#import "FORouteLink.h"
#import "NSDate+CWExtentions.h"
#import "FOModel.h"
#import "CWTranslatedString.h"
#import <objc/runtime.h>

@interface FOJourneyParser : NSObject <CWXMLTranslatorDelegate> {
@private
    NSURL* url;
    FOModel* sharedModel;
}

-(id)initWithFrom:(FOPoint*)from to:(FOPoint*)to at:(NSDate*)time inDirection:(FOJourneyDirection)direction;
-(id)initWithBeforeJourney:(FOJourney*)journey;
-(id)initWithAfterJourney:(FOJourney*)journey;

-(NSArray*)parseJourneys;

@end


@implementation FOJourney

@synthesize journeyKey = _journeyKey;
@synthesize sequenceNo = _sequenceNo;

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWJourney", 0);
	objc_registerClassPair(cls);
}

-(FOPoint*)from;
{
    return ((FORouteLink*)[self.routeLinks objectAtIndex:0]).from;
}

-(NSDate*)departure;
{
    return ((FORouteLink*)[self.routeLinks objectAtIndex:0]).departure;
}

-(NSDate*)actualDeparture;
{
    return ((FORouteLink*)[self.routeLinks objectAtIndex:0]).actualDeparture;
}

-(FOPoint*)to;
{
    return ((FORouteLink*)[self.routeLinks lastObject]).to;
}

-(NSDate*)arrival;
{
    return ((FORouteLink*)[self.routeLinks lastObject]).arrival;
}

-(NSDate*)actualArrival;
{
    return ((FORouteLink*)[self.routeLinks lastObject]).actualArrival;
}

-(NSUInteger)numberOfChanges;
{
    return [self.routeLinks count] - 1;
}

-(NSArray*)parts;
{
    if (_parts == nil) {
        if ([self canFetchParts]) {
            _parts = [[FOPart partsWithJourney:self] retain];
        }
    }
    return _parts;
}

-(BOOL)isDeviated;
{
	for (FORouteLink* link in self.routeLinks) {
        if ([link isDeviated]) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)canFetchParts;
{
    return _journeyKey != nil || [_parts count] > 0;
}

@synthesize routeLinks = _routeLinks;

+(NSArray*)journeysFrom:(FOPoint*)from to:(FOPoint*)to at:(NSDate*)time inDirection:(FOJourneyDirection)direction;
{
    FOJourneyParser* parser = [[FOJourneyParser alloc] initWithFrom:from to:to at:time inDirection:direction];
    NSArray* journeys = [parser parseJourneys];
    NSLog(@"%@", [journeys description]);
    [parser release];
    return journeys;
}

+(NSArray*)journeysBefore:(FOJourney*)journey;
{
    FOJourneyParser* parser = [[FOJourneyParser alloc] initWithBeforeJourney:journey];
    NSArray* journeys = [parser parseJourneys];
    NSLog(@"%@", [journeys description]);
    [parser release];
    return journeys;
}

+(NSArray*)journeysAfter:(FOJourney*)journey;
{
    FOJourneyParser* parser = [[FOJourneyParser alloc] initWithAfterJourney:journey];
    NSArray* journeys = [parser parseJourneys];
    NSLog(@"%@", [journeys description]);
    [parser release];
    return journeys;
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [self init];
    if (self) {
        _routeLinks = [[aDecoder decodeObjectForKey:@"routeLinks"] retain];
        _parts = [[aDecoder decodeObjectForKey:@"parts"] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.routeLinks forKey:@"routeLinks"];
    [aCoder encodeObject:self.parts forKey:@"parts"];
}

-(void)dealloc;
{
    [_journeyKey release];
    [_routeLinks release];
    [_parts release];
    [super dealloc];
}

-(BOOL)isEqual:(id)anObject;
{
    if (self == anObject) {
        return YES;
    } else if ([anObject isKindOfClass:[FOJourney class]]) {
        FOJourney* otherJourney = anObject;
        return [self.routeLinks isEqualToArray:otherJourney.routeLinks];
    }
    return NO;
}

-(NSString*)description;
{
    return [NSString stringWithFormat:@"<CWRouteLink: %@ at %@, %@ at %@, %@", self.from, self.departure, self.to, self.arrival, self.routeLinks];
}

@end

@implementation FOJourneyParser


+(NSURL*)queryURLForFrom:(FOPoint*)from to:(FOPoint*)to at:(NSDate*)time inDirection:(FOJourneyDirection)direction;
{
    static NSString* queryFormat = @"resultspage.asp?cmdaction=search&selpointfr=%@&selpointto=%@&inpDate=%@&inpTime=%@&selDirection=%d";
    NSString* query = [NSString stringWithFormat:queryFormat, from.queryString, to.queryString, [time compactISODate], [time compactISOTime], direction];
    query = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerURL"] stringByAppendingString:query];
    NSURL* url = [NSURL URLWithString:query];
    NSLog(@"%@", url);
    return url;
}

+(NSURL*)queryURLForBeforeJourney:(FOJourney*)journey;
{
    static NSString* queryFormat = @"resultspage.asp?FirstStart=%@%%20%@&selpointfr=%@&selpointto=%@&cmdaction=previous";
    FOPoint* from = [FOModel sharedModel].from;   // journey.from;
    FOPoint* to = [FOModel sharedModel].to;       //journey.to;
    NSDate* time = journey.departure;
    NSString* query = [NSString stringWithFormat:queryFormat, [time ISODate], [time ISOTime], from.queryString, to.queryString];
    query = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerURL"] stringByAppendingString:query];
    NSURL* url = [NSURL URLWithString:query];
    NSLog(@"%@", url);
    return url;
}

+(NSURL*)queryURLForAfterJourney:(FOJourney*)journey;
{
    static NSString* queryFormat = @"resultspage.asp?LastStart=%@%%20%@&selpointfr=%@&selpointto=%@&cmdaction=next";
    FOPoint* from = [FOModel sharedModel].from;   // journey.from;
    FOPoint* to = [FOModel sharedModel].to;       //journey.to;
    NSDate* time = journey.departure;
    NSString* query = [NSString stringWithFormat:queryFormat, [time ISODate], [time ISOTime], from.queryString, to.queryString];
    query = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerURL"] stringByAppendingString:query];
    NSURL* url = [NSURL URLWithString:query];
    NSLog(@"%@", url);
    return url;
}

-(id)init;
{
	self = [super init];
    if (self) {
        sharedModel = [FOModel sharedModel];
    }
    return self;
}

-(id)initWithFrom:(FOPoint*)from to:(FOPoint*)to at:(NSDate*)time inDirection:(FOJourneyDirection)direction;
{
    self = [self init];
    if (self) {
        url = [[FOJourneyParser queryURLForFrom:from to:to at:time inDirection:direction] retain];
    }
    return self;
}

-(id)initWithBeforeJourney:(FOJourney*)journey;
{
    self = [self init];
    if (self) {
        url = [[FOJourneyParser queryURLForBeforeJourney:journey] retain];
    }
    return self;
}

-(id)initWithAfterJourney:(FOJourney*)journey;
{
    self = [self init];
    if (self) {
        url = [[FOJourneyParser queryURLForAfterJourney:journey] retain];
    }
    return self;
}

-(void)dealloc;
{
    [url release];
    [super dealloc];
}

-(void)fixCoordinatesForKnownPointsInJourneys:(NSArray*)journeys;
{
	for (FOJourney* journey in journeys) {
		for (FORouteLink* link in journey.routeLinks) {
            if (link.from.ID < CWPointCurrentLocationID) {
				link.from.coordinate;
            }
            if (link.to.ID < CWPointCurrentLocationID) {
				link.to.coordinate;
            }
        }
    }
}

-(NSArray*)parseJourneys;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDate* delayDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    NSDictionary* translation = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FOJourneyParser" ofType:@"plist"]];
	CWXMLTranslator* translater = [[CWXMLTranslator alloc] initWithTranslationPropertyList:translation delegate:self];
	NSError* error = nil;
    NSArray* journeys = [translater translateContentsOfURL:url error:&error];
    NSString* errorMessage = NSLocalizedString(@"FailedNetworkMessage", nil);
    if ([journeys count] > 0 && [[journeys objectAtIndex:0] isKindOfClass:[NSString class]]) {
		errorMessage = [journeys objectAtIndex:0];
        if ([errorMessage longLongValue] > 0) {
            [errorMessage retain];
            journeys = [journeys subarrayWithRange:NSMakeRange(1, [journeys count] - 1)];
            for (FOJourney* j in journeys) {
                [j setValue:errorMessage forKey:@"journeyKey"];
            }
            
        } else {
            if (sharedModel.translateTexts) {
                errorMessage = CWTranslatedString(errorMessage, @"sv");
            }
            journeys = nil;
        }
    }
    if (journeys == nil) {
        NSLog(@"Error: %@", [error description]);
        NSLog(@"URL: %@", [url description]);
        //NSLog(@"XML: %@", [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL]);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FailedNetwork", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        journeys = nil;
    } else {
        [NSThread sleepUntilDate:delayDate];
    }
    
	[self fixCoordinatesForKnownPointsInJourneys:journeys];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	return journeys;
}

-(id)xmlTranslater:(CWXMLTranslator *)translater didTranslateObject:(id)anObject forKey:(NSString *)key;
{
	if ([key isEqual:@"Message"] && [anObject length] == 0) {
        return nil;
    }
    return anObject;
}

-(id)xmlTranslater:(CWXMLTranslator*)translater willTranslateValueOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;
{
	if (aClass == [NSDate class]) {
        return [NSDate dateWithISODateString:aString];
    } else if ([key isEqualToString:@"name"]) {
        if ([aString hasPrefix:@"From user defined"]) {
            // Point from server do not contain the coordinate, resuse current location point.
            return [FOPoint currentLocationPoint].title;
        }
        return [aString capitalizedString];
    } else if (sharedModel.translateTexts && ([key isEqualToString:@"header"] || [key isEqualToString:@"shortText"])) {
		return CWTranslatedString(aString, @"sv");
    }
    return nil;
}

@end
