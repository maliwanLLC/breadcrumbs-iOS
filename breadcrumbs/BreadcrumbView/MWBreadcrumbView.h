//
//  MWBreadcrumbView.h
//  Maliwan
//
//  Created by msavula on 2/20/14.
//  Copyright (c) 2014 Maliwan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MWBreadcrumbView;

@protocol MWBreadcrumbViewDelegate <NSObject>

// delegate should reset the content to the list of parent departments
- (void)breadcrumbViewDidSelectRoot:(MWBreadcrumbView *)breadcrumbView;
// delegate should update the content with the sub departments of selected department
- (void)breadcrumbView:(MWBreadcrumbView *)breadcrumbView didSelectSection:(NSString *)section;

@end

@interface MWBreadcrumbView : UIView

// adds the section as tail
- (void)addSection:(NSString *)section;
// removes all sections
- (void)popToRoot;

// the breadcrumb view delegate
@property (nonatomic, weak) id<MWBreadcrumbViewDelegate> delegate;

@end
