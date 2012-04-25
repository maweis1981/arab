//
//  Bookmark.h
//  arab
//
//  Created by 伟 马 on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//



@interface Bookmark : NSObject
{
    NSString *bookName;
    int chapterPosition;
    int pageId;
    NSString *bookmarkTitle;
}

@property(strong) NSString *bookName;
@property(nonatomic,assign) int chapterPosition;
@property(nonatomic,assign) int pageId;
@property(strong) NSString *bookmarkTitle;

@end
