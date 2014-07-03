//
//  ViewController.m
//  FacialRecognition
//
//  Created by user on 6/10/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "PhotoViewController.h"
#import <CoreImage/CoreImage.h>
#import "FilterViewController.h"
#import "PhotoViewCell.h"

@interface PhotoViewController ()< UICollectionViewDelegate, UICollectionViewDataSource >
            
@property (nonatomic)NSArray* photos;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic)NSDictionary* selectedFilters;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end

@implementation PhotoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        //Background Thread
        [self loadPhotos];
        
        dispatch_async(dispatch_get_main_queue(), ^(void){
            
            //Run UI Updates
            [self.collectionView reloadData];
            self.imageView.image =  self.photos.firstObject;
            
            dispatch_async(dispatch_get_main_queue(), ^(void){
                //Run UI Updates
                [self findFaces:self.imageView.image];
            });
        });
        
    });
}

/*
 *
 */
-(void)loadPhotos
{
    NSArray* images =  @[[UIImage imageNamed:@"linkedin_image.jpg"],[UIImage imageNamed:@"jennandme.jpg"],
                       [UIImage imageNamed:@"graduation.jpg"],[UIImage imageNamed:@"mikeandpops.jpg"]];
    
    NSMutableArray* resizedImages = [NSMutableArray new];
    
    for (UIImage* image in images)
    {
        [resizedImages addObject:[self resizeImage:image withWidth:150.0 andHeight:150.0]];
    }
    
    self.photos = [NSArray arrayWithArray:resizedImages];
}

/**
 *Resize an image taken with the camera for uploading to Parse.com
 *@param float New width for the resized image
 *@param float New height for the resized image
 *@return UIImage Resized image
 */
-(UIImage *)resizeImage:(UIImage *)image withWidth:(float)width andHeight:(float)height
{
    UIImage *resizedImage = nil;
    
    //get the new size for the image
    CGSize newSize = CGSizeMake(width, height);
    
    //create a rectangle based on the new size
    CGRect rectangle = CGRectMake(0, 0, newSize.width, newSize.height);
    
    //create a bitmap content for the resized image
    UIGraphicsBeginImageContext(newSize);
    
    //redraw the image in the new rectangle
    [image drawInRect:rectangle];
    
    //assign the new image to resize image variable
    resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //end the image context
    UIGraphicsEndImageContext();
    
    return resizedImage;
}


#pragma mark - UICollectionViewDelegate Methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}


- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIdentifier = @"photoCellId";
    
    //load the nib file and register the cell with the collection view
    UINib *cellNib = [UINib nibWithNibName:@"PhotoCollectionViewCell" bundle:nil];
    [self.collectionView registerNib:cellNib forCellWithReuseIdentifier:cellIdentifier];
    
    PhotoViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    
    if (!cell)
    {
        cell = [[PhotoViewCell alloc]init];
    }
    
    cell.backgroundColor = [UIColor redColor];
    cell.imageView.image = self.photos[indexPath.row];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self removeSubviewsFromImageView];
    self.imageView.image = self.photos[indexPath.row];
    [self findFaces:self.imageView.image];
}

- (void)removeSubviewsFromImageView
{
    for (UIView* view in self.imageView.subviews)
    {
        [view removeFromSuperview];
    }
}

#pragma mark - IBAction Methods

/*
 *
 */
- (IBAction)onShowFiltersPressed:(UIBarButtonItem *)sender
{
    FilterViewController* fvc = [[FilterViewController alloc]init];
    fvc.delegate = (id)self;
    [self presentViewController:fvc animated:YES completion:nil];
}

#pragma mark - FilterRelated Methods

/*
 * delegate method to get filter selected by user
 */
- (void)selectedFilter:(NSDictionary*)filters
{
    self.selectedFilters = filters;
    
    dispatch_async(dispatch_get_main_queue(), ^{
         [self applyFilter:self.selectedFilters toImage:self.imageView.image withContextOptions:nil];
    });
}


