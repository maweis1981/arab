//
//  CTView.m
//  CoreTextMagazine
//
//  Created by Marin Todorov on 8/11/11.
//  Copyright 2011 Marin Todorov. All rights reserved.
//

#import "CTView.h"
#import <CoreText/CoreText.h>
#import "CTColumnView.h"


@implementation CTView
@synthesize ctViewDelegate;

@synthesize attString;
@synthesize frames;
@synthesize images;
@synthesize pageControlUsed;
@synthesize pageLabel;
@synthesize pageId;
@synthesize contentsInChapters;


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)renderPageContent:(CGRect)textFrame columnIndex:(int)columnIndex textPos_p:(int *)textPos_p framesetter:(CTFramesetterRef)framesetter
{
    CGPoint colOffset = CGPointMake( (columnIndex+1)*frameXOffset + columnIndex*(textFrame.size.width - frameXOffset), frameYOffset);
    CGRect colRect = CGRectMake(0, 0, textFrame.size.width, textFrame.size.height - 30);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);
    
    //use the column path
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(*textPos_p, 0), path, NULL);
    CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
    
    //create an empty column view
    CTColumnView* content = [[[CTColumnView alloc] init] autorelease];
    content.backgroundColor = [UIColor clearColor];
    content.frame = CGRectMake(colOffset.x, colOffset.y, colRect.size.width, colRect.size.height) ;
    
    [content setCTFrame:(id)frame];  //6  
    
    [self.frames addObject: (id)frame];
    [self addSubview: content];
    
    int tempL = frameRange.length;
    [self.contentsInChapters addObject:[[attString string] substringWithRange:NSMakeRange(*textPos_p, tempL)]];
    //prepare for next frame
    *textPos_p += frameRange.length;       
    //CFRelease(frame);
    CFRelease(path);
}

- (void)buildFrames
{
    NSLog(@"Bounds W %f, H %f",self.bounds.size.width, self.bounds.size.height);
    contentsInChapters = [[NSMutableArray alloc]init];
    
    frameXOffset = 0;
    frameYOffset = 20;
//    pageId = 1;
    self.scrollEnabled = NO;
    self.pagingEnabled = YES;
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    
    self.frames = [NSMutableArray array];
    CGMutablePathRef path = CGPathCreateMutable(); 

    CGRect textFrame = CGRectInset(self.bounds, frameXOffset, frameYOffset);
    CGPathAddRect(path, NULL, textFrame );
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    
    int textPos = 0;
    int columnIndex = 0;
    
    while (textPos < [attString length]) {
        [self renderPageContent:textFrame columnIndex:columnIndex textPos_p:&textPos framesetter:framesetter];            
        NSLog(@"Text Position is %d",textPos);
        columnIndex++;
    }
    
    //set the total width of the scroll view
    totalPages = columnIndex; //7
    
    NSLog(@"page id is %d %d ",pageId,totalPages);    
    if (pageId > totalPages) {
        pageId = totalPages;
    }
    NSLog(@"page id is %d %d ",pageId,totalPages);
    
    [self reRenderPageNo:pageId];
    
    self.contentSize = CGSizeMake(totalPages*self.bounds.size.width, textFrame.size.height);
    NSLog(@"TEXT FRAME SIZE HEIGHT %f", textFrame.size.height);
}


-(void)prevChapterLastPage{
    NSLog(@"CALLL PREV !!!!! Total Page s is %d",totalPages);
    [self setContentOffset:CGPointMake(self.bounds.size.width * (totalPages - 1), 0) animated:NO];     
    int page = floor((self.contentOffset.x) / self.bounds.size.width) + 1;
    [self reRenderPageNo:page];                
}

