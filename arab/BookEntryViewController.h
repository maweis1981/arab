//
//  BookEntryViewController.h
//  arab
//
//  Created by Peter Ma on 3/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "AsyncImageView.h"
#import "EPub.h"

@interface BookEntryViewController : UIViewController<ASIHTTPRequestDelegate,ASIProgressDelegate,UIAlertViewDelegate>
{

    ASIHTTPRequest *httpRequest;
    
    IBOutlet UIProgressView *downloadProgress;
    
    NSString *bookUrl;
    NSString *epubUrl;
    
    NSDictionary *bookData;
    
    IBOutlet UILabel *bookNameLabel;
    
    IBOutlet AsyncImageView *coverView;
    
    IBOutlet UILabel *authorLabel;
    IBOutlet UILabel *publisherLabel;
    IBOutlet UILabel *publishDateLabel;
    
    IBOutlet UIScrollView *descriptionScrollView;
    IBOutlet UITextView *descriptionLabel;
    
}

@property(nonatomic,retain) ASIHTTPRequest *httpRequest;
@property(nonatomic,retain) IBOutlet UIProgressView *downloadProgress;

@property(nonatomic,retain) NSString *bookUrl;
@property(nonatomic,retain) NSString *epubUrl;

@property(nonatomic,retain) NSDictionary *bookData;

@property(nonatomic,retain) IBOutlet UILabel *bookNameLabel;

@property(nonatomic,retain) IBOutlet AsyncImageView *coverView;

@property(nonatomic,retain) IBOutlet UILabel *authorLabel;
@property(nonatomic,retain) IBOutlet UILabel *publisherLabel;
@property(nonatomic,retain) IBOutlet UILabel *publishDateLabel;

@property(nonatomic,retain) IBOutlet UIScrollView *descriptionScrollView;
@property(nonatomic,retain) IBOutlet UITextView *descriptionLabel;


-(IBAction)downloadEpubFile:(id)sender;

@end
