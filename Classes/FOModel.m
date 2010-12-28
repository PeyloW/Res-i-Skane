//
//  CWMOdel.m
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

#import "FOModel.h"
#import "NSDate+CWExtentions.h"
#import "CWNetworkChecker.h"
#import <objc/runtime.h>

@implementation FOModel

@synthesize knownPoints = _knownPoints;
@synthesize bookmarkedJourneys = _bookmarkedJourneys;
@synthesize date = _date;
@synthesize direction = _direction;
@synthesize from = _from;
@synthesize to = _to;
@synthesize currentJourneyList = _currentJourneyList;
@synthesize currentLineList = _currentLineList;
@synthesize translateTexts = _translateTexts;
@synthesize lineTypeFilter = _lineTypeFilter;

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWModel", 0);
	objc_registerClassPair(cls);
}

static FOModel* sharedModel = nil;

-(void)setFrom:(FOPoint*)point;
{
	if (_from != point) {
		[_from autorelease];
        _from = [point retain];
        [point didSelectPoint];
    }
}

-(void)setTo:(FOPoint*)point;
{
	if (_to != point) {
		[_to autorelease];
        _to = [point retain];
        [point didSelectPoint];
    }
}

-(NSArray*)currentBookmark;
{
	if (_from != nil && _to != nil) {
		return [NSArray arrayWithObjects:_from, _to, nil];
    } else {
        return nil;
    }
}

+(NSString*)typeTranslationFileName;
{
	NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:@"types.dat"];
}


+(NSString*)sharedModelFileName;
{
	NSString* path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    return [path stringByAppendingPathComponent:@"model.dat"];
}

+(FOModel*)sharedModel;
{
	if (sharedModel == nil) {
        sharedModel = [[NSKeyedUnarchiver unarchiveObjectWithFile:[self sharedModelFileName]] retain];
        if (sharedModel == nil) {
            sharedModel = [[FOModel alloc] init];
            [sharedModel.knownPoints addObjectsFromArray:[FOPoint defaultKnownPoints]];
        } else {
            // Convert old NSSet bookmarks to arrays.
            for (int index = 0; index < [sharedModel.bookmarkedJourneys count]; index++) {
                id bookmark = [sharedModel.bookmarkedJourneys objectAtIndex:index];
                if ([bookmark isKindOfClass:[NSSet class]]) {
                    NSArray* points = [bookmark allObjects];
                    points = [points sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES] autorelease]]];
                    [sharedModel.bookmarkedJourneys replaceObjectAtIndex:index withObject:points];
                }
            }
            // Remove illegal bookmarks.
            [sharedModel.bookmarkedJourneys removeObject:sharedModel];
        }
        if ([[sharedModel.knownPoints objectAtIndex:0] ID] != CWPointCurrentLocationID) {
            [sharedModel.knownPoints insertObject:[FOPoint currentLocationPoint] atIndex:0];
        }
        sharedModel->typeTranslations = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"resiskane_type" ofType:@"plist"]];
    }
    return sharedModel;
}

-(BOOL)persistToStorage;
{
	return [NSKeyedArchiver archiveRootObject:self toFile:[FOModel sharedModelFileName]];
}

-(int)typeIdForTypeName:(NSString*)typeName;
{
	return [[typeTranslations objectForKey:typeName] intValue];
}

-(id)init;
{
	self = [super init];
    if (self) {
        self.knownPoints = [NSMutableArray new];
        self.bookmarkedJourneys = [NSMutableArray new];
        self.date = [NSDate relativeDateWithTimeIntervalSinceNow:0];
        self.direction = FOJourneyDirectionDeparture;
    }
    return self;
}

-(void)dealloc;
{
    self.knownPoints = nil;
    self.bookmarkedJourneys = nil;
    self.date = nil;
    self.from = nil;
    self.to = nil;
    [super dealloc];
}

-(void)addJourneys:(NSArray*)journeys;
{
    if (_currentJourneyList == nil) {
		_currentJourneyList = [[NSMutableArray alloc] init];
    }
    if ([journeys count]) {
        if ([_currentJourneyList count] && [[[journeys objectAtIndex:0] departure] timeIntervalSinceReferenceDate] < [[[_currentJourneyList objectAtIndex:0] departure] timeIntervalSinceReferenceDate]) {
            for (id journey in [journeys reverseObjectEnumerator]) {
                [_currentJourneyList insertObject:journey atIndex:0];
            }
        } else {
            [_currentJourneyList addObjectsFromArray:journeys];
        }
    }
}

-(void)clearJourneys;
{
	[_currentJourneyList release];
    _currentJourneyList = nil;
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super init];
    if (self) {
        self.knownPoints= [aDecoder decodeObjectForKey:@"knownPoints"];
        self.bookmarkedJourneys = [aDecoder decodeObjectForKey:@"bookmarkedJourneys"];
        self.date = [aDecoder decodeObjectForKey:@"date"];
        self.direction = [aDecoder decodeIntegerForKey:@"direction"];
        self.from = [aDecoder decodeObjectForKey:@"from"];
        self.to = [aDecoder decodeObjectForKey:@"to"];
        self.currentJourneyList = [aDecoder decodeObjectForKey:@"currentJourneyList"];
        self.currentLineList = [aDecoder decodeObjectForKey:@"currentLineList"];
        self.translateTexts = [aDecoder decodeBoolForKey:@"translateTexts"];
        self.lineTypeFilter = [aDecoder decodeIntegerForKey:@"lineTypeFilter"];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:self.knownPoints forKey:@"knownPoints"];
    [aCoder encodeObject:self.bookmarkedJourneys forKey:@"bookmarkedJourneys"];
    [aCoder encodeObject:self.date forKey:@"date"];
    [aCoder encodeInteger:self.direction forKey:@"direction"];
    [aCoder encodeObject:self.from forKey:@"from"];
    [aCoder encodeObject:self.to forKey:@"to"];
	[aCoder encodeObject:self.currentJourneyList forKey:@"currentJourneyList"];
	[aCoder encodeObject:self.currentLineList forKey:@"currentLineList"];
    [aCoder encodeBool:self.translateTexts forKey:@"translateTexts"];
    [aCoder encodeInteger:self.lineTypeFilter forKey:@"lineTypeFilter"];
}

@end
