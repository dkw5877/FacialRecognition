//
//  FilterViewController.m
//  FacialRecognition
//
//  Created by user on 6/16/14.
//  Copyright (c) 2014 someCompanyNameHere. All rights reserved.
//

#import "FilterViewController.h"

@interface FilterViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSDictionary* availableFilters;

@end

@implementation FilterViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self loadAvailableFitlers];
    
}

- (void)loadAvailableFitlers
{
    //get a list of all filters available in the system
    
    //NSArray* filters = [CIFilter filterNamesInCategory:kCICategoryDistortionEffect];
    self.availableFilters = @{@"kCICategoryDistortionEffect":[CIFilter filterNamesInCategory:kCICategoryDistortionEffect],
                              @"kCICategoryColorEffect":[CIFilter filterNamesInCategory:kCICategoryColorEffect],
                              @"kCICategoryStylize":[CIFilter filterNamesInCategory:kCICategoryStylize],
                              @"kCICategoryBuiltIn":[CIFilter filterNamesInCategory:kCICategoryBuiltIn]};
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.availableFilters.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionValues = [self.availableFilters allValues];
    return [sectionValues[section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  
    NSArray *sectionKeys = [self.availableFilters allKeys];
    NSString *title = sectionKeys[section];
    return title;
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* cellIndentifier = @"filterCellId";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    
    NSNumber *sectionKey = [self.availableFilters allKeys][indexPath.section];
    
    if(!cell)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIndentifier];
    }
    
    cell.textLabel.text = self.availableFilters[sectionKey][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSNumber *sectionKey = [self.availableFilters allKeys][indexPath.section];
    [self.delegate selectedFilter:self.availableFilters[sectionKey][indexPath.row]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


@end