/*
 *
 */
- (void)applyFilter:(NSDictionary*)imageFilters toImage:(UIImage*)image withContextOptions:(NSDictionary*)options
{
    //render the image on the GPU
    options = @{@"kCIContextUseSoftwareRenderer":@"YES"};
    
    //create a context for the image. This can be CPU or GPU depending upon performance requirement such as real-time processing
    CIContext* context = [CIContext contextWithOptions:options];
    
    //convert the UIImage to NSData for creating a CIImage
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    CIImage* aImage = [CIImage imageWithData:data];
    
    //create the image filter and set values
    CIFilter* filter = nil;
    
    CIImage* result = aImage;

    NSArray* filters = [self.selectedFilters allValues];
    
    for (NSString* afilter in filters)
    {
        //create the filter
        filter = [CIFilter filterWithName:afilter];
        
        //apply the filter (using only default values)
        [filter setValue:result forKey:kCIInputImageKey];
        
        //get the resulting image of the applied filter
        result = [filter valueForKey:kCIOutputImageKey];
    }
    
    //get the extent
    CGRect extent = [result extent];
    
    //render the image to a Core Graphics image that is ready for display or saving to a file
    CGImageRef imageRef = [context createCGImage:result fromRect:extent];
    
    self.imageView.image = [UIImage imageWithCGImage:imageRef];
}



/*
 *
 */
- (void)findFaces:(UIImage*)image
{
    //convert the UIImage to NSData for creating a CIImage
    //Note: the face detector will only work in CIImage types
    NSData* data = UIImageJPEGRepresentation(image, 1.0);
    
    CIImage* aImage = [CIImage imageWithData:data];
    
    CGRect extent = [aImage extent];
    NSLog(@"extent %f %f",extent.size.width, extent.size.height);
    
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
    NSArray *foundFaces = [detector featuresInImage:aImage options:opts];
    
    for (CIFaceFeature *feature in foundFaces)
    {
        //the face origin an size within the image
        CGRect rect = feature.bounds;
        
        [self addRectangleFromCGRect:feature.bounds scale:extent toView:self.imageView withColor:[UIColor yellowColor]];
        
        NSLog(@"face bounds: %@", NSStringFromCGRect(rect));
        
        if (feature.hasLeftEyePosition)
        {
            //NSLog(@"Left eye %g %g", feature.leftEyePosition.x, feature.leftEyePosition.y);
        }
        
        if (feature.hasRightEyePosition)
        {
            //NSLog(@"Right eye %g %g", feature.rightEyePosition.x, feature.rightEyePosition.y);
        }
        
        if (feature.hasMouthPosition)
        {
            //NSLog(@"Mouth %g %g", feature.mouthPosition.x, feature.mouthPosition.y);
        }
    }

}


#pragma mark - Helper Methods

/**
 *  Adds a rectangle-view to the passed view
 *  @param rect  the dimensions and position of the new rectangle
 *  @param view  the parent-view
 *  @param color the color of the rectangle (will have an alpha-value of 0.3)
 */
- (void)addRectangleFromCGRect:(CGRect)rect scale:(CGRect)scale toView:(UIView *)view withColor:(UIColor *) color
{
    //create a scale transform,
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0, -1.0);
    
    //create a translation based on transform (scale in this case) with no movement on x (x = 0) and a movement of the y value by the height of the image view
    CGAffineTransform transformToUIKit = CGAffineTransformTranslate(transform, 0, -self.imageView.image.size.height);
    
    CGRect translatedRect = CGRectApplyAffineTransform(rect, transformToUIKit);
    
    UIView * newView = [[UIView alloc] initWithFrame:translatedRect];
    NSLog(@"view frame %f %f", newView.frame.origin.x, newView.frame.origin.y);
    newView.layer.cornerRadius = 10;
    newView.alpha = 0.3;
    newView.backgroundColor = color;
    [view addSubview:newView];
}

@end
