//
//  S2Geometry.h
//  Ingress
//
//  Created by Alex Studnička on 28.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface S2Geometry : NSObject

+ (NSArray <NSString*>*)cellIdsStringForNeCoord:(CLLocationCoordinate2D)neCoord swCoord:(CLLocationCoordinate2D)swCoord minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel;
+ (CLLocationCoordinate2D)coordinateForCellId:(unsigned long long)numCellId;
+ (NSString *)cellIdStringForCoordinates:(CLLocationCoordinate2D)coordinates;
+ (NSData *)cellIdDataForCoordinates:(CLLocationCoordinate2D)coordinates;
+ (NSArray <NSString*>*)cellIdsStringForRadius:(double)radius aroundCoordinates:(CLLocationCoordinate2D)coordinates minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel;
+ (NSArray <NSData*>*)cellIdsDataForRadius:(double)radius aroundCoordinates:(CLLocationCoordinate2D)coordinates minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel;

@end
