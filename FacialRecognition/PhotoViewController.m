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
            
- (void)viewDidLoad
{
    
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
    [self findFaces:_photos.firstObject];
    
}


- (void)applyFilter:(NSString*)imageFilter toImage:(UIImage*)image withContextOptions:(NSDictionary*)options
{
    //render the image on the GPU
    options = @{@"kCIContextUseSoftwareRenderer":@"YES"};
    
    //create a context for the image. This can be CPU or GPU depending upon performance requirement such as real-time processing
    CIContext* context = [CIContext contextWithOptions:options];
    
    //convert the UIImage to NSData for creating a CIImage
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    CIImage* aImage = [CIImage imageWithData:data];
    
    //create the image filter and set values
    CIFilter* filter = [CIFilter filterWithName:imageFilter];
    [filter setValue:aImage forKey:kCIInputImageKey];
    
    //get the resulting image of the applied filter
    CIImage* result = [filter valueForKey:kCIOutputImageKey];
    
    //get the extent
    CGRect extent = [result extent];
    
    //render the image to a Core Graphics image that is ready for display or saving to a file
    CGImageRef imageRef = [context createCGImage:result fromRect:extent];
    
    _imageView.image = [UIImage imageWithCGImage:imageRef];
    
}

- (NSArray*)findFaces:(UIImage*)image
{
    //convert the UIImage to NSData for creating a CIImage
    //Note: the face detector will only work in CIImage types
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    CIImage* aImage = [CIImage imageWithData:data];
    
    
    //create the context for image processing
    CIContext *context = [CIContext contextWithOptions:nil];
    
    //set the options
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };
    
    //create a detector for human faces, the only type of detector you can create is one for human faces
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];

    //in order to find the faces, we need to tell the detector the orientation of the image, this can be obtained from the image's properties using the key Orientation
    opts = @{ CIDetectorImageOrientation :
                  [[aImage properties] valueForKey:@"Orientation"] };
    
    //Use the detector to find the features (i.e. faces in the image). There will be an entry for each face.
    NSArray *features = [detector featuresInImage:aImage options:opts];
    return features;
}


- (void)getFeaturesFromFace:(NSArray*)features
{
    //features is an array of type CIFeature return from the detector object
    
    for (CIFaceFeature *f in features)
    {
        //NSLog(NSStringFromRect(f.bounds));
        
        if (f.hasLeftEyePosition)
        {
            NSLog(@"Left eye %g %g", f.leftEyePosition.x, f.leftEyePosition.y);
        }
        
        if (f.hasRightEyePosition)
        {
            NSLog(@"Right eye %g %g", f.rightEyePosition.x, f.rightEyePosition.y);
        }
        
        if (f.hasMouthPosition)
        {
            NSLog(@"Mouth %g %g", f.mouthPosition.x, f.mouthPosition.y);
        }
    }
}

@end
