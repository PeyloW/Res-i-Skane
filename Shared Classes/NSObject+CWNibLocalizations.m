//
//  NSObject+CWNibLocalizations.m
//  SharedComponents
//
//  Copyright 2010 Jayway. All rights reserved.
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

#import "NSObject+CWNibLocalizations.h"

@implementation NSObject (CWNIBLocalizations)

-(NSString*)localizedValue:(NSString*)value;
{
    if ([value hasPrefix:@"@"]) {
    	value = NSLocalizedString([value substringFromIndex:1], nil);
    } else if ([value hasPrefix:@"\\@"]) {
        value = [value substringFromIndex:1];
    }
    return value;
}

-(void)localizeValueForKey:(NSString*)key;
{
	NSString* oldValue = [self valueForKey:key];
    NSString* newValue = [self localizedValue:oldValue];
    if (oldValue != newValue) {
	    [self setValue:newValue forKey:key];
    }
}

-(void)localizeButton;
{
    UIButton* button = (id)self;
	for (int state = 0; state < 8; state++) {
		NSString* oldTitle = [button titleForState:state];
        if (oldTitle != nil) {
            NSString* newTitle = [self localizedValue:oldTitle];
            if (oldTitle != newTitle) {
                [button setTitle:newTitle forState:state];
            }
        }
    }
}

-(void)localizeSegmentedControl;
{
    UISegmentedControl* segment = (id)self;
    int itemCount = [segment numberOfSegments];
    for (int index = 0; index < itemCount; index++) {
        NSString* oldTitle = [segment titleForSegmentAtIndex:index];
        if (oldTitle != nil) {
            NSString* newTitle = [self localizedValue:oldTitle];
            if (oldTitle != newTitle) {
                [segment setTitle:newTitle forSegmentAtIndex:index];
            }
        }
    }
}

-(void)awakeFromNib;
{
	if ([self respondsToSelector:@selector(text)]) {
        [self localizeValueForKey:@"text"];
    } else if ([self respondsToSelector:@selector(title)]) {
        [self localizeValueForKey:@"title"];
    } else if ([self isKindOfClass:[UIButton class]]) {
    	[self localizeButton];
    } else if ([self isKindOfClass:[UISegmentedControl class]]) {
    	[self localizeSegmentedControl];
    }
    if ([self respondsToSelector:@selector(placeholder)]) {
        [self localizeValueForKey:@"placeholder"];
    }
}

@end
