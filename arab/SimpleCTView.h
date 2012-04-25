//
//  SimpleCTView.h
//  arab
//
//  Created by 伟 马 on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>

@interface SimpleCTView : UIView

@property (nonatomic, retain) NSString* text;
+(CGFloat)heightForAttributedString:(NSAttributedString *)attrString forWidth:(CGFloat)inWidth;
- (void)calculateHeight;
@end
