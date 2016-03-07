//
//  main.m
//  regionagogogen
//
//  Created by AkH on 3/7/16.
//  Copyright © 2016 Nobugware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBS2Geometry.h"

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
  NSMutableArray *cl = [NSMutableArray array];

  
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
      if ([code isEqualToString:@"AF"]) {
        continue;
      }
      
      if ([code isEqualToString:@"AX"]) {
        continue;
      }
      
      if ([code isEqualToString:@"AL"]) {
        continue;
      }
      if ([code isEqualToString:@"AO"]) {
        continue;
      }
      if ([code isEqualToString:@"CV"]) {
        continue;
      }
      
      if ([code isEqualToString:@"DZ"]) {
        continue;
      }
      if ([code isEqualToString:@"CI"]) {
        continue;
      }
      if ([code isEqualToString:@"BR"]) {
        continue;
        if ([region isEqualToString:@"So Paulo"] || [region isEqualToString:@"Pernambuco"] || [region isEqualToString:@"Maranho"] || [region isEqualToString:@"Minas Gerais"] || [region isEqualToString:@"Cear"] || [region isEqualToString:@"Piau"]) {
          NSLog(@"SKIP  code %@ region %@", code, region);
        continue;
        }
      }
      // skip Gourma
      if ([code isEqualToString:@"BF"]) {
        continue;
        if ([region isEqualToString:@"Gourma"] || [region isEqualToString:@"Houet"] || [region isEqualToString:@"Kndougou"] || [region isEqualToString:@"Banwa"] || [region isEqualToString:@"Kossi"] || [region isEqualToString:@"Bal"] || [region isEqualToString:@"Mou Houn"] || [region isEqualToString:@"Oudalan"] || [region isEqualToString:@"Soum"] || [region isEqualToString:@"Nayala"] || [region isEqualToString:@"Sourou"] || [region isEqualToString:@"Bam"] || [region isEqualToString:@"Boulkiemd"] || [region isEqualToString:@"Kourwogo"] || [region isEqualToString:@"Bazga"] || [region isEqualToString:@"Kadiogo"] || [region isEqualToString:@"Oubritenga"] || [region isEqualToString:@"Passor"] || [region isEqualToString:@"Zondoma"] || [region isEqualToString:@"Sangui"] || [region isEqualToString:@"Sissili"] || [region isEqualToString:@"Ziro"] || [region isEqualToString:@"Loroum"] || [region isEqualToString:@"Yatenga"] || [region isEqualToString:@"Namentenga"] || [region isEqualToString:@"Sanmatenga"] || [region isEqualToString:@"Boulgou"] || [region isEqualToString:@"Koulplogo"] || [region isEqualToString:@"Ganzourgou"] || [region isEqualToString:@"Kouritenga"] || [region isEqualToString:@"Nahouri"] || [region isEqualToString:@"Zoundwogo"] || [region isEqualToString:@"Bougouriba"]) {
          NSLog(@"SKIP  code %@ region %@", code, region);
          continue;
        }
      }
      NSArray *coverCellIDs = [NBS2Geometry cellIdsForPolygon:tmpArray];
      if (!coverCellIDs) {
        continue;
      }
      if (!properties[@"iso_a2"]) {
        NSLog(@"can't find country code %@", feature);
        exit(2);
      }
      
      NSLog(@"cover %@", coverCellIDs);
      
      loopID++;
      
    }
    
  }
  
  return YES;
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
