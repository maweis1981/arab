#import "CoreTextMagazineViewController.h"
//#import "CTView.h"

#import "CTColumnView.h"
#import "EPub.h"
#import "Chapter.h"
#import "DTAttributedTextView.h"
#import "DTAttributedTextContentView.h"
#import "NSAttributedString+HTML.h"
#import "DTTextAttachment.h"
#import "DirectoryViewController.h"
#import "DataBase.h"
#import <QuartzCore/QuartzCore.h>

#import "DoMobView.h"

@implementation CoreTextMagazineViewController
@synthesize chapterPosition;
@synthesize chapters;
//@synthesize contentView;
@synthesize bookName;
@synthesize bookNameLabel;
@synthesize libraryBtn;
@synthesize menuBarView;
@synthesize bookTitle;
//@synthesize adView;
@synthesize domobView;

@synthesize attString;
@synthesize currentPageContent;

- (UIViewController *)viewControllerForPresentingModalView{
    return self; //返回的对象为adView的父视图控制器
}


-(void)calPages{
    //is page id.
    pageArray = [[NSMutableArray alloc]init];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);
    
    //    NSLog(@"%@",attString);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
    //use the column path

    int textPos = 0;
    int columnIndex = 0;
   
    NSDictionary *pageObj = [[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:0],@"text_pos",[[NSNumber alloc]initWithInt:columnIndex],@"page_id", nil];
    [pageArray addObject:pageObj];

    while (textPos < [attString length]) {

        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5

        textPos += frameRange.length;
        columnIndex ++;
                
        NSDictionary *pageObj = [[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:textPos],@"text_pos",[[NSNumber alloc]initWithInt:columnIndex],@"page_id", nil];
        
        NSLog(@"cal page object is %@",pageObj);
        [pageArray addObject:pageObj];
        //CFRelease(frame);
    }
    CFRelease(path);    
//    [self renderPageNo];
}

- (CATransition *) getAnimation:(NSString *) direction
{
    CATransition *animation = [CATransition animation];
    [animation setDelegate:self];
    // [animation setType:@"oglFlip"]; 
    [animation setType:kCATransitionFade];
    [animation setSubtype:direction];
    [animation setDuration:0.3f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    return animation;
}


-(void)showPageContent{
    
    if ([pageArray count] > 0) {
        NSLog(@"current page id is %d",currentPageId);
        [self renderPageNo];
        textPos_p = [[[pageArray objectAtIndex:currentPageId - 1] objectForKey:@"text_pos"] intValue];
    }else{
        if (currentPageId == 1) {
            textPos_p = 0;            
        }else{
            NSLog(@"need load text position by bookmark page id");
            textPos_p = 0;
            currentPageId = 1;
        }
    }
    
    NSLog(@"start text position is %d",textPos_p);
        
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);

    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)attString);
        
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos_p, 0), path, NULL);
    CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
   
    [content setCTFrame:(id)frame];
    [content setNeedsDisplay];
    
    [self setCurrentPageContent:[[attString string] substringWithRange:NSMakeRange(textPos_p, frameRange.length)]];
    textPos_p += frameRange.length;       
    CFRelease(path);
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{    
    CGPoint pt = [[touches anyObject] locationInView:self.view];
    
    if (pt.x < 110.0f) {
        if (currentPageId == 1) {
            [self prevChapter];
            return;        
        }
        currentPageId --;
        NSDictionary *obj = [pageArray objectAtIndex:currentPageId];
        textPos_p = [[obj objectForKey:@"text_pos"] intValue];
        
        CATransition *animation = [self getAnimation:kCATransitionFromLeft];
        [[self.view layer] addAnimation:animation forKey:@"custom animation"];

//        columnIndex = [[obj objectForKey:@"page_id"] intValue];
    }else if(pt.x > 210.0f){
        if(currentPageId + 1 == [pageArray count]){
            [self nextChapter];
            return;
        }
        currentPageId ++;
        NSDictionary *obj = [pageArray objectAtIndex:currentPageId];
        textPos_p = [[obj objectForKey:@"text_pos"] intValue];
        
        CATransition *animation = [self getAnimation:kCATransitionFromRight];
        [[self.view layer] addAnimation:animation forKey:@"custom animation"];
        
//        columnIndex = [[obj objectForKey:@"page_id"] intValue];        
    }else{
        [self callNavigationBar];
    }

    [self showPageContent];
}


