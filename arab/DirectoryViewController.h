//
//  DirectoryViewController.h
//  arab
//
//  Created by 伟 马 on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTextMagazineViewController.h"

@interface DirectoryViewController : UITableViewController
{
    NSString *epubName;
    NSArray *chapters;
    
    NSMutableArray *bookmarks;
    
    CoreTextMagazineViewController *view;  
    
    int currentState;
}

@property(strong) NSString *epubName;
@property(strong) NSArray *chapters;
@property(strong) NSMutableArray *bookmarks;

@end
