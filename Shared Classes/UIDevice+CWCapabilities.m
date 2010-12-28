//
//  UIDevice+CWCapabilities.m
//  CWUIKitAdditions
//
//  Copyright 2010 Jayway. All rights reserved.
//  Created by Fredrik Olsson.
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

#import "UIDevice+CWCapabilities.h"

typedef enum {
	CWCapabilityStateUnknown = 0,
    CWCapabilityStateNo = 1,
    CWCapabilityStateYes = 2
} CWCapabilityState;

@implementation UIDevice (CWCapabilities)

+(BOOL)isPhone;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
    	v = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ? CWCapabilityStateYes : CWCapabilityStateNo;
    }
    return v == CWCapabilityStateYes;
}

+(BOOL)isPad;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
    	v = [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad ? CWCapabilityStateYes : CWCapabilityStateNo;
    }
    return v == CWCapabilityStateYes;
}

+(BOOL)isMultitaskingCapable;
{
	static CWCapabilityState v = CWCapabilityStateUnknown;
    if (v == CWCapabilityStateUnknown) {
        v = CWCapabilityStateNo;
        if ([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
    		v = [[UIDevice currentDevice] isMultitaskingSupported] ? CWCapabilityStateYes : CWCapabilityStateNo;
        }
    }
    return v == CWCapabilityStateYes;
}
@end
