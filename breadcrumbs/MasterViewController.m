//
//  MasterViewController.m
//  breadcrumbs
//
//  Created by Mykola Savula on 2/6/15.
//  Copyright (c) 2015 Maliwan. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"

#import "MWBreadcrumbView.h"


@interface MasterViewController () <MWBreadcrumbViewDelegate>

@property NSMutableArray *objects;

@property (nonatomic, strong) NSDictionary *selectedSection;
@property (nonatomic, strong) MWBreadcrumbView *breadcrumbView;

@end

@implementation MasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.clearsSelectionOnViewWillAppear = NO;
    self.preferredContentSize = CGSizeMake(320.0, 600.0);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.objects = [[NSMutableArray alloc] init];
    
    [self.objects addObject:@{@"Books":
                                  @[@{@"Arts & Photography" :
                                          @[@{@"Architecture" :
                                                  @[@{@"Buildings" : @[@"Landmarks & Monuments",
                                                                       @"Religious Buildings",
                                                                       @"Residential"]},
                                                @"Criticism",
                                                @"Decoration & Omament",
                                                @"History",
                                                @"Landscape",
                                                @"Urban & Land Use Planning"]},
                                            @"Business of Art",
                                            @"Drawing",
                                            @"Fashion",
                                            @"Music",
                                            @"Sculpture",
                                            @"Painting",
                                            @"Religious"]},
                                    @{@"Cookbooks, Food & Wine" :
                                          @[@{@"Asian Cooking" : @[@"Chinese",
                                                                   @"Indian",
                                                                   @"Japanese",
                                                                   @"Pacific Rim",
                                                                   @"Thai",
                                                                   @"Vietnamese",
                                                                   @"Wok Cookery"],},
                                            @{@"Baking" : @[@"Bread",
                                                            @"Cakes",
                                                            @"Cookies",
                                                            @"Biscuits, Muffins & Scones",
                                                            @"Pastry",
                                                            @"Pies",
                                                            @"Pizza"]},
                                            @{@"Beverages & Wine" : @[@"Beer",
                                                                      @"Cocktails & Mixed Drinks",
                                                                      @"Coffe & Tea",
                                                                      @"Homebrewing, Distilling & Wine Making",
                                                                      @"Juice",
                                                                      @"Smoothies",
                                                                      @"Wine & Spirits"]},
                                            @"Italian Cooking"]} ]}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"])
    {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        NSArray *values = self.selectedSection == nil ? self.objects : self.selectedSection[[self.selectedSection allKeys][0]];
        id object = values[indexPath.row];
        
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        
        if ([object isKindOfClass:[NSDictionary class]] && [[(NSDictionary *)object allKeys] count] == 1)
        {
            // we should add crumb for dictionary key and reload table
            [self.breadcrumbView addSection:[(NSDictionary *)object allKeys][0]];
            self.selectedSection = object;
            
            [controller setDetailItem:[(NSDictionary *)object allKeys][0]];
        }
        else if ([object isKindOfClass:[NSString class]])
        {
            [controller setDetailItem:object];
        }
        
        [self.tableView reloadData];
        
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.breadcrumbView == nil)
    {
        self.breadcrumbView = (MWBreadcrumbView *)[[[NSBundle mainBundle] loadNibNamed:@"MWBreadcrumbView" owner:self options:nil] lastObject];
        self.breadcrumbView.delegate = self;
    }
    
    return self.breadcrumbView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.selectedSection == nil ? self.objects.count : [self.selectedSection[[self.selectedSection allKeys][0]] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSArray *values = self.selectedSection == nil ? self.objects : self.selectedSection[[self.selectedSection allKeys][0]];
    
    id object = values[indexPath.row];
    NSString *title = @"error";
    
    if ([object isKindOfClass:[NSString class]])
    {
        title = object;
    }
    else if ([object isKindOfClass:[NSDictionary class]] && [[(NSDictionary *)object allKeys] count] == 1)
    {
        title = [(NSDictionary *)object allKeys][0];
    }
    
    cell.textLabel.text = title;
    
    return cell;
}

#pragma mark - Breadcrumb View Delegate

- (void)breadcrumbViewDidSelectRoot:(MWBreadcrumbView *)breadcrumbView
{
    self.selectedSection = nil;
    [self.tableView reloadData];
}

- (void)breadcrumbView:(MWBreadcrumbView *)breadcrumbView didSelectSection:(NSString *)section
{
    // now we should traverse our tree to get new current section and update table
    // we'll use recursive iteration
    
    NSDictionary *newCurrentSection = nil;
    
    for (id object in self.objects)
    {
        if ([object isKindOfClass:[NSDictionary class]])
        {
            newCurrentSection = [self sectionWithName:section inNode:object];
        }
        
        if (newCurrentSection != nil)
        {
            break;
        }
    }
    
    if (newCurrentSection != nil)
    {
        self.selectedSection = newCurrentSection;
        [self.tableView reloadData];
    }
    else
    {
        // something went terrebly wrong, trying to restore
        self.selectedSection = nil;
        [self.tableView reloadData];
    }
}

- (NSDictionary *)sectionWithName:(NSString *)sectionName inNode:(NSDictionary *)node
{
    if ([[node allKeys][0] isEqualToString:sectionName])
    {
        return node;
    }
    else
    {
        for (id object in node[[node allKeys][0]])
        {
            if ([object isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *result = [self sectionWithName:sectionName inNode:object];
                
                if (result != nil)
                {
                    return result;
                }
            }
        }
    }
    
    return nil;
}

@end
