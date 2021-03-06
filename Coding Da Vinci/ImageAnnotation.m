//
//  ImageAnnotation.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 27.04.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "ImageAnnotation.h"

@implementation ImageAnnotation

- (BOOL)isAvailableInYear:(NSUInteger)year
{
    return (year > self.yearConstruction) && (year < self.yearDemolition);
}

@end
