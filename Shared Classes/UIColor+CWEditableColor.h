//
//  UIColor+CWEditableColor.h
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

#import <Foundation/Foundation.h>

/*!
 * @abstract Helper category for more standard colors.
 */
@interface UIColor (CWEditableColor)

+(UIColor*)editableColor;            //! Color of the editable detail label of a cell.
+(UIColor*)groupedLabelTextColor;    //! Color of the section labels of a groubed table view.
+(UIColor*)warningTextColor;         //! Color to use for displaying a warning label.

@end
