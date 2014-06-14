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

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = self.image;
}

@end
