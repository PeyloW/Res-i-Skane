//
//  CWPoint.m
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

#import "FOPoint.h"
#import "CWXMLTranslator.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "NSString+CWLocalizedFormats.h"
#import "FOLocationConversions.h"
#import "FOModel.h"
#import <objc/runtime.h>

NSString *const FOPointStatusDidChangeNotification = @"FOPointStatusChangesNotification";

@interface FOGoogleMapsPlacemark: NSObject {
@private NSString* coordinates;
}

@property(nonatomic, copy) NSString* coordinates;
@property(nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

@end


@interface FOPointParser : NSObject <CWXMLTranslatorDelegate> {
@private
    NSURL* url;
}

-(id)initWithSearchString:(NSString*)searchString;

-(NSArray*)parsePoints;

@end

@interface FOPoint () <CLLocationManagerDelegate, MKReverseGeocoderDelegate>

@end


@implementation FOPoint

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWPoint", 0);
	objc_registerClassPair(cls);
}

@synthesize ID = _ID;
@synthesize title = _name;
@synthesize stopPoint = _stopPoint;
@synthesize type = _type;
@synthesize coordinateSource = coordinateSource;

-(NSString*)typeString;
{
    switch (self.type) {
        case FOPointTypeStopArea:
            return @"STOP_AREA";
        case FOPointTypeAddress:
            return @"ADDRESS";
        case FOPointTypePointOfInterest:
            return @"POI";
        default:
            return @"_unknown_";
    }
}

// NOTE: Journey queries must report ADDRESS and POI as same type, for some stupid reason.
static int CWQueryTypeForPointType(FOPointType type) {
    if (type == 0) {
        return 0;
    } else {
        return 1;
    }
}

static CLLocation* lastLocation = nil;
static BOOL failedLocation = NO;
static CLLocationManager* locationManager = nil;
static BOOL isUpdatingLocation = NO;

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if ([error code] != kCLErrorLocationUnknown) {
		failedLocation = YES;
        if ([error code] != kCLErrorDenied) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LocationError", nil)
                                                            message:NSLocalizedString(@"LocationErrorMessage", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        [manager stopUpdatingLocation];
        [[NSNotificationCenter defaultCenter] postNotificationName:FOPointStatusDidChangeNotification object:[FOPoint currentLocationPoint]];
    }
}

static MKReverseGeocoder* geocoder = nil;

- (void)reverseGeocoder:(MKReverseGeocoder *)aGeocoder didFailWithError:(NSError *)error;
{
	[[NSNotificationCenter defaultCenter] postNotificationName:FOPointStatusDidChangeNotification object:[FOPoint currentLocationPoint]];
    [aGeocoder release];
    geocoder = nil;
}

- (void)reverseGeocoder:(MKReverseGeocoder *)aGeocoder didFindPlacemark:(MKPlacemark *)placemark;
{
    NSString* name = placemark.thoroughfare;
    if (placemark.subThoroughfare != nil) {
        name = [name stringByAppendingFormat:@" %@", placemark.subThoroughfare];
    }
    if (placemark.locality != nil) {
        name = [name stringByAppendingFormat:@", %@", placemark.locality];
    }
    if (![placemark.countryCode isEqualToString:@"SE"]) {
        name = [name stringByAppendingFormat:@", %@", placemark.country];
    }
	[[FOPoint currentLocationPoint] setValue:name forKey:@"name"];
	[[NSNotificationCenter defaultCenter] postNotificationName:FOPointStatusDidChangeNotification object:[FOPoint currentLocationPoint]];
    [aGeocoder release];
    geocoder = nil;
}

