//
//  NBS2CellId.mm
//  MyAPRS
//
//  Created by AkH on 2/4/16.
//  Copyright © 2016 Nobugware. All rights reserved.
//

#import "NBS2CellId.h"
#include "s2.h"
#include "s2cellid.h"
#include "s2latlng.h"

@interface NBS2CellId () {
  S2CellId cell;
}

@end

@implementation NBS2CellId {
  
}

- (instancetype)initWithCellId:(uint64_t)cellId {
  self = [super init];
  if (self) {
    cell = S2CellId(cellId);
  }
  return self;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  self = [super init];
  if (self) {
    S2LatLng latLng = S2LatLng::FromDegrees(coordinate.latitude, coordinate.longitude);
    cell = S2CellId::FromLatLng(latLng);
  }
  return self;
}

+ (instancetype)cellWithId:(uint64_t)cellId {
  return [[NBS2CellId alloc] initWithCellId:cellId];
}

+ (instancetype)cellIdForCoordinate:(CLLocationCoordinate2D)coordinate {
  return [[NBS2CellId alloc] initWithCoordinate:coordinate];
}

- (instancetype)rangeMin {
  S2CellId min = cell.range_min();
  NBS2CellId *c = [[NBS2CellId alloc] initWithCellId:min.id()];
  return c;
}

- (instancetype)rangeMax {
  S2CellId max = cell.range_max();
  NBS2CellId *c = [[NBS2CellId alloc] initWithCellId:max.id()];
  return c;
}

- (CLLocationCoordinate2D)coordinate {
  S2LatLng latLng = cell.ToLatLng();
  return CLLocationCoordinate2DMake(latLng.lat().degrees(), latLng.lng().degrees());
}

- (NSData *)data {
  uint64_t cellId = cell.id();
  cellId = CFSwapInt64HostToBig(cellId);
  return [NSData dataWithBytes:&cellId length:8];
}

- (NSString *) description {
  CLLocationCoordinate2D coordinate = [self coordinate];
  return [NSString stringWithFormat:@"%llx level:%d lat: %f lng: %f",cell.id(), cell.level(), coordinate.latitude, coordinate.longitude];

}

@end