-(NSMutableArray *)calPages:(NSAttributedString *)tempAttStr{
    //is page id.
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, colRect);
    
    //    NSLog(@"%@",attString);
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)tempAttStr);
    //use the column path
    
    int textPos = 0;
    int columnIndex = 0;
    
    NSDictionary *pageObj = [[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:0],@"text_pos",[[NSNumber alloc]initWithInt:columnIndex],@"page_id", nil];
    NSMutableArray *pageArrayForChapter = [[NSMutableArray alloc]init];
    
    [pageArrayForChapter addObject:pageObj];
    
    while (textPos < [tempAttStr length]) {
        
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(textPos, 0), path, NULL);
        CFRange frameRange = CTFrameGetVisibleStringRange(frame); //5
     
        textPos += frameRange.length;
        columnIndex ++;
        
        
        NSDictionary *pageObj = [[NSDictionary alloc]initWithObjectsAndKeys:[[NSNumber alloc]initWithInt:textPos],@"text_pos",[[NSNumber alloc]initWithInt:columnIndex],@"page_id",nil];
        
        [pageArrayForChapter addObject:pageObj];
        //CFRelease(frame);
    }
    CFRelease(path);    
    //    [self renderPageNo];
    return pageArrayForChapter;
}

-(void)calBookPageNums{
    
    totalPages = 0;
    chapterPageArray = [[NSMutableArray alloc]init];
    
    for (Chapter *tempChapter in self.chapters) {
            
        NSString *readmePath = [tempChapter spinePath];    
       
        if (readmePath == NULL) {
            return;
        }
        NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
        NSLog(@"%@",html);
        
        NSRange start = [html rangeOfString:@"<body"];
        NSRange end = [html rangeOfString:@"</body>"];
        
        
        html = [html substringWithRange:NSMakeRange(start.location, html.length - start.location - (html.length - end.location - end.length))];

        NSLog(@"body[%@]",html);
        
        NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];

        CGSize maxImageSize = CGSizeMake(200, 300);  
        
        NSNumber *headIndent = [[NSNumber alloc]initWithInt:36.0];

        NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                               [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                               headIndent,DTDefaultFirstLineHeadIndent,
                               headIndent,DTDefaultHeadIndent,
                               //need to save into NSUserDefault
                               [NSNumber numberWithFloat:multiplier], NSTextSizeMultiplierDocumentOption,                           
                               font, DTDefaultFontFamily,
                               fontColor, DTDefaultTextColor,
                               nil];
        
        NSAttributedString  *tempAttString = [[NSAttributedString alloc]initWithHTML:data options:attrs documentAttributes:nil];
     
        if ([tempAttString length] > 0) {
            NSMutableArray *tempChapterPageArray = [self calPages:tempAttString];            
            NSLog(@"Chapter Title %@ Pages is %d   %d",[tempChapter title],[tempChapterPageArray count],totalPages);
         
            totalPages += [tempChapterPageArray count];   
            
            //add the chapter page array into global chapter page arry .
            [chapterPageArray addObject:tempChapterPageArray];
        }else{
            NSLog(@"empty content chapter.");
        }
    }
    
    NSLog(@"total pages is %d",totalPages);
}



