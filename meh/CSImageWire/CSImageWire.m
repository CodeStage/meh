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
//static NSUInteger kMaxStoredImages  = 2;


@interface CSImageWire ()

@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) BOOL pageFetchingInProgess;

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
    Log(@"Asking for first image");
    
    ImageInfo *info = [ImageInfo MR_findFirstOrderedByAttribute:@"url" ascending:NO];
    [self refreshFirstImage];
    [self removeOldImages];
    
    if (info.imageData.data)
    {
        return info;
    }
    return nil;
}


- (ImageInfo *)predecessingImageForImage:(ImageInfo *)info
{
    Log(@"Asking for predecessor of '%@'", info.title);
    
//    info = [ImageInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"url == %@", info.url] sortedBy:@"url" ascending:NO];
    if (info.predecessor)
    {
        if (info.predecessor.imageData.data)
        {
            Log(@"Predecessor is in cache");
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
    Log(@"Asking for successor of '%@'", info.title);
    
//    info = [ImageInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"url == %@", info.url] sortedBy:@"url" ascending:NO];
    if (info.successor)
    {
        if (info.successor.imageData.data)
        {
            Log(@"Successor is in cache");
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
        [self fetchInfosForPage:info.pageNumberValue+1 completion:^{
            if (!info.successor)
            {
                [self fetchSuccessorForImage:info startingAtPage:1];
            }
            else
            {
                [self fetchDataForImageInfo:info.successor firstImage:NO];
            }
        }];
        return nil;
    }
}


#pragma mark Fetching


- (void)refreshFirstImage
{
    [self fetchInfosForPage:1 completion:^
     {
         ImageInfo *info = [ImageInfo MR_findFirstOrderedByAttribute:@"url" ascending:NO];
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
    Log(@"Notifying delegate with '%@' (first: %u)", info.title, firstImage);
    dispatch_async(dispatch_get_main_queue(), ^
    {
        [self.delegate imageWire:self didLoadImage:info];
    });
    
    if (firstImage)
    {
        [self successingImageForImage:info];
    }
}


- (void)fetchDataForImageInfo:(ImageInfo *)info firstImage:(BOOL)firstImage
{
    Log(@"fetching image: %@", info.title);
    
    if (info.imageData.data)
    {
        Log(@"fetching aborted (data available)");
        return;
    }
    
    if (info.fetchingInProgressValue)
    {
        Log(@"fetching aborted (already in progress)");
        return;
    }

    info.fetchingInProgressValue = YES;
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:info.url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         ImageData *data = [ImageData MR_createEntity];
         data.data = responseObject;

         if (info.imageData)
         {
             Log(@"image already exists: %@", info.title);
         }
         else
         {
             info.imageData = data;
             Log(@"saving image: %@", info.title);
         }
         
         info.fetchingInProgressValue = NO;
         [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
         
         [self didLoadImage:info firstImage:firstImage];
         [self updateIndicator];

     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         info.fetchingInProgressValue = NO;
         [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
         
         Log(@"Error: %@", error);
         [self updateIndicator];
     }];
    
    if (firstImage) operation.queuePriority = NSOperationQueuePriorityHigh;
    [self.queue addOperation:operation];
    [self updateIndicator];
}


- (void)fetchInfosForPage:(NSUInteger)page completion:(void (^)())completion
{
    Log(@"fetching page: %u", page);
    NSString *url = [NSString stringWithFormat:@"http://www.meh.ro/page/%u", page];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *infos = [self imageInfosFromData:responseObject forPage:page];
         [self processInfos:infos forPage:page];
         if (completion) completion();
         [self updateIndicator];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         Log(@"%@", error);
         [self updateIndicator];
     }];
    
    [self.queue addOperation:operation];
    [self updateIndicator];
}


#pragma mark Info Processing


- (NSArray *)imageInfosFromData:(NSData *)data forPage:(NSUInteger)page
{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *imageInfos = [NSMutableArray array];
    NSError *error = nil;
    
    NSString *pattern = @"<a\\shref=\"(http://www.meh.ro/wp-content/uploads/[^\\s]*\\.[a-zA-Z]{3})\".*title=\"([^\"]*)\".*</a>";    
    
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
    
    if (error) Log(@"Error: %@", error);
    
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"url" ascending:NO selector:@selector(compare:)];
    [imageInfos sortUsingDescriptors:@[sd]];
    
    return imageInfos;
}


- (void)processInfos:(NSArray *)infos forPage:(NSUInteger)page
{    
    NSMutableArray *infoModels = [NSMutableArray array];
    NSUInteger newInfoCount = 0;
    NSUInteger oldInfoCount = 0;
    
    for (NSDictionary *dict in infos)
    {
        NSString *url = [dict objectForKey:kUrlKey];
        NSString *title = [dict objectForKey:kTitleKey];
        ImageInfo *info = [ImageInfo MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"url == %@", url] sortedBy:@"url" ascending:NO];
        
        if (!info)
        {
            info = [ImageInfo MR_createEntity];
            newInfoCount++;
        }
        else
        {
            oldInfoCount++;
        }
        
        info.url = url;
        info.title = title;
        info.pageNumberValue = page;
        
        [infoModels addObject:info];
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];

    Log(@"new: %u", newInfoCount);
    Log(@"old: %u", oldInfoCount);
    
    //------------------------------------------------------------------------------------------------
    
    if (page == 1 && newInfoCount == 0)
    {
        Log(@"No new images found.");
        return;
    }
    
    //------------------------------------------------------------------------------------------------
    
    NSArray *infosToReset = [ImageInfo MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"pageNumber >= %u", page]];
    for (ImageInfo *info in infosToReset)
    {
        info.pageNumber = nil;
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    
    //------------------------------------------------------------------------------------------------
    
    
    NSUInteger i = 0;
    __block BOOL linked = NO;
    
    for (ImageInfo *info in infoModels)
    {
        if (i == 0)
        {
            if (page > 1)
            {
                NSArray *predecessingInfos = [ImageInfo MR_findAllSortedBy:@"url" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"pageNumber == %u", page - 1]];
                
                ImageInfo *lastPredecessingInfo = [predecessingInfos lastObject];
                
                lastPredecessingInfo.successor = info;
                Log(@"setting successor   of '%@' to '%@'", lastPredecessingInfo.title, info.title);
                
                info.predecessor = lastPredecessingInfo;
                Log(@"setting predecessor of '%@' to '%@'", info.title, lastPredecessingInfo.title);
                
                Log(@"link established");
            }
        }
        
        if (i > 0)
        {
            info.predecessor = infoModels[i-1];
            Log(@"setting predecessor of '%@' to '%@'", info.title, info.predecessor.title);
        }
        
        if (i < [infoModels count]-1)
        {
            info.successor = infoModels[i+1];
            Log(@"setting successor   of '%@' to '%@'", info.title, info.successor.title);
        }
        
        if (info.successor.successor)
        {
            Log(@"successor of '%@' is '%@'", info.title, info.successor.title);
            Log(@"successor of '%@' is '%@'", info.successor.title, info.successor.successor.title);
            
            info.successor.predecessor = info;
            Log(@"setting predecessor of '%@' to '%@'", info.successor.title, info.successor.predecessor.title);
            linked = YES;
        }
        
        if (linked) break;
        i++;
    }
    
    [[NSManagedObjectContext MR_contextForCurrentThread] MR_saveToPersistentStoreAndWait];
    Log(@"link established: %u", linked);
}


- (void)updateIndicator
{
    BOOL visible = [self.queue operationCount] > 0;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = visible;
}


- (void)removeOldImages
{
//    NSArray *infos = [ImageInfo MR_findAllSortedBy:@"url" ascending:YES];
//
//    NSUInteger countBefore = 0;
//    NSUInteger counter = 0;
//    
//    for (ImageInfo *info in infos)
//    {
//        if (info.imageData) countBefore++;
//
//        [info.imageData MR_deleteEntity];
//        
////        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *context)
////         {
////             ImageInfo *localInfo = [info MR_inContext:context];
////             localInfo.imageData = nil;
////         }];
//
//        
//        counter++;
//        if (counter >= kMaxStoredImages) break;
//    }
//    
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    
//    NSUInteger countAfter = [ImageData MR_countOfEntities];
//    
//    Log(@"image data count before deleting: %u", countBefore);
//    Log(@"image data count after deleting: %u", countAfter);
}


@end
