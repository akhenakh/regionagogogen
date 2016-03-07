//
//  NBS2Geometry.mm
//  MyAPRS
//
//  Created by AkH on 2/4/16.
//  Copyright © 2016 Nobugware. All rights reserved.
//

#import "NBS2Geometry.h"
#import "NBS2CellId.h"
#include "s2.h"
#include "s2cellid.h"
#include "s2latlng.h"
#include "s2latlngrect.h"
#include "s2regioncoverer.h"
#include "s2cap.h"
#include "s2polygonbuilder.h"
#include "s2polygon.h"


@implementation NBS2Geometry

+ (NSArray <NBS2CellId *>*)cellIdsForRadius:(double)radius aroundCoordinate:(CLLocationCoordinate2D)coordinates minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel {
  S2LatLng centerLL = S2LatLng::FromDegrees(coordinates.latitude, coordinates.longitude);
  S1Angle angle =S1Angle::Radians(radius/6371);
  S2Cap cap = S2Cap::FromAxisAngle(centerLL.ToPoint(), angle);
  
  S2RegionCoverer coverer;
  coverer.set_min_level(minZoomLevel);
  coverer.set_max_level(maxZoomLevel);
  
  vector<S2CellId> covering;
  coverer.GetCovering(cap, &covering);
  
  NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];
  
  for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
    S2CellId cellIdObj = *it;
    [cellsArray addObject:[NBS2CellId cellWithId:cellIdObj.id()]];
  }
  
  return cellsArray;
}

+ (NSArray <NBS2CellId *>*)cellIdsForNeCoordinate:(CLLocationCoordinate2D)neCoord swCoordinate:(CLLocationCoordinate2D)swCoord minZoomLevel:(int)minZoomLevel maxZoomLevel:(int)maxZoomLevel {
  
  S2LatLngRect rect = S2LatLngRect(S2LatLng::FromDegrees(MIN(neCoord.latitude, swCoord.latitude), MIN(neCoord.longitude, swCoord.longitude)), S2LatLng::FromDegrees(MAX(neCoord.latitude, swCoord.latitude), MAX(neCoord.longitude, swCoord.longitude)));
  
  S2RegionCoverer coverer;
  coverer.set_min_level(minZoomLevel);
  coverer.set_max_level(maxZoomLevel);
  
  vector<S2CellId> covering;
  coverer.GetCovering(rect, &covering);
  
  NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];
  
  for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
    S2CellId cellIdObj = *it;
    [cellsArray addObject:[NBS2CellId cellWithId:cellIdObj.id()]];
  }
  
  return cellsArray;
}

+ (NSArray <NBS2CellId *>*)cellIdsForPolygon:(NSArray *)polygonArray {
  vector<S2Point> points;
  vector<S2Point>::iterator it;
  
  scoped_ptr<S2PolygonBuilder> builder(new S2PolygonBuilder(S2PolygonBuilderOptions::DIRECTED_XOR()));
  
  // do not take the last point (same as the first)
  for (int i=0; i<[polygonArray count]-1;i++) {
    NSArray *coordinate = polygonArray[i];
    it = points.begin();
    S2LatLng ll = S2LatLng::FromDegrees([coordinate[1] doubleValue], [coordinate[0] doubleValue]);
    if (ll.is_valid()) {
      S2Point point = ll.ToPoint();
      it = points.insert(it , point);
    }
  }
  
  if (points.size() < 3) {
    return nil;
  }
  
  for (int i = 0; i < points.size(); i++) {
    builder->AddEdge(
                     points[i],
                     points[(i + 1) % points.size()]);
  }

  S2Polygon polygon;
  typedef vector<pair<S2Point, S2Point> > EdgeList;
  EdgeList edgeList;
  builder->AssemblePolygon(&polygon, &edgeList);
  
  S2RegionCoverer coverer;
  coverer.set_min_level(1);
  coverer.set_max_level(30);
  coverer.set_max_cells(8);
  
  vector<S2CellId> covering;
  coverer.GetCovering(polygon, &covering);
  
  NSMutableArray *cellsArray = [NSMutableArray arrayWithCapacity:covering.size()];
  
  for(std::vector<S2CellId>::iterator it = covering.begin(); it != covering.end(); ++it) {
    S2CellId cellIdObj = *it;
    [cellsArray addObject:[NBS2CellId cellWithId:cellIdObj.id()]];
  }
  
  return cellsArray;
}

@end