-(void)showChapterContet:(BOOL)nextOrPrev{

    NSLog(@"Chapter Positon is %d",chapterPosition);
    if (chapterPosition < 0) {
        chapterPosition = 0;
    }else if (chapterPosition >= [self.chapters count]) {
        
        [self.navigationController popViewControllerAnimated:YES];
//       
//        UIButton *overBackBtn = [[UIButton alloc]initWithFrame:CGRectMake(20, 200, 280, 400)];
//        //        [overBackBtn setTitle:@"back" forState:UIControlStateNormal];
//        [overBackBtn addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
//        [overBackBtn setBackgroundColor:[UIColor clearColor]];
//        [self.view addSubview:overBackBtn];
//
//        
//        UIView *readOverView = [[UIView alloc]initWithFrame:self.view.frame];
//        [readOverView setBackgroundColor:[UIColor whiteColor]];
//        UILabel *doneLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 200, 280, 100)];
//        [doneLabel setText:@"本书结束。"];
//        [readOverView addSubview:doneLabel];
//        [self.view addSubview:readOverView];
//        [self.view bringSubviewToFront:readOverView];
//        
//                
//        [self.view setUserInteractionEnabled:NO];
        return;
    }
    
    NSString *readmePath = [(Chapter*)[self.chapters objectAtIndex:chapterPosition]spinePath];    
    NSLog(@"%@",readmePath==NULL?@"NULL":@"NOT NULL");
    if (readmePath == NULL) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@_spins",bookTitle]];
        [self performSelector:@selector(gotoBack:)];
        return;
    }
	NSString *html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
        
    NSRange start = [html rangeOfString:@"<body"];
    NSRange end = [html rangeOfString:@"</body>"];

    html = [html substringWithRange:NSMakeRange(start.location, html.length - start.location - (html.length - end.location - 7))];
	
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
	// Create attributed string from HTML
//	CGSize maxImageSize = CGSizeMake(self.view.bounds.size.width - 20.0, self.view.bounds.size.height - 20.0);
	CGSize maxImageSize = CGSizeMake(200, 300);  

    NSNumber *headIndent = [[NSNumber alloc]initWithInt:0];
    //apply the current text style //2
    NSDictionary* attrs = [NSDictionary dictionaryWithObjectsAndKeys:
                           [NSValue valueWithCGSize:maxImageSize], DTMaxImageSize,
                           headIndent,DTDefaultFirstLineHeadIndent,
                           //need to save into NSUserDefault
                           [NSNumber numberWithFloat:multiplier], NSTextSizeMultiplierDocumentOption,                           
                           font, DTDefaultFontFamily,
                           fontColor, DTDefaultTextColor,
                           nil];

    attString = [[NSAttributedString alloc]initWithHTML:data options:attrs documentAttributes:nil];

    
    [self calPages];
    [self showPageContent];
        
    NSLog(@"core text render done.");
}

-(void)gotoBack:(id)sender{
    NSLog(@"go back.");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)configView:(id)sender{
    multiplier = 1.5;
    fontColor = @"#338855";
    font = @"Hiragino Sans GB W3";
    [self showChapterContet:YES];
}

-(void)configMutliplier:(id)sender{
    if ([sender tag] == 0) {
        multiplier = multiplier + 0.1;
        NSLog(@"%f",multiplier);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:multiplier forKey:@"multiplier"];
    }else{
        multiplier = multiplier - 0.1;
        NSLog(@"%f",multiplier);
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setFloat:multiplier forKey:@"multiplier"];
    }

    [self showChapterContet:YES];    
}

-(void)configFontColor:(id)sender{
    currentConfigState = 1;
    [configsTable reloadData];
    [configsTable setHidden:NO];
}

-(void)configFont:(id)sender{
    currentConfigState = 0;
    [configsTable reloadData];
    [configsTable setHidden:NO];
}

-(void)configBackGround:(id)sender{
    if ([sender tag] == 0) {
        [sender setTag:1];
    }else{
        [sender setTag:0];
    }
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if ([sender tag] == 0) {
        bgColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"Default-Book-iPhone.png"]];        
        [prefs setValue:@"Default-Book-iPhone.png" forKey:@"background"];
    }else if([sender tag] == 1){
        bgColor = [[UIColor alloc]initWithPatternImage:[UIImage imageNamed:@"Default-Book-Sepia-iPhone.png"]];        
        [prefs setValue:@"Default-Book-Sepia-iPhone.png" forKey:@"background"];
    }

    
    [self.view setBackgroundColor:bgColor];
}

