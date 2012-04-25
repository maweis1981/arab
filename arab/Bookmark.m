//
//  Bookmark.m
//  arab
//
//  Created by 伟 马 on 11/21/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bookmark.h"

@implementation Bookmark
@synthesize bookName,chapterPosition,pageId,bookmarkTitle;


- (void)encodeWithCoder:(NSCoder *)coder;
{
    NSLog(@"ENCODE %@,%@,%d,%d",bookName,bookmarkTitle,chapterPosition,pageId);
    
    [coder encodeObject:bookName forKey:@"bookName"];
    [coder encodeInt:chapterPosition forKey:@"chapterPosition"];
    [coder encodeInt:pageId forKey:@"pageId"];
    [coder encodeObject:bookmarkTitle forKey:@"bookmarkTitle"];
}

- (id)initWithCoder:(NSCoder *)coder;
{
    NSLog(@"INIT %@,%@,%d,%d",bookName,bookmarkTitle,chapterPosition,pageId);
    
    self = [[Bookmark alloc] init];
    if (self != nil)
    {
        bookName = [[coder decodeObjectForKey:@"bookName"] retain];
        chapterPosition = [coder decodeIntForKey:@"chapterPosition"];
        pageId = [coder decodeIntForKey:@"pageId"];
        bookmarkTitle = [coder decodeObjectForKey:@"bookmarkTitle"];
    }   
    return self;
}

@end
