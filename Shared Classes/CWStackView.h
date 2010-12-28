//
//  CWStackView.h
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

@protocol CWStackViewDelegate;

/*!
 * @abstract A CWStackView manages a stack of subviews that can be panned
 *           horizontally.
 *
 * @discussion It is recomended to use CWStackController to manage a CWStackView.
 */
@interface CWStackView : UIView <UIGestureRecognizerDelegate> {
@private
    id<CWStackViewDelegate> _delegate;
    NSMutableArray* _stackItemData;
    NSInteger _focusedStackViewIndex;
    CGFloat _rootViewMinInset;
    CGFloat _stackedViewMinInset;
    UIDeviceOrientation _interfaceOrientation;
}

@property(nonatomic, assign) IBOutlet id<CWStackViewDelegate> delegate;
@property(nonatomic, copy, readonly) NSArray* stackedSubviews;

/*!
 * @abstract The focused stack view is always fully visible.
 * @discussion The last panned view, or the last pushed view is focused.
 */
@property(nonatomic, assign) NSInteger focusedStackViewIndex;

/*!
 * @abstract The min inset for the view above the root view.
 * @discussion Default is 72 points.
 */
@property(nonatomic, assign) CGFloat rootViewMinInset;

/*!
 * @abstract The min inset for the view above another view.
 * @abstract The default is 32 points.
 */
@property(nonatomic, assign) CGFloat stackedViewMinInset;

/*!
 * @abstract The current interface orientation to layout the stack view for.
 */
@property(nonatomic, assign) UIDeviceOrientation interfaceOrientation;

/*!
 * @abstract Add a new stacked subview with same width in portrait and landscape.
 */
-(void)addStackedSubview:(UIView*)view contentWidth:(CGFloat)width;

/*!
 * @abstract Add a new stacked subview with different width in portrait and landscape.
 */
-(void)addStackedSubview:(UIView*)view contentWidthInPortrait:(CGFloat)portraitWidth widthInLandscape:(CGFloat)landscapeWidth;

/*!
 * @abstract Remove a subview form the stack.
 */
-(void)removeStackedSubviewAtIndex:(NSInteger)index;

/*!
 * @abstract The current frame of the stacked subview.
 */
-(CGRect)frameForStackedSubviewAtIndex:(NSInteger)index;

/*!
 * @abstract The rectangle with the bounds that the stacked subview can be panned in.
 * @discussion The current frame can be outside the bounds during panning, this can be
 *             used to implement "tear of item", or "drag to refresh" behaviours.
 */
-(CGRect)panningBoundsForStackedSubviewAtIndex:(NSInteger)index;

@end


@protocol CWStackViewDelegate <NSObject>

@optional
-(BOOL)stackView:(CWStackView*)stactView shouldBegingPannigStackedSubviewAtIndex:(NSInteger)index;
-(void)stackView:(CWStackView*)stackView didPanStackedSubviewAtIndex:(NSInteger)index;
-(void)stackView:(CWStackView*)stactView didEndPannigStackedSubviewAtIndex:(NSInteger)index;

@end
