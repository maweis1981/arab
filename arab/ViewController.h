//
//  ViewController.h
//  arab
//
//  Created by 伟 马 on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageController.h"
#import "MBProgressHUD.h"
#import "FirstViewController.h"

@interface ViewController : UIViewController<MBProgressHUDDelegate>
{
    PageController *pageController;
    
    FirstViewController *firstVC;

    MBProgressHUD *hud;
}

@property(strong) PageController *pageController;
@property(strong) MBProgressHUD *hud;


@end
