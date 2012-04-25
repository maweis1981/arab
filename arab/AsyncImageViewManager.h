//
//  AsyncImageViewManager.h
//  socialReminder
//
//  Created by peter on 8/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncImageView.h"

@interface AsyncImageViewManager : NSObject {

}

+(AsyncImageView*)factoryWithUrl:(NSString*)url_str;
@end
