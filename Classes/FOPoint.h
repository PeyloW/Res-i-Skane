//
//  CWPoint.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

/**
 * @abstract Stop location manager when a point with accuracy threshold has been found.
 */
#define FOPointAccuracyThreshold (100)

#define FOPointMaxTimeToWaitForLocation (30)

extern NSString *const FOPointStatusDidChangeNotification;

/*!
 * @abstract Type of point.
 */
typedef enum {
    FOPointTypeStopArea = 0,          //! A buss stop or train station.
    FOPointTypePointOfInterest = 1,   //! A point of interest.
    FOPointTypeAddress = 2,           //! A street address.
    FOPointTypeGPSCoordinte = 3				//! GPS coordinate
} FOPointType;

#define CWPointCurrentLocationID (1)

typedef enum {
	FOPointStatusStatic = 0,
    FOPointStatusKnown = 1,
    FOPointStatusInitial = 2,
    FOPointStatusPending = 3,
    FOPointStatusError = 4
} FOPointStatus;

/*!
 * @abstract Source for map coordinate of point.
 */
typedef enum {
    FOPointCoordinateSourceNone = 0,						//! No map coordinate is present, requires lookup.
    FOPointCoordinateSourceGoogleMaps = 1,			//! Map coordinate is fetched from Google Maps and may be inaccurate.
    FOPointCoordinateSourceOfficialServer = 2,  //! Map coordinate is fetched from official server and should be accurate.
    FOPointCoordinateSourceCoreLocation = 3			//! Coordinate has been fetches using Core Location API.
} FOPointCoordinateSource;


/*!
 * @abstract A start, end or change point for a trip.
 *
 * @discussion A point is identified by it's ID and point type, points of different types could have the same ID.
 *             The name of a point is optional for request to the server.
 */
@interface FOPoint : NSObject <NSCoding, MKAnnotation> {
@private
    NSUInteger _ID;
    NSString* _name;
    NSString* _stopPoint;
    FOPointType _type;
@protected
    CLLocationCoordinate2D coordinate;
    FOPointCoordinateSource coordinateSource;
    int x;
    int y;
}

@property(nonatomic, readonly, assign) NSUInteger ID;           //! Numeric ID of point.
@property(nonatomic, readonly, retain) NSString* title;          //! Human readable name of point.
@property(nonatomic, readonly, retain) NSString* stopPoint;     //! Stop point, eg. 'E' or '2' for a point, only used for search results.
@property(nonatomic, readonly, assign) FOPointType type;        //! The stop type of this point.
@property(nonatomic, readonly, retain) NSString* typeString;    //! Human readable stop type of this point.
@property(nonatomic, readonly, retain) NSString* queryString;   //! String to insert into get query URL when searchig for this point.
@property(nonatomic, readonly, retain) CLLocation* location;    //! Only supported by current localtion for the moment.
@property(nonatomic, readonly, assign) CLLocationAccuracy locationAccuracy; //! Current accuracy of location.
@property(nonatomic, readonly, assign) CLLocationCoordinate2D coordinate; //! Coordinate of location;
@property(nonatomic, readonly, assign) FOPointCoordinateSource coordinateSource; //! Source of map coordinate.

+(FOPoint*)currentLocationPoint;

/*!
 * @abstract An array of default points to add at first start, so the user is not presented with a confusing empty UI.
 */
+(NSMutableArray*)defaultKnownPoints;

/*!
 * @abstract An array of default bookmarks to add at first start, a bookmark a set with two points.
 */
+(NSMutableArray*)defaultJourneySearchBookmarks;

/*!
 * @abstract Fetch an array of points mathcing a string from the server.
 *
 * @discussion You must queue fetches in order to not starve the server. Responses are fast enough for searchingas you type.
 */
+(NSArray*)pointsMatchingString:(NSString*)searchString;

/*!
 * @abstract An image representing the type of point.
 */
-(UIImage*)imageForType;

/*!
 * @abstract An accessory type for this type of view.
 *
 * @discussion Currently unused,, but should be used to return a detail disclosure triangle for points that can have
 *             real-time information.
 */
-(UITableViewCellAccessoryType)accessoryType;

-(BOOL)isReady;

-(FOPointStatus)pointStatus;

-(void)didSelectPoint;

@end
