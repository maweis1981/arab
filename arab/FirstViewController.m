//
//  FirstViewController.m
//  FlipCardNavigationView
//
//  Created by Kishikawa Katsumi on 10/03/08.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import "FirstViewController.h"
#import "DirectoryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "CoreTextMagazineViewController.h"
#import "EPub.h"
#import "MBProgressHUD.h"

@implementation FirstViewController
@synthesize httpRequest,epubBooks,hud;
@synthesize delAlertView;

-(void)hudWasHidden:(MBProgressHUD *)aHud{
    [hud removeFromSuperview];
    [hud release];
}

- (void)loadBookShelfView:(UIView *)contentView {
    thumbnailView = [[FlipCardView alloc] initWithFrame:contentView.frame];
	thumbnailView.delegate = self;
	thumbnailView.dataSource = self;
    [thumbnailView setBackgroundColor:[UIColor clearColor]];
	[contentView addSubview:thumbnailView];
    [contentView bringSubviewToFront:thumbnailView];
}

- (void)loadView {
    NSLog(@"load view in first view controller = %f",self.navigationController.navigationBar.frame.size.height);
	UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 416.0f)];
	
    self.view = contentView;
    
    UIImageView *leftShelfSlideView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 160, self.view.frame.size.height)];
    UIImage *leftShelfImg = [UIImage imageNamed:@"topshelf side shading-iPhone.png"];
    leftShelfImg = [leftShelfImg stretchableImageWithLeftCapWidth:160 topCapHeight:0];
    [leftShelfSlideView setImage:leftShelfImg];
    [contentView addSubview:leftShelfSlideView];
    
    [leftShelfSlideView setAlpha:0.8];
    
    UIImageView *rightShelfSlideView = [[UIImageView alloc]initWithFrame:CGRectMake(160, 0, 160, self.view.frame.size.height)];
    [rightShelfSlideView setImage:leftShelfImg];
    
    CGAffineTransform rotation = CGAffineTransformMakeScale(-1.0, 1.0);
    [rightShelfSlideView setTransform:rotation];    
    [contentView addSubview:rightShelfSlideView];
    [rightShelfSlideView setAlpha:0.8];
    
	[self loadBookShelfView:contentView];
    
}

-(NSString *)ePubsDirectory:(id)sender{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    basePath = [basePath stringByAppendingPathComponent:@"epub_files"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:basePath]){
        [[NSFileManager defaultManager] createDirectoryAtPath:basePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return basePath;
}

-(void)refreshFlipCardView:(id)sender{
    NSLog(@"refresh book shelf.");
        
    NSLog(@"refresh book shelf. %@",[self epubBooks]);
    [self setEpubBooks:[[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self ePubsDirectory:nil] error:nil]];
    
    NSLog(@"refresh book shelf. %@",[self epubBooks]);
    [self loadBookShelfView:self.view];
}


-(void)backAction:(id)sender{
    NSLog(@"do back action.");
    [self.navigationController popViewControllerAnimated:YES];
}
               

-(void)openBookStore:(id)sender{
    BookStoreViewController *bs = [[BookStoreViewController alloc]init];
    [self.navigationController pushViewController:bs animated:YES];
}


-(void)reloadBookShelf:(id)sender{
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)viewDidLoad {

    UIBarButtonItem *loadBtn = [[UIBarButtonItem alloc]initWithTitle:@"网上书库" style:UIBarButtonItemStylePlain target:self action:@selector(openBookStore:)];
    [self.navigationItem setRightBarButtonItem:loadBtn];
    
    UIBarButtonItem *reloadBtn = [[UIBarButtonItem alloc]initWithTitle:@"刷新" style:UIBarButtonItemStylePlain target:self action:@selector(reloadBookShelf:)];

    [self.navigationItem setLeftBarButtonItem:reloadBtn];
    
    
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    
    UIColor *background = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Wood Tile-iPhone.png"]];
    self.view.backgroundColor = background;
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    //@todo read title from product name.
    [titleLabel setText:@"爱看书"];
    [titleLabel setTextAlignment:UITextAlignmentCenter];
    [titleLabel setTextColor:[UIColor brownColor]];
    [titleLabel setFont:[UIFont fontWithName:@"AmericanTypewriter-Bold" size:18]];
    [self.navigationController.navigationBar addSubview:titleLabel];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"NavBar-iPhone.png"] forBarMetrics:UIBarMetricsDefault];                
    }else{
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
        [imageView setImage:[UIImage imageNamed:@"NavBar-iPhone.png"]];
//        [self.navigationController.navigationBar setBarStyle:UIBarStyleBlack];
        [self.navigationController.navigationBar addSubview:imageView];
    }
    
    
    CALayer *navLayer = self.navigationController.navigationBar.layer;
    navLayer.masksToBounds = NO;
    
    navLayer.shadowColor = [UIColor blackColor].CGColor;
    navLayer.shadowOffset = CGSizeMake(0.0, 8.0);
    navLayer.shadowOpacity = 0.75f;
    navLayer.shouldRasterize = YES;

    [super viewDidLoad];
    
