//
//  ImageViewController.m
//  Black Mesa
//
//  Created by CKO on 22.10.12.
//  Copyright (c) 2012 CodeStage. All rights reserved.
//

#import "ImageScrollViewController.h"
#import "ImageScrollView.h"
#import "ImageInfo.h"

#define ZOOM_STEP 2.0


@interface ImageScrollViewController ()
{
    __weak ImageScrollView *_imageScrollView;
}

@property (nonatomic) ImageInfo *imageInfo;

@end


@implementation ImageScrollViewController


- (id)initWithImageInfo:(ImageInfo *)info
{
    self = [super init];
    if (self)
    {
        _imageInfo = info;
    }
    return self;
}


- (void)loadView
{
    ImageScrollView *scrollView = [[ImageScrollView alloc] init];
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view = scrollView;

    UIImage *image = [UIImage imageWithData:self.imageInfo.imageData.data];
    _imageScrollView = scrollView;
    [_imageScrollView displayImage:image];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    
    [doubleTap setNumberOfTapsRequired:2];
    
    [self.view addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:doubleTap];
}


- (BOOL)shouldAutorotate
{
    return YES;
}


#pragma mark Gesture Recognizers


- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{

}


- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if (_imageScrollView.zoomScale == _imageScrollView.minimumZoomScale && _imageScrollView.zoomScale < _imageScrollView.maximumZoomScale)
    {
        // zoom in
        CGRect zoomRect = [self zoomRectForScale:_imageScrollView.maximumZoomScale/2 withCenter:[gestureRecognizer locationInView:_imageScrollView.zoomView]];
        [_imageScrollView zoomToRect:zoomRect animated:YES];
    }
    else if (_imageScrollView.zoomScale > _imageScrollView.minimumZoomScale)
    {
        // zoom out
        CGRect zoomRect = [self zoomRectForScale:_imageScrollView.minimumZoomScale withCenter:[gestureRecognizer locationInView:_imageScrollView.zoomView]];
        [_imageScrollView zoomToRect:zoomRect animated:YES];
    }
}


- (void)handleTwoFingerTap:(UIGestureRecognizer *)gestureRecognizer
{

}


#pragma mark Utility methods


- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [_imageScrollView frame].size.height / scale;
    zoomRect.size.width  = [_imageScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


@end
