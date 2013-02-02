//
//  ImageScrollView.h
//  meh
//
//  Created by CKO on 22.10.12.
//  Copyright (c) 2012 CodeStage. All rights reserved.
//


@interface ImageScrollView : UIScrollView

@property (nonatomic, readonly) UIImageView *zoomView;

- (void)displayImage:(UIImage *)image;

@end
