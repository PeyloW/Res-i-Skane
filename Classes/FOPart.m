//
//  CWPart.m
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


#import "FOPart.h"
#import "CWXMLTranslator.h"
#import "FOModel.h"
#import "FOLocationConversions.h"
#import "CWTranslatedString.h"
#import <objc/runtime.h>


@interface FOPartParser : NSObject <CWXMLTranslatorDelegate> {
@private
    NSURL* url;
    FOModel* sharedModel;
}

-(id)initWithJourney:(FOJourney*)journey;

-(NSArray*)parseParts;

@end



@implementation FOPart

@synthesize from = _from;
@synthesize to = _to;
@synthesize line = _line;
@synthesize coordinates = _coordinates;

static int lastX;

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWPart", 0);
	objc_registerClassPair(cls);
}


-(void)setX:(int)x;
{
    lastX = x;
}

-(void)setY:(int)y;
{
    CLLocationCoordinate2D rt90coordinate = (CLLocationCoordinate2D){lastX, y};
    CLLocationCoordinate2D coordinate = FOLocationConvertSystem(rt90coordinate, FOLocationCoordinateSystemRT90, FOLocationCoordinateSystemWGS84,
                                                         FOLocationCoordinateSystemParamRT90_2_5_gon_v);
    if (_coordinates == nil) {
        _coordinates = [[NSMutableArray alloc] init];
    }
    [_coordinates addObject:[[[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude] autorelease]];
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [self init];
    if (self) {
        _from = [[aDecoder decodeObjectForKey:@"From"] retain];
        _to = [[aDecoder decodeObjectForKey:@"To"] retain];
        _line = [[aDecoder decodeObjectForKey:@"Line"] retain];
        _coordinates = [[aDecoder decodeObjectForKey:@"Coords"] retain];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeObject:_from forKey:@"From"];
    [aCoder encodeObject:_to forKey:@"To"];
    [aCoder encodeObject:_line forKey:@"Line"];
    [aCoder encodeObject:_coordinates forKey:@"Coords"];
}

-(void)dealloc;
{
    [_from release];
    [_to release];
    [_line release];
    [_coordinates release];
    [super dealloc];
}

+(NSArray*)partsWithJourney:(FOJourney*)journey;
{
    FOPartParser* parser = [[FOPartParser alloc] initWithJourney:journey];
    NSArray* parts = [parser parseParts];
    NSLog(@"%@", [parts description]);
    [parser release];
    return parts;
}

-(NSString*)description;
{
    return [NSString stringWithFormat:@"<CWPart: %@ %@ %@", self.from, self.to, self.line];
}


@end




@implementation FOPartParser


+(NSURL*)queryURLForJourney:(FOJourney*)journey;
{
    static NSString* queryFormat = @"journeypath.asp?cf=%@&id=%d";
    NSString* query = [NSString stringWithFormat:queryFormat, journey.journeyKey, journey.sequenceNo];
    query = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerURL"] stringByAppendingString:query];
    NSURL* url = [NSURL URLWithString:query];
    NSLog(@"%@", url);
    return url;
}


-(id)initWithJourney:(FOJourney*)journey;
{
    self = [self init];
    if (self) {
        sharedModel = [FOModel sharedModel];
        url = [[FOPartParser queryURLForJourney:journey] retain];
    }
    return self;
}

-(void)dealloc;
{
    [url release];
    [super dealloc];
}

-(NSArray*)parseParts;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDate* delayDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
    NSDictionary* translation = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FOPartParser" ofType:@"plist"]];
	CWXMLTranslator* translater = [[CWXMLTranslator alloc] initWithTranslationPropertyList:translation delegate:self];
	NSError* error = nil;
    NSArray* xmlData = [translater translateContentsOfURL:url error:&error];
    NSString* errorMessage = NSLocalizedString(@"FailedNetworkMessage", nil);
    if ([xmlData count] > 0 && ![[xmlData objectAtIndex:0] hasPrefix:@"<Part>"]) {
		errorMessage = [xmlData objectAtIndex:0];
        if (sharedModel.translateTexts) {
            errorMessage = CWTranslatedString(errorMessage, @"sv");
        }
        xmlData = nil;
    }
    if (xmlData != nil) {
        NSString* xmlString = [NSString stringWithFormat:@"<parts>%@</parts>", [xmlData objectAtIndex:0]];
        NSArray* parts = [translater translateContentsOfData:[xmlString dataUsingEncoding:NSUTF8StringEncoding] error:&error];
        NSString* errorMessage = NSLocalizedString(@"FailedNetworkMessage", nil);
        if ([parts count] > 0 && [[parts objectAtIndex:0] isKindOfClass:[NSString class]]) {
            errorMessage = [parts objectAtIndex:0];
            if (sharedModel.translateTexts) {
                errorMessage = CWTranslatedString(errorMessage, @"sv");
            }
            parts = nil;
        }
        if (parts == nil) {
            NSLog(@"Error: %@", [error description]);
            NSLog(@"URL: %@", [url description]);
            //NSLog(@"XML: %@", [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL]);
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FailedNetwork", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            [alert release];
            parts = nil;
        } else {
            [NSThread sleepUntilDate:delayDate];
        }

        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        return parts;
    } else {
        NSLog(@"Error: %@", [error description]);
        NSLog(@"URL: %@", [url description]);
        //NSLog(@"XML: %@", [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL]);
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"FailedNetwork", nil) message:errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
	return nil;
}


-(id)xmlTranslater:(CWXMLTranslator*)translater didTranslateObject:(id)anObject forKey:(NSString*)key;
{
    if ([anObject isKindOfClass:[FOPoint class]]) {
        NSMutableArray* knownPoints = [FOModel sharedModel].knownPoints;
        NSUInteger index = [knownPoints indexOfObject:anObject];
        if (index != NSNotFound) {
            FOPoint* oldObject = [knownPoints objectAtIndex:index];
            [oldObject performSelector:@selector(mergeWithNewPoint:) withObject:anObject];
            return oldObject;
        }
    }
    return anObject;
}

-(id)xmlTranslater:(CWXMLTranslator*)translater willTranslateValueOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;
{
	if ([key isEqualToString:@"type"]) {
        FOPointType type;
        if ([aString isEqualToString:@"STOP_AREA"]) {
            type = FOPointTypeStopArea;
        } else if ([aString isEqualToString:@"ADDRESS"]) {
            type = FOPointTypeAddress;
        } else if ([aString isEqualToString:@"POI"]) {
            type = FOPointTypePointOfInterest;
        }
        return [NSNumber numberWithInt:(int)type];
    } else if ([key isEqualToString:@"name"]) {
        return [aString capitalizedString];
    }
    return nil;
}


@end