-(void)addBookmark:(id)sender{
    NSLog(@"book mark this %d %d ",chapterPosition,currentPageId);
    if (currentPageId >= 1) {     

        NSString *bookmarkTitle;
        if ([currentPageContent length] > 20) {
             bookmarkTitle = [currentPageContent substringWithRange:NSMakeRange(0, 20)];
        }else{
            bookmarkTitle = currentPageContent;
        }
        DataBase *db = [[DataBase alloc]init];
        [db openDB];
        [db recordBookmark:bookTitle bookmark:bookmarkTitle chapter:chapterPosition page:currentPageId];
        [db closeDB];
        NSLog(@"done......");
    }
    [bookmarkView setHidden:NO];
}

-(void)checkIsBookMark{
    DataBase *db = [[DataBase alloc]init];
    [db openDB];
    if([db isBookmarked:bookTitle chapterPosition:chapterPosition pageId:currentPageId]){
        [bookmarkView setHidden:NO];
    }else{
        [bookmarkView setHidden:YES];
    }
    [db closeDB];
}

- (void)viewDidLoad
{    
    
    [self performSelectorInBackground:@selector(calBookPageNums) withObject:nil];
    
    content = [[[CTColumnView alloc] init] autorelease];
    content.backgroundColor = [UIColor clearColor];
    colRect = CGRectMake(20, 20, 280, 400-50);
    
    content.frame = CGRectMake(0, 0, 320, 460-50);

    [content setClearsContextBeforeDrawing:YES];    
    [self.view addSubview: content];
    
    [self.view setUserInteractionEnabled:YES];
    
    fonts = [[NSArray alloc]initWithObjects:@"STHeitiJ-Light",@"STHeitiSC-Medium",@"ArialMT",@"Helvetica-Light",@"Palatino-Roman",@"Hiragino Sans GB W3", nil];
    colors = [[NSArray alloc]initWithObjects:@"#000000",@"#111111",@"#887788",@"#634578",@"#108345",nil];
    
    bookmarkView = [[UIImageView alloc]initWithFrame:CGRectMake(280, 0, 38, 52)];
    [bookmarkView setImage:[UIImage imageNamed:@"bookmark-ribbon-iPhone.png"]];
    [self.view addSubview:bookmarkView];
    [bookmarkView setHidden:YES];
    
    
    bookNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    [bookNameLabel setBackgroundColor:[UIColor clearColor]];
    [bookNameLabel setTextAlignment:UITextAlignmentCenter];
    [bookNameLabel setFont:[UIFont fontWithName:@"STHeitiSC-Medium" size:10]];
    [bookNameLabel setTextColor:[UIColor brownColor]];
    [bookNameLabel setAlpha:0.6];
    [self.view addSubview: bookNameLabel];
//    [bookNameLabel setText:bookTitle];
    [bookNameLabel setNumberOfLines:0];
    
//    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
    self.navigationController.navigationBarHidden = YES;
    [super viewDidLoad];
//    [self showChapterContet:YES];
        
    menuBarView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [menuBarView setBackgroundColor:[UIColor clearColor]];
//    [menuBarView setAlpha:0.6f];
    [menuBarView setHidden:YES];
    [self.view addSubview:menuBarView];
    
    UIImage *image = [UIImage imageNamed:@"book_button_library_background.png"]; 
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width/2) topCapHeight:floorf(image.size.height/2)];
    
    libraryBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 6, 60, 34)];
    [libraryBtn setBackgroundImage:image forState:UIControlStateNormal];
    [libraryBtn setTitle:@"书架" forState:UIControlStateNormal];
    [libraryBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [libraryBtn addTarget:self action:@selector(gotoBack:) forControlEvents:UIControlEventTouchUpInside];
    


    
    directoryBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, 6, 40, 34)];
    [directoryBtn setBackgroundImage:image forState:UIControlStateNormal];
