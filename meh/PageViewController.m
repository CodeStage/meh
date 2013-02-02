//
//  PageViewController.m
//  meh
//
//  Created by Chris on 02.02.13.
//  Copyright (c) 2013 CodeStage. All rights reserved.
//

#import "PageViewController.h"
#import "ImageScrollViewController.h"


@interface PageViewController ()

@property (nonatomic) CSImageWire *wire;

@end


@implementation PageViewController


- (id)initWithTransitionStyle:(UIPageViewControllerTransitionStyle)style
        navigationOrientation:(UIPageViewControllerNavigationOrientation)navigationOrientation
                      options:(NSDictionary *)options
{
    self = [super initWithTransitionStyle:style navigationOrientation:navigationOrientation options:options];
    if (self)
    {
        _wire = [[CSImageWire alloc] init];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.wire.delegate = self;
    self.delegate = self;
    self.dataSource = self;
    
    ImageInfo *info = [_wire firstImage];
    if (info)
    {
        ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:info];
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        [self.wire successingImageForImage:info];
    }
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ImageScrollViewController *)viewController
{
    ImageInfo *info = viewController.imageInfo;
    ImageInfo *nextInfo = [self.wire predecessingImageForImage:info];
    if (nextInfo)
    {
        ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:nextInfo];
        return vc;
    }
    return nil;
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ImageScrollViewController *)viewController
{
    ImageInfo *info = viewController.imageInfo;
    ImageInfo *nextInfo = [self.wire successingImageForImage:info];
    if (nextInfo)
    {
        ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:nextInfo];
        [self.wire successingImageForImage:nextInfo];
        return vc;
    }
    return nil;
}


- (void)imageWire:(CSImageWire *)wire didLoadFirstImage:(ImageInfo *)imageInfo
{
    if ([self.viewControllers count] == 0)
    {
        ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:imageInfo];
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    }
}


- (void)imageWire:(CSImageWire *)wire didLoadImage:(ImageInfo *)imageInfo
{
    if ([self.viewControllers count] > 0)
    {
        ImageScrollViewController *vc = self.viewControllers[0];
        ImageInfo *visibleImageInfo = vc.imageInfo;
        if (visibleImageInfo.successor == nil || [visibleImageInfo.predecessor.url isEqual:imageInfo.url] || [visibleImageInfo.successor.url isEqual:imageInfo.url])
        {
            [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
            [self.wire successingImageForImage:imageInfo];
        }
    }
}


@end
