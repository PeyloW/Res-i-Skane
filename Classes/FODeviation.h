//
//  CWDeviation.h
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


/*!
 * @abstract A deviation of a journey.
 *
 * @discussion Time deviations are not represenated as deviation but hanled seperately.
 *             All deviation information is proveded in Swedish fromt he server, Google translate can optionally be used
 *             to transle text when fetched from server. This means that text is not transled if the user switches
 *             languages with cached searched.
 */
@interface FODeviation : NSObject <NSCoding> {
@private
  NSString* _header;
  NSString* _shortText;
  NSURL* _URL;
}

@property(nonatomic, readonly, retain) NSString* header;    //! A short human readble header text.
@property(nonatomic, readonly, retain) NSString* shortText; //! A short and descriptive text about the deviation.
@property(nonatomic, readonly, retain) NSURL* URL;          //! An URL for more information about the deviation.


@end
