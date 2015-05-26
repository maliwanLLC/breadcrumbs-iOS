//
//  MWBreadcrumbView.m
//  Maliwan
//
//  Created by msavula on 2/20/14.
//  Copyright (c) 2014 Maliwan. All rights reserved.
//

#import "MWBreadcrumbView.h"

@interface MWScrollView : UIScrollView

@end

@implementation MWScrollView

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    UITouch *touch = [touches anyObject];
    
    if(touch.phase == UITouchPhaseMoved)
    {
        return NO;
    }
    else
    {
        return [super touchesShouldBegin:touches withEvent:event inContentView:view];
    }
}

@end

@interface MWBreadcrumbView ()

@property (nonatomic, weak) IBOutlet UIScrollView *containerView;

@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSMutableDictionary *sectionButtons;

@property (nonatomic, strong) UIButton *rootButton;

@end

@implementation MWBreadcrumbView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        [self setupDefaults];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        [self setupDefaults];
    }
    
    return self;
}

- (void)setupDefaults
{
    self.sections = [NSMutableArray array];
    self.sectionButtons = [NSMutableDictionary dictionary];
}

- (void)awakeFromNib
{
    self.rootButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rootButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    self.rootButton.titleLabel.textColor = [UIColor lightGrayColor];
    [self.rootButton setBackgroundImage:[UIImage imageNamed:@"homeCrumb"] forState:UIControlStateNormal];
    
    self.rootButton.frame = CGRectMake(0, 0, 44, self.frame.size.height);
    
    [self.rootButton addTarget:self action:@selector(didSelectRoot:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.containerView addSubview:self.rootButton];
}

#pragma mark - public

- (void)addSection:(NSString *)section
{
    UIButton *sectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sectionButton setTitle:section forState:UIControlStateNormal];
    sectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:13];
    sectionButton.titleLabel.textColor = [UIColor lightGrayColor];
    [sectionButton setBackgroundImage:[UIImage imageNamed:@"lastCrumb"]
                             forState:UIControlStateNormal];
    
    CGSize textSize = [sectionButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:sectionButton.titleLabel.font}];
    
    CGFloat originX = self.rootButton.frame.size.width - 10;
    
    for (NSString *section in self.sections)
    {
        originX += [(UIButton *)[self.sectionButtons objectForKey:section] frame].size.width - 8;
        
        [(UIButton *)[self.sectionButtons objectForKey:section] setBackgroundImage:[UIImage imageNamed:@"commonCrumb"]
                                                                          forState:UIControlStateNormal];
    }
    
    sectionButton.frame = CGRectMake(originX, 0, textSize.width + 20, self.frame.size.height);
    sectionButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    
    [sectionButton addTarget:self action:@selector(didSelectSection:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.sections addObject:section];
    [self.sectionButtons setObject:sectionButton forKey:section];
    [self.containerView addSubview:sectionButton];
    self.containerView.contentSize = CGSizeMake(sectionButton.frame.origin.x + sectionButton.frame.size.width, self.frame.size.height);
}

- (void)popToRoot
{
    [self didSelectRoot:nil];
}

#pragma mark - private

- (void)didSelectRoot:(id)sender
{
    for (NSString *section in self.sections)
    {
        [[self.sectionButtons objectForKey:section] removeFromSuperview];
    }
    
    [self.sectionButtons removeAllObjects];
    [self.sections removeAllObjects];
    
    [self.delegate breadcrumbViewDidSelectRoot:self];
}

- (void)didSelectSection:(id)sender
{
    NSString *lastSection = [self.sections lastObject];
    UIButton *lastSectionButton = [self.sectionButtons objectForKey:lastSection];
    
    if (lastSectionButton != sender)
    {
        while (lastSectionButton != sender)
        {
            NSString *section = lastSection;
            
            if (section == nil)
            {
                continue;
            }
            
            [[self.sectionButtons objectForKey:section] removeFromSuperview];
            [self.sectionButtons removeObjectForKey:section];
            [self.sections removeObject:lastSection];
            
            lastSection = [self.sections lastObject];
            lastSectionButton = [self.sectionButtons objectForKey:lastSection];
        }
        
        [(UIButton *)[self.sectionButtons objectForKey:[self.sections lastObject]] setBackgroundImage:[UIImage imageNamed:@"lastCrumb"] forState:UIControlStateNormal];
        
        [self.delegate breadcrumbView:self didSelectSection:lastSection];
    }
}

@end
