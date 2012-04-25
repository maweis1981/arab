//
//  AsyncImageView.m
//  socialReminder
//
//  Created by peter on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "AsyncImageView.h"


// This class demonstrates how the URL loading system can be used to make a UIView subclass
// that can download and display an image asynchronously so that the app doesn't block or freeze
// while the image is downloading. It works fine in a UITableView or other cases where there
// are multiple images being downloaded and displayed all at the same time.


@implementation AsyncImageView

@synthesize _str_url;

- (void)dealloc {
    [_str_url release];
    [connection cancel]; //in case the URL is still downloading
    [connection release];
    [data release];
    [super dealloc];
}


//- (UIImage *)cachedImageForUrl:(NSString *)path {
//    id cachedObject = [self.cachedImages objectForKey:path];
//    if (cachedObject == nil) {
//		
//		if (path != nil && [imageUtils thumbnailOfImage:[UIImage imageWithContentsOfFile:path] withSize:CGSizeMake(100.0f,100.0f)] != nil) {
//			[self.cachedImages setObject:[imageUtils thumbnailOfImage:[UIImage imageWithContentsOfFile:path] withSize:CGSizeMake(100.0f,100.0f)] forKey:path];
//			return [self.cachedImages objectForKey:path];			
//		}else {
//			[self.cachedImages setObject:[UIImage imageNamed:@"2.png"] forKey:path];
//			return [self.cachedImages objectForKey:path];			
//		}
//        
//    }else if ( ![cachedObject isKindOfClass:[UIImage class]] ) {
//        cachedObject = nil;
//    }
//    return cachedObject;
//}


- (void)loadImageFromURLStr:(NSString*)url_str {
    NSLog(@"async image url is %@",url_str);
    


    NSString *cachedFilePath = [[NSUserDefaults standardUserDefaults] objectForKey:url_str];
    
    if (cachedFilePath == nil) {
        [self set_str_url:url_str];
        [self loadImageFromURL:[[NSURL alloc]initWithString:url_str]];
    }else{
        UIImage *cacheImageObj = [UIImage imageWithContentsOfFile:cachedFilePath];
        //make an image view for the image
        UIImageView* imageView = [[[UIImageView alloc] initWithImage:cacheImageObj] autorelease];
        //make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
        [self addSubview:imageView];
        imageView.frame = self.bounds;
        NSLog(@"%d,%d",imageView.frame.size.width,imageView.frame.size.height);
        [imageView setNeedsLayout];
        [self setNeedsLayout];
    }
}


- (void)loadImageFromURL:(NSURL*)url {
    if (connection!=nil) { [connection release]; } //in case we are downloading a 2nd image
    if (data!=nil) { [data release]; }
    
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
    //TODO error handling, what if connection is nil?
}


//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
    if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; }
    [data appendData:incrementalData];
}



-(NSString*)findUniqueSavePath:(NSString *)temPath{
	
	NSLog(@"PATH IS = %@ ",temPath);
	int i = 1;
	NSString *path;
	do {
		path = [NSString stringWithFormat:@"%@/IMAGE_%04d.jpg",temPath,i ++];
		
	} while ([[NSFileManager defaultManager] fileExistsAtPath:path]);
	
	
	NSLog(@"Unique Path is %@",path);
	return path;
}


//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    //so self data now has the complete image
    [connection release];
    connection=nil;
    if ([[self subviews] count]>0) {
        //then this must be another image, the old one is still in subviews
        [[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
    }
    
    
    
	NSString *fullpath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0];
	NSLog(@"Full Path = %@ ",fullpath);
    
    NSString *cacheFilePath = [self findUniqueSavePath:fullpath];
    [data writeToFile:cacheFilePath atomically:NO];
    NSLog(@"cached file path is %@, key is %@",cacheFilePath,_str_url);
    [[NSUserDefaults standardUserDefaults] setObject:cacheFilePath forKey:_str_url];
    
    //make an image view for the image
    UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
    //make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
    [self addSubview:imageView];
    imageView.frame = self.bounds;
    NSLog(@"%d,%d",imageView.frame.size.width,imageView.frame.size.height);
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    
    [data release]; //don't need this any more, its in the UIImageView now
    data=nil;
}

//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
    UIImageView* iv = [[self subviews] objectAtIndex:0];
    return [iv image];
}

@end