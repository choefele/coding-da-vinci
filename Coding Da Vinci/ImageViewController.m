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
    
    SEL selector;
    if (self.targetImage) {
        selector = @selector(handleGestureSwipe:);
        self.targetImageView.image = self.targetImage;
    } else if (self.morphImageFilePath) {
        selector = @selector(handleGestureMorph:);
        [self.targetImageView.superview removeFromSuperview];
    } else {
        selector = NULL;
        [self.targetImageView.superview removeFromSuperview];
    }
    
    if (selector) {
        UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:selector];
        [self.interactionView addGestureRecognizer:panGestureRecognizer];

        UILongPressGestureRecognizer *longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:selector];
        longPressGestureRecognizer.minimumPressDuration = 0.001;
        [self.interactionView addGestureRecognizer:longPressGestureRecognizer];
    }
}

- (void)handleGestureSwipe:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.imageView];
    CGFloat constant = 640 - point.x - 10;
    self.constraint.constant = MAX(MIN(constant, 630), 0);
}

- (void)handleGestureMorph:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self.imageView];
    CGFloat progress = point.x / self.imageView.frame.size.width;
    progress = progress * 15;
    progress = MAX(MIN(progress, 14.99), 1);
    progress = ceil(progress);

    NSString *imageFilePath = [NSString stringWithFormat:self.morphImageFilePath, progress];
    UIImage *image = [UIImage imageNamed:imageFilePath];
    self.imageView.image = image;
}

@end
