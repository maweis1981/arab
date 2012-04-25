//
//  PageController.m
//  CoreTextWrapper
//
//  Created by Adrian on 7/8/10.
//  Copyright 2010 akosma software. All rights reserved.
//

#import "PageController.h"
#import "AKOMultiPageTextView.h"
#import "AKOCustomFontLabel.h"
#import "NSString+BundleExtensions.h"
#import "UIFont+CoreTextExtensions.h"

@interface PageController ()

@property (nonatomic) CGFloat previousScale;
@property (nonatomic) CGFloat fontSize;

@end


@implementation PageController

@synthesize text;

@synthesize multiPageView = _multiPageView;
@synthesize label = _label;
@synthesize previousScale = _previousScale;
@synthesize fontSize = _fontSize;

- (void)dealloc 
{
    self.label = nil;
    self.multiPageView = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    self.navigationController.navigationBarHidden = YES;
 
    NSLog(@"page controller view did load.");
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.label.text = @"EPub";
    self.label.font = [UIFont bundledFontNamed:@"Polsku" size:18.0];
    self.label.shadowColor = [UIColor lightGrayColor];
    self.label.shadowOffset = CGSizeMake(2, 2);
    
    self.fontSize = 16.0;
    
    self.multiPageView.dataSource = self;
//    self.multiPageView.columnInset = CGPointMake(50, 30);
    
    self.multiPageView.text = self.text;
    self.multiPageView.font = [UIFont fontWithName:@"Georgia" size:self.fontSize];
    self.multiPageView.columnCount = UIInterfaceOrientationIsPortrait(self.interfaceOrientation) ? 1 : 2;
    
//    UIPinchGestureRecognizer *pinchRecognizer = [[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(changeTextSize:)] autorelease];
//    [self.multiPageView addGestureRecognizer:pinchRecognizer];
    
}

-(void)btnClicked:(id)sender{
    UIAlertView *a = [[UIAlertView alloc]initWithTitle:@"---" message:@"===" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [a show];
}

- (UIView*)akoMultiColumnTextView:(AKOMultiColumnTextView*)textView viewForColumn:(NSInteger)column onPage:(NSInteger)page
{
    if (page == 1 && column == 1)
    {
//        UIView *view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 200)] autorelease];
//        view.backgroundColor = [UIColor redColor];
//        return view;
        
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(0,0, 381, 238)];
        [btn setImage:[UIImage imageNamed:@"t.png"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
         return btn;
    
    }
    
    return nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return NO;
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        self.multiPageView.columnCount = 1;
    }
    else
    {
        self.multiPageView.columnCount = 2;
    }
    [self.multiPageView setNeedsDisplay];
    [self.label setNeedsDisplay];
}

#pragma mark -
#pragma mark Gesture recognizer methods

- (void)changeTextSize:(UIPinchGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.previousScale = recognizer.scale;
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        if (recognizer.scale > self.previousScale)
        {
            if (self.fontSize < 48.0)
            {
                self.fontSize += 0.25;
            }
        }
        else 
        {
            if (self.fontSize > 12.0)
            {
                self.fontSize -= 0.25;
            }
        }
        
        self.multiPageView.font = [UIFont fontWithName:@"Georgia" size:self.fontSize];
        self.previousScale = recognizer.scale;
    }
}

@end

