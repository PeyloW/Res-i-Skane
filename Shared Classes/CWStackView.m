//
//  CWStackView.m
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

#import "CWStackView.h"
#import "CWStackItemView.h"


typedef struct {
    CWStackView* stackView;
    CWStackItemView* stackItemView;
    CGFloat portraitWidth;
    CGFloat landscapeWidth;
} CWStackItemData;


static CGFloat CWStackItemDataGetCurrentWidth(CWStackItemData* data) {
    if (UIDeviceOrientationIsPortrait(data->stackView.interfaceOrientation)) {
		return data->portraitWidth;
    } else {
        return data->landscapeWidth;
    }
}

static CGRect CWStackItemDataGetCurrentFrame(CWStackItemData* data) {
	CGRect frame = data->stackItemView.frame;
    frame.origin.y = 0;
    frame.size.width = CWStackItemDataGetCurrentWidth(data);
    frame.size.height = data->stackView.bounds.size.height;
    return frame;
}


@interface CWStackView ()

-(CGFloat)minOriginForStackedViewAtIndex:(NSInteger)index;
-(CGFloat)maxOriginForStackedViewAtIndex:(NSInteger)index;

@end


@implementation CWStackView

#pragma mark --- Properties

@synthesize delegate = _delegate;
@synthesize focusedStackViewIndex = _focusedStackViewIndex;
@synthesize rootViewMinInset = _rootViewMinInset;
@synthesize stackedViewMinInset = _stackedViewMinInset;
@synthesize interfaceOrientation = _interfaceOrientation;

-(NSArray*)stackedSubviews;
{
	return [_stackItemData valueForKeyPath:@"stackedView.view"];
}

-(CWStackItemData)stackViewDataAtIndex:(NSInteger)index;
{
    NSValue* value = [_stackItemData objectAtIndex:index];
    CWStackItemData data;
    [value getValue:&data];
	return data;
}

#pragma mark --- Object life cycle

-(void)primitiveInit;
{
    self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
    _stackItemData = [[NSMutableArray alloc] initWithCapacity:8];
    _rootViewMinInset = 72;
    _stackedViewMinInset = 32;
}


