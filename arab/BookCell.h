//
//  BookCell.h
//  arab
//
//  Created by Peter Ma on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView.h"

@interface BookCell : UITableViewCell
{
    IBOutlet UILabel *titleLabel;
 
    IBOutlet UILabel *descriptionLabel;
    
    IBOutlet AsyncImageView *coverView;
}

@property(nonatomic,retain) IBOutlet UILabel *titleLabel;
@property(nonatomic,retain) IBOutlet UILabel *descriptionLabel;
@property(nonatomic,retain) IBOutlet AsyncImageView *coverView;
@end
