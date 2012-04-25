//
//  ViewController.m
//  arab
//
//  Created by 伟 马 on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "Book.h"
#import "ZipArchive.h"
#import "EPub.h"
#import "Chapter.h"
#import "CTView.h"
#import "CoreTextMagazineViewController.h"
#import "DirectoryViewController.h"
#import "FirstViewController.h"

@implementation ViewController
@synthesize pageController;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}


-(void) loadSpine:(EPub *)epub{
	NSURL* url = [NSURL fileURLWithPath:[[epub.spineArray objectAtIndex:0] spinePath]];
    NSLog(@"URL = %@", url);
    //	[webView loadRequest:[NSURLRequest requestWithURL:url]];
    
}


- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    
    NSString *temp_basePath = [basePath stringByAppendingPathComponent:@"temp_epub_files"];
    if(![[NSFileManager defaultManager] fileExistsAtPath:temp_basePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:temp_basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    basePath = [basePath stringByAppendingPathComponent:@"epub_files"];
    NSLog(@"View base path is %@",basePath);
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:basePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
   return basePath;
}


#pragma mark - View lifecycle

- (void)openBookShelf
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    int openCounts = [prefs integerForKey:@"open_counts"];
    
    NSArray *originArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"epub" inDirectory:nil];
    
    for (NSString *path in originArray) {
        NSString *desPath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:[path lastPathComponent]];
        [[NSFileManager defaultManager]copyItemAtPath:path toPath:desPath error:nil];
    }

    NSArray *tmpArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self applicationDocumentsDirectory] error:nil];
    NSLog(@"epub books array from bundle %d",[tmpArray count]);    
    
    
    firstVC = [[FirstViewController alloc]init];
    [firstVC setEpubBooks:tmpArray];
    
    if (openCounts == 0) {
        NSLog(@"优化封面显示");
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];   
        hud.delegate = self;
        hud.dimBackground = YES;  
        hud.labelText = @"正在优化封面显示";
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{   
            dispatch_async(dispatch_get_main_queue(), ^{  
                for (NSString *epubFile in tmpArray) {
                    NSLog(@"application start %@",epubFile);
                    EPub *epub = [[EPub alloc]initWithEPubPath:[[self applicationDocumentsDirectory] stringByAppendingPathComponent:epubFile]];        
                    //计算每本书的页数 诸如此类的计算。
                    NSLog(@"app lication start unzip %@",epubFile);
                }
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES]; 
            }); 
        });
        
        [prefs setInteger:1 forKey:@"open_counts"];
    }else{
        openCounts = openCounts + 1;
        [prefs setInteger:openCounts forKey:@"open_counts"];
    }
    
    NSLog(@"open counts is %d",openCounts);    
    [self.navigationController pushViewController:firstVC animated:NO];
}

- (void)viewDidLoad
{
    
//    [self openBookShelf];            
//    [super viewDidLoad];
}


-(void)hudWasHidden:(MBProgressHUD *)hud{
    NSLog(@"Has Hidden");
    
    NSArray *tmpArray = [[NSBundle mainBundle] pathsForResourcesOfType:@"epub" inDirectory:nil];
    NSLog(@"epub books array from bundle %d",[tmpArray count]);
    
    firstVC = [[FirstViewController alloc]init];
    [firstVC setEpubBooks:tmpArray];
    [self.navigationController pushViewController:firstVC animated:NO];                
}



- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"should be reload book shelf.");
    [self openBookShelf];
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self performSelector:@selector(firstUpdate) withObject:nil afterDelay:0.0];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
