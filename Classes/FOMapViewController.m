//
//  CWMapViewController.m
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-02-05.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import "FOMapViewController.h"
#import "NSDate+CWExtentions.h"
#import "CSRouteAnnotation.h"
#import "CSRouteView.h"
#import "FOPart.h"
#import "CSRouteView.h"

@interface CWJourneyAnnotation : NSObject <MKAnnotation> {
@private
    CLLocationCoordinate2D coordinate;
    FOPointType pointType;
    MKPinAnnotationColor pinColor;
    NSString* title;
    NSString* subtitle;
}

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;
@property(nonatomic, assign) FOPointType pointType;
@property(nonatomic, assign) MKPinAnnotationColor pinColor;
@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* subtitle;

+(CWJourneyAnnotation*)journeyAnnotationWithStartRouteLink:(FORouteLink*)routeLink;
+(CWJourneyAnnotation*)journeyAnnotationWithRouteLink:(FORouteLink*)routeLink previousRouteLink:(FORouteLink*)prevRouteLink;
+(CWJourneyAnnotation*)journeyAnnotationWithEndRouteLink:(FORouteLink*)routeLink;

@end


@implementation FOMapViewController

-(id)initWithPoint:(FOPoint*)aPoint;
{
    self = [self init];
    if (self) {
        point = [aPoint retain];
        annotations = [[NSMutableArray alloc] init];
        self.title = point.title;
    }
    return self;
}

-(id)initWithJourney:(FOJourney*)aJourney;
{
    self = [self init];
    if (self) {
        annotations = [[NSMutableArray alloc] init];
        journey = [aJourney retain];
        routeViews = [[NSMutableSet alloc] init];
    }
    return self;
}

-(void)loadView;
{
    mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    mapView.delegate = self;
    self.view = mapView;
	if (point != nil) {
        [self performSelectorInBackground:@selector(primePointAnnotation) withObject:nil];
    } else if (journey != nil) {
        [self performSelectorInBackground:@selector(primeJourneyAnnotations) withObject:nil];
    }
}

-(void)viewDidLoad;
{
    mapView.showsUserLocation = YES;
}

-(IBAction)targetSwap:(UIButton*)sender;
{
    sender.selected = !sender.selected;
    mapView.showsUserLocation = sender.selected;
}

-(void)primePointAnnotation;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    point.coordinate;
    [annotations addObject:point];
    [self performSelectorOnMainThread:@selector(addAnnotations) withObject:nil waitUntilDone:NO];
    [pool release];
}

-(void)primeJourneyAnnotations;
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    points = [[NSMutableArray alloc] init];
    if ([journey canFetchParts]) {
        NSArray* parts = journey.parts;
        if (parts) {
            hasParts = YES;
            int routeIndex = 0;
            for (FOPart* part in parts) {
                BOOL isPadder = [part.from isEqual:part.to];
                FORouteLink* link = [journey.routeLinks objectAtIndex:routeIndex];
                CSRouteAnnotation* partAnotation = [[CSRouteAnnotation alloc] initWithPoints:part.coordinates 
                                                                                       color:isPadder ? [UIColor colorWithWhite:0.1f alpha:0.7f] : link.line.color];
                [annotations addObject:partAnotation];
                [partAnotation release];
                if (!isPadder) {
                    routeIndex++;
                }
            }
        }
        BOOL isStarting = YES;
        BOOL isFirst = YES;
		int routeIndex = 0;
		for (FOPart* part in parts) {
        	FORouteLink* link = [journey.routeLinks objectAtIndex:routeIndex];
            CWJourneyAnnotation* annotation = [[[CWJourneyAnnotation alloc] init] autorelease];
            annotation.pinColor = isFirst ? MKPinAnnotationColorGreen : MKPinAnnotationColorRed;
            annotation.coordinate = [[part.coordinates objectAtIndex:0] coordinate];
            annotation.pointType = link.from.type;
            annotation.title = part.from.title;
            isFirst = NO;
            BOOL isPadder = [part.from isEqual:part.to];
            if (isStarting) {
                isStarting = NO;
                annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleStart", nil), [link.departure localizedShortTimeString], link.line.fullName];
            } else {
				if (isPadder) {
                    link = [journey.routeLinks objectAtIndex:routeIndex - 1];
                    annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleEnd", nil), [link.arrival localizedShortTimeString], link.line.fullName];
                } else {
                    annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleStart", nil), [link.departure localizedShortTimeString], link.line.fullName];
                }
            }
            if (!isPadder) {
            	routeIndex++;
            } else {
            	isStarting = YES;
            }
            [annotations addObject:annotation];
        }
        FOPart* part = [parts lastObject];
        FORouteLink* link = [journey.routeLinks lastObject];
        CWJourneyAnnotation* annotation = [[[CWJourneyAnnotation alloc] init] autorelease];
        annotation.pinColor = MKPinAnnotationColorRed;
        annotation.coordinate = [[part.coordinates lastObject] coordinate];
        annotation.pointType = link.to.type;
        annotation.title = part.to.title;
        annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleEnd", nil), [link.arrival localizedShortTimeString], link.line.fullName];
        [annotations addObject:annotation];
    } else {
        CWJourneyAnnotation* annotation = [CWJourneyAnnotation journeyAnnotationWithStartRouteLink:[journey.routeLinks objectAtIndex:0]];
        [annotations addObject:annotation];
        [points addObject:[[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude] autorelease]];
        for (int i = 0; i < [journey.routeLinks count] - 1; i++) {
            annotation = [CWJourneyAnnotation journeyAnnotationWithRouteLink:[journey.routeLinks objectAtIndex:i + 1] previousRouteLink:[journey.routeLinks objectAtIndex:i]];
            [annotations addObject:annotation];
            [points addObject:[[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude] autorelease] ];
        }
        annotation = [CWJourneyAnnotation journeyAnnotationWithEndRouteLink:[journey.routeLinks lastObject]];
        [annotations addObject:annotation];
        [points addObject:[[[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude] autorelease]];
    }
    
    [self performSelectorOnMainThread:@selector(addAnnotations) withObject:nil waitUntilDone:NO];
    
    [pool release];
}

