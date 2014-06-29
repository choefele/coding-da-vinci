//
//  ImageViewController.m
//  Coding Da Vinci
//
//  Created by Claus Höfele on 14.06.14.
//  Copyright (c) 2014 Claus Höfele. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *targetImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraint;
@property (weak, nonatomic) IBOutlet UIView *interactionView;

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = self.image;
    self.targetImageView.image = self.targetImage;
    
    if (self.targetImage) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        [self.interactionView addGestureRecognizer:panGestureRecognizer];

        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        longPressGestureRecognizer.minimumPressDuration = 0.001;
        [self.interactionView addGestureRecognizer:longPressGestureRecognizer];
    } else {
        [self.targetImageView.superview removeFromSuperview];
    }
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.imageView];
    CGFloat constant = 640 - point.x - 10;
    self.constraint.constant = MAX(MIN(constant, 630), 0);
}

@end
