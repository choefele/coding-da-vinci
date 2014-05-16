//
//  MorphViewController.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 16.05.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "MorphViewController.h"

#import "BCMeshTransformView.h"

@interface MorphViewController ()

@property (nonatomic) BCMeshTransformView *transformView;

@end

@implementation MorphViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.transformView = [[BCMeshTransformView alloc] initWithFrame:self.view.bounds];
    self.transformView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.transformView];

    UIImage *image = [UIImage imageNamed:@"Berlin_vom_Kreuzberg_aus-GDR-69-56.jpg"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.transformView.contentView.bounds;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.transformView.contentView addSubview:imageView];
    
    // we don't want any shading on this one
    self.transformView.diffuseLightFactor = 0.0;
    
    [self meshBuldgeAtPoint:imageView.center];
}

- (void)meshBuldgeAtPoint:(CGPoint)point
{
    self.transformView.meshTransform = [self.class buldgeMeshTransformAtPoint:point withRadius:120.0 boundsSize:self.transformView.bounds.size];
    
}

+ (BCMeshTransform *)buldgeMeshTransformAtPoint:(CGPoint)point withRadius:(CGFloat)radius boundsSize:(CGSize)size
{
    const CGFloat Bulginess = 0.4;
    
    BCMutableMeshTransform *transform = [BCMutableMeshTransform identityMeshTransformWithNumberOfRows:36 numberOfColumns:36];
    
    CGFloat rMax = radius/size.width;
    
    CGFloat yScale = size.height/size.width;
    
    CGFloat x = point.x/size.width;
    CGFloat y = point.y/size.height;
    
    NSUInteger vertexCount = transform.vertexCount;
    
    for (int i = 0; i < vertexCount; i++) {
        BCMeshVertex v = [transform vertexAtIndex:i];
        
        CGFloat dx = v.to.x - x;
        CGFloat dy = (v.to.y - y) * yScale;
        
        CGFloat r = sqrt(dx*dx + dy*dy);
        
        if (r > rMax) {
            continue;
        }
        
        CGFloat t = r/rMax;
        
        CGFloat scale = Bulginess*(cos(t * M_PI) + 1.0);
        
        v.to.x += dx * scale;
        v.to.y += dy * scale / yScale;
        v.to.z = scale * 0.2;
        [transform replaceVertexAtIndex:i withVertex:v];
    }
    
    return transform;
}

@end
