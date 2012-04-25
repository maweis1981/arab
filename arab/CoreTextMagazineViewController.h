//
//  CoreTextMagazineViewController.h
//  CoreTextMagazine
//
//  Created by Marin Todorov on 8/11/11.
//  Copyright 2011 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CTView.h"
//#import "AdMoGoView.h"
#import "DoMobDelegateProtocol.h"

#import "CTColumnView.h"

@class DoMobView;
@interface CoreTextMagazineViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,DoMobDelegate>{
    
    NSAttributedString *attString;
    int textPos_p;
    
    
    int totalPages;
    
    CGRect colRect;
    
    
    CTColumnView* content;
    
    NSMutableArray *pageArray;
    NSMutableArray *chapterPageArray;
    
//    AdMoGoView *adView;
    
	DoMobView *domobView;	
    
    
    NSArray *chapters;
    
    NSArray *fonts;
    NSArray *colors;
    
    int currentConfigState;
    
    int chapterPosition;
    int currentPageId;
    
//    CTView *contentView;
    NSString *bookName;
    
    NSString *bookTitle;
    
    NSString *currentPageContent;
    
    UILabel *bookNameLabel;
    
    UIColor *bgColor;
    
    UITableView *configsTable;
    
    UIButton *libraryBtn;
    UIButton *adjustFontBtn;
    UIButton *multiplierBtn;
    UIButton *multiplierLessBtn;
    
    UIButton *fontColorBtn;
    UIButton *fontBtn;
    UIButton *backgroundBtn;
    UIButton *directoryBtn;
    
    UIButton *bookmarkBtn;
    
    UIView *menuBarView;
    
    UIView *adjustView;
    
    UIImageView *bookmarkView;
    
    int bookmarkChapterPosition;
    int bookmarkPageId;
    
    //font mutliplier
    CGFloat multiplier;
    int backGroundId;
    NSString *font;
    NSString *fontColor;
}
@property(nonatomic)int chapterPosition;
@property(strong)NSArray *chapters;
//@property(strong)CTView *contentView;
@property(strong)UILabel *bookNameLabel;
@property(strong)NSString *bookName;
@property(strong)NSString *bookTitle;
@property(strong)NSString *currentPageContent;
@property(strong)UIButton *libraryBtn;
@property(strong)UIView *menuBarView;
//@property (nonatomic, retain) AdMoGoView *adView;
@property (retain,nonatomic) DoMobView *domobView;	

@property (retain, nonatomic) NSAttributedString *attString;


- (void)adjustAdSize;
-(void)callNavigationBar;
-(void)initPopoverConfigView:(id)sender;
-(void)showChapterContet:(BOOL)nextOrPrev;

-(void)repaintPageNo:(NSString *)labelText;
-(void)nextChapter;
-(void)prevChapter;
-(void)callNavigationBar;
-(void)page:(int)pageId;
-(void)renderPageNo;

@end
