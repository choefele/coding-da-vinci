//
//  ImageAnnotationView.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 27.04.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "ImageAnnotationView.h"

static CGFloat SIZE = 50;

@implementation ImageAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    UIGraphicsBeginImageContext(CGSizeMake(SIZE, SIZE));
    [image drawInRect:CGRectMake(0, 0, SIZE, SIZE)];
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [super setImage:thumbnailImage];
}

@end