//    [self loadEpubs:nil];
} 


-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = NO;
    [self.navigationController.navigationItem.backBarButtonItem setEnabled:NO];
    [self.navigationItem setHidesBackButton:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark FlipCardViewDataSource Methods

- (NSUInteger)flipCardViewNumberOfRows:(FlipCardView *)flipCardView {
    int rows = [self.epubBooks count] / 3;
    int mod_value = [self.epubBooks count] % 3;
    if (mod_value > 0) {
        return rows + 1;
    }else{
        return rows;
    }
}

- (NSUInteger)flipCardViewNumberOfColumns:(FlipCardView *)flipCardView {
    return 3;
}


- (CGPathRef)renderRect:(UIView*)imgView {
	UIBezierPath *path = [UIBezierPath bezierPathWithRect:imgView.bounds];
	return path.CGPath;
}

- (CGPathRef)renderTrapezoid:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(size.width * 0.33f, size.height * 0.66f)];
	[path addLineToPoint:CGPointMake(size.width * 0.66f, size.height * 0.66f)];
	[path addLineToPoint:CGPointMake(size.width * 1.15f, size.height * 1.15f)];
	[path addLineToPoint:CGPointMake(size.width * -0.15f, size.height * 1.15f)];
    
	return path.CGPath;
}

- (CGPathRef)renderEllipse:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	
	CGRect ovalRect = CGRectMake(0.0f, size.height + 5, size.width - 10, 15);
	UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:ovalRect];
	
	return path.CGPath;
}

- (CGPathRef)renderPaperCurl:(UIView*)imgView {
	CGSize size = imgView.bounds.size;
	CGFloat curlFactor = 15.0f;
	CGFloat shadowDepth = 5.0f;
    
	UIBezierPath *path = [UIBezierPath bezierPath];
	[path moveToPoint:CGPointMake(0.0f, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, 0.0f)];
	[path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
	[path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
			controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
			controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    
	return path.CGPath;
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (UIImage *)imageScaleAspectToMaxSize:(UIImage*)image withSize:(CGFloat)newSize {
	CGSize size = [image size];
	CGFloat ratio;
	if (size.width > size.height) {
		ratio = newSize / size.width;
	} else {
		ratio = newSize / size.height;
	}
	
	CGRect rect = CGRectMake(0.0, 0.0, ratio * size.width, ratio * size.height);
	UIGraphicsBeginImageContext(rect.size);
	[image drawInRect:rect];
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	return scaledImage;
}


- (UIView *)flipCardView:(FlipCardView *)flipCardView thumbnailViewForRow:(NSUInteger)row forColumn:(NSUInteger)column {
    
    UIView *groupView = [[UIView alloc]initWithFrame:CGRectMake(0,0,106,138)];
    [groupView setBackgroundColor:[UIColor clearColor]];
    
    [self.view bringSubviewToFront:groupView];
    
	UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    
    int indexValue = row * [self flipCardViewNumberOfColumns:flipCardView] + column;

    if (indexValue < [self.epubBooks count]) {
        
        label.textAlignment = UITextAlignmentCenter;
        [label setTextColor:[UIColor whiteColor]];
        label.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10];
        label.text = [[[self.epubBooks objectAtIndex:indexValue] lastPathComponent] stringByDeletingPathExtension];
        [label setNumberOfLines:0];
        
        UIImageView *coverView = [[UIImageView alloc]init];
        if (indexValue % 3 == 0) {            
            UIImageView *shelfView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 95, 320, 87)];
            [shelfView setImage:[UIImage imageNamed:@"Shelf-iPhone.png"]];
            [groupView addSubview:shelfView];
            
//            if (indexValue / 3 == 1) {
//                [coverView setFrame:CGRectMake(15, 7, 86, 100)];                
//            }
            [label setFrame:CGRectMake(15, 40, 86, 50)];
            [coverView setFrame:CGRectMake(15, 7, 86, 100)];
        }else if (indexValue % 3 == 1){
            [label setFrame:CGRectMake(10, 40, 86, 30)];
            [coverView setFrame:CGRectMake(10, 7, 86, 100)];
        }else{
            [label setFrame:CGRectMake(5, 40, 86, 30)];
            [coverView setFrame:CGRectMake(5, 7, 86, 100)];
        }
        [coverView setContentMode:UIViewContentModeScaleAspectFit];
        [coverView setBackgroundColor:[UIColor clearColor]];
        
        NSString *coverImgPath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@/cover.jpg",[self applicationDocumentsDirectory],[[[self.epubBooks objectAtIndex:indexValue] lastPathComponent] stringByDeletingPathExtension]];
        
        
        NSLog(@"Cover is : %@",coverImgPath);
        if([[NSFileManager defaultManager] fileExistsAtPath:coverImgPath]){
//            [[NSFileManager defaultManager] copyItemAtPath:
//            [[NSBundle mainBundle] pathForResource:@"cover_default" ofType:@"jpg"] 
//            toPath:coverImgPath error:nil];
//            [coverView setImage:[UIImage imageWithContentsOfFile:coverImgPath]];
            [coverView setImage:[self imageScaleAspectToMaxSize:[UIImage imageWithContentsOfFile:coverImgPath] withSize:200]];
            
        }else{
//            NSLog(@"show default cover image with book name.");
            [coverView setImage:[UIImage imageNamed:@"cover_default.jpg"]];
            [groupView addSubview:label];            
        }
        
        [groupView addSubview:coverView];

        
        coverView.layer.shadowColor = [UIColor blackColor].CGColor;
        coverView.layer.shadowOpacity = 0.7f;
        coverView.layer.shadowOffset = CGSizeMake(3.0f, 3.0f);
        coverView.layer.shadowRadius = 1.0f;
        coverView.layer.masksToBounds = NO;
        
        coverView.layer.shadowPath = [self renderRect:coverView];
//        coverView.layer.shadowPath = [self renderTrapezoid:coverView];
//        coverView.layer.shadowPath = [self renderEllipse:coverView];
//        coverView.layer.shadowPath = [self renderPaperCurl:coverView];
            
    }
    
//    [groupView addSubview:label];
	return groupView;
}