//     [UIImage imageNamed:@"ToC.png"] forState:UIControlStateNormal];
//    [directoryBtn setBackgroundColor:[UIColor clearColor]];
    [directoryBtn setImage:[UIImage imageNamed:@"ToC.png"] forState:UIControlStateNormal];
    [directoryBtn setTag:0];
    [directoryBtn addTarget:self action:@selector(showDirectory:) forControlEvents:UIControlEventTouchUpInside];
                     

    adjustFontBtn = [[UIButton alloc]initWithFrame:CGRectMake(130, 6, 40, 34)];
    [adjustFontBtn setBackgroundImage:image forState:UIControlStateNormal];
    [adjustFontBtn setTitle:@"设置" forState:UIControlStateNormal];
    [adjustFontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [adjustFontBtn setTag:0];
    [adjustFontBtn addTarget:self action:@selector(popoverConfigView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    bookmarkBtn =  [[UIButton alloc]initWithFrame:CGRectMake(270, 6, 40, 34)];
//    [bookmarkBtn setBackgroundImage:image forState:UIControlStateNormal];
    [bookmarkBtn setImage:[UIImage imageNamed:@"bookmark-book.png"] forState:UIControlStateNormal];
    [bookmarkBtn setTag:0];
    [bookmarkBtn addTarget:self action:@selector(addBookmark:) forControlEvents:UIControlEventTouchUpInside];

    [menuBarView addSubview:libraryBtn];
    [menuBarView addSubview:directoryBtn];
    [menuBarView addSubview:adjustFontBtn];    
    [menuBarView addSubview:bookmarkBtn];    
    
    [self initPopoverConfigView:nil];
    
    NSLog(@"view did load done.");
    
    self.domobView = [DoMobView requestDoMobViewWithSize:CGSizeMake(320, 48) WithDelegate:self];


    

//    self.adView= [AdMoGoView requestAdMoGoViewWithDelegate:self
//                                                 AndAdType:AdViewTypeNormalBanner];
//    [self.adView setDelegate:self];
    
    //根据需要添加不同类型的广告类型
    //typedef enum { //广告类型变量
    //AdViewTypeUnknown = 0, //
    // AdViewTypeNormalBanner = 1, //iPhone横幅广告
    // AdViewTypeLargeBanner = 2, //iPad平板大横幅广告
    // AdViewTypeMediumBanner = 3, //iPad平板小横幅广告
    // AdViewTypeRectangle = 4, //iPad平板矩形广告
    // AdViewTypeSky = 5, //
    // AdViewTypeFullScreen = 6, //iPhone全屏广告
    // AdViewTypeVideo = 7, //
    // AdViewTypeiPadNormalBanner = 8,//iPad兼容横幅
    //} AdViewType;
//    [adView setFrame:CGRectZero];
//    [self.view addSubview:adView];
}



-(void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBarHidden = YES;

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    font =    [prefs stringForKey:@"font"];
    fontColor =   [prefs stringForKey:@"font_color"];
    multiplier = [prefs floatForKey:@"multiplier"];

    NSString *readBackgroundColor = [prefs valueForKey:@"background"];
//     setValue:bgColor forKey:@"background"];
    if (readBackgroundColor == nil) {
        readBackgroundColor = @"Default-Book-iPhone.png";
    }
    [self.view setBackgroundColor:[[UIColor alloc]initWithPatternImage:[UIImage imageNamed:readBackgroundColor]]];
    
    if (font == nil) {
        font = @"STHeitiJ-Light";
    }
    if (fontColor == nil) {
        fontColor = @"#000000";
    }
    if (multiplier == 0.0f) {
        multiplier = 1.0;
    }
    
    bookmarkChapterPosition = [prefs integerForKey:[NSString stringWithFormat:@"%@_lastread_chapterId",bookTitle]];
    bookmarkPageId = [prefs integerForKey:[NSString stringWithFormat:@"%@_lastread_pageId",bookTitle]];
    
    if (bookmarkChapterPosition > 0 && bookmarkPageId > 0) {
        chapterPosition = bookmarkChapterPosition;
        currentPageId = bookmarkPageId;
    }else{
        currentPageId = 1;
    }

    [self showChapterContet:YES];

    [self calPages];
    NSLog(@"view will appear done.");
}

-(void)popoverConfigView:(id)sender{
    [adjustView setHidden:!adjustView.hidden];
    if (!adjustView.hidden) {
        [self.view bringSubviewToFront:adjustView];
    }
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (currentConfigState == 0) {
        return [fonts count];
    }else{
        return [colors count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}


//#009900
-(UIColor *) colorWithHexString: (NSString *) stringToConvert
{
	NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
	
	// String should be 6 or 8 characters
	if ([cString length] < 6) return [UIColor blackColor];
	
	// strip 0X if it appears
	if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
	if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
	
	if ([cString length] != 6) return [UIColor blackColor];
	
	// Separate into r, g, b substrings
	NSRange range;
	range.location = 0;
	range.length = 2;
	NSString *rString = [cString substringWithRange:range];
	
	range.location = 2;
	NSString *gString = [cString substringWithRange:range];
	
	range.location = 4;
	NSString *bString = [cString substringWithRange:range];
	
	// Scan values
	unsigned int r, g, b;
	[[NSScanner scannerWithString:rString] scanHexInt:&r];
	[[NSScanner scannerWithString:gString] scanHexInt:&g];
	[[NSScanner scannerWithString:bString] scanHexInt:&b];
	
	return [UIColor colorWithRed:((float) r / 255.0f)
						   green:((float) g / 255.0f)
							blue:((float) b / 255.0f)
						   alpha:1.0f];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setFont:[UIFont fontWithName:@"STHeitiJ-Light" size:14]];
    if (currentConfigState == 0) {
        [cell.textLabel setText:[fonts objectAtIndex:indexPath.row]];
        [cell.textLabel setFont:[UIFont fontWithName:[fonts objectAtIndex:indexPath.row] size:12]];
    }else{
        [cell.textLabel setText:[colors objectAtIndex:indexPath.row]];
        [cell.textLabel setTextColor:[self colorWithHexString:[colors objectAtIndex:indexPath.row]]];
    }
    return cell;   
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (currentConfigState == 0) {
        font = [fonts objectAtIndex:indexPath.row];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:font forKey:@"font"];
        [self showChapterContet:YES];
    }else{
        fontColor = [colors objectAtIndex:indexPath.row];
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        [prefs setValue:font forKey:@"font_color"];
        [self showChapterContet:YES];
    }
    [tableView setHidden:YES];
}

-(void)initConfigTableView:(id)sender{
    configsTable = [[UITableView alloc]initWithFrame:CGRectMake(30, 50, 220, 120) style:UITableViewStylePlain];
    [configsTable setBackgroundColor:[UIColor whiteColor]];
    [configsTable setDataSource:self];
    [configsTable setDelegate:self];
}


-(void)initPopoverConfigView:(id)sender{
    
    UIImage *image = [UIImage imageNamed:@"book_button_library_background.png"]; 
    image = [image stretchableImageWithLeftCapWidth:floorf(image.size.width/2) topCapHeight:floorf(image.size.height/2)];
    
    multiplierLessBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 50, 80, 30)];
    [multiplierLessBtn setBackgroundImage:image forState:UIControlStateNormal];
    [multiplierLessBtn setImage:[UIImage imageNamed:@"littleA.png"] forState:UIControlStateNormal];
    [multiplierLessBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [multiplierLessBtn setTag:1];
    [multiplierLessBtn addTarget:self action:@selector(configMutliplier:) forControlEvents:UIControlEventTouchUpInside];
    
    multiplierBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 50, 80, 30)];
    [multiplierBtn setBackgroundImage:image forState:UIControlStateNormal];
    [multiplierBtn setImage:[UIImage imageNamed:@"littleA.png"] forState:UIControlStateNormal];
    [multiplierBtn setTag:0];
    [multiplierBtn addTarget:self action:@selector(configMutliplier:) forControlEvents:UIControlEventTouchUpInside];
  
    fontColorBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 90, 80, 30)];
    [fontColorBtn setBackgroundImage:image forState:UIControlStateNormal];
    [fontColorBtn setTitle:@"文字颜色" forState:UIControlStateNormal];
    [fontColorBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [fontColorBtn setTag:(NSInteger)@"#000000"];
    [fontColorBtn addTarget:self action:@selector(configFontColor:) forControlEvents:UIControlEventTouchUpInside];
//    
    fontBtn = [[UIButton alloc]initWithFrame:CGRectMake(150, 90, 80, 30)];
    [fontBtn setBackgroundImage:image forState:UIControlStateNormal];
    [fontBtn setTitle:@"字体" forState:UIControlStateNormal];
    [fontBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [fontBtn setTag:(NSInteger)@"Hiragino Sans GB W3"];
    [fontBtn setTag:(NSInteger)@"STHeitiJ-Light"];    
    [fontBtn addTarget:self action:@selector(configFont:) forControlEvents:UIControlEventTouchUpInside];
//    
    backgroundBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 130, 80, 30)];
    [backgroundBtn setBackgroundImage:image forState:UIControlStateNormal];
    [backgroundBtn setTitle:@"背景色" forState:UIControlStateNormal];
    [backgroundBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backgroundBtn setTag:0];
    [backgroundBtn addTarget:self action:@selector(configBackGround:) forControlEvents:UIControlEventTouchUpInside];
        
    adjustView = [[UIView alloc]initWithFrame:CGRectMake(20, 30, 280, 300)];
    [adjustView setBackgroundColor:[UIColor clearColor]];
    [adjustView setAlpha:1.0f];
    [adjustView setOpaque:YES];
    
    
    
    UIImage *ptImage = [UIImage imageNamed:@"whitepopover-top.png"]; 
    UIImage *pbImage = [UIImage imageNamed:@"whitepopover-bottom.png"]; 
    UIImage *pmImage = [UIImage imageNamed:@"whitepopover-middle.png"]; 
    UIImage *ptaImage = [UIImage imageNamed:@"whitepopover-top-arrow.png"]; 
