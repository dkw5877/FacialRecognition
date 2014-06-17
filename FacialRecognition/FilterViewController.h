//
//  FilterViewController.h
//  FacialRecognition
//
//  Created by user on 6/16/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FilterPhotoDelegate;

@interface FilterViewController : UIViewController

@property id <FilterPhotoDelegate> delegate;

@end

@protocol FilterPhotoDelegate

@optional

- (void)selectedFilter:(NSString*)filter;

@end

