//
//  CWLocationIndicatorView.m
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-02-03.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import "FOLocationIndicatorView.h"
#import <CoreGraphics/CoreGraphics.h>
#import "FOPoint.h"
#import <math.h>

@implementation FOLocationIndicatorView

static CGFloat lastRadius = 14;

-(id)init;
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 34, 20)];
	self = [self initWithFrame:CGRectMake(3, -9, 40, 40)];
	if (self) {
        self.userInteractionEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        self.clearsContextBeforeDrawing = YES;
        self.opaque = NO;
		view.clipsToBounds = NO;
		[view addSubview:self];
        [self release];
    }
    return view;
}


- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGPoint center = CGPointMake(20, 20);
    FOPoint* p = [FOPoint currentLocationPoint];
    FOPointStatus pointStatus = [p pointStatus];
    CGFloat radius = p.locationAccuracy;
    radius = log(radius / 100) * 8 + 6;
    radius = MIN(MAX(4, radius), 14);
    BOOL isSearching = NO;
    if (pointStatus == FOPointStatusInitial || pointStatus == FOPointStatusPending) {
        CGFloat deltaRadius = MAX(MIN(lastRadius - radius, 0.5f), -0.5f);
        radius = lastRadius - deltaRadius;
        lastRadius = radius;
		isSearching = YES;
        NSTimeInterval ti = [NSDate timeIntervalSinceReferenceDate];
		radius -= sin(ti * 7) * 1.5f;
        //    NSLog(@"acc: %f radius: %f time interval: %f", p.locationAccuracy, radius, ti);
    }
    CGRect circleRect = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    
	CGContextSetRGBStrokeColor(context, 0, .2f, 1.f, isSearching ? .6f : .8f);
	CGContextSetRGBFillColor(context, 0, .2f, 1.f, isSearching ? .05f : .15f);
    CGContextFillEllipseInRect(context, circleRect);
	CGContextStrokeEllipseInRect(context, circleRect);
    
	CGContextSetRGBFillColor(context, .1f, .3f, 1.f, 1.f);
    CGContextFillEllipseInRect(context, CGRectMake(center.x-2.f, center.y-2.f, 4, 4));
    if (isSearching) {
        [self performSelector:@selector(setNeedsDisplay) withObject:nil afterDelay:1.f / 30];
    }
}

@end
