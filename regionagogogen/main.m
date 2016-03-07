//
//  main.m
//  regionagogogen
//
//  Created by AkH on 3/7/16.
//  Copyright © 2016 Nobugware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBS2Geometry.h"
#import "NBS2CellId.h"
#import "MPMessagePack.h"

void usage() {
  printf("regionagogogen [GEOJSONFILE]\n");
}

BOOL importGeoJSON(NSDictionary *d) {
  if (!d[@"features"]) {
    return NO;
  }
  
  if (![d[@"features"] isKindOfClass:[NSArray class]]) {
    return NO;
  }
  
  int loopID = 0;
  
  // RegionStorage
  NSMutableArray *rs = [NSMutableArray array];
  
  // CellIDLoopStorage
  NSMutableDictionary *cl = [NSMutableDictionary dictionary];

  
  NSArray *features = d[@"features"];
  for (NSDictionary *feature in features) {
    if (!feature[@"geometry"]) {
      return NO;
    }
    
    if (!feature[@"properties"]) {
      return NO;
    }
    
    NSDictionary *properties = feature[@"properties"];
    
    NSDictionary *geo = feature[@"geometry"];
    if (!geo[@"type"]) {
      return NO;
    }

    if (![geo[@"type"] isEqualToString:@"MultiPolygon"]) {
      continue;
    }
    
    if (!geo[@"coordinates"] || ![geo[@"coordinates"] isKindOfClass:[NSArray class]]) {
      return NO;
    }
    
    if (!properties[@"iso_a2"]) {
      NSLog(@"can't find country code %@", feature);
      exit(2);
    }
    NSString *code = properties[@"iso_a2"];
    
    NSString *region = properties[@"name"];
    if (!region) {
      region = properties[@"region"];
    }
    
    
    for (NSArray *multipolygons in geo[@"coordinates"]) {
      // For type "MultiPolygon", the "coordinates" member must be an array of Polygon coordinate arrays.
      // "Polygon", the "coordinates" member must be an array of LinearRing coordinate arrays. For Polygons with multiple rings, the first must be the exterior ring and any others must be interior rings or holes.
      NSArray *tmpArray = [multipolygons firstObject];
      
      NSLog(@"loopID %d, code %@ region %@", loopID, code, region);
      
      NSArray *coverCellIDs = [NBS2Geometry cellIdsForPolygon:tmpArray];
      if (!coverCellIDs) {
        continue;
      }
      
      if (!properties[@"iso_a2"]) {
        NSLog(@"can't find country code %@", feature);
        exit(2);
      }
      
      NSMutableArray *cellIdsAsInt = [NSMutableArray arrayWithCapacity:coverCellIDs.count];
      for (NBS2CellId *cell in coverCellIDs) {
        [cellIdsAsInt addObject:@([cell unsignedIntegerValue])];
        
        if (!cl[@([cell unsignedIntegerValue])]) {
          cl[@([cell unsignedIntegerValue])] = [NSMutableArray array];
        }
        
        [cl[@([cell unsignedIntegerValue])] addObject:@(loopID)];
        
      }
      
      // add the msgpack "c" to the points
      NSMutableArray *cPoint = [NSMutableArray arrayWithCapacity:tmpArray.count];
  
      // reverse the list & remove last for the Go implem
      [[[tmpArray reverseObjectEnumerator] allObjects] enumerateObjectsUsingBlock:^(NSArray *p, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == tmpArray.count -1) {
          *stop = YES;
          return;
        }
        NSDictionary *d = @{@"c": @[p[1], p[0]]};
        [cPoint addObject:d];
      }];
      
      [rs addObject:@{@"n": region, @"i": code, @"p": cPoint, @"c": cellIdsAsInt}];
      
      loopID++;
      
    }
    
    
  }
  
  NSMutableArray *clstorage = [NSMutableArray array];
  [cl enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
    [clstorage addObject:@{@"c": key, @"l": obj}];
  }];
  
  NSDictionary *dstore = @{@"rs": rs, @"cl": clstorage};
  NSData *data = [dstore mp_messagePack];
  
  return [data writeToFile:@"geodata" atomically:YES];
}

int main(int argc, const char * argv[]) {
  @autoreleasepool {
      // insert code here...
    if (argc != 2) {
      usage();
      exit(2);
    }
    
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:[NSString stringWithUTF8String:argv[1]]];
    if (data == nil) {
      usage();
      exit(2);
    }
    
    NSError *err = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
    
    if (err != nil) {
      NSLog(@"%@", [err localizedDescription]);
      exit(2);
    }
    
    if (!importGeoJSON(result)) {
      NSLog(@"Can't import file");
      exit(2);
    }
    
  }
    return 0;
}