-(void)addAnnotations;
{
    if (points != nil && !hasParts) {
        CSRouteAnnotation* routeAnnotation = [[[CSRouteAnnotation alloc] initWithPoints:points] autorelease];
        [mapView addAnnotation:routeAnnotation];
    }
    MKCoordinateRegion region;
	CLLocationCoordinate2D max = (CLLocationCoordinate2D) {-1000, -1000};
	CLLocationCoordinate2D min = (CLLocationCoordinate2D) {1000, 1000};
    for (id<MKAnnotation> annotation in annotations) {
		CLLocationCoordinate2D crd = annotation.coordinate;
        max = (CLLocationCoordinate2D){MAX(max.latitude, crd.latitude), MAX(max.longitude, crd.longitude)};
        min = (CLLocationCoordinate2D){MIN(min.latitude, crd.latitude), MIN(min.longitude, crd.longitude)};
        [mapView addAnnotation:annotation];
    }
    if ([annotations count] == 1) {
        region = MKCoordinateRegionMake(max, MKCoordinateSpanMake(0.01, 0.01));
    } else {
        CLLocationCoordinate2D center = (CLLocationCoordinate2D) {(min.latitude + max.latitude) / 2, (min.longitude + max.longitude) / 2};
		MKCoordinateSpan span = MKCoordinateSpanMake((max.latitude - min.latitude), (max.longitude - min.longitude));
        region = MKCoordinateRegionMake(center, span);
    }
    [mapView setRegion:region animated:YES];
}

- (void)mapView:(MKMapView *)aMapView regionWillChangeAnimated:(BOOL)animated
{
    NSLog(@"Will Change %@", animated ? @"animated" : @"");
    if (journey && [annotations count] > 1) {
        regionChanging = YES;
        
        isAnimating = YES;
        [self performSelectorInBackground:@selector(launchTransformTimerFromThread) withObject:nil];
        
        UIView *viewAnnotationStart = [mapView viewForAnnotation:[annotations objectAtIndex:[annotations count] - 2]];
        UIView *viewAnnotationEnd = [mapView viewForAnnotation:[annotations lastObject]];
        
        oldDistance = viewAnnotationStart.frame.origin.x - viewAnnotationEnd.frame.origin.x;
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"Did Change %@", animated ? @"animated" : @"");
    if (journey && [annotations count] > 1) {
        regionChanging = NO;
        isAnimating = NO;
        lastScale = 1.0f;	
        
        // re-enable and re-poosition the route display.
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
        for(CSRouteView* routeView in routeViews) {
            routeView.transform = transform;
            
            [routeView regionChanged];
        }
    }
}


-(void)launchTransformTimerFromThread
{
	//this function needs tweaking, sometimes a little flickering when doubletapping.
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; 
	
	NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(timerMethod) userInfo:nil repeats:YES];
	
	NSDate *loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];
	
	while (isAnimating && [[NSRunLoop currentRunLoop] runMode: NSDefaultRunLoopMode beforeDate:loopUntil]) {
		loopUntil = [NSDate dateWithTimeIntervalSinceNow:0.1];	
    }
	
    [timer invalidate];
    
	[pool release];
}

-(void)scaleRoutes;
{		
	float scale=1.0;
	
	if (regionChanging) {	
		
        UIView *viewAnnotationStart = [mapView viewForAnnotation:[annotations objectAtIndex:[annotations count] - 2]];
        UIView *viewAnnotationEnd = [mapView viewForAnnotation:[annotations lastObject]];
		float newDistance = viewAnnotationStart.frame.origin.x - viewAnnotationEnd.frame.origin.x;
		
		scale = newDistance/oldDistance;
		
		if(scale!=1.0f && scale != lastScale){
			CGAffineTransform transform = CGAffineTransformMakeScale(scale,scale);
            
            for(CSRouteView* routeView in routeViews) {
				routeView.transform = transform;
			}
			
			lastScale = scale;
		} 
	}
}

