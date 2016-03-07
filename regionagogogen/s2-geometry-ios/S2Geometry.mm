//
//  S2Geometry.m
//  Ingress
//
//  Created by Alex Studnička on 28.04.13.
//  Copyright (c) 2013 A&A Code. All rights reserved.
//

#import "S2Geometry.h"

#include "s2.h"
#include "s2cellid.h"
#include "s2latlng.h"
#include "s2latlngrect.h"
#include "s2regioncoverer.h"
#include "s2cap.h"


@implementation S2Geometry

+ (NSArray <NSString*>*)cellIdsStringForNeCoord:(CLLocationCoordinate2D)neCoord swCoord:(CLLocationCoordinate2D)swCoord minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel {

	S2LatLngRect rect = S2LatLngRect(S2LatLng::FromDegrees(MIN(neCoord.latitude, swCoord.latitude), MIN(neCoord.longitude, swCoord.longitude)), S2LatLng::FromDegrees(MAX(neCoord.latitude, swCoord.latitude), MAX(neCoord.longitude, swCoord.longitude)));

    S2RegionCoverer coverer;
	coverer.set_min_level(minZoomLevel);
	coverer.set_max_level(maxZoomLevel);
  //coverer.set_max_cells(9);

	vector<S2CellId> covering;
	coverer.GetCovering(rect, &covering);

	NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];

	for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
		S2CellId cellId = *it;
		[cellsArray addObject:[NSString stringWithFormat:@"%llx", cellId.id()]];
	}

	return cellsArray;
}

+ (NSArray <NSString*>*)cellIdsStringForRadius:(double)radius aroundCoordinates:(CLLocationCoordinate2D)coordinates minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel {
  S2LatLng centerLL = S2LatLng::FromDegrees(coordinates.latitude, coordinates.longitude);
  S1Angle angle =S1Angle::Radians(radius/6371);
  S2Cap cap = S2Cap::FromAxisAngle(centerLL.ToPoint(), angle);
  
  S2RegionCoverer coverer;
  coverer.set_min_level(minZoomLevel);
  coverer.set_max_level(maxZoomLevel);
  //coverer.set_max_cells(9);
  
  vector<S2CellId> covering;
  coverer.GetCovering(cap, &covering);
  
  NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];
  
  for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
    S2CellId cellId = *it;
    [cellsArray addObject:[NSString stringWithFormat:@"%llx", cellId.id()]];
  }
  
  return cellsArray;
}

+ (CLLocationCoordinate2D)coordinateForCellId:(unsigned long long)numCellId {
	S2CellId cellId = S2CellId(numCellId);
	S2LatLng latLng = cellId.ToLatLng();
	return CLLocationCoordinate2DMake(latLng.lat().degrees(), latLng.lng().degrees());
}

+ (NSString *)cellIdStringForCoordinates:(CLLocationCoordinate2D)coordinates {
  S2CellId cellId;
  S2LatLng latLng = S2LatLng::FromDegrees(coordinates.latitude, coordinates.longitude);
  cellId.FromLatLng(latLng);
  return [NSString stringWithFormat:@"%llx", cellId.id()];
}

+ (NSArray <NSData*>*)cellIdsDataForRadius:(double)radius aroundCoordinates:(CLLocationCoordinate2D)coordinates minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel {
  S2LatLng centerLL = S2LatLng::FromDegrees(coordinates.latitude, coordinates.longitude);
  S1Angle angle =S1Angle::Radians(radius/6371);
  S2Cap cap = S2Cap::FromAxisAngle(centerLL.ToPoint(), angle);
  
  S2RegionCoverer coverer;
  coverer.set_min_level(minZoomLevel);
  coverer.set_max_level(maxZoomLevel);
  //coverer.set_max_cells(9);
  
  vector<S2CellId> covering;
  coverer.GetCovering(cap, &covering);
  
  NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];
  
  for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
    S2CellId cellIdObj = *it;
    uint64_t cellId = cellIdObj.id();
    cellId = CFSwapInt64HostToBig(cellId);
    NSData *d = [NSData dataWithBytes:&cellId length:8];
    
    [cellsArray addObject:d];
  }
  
  return cellsArray;
}

+ (NSData *)cellIdDataForCoordinates:(CLLocationCoordinate2D)coordinates {
  S2CellId cellIdObj;
  S2LatLng latLng = S2LatLng::FromDegrees(coordinates.latitude, coordinates.longitude);
  cellIdObj.FromLatLng(latLng);
  uint64_t cellId = cellIdObj.id();
  cellId = CFSwapInt64HostToBig(cellId);
  NSData *d = [NSData dataWithBytes:&cellId length:8];
  return d;
}

@end
