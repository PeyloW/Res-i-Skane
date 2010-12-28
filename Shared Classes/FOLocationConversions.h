//
//  CWLoactionConversions.h
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-02-05.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


//! Location Coordinate Systems
typedef enum {
    FOLocationCoordinateSystemWGS84 = 0,  //! World Geodetic System, location coordinate system used by Core Location.
    FOLocationCoordinateSystemRT90 = 1    //! Swedish Grid, location coordinate system used for government Swedish maps. 
} FOLocationCoordinateSystem;

//! Projections for the RT90 coordinate system.
typedef enum {
    FOLocationCoordinateSystemParamRT90_7_5_gon_v,  //! Westmost of sweden
    FOLocationCoordinateSystemParamRT90_5_0_gon_v,
    FOLocationCoordinateSystemParamRT90_2_5_gon_v,
    FOLocationCoordinateSystemParamRT90_0_0_gon_v,  //! Central sweden
    FOLocationCoordinateSystemParamRT90_2_5_gon_o,
    FOLocationCoordinateSystemParamRT90_5_0_gon_o   //! Eastmost Sweden
} FOLocationCoordinateSystemParamRT90;

CLLocationCoordinate2D FOLocationConvertSystem(CLLocationCoordinate2D location, FOLocationCoordinateSystem from, FOLocationCoordinateSystem to, int param);