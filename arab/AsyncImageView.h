//
//  AsyncImageView.h
//  socialReminder
//
//  Created by peter on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class socialReminderAppDelegate;

@interface AsyncImageView : UIView {
    //could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to
    // to build into this class?
    
    NSURLConnection* connection; //keep a reference to the connection so we can cancel download in dealloc
    NSMutableData* data; //keep reference to the data so we can collect it as it downloads
    //but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class
    NSString *_str_url;

    
}
@property (nonatomic,retain)    NSString *_str_url;

- (void)loadImageFromURLStr:(NSString*)url_str;
- (void)loadImageFromURL:(NSURL*)url;
- (UIImage*) image;
@end