-(void)timerMethod
{
	if(isAnimating) {
		[self scaleRoutes];
    }
}



- (MKAnnotationView *)mapView:(MKMapView *)aMapView viewForAnnotation:(id <MKAnnotation>)annotation;
{
    if (annotation == aMapView.userLocation) {
        return nil;
    } else if ([annotation isKindOfClass:[CSRouteAnnotation class]]) {
		CSRouteAnnotation* routeAnnotation = (CSRouteAnnotation*) annotation;
        
        static NSString* ReuseIdA = @"ReuseIdA";
        CSRouteView* view = (CSRouteView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:ReuseIdA];
		if (view == nil) {
	        view = [[[CSRouteView alloc] initWithAnnotation:routeAnnotation reuseIdentifier:ReuseIdA] autorelease]; 
        	view.bounds = CGRectMake(0, 0, mapView.frame.size.width, mapView.frame.size.height);
            view.mapView = mapView;
    	} else {
	        view.annotation = routeAnnotation;
        }
        [routeViews addObject:view];
        return view;
	} else {
        static NSString* ReuseIdB = @"ReuseIB";
        MKPinAnnotationView* view = (MKPinAnnotationView*)[aMapView dequeueReusableAnnotationViewWithIdentifier:ReuseIdB];
        FOPointType pointType;
        MKPinAnnotationColor pinColor = MKPinAnnotationColorPurple;
        
        if ([annotation isKindOfClass:[FOPoint class]]) {
            pointType = point.type;
        } else if ([annotation isKindOfClass:[CWJourneyAnnotation class]]) {
            CWJourneyAnnotation* journeyAnnotation = (CWJourneyAnnotation*)annotation;
            pointType = journeyAnnotation.pointType;
            pinColor = journeyAnnotation.pinColor;
        }
        
        if (view == nil) {
            view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ReuseIdB] autorelease];
            view.animatesDrop = YES;
            view.canShowCallout = YES;
        }
        
        UIImageView* iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"call_point-%d.png", pointType]]];
        view.leftCalloutAccessoryView = iconView;
        [iconView release];
        view.pinColor = pinColor;
        view.annotation = annotation;
        
        return view;
    }
}

- (void)dealloc;
{
    [routeViews release];
    [point release];
    [journey release];
    [annotations release];
    [points release];
    [super dealloc];
}


@end


@implementation CWJourneyAnnotation

@synthesize coordinate, pointType, pinColor, title, subtitle;

+(void)setupAnnotation:(CWJourneyAnnotation*)annotation withPoint:(FOPoint*)point;
{
    annotation.coordinate = point.coordinate;
    annotation.pointType = point.type;
	annotation.title = point.title;
}

+(CWJourneyAnnotation*)journeyAnnotationWithStartRouteLink:(FORouteLink*)routeLink;
{
	CWJourneyAnnotation* annotation = [[[CWJourneyAnnotation alloc] init] autorelease];
    [self setupAnnotation:annotation withPoint:routeLink.from];
    annotation.pinColor = MKPinAnnotationColorGreen;
    annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleStart", nil), [routeLink.departure localizedShortTimeString], routeLink.line.fullName];
    return annotation;
}

+(CWJourneyAnnotation*)journeyAnnotationWithRouteLink:(FORouteLink*)routeLink previousRouteLink:(FORouteLink*)prevRouteLink;
{
	CWJourneyAnnotation* annotation = [[[CWJourneyAnnotation alloc] init] autorelease];
    [self setupAnnotation:annotation withPoint:routeLink.from];
    annotation.pinColor = MKPinAnnotationColorRed;
    annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleStart", nil), [routeLink.departure localizedShortTimeString], routeLink.line.fullName];
    //  annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleMiddle", nil), [prevRouteLink.arrival localizedShortTimeString], prevRouteLink.line.fullName, [routeLink.actualDeparture localizedShortTimeString], routeLink.line.fullName];
    return annotation;
}

+(CWJourneyAnnotation*)journeyAnnotationWithEndRouteLink:(FORouteLink*)routeLink;
{
	CWJourneyAnnotation* annotation = [[[CWJourneyAnnotation alloc] init] autorelease];
    [self setupAnnotation:annotation withPoint:routeLink.to];
    annotation.pinColor = MKPinAnnotationColorRed;
    annotation.subtitle = [NSString stringWithFormat:NSLocalizedString(@"SubtitleEnd", nil), [routeLink.arrival localizedShortTimeString], routeLink.line.fullName];
    return annotation;
}


@end


