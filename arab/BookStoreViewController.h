//
//  BookStoreViewController.h
//  arab
//
//  Created by Peter Ma on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"
#import "JSONKit.h"
#import "BookCell.h"
#import "BookEntryViewController.h"

@interface BookStoreViewController : UITableViewController<MBProgressHUDDelegate,ASIHTTPRequestDelegate>
{

    NSMutableArray *bookArray;
    
    ASIHTTPRequest *httpRequest;
    MBProgressHUD *hud;
        
}

@property(strong) NSMutableArray *bookArray;
@property(strong) ASIHTTPRequest *httpRequest;
@property(strong) MBProgressHUD *hud;


@end
