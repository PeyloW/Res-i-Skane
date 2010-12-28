//
//  CWRouteLink.m
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

#import "FORouteLink.h"
#import "FODeviation.h"
#import "NSDate+CWExtentions.h"
#import <objc/runtime.h>

@implementation FORouteLink

@synthesize departure = _departure;
@synthesize arrival = _arrival;
@synthesize from = _from;
@synthesize to = _to;
@synthesize line = _line;
@synthesize deviations = _deviations;

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWRouteLink", 0);
	objc_registerClassPair(cls);
}

-(NSDate*)deviatedDeparture;
{
	if (_departureDeviation == 0) {
		return nil;
    } else {
        return [_departure addTimeInterval:_departureDeviation * 60];
    }
}

-(NSDate*)deviatedArrival;
{
	if (_arrivalDeviation == 0) {
		return nil;
    } else {
        return [_arrival addTimeInterval:_arrivalDeviation * 60];
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

-(NSDate*)actualArrival;
{
	if (_arrivalDeviation != 0) {
        return self.deviatedArrival;
    } else {
        return self.arrival;
    }
}

-(NSString*)deviationsAsString;
{
	NSMutableArray* strings = [NSMutableArray array];
    if (![self.departure isEqualToDate:self.actualDeparture]) {
		[strings addObject:[NSString stringWithFormat:NSLocalizedString(@"ActualDeviationTimeDeparture", nil), [self.actualDeparture localizedShortTimeString]]];
    }
    if (![self.arrival isEqualToDate:self.actualArrival]) {
		[strings addObject:[NSString stringWithFormat:NSLocalizedString(@"ActualDeviationTimeArrival", nil), [self.actualArrival localizedShortTimeString]]];
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

-(BOOL)isDeviated;
{
	return _departureDeviation != 0 || _arrivalDeviation != 0 || [self.deviations count];
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [self init];
    if (self) {
        _departure = [[aDecoder decodeObjectForKey:@"departure"] retain];
        _arrival = [[aDecoder decodeObjectForKey:@"arrival"] retain];
        _departureDeviation = [aDecoder decodeIntegerForKey:@"departureDeviation"];
        _arrivalDeviation = [aDecoder decodeIntegerForKey:@"arrivalDeviation"];
        _from = [[aDecoder decodeObjectForKey:@"from"] retain];
        _to = [[aDecoder decodeObjectForKey:@"to"] retain];
        _line = [[aDecoder decodeObjectForKey:@"line"] retain];
        _deviations = [[aDecoder decodeObjectForKey:@"deviations"] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.departure forKey:@"departure"];
    [aCoder encodeObject:self.arrival forKey:@"arrival"];
	[aCoder encodeInteger:_departureDeviation forKey:@"departureDeviation"];
	[aCoder encodeInteger:_arrivalDeviation forKey:@"arrivalDeviation"];
    [aCoder encodeObject:self.from forKey:@"from"];
    [aCoder encodeObject:self.to forKey:@"to"];
    [aCoder encodeObject:self.line forKey:@"line"];
    [aCoder encodeObject:self.deviations forKey:@"deviations"];
}

-(void)dealloc;
{
    [_departure release];
    [_arrival release];
    [_from release];
    [_to release];
    [_line release];
    [_deviations release];
    [super dealloc];
}

-(BOOL)isEqual:(id)anObject;
{
    if (self == anObject) {
        return YES;
    } else if ([anObject isKindOfClass:[FORouteLink class]]) {
        FORouteLink* otherRouteLink = anObject;
        return ([self.arrival isEqualToDate:otherRouteLink.arrival] &&
                [self.departure isEqualToDate:otherRouteLink.departure] &&
                [self.from isEqual:otherRouteLink.from] &&
                [self.to isEqual:otherRouteLink.to] &&
                [self.line isEqual:otherRouteLink.line]);
    }
    return NO;
}

-(NSString*)description;
{
    return [NSString stringWithFormat:@"<CWRouteLink: %@ at %@, %@ at %@, %@, %@", self.from, self.departure, self.to, self.arrival, self.line, self.deviations];
}

@end
