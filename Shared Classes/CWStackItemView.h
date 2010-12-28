//
//  CWStackItemView.h
//  CWStackController
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
 * @abstract CWStackItemView is private layout view used by CWStackView.
 */
@interface CWStackItemView : UIView {
@private
    UIView* _view;
    UIView* _dimmingView;
}

@property(nonatomic, readonly, assign) UIView* view;
@property(nonatomic, readonly, assign) UIView* dimmingView;

+(CWStackItemView*)stackItemViewWithView:(UIView*)view;

-(void)setCoveredByRatio:(CGFloat)coveredBy;

@end

