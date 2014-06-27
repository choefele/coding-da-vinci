//
//  ImageAnnotation.h
//  Coding Da Vinci
//
//  Created by Claus Höfele on 27.04.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ImageAnnotation : NSObject<MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *imageFilePath;
@property (nonatomic, copy) NSString *alternativeImageFilePath;
@property (nonatomic) NSUInteger yearConstruction;
@property (nonatomic) NSUInteger yearDemolition;

- (BOOL)isAvailableInYear:(NSUInteger)year;

@end
