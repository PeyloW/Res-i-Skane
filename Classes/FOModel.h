//
//  CWMOdel.h
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
#import "FOLine.h"
#import "FODeviation.h"
#import "FORouteLink.h"
#import "FOJourney.h"


typedef enum {
    FOLineTypeFilterAll = 0,
    FOLineTypeFilterBuses = 1,
    FOLineTypeFilterTraines = 2
} FOLineTypeFilter;

typedef enum {
    FOLineTypeGang = 0,
    FOLineTypeStadsbuss = 1,
    FOLineTypeRegionbuss = 2,
    FOLineTypeSkaneexpress = 4,
    FOLineTypePendeln = 8,
    FOLineTypeOresundstag = 16,
    FOLineTypePagatagen = 32,
    FOLineTypeTagbuss = 64,
    FOLineTypeFarjeforbindelse = 128,
    FOLineTypeFlygbuss = 256,
    FOLineTypeBil = 1024
} FOLineType;

/*!
 * @abstract The application model.
 *
 * @discussion As a singleton object so that it can eaily be archived and uarchived in a single operation.
 */
@interface FOModel : NSObject <NSCoding> {
@private
    NSMutableArray* _knownPoints;
    NSMutableArray* _bookmarkedJourneys;
    NSDate* _date;
    FOJourneyDirection _direction;
    FOPoint* _from;
    FOPoint* _to;
    NSMutableArray* _currentJourneyList;
    NSArray* _currentLineList;
    BOOL _translateTexts;
    FOLineTypeFilter _lineTypeFilter;
    NSDictionary* typeTranslations;
}

@property(nonatomic, retain) NSMutableArray* knownPoints;          //! An array of known points, a point is added as known when selected from a search.
@property(nonatomic, retain) NSMutableArray* bookmarkedJourneys;   //! An array of bookmarked searches, a boomark is a set of two points.
@property(nonatomic, retain) NSDate* date;                         //! The currebtly selected date to search relative to.
@property(nonatomic, assign) FOJourneyDirection direction;         //! The currently selected type of date to search for.
@property(nonatomic, retain) FOPoint* from;                        //! The currebtly selected point to travel from.
@property(nonatomic, retain) FOPoint* to;                          //! The currently selected point to travel to.
@property(nonatomic, readonly, retain) NSArray* currentBookmark;	 //! The current selected points as a bookmark.
@property(nonatomic, retain) NSMutableArray* currentJourneyList;   //! The currently displayed array of journey being displayed for a search, nil of not displaying any results.
@property(nonatomic, retain) NSArray* currentLineList;      //! The currently displayed array of lines.
@property(nonatomic, assign) BOOL translateTexts;                  //! YES if deviations texts should be translated using Google translate, default is NO.
@property(nonatomic, assign) FOLineTypeFilter lineTypeFilter;


/*!
 * @abstract Fetch the shared model, unarchive or create if needed.
 */
+(FOModel*)sharedModel;

/*!
 * @abstract Archive model to storage.
 */
-(BOOL)persistToStorage;

/*!
 * @abstract Add an array of journeys to the current array of search results.
 */
-(void)addJourneys:(NSArray*)journeys;

/*!
 * @abstract Clear the current search result, must be called when closing search result controller.
 */
-(void)clearJourneys;

-(int)typeIdForTypeName:(NSString*)typeName;

@end
