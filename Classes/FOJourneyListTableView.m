//
//  CWJournetListTableView.m
//  ResaISkane
//
//  Copyright 2009-2010 Fredrik Olsson. All rights reserved.
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

#import "FOJourneyListTableView.h"


@implementation FOMoreView

-(void)setHidden:(BOOL)hidden;
{
	contentView.hidden = hidden;
}

-(void)updateTitle;
{
    NSString* title = nil;
	if (_loading) {
        title = NSLocalizedString(@"Loading", nil);
    } else if (_before) {
		title = NSLocalizedString(_primed ? @"DropToFetchBefore" : @"DragToFetchBefore", nil);
    } else {
		title = NSLocalizedString(_primed ? @"DropToFetchAfter" : @"DragToFetchAfter", nil);
    }
    titleLabel.text = title;
}

-(void)rotateArrow;
{
    if (CGAffineTransformIsIdentity(arrowImageView.transform)) {
        targetTransform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI);
    } else {
		targetTransform = CGAffineTransformIdentity;
    }
 	if (self.window) {
        [UIView beginAnimations:@"rotateArrow" context:NULL];
 		[UIView setAnimationDelegate:self];
        [UIView setAnimationDuration:0.1f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        arrowImageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI / 2);
        [UIView commitAnimations];
    } else {
        arrowImageView.transform = targetTransform;
    }
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
{
    if ([animationID isEqualToString:@"rotateArrow"]) {
        [UIView beginAnimations:@"finishRotateArrow" context:NULL];
        [UIView setAnimationDuration:0.1f];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		arrowImageView.transform = targetTransform;
        [UIView commitAnimations];
    }
}

-(BOOL)before;
{
	return _before;
}

-(void)setBefore:(BOOL)before
{
	_before = before;
    [self updateTitle];
    if (_before) {
        [self rotateArrow];
        contentView.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
    } else {
        contentView.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
    }
}

-(BOOL)primed;
{
	return _primed;
}

-(void)setPrimed:(BOOL)primed;
{
    if (_primed != primed) {
        if (_primed != primed) {
            [self rotateArrow];
        }
        _primed = primed;
        [self updateTitle];
    }
}

-(BOOL)loading;
{
	return _loading;
}

-(void)setLoading:(BOOL)loading;
{
    if (_loading != loading) {
        _loading = loading;
        [self updateTitle];
        if (_loading) {
            arrowImageView.hidden = YES;
            [activityIndicatorView startAnimating];
        } else {
            arrowImageView.hidden = NO;
            [activityIndicatorView stopAnimating];
        }
    }
}

+(FOMoreView*)moreViewForBefore:(BOOL)before;
{
    NSArray* objects = [[NSBundle mainBundle] loadNibNamed:@"FOMoreView" owner:self options:nil];
    for (id object in objects) {
        if ([object tag] == 1) {
            [object setBefore:before];
			return object;
        }
    }
    return nil;
}

@end


@implementation FOJourneyListTableView

-(FOMoreView*)beforeMoreView;
{
	if (beforeMoreView == nil) {
        beforeMoreView = [FOMoreView moreViewForBefore:YES];
        [self addSubview:beforeMoreView];
    }
    CGRect frame = self.bounds;
    frame.origin.y = -frame.size.height;
    beforeMoreView.frame = frame;
    return beforeMoreView;
}

-(FOMoreView*)afterMoreView;
{
	if (afterMoreView == nil) {
        afterMoreView = [FOMoreView moreViewForBefore:NO];
        [self addSubview:afterMoreView];
    }
    CGRect frame = self.bounds;
    frame.origin.y = MAX(self.contentSize.height, frame.size.height);
    afterMoreView.frame = frame;
    return afterMoreView;
}

@end
