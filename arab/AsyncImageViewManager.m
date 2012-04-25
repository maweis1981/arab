//
//  AsyncImageViewManager.m
//  socialReminder
//
//  Created by peter on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageViewManager.h"

@implementation AsyncImageViewManager

+(AsyncImageView*)factoryWithUrl:(NSString*)url_str{
    NSLog(@"async image url is %@",url_str);

    id cachedObject = [[NSUserDefaults standardUserDefaults] objectForKey:url_str];
    if (cachedObject == nil) {
        NSLog(@"cache object is nil");
        cachedObject = [[AsyncImageView alloc]init];
        [cachedObject loadImageFromURL:[[NSURL alloc]initWithString:url_str]];
        NSLog(@"load image from url");
        NSLog(@"cached object load done is %@",cachedObject);
        
        [[NSUserDefaults standardUserDefaults] setObject:cachedObject forKey:url_str];
        
    }else if ( ![cachedObject isKindOfClass:[AsyncImageView class]]) {
        cachedObject = nil;
    }
    return cachedObject;
}


@end
