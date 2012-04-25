//
//  FirstViewController.h
//  FlipCardNavigationView
//
//  Created by Kishikawa Katsumi on 10/03/08.
//  Copyright Kishikawa Katsumi 2010. All rights reserved.
//

#import "FlipCardView.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "JSONKit.h"
#import "BookStoreViewController.h"

@interface FirstViewController : UIViewController<UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource,MBProgressHUDDelegate,ASIHTTPRequestDelegate,UIAlertViewDelegate>
{
    FlipCardView *thumbnailView;
    ASIHTTPRequest *httpRequest;
    NSArray *epubBooks;
    MBProgressHUD *hud;
    
    UIAlertView *delAlertView;
//    NSMutableArray *epubArray;
}

@property(strong) ASIHTTPRequest *httpRequest;
@property(strong) NSArray *epubBooks;
@property(strong) MBProgressHUD *hud;

@property(nonatomic,retain)UIAlertView *delAlertView;
//@property(strong) NSMutableArray *epubArray;

@end
