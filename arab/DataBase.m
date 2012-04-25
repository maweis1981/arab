//
//  DataBase.m
//  EventRecord
//
//  Created by peter on 9/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DataBase.h"

@implementation DataBase


-(NSString *)filePath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSLog(@"DB Path is %@",documentsDir);
    return [documentsDir stringByAppendingPathComponent:@"database.sqlite"];
}

-(void)openDB{
    //--create database--
    if (sqlite3_open([[self filePath] UTF8String], &db) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"Database failed to open.");
    }
}
    
//    [self createTableNamed:@"Event" withField1:@"TITLE" withField2:@"DESCRIPTION"];
-(void)createBookmarkTable{
    char *err;
    NSString *sql = [NSString stringWithString:
                     @"CREATE TABLE IF NOT EXISTS 'BOOKMARKS' ('id' INTEGER PRIMARY KEY  AUTOINCREMENT  NOT NULL , 'BOOKNAME' TEXT, 'BOOKMARK' TEXT, 'CHAPTER_ID' INTEGER, 'PAGE_ID' INTEGER,'CREATED_DATETIME' TIMESTAMP DEFAULT (datetime('now', 'localtime')))"];
    
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"Tabled failed to create");
    }    
}

-(void)recordBookmark: (NSString *)bookName bookmark:(NSString *)bookmark chapter:(int)chapter_id page:(int)page_id{
    NSString *sql = [NSString stringWithFormat:
                     @"insert into 'main'.'BOOKMARKS' ('BOOKNAME','BOOKMARK','CHAPTER_ID','PAGE_ID') values ('%@','%@',%d,%d)",
                     bookName,bookmark,chapter_id,page_id];
    char *err;
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(db);
        NSAssert(0, @"Error updating table.");
    }    
}

-(NSMutableArray *)getBookmarks:(NSString*)bookName {
    //---retrieve rows---
    NSMutableArray *bookmarkArray = [[NSMutableArray alloc]init];
    
    //    NSString *qsql = @"SELECT * FROM EventRecord where eventTitle ='%@'";
    NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM BOOKMARKS where BOOKNAME = '%@'",bookName];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) ==
        SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            char *field1 = (char *) sqlite3_column_text(statement, 0);
            NSString *field1Str = [[NSString alloc] initWithUTF8String: field1];
            char *field2 = (char *) sqlite3_column_text(statement, 1);
            NSString *field2Str = [[NSString alloc] initWithUTF8String: field2];
            char *field3 = (char *) sqlite3_column_text(statement, 2);
            NSString *field3Str = [[NSString alloc] initWithUTF8String: field3];
            char *field4 = (char *) sqlite3_column_text(statement, 3);
            NSString *field4Str = [[NSString alloc] initWithUTF8String: field4];
            char *field5 = (char *) sqlite3_column_text(statement, 4);
            NSString *field5Str = [[NSString alloc] initWithUTF8String: field5];
            char *field6 = (char *) sqlite3_column_text(statement, 5);
            NSString *field6Str = [[NSString alloc] initWithUTF8String: field6];

            NSDictionary *obj = [[NSDictionary alloc]initWithObjectsAndKeys:field1Str,@"id",field2Str,@"bookname",
                                 field3Str, @"bookmark", field4Str,@"chapter_id",field5Str,@"page_id",field6Str,@"created_datetime",nil];
            
            [bookmarkArray addObject:obj];                        
        }
        //---deletes the compiled statement from memory---
        sqlite3_finalize(statement);
    }
    return bookmarkArray;
}


-(BOOL)isBookmarked:(NSString*)bookName chapterPosition:(int)chapter_id pageId:(int)page_id{
    BOOL ret = false;
    //    NSString *qsql = @"SELECT * FROM EventRecord where eventTitle ='%@'";
    NSString *qsql = [NSString stringWithFormat:@"SELECT * FROM BOOKMARKS where BOOKNAME = '%@' AND CHAPTER_ID = %d AND PAGE_ID = %d",bookName,chapter_id,page_id];
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2( db, [qsql UTF8String], -1, &statement, nil) ==
        SQLITE_OK) {
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            ret = true;
        }
        //---deletes the compiled statement from memory---
        sqlite3_finalize(statement);
    }
    return ret;
}


-(void)closeDB{
    sqlite3_close(db);
}

-(void)dealloc{
    sqlite3_close(db);
}
@end
