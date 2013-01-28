//
//  CSImageWire.m
//  meh
//
//  Created by CKO on 28.01.13.
//  Copyright (c) 2013 CodeStage. All rights reserved.
//

#import "CSImageWire.h"


@implementation CSImageWire


+ (NSArray *)imageInfosFromData:(NSData *)data
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
         NSString *url      = [string substringWithRange:[result rangeAtIndex:1]];
         NSString *title    = [string substringWithRange:[result rangeAtIndex:2]];
         
         ImageInfo *info = [ImageInfo MR_findFirstByAttribute:@"url" withValue:url];
         
         if (!info)
         {
             info = [ImageInfo MR_createEntity];
             
             [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext)
             {
                 ImageInfo *localInfo = [info MR_inContext:localContext];
                 localInfo.url = url;
                 localInfo.title = title;
             }];
         }

         [imageInfos addObject:info];
     }];
    
    return imageInfos;
}


@end
