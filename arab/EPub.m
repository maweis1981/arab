//
//  EPub.m
//  AePubReader
//
//  Created by Federico Frappi on 05/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "EPub.h"
#import "ZipArchive.h"
#import "Chapter.h"

@interface EPub()

- (void) parseEpub;
- (void) unzipAndSaveFileNamed:(NSString*)fileName;
- (NSString*) applicationDocumentsDirectory;
- (NSString*) parseManifestFile;
- (void) parseOPF:(NSString*)opfPath;

@end

@implementation EPub

@synthesize spineArray;

- (id) initWithEPubPath:(NSString *)path{
	if((self=[super init])){
		epubFilePath = path;
		spineArray = [[NSMutableArray alloc] init];        
        [self parseEpub];
	}
	return self;
}

- (void) parseEpub{
	[self unzipAndSaveFileNamed:epubFilePath];
	NSString* opfPath = [self parseManifestFile];
    if (opfPath != nil) {
        [self parseOPF:opfPath];        
    }else{
        [[NSFileManager defaultManager]removeItemAtPath:epubFilePath error:nil];
        NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],[[epubFilePath lastPathComponent]stringByDeletingPathExtension]];
        NSLog(@"%@", strPath);
        [[NSFileManager defaultManager]removeItemAtPath:strPath error:nil];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error Book" delegate:self cancelButtonTitle:@"YES" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)unzipAndSaveFileNamed:(NSString*)fileName{
	ZipArchive* za = [[ZipArchive alloc] init];
	NSLog(@"%@", fileName);
	NSLog(@"unzipping %@", epubFilePath);
    
    //check the files exist.
    //Delete all the previous files
    NSString *strPath=[NSString stringWithFormat:@"%@/UnzippedEpub/%@",[self applicationDocumentsDirectory],[[epubFilePath lastPathComponent]stringByDeletingPathExtension]];
    NSLog(@"%@", strPath);
    
    NSFileManager *filemanager=[[NSFileManager alloc] init];
    if ([filemanager fileExistsAtPath:strPath]) {
        //			NSError *error;
        //			[filemanager removeItemAtPath:strPath error:&error];
        [filemanager release];
        filemanager=nil;
        NSLog(@"file exist, do not need unzip.");
        return;
    }
        
	[filemanager release];
	filemanager=nil;

	if( [za UnzipOpenFile:epubFilePath]){        
       		//start unzip
		BOOL ret = [za UnzipFileTo:[NSString stringWithFormat:@"%@/",strPath] overWrite:YES];
		if( NO==ret ){
			// error handler here
			UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"Error"
														  message:@"Error while unzipping the epub"
														 delegate:self
												cancelButtonTitle:@"OK"
												otherButtonTitles:nil];
			[alert show];
			[alert release];
			alert=nil;
		}
		[za UnzipCloseFile];
	}					
	[za release];
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

- (NSString*) parseManifestFile{
	NSString* manifestFilePath = [NSString stringWithFormat:@"%@/UnzippedEpub/%@/META-INF/container.xml", [self applicationDocumentsDirectory],[[epubFilePath lastPathComponent]stringByDeletingPathExtension]];
//	NSLog(@"%@", manifestFilePath);
	NSFileManager *fileManager = [[NSFileManager alloc] init];
	if ([fileManager fileExistsAtPath:manifestFilePath]) {
		//		NSLog(@"Valid epub");
		CXMLDocument* manifestFile = [[[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:manifestFilePath] options:0 error:nil] autorelease];
		CXMLNode* opfPath = [manifestFile nodeForXPath:@"//@full-path[1]" error:nil];
//		NSLog(@"%@", [NSString stringWithFormat:@"%@/UnzippedEpub/%@", [self applicationDocumentsDirectory], [opfPath stringValue]]);
		return [NSString stringWithFormat:@"%@/UnzippedEpub/%@/%@", [self applicationDocumentsDirectory],[[epubFilePath lastPathComponent]stringByDeletingPathExtension],[opfPath stringValue]];
	} else {
		NSLog(@"ERROR: ePub not Valid");
        //@TODO need to remove the epub and show a alert window to tell the epub books is error.        
		return nil;
	}
	[fileManager release];
}

