//
//  CWJourney.h
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
#import "FOPart.h"

@class FOPoint;

/*!
 * @abstract Target time for journey searches.
 */
typedef enum {
    FOJourneyDirectionDeparture = 0,  //! Match eparture time.
    FOJourneyDirectionArrival = 1     //! Match arrival time.
} FOJourneyDirection;

/*!
 * @abstract One suggestion for a searched journey.
 */
@interface FOJourney : NSObject <NSCoding> {
@private
    NSMutableArray* _routeLinks;
    NSString* _journeyKey;
    NSInteger _sequenceNo;
    NSArray* _parts;
}

@property(nonatomic, readonly, retain) NSDate* departure;           //! Departure of first route link.
@property(nonatomic, readonly, retain) NSDate* arrival;             //! Arrival of first route link.
@property(nonatomic, readonly, retain) NSDate* actualDeparture;       //! Actual departure time.
@property(nonatomic, readonly, retain) NSDate* actualArrival;         //! Actual arrival time.
@property(nonatomic, readonly, retain) FOPoint* from;               //! First point to travel from.
@property(nonatomic, readonly, retain) FOPoint* to;                 //! Last point to travel to.
@property(nonatomic, readonly, assign) NSUInteger numberOfChanges;  //! Number of changes, one route link is 0 changes.
@property(nonatomic, readonly, retain) NSArray* routeLinks;         //! An array of one or more route links.
@property(nonatomic, readonly, copy) NSString* journeyKey;
@property(nonatomic, readonly, assign) NSInteger sequenceNo;
@property(nonatomic, readonly, retain) NSArray* parts;


/*!
 * @abstract Query if any of the route links has any kind of deviation.
 */
-(BOOL)isDeviated;

-(BOOL)canFetchParts;

/*!
 * @abstract Fetch an array of journeys mathching a search.
 *
 * @discussion Requery swapping to and from for return journeys.
 */
+(NSArray*)journeysFrom:(FOPoint*)from to:(FOPoint*)to at:(NSDate*)time inDirection:(FOJourneyDirection)direction;

/*!
 * @abstract Fetch an array of journey with departure time before a previosly fetched journey.
 */
+(NSArray*)journeysBefore:(FOJourney*)journey;

/*!
 * @abstract Fetch an array of journey with departure time after a previosly fetched journey.
 */
+(NSArray*)journeysAfter:(FOJourney*)journey;

@end
