//
//  CWStackItemView.m
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

#import "CWStackItemView.h"


@implementation CWStackItemView


-(UIView*)view;
{
	return [self.subviews objectAtIndex:0];
}

-(UIView*)dimmingView;
{
	return [self.subviews objectAtIndex:1];
}

+(UIImage*)shadowImage;
{
    static UIImage* shadowImage = nil;
	if (shadowImage == nil) {
    	shadowImage = [UIImage imageNamed:@"stackview_shadow.png"];
        shadowImage = [[shadowImage stretchableImageWithLeftCapWidth:1 
                                                        topCapHeight:1] retain];
    }
	return shadowImage;
}

+(CWStackItemView*)stackItemViewWithView:(UIView*)view;
{
    CGRect frame = view.frame;
	CWStackItemView* stackedView = [[[self alloc] initWithFrame:view.frame] autorelease];
    stackedView.autoresizesSubviews = YES;
    stackedView.clipsToBounds = NO;
    frame.origin = CGPointZero;
    view.frame = frame;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [stackedView addSubview:view];
    UIView* dimmingView = [[UIView alloc] initWithFrame:frame];
    dimmingView.userInteractionEnabled = NO;
    dimmingView.frame = frame;
    dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [stackedView addSubview:dimmingView];
	UIImageView* shadowView = [[[UIImageView alloc] initWithImage:[self shadowImage]] autorelease];
    shadowView.userInteractionEnabled = NO;
    shadowView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    frame.size.width = 32;
    frame.origin.x = -32;
    shadowView.frame = frame;
    shadowView.alpha = 0.5f;
    [stackedView addSubview:shadowView];
    [stackedView setCoveredByRatio:0.5f];
    return stackedView;
}

-(void)setCoveredByRatio:(CGFloat)coveredBy;
{
    self.dimmingView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:coveredBy / 2];
}

@end
