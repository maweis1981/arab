//
//  SimpleCTView.m
//  arab
//
//  Created by 伟 马 on 11/16/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SimpleCTView.h"


@implementation SimpleCTView

@synthesize text;


+(CGFloat)heightForAttributedString:(NSAttributedString *)attrString forWidth:(CGFloat)inWidth { 
    CGFloat H = 0;
    // Create the framesetter with the attributed string.
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) attrString); 
    
    CGRect box = CGRectMake(0,0, inWidth, CGFLOAT_MAX);
    
    CFIndex startIndex = 0;
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    
    // Create a frame for this column and draw it.
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
    
    // Start the next frame at the first character not visible in this frame.
    //CFRange frameRange = CTFrameGetVisibleStringRange(frame);
    //startIndex += frameRange.length;
    
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex j = 0, lineCount = CFArrayGetCount(lineArray);
    CGFloat h, ascent, descent, leading;
    
    for (j=0; j < lineCount; j++)
    {
        CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
        CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);
        h = ascent + descent + leading;
        NSLog(@"%f", h);
        H+=h;
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    return H;
}

- (void)calculateHeight {
    CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
    CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)self.text);
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	
	CFRange fitRange = CFRangeMake(0,0);
	CGSize aSize = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, CFRangeMake(0, CFStringGetLength((CFStringRef)attrString)), NULL, CGSizeMake(self.frame.size.width,CGFLOAT_MAX), &fitRange);
    NSLog(@"Page Size is %f  %f",aSize.height,aSize.width);
    CFRelease(attrString);
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setText:(NSString *)aText
{
	if (text != aText) {
		text = [aText retain];
	}
	
    NSLog(@"%@",text);
	[self setNeedsDisplay];
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	
	CTParagraphStyleSetting setting[10];
	CGFloat floatValue[10];
	
	floatValue[0] = 0.0; // Deprecated (see header file)
	floatValue[1] = 0.0;
	floatValue[2] = 0.0;
	floatValue[3] = 0.0;
	floatValue[4] = 0.0; // Line spacing (必要に応じて行間調整)
	floatValue[5] = floatValue[4]; // Same as kCTParagraphStyleSpecifierMinimumLineSpacing
	
	setting[0].spec = kCTParagraphStyleSpecifierLineSpacing; // Deprecated (see header file)
	setting[0].valueSize = sizeof(CGFloat);
	setting[0].value = &floatValue[0];
	
	setting[1].spec = kCTParagraphStyleSpecifierParagraphSpacing;
	setting[1].valueSize = sizeof(CGFloat);
	setting[1].value = &floatValue[1];
	
	setting[2].spec = kCTParagraphStyleSpecifierMaximumLineHeight;
	setting[2].valueSize = sizeof(CGFloat);
	setting[2].value = &floatValue[2];
	
	setting[3].spec = kCTParagraphStyleSpecifierMinimumLineHeight;
	setting[3].valueSize = sizeof(CGFloat);
	setting[3].value = &floatValue[3];
	
	setting[4].spec = kCTParagraphStyleSpecifierMinimumLineSpacing;
	setting[4].valueSize = sizeof(CGFloat);
	setting[4].value = &floatValue[4];
	
	setting[5].spec = kCTParagraphStyleSpecifierMaximumLineSpacing;
	setting[5].valueSize = sizeof(CGFloat);
	setting[5].value = &floatValue[5];
	
	CTParagraphStyleRef para = CTParagraphStyleCreate(setting, 6);
	
	NSMutableDictionary* attr = [NSMutableDictionary dictionaryWithCapacity:5];
	
	CTFontRef font = CTFontCreateWithName(CFSTR("Helvetica"), 14.0f, NULL);
	[attr setObject:(id)font forKey:(id)kCTFontAttributeName];
	//
	[attr setObject:(id)para forKey:(id)kCTParagraphStyleAttributeName];
	//
	CFRelease(font);
	CFRelease(para);
    
	CFAttributedStringRef attrString = CFAttributedStringCreate(NULL, (CFStringRef)self.text, (CFDictionaryRef)attr);
    
	CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString(attrString);
	
	CGPathRef framePath = [[UIBezierPath bezierPathWithRect:self.bounds] CGPath];
	CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, CFAttributedStringGetLength(attrString)), framePath, NULL);
	
	CGContextRef context = UIGraphicsGetCurrentContext();	
	
	CGContextTranslateCTM(context, 0, self.bounds.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	
	CGContextSaveGState(context);
	CTFrameDraw(frame, context);
	CGContextRestoreGState(context);
	
	CGContextSetTextMatrix(context, CGAffineTransformIdentity);
	CGContextSetTextPosition(context, 0, 0);
    
#if 0
	// Draw line bounds
	NSArray* lines = (id)CTFrameGetLines(frame);
	NSUInteger lineIndex = 0;
	for (id obj in lines) {
		CTLineRef line = (CTLineRef)obj;
		[[UIColor blueColor] setStroke];
		
		
		CGContextSaveGState(context);
		CGPoint p;
		CTFrameGetLineOrigins(frame, CFRangeMake(lineIndex, 1), &p);
		CGContextTranslateCTM(context, p.x, p.y);
		CGRect lineBounds = CTLineGetImageBounds(line, context);
		//CGContextStrokeRect(context, lineBounds);
		float ascent = 0;
		float descent = 0;
		float leading = 0;
		float size = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
		
		CGContextTranslateCTM(context, lineBounds.origin.x, lineBounds.origin.y);
		
		NSLog(@"line: %@ - %@, a:%f, d:%f, l:%f, w:%f", CFStringCreateWithSubstring(NULL, self.text, CTLineGetStringRange(line)), NSStringFromCGRect(CTLineGetImageBounds(line, context)),
			  ascent, descent, leading, size);
		
		
		CGContextMoveToPoint(context, 0, 0);
         CGContextAddLineToPoint(context, size, 0);
         [[UIColor blackColor] setStroke];
         CGContextStrokePath(context);
         
		
		 // これ正しくないので注意
         CGContextMoveToPoint(context, 0, ascent);
         CGContextAddLineToPoint(context, size, ascent);
         [[UIColor redColor] setStroke];
         CGContextStrokePath(context);
         
         CGContextMoveToPoint(context, 0, descent);
         CGContextAddLineToPoint(context, size, descent);
         [[UIColor greenColor] setStroke];
         CGContextStrokePath(context);
         
         CGContextMoveToPoint(context, 0, -leading);
         CGContextAddLineToPoint(context, size, -leading);
         [[UIColor yellowColor] setStroke];
         CGContextStrokePath(context);
		  
		
		CGContextRestoreGState(context);
        
		CGContextSaveGState(context);
		CGContextTranslateCTM(context, p.x, p.y);
		NSArray* runs = (id)CTLineGetGlyphRuns(line);
		for (id obj in runs) {
			CTRunRef run = obj;
			NSLog(@"\t+run:%@, %@, %@", CFStringCreateWithSubstring(NULL, self.text, CTRunGetStringRange(run)), NSStringFromCGRect(CTRunGetImageBounds(run, context, CFRangeMake(0, 0))),
				  NSStringFromCGAffineTransform(CTRunGetTextMatrix(run)) );
			[[UIColor blueColor] setStroke];
			CGContextStrokeRect(context, CTRunGetImageBounds(run, context, CFRangeMake(0, 0)) );
		}
		CGContextRestoreGState(context);
		
		lineIndex ++;
	}
	
#endif
	
	CFRelease(frame);
	CFRelease(framesetter);
	CFRelease(attrString);
}


@end
