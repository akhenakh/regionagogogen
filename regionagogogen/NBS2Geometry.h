//
//  NBS2Geometry.h
//  MyAPRS
//
//  Created by AkH on 2/4/16.
//  Copyright © 2016 Nobugware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class NBS2CellId;

@interface NBS2Geometry : NSObject

// radius is in kilometers, stop using your stupid units
+ (NSArray <NBS2CellId *>*)cellIdsForRadius:(double)radius aroundCoordinate:(CLLocationCoordinate2D)coordinates minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel;
+ (NSArray <NBS2CellId *>*)cellIdsForNeCoordinate:(CLLocationCoordinate2D)neCoord swCoordinate:(CLLocationCoordinate2D)swCoord minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel;

+ (NSArray <NBS2CellId *>*)cellIdsForPolygon:(NSArray *)polygon;

@end