- (void) parseOPF:(NSString*)opfPath{
    
    int lastSlash = [opfPath rangeOfString:@"/" options:NSBackwardsSearch].location;
	NSString* ebookBasePath = [opfPath substringToIndex:(lastSlash +1)];
    
    NSString *opfFileContent = [[NSString alloc]initWithContentsOfFile:opfPath encoding:NSUTF8StringEncoding error:nil];
    opfFileContent = [opfFileContent stringByReplacingOccurrencesOfString:@" mlns=" withString:@" xmlns="];
    [opfFileContent writeToFile:opfPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    //update the file fixed the mlns error.
    
	CXMLDocument* opfFile = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:opfPath] options:0 error:nil];
    NSError *error;
    
	NSArray* itemsArray = [opfFile nodesForXPath:@"//opf:item" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:&error];

    NSString* ncxFileName;
	
    NSMutableDictionary* itemDictionary = [[NSMutableDictionary alloc] init];
	for (CXMLElement* element in itemsArray) {
		[itemDictionary setValue:[[element attributeForName:@"href"] stringValue] forKey:[[element attributeForName:@"id"] stringValue]];
        if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"application/x-dtbncx+xml"]){
            ncxFileName = [[element attributeForName:@"href"] stringValue];

        }else if([[[element attributeForName:@"media-type"] stringValue] isEqualToString:@"image/jpeg"]){
            NSString *coverIdName = [[element attributeForName:@"id"] stringValue];
            NSString *coverImgName = [[element attributeForName:@"href"] stringValue];
            if ([[coverImgName lowercaseString] rangeOfString:@"cover"].location != NSNotFound || 
                [[coverIdName lowercaseString] rangeOfString:@"cover"].location != NSNotFound) {
                //The string has been found
                coverImgName = [NSString stringWithFormat:@"%@%@", ebookBasePath, coverImgName];
                NSString *newCoverPath = [NSString stringWithFormat:@"%@/UnzippedEpub/%@/cover.jpg",[self applicationDocumentsDirectory],[[epubFilePath lastPathComponent]stringByDeletingPathExtension]];
                NSError *error;
                [[NSFileManager defaultManager] copyItemAtPath:coverImgName toPath:newCoverPath error:&error];
            }
        }
	}
	
    CXMLDocument* ncxToc = [[CXMLDocument alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@%@", ebookBasePath, ncxFileName]] options:0 error:nil];
    NSMutableDictionary* titleDictionary = [[NSMutableDictionary alloc] init];
    for (CXMLElement* element in itemsArray) {
        NSString* href = [[element attributeForName:@"href"] stringValue];
        NSString* xpath = [NSString stringWithFormat:@"//ncx:content[@src='%@']/../ncx:navLabel/ncx:text", href];
        NSArray* navPoints = [ncxToc nodesForXPath:xpath namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.daisy.org/z3986/2005/ncx/" forKey:@"ncx"] error:nil];
        if([navPoints count]!=0){
            CXMLElement* titleElement = [navPoints objectAtIndex:0];
           [titleDictionary setValue:[titleElement stringValue] forKey:href];
        }
    }

	
	NSArray* itemRefsArray = [opfFile nodesForXPath:@"//opf:itemref" namespaceMappings:[NSDictionary dictionaryWithObject:@"http://www.idpf.org/2007/opf" forKey:@"opf"] error:nil];
//	NSLog(@"itemRefsArray size: %d", [itemRefsArray count]);
	NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
    int count = 0;
	for (CXMLElement* element in itemRefsArray) {
        NSString* chapHref = [itemDictionary valueForKey:[[element attributeForName:@"idref"] stringValue]];

        Chapter* tmpChapter = [[Chapter alloc] initWithPath:[NSString stringWithFormat:@"%@%@", ebookBasePath, chapHref]
                                                       title:[titleDictionary valueForKey:chapHref] 
                                                chapterIndex:count++];
        if (![[tmpChapter title] isEqualToString:@""] && [tmpChapter title] != nil) {
            [tmpArray addObject:tmpChapter];            
            [tmpChapter release];
        }else{
            NSLog(@"Trim empty Chapter Title.... maybe image, we dont support now.");
        }
	}
	
	self.spineArray = [NSArray arrayWithArray:tmpArray]; 
	
//    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.spineArray];
//    [prefs setObject:data forKey:[NSString stringWithFormat:@"%@_spins",[[epubFilePath lastPathComponent]stringByDeletingPathExtension]]];
//    
    
	[opfFile release];
	[tmpArray release];
	[ncxToc release];
	[itemDictionary release];
	[titleDictionary release];
}

- (void)dealloc {
    [spineArray release];
	[epubFilePath release];
    [super dealloc];
}

@end
