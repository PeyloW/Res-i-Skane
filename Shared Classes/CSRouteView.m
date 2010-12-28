//
//  CSRouteView.m
//  testMapp
//
//  Created by Craig on 8/18/09.
//  Copyright Craig Spitzkoff 2009. All rights reserved.
//

#import "CSRouteView.h"
#import "CSRouteAnnotation.h"

// this is an internally used view to CSRouteView. The CSRouteView needs a subview that does not get clipped to always
// be positioned at the full frame size and origin of the map. This way the view can be smaller than the route, but it
// always draws in the internal subview, which is the size of the map view. 
@interface CSRouteViewInternal : UIView
{
	// route view which added this as a subview. 
	CSRouteView* _routeView;
}
@property (nonatomic, retain) CSRouteView* routeView;
@end

@implementation CSRouteViewInternal
@synthesize routeView = _routeView;

-(void) drawRect:(CGRect) rect
{    
	CSRouteAnnotation* routeAnnotation = (CSRouteAnnotation*)self.routeView.annotation;
	
	// only draw our lines if we're not int he moddie of a transition and we 
	// acutally have some points to draw. 
	if(nil != routeAnnotation.points && routeAnnotation.points.count > 0)
	{
		CGContextRef context = UIGraphicsGetCurrentContext(); 
		
		if(nil == routeAnnotation.lineColor)
			routeAnnotation.lineColor = [UIColor blueColor]; // setting the property instead of the member variable will automatically reatin it.
						
        CGMutablePathRef path = CGPathCreateMutable();
        
		for(int idx = 0; idx < routeAnnotation.points.count; idx++)
		{
			CLLocation* location = [routeAnnotation.points objectAtIndex:idx];
			CGPoint point = [self.routeView.mapView convertCoordinate:location.coordinate toPointToView:self];
			
			//NSLog(@"Point: %lf, %lf", point.x, point.y);
			
			if(idx == 0)
			{
				// move to the first point
                CGPathMoveToPoint(path, NULL, point.x, point.y);
			}
			else
			{
                CGPathAddLineToPoint(path, NULL, point.x, point.y);
			}
		}
		
		CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        
        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor);
		CGContextSetLineWidth(context, 5.0);
        CGContextAddPath(context, path);
		CGContextStrokePath(context);

        // Draw them with a 2.0 stroke width so they are a bit more visible.
        CGContextSetStrokeColorWithColor(context, routeAnnotation.lineColor.CGColor);
		CGContextSetLineWidth(context, 3.0);
        CGContextAddPath(context, path);
		CGContextStrokePath(context);
                
        CGPathRelease(path);
		
		// debug. Draw the line around our view. 
		/*
		CGContextMoveToPoint(context, 0, 0);
		CGContextAddLineToPoint(context, 0, self.frame.size.height);
		CGContextAddLineToPoint(context, self.frame.size.width, self.frame.size.height);
		CGContextAddLineToPoint(context, self.frame.size.width, 0);
		CGContextAddLineToPoint(context, 0, 0);
		CGContextStrokePath(context);
		*/
	}
	

}

-(id) init
{
	self = [super init];
	self.backgroundColor = [UIColor clearColor];
	self.clipsToBounds = NO;
	
	return self;
}

-(void) dealloc
{
	self.routeView = nil;
	
	[super dealloc];
}
@end

@implementation CSRouteView
@synthesize mapView = _mapView;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
		self.backgroundColor = [UIColor clearColor];

		// do not clip the bounds. We need the CSRouteViewInternal to be able to render the route, regardless of where the
		// actual annotation view is displayed. 
		self.clipsToBounds = NO;
		
		// create the internal route view that does the rendering of the route. 
		_internalRouteView = [[CSRouteViewInternal alloc] init];
		_internalRouteView.routeView = self;
		
		[self addSubview:_internalRouteView];
    }
    return self;
}

-(void) setMapView:(MKMapView*) mapView
{
	[_mapView release];
	_mapView = [mapView retain];
	
	[self regionChanged];
}
-(void) regionChanged
{
	//NSLog(@"Region Changed");
	
	// move the internal route view. 
	CGPoint origin = CGPointMake(0, 0);
	origin = [_mapView convertPoint:origin toView:self];
	
	_internalRouteView.frame = CGRectMake(origin.x, origin.y, _mapView.frame.size.width, _mapView.frame.size.height);
	[_internalRouteView setNeedsDisplay];
	
}

- (void)dealloc 
{
	[_mapView release];
	[_internalRouteView release];
	
    [super dealloc];
}


@end
