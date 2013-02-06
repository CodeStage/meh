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
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ImageInfo *info = [_wire firstImage];
    if (info)
    {
        ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:info];
        [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        [self.wire successingImageForImage:info];
    }
}


- (void)refreshFirstPage
{
    [self.wire firstImage];
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(ImageScrollViewController *)viewController
{
//    @synchronized(self)
//    {
        ImageInfo *info = viewController.imageInfo;
        ImageInfo *nextInfo = [self.wire predecessingImageForImage:info];
        if (nextInfo)
        {
            ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:nextInfo];
            return vc;
        }
        
        Log(@"No predecessor: '%@'", info.title);
        return nil;
//    }
}


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(ImageScrollViewController *)viewController
{
//    @synchronized(self)
//    {
        ImageInfo *info = viewController.imageInfo;
        ImageInfo *nextInfo = [self.wire successingImageForImage:info];
        if (nextInfo)
        {
            ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:nextInfo];
            [self.wire successingImageForImage:nextInfo];
            return vc;
        }
        
        Log(@"No successor: '%@'", info.title);
        return nil;
//    }
}


- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if ([pendingViewControllers count] > 0)
    {
        ImageScrollViewController *vc = self.viewControllers[0];
        ImageInfo *visibleImageInfo = vc.imageInfo;
        [self.wire successingImageForImage:visibleImageInfo];
    }
}


- (void)imageWire:(CSImageWire *)wire didLoadImage:(ImageInfo *)imageInfo
{
    @synchronized(self)
    {
        if ([self.viewControllers count] > 0)
        {
            ImageScrollViewController *vc = self.viewControllers[0];
            ImageInfo *visibleImageInfo = vc.imageInfo;
            
            if (visibleImageInfo.successor == nil || [visibleImageInfo.predecessor.url isEqualToString:imageInfo.url] || [visibleImageInfo.successor.url isEqualToString:imageInfo.url])
            {
                Log(@"Reloading Viewcontrollers with visible image: '%@'", visibleImageInfo.title);
                Log(@"Successor: '%@'", visibleImageInfo.successor.title);
                
                dispatch_async(dispatch_get_main_queue(), ^
                               {
                                   ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:visibleImageInfo];
                                   [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL]; 
                               });
            }
        }
        else
        {
            Log(@"Setting initial Viewcontroller with visible image: '%@'", imageInfo.title);
            ImageScrollViewController *vc = [[ImageScrollViewController alloc] initWithImageInfo:imageInfo];
            [self setViewControllers:@[vc] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
        }
    }
}


@end