//    UIImage *ptacImage = [UIImage imageNamed:@"whitepopover-top-arrow-corner.png"]; 
    
    ptImage = [ptImage stretchableImageWithLeftCapWidth:floorf(ptImage.size.width/2) topCapHeight:ptImage.size.height];
    pbImage = [pbImage stretchableImageWithLeftCapWidth:floorf(pbImage.size.width/2) topCapHeight:pbImage.size.height];
//    pmImage = [pmImage stretchableImageWithLeftCapWidth:floorf(pmImage.size.width/2) topCapHeight:floorf(pmImage.size.height/2)];
//    ptaImage = [ptaImage stretchableImageWithLeftCapWidth:floorf(ptaImage.size.width/2) topCapHeight:floorf(ptaImage.size.height/2)];
//    ptacImage = [ptacImage stretchableImageWithLeftCapWidth:floorf(ptacImage.size.width/2) topCapHeight:floorf(ptacImage.size.height/2)];
    
    
    UIImageView *topIV = [[UIImageView alloc]init];
    [topIV setFrame:CGRectMake(0, 15, 280, 160)];
    [topIV setImage:ptImage];
    [adjustView addSubview:topIV];
    
    UIImageView *botIV = [[UIImageView alloc]init];
    [botIV setFrame:CGRectMake(0, 175, 280, 200)];
    [botIV setImage:pbImage];
    [adjustView addSubview:botIV];
    
    UIImageView *mIV = [[UIImageView alloc]init];
    [mIV setFrame:CGRectMake(95, 30, 69, 1)];
    [mIV setImage:pmImage];
    [adjustView addSubview:mIV];
    
    UIImageView *taIV = [[UIImageView alloc]init];
    [taIV setFrame:CGRectMake(100, 0, 59, 31)];
    [taIV setImage:ptaImage];
    [adjustView addSubview:taIV];

    [adjustView addSubview: fontColorBtn];
    [adjustView addSubview: multiplierBtn];
    [adjustView addSubview: multiplierLessBtn];
    [adjustView addSubview: fontBtn];
    [adjustView addSubview: backgroundBtn];
    
    [self initConfigTableView:nil];
    
    [configsTable setHidden:YES];
    [adjustView addSubview:configsTable];
      
    
    [adjustView setUserInteractionEnabled:YES];
    [adjustView setHidden:YES];
    [self.view addSubview:adjustView];
}

