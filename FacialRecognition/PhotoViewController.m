//
//  ViewController.m
//  FacialRecognition
//
//  Created by user on 6/10/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "PhotoViewController.h"
#import <CoreImage/CoreImage.h>

@interface PhotoViewController ()
            
@property (nonatomic)NSArray* photos;
@property (nonatomic)UIImageView *imageView;

@end

@implementation PhotoViewController
            
- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    self.photos = @[[UIImage imageNamed:@"linkedin_image.jpg"],[UIImage imageNamed:@"jennandme.jpg"],
                     [UIImage imageNamed:@"graduation.jpg"],[UIImage imageNamed:@"mikeandpops.jpg"]];
    
    CGRect imageFrame = self.view.frame;
    imageFrame.size = CGSizeMake(300, 300);
    float xPosition = (self.view.frame.size.width - imageFrame.size.width )/2;
    imageFrame.origin = CGPointMake(xPosition, 80.0);
    _imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    
    [self.view addSubview:_imageView];

    _imageView.image =  _photos.firstObject;
    
    [self applyFilter:@"CISepiaTone" toImage:_photos.firstObject withContextOptions:nil];
    
}


- (void)applyFilter:(NSString*)imageFilter toImage:(UIImage*)image withContextOptions:(NSDictionary*)options
{
    //render the image of the GPU
    options = @{@"kCIContextUseSoftwareRenderer":@"YES"};
    CIContext* context = [CIContext contextWithOptions:options];
    
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    CIImage* aImage = [CIImage imageWithData:data];
    
    //create the image filter
    CIFilter* filter = [CIFilter filterWithName:imageFilter];
    [filter setValue:aImage forKey:kCIInputImageKey];
    
    
    CIImage* result = [filter valueForKey:kCIOutputImageKey];
    
    CGRect extent = [result extent];
    
    //render the image to a Core Graphics image that is ready for display or saving to a file
    CGImageRef imageRef = [context createCGImage:result fromRect:extent];
    
    _imageView.image = [UIImage imageWithCGImage:imageRef];
    
}

@end
