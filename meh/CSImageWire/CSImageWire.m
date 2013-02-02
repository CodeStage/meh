//
//  CSImageWire.m
//  meh
//
//  Created by CKO on 28.01.13.
//  Copyright (c) 2013 CodeStage. All rights reserved.
//

#import "CSImageWire.h"


static NSString *const kUrlKey      = @"url";
static NSString *const kTitleKey    = @"title";


@interface CSImageWire ()

@property (nonatomic) NSOperationQueue *queue;

@end


@implementation CSImageWire


- (id)init
{
    self = [super init];
    if (self)
    {
        _queue = [[NSOperationQueue alloc] init];
    }
    return self;
}


#pragma mark Public


- (ImageInfo *)firstImage
{
    ImageInfo *info = [ImageInfo MR_findFirst];
    [self refreshFirstImage];
    
    if (info.imageData.data)
    {
        return info;
    }
    return nil;
}


- (ImageInfo *)predecessingImageForImage:(ImageInfo *)info
{
    if (info.predecessor)
    {
        if (info.predecessor.imageData.data)
        {
            return info.predecessor;
        }
        else
        {
            [self fetchDataForImageInfo:info.predecessor firstImage:NO];
            return nil;
        }
    }
    else
    {
        [self refreshFirstImage];
        return nil;
    }
}


- (ImageInfo *)successingImageForImage:(ImageInfo *)info
{
    if (info.successor)
    {
        if (info.successor.imageData.data)
        {
            return info.successor;
        }
        else
        {
            [self fetchDataForImageInfo:info.successor firstImage:NO];
            return nil;
        }
    }
    else
    {
        [self fetchSuccessorForImage:info startingAtPage:1];
        return nil;
    }
}


#pragma mark Fetching


- (void)refreshFirstImage
{
    [self fetchInfosForPage:1 completion:^{
        ImageInfo *info = [ImageInfo MR_findFirst];
        [self fetchDataForImageInfo:info firstImage:YES];
    }];
}


- (void)fetchSuccessorForImage:(ImageInfo *)info startingAtPage:(NSUInteger)page
{
    [self fetchInfosForPage:page completion:^{
        if (!info.successor && page <= 600)
        {
            [self fetchSuccessorForImage:info startingAtPage:page+1];
        }
        else
        {
            [self fetchDataForImageInfo:info firstImage:NO];
        }
    }];
}


- (void)didLoadImage:(ImageInfo *)info firstImage:(BOOL)firstImage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (firstImage)
        {
            [self.delegate imageWire:self didLoadFirstImage:info];
        }
        else
        {
            [self.delegate imageWire:self didLoadImage:info];
        }
    });
}


- (void)fetchDataForImageInfo:(ImageInfo *)info firstImage:(BOOL)firstImage
{
    if (info.imageData.data)
    {
        [self didLoadImage:info firstImage:firstImage];
        return;
    }
    
    NSLog(@"fetching image: %@", info.title);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:info.url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self.queue addOperationWithBlock:^{
             [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *context)
              {
                  ImageInfo *localInfo = [info MR_inContext:context];
                  localInfo.imageData = [ImageData MR_createInContext:context];
                  localInfo.imageData.data = responseObject;
                  [self didLoadImage:localInfo firstImage:firstImage];
              }];
         }];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error);
     }];
    
    [self.queue addOperation:operation];
}


- (void)fetchInfosForPage:(NSUInteger)page completion:(void (^)())completion
{
    NSLog(@"fetching page: %u", page);
    NSString *url = [NSString stringWithFormat:@"http://www.meh.ro/page/%u", page];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         [self.queue addOperationWithBlock:^{
             NSArray *infos = [self imageInfosFromData:responseObject forPage:page];
             [self processInfos:infos forPage:page];
             if (completion) completion();
         }];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error);
     }];
    
    [self.queue addOperation:operation];
}


#pragma mark Info Processing


