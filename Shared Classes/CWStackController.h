//
//  CWStackController.h
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
#import "CWStackView.h"


@protocol CWStackControllerDelegate;


/*!
 * @abstract CWStackController is a view controller subclass for managing a stack of 
 *           view controllers.
 *
 * @discussion Conceptually CWStackController works like a UINavigationController,
 *			   where view controllers are pushed and popped. The difference is that
 *             all view controllers are accesible all the time.
 */
@interface CWStackController : UIViewController <CWStackViewDelegate> {
@private
    id<CWStackControllerDelegate> _delegate;
    NSMutableArray* _stackedViewControllers;
}

/*!
 * @abstract The delegate, settable from Interface Builder.
 */
@property(nonatomic, assign) IBOutlet id<CWStackControllerDelegate> delegate;

/*!
 * @abstract The root view controller, settable from Interface Builder.
 */
@property(nonatomic, readonly, retain) IBOutlet UIViewController* rootViewController;

/*!
 * @abstract The managed CWStackView. 
 * @discussion The view property can be set to a custom CWStackView from Interface Builder.
 */
@property(nonatomic, readonly, retain) CWStackView* stackView;

/*!
 * @abstract The view controller currently on top of the stack. Can be the root view controller.
 */
@property(nonatomic, readonly, retain) UIViewController* topViewController;

/*!
 * @abstract An ordered array of all managed view controllers.
 * @discussion The root view controller is at index 0, and the top controller at the last index.
 */
@property(nonatomic, readonly, copy) NSArray* viewControllers;

/*!
 * @abstract The designated initializer. 
 */
-(id)initWithRootViewController:(UIViewController*)viewController;

/*!
 * @abstract Push a new view controller on top of the stack.
 */
-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;

/*!
 * @abstract Pop the top view controller.
 */
-(void)popViewControllerAnimated:(BOOL)animated;

/*!
 * @abstract Pop all but the root view controllers.
 */
-(void)popToRootViewControllerAnimated:(BOOL)animated;

/*!
 * @abstract Pop view controllers until the specified view controller is the top controller.
 */
-(void)popToViewController:(UIViewController*)viewController animated:(BOOL)animated;

/*!
 * @abstract The current frame of the view managed by a view controller in th stack.
 */
-(CGRect)frameForViewController:(UIViewController*)viewController;

/*!
 * @abstract The rectangle with the bounds that the view managed by a view controller can be panned in.
 * @discussion The current frame can be outside the bounds during panning, this can be
 *             used to implement "tear of item", or "drag to refresh" behaviours.
 */
-(CGRect)panningBoundsForViewController:(UIViewController*)viewController;

@end


/*!
 * @abstract The CWStackControllerDelegate protocol defines methods for responding to
 *           events from the stack controller.
 */
@protocol CWStackControllerDelegate <NSObject>

@optional
-(BOOL)stackController:(CWStackController*)stackController shouldBeginPanningViewController:(UIViewController*)viewController; 
-(void)stackController:(CWStackController*)stackController didPanViewController:(UIViewController*)viewController;
-(void)stackController:(CWStackController*)stackController didEndPanningViewController:(UIViewController*)viewController;

@end


/*!
 * @abstract Additions to UIViewController in order to work in a CWStackController.
 */
@interface UIViewController (CWStackController)

@property(nonatomic, readonly, retain) CWStackController* stackController;

@property(nonatomic, readonly, assign) CGFloat contentWidthInStackControllerForPortraitOrientation;
@property(nonatomic, readonly, assign) CGFloat contentWidthInStackControllerForLandscapeOrientation;

@end