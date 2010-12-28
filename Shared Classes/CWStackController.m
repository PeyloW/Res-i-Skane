//
//  CWStackController.m
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

#import "CWStackController.h"
#import "CWStackView.h"
#import "NSInvocation+CWVariableArguments.h"

@implementation CWStackController

#pragma mark --- Properties

@synthesize delegate = _delegate;

-(CWStackView*)stackView;
{
	return (id)self.view;
}

-(UIViewController* )rootViewController;
{
	return [_stackedViewControllers objectAtIndex:0];    
}

-(void)setRootViewController:(UIViewController*)viewController;
{
    NSAssert(_stackedViewControllers == nil, @"CWStackController do not support eplacing the rootViewController.");
    _stackedViewControllers = [[NSMutableArray alloc] initWithObjects:viewController, nil];
    [viewController setValue:self forKey:@"_parentViewController"];
}

-(UIViewController*) topViewController;
{
    return [_stackedViewControllers lastObject];
}

-(NSArray*)viewControllers;
{
	return [NSArray arrayWithArray:_stackedViewControllers];
}


#pragma mark --- Instance life cycle

-(id)initWithRootViewController:(UIViewController*)viewController;
{
	self = [super initWithNibName:nil bundle:nil];
    _stackedViewControllers = [[NSMutableArray alloc] initWithObjects:viewController, nil];
    [viewController setValue:self forKey:@"_parentViewController"];
    return self;
}

-(void)dealloc;
{
	[_stackedViewControllers release];
    [super dealloc];
}

#pragma mark --- Manage view life cycle

-(void)setupPushedViewController:(UIViewController*)viewController animated:(BOOL)animated;
{
    [viewController viewWillAppear:animated];
    [self.stackView addStackedSubview:viewController.view
               contentWidthInPortrait:viewController.contentWidthInStackControllerForPortraitOrientation
                     widthInLandscape:viewController.contentWidthInStackControllerForLandscapeOrientation];
	[viewController viewDidAppear:animated];
}

-(void)viewDidLoad;
{
	[super viewDidLoad];
    if ([self.stackView isKindOfClass:[CWStackView class]]) {
    	CWStackView* stackView = [[[CWStackView alloc] initWithFrame:self.stackView.frame] autorelease];
        stackView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.view = stackView;
    }
    self.stackView.interfaceOrientation = self.interfaceOrientation;
    for (UIViewController* viewController in _stackedViewControllers) {
    	[self setupPushedViewController:viewController animated:NO];
    }
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
{
	for (UIViewController* viewController in _stackedViewControllers) {
    	if (![viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
        	return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
        }
    }
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if ([self isViewLoaded]) {
    	self.stackView.interfaceOrientation = toInterfaceOrientation;
    }
    NSInvocation* invocation = [NSInvocation invocationForInstancesOfClass:[UIViewController class]
                                                              withSelector:_cmd
                                                           retainArguments:NO, toInterfaceOrientation, duration];
    [invocation invokeWithAllTargets:self.viewControllers];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
{
	[super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    NSInvocation* invocation = [NSInvocation invocationForInstancesOfClass:[UIViewController class]
                                                              withSelector:_cmd
                                                           retainArguments:NO, toInterfaceOrientation, duration];
    [invocation invokeWithAllTargets:self.viewControllers];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
{
	[super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    NSInvocation* invocation = [NSInvocation invocationForInstancesOfClass:[UIViewController class]
                                                              withSelector:_cmd
                                                           retainArguments:NO, fromInterfaceOrientation];
    [invocation invokeWithAllTargets:self.viewControllers];
}

#pragma mark --- Pushing and poppin stacked items

-(void)pushViewController:(UIViewController*)viewController animated:(BOOL)animated;
{
    [_stackedViewControllers addObject:viewController];
    [viewController setValue:self forKey:@"_parentViewController"];
    if ([self isViewLoaded]) {
        [self setupPushedViewController:viewController animated:animated];
    }
}

-(void)popViewControllerAnimated:(BOOL)animated;
{
    NSInteger count = [_stackedViewControllers count];
	if (count > 1) {
    	[self popToViewController:[_stackedViewControllers objectAtIndex:count - 2]
                         animated:animated];
    } else {
    	[NSException raise:NSInternalInconsistencyException
                    format:@"Can not pop the root view controller"];
    }
}

-(void)popToRootViewControllerAnimated:(BOOL)animated;
{
	[self popToViewController:self.rootViewController
                     animated:animated];    
}

-(void)popToViewController:(UIViewController*)viewController animated:(BOOL)animated;
{
    if ([_stackedViewControllers indexOfObject:viewController] == NSNotFound) {
    	[NSException raise:NSInvalidArgumentException
                    format:@"View controller not in stack: %@", viewController];
    } else {
        while ([_stackedViewControllers lastObject] != viewController) {
            UIViewController* viewController = [_stackedViewControllers lastObject];
            [viewController viewWillDisappear:animated];
            [self.stackView removeStackedSubviewAtIndex:[_stackedViewControllers count] - 1];
            [[_stackedViewControllers lastObject] setValue:nil forKey:@"_parentViewController"];
            [_stackedViewControllers removeLastObject];
            [viewController viewDidDisappear:animated];
        }
    }
}

-(CGRect)frameForViewController:(UIViewController*)viewController;
{
	NSInteger index = [_stackedViewControllers indexOfObject:viewController];
    return [self.stackView frameForStackedSubviewAtIndex:index];
}

-(CGRect)panningBoundsForViewController:(UIViewController*)viewController;
{
	NSInteger index = [_stackedViewControllers indexOfObject:viewController];
    return [self.stackView panningBoundsForStackedSubviewAtIndex:index];
}


#pragma mark --- Stack view delegate

-(BOOL)stackView:(CWStackView *)stactView shouldBegingPannigStackedSubviewAtIndex:(NSInteger)index;
{
 	if ([self.delegate respondsToSelector:@selector(stackController:shouldBeginPanningViewController:)]) {
    	return [self.delegate stackController:self 
             shouldBeginPanningViewController:[_stackedViewControllers objectAtIndex:index]];
    }
    return YES;
}

-(void)stackView:(CWStackView *)stackView didPanStackedSubviewAtIndex:(NSInteger)index;
{
	if ([self.delegate respondsToSelector:@selector(stackController:didPanViewController:)]) {
    	[self.delegate stackController:self
                  didPanViewController:[_stackedViewControllers objectAtIndex:index]];
    }
}

-(void)stackView:(CWStackView *)stactView didEndPannigStackedSubviewAtIndex:(NSInteger)index;
{
	if ([self.delegate respondsToSelector:@selector(stackController:didEndPanningViewController:)]) {
    	[self.delegate stackController:self
           didEndPanningViewController:[_stackedViewControllers objectAtIndex:index]];
    }
}

@end


@implementation  UIViewController (CWStackController)

-(CWStackController*)stackController;
{
	UIViewController* parent = self.parentViewController;
    if (parent == nil) {
    	return nil;
    }
    if ([parent isKindOfClass:[CWStackController class]]) {
        return (id)parent;
    } else {
    	return parent.stackController;
    }
}

-(CGFloat)contentWidthInStackControllerForPortraitOrientation;
{
	return 320.f; 
}

-(CGFloat)contentWidthInStackControllerForLandscapeOrientation;
{
	return self.contentWidthInStackControllerForPortraitOrientation;
}

@end