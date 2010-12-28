//
//  CWPart.h
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

@class FOJourney;

@interface FOPart : NSObject <NSCoding> {
@private 
    FOPoint* _from;
    FOPoint* _to;
    FOLine* _line;
    NSMutableArray* _coordinates;
}

@property(nonatomic, readonly, retain) FOPoint* from;
@property(nonatomic, readonly, retain) FOPoint* to;
@property(nonatomic, readonly, retain) FOLine* line;
@property(nonatomic, readonly, retain) NSArray* coordinates;


+(NSArray*)partsWithJourney:(FOJourney*)journey;

@end
