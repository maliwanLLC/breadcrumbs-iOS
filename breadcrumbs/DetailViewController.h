//
//  DetailViewController.h
//  breadcrumbs
//
//  Created by Mykola Savula on 2/6/15.
//  Copyright (c) 2015 Maliwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end

