//
//  NBS2CellId.h
//  MyAPRS
//
//  Created by AkH on 2/4/16.
//  Copyright © 2016 Nobugware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface NBS2CellId : NSObject

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (instancetype)initWithCellId:(uint64_t)cellId;
- (CLLocationCoordinate2D)coordinate;
- (instancetype)rangeMin;
- (instancetype)rangeMax;

// return big endian uint64 data representation
- (NSData *)data;

+ (instancetype)cellWithId:(uint64_t)cellId;
+ (instancetype)cellIdForCoordinate:(CLLocationCoordinate2D)coordinate;

@end