-(void)setAttString:(NSAttributedString *)string withImages:(NSArray*)imgs
{
    self.attString = string;
    self.images = imgs;
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView 
{
    self.pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView 
{
    self.pageControlUsed = NO;    
    int page = floor((scrollView.contentOffset.x) / self.bounds.size.width) + 1;
    NSLog(@"END scroll view did scroll calcute page is %d",page);
    if (page > totalPages) {
        [ctViewDelegate nextChapter];        
    }
    if (page < 1) {
        [ctViewDelegate prevChapter];
    }
    [self reRenderPageNo:page];        
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    CGPoint pt = [[touches anyObject] locationInView:self];
    int tmpPage = floor((self.contentOffset.x) / self.bounds.size.width) + 1;
    NSLog(@"touches began content offset x  is %f  width is %f contentSize width is %f",self.contentOffset.x, self.bounds.size.width,self.contentSize.width );    
    CGFloat tmpSingleX =  pt.x -( (tmpPage - 1)* self.bounds.size.width);
    NSLog(@"touches began the page id is %d",tmpPage);
    
    if (tmpSingleX < 110.0f) {
        if (self.contentSize.width > 0 && tmpPage > 1) {
            [self setContentOffset:CGPointMake(self.bounds.size.width * (tmpPage - 2), 0) animated:YES];        
        }else{
            [ctViewDelegate prevChapter];
        }
        self.pageControlUsed = YES;
    }else if(tmpSingleX > 210.0f){
        if (self.contentSize.width > 0 && tmpPage < totalPages ) {
            [self setContentOffset:CGPointMake(self.bounds.size.width * (tmpPage), 0) animated:YES];            
        }else{
            [ctViewDelegate nextChapter];
        }
        self.pageControlUsed = YES;
    }else{
        [ctViewDelegate callNavigationBar];
    }
    
    self.pageControlUsed = NO;
}


-(void)gotoPageNo:(int)page{
    //    NSLog(@"page Width [%f] offset is %f ",pageWidth,scrollView.contentOffset.x);
    if (self.contentSize.width > 0 && self.contentSize.width > self.contentOffset.x && self.contentOffset.x >= 0) {
        [self setContentOffset:CGPointMake(self.bounds.size.width * (page - 1), 0) animated:NO];        
    }

}

-(void)reRenderPageNo:(int)page{
    if (page > [self.contentsInChapters count]) {
        page = [self.contentsInChapters count] - 1;
    }else if(page == 0){
        page = 1;
    }
    pageId = page;
    
    NSLog(@"render page no. page is %d  contents in this page %@",page,[self.contentsInChapters objectAtIndex:page - 1]);    
    [ctViewDelegate page:pageId];
    [ctViewDelegate repaintPageNo:[NSString stringWithFormat:@"%d / %d",pageId, totalPages]];
}


-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    NSLog(@"AAA END page Width [%f] offset is %f ",self.bounds.size.width,scrollView.contentOffset.x);
    int page = floor((scrollView.contentOffset.x) / self.bounds.size.width) + 1;
    NSLog(@"AAA END scroll view did scroll calcute page is %d",page);
    
    if (page > totalPages) {
        [ctViewDelegate nextChapter];        
    }
    
    if (page < 1) {
        [ctViewDelegate prevChapter];
    }
    
    [self reRenderPageNo:page];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (self.pageControlUsed) {
//        return;
//    }
//    NSLog(@"page Width [%f] offset is %f ",self.bounds.size.width,scrollView.contentOffset.x);
//    int page = floor((scrollView.contentOffset.x) / self.bounds.size.width);
////    NSLog(@"%f",scrollView.contentOffset.x);
//    //    NSLog(@"page....%d.",page);
//    //    NSLog(@"Current Page [%d] Total %d ",page,totalPages);
//
////    if (page == totalPages) {
////        self.pageControlUsed = YES;
////        if (self.pageControlUsed ) {
////            [ctViewDelegate showAD];
////        }
////    }else
//    NSLog(@"scroll view did scroll calcute page is %d",page);
//    
//    if (page >= totalPages) {
//        self.pageControlUsed = YES;
//        if (self.pageControlUsed ) {
//            [ctViewDelegate nextChapter];
//        }
//    }else if (page == -1 ){
//        self.pageControlUsed = YES;
//        if (self.pageControlUsed ) {
//            [ctViewDelegate prevChapter];
//        }
////    }else if (page == 0 ){
////        self.pageControlUsed = YES;
////        page = 1;
////        if (self.pageControlUsed ) {
////        }        
//    }else{
//        self.pageControlUsed = YES;
////        if (self.pageControlUsed ) {
////            //            if (pageId != page) {
////            //                NSLog(@"render page NO.");
////            [self reRenderPageNo:page];                
////            //            }
////        }
//    }
}


-(void)dealloc
{
    self.attString = nil;
    self.frames = nil;
    self.images = nil;
    [super dealloc];
}

@end
