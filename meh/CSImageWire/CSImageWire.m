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


- (void)fetchInfosForPage:(NSUInteger)page
{
    NSString *url = [NSString stringWithFormat:@"http://www.meh.ro/page/%u", page];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSArray *infos = [self imageInfosFromData:responseObject forPage:page];
         [self processInfos:infos forPage:page];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         NSLog(@"%@", error);
     }];
    
    [self.queue addOperation:operation];
}


- (void)processInfos:(NSArray *)infos forPage:(NSUInteger)page
{
    for (NSDictionary *dict in infos)
    {
        NSString *url = [dict objectForKey:kUrlKey];
        NSString *title = [dict objectForKey:kTitleKey];
        
        ImageInfo *info = [ImageInfo MR_findFirstByAttribute:@"url" withValue:url];
        
        if (!info)
        {
            info = [ImageInfo MR_createEntity];
        }
        
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext)
         {
             ImageInfo *localInfo = [info MR_inContext:localContext];
             localInfo.url = url;
             localInfo.title = title;
             localInfo.pageNumberValue = page;
         }];
    }
}


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


@end
