//
//  DirectoryViewController.m
//  arab
//
//  Created by 伟 马 on 11/17/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "DirectoryViewController.h"
#import "Chapter.h"
#import "CoreTextMagazineViewController.h"
#import "EPub.h"
#import "Bookmark.h"
#import "DataBase.h"

@implementation DirectoryViewController
@synthesize epubName;
@synthesize chapters;
@synthesize bookmarks;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


-(void)updateState:(id)sender{
    NSLog(@"segemented select index is %d",[sender selectedSegmentIndex]);
    
    currentState = [sender selectedSegmentIndex];
    
    self.bookmarks = [[NSMutableArray alloc]init];
    
    DataBase *db = [[DataBase alloc]init];
    [db openDB];
    self.bookmarks = [db getBookmarks:epubName];
    [db closeDB];
    
    [self.tableView reloadData];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    UISegmentedControl *stateSegmented = [[UISegmentedControl alloc]initWithFrame:CGRectMake(0, 0, 120, 30)];
    [stateSegmented insertSegmentWithTitle:@"目录" atIndex:0 animated:YES];
    [stateSegmented insertSegmentWithTitle:@"书签" atIndex:1 animated:YES];    
    
    [stateSegmented setSelectedSegmentIndex:0];

    [stateSegmented addTarget:self action:@selector(updateState:) forControlEvents:UIControlEventValueChanged];
    UIBarButtonItem *stateBtn = [[UIBarButtonItem alloc]initWithCustomView:stateSegmented];
    
    [self.navigationItem setRightBarButtonItem:stateBtn];
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    
    if (currentState == 0) {
        return [self.chapters count];        
    }else{
        return [self.bookmarks count];        
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [cell.textLabel setNumberOfLines:0];
    [cell.textLabel setFont:[UIFont fontWithName:@"STHeitiJ-Light" size:14]];
    
    if (currentState == 0) {
        [cell.textLabel setText:[(Chapter *)[self.chapters objectAtIndex:indexPath.row] title]];        
    }else{
        [cell.textLabel setText:
         [NSString stringWithFormat:@"%@- %@",
         [[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"bookmark"] substringWithRange:NSMakeRange(0, 20)],[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"created_datetime"]]];
         
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
 
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    if (currentState == 0) {
        [prefs setInteger:indexPath.row forKey:[NSString stringWithFormat:@"%@_lastread_chapterId",epubName]];
        [prefs setInteger:1 forKey:[NSString stringWithFormat:@"%@_lastread_pageId",epubName]];
        [prefs synchronize];
        [self.navigationController popViewControllerAnimated:YES];        
    }else{
        //back to bookmark position.
        NSLog(@"%d,%d",[[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"chapter_id"]intValue],[[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"page_id"]intValue]);
        [prefs setInteger:[[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"chapter_id"]intValue] forKey:[NSString stringWithFormat:@"%@_lastread_chapterId",epubName]];
        [prefs setInteger:[[[self.bookmarks objectAtIndex:indexPath.row] objectForKey:@"page_id"]intValue] forKey:[NSString stringWithFormat:@"%@_lastread_pageId",epubName]];
        [prefs synchronize];
        [self.navigationController popViewControllerAnimated:YES];        
    }

}

@end
