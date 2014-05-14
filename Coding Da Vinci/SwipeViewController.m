//
//  SwipeViewController.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 14.05.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "SwipeViewController.h"

#import <CoreImage/CoreImage.h>

@interface SwipeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic) CIContext *contextCI;
@property (nonatomic) UIImage *inputImage;
@property (nonatomic) UIImage *targetImage;
@property (nonatomic, getter = isInProgress) BOOL inProgress;

@end

@implementation SwipeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contextCI = [CIContext contextWithOptions:nil];
    self.inputImage = [UIImage imageNamed:@"osterdeich-bremen.jpg"];
    self.targetImage = [UIImage imageNamed:@"osterdeich-bremen-strandpromenade.jpg"];
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.imageView addGestureRecognizer:panGestureRecognizer];
    self.imageView.userInteractionEnabled = YES;
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGestureRecognizer
{
    CGPoint point = [panGestureRecognizer locationInView:self.imageView];
    double progress = point.x / self.imageView.bounds.size.width;
    
    if (self.isInProgress == NO) {
        self.inProgress = YES;
        [self createFilteredImageForInputImage:self.inputImage targetImage:self.targetImage progress:progress completionBlock:^(UIImage *image) {
            self.imageView.image = image;
            self.inProgress = NO;
        }];
    }
}

+ (CIFilter *)filterWithInputImage:(UIImage *)inputImage targetImage:(UIImage *)targetImage
{
    CIImage *inputImageCI = [CIImage imageWithCGImage:inputImage.CGImage];
    CIImage *targetImageCI = [CIImage imageWithCGImage:targetImage.CGImage];
    CIFilter *filter = [CIFilter filterWithName:@"CISwipeTransition" keysAndValues:kCIInputImageKey, inputImageCI, kCIInputTargetImageKey, targetImageCI, nil];

    [filter setValue:@0 forKey:@"inputWidth"];
    CIVector *inputExtent = [CIVector vectorWithCGRect:CGRectMake(0, 0, targetImage.size.width, targetImage.size.height)];
    [filter setValue:inputExtent forKey:@"inputExtent"];
    
    return filter;
}

- (void)createFilteredImageForInputImage:(UIImage *)inputImage targetImage:(UIImage *)targetImage progress:(double)progress completionBlock:(void (^)(UIImage *image))completionBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CIFilter *filter = [self.class filterWithInputImage:inputImage targetImage:targetImage];
        [filter setValue:@(progress) forKey:@"inputTime"];

        CIImage *outputImage = [filter outputImage];
        CGImageRef outputImageCG = [self.contextCI createCGImage:outputImage fromRect:outputImage.extent];
        UIImage *newImage = [UIImage imageWithCGImage:outputImageCG];
        CGImageRelease(outputImageCG);
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(newImage);
            });
        }
    });
}

@end
