//
//  UIDevice+CWCapabilities.h
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

#import <UIKit/UIKit.h>

/*!
 * @abstract A category on UIDevice to allow fast quering of cached capabilities.
 */
@interface UIDevice (CWCapabilities)

/*!
 * @abstract Ask is the current device is using Phone user interface idiom.
 */
+(BOOL)isPhone;

/*!
 * @abstract Ask is the current device is using Pad user interface idiom.
 */
+(BOOL)isPad;

/*!
 * @abstract Ask if the current devive is capable of multitasking.
 *
 * @discussion Allways returns NO for deviced running iPhone OS 3.2 and earlier.
 */
+(BOOL)isMultitaskingCapable;

@end
