//
//  CWLine.h
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
#import "FOPoint.h"

/*!
 * @abstract A line is the type of transportation used for a part of a journey.
 *
 * @discussion Different lines will be created for different sub parts of the same journey. For example from Triangeln
 *             to Malmö C, is a different line than Södervärn to C, even if they are both run by citybuss 8.
 */
@interface FOLine : NSObject <NSCoding> {
@private
    NSString* _name;
    NSString* _number;
    NSDate* _departure;
    NSString* _stopPoint;
    NSString* _typeName;
//    NSString* _typeId;
    NSString* _towards;
    NSInteger _departureDeviation;
    NSMutableArray* _deviations;
}

@property(nonatomic, readonly, retain) NSString* name;      //! Human readbale name of the line.
@property(nonatomic, readonly, retain) NSString* number;    //! Line number or nil.
@property(nonatomic, readonly, retain) NSDate* departure;   //! Journey departure data time.
@property(nonatomic, readonly, retain) NSDate* actualDeparture;       //! Actual departure time.
@property(nonatomic, readonly, retain) NSDate* deviatedDeparture;     //! Deviated departure time, or nil if no deviation from planned time.
@property(nonatomic, readonly, retain) NSString* stopPoint;     //! Stop point, eg. 'E' or '2' for a point, only used for search results.
@property(nonatomic, readonly, retain) NSString* fullName;  //! Human readable full name.
@property(nonatomic, readonly, retain) NSString* typeName;  //! Human readable type of line.
@property(nonatomic, readonly, retain) NSString* towards;   //! Human readable description of the direction to choose when entering the transportation.
@property(nonatomic, readonly, retain) NSArray* deviations;           //! An array of deviations, may be nil.
@property(nonatomic, readonly, retain) NSString* deviationsAsString;  //! All deviations including time deviations as line-break separated human readable string.
@property(nonatomic, readonly, retain) UIColor* color;

/*!
 * @abstract Fetch an array for lines with departures from a point at a given time.
 */
+(NSArray*)linesFromPoint:(FOPoint*)point at:(NSDate*)time;

/*!
 * @abstract Query if route link has any kind of deviations.
 */
-(BOOL)isDeviated;

/*!
 * @abstract Query if line is some kind of train.
 */
-(BOOL)isTrain;

-(BOOL)isBus;

-(UIImage*)typeImage;

@end