-(id)initWithFrame:(CGRect)frame;
{
	self = [super initWithFrame:frame];
    if (self) {
        [self primitiveInit];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder;
{
	[self primitiveInit];
    return [super initWithCoder:aDecoder];
}

-(void)awakeFromNib;
{
    [super awakeFromNib];
	[self primitiveInit];
}

#pragma mark --- Manage the subviews

-(void)addStackedSubview:(UIView*)view contentWidth:(CGFloat)width;
{
	[self addStackedSubview:view
     contentWidthInPortrait:width 
           widthInLandscape:width];
}

-(void)addStackedSubview:(UIView*)view contentWidthInPortrait:(CGFloat)portraitWidth widthInLandscape:(CGFloat)landscapeWidth;
{
	UIPanGestureRecognizer* panGesture = [[[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(handlePanGesture:)] autorelease];
	panGesture.delegate = self;
    view = [CWStackItemView stackItemViewWithView:view];
    [view addGestureRecognizer:panGesture];
    CWStackItemData data = (CWStackItemData){ self, (id)view, portraitWidth, landscapeWidth};
	[_stackItemData addObject:[NSValue value:&data withObjCType:@encode(CWStackItemData)]];
    [self addSubview:view];
    self.focusedStackViewIndex = [_stackItemData count] - 1;
    [self setNeedsLayout];
}

-(void)removeStackedSubviewAtIndex:(NSInteger)index;
{
    CWStackItemData data = [self stackViewDataAtIndex:index];
	[data.stackItemView removeFromSuperview];
    [_stackItemData removeObjectAtIndex:index];
    if (self.focusedStackViewIndex >= [_stackItemData count]) {
    	self.focusedStackViewIndex = [_stackItemData count] - 1;
    }
    [self setNeedsLayout];
}

-(CGRect)frameForStackedSubviewAtIndex:(NSInteger)index;
{
    CWStackItemData data = [self stackViewDataAtIndex:index];
    CGRect frame = CWStackItemDataGetCurrentFrame(&data);
    return frame;
}

-(CGRect)panningBoundsForStackedSubviewAtIndex:(NSInteger)index;
{
    CWStackItemData data = [self stackViewDataAtIndex:index];
    CGRect bounds = CWStackItemDataGetCurrentFrame(&data);
    bounds.origin.x = [self minOriginForStackedViewAtIndex:index];
    bounds.size.width = [self maxOriginForStackedViewAtIndex:index] - bounds.origin.x;
    bounds.size.width += CWStackItemDataGetCurrentWidth(&data);
    return bounds;
}

#pragma mark --- Layout support

-(CGFloat)actualInsetForStackedViewAtIndex:(NSInteger)index;
{
    if (index > 0) {
	    CGFloat fixedInset = (index == 1 ? self.rootViewMinInset : self.stackedViewMinInset);
        CWStackItemData data = [self stackViewDataAtIndex:index - 1];
        CGFloat calculatedInset = CWStackItemDataGetCurrentWidth(&data);
        data = [self stackViewDataAtIndex:index];
        calculatedInset -= CWStackItemDataGetCurrentWidth(&data);
    	CGFloat actualInset = MAX(fixedInset, calculatedInset);
    	return actualInset;
    } else {
    	return 0;
    }
}

-(CGFloat)minOriginForStackedViewAtIndex:(NSInteger)index;
{
	CGFloat minOrigin = 0;
	for (NSInteger leftOfIndex = 1; leftOfIndex <= index; leftOfIndex++) {
        minOrigin += [self actualInsetForStackedViewAtIndex:leftOfIndex];
    }
    return minOrigin;
}

-(CGFloat)maxOriginForStackedViewAtIndex:(NSInteger)index;
{
    CGFloat maxOrigin = 0;
    CWStackItemData data;
    for (NSInteger leftOfIndex = 0; leftOfIndex < index; leftOfIndex++) {
        data = [self stackViewDataAtIndex:leftOfIndex];
    	maxOrigin += CWStackItemDataGetCurrentWidth(&data);
    }
    data = [self stackViewDataAtIndex:index];
    maxOrigin = MIN(maxOrigin, self.bounds.size.width - CWStackItemDataGetCurrentWidth(&data));
    return maxOrigin;
}

-(void)updateCoveredByRatiosForAllStackedViews;
{
    if ([_stackItemData count] > 0) {
    	[[self stackViewDataAtIndex:0].stackItemView setCoveredByRatio:0];
        for (NSInteger index = 1; index < [_stackItemData count] - 1; index++) {
			CWStackItemData data = [self stackViewDataAtIndex:index];
            CGFloat nextOrigin = [self stackViewDataAtIndex:index + 1].stackItemView.frame.origin.x;
            CGFloat delta = nextOrigin - data.stackItemView.frame.origin.x;
            CGFloat maxDelta = CWStackItemDataGetCurrentWidth(&data) - [self actualInsetForStackedViewAtIndex:index];
            CGFloat coveredByRatio = 1 - delta / maxDelta;
            [data.stackItemView setCoveredByRatio:coveredByRatio];
        }
        [[self stackViewDataAtIndex:[_stackItemData count] - 1].stackItemView setCoveredByRatio:0];
    }
}

-(void)addTranslationToFocusedStackView:(CGPoint)translation;
{
    CWStackItemData data = [self stackViewDataAtIndex:self.focusedStackViewIndex];
	CGRect fixedFrame = CWStackItemDataGetCurrentFrame(&data);
    fixedFrame.origin.x += translation.x;
    data.stackItemView.frame = fixedFrame;
    CGRect frame = fixedFrame;
    for (NSInteger leftOfIndex = self.focusedStackViewIndex - 1; leftOfIndex > 0; leftOfIndex--) {
        data = [self stackViewDataAtIndex:leftOfIndex];
    	CGFloat minOrigin = frame.origin.x - CWStackItemDataGetCurrentWidth(&data);
        CGFloat maxOrigin = frame.origin.x - [self actualInsetForStackedViewAtIndex:leftOfIndex + 1];
        frame = CWStackItemDataGetCurrentFrame(&data);
        CGFloat targetOrigin = MAX(minOrigin, MIN(maxOrigin, frame.origin.x));
        if (targetOrigin != frame.origin.x) {
			frame.origin.x = targetOrigin;
            data.stackItemView.frame = frame;
        }
    }
    frame = fixedFrame;
    for (NSInteger rightOfIndex = self.focusedStackViewIndex + 1; rightOfIndex < [_stackItemData count]; rightOfIndex++) {
        CWStackItemData data = [self stackViewDataAtIndex:rightOfIndex];
    	CGFloat minOrigin = frame.origin.x + [self actualInsetForStackedViewAtIndex:rightOfIndex];
        CGFloat maxOrigin = frame.origin.x + frame.size.width;
        if (rightOfIndex == self.focusedStackViewIndex + 1) {
        	minOrigin = maxOrigin;
        }
        frame = CWStackItemDataGetCurrentFrame(&data);
        CGFloat targetOrigin = MAX(minOrigin, MIN(maxOrigin, frame.origin.x));
        if (targetOrigin != frame.origin.x) {
			frame.origin.x = targetOrigin;
            data.stackItemView.frame = frame;
        }
    }
    [self updateCoveredByRatiosForAllStackedViews];
}

-(void)layoutStackedViewsAnimated:(BOOL)animated;
{
    NSInteger index = self.focusedStackViewIndex;
    CWStackItemData data = [self stackViewDataAtIndex:index];
    CGRect frame = CWStackItemDataGetCurrentFrame(&data);
    CGFloat minOrigin = [self minOriginForStackedViewAtIndex:index];
    CGFloat maxOrigin = [self maxOriginForStackedViewAtIndex:index];
    CGFloat targetOrigin = minOrigin;
    if (ABS(maxOrigin - frame.origin.x) < ABS(minOrigin - frame.origin.x)) {
    	targetOrigin = maxOrigin;
    }
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    }
    frame.origin.x = targetOrigin;
    data.stackItemView.frame = frame;
    [self addTranslationToFocusedStackView:CGPointZero];
    for (NSInteger leftOfIndex = 1; leftOfIndex < index; leftOfIndex++) {
        data = [self stackViewDataAtIndex:leftOfIndex];
        frame = CWStackItemDataGetCurrentFrame(&data);
        minOrigin = [self minOriginForStackedViewAtIndex:leftOfIndex];
        maxOrigin = [self maxOriginForStackedViewAtIndex:leftOfIndex];
        frame.origin.x = MAX(minOrigin, MIN(maxOrigin, frame.origin.x));
        data.stackItemView.frame = frame;
    }
    for (NSInteger rightOfIndex = index; rightOfIndex < [_stackItemData count]; rightOfIndex++) {
        data = [self stackViewDataAtIndex:rightOfIndex];
        frame = CWStackItemDataGetCurrentFrame(&data);
        data.stackItemView.frame = frame;
    }
    [self updateCoveredByRatiosForAllStackedViews];
    if (animated) {
        [UIView commitAnimations];
    }
}

-(void)layoutSubviews;
{
	[super layoutSubviews];
    if ([_stackItemData count] > 0) {
        [self layoutStackedViewsAnimated:NO];
        CWStackItemData data = [self stackViewDataAtIndex:0];
        data.stackItemView.frame = CWStackItemDataGetCurrentFrame(&data);
    }
}


#pragma mark --- Handle Dragging of managed views

-(NSInteger)indexForGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer;
{
	UIView* view = gestureRecognizer.view;
    for (NSInteger index = 0; index < [_stackItemData count]; index++) {
    	if ([self stackViewDataAtIndex:index].stackItemView == view) {
        	return index;
        }
    }
    return NSNotFound;
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
	NSInteger index = [self indexForGestureRecognizer:gestureRecognizer];
    if ([_delegate respondsToSelector:@selector(stackView:shouldBegingPannigStackedSubviewAtIndex:)]) {
        return [_delegate stackView:self shouldBegingPannigStackedSubviewAtIndex:index];                
    }
    return index > 0;
}

-(void)beginPanningForStackedViewAtIndex:(NSInteger)index;
{
	self.focusedStackViewIndex = index;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[self addTranslationToFocusedStackView:CGPointZero];
    [UIView commitAnimations];
}

-(void)performPanningForStackedViewAtIndex:(NSInteger)index translation:(CGPoint)translation;
{
	[self addTranslationToFocusedStackView:translation];
	if ([_delegate respondsToSelector:@selector(stackView:didPanStackedSubviewAtIndex:)]) {
    	[_delegate stackView:self didPanStackedSubviewAtIndex:index];
    }
}

-(void)endPanningForStackedViewAtIndex:(NSInteger)index;
{
    [self layoutStackedViewsAnimated:YES];
    if ([_delegate respondsToSelector:@selector(stackView:didEndPannigStackedSubviewAtIndex:)]) {
        [_delegate stackView:self didEndPannigStackedSubviewAtIndex:index];
    }
}

-(void)handlePanGesture:(UIPanGestureRecognizer*)panGesture;
{
	NSInteger index = [self indexForGestureRecognizer:panGesture];
    NSAssert([self stackViewDataAtIndex:index].stackItemView == panGesture.view, @"Unexpected view to gesture recognizer mapping");
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self beginPanningForStackedViewAtIndex:index];
            break;
    	case UIGestureRecognizerStateChanged:
            [self performPanningForStackedViewAtIndex:index translation:[panGesture translationInView:panGesture.view]];
            break;
        case UIGestureRecognizerStateEnded: // Intentional fallthrough
        case UIGestureRecognizerStateCancelled:
			[self endPanningForStackedViewAtIndex:index];
            break;
    }
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

@end
