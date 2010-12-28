//
//  UIColor+CWEditableColor.m
//  SharedComponents
//
//  Copyright 2008-2010 Jayway. All rights reserved.
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

#import "UIColor+CWEditableColor.h"


@implementation UIColor (CWEditableColor)

+(UIColor*)editableColor;
{
  return [UIColor colorWithRed:0.196f green:0.31f blue:0.522f alpha:1.f];;
}

+(UIColor*)groupedLabelTextColor;
{
	return [UIColor colorWithRed:0.3f green:0.33f blue:0.42f alpha:1.f];  
}

+(UIColor*)warningTextColor
{
	return [UIColor colorWithRed:0.5f green:0.f blue:0.f alpha:1.f];
}

@end
