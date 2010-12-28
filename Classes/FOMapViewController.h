//
//  CWMapViewController.h
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-02-05.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "FOModel.h"
#import "CSRouteView.h"

@interface FOMapViewController : UIViewController <MKMapViewDelegate> {
@private
    IBOutlet MKMapView* mapView;
    FOPoint* point;
    FOJourney* journey;
	NSMutableArray* annotations;
    NSMutableArray* points;
    NSMutableSet* routeViews;
    BOOL hasParts;
    
	float oldDistance;
	float lastScale;
	BOOL isAnimating;
	BOOL regionChanging;
    
}

-(id)initWithPoint:(FOPoint*)point;

-(id)initWithJourney:(FOJourney*)journey;

-(IBAction)targetSwap:(UIButton*)sender;

@end