-(void)showDirectory:(id)sender{
    DirectoryViewController *dvc = [[DirectoryViewController alloc]init];
    [dvc setEpubName:bookTitle];
    [dvc setChapters:self.chapters];
    
    [self.navigationController pushViewController:dvc animated:YES];
}

-(void)renderPageNo{
    NSLog(@"repaint page NO.");
//    if (totalPages > 0) {
    [bookNameLabel setText:[NSString stringWithFormat:@"%@ %@ %d/%d [%d]",bookTitle,[(Chapter*)[self.chapters objectAtIndex:chapterPosition]title],currentPageId,[pageArray count] - 1,totalPages]];              
//    }
//    else{
//        [bookNameLabel setText:[NSString stringWithFormat:@"%@ %@ %d/%d [%d]",bookTitle,[(Chapter*)[self.chapters objectAtIndex:chapterPosition]title],currentPageId,[pageArray count] - 1]];      
//    }
    [self page:currentPageId];
    [self checkIsBookMark];
}

-(void)page:(int)aPageId{
    [adjustView setHidden:YES];
    currentPageId = aPageId;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:chapterPosition forKey:[NSString stringWithFormat:@"%@_lastread_chapterId",bookTitle]];
    [prefs setInteger:aPageId forKey:[NSString stringWithFormat:@"%@_lastread_pageId",bookTitle]];
    [prefs synchronize];
    
}

