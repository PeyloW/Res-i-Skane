//
//  CWLoactionConversions.m
//  ResaISkane
//
//  Created by Fredrik Olsson on 2010-02-05.
//  Copyright 2010 Fredrik Olsson. All rights reserved.
//

#import "FOLocationConversions.h"

typedef struct {
    double axis; // Semi-major axis of the ellipsoid.
    double flattening; // Flattening of the ellipsoid.
    double central_meridian; // Central meridian for the projection.
    double scale; // Scale on central meridian.
    double false_northing; // Offset for origo.
    double false_easting; // Offset for origo.
} CWGaussKreuger;


static CWGaussKreuger CWGausGreugerForRT90Param(FOLocationCoordinateSystemParamRT90 param) {
    CWGaussKreuger gaussKreuger;
    gaussKreuger.axis = 6378137.0; // GRS 80.
    gaussKreuger.flattening = 1.0 / 298.257222101; // GRS 80.
    switch(param) {
        case FOLocationCoordinateSystemParamRT90_7_5_gon_v:
            gaussKreuger.central_meridian = 11.0 + 18.375 / 60.0;
            gaussKreuger.scale = 1.000006000000;
            gaussKreuger.false_northing = -667.282;
            gaussKreuger.false_easting = 1500025.141;
            break;
        case FOLocationCoordinateSystemParamRT90_5_0_gon_v:
            gaussKreuger.central_meridian = 13.0 + 33.376 / 60.0;
            gaussKreuger.scale = 1.000005800000;
            gaussKreuger.false_northing = -667.130;
            gaussKreuger.false_easting = 1500044.695;
            break;
        case FOLocationCoordinateSystemParamRT90_2_5_gon_v:
            gaussKreuger.central_meridian = 15.0 + 48.0 / 60.0 + 22.624306 / 3600.0;
            gaussKreuger.scale = 1.00000561024;
            gaussKreuger.false_northing = -667.711;
            gaussKreuger.false_easting = 1500064.274;
            break;
        case FOLocationCoordinateSystemParamRT90_0_0_gon_v:
            gaussKreuger.central_meridian = 18.0 + 3.378 / 60.0;
            gaussKreuger.scale = 1.000005400000;
            gaussKreuger.false_northing = -668.844;
            gaussKreuger.false_easting = 1500083.521;
            break;
        case FOLocationCoordinateSystemParamRT90_2_5_gon_o:
            gaussKreuger.central_meridian = 20.0 + 18.379 / 60.0;
            gaussKreuger.scale = 1.000005200000;
            gaussKreuger.false_northing = -670.706;
            gaussKreuger.false_easting = 1500102.765;
            break;
        case FOLocationCoordinateSystemParamRT90_5_0_gon_o:
            gaussKreuger.central_meridian = 22.0 + 33.380 / 60.0;
            gaussKreuger.scale = 1.000004900000;
            gaussKreuger.false_northing = -672.557;
            gaussKreuger.false_easting = 1500121.846;
            break;
    }
    return gaussKreuger;
}

#define MATH_SINH(value) (0.5 * (exp(value) - exp(-value)))
#define MATH_COSH(value) (0.5 * (exp(value) + exp(-value)))
#define MATH_ATAN(value) (0.5 * log((1.0 + value) / (1.0 - value)))

static CLLocationCoordinate2D CWConvertWGS84ToRT90(CLLocationCoordinate2D location, int param) {
    // Prepare ellipsoid-based stuff.
    CWGaussKreuger gk = CWGausGreugerForRT90Param(param);
    double e2 = gk.flattening * (2.0 - gk.flattening);
    double n = gk.flattening / (2.0 - gk.flattening);
    double a_roof = gk.axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0);
    double A = e2;
    double B = (5.0 * e2 * e2 - e2 * e2 * e2) / 6.0;
    double C = (104.0 * e2 * e2 * e2 - 45.0 * e2 * e2 * e2 * e2) / 120.0;
    double D = (1237.0 * e2 * e2 * e2 * e2) / 1260.0;
    double beta1 = n / 2.0 - 2.0 * n * n / 3.0 + 5.0 * n * n * n / 16.0 + 41.0 * n * n * n * n / 180.0;
    double beta2 = 13.0 * n * n / 48.0 - 3.0 * n * n * n / 5.0 + 557.0 * n * n * n * n / 1440.0;
    double beta3 = 61.0 * n * n * n / 240.0 - 103.0 * n * n * n * n / 140.0;
    double beta4 = 49561.0 * n * n * n * n / 161280.0;
    
    // Convert.
    double deg_to_rad = M_PI / 180.0;
    double phi = location.latitude * deg_to_rad;
    double lambda = location.longitude * deg_to_rad;
    double lambda_zero = gk.central_meridian * deg_to_rad;
    
    double phi_star = phi - sin(phi) * cos(phi) * (A +
                                                   B * pow(sin(phi), 2) +
                                                   C * pow(sin(phi), 4) +
                                                   D * pow(sin(phi), 6));
    
    double delta_lambda = lambda - lambda_zero;
    double xi_prim = atan(tan(phi_star) / cos(delta_lambda));
    double eta_prim = MATH_ATAN(cos(phi_star) * sin(delta_lambda));
    double x = gk.scale * a_roof * (xi_prim +
                                    beta1 * sin(2.0 * xi_prim) * MATH_COSH(2.0 * eta_prim) +
                                    beta2 * sin(4.0 * xi_prim) * MATH_COSH(4.0 * eta_prim) +
                                    beta3 * sin(6.0 * xi_prim) * MATH_COSH(6.0 * eta_prim) +
                                    beta4 * sin(8.0 * xi_prim) * MATH_COSH(8.0 * eta_prim)) + gk.false_northing;
    double y = gk.scale * a_roof * (eta_prim +
                                    beta1 * cos(2.0 * xi_prim) * MATH_SINH(2.0 * eta_prim) +
                                    beta2 * cos(4.0 * xi_prim) * MATH_SINH(4.0 * eta_prim) +
                                    beta3 * cos(6.0 * xi_prim) * MATH_SINH(6.0 * eta_prim) +
                                    beta4 * cos(8.0 * xi_prim) * MATH_SINH(8.0 * eta_prim)) + gk.false_easting;
    
    CLLocationCoordinate2D result;
    result.latitude = round(x * 1000.0) / 1000.0;
    result.longitude = round(y * 1000.0) / 1000.0;
    
    return result;
}

static CLLocationCoordinate2D CWConvertRT90ToWGS84(CLLocationCoordinate2D location, int param) {
    // Prepare ellipsoid-based stuff.
    CWGaussKreuger gk = CWGausGreugerForRT90Param(param);
    double e2 = gk.flattening * (2.0 - gk.flattening);
    double n = gk.flattening / (2.0 - gk.flattening);
    double a_roof = gk.axis / (1.0 + n) * (1.0 + n * n / 4.0 + n * n * n * n / 64.0);
    double delta1 = n / 2.0 - 2.0 * n * n / 3.0 + 37.0 * n * n * n / 96.0 - n * n * n * n / 360.0;
    double delta2 = n * n / 48.0 + n * n * n / 15.0 - 437.0 * n * n * n * n / 1440.0;
    double delta3 = 17.0 * n * n * n / 480.0 - 37 * n * n * n * n / 840.0;
    double delta4 = 4397.0 * n * n * n * n / 161280.0;
    
    double Astar = e2 + e2 * e2 + e2 * e2 * e2 + e2 * e2 * e2 * e2;
    double Bstar = -(7.0 * e2 * e2 + 17.0 * e2 * e2 * e2 + 30.0 * e2 * e2 * e2 * e2) / 6.0;
    double Cstar = (224.0 * e2 * e2 * e2 + 889.0 * e2 * e2 * e2 * e2) / 120.0;
    double Dstar = -(4279.0 * e2 * e2 * e2 * e2) / 1260.0;
    
    // Convert.
    double deg_to_rad = M_PI / 180;
    double lambda_zero = gk.central_meridian * deg_to_rad;
    double xi = (location.latitude - gk.false_northing) / (gk.scale * a_roof);
    double eta = (location.longitude - gk.false_easting) / (gk.scale * a_roof);
    double xi_prim = (xi -
                      delta1 * sin(2.0 * xi) * MATH_COSH(2.0 * eta) -
                      delta2 * sin(4.0 * xi) * MATH_COSH(4.0 * eta) -
                      delta3 * sin(6.0 * xi) * MATH_COSH(6.0 * eta) -
                      delta4 * sin(8.0 * xi) * MATH_COSH(8.0 * eta));
    double eta_prim = (eta -
                       delta1 * cos(2.0 * xi) * MATH_SINH(2.0 * eta) -
                       delta2 * cos(4.0 * xi) * MATH_SINH(4.0 * eta) -
                       delta3 * cos(6.0 * xi) * MATH_SINH(6.0 * eta) -
                       delta4 * cos(8.0 * xi) * MATH_SINH(8.0 * eta));
    double phi_star = asin(sin(xi_prim) / MATH_COSH(eta_prim));
    double delta_lambda = atan(MATH_SINH(eta_prim) / cos(xi_prim));
    double lon_radian = lambda_zero + delta_lambda;
    double lat_radian = (phi_star + sin(phi_star) * cos(phi_star) *
                         (Astar +
                          Bstar * pow(sin(phi_star), 2) +
                          Cstar * pow(sin(phi_star), 4) +
                          Dstar * pow(sin(phi_star), 6)));
    
    CLLocationCoordinate2D result;
    result.latitude = lat_radian * 180.0 / M_PI;
    result.longitude = lon_radian * 180.0 / M_PI;
    
    return result;
}

CLLocationCoordinate2D FOLocationConvertSystem(CLLocationCoordinate2D location, FOLocationCoordinateSystem from, FOLocationCoordinateSystem to, int param) {
    switch (from) {
        case FOLocationCoordinateSystemWGS84:
            switch(to) {
                case FOLocationCoordinateSystemWGS84:
                    return location;
                case FOLocationCoordinateSystemRT90:
                    return CWConvertWGS84ToRT90(location, param);
            }
        case FOLocationCoordinateSystemRT90:
            switch(to) {
                case FOLocationCoordinateSystemWGS84:
                    return CWConvertRT90ToWGS84(location, param);
                case FOLocationCoordinateSystemRT90:
                    return location;
            }
    }
    [NSException raise:NSInvalidArgumentException format:@""];
    return (CLLocationCoordinate2D){ 0.0, 0.0};
}