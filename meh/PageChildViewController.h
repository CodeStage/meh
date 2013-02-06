//
//  PageChildViewController.h
//  meh
//
//  Created by Chris on 07.02.13.
//  Copyright (c) 2013 CodeStage. All rights reserved.
//


@interface PageChildViewController : UIViewController

@property (nonatomic) ImageInfo *imageInfo;

@property (nonatomic, weak) PageChildViewController *predecessor;
@property (nonatomic, weak) PageChildViewController *successor;

@end