- (NSArray *)imageInfosFromData:(NSData *)data forPage:(NSUInteger)page
{
    NSError *error = nil;
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *pattern = @"<a.*href=\"(http://www.meh.ro/wp-content/uploads/[^ ]*\\.jpg)\".*title=\"([^\"]*)\".*</a>";
    NSMutableArray *imageInfos = [NSMutableArray array];
    
    NSRegularExpression *expr = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    [expr enumerateMatchesInString:string
                           options:0
                             range:NSMakeRange(0, [string length])
                        usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop)
     {
         NSString *url = [string substringWithRange:[result rangeAtIndex:1]];
         NSString *title = [string substringWithRange:[result rangeAtIndex:2]];
         NSDictionary *info = @{ kUrlKey : url, kTitleKey : title };
         
         [imageInfos addObject:info];
     }];
    
    return imageInfos;
}


- (void)processInfos:(NSArray *)infos forPage:(NSUInteger)page
{
    NSArray *infosToReset = [ImageInfo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"pageNumber >= %u", page]];
    for (ImageInfo *info in infosToReset)
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *context)
         {
             ImageInfo *localInfo = [info MR_inContext:context];
             localInfo.pageNumber = nil;
         }];
    }
    
    //------------------------------------------------------------------------------------------------
    
    NSMutableArray *infoModels = [NSMutableArray array];
    NSUInteger newInfoCount = 0;
    NSUInteger oldInfoCount = 0;
    
    for (NSDictionary *dict in infos)
    {
        NSString *url = [dict objectForKey:kUrlKey];
        NSString *title = [dict objectForKey:kTitleKey];
        ImageInfo *info = [ImageInfo MR_findFirstByAttribute:@"url" withValue:url];
        
        if (!info)
        {
            info = [ImageInfo MR_createEntity];
            newInfoCount++;
        }
        else
        {
            oldInfoCount++;
        }
        
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *context)
         {
             ImageInfo *localInfo = [info MR_inContext:context];
             localInfo.url = url;
             localInfo.title = title;
             localInfo.pageNumberValue = page;
         }];
        
        [infoModels addObject:info];
    }
    
    NSLog(@"new: %u", newInfoCount);
    NSLog(@"old: %u", oldInfoCount);
    
    //------------------------------------------------------------------------------------------------
    
    NSUInteger i = 0;
    __block BOOL linked = NO;
    
    for (ImageInfo *info in infoModels)
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *context)
         {
             ImageInfo *localInfo = [info MR_inContext:context];
             
             if (i == 0)
             {
                 if (page > 1)
                 {
                     NSArray *predecessingInfos = [ImageInfo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"pageNumber == %u", page - 1]];
                     ImageInfo *lastPredecessingInfo = [predecessingInfos lastObject];
                     
                     lastPredecessingInfo.successor = localInfo;
                     NSLog(@"setting successor of '%@' to '%@'", lastPredecessingInfo.title, localInfo.title);
                     
                     localInfo.predecessor = lastPredecessingInfo;
                     NSLog(@"setting predecessor of '%@' to '%@'", localInfo.title, lastPredecessingInfo.title);
                 }
             }
             
             if (i > 0)
             {
                 localInfo.predecessor = infoModels[i-1];
                 NSLog(@"setting predecessor of '%@' to '%@'", localInfo.title, localInfo.predecessor.title);
             }
             
             if (i < [infoModels count]-1)
             {
                 localInfo.successor = infoModels[i+1];
                 NSLog(@"setting successor of '%@' to '%@'", localInfo.title, localInfo.successor.title);
             }
             
             if (localInfo.successor.successor)
             {
                 NSLog(@"successor of '%@' is '%@'", localInfo.title, localInfo.successor.title);
                 NSLog(@"successor of '%@' is '%@'", localInfo.successor.title, localInfo.successor.successor.title);
                 
                 localInfo.successor.predecessor = localInfo;
                 NSLog(@"setting predecessor of '%@' to '%@'", localInfo.successor.title, localInfo.successor.predecessor.title);
                 linked = YES;
             }
             

         }];
        
        if (linked) break;
        i++;
    }
    
    NSLog(@"link established: %u", linked);
}


@end
