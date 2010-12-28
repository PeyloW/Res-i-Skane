//
//  CWRouteLink.h
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

@class FOPoint, FOLine;


/*!
 * @abstract One transportation part of a journey.
 *
 * @discussion A journey consists of one or more route links, changes are required between route links.
 *             Each route link has a from and to point, a line specifying the transportation type.
 *             A route link can have an infinite number of deviations.
 */
@interface FORouteLink : NSObject <NSCoding> {
@private
    NSDate* _departure;
    NSDate* _arrival;
    NSInteger _departureDeviation;
    NSInteger _arrivalDeviation;
    FOPoint* _from;
    FOPoint* _to;
    FOLine* _line;
    NSMutableArray* _deviations;
}

@property(nonatomic, readonly, retain) NSDate* departure;             //! Planned departure time.
@property(nonatomic, readonly, retain) NSDate* arrival;               //! Planned arrival time.
@property(nonatomic, readonly, retain) NSDate* actualDeparture;       //! Actual departure time.
@property(nonatomic, readonly, retain) NSDate* actualArrival;         //! Actual arrival time.
@property(nonatomic, readonly, retain) NSDate* deviatedDeparture;     //! Deviated departure time, or nil if no deviation from planned time.
@property(nonatomic, readonly, retain) NSDate* deviatedArrival;       //! Deviated rrival time, or nil if no deviation from planned time.
@property(nonatomic, readonly, retain) FOPoint* from;                 //! The point to travel from.
@property(nonatomic, readonly, retain) FOPoint* to;                   //! The point to travel to.
@property(nonatomic, readonly, retain) FOLine* line;                  //! The line type and information.
@property(nonatomic, readonly, retain) NSArray* deviations;           //! An array of deviations, may be nil.
@property(nonatomic, readonly, retain) NSString* deviationsAsString;  //! All deviations including time deviations as line-break separated human readable string.

/*!
 * @abstract Query if route link has any kind of deviations.
 */
-(BOOL)isDeviated;

@end
