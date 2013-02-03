//
//  CSImageWire.h
//  meh
//
//  Created by CKO on 28.01.13.
//  Copyright (c) 2013 CodeStage. All rights reserved.
//

@class CSImageWire, ImageInfo;


@protocol CSImageWireDelegate <NSObject>

- (void)imageWire:(CSImageWire *)wire didLoadImage:(ImageInfo *)imageInfo;

@end


@interface CSImageWire : NSObject

@property (nonatomic, weak) id<CSImageWireDelegate> delegate;

- (ImageInfo *)firstImage;
- (ImageInfo *)predecessingImageForImage:(ImageInfo *)info;
- (ImageInfo *)successingImageForImage:(ImageInfo *)info;

@end
