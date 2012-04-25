//
//  CTView.h
//  CoreTextMagazine
//
//  Created by Marin Todorov on 8/11/11.
//  Copyright 2011 Marin Todorov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CTColumnView.h"

@protocol CTViewDelegate <NSObject>
-(void)showAD;
-(void)repaintPageNo:(NSString *)labelText;
-(void)nextChapter;
-(void)prevChapter;
-(void)callNavigationBar;
-(void)page:(int)pageId;
@end

@interface CTView : UIScrollView<UIScrollViewDelegate> {

    id<CTViewDelegate> ctViewDelegate;    
    float frameXOffset;
    float frameYOffset;
    

    NSAttributedString* attString;
    
    NSMutableArray *contentsInChapters;
    NSMutableArray* frames;
    NSArray* images;
    int totalPages;
    BOOL pageControlUsed;
    UILabel *pageLabel;
    
    int pageId;
}

@property (strong) id<CTViewDelegate> ctViewDelegate;    
@property (retain, nonatomic) NSAttributedString* attString;
@property (retain, nonatomic) NSMutableArray *contentsInChapters;
@property (retain, nonatomic) NSMutableArray* frames;
@property (retain, nonatomic) NSArray* images;
@property (nonatomic) BOOL pageControlUsed;
@property (nonatomic, retain) UILabel *pageLabel;

@property (nonatomic) int pageId;


-(void)buildFrames;
-(void)setAttString:(NSAttributedString *)attString withImages:(NSArray*)imgs;
-(void)prevChapterLastPage;
-(void)reRenderPageNo:(int)page;
-(void)gotoPageNo:(int)page;
@end