-(void)callNavigationBar{
//    self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    [menuBarView setHidden:!menuBarView.hidden];
    [bookNameLabel setHidden:!bookNameLabel.hidden];
    [adjustView setHidden:YES];    
//    [libraryBtn setHidden:!libraryBtn.hidden];
}



-(void)prevChapter{
    NSLog(@"prev chapter %d",chapterPosition);
    if (chapterPosition > 1) {
        chapterPosition = chapterPosition - 1;    
        
        currentPageId = [[chapterPageArray objectAtIndex:chapterPosition] count] - 1;
        [self showChapterContet:NO];    
    }
}




-(void)nextChapter{    
    //load chapter show progress HUD
    
    NSLog(@"next chapter");
    if (chapterPosition < [self.chapters count]) {
        chapterPosition = chapterPosition + 1;
        currentPageId = 1;
        [self showChapterContet:YES];
    }
}



#pragma mark -
#pragma mark DoMobDelegate methods
- (UIViewController *)domobCurrentRootViewControllerForAd:(DoMobView *)doMobView
{
	return self;
}

- (NSString *)domobPublisherIdForAd:(DoMobView *)doMobView
{
	// 请到www.domob.cn网站注册获取自己的publisher id
	return @"56OJyCAouMDHtZDBW8";
}

// 发布前请取消下面函数的注释

/*
 - (NSString *)domobKeywords
 {
 return @"iPhone,game";
 }*/
/*
 - (NSString *)domobPostalCode
 {
 return @"100032";
 }
 
 - (NSString *)domobDateOfBirth
 {
 return @"20101211";
 }
 
 - (NSString *)domobGender
 {
 return @"male";
 }
 
 - (double)domobLocationLongitude
 {
 return 391.0;
 }
 
 - (double)domobLocationLatitude
 {
 return -200.1;
 }
 */
- (NSString *)domobSpot:(DoMobView *)doMobView;
{
	return @"all";
}
// Sent when an ad request loaded an ad; 
// it only send once per DoMobView
- (void)domobDidReceiveAdRequest:(DoMobView *)doMobView
{
	self.domobView.frame = CGRectMake(0, self.view.frame.size.height - self.domobView.frame.size.height, self.domobView.frame.size.width, self.domobView.frame.size.height);
	[self.view addSubview:self.domobView];
}

- (void)domobDidFailToReceiveAdRequest:(DoMobView *)doMobView
{
}
/*
 - (UIColor *)adBackgroundColorForAd:(DoMobView *)doMobView
 {
 return [UIColor blackColor];
 }*/

- (void)domobWillPresentFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view will Full Screen");
}

- (void)domobDidPresentFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view did Full Screen");
}

- (void)domobWillDismissFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view will Dismiss Full Screen");
}

- (void)domobDidDismissFullScreenModalFromAd:(DoMobView *)doMobView
{
	NSLog(@"The view did Dismiss Full Screen");
}

-(void)dealloc{
    self.domobView.doMobDelegate = nil;
	self.domobView = nil;
    
    [super dealloc];
}



@end