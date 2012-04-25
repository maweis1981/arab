//
//  DataBase.h
//  EventRecord
//
//  Created by peter on 9/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"


@interface DataBase : NSObject
{
    sqlite3 *db;
}

-(NSString *) filePath;
-(void)openDB;

-(void)createBookmarkTable;
-(void)recordBookmark: (NSString *)bookName bookmark:(NSString *)bookmark chapter:(int)chapter_id page:(int)page_id;
-(NSMutableArray *)getBookmarks:(NSString*)bookName;
-(BOOL)isBookmarked:(NSString*)bookName chapterPosition:(int)chapter_id pageId:(int)page_id;
-(void)closeDB;
@end
