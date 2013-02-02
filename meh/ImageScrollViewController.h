//
//  ImageViewController.h
//  meh
//
//  Created by CKO on 22.10.12.
//  Copyright (c) 2012 CodeStage. All rights reserved.
//

@class ImageInfo;


@interface ImageScrollViewController : UIViewController

@property (nonatomic, readonly) ImageInfo *imageInfo;

- (id)initWithImageInfo:(ImageInfo *)info;

@end