-(void)cancelLocationUpdates;
{
    [locationManager stopUpdatingLocation];
    isUpdatingLocation = NO;
	[[NSNotificationCenter defaultCenter] postNotificationName:FOPointStatusDidChangeNotification object:[FOPoint currentLocationPoint]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
{
    [[NSRunLoop currentRunLoop] cancelPerformSelector:@selector(cancelLocationUpdates) target:self argument:nil];
	[lastLocation release];
    lastLocation = [newLocation retain];
    CLLocationAccuracy accuracy = MAX(lastLocation.horizontalAccuracy, lastLocation.verticalAccuracy);
    if (accuracy < FOPointAccuracyThreshold) {
        [manager stopUpdatingLocation];
        isUpdatingLocation = NO;
    } else {
		[self performSelector:@selector(cancelLocationUpdates) withObject:nil afterDelay:FOPointMaxTimeToWaitForLocation];
    }
    if (geocoder != nil) {
        [geocoder cancel];
        [geocoder release];
    }
    geocoder = [[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
    geocoder.delegate = self;
    [geocoder start];
}

-(void)didSelectPoint;
{
	if (self.ID == CWPointCurrentLocationID) {
        failedLocation = NO;
        isUpdatingLocation = YES;
        [locationManager startUpdatingLocation];
    }
}

-(NSString*)queryString;
{
    if (self.ID == CWPointCurrentLocationID) {
        CLLocationCoordinate2D lastCoordinate = lastLocation.coordinate;
        //coordinate.latitude = 55.612150;
        //coordinate.longitude = 12.995901;
        return [NSString stringWithFormat:@"%%7C%f%%3A%f%%7C3", lastCoordinate.latitude, lastCoordinate.longitude];
    } else {
        return [NSString stringWithFormat:@"%%7C%d%%7C%d", self.ID, CWQueryTypeForPointType(self.type)];
    }
}

-(CLLocation*)location;
{
	if (self.ID == CWPointCurrentLocationID) {
		return lastLocation;
    } else {
        return nil;
    }
}

-(CLLocationAccuracy)locationAccuracy;
{
	if (lastLocation != nil) {
        return MAX(lastLocation.horizontalAccuracy, lastLocation.verticalAccuracy);
    } else {
        return 10000;
    }
}


-(CLLocationCoordinate2D)coordinate;
{
    if (coordinateSource == FOPointCoordinateSourceNone) {
        if (self.ID == CWPointCurrentLocationID) {
            coordinate = self.location.coordinate;
            coordinateSource = FOPointCoordinateSourceCoreLocation;
        } else if (self.ID < CWPointCurrentLocationID) {
            coordinate = [FOPoint currentLocationPoint].coordinate;
            coordinateSource = FOPointCoordinateSourceCoreLocation;
        } else if (x != 0 && y != 0) {
            CLLocationCoordinate2D rt90coordinate = (CLLocationCoordinate2D){x, y};
            coordinate = FOLocationConvertSystem(rt90coordinate, FOLocationCoordinateSystemRT90, FOLocationCoordinateSystemWGS84,
                                          FOLocationCoordinateSystemParamRT90_2_5_gon_v);
            coordinateSource = FOPointCoordinateSourceOfficialServer;
        } else {
            NSArray* points = [FOPoint pointsMatchingString:self.title];
            for (FOPoint* point in points) {
                if (_ID == point->_ID /*&& [_name isEqualToString:point->_name]*/) {
                    if (point->x != 0 && point->y != 0) {
                        coordinate = point.coordinate;
						coordinateSource = FOPointCoordinateSourceOfficialServer;
                    }
                    break;
                }
            }
            if (coordinateSource != FOPointCoordinateSourceOfficialServer) {
                coordinateSource = FOPointCoordinateSourceNone;
            }
        }
    }
    return coordinate;
}

-(BOOL)isReady;
{
	return self.pointStatus <= FOPointStatusInitial;
}

-(FOPointStatus)pointStatus;
{
	if (self.ID == CWPointCurrentLocationID) {
		if (failedLocation) {
            return FOPointStatusError;
        } else {
			return lastLocation == nil ? FOPointStatusPending : (isUpdatingLocation ? FOPointStatusInitial : FOPointStatusKnown);
        }
    } else {
        return FOPointStatusStatic;
    }
}

-(void)mergeWithNewPoint:(FOPoint*)point;
{
    x = point->x;
    y = point->y;
    if (coordinate.latitude == 0 && coordinate.longitude == 0) {
        coordinate = point->coordinate;
    }
}

+(FOPoint*)pointWithID:(NSUInteger)pointId name:(NSString*)name type:(FOPointType)type;
{
	FOPoint* point = [[FOPoint alloc] init];
    if (point) {
		point->_ID = pointId;
        point->_name = [name retain];
        point->_type = type;
        if (pointId == CWPointCurrentLocationID) {
            locationManager = [[CLLocationManager alloc] init];
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            locationManager.delegate = point;
        }
    }
    return [point autorelease];
}

+(FOPoint*)currentLocationPoint;
{
	static FOPoint* currentLocationPoint = nil;
    if (currentLocationPoint == nil) {
		currentLocationPoint = [[FOPoint pointWithID:CWPointCurrentLocationID
                                                name:NSLocalizedString(@"CurrentLocation", nil)
                                                type:FOPointTypeGPSCoordinte] retain];
    }
    return currentLocationPoint;
}

+(NSMutableArray*)defaultKnownPoints;
{
    NSMutableArray* points = [NSMutableArray array];
	[points addObject:[FOPoint pointWithID:80000 name:@"Malmö C" type:FOPointTypeStopArea]];
	[points addObject:[FOPoint pointWithID:80120 name:@"Södervärn Malmö" type:FOPointTypeStopArea]];
	[points addObject:[FOPoint pointWithID:81216 name:@"Lund C" type:FOPointTypeStopArea]];
	[points addObject:[FOPoint pointWithID:83241 name:@"Helsingborg C" type:FOPointTypeStopArea]];
	[points addObject:[FOPoint pointWithID:85131 name:@"Eslövs Station" type:FOPointTypeStopArea]];
    return points;
}

+(NSMutableArray*)defaultJourneySearchBookmarks;
{
    return [NSMutableArray array];
}

+(NSArray*)pointsMatchingString:(NSString*)searchString;
{
    FOPointParser* pointParser = [[FOPointParser alloc] initWithSearchString:searchString];
    NSArray* points = [pointParser parsePoints];
    NSLog(@"Points: %@", [points description]);
	[pointParser release];
    return points;
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
    NSUInteger pointId = [aDecoder decodeIntegerForKey:@"ID"];
 	if (pointId == CWPointCurrentLocationID) {
		[self release];
        return [FOPoint currentLocationPoint];
    } else {
        self = [self init];
        if (self) {
            _ID = pointId;
            _name = [[aDecoder decodeObjectForKey:@"name"] retain];
            _stopPoint = [[aDecoder decodeObjectForKey:@"stopPoint"] retain];
            _type = [aDecoder decodeIntegerForKey:@"type"];
            x = [aDecoder decodeInt32ForKey:@"x"];
            y = [aDecoder decodeInt32ForKey:@"y"];
            coordinate.latitude = [aDecoder decodeDoubleForKey:@"la"];
            coordinate.longitude = [aDecoder decodeDoubleForKey:@"lo"];
            coordinateSource = [aDecoder decodeIntegerForKey:@"coordinateSource"];
        }
        return self;
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
    [aCoder encodeInteger:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.title forKey:@"name"];
    [aCoder encodeObject:self.stopPoint forKey:@"stopPoint"];
    [aCoder encodeInteger:self.type forKey:@"type"];
    [aCoder encodeInt32:x forKey:@"x"];
    [aCoder encodeInt32:y forKey:@"y"];
    if (coordinateSource != FOPointCoordinateSourceGoogleMaps) {
        [aCoder encodeInteger:coordinateSource forKey:@"coordinateSource"];
        if (coordinate.latitude != 0 && coordinate.longitude != 0) {
            [aCoder encodeDouble:coordinate.latitude forKey:@"la"];
            [aCoder encodeDouble:coordinate.longitude forKey:@"lo"];
        }
    }
}

-(void)dealloc;
{
    [_name release];
    [super dealloc];
}

-(UIImage*)imageForType;
{
    if (self.ID == CWPointCurrentLocationID) {
 		return [UIImage imageNamed:@"point-current.png"];
    } else {
        return [UIImage imageNamed:[NSString stringWithFormat:@"point-%d.png", self.type]];
    }
}

-(UITableViewCellAccessoryType)accessoryType;
{
    return UITableViewCellAccessoryNone;
    //	return self.type == FOPointTypeStopArea ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone;
}

-(BOOL)isEqual:(id)anObject;
{
    if (self == anObject) {
        return YES;
    } else if ([anObject isKindOfClass:[FOPoint class]]) {
        FOPoint* otherPoint = anObject;
        // It is safe to ignore types, as they use different ID ranges anyway.
        return self.ID == otherPoint.ID;
    }
    return NO;
}

-(NSString*)description;
{
    return [NSString stringWithFormat:@"<CWPoint: %d, '%@', %@>", self.ID, self.title, self.typeString];
}

@end

@implementation FOPointParser

+(NSURL*)queryURLForSearchString:(NSString*)searchString;
{
    NSString* escapedSearchString = [searchString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString* query = [NSString stringWithFormat:@"querypage.asp?inpPointTo=zq&inpPointFr=%@", escapedSearchString];
    query = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"ServerURL"] stringByAppendingString:query];
    return [NSURL URLWithString:query];
}

-(id)initWithSearchString:(NSString*)searchString;
{
    self = [super init];
    if (self) {
        url = [[FOPointParser queryURLForSearchString:searchString] retain];
    }
    return self;
}

-(void)dealloc;
{
    [url release];
    [super dealloc];
}

-(NSArray*)parsePoints;
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    NSDictionary* translation = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FOPointParser" ofType:@"plist"]];
	CWXMLTranslator* translater = [[CWXMLTranslator alloc] initWithTranslationPropertyList:translation delegate:self];
	NSError* error = nil;
    NSArray* points = [translater translateContentsOfURL:url error:&error];
    if (points == nil) {
        NSLog(@"Error: %@", [error description]);
        NSLog(@"URL: %@", [url description]);
        NSLog(@"XML: %@", [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:NULL]);
        // Intentionally not an error, because this happens too often!
    }
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	return points;
}

-(id)xmlTranslator:(CWXMLTranslator *)translator didTranslateObject:(id)anObject forKey:(NSString*)key;
{
    if ([anObject isKindOfClass:[FOPoint class]]) {
        NSMutableArray* knownPoints = [FOModel sharedModel].knownPoints;
        NSUInteger index = [knownPoints indexOfObject:anObject];
        if (index != NSNotFound) {
            FOPoint* oldObject = [knownPoints objectAtIndex:index];
            [oldObject mergeWithNewPoint:anObject];
            return oldObject;
        }
    }
    return anObject;
}

-(id)xmlTranslator:(CWXMLTranslator *)translator primitiveObjectInstanceOfClass:(Class)aClass withString:(NSString*)aString forKey:(NSString*)key;
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



@implementation FOGoogleMapsPlacemark

@synthesize coordinates;

-(CLLocationCoordinate2D)coordinate;
{
	NSArray* array = [coordinates componentsSeparatedByString:@","];
    CLLocationCoordinate2D coordinate;
    coordinate.longitude = [[array objectAtIndex:0] doubleValue];
	coordinate.latitude = [[array objectAtIndex:1] doubleValue];
    return coordinate;
}

-(void)dealloc;
{
	[coordinates release];
    [super dealloc];
}

@end
