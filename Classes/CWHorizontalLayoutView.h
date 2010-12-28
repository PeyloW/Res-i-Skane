//
//  CWHorizontalLayoutView.h
//  SharedComponents
//
//  Copyright 2009-2010 Jayway. All rights reserved.
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

#define CWHorizontalLayoutViewPadding (4.f)

/*!
 * @abstract A view that layouts it's childviews horizontally, and adjust their sizes to fill it's own size.
 *
 * @discussion A Child view with flexxible with according to autoresizing mask will be requested to fitSizeToFit before layout.
 */
@interface CWHorizontalLayoutView : UIView {
@private
  NSInteger _indexOfFlexibleView;
}

@property(nonatomic, assign) NSInteger indexOfFlexibleView; //! Index of the child view that should flex in size.

@end