#pragma mark FlipCardViewDelegate Methods

- (CGFloat)flipCardView:(FlipCardView *)flipCardView heightForRow:(NSUInteger)row {
    return 138.0f;
}

- (CGFloat)flipCardView:(FlipCardView *)flipCardView widthForColumn:(NSUInteger)column {
    return 106.0f;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.epubBooks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return nil;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"%d",buttonIndex);
    if (buttonIndex == 1) {
        
        NSString *epubFilePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"epub_files"] stringByAppendingPathComponent:[self.epubBooks objectAtIndex:[alertView tag]]];

        NSString *unzippedFilePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"UnzippedEpub"] stringByAppendingPathComponent:[[self.epubBooks objectAtIndex:[alertView tag]]stringByDeletingPathExtension]];

        
        NSLog(@"epub path is %@",epubFilePath);
        NSLog(@"unzipped epub path is %@",unzippedFilePath);
        
        [[NSFileManager defaultManager] removeItemAtPath:epubFilePath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:unzippedFilePath error:nil];
        
        [self reloadBookShelf:nil];
    }
}

- (void)flipCardView:(FlipCardView *)flipCardView didLongPressedThumbnailForRow:(NSUInteger)row forColumn:(NSUInteger)column{
    
    int indexValue = row * [self flipCardViewNumberOfColumns:flipCardView] + column;
    if (indexValue < [self.epubBooks count]) {
        

        delAlertView = [[UIAlertView alloc]initWithTitle:@"删除" message:[NSString stringWithFormat:@"删除 %@",[self.epubBooks objectAtIndex:indexValue]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];

        NSString *filePath = [[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"epub_files"] stringByAppendingPathComponent:[self.epubBooks objectAtIndex:indexValue]];
        
        NSLog(@"%@",filePath);
        
        [delAlertView setTag:indexValue];
        [delAlertView show];

    }
    
}
    

- (void)flipCardView:(FlipCardView *)flipCardView didSelectThumbnailForRow:(NSUInteger)row forColumn:(NSUInteger)column {
   
    
        
    int indexValue = row * [self flipCardViewNumberOfColumns:flipCardView] + column;
    if (indexValue < [self.epubBooks count]) {
        
        hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];   
        hud.dimBackground = YES;  
        
        hud.labelText = @"正在打开书籍...";
        
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{          
            dispatch_async(dispatch_get_main_queue(), ^{  
                
                
                EPub *epubFile = [[EPub alloc] initWithEPubPath:[[[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"epub_files"] stringByAppendingPathComponent:[self.epubBooks objectAtIndex:indexValue]]];
                
                NSArray *chapterArray = [epubFile spineArray];
                
                if ([chapterArray count] > 0) {
                    CoreTextMagazineViewController *view = [[CoreTextMagazineViewController alloc]initWithNibName:@"CoreTextMagazineViewController_iPhone" bundle:nil];
                    [view setBookName:[self.epubBooks objectAtIndex:indexValue]];
                    [view setBookTitle:[[[self.epubBooks objectAtIndex:indexValue] lastPathComponent]stringByDeletingPathExtension]];
                    [view setChapters:chapterArray];
                    [view setChapterPosition:0];        
                    [self.navigationController pushViewController:view animated:YES];
                }
                
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES]; 
            });  
        });  
    }
    //Memory clean up
    
    //    DirectoryViewController *dvc = [[DirectoryViewController alloc]init];
    //    [dvc setEpubName:[[[self.epubBooks objectAtIndex:indexValue] lastPathComponent] stringByDeletingPathExtension]];
    //    [self.navigationController pushViewController:dvc animated:YES];
    
}

@end
