//
//  CWDeviation.m
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

#import "FODeviation.h"
#import <objc/runtime.h>


@implementation FODeviation

@synthesize header = _header;
@synthesize shortText = _shortText;
@synthesize URL = _URL;

/*
 * Create a subclass with old name for backward compatibility.
 */
+(void)load;
{
	Class cls = objc_allocateClassPair(self, "CWDeviation", 0);
	objc_registerClassPair(cls);
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
  self = [self init];
  if (self) {
    _header = [[aDecoder decodeObjectForKey:@"header"] retain];
    _shortText = [[aDecoder decodeObjectForKey:@"shortText"] retain];
    _URL = [[aDecoder decodeObjectForKey:@"URL"] retain];
  }
  return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder;
{
  [aCoder encodeObject:self.header forKey:@"header"];
  [aCoder encodeObject:self.shortText forKey:@"shortText"];
  [aCoder encodeObject:self.URL forKey:@"URL"];
}

-(void)dealloc;
{
  [_header release];
  [_shortText release];
  [_URL release];
  [super dealloc];
}

-(BOOL)isEqual:(id)anObject;
{
  if (self == anObject) {
    return YES;
  } else if ([anObject isKindOfClass:[FODeviation class]]) {
    FODeviation* otherDeviation = anObject;
    return ([self.header isEqualToString:otherDeviation.header] &&
            (self.URL == otherDeviation.URL || [self.URL isEqual:otherDeviation.URL]));
  }
  return NO;
}

-(NSString*)description;
{
  return [NSString stringWithFormat:@"<CWDeviation: '%@', '%@', %@", self.header, self.shortText, self.URL];
}

@end
