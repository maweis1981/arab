//
//  BookEntryViewController.m
//  arab
//
//  Created by Peter Ma on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BookEntryViewController.h"

@implementation BookEntryViewController
@synthesize httpRequest,downloadProgress;

@synthesize bookNameLabel,coverView,authorLabel,publisherLabel,publishDateLabel,descriptionLabel,descriptionScrollView;
@synthesize bookData;

@synthesize bookUrl;
@synthesize epubUrl;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
//    basePath = [basePath stringByAppendingPathComponent:@"epub_files"];
    NSLog(@"base path is %@",basePath);
    return basePath;
}


-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"failed");
    NSLog(@"Failed %@",[request responseString]);

    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"no this epub" message:@"Done" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil];
    [alertView show];
    //    NSLog(@"failed %@,  %@",[request responseStatusCode],[request responseString]);
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"finished");
    NSLog(@"Finished %@",[request responseString]);
    
    
    EPub *epubFile = [[EPub alloc] initWithEPubPath:[[[self applicationDocumentsDirectory]stringByAppendingPathComponent:@"epub_files"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub",[self.bookData objectForKey:@"name"]]]];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"下载完毕" message:@"下载成功" delegate:self cancelButtonTitle:@"继续浏览网上书库" otherButtonTitles:@"返回书架",nil];
    [alertView show];
    //    NSLog(@"finished %@,  %@",[request responseStatusCode],[request responseString]);
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

-(void)requestStarted:(ASIHTTPRequest *)request{
    NSLog(@"request started.");
}

-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    NSLog(@"request receivce response headers data. %@", responseHeaders);
}

-(void)request:(ASIHTTPRequest *)request didReceiveBytes:(long long)bytes{
    NSLog(@"received bytes is %@",bytes);
}

-(IBAction)downloadEpubFile:(id)sender{
    [httpRequest cancel];
    
    NSString *epub_download_uri = [self.bookData objectForKey:@"epub_uri"];
    NSLog(@"epub uri is %@", epub_download_uri);
    
//    epub_download_uri = [epub_download_uri stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];  
    
    epub_download_uri = [epub_download_uri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSLog(@"epub uri is %@", epub_download_uri);
    
    [self setHttpRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:epub_download_uri]]];
    

    [httpRequest setTimeOutSeconds:60];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	[httpRequest setShouldContinueWhenAppEntersBackground:YES];
#endif
    [httpRequest setShowAccurateProgress:YES];
    
    [httpRequest setDelegate:self];

    [[self downloadProgress] setHidden:NO];
    [[self downloadProgress] setProgress:0.0f];
    
    [httpRequest setDownloadProgressDelegate:downloadProgress];
    
    [httpRequest setDownloadDestinationPath:[[[self applicationDocumentsDirectory]stringByAppendingPathComponent:@"epub_files"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub",[self.bookData objectForKey:@"name"]]]];
    
    [httpRequest setTemporaryFileDownloadPath:[[[self applicationDocumentsDirectory]stringByAppendingPathComponent:@"temp_epub_files"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.epub",[self.bookData objectForKey:@"name"]]]];
        
    NSLog(@"path is %@",[httpRequest downloadDestinationPath]);

    NSLog(@"temp path is %@",[httpRequest temporaryFileDownloadPath]);
    
    [httpRequest setDidFailSelector:@selector(requestFailed:)];
    [httpRequest setDidFinishSelector:@selector(requestFinished:)];

    [httpRequest startAsynchronous];
}

- (void)viewDidLoad
{
    [[self coverView] loadImageFromURLStr:[self.bookData objectForKey:@"cover"]];
    
    [[self bookNameLabel]setText:[self.bookData objectForKey:@"name"]];
    [[self authorLabel]setText:[self.bookData objectForKey:@"author"]];
    [[self publisherLabel]setText:[self.bookData objectForKey:@"publisher"]];    
    [[self publishDateLabel]setText:[self.bookData objectForKey:@"publish_date"]];
    [[self descriptionLabel]setText:[self.bookData objectForKey:@"description"]];    
    
    [self setEpubUrl:[self.bookData objectForKey:@"epub_uri"]];

    
    [[self downloadProgress]setHidden:YES];
//    downloadProgress = [[UIProgressView alloc]initWithFrame:CGRectMake(10, 10, 300, 20)];
//    [downloadProgress setProgressViewStyle:UIProgressViewStyleDefault];
//    [downloadProgress setBackgroundColor:[UIColor redColor]];
//
//    [self.view addSubview: downloadProgress];
//
//    
//    UIButton *downloadBtn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 50)];
//    [downloadBtn setTitle:@"download" forState:UIControlStateNormal];
//    [downloadBtn addTarget:self action:@selector(downloadEpubFile:) forControlEvents:UIControlEventTouchUpInside];
//    
//    [downloadBtn setBackgroundColor:[UIColor blueColor]];
//    
//    [self.view addSubview:downloadBtn];
        
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
