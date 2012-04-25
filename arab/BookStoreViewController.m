//
//  BookStoreViewController.m
//  arab
//
//  Created by Peter Ma on 3/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "BookStoreViewController.h"


@implementation BookStoreViewController
@synthesize hud,httpRequest;
@synthesize bookArray;

-(void)requestFailed:(ASIHTTPRequest *)request{
    NSLog(@"request failed.");
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
}

-(void)requestFinished:(ASIHTTPRequest *)request{
    if ([request responseStatusCode] == 200 ) {
        NSString *response = [request responseString];
        NSLog(@"%@",response);
        NSDictionary *objs = [response objectFromJSONString];
        NSLog(@"%@",objs);
        
        for (NSDictionary *tempObj in [objs objectForKey:@"data"]) {
            [self.bookArray addObject:tempObj];
        }
        [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
        [self.tableView reloadData];
        
    }
    
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:NO];
}


-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    NSLog(@"Response Header is %@",responseHeaders);
}

-(void) hudWasHidden:(MBProgressHUD *)aHud{
    [hud removeFromSuperview];
    [hud release];
}


-(void)loadBookList:(id)sender{
    
    NSString *book_list_url = [NSString stringWithString:@"http://epubspider.com/books/list"];
    [httpRequest cancel];
    [self setHttpRequest:[ASIHTTPRequest requestWithURL:[NSURL URLWithString:book_list_url]]];
    [httpRequest setTimeOutSeconds:30];
    [httpRequest setDelegate:self];
    [[UIApplication sharedApplication]setNetworkActivityIndicatorVisible:YES];
    [httpRequest startSynchronous];
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)applicationDocumentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    basePath = [basePath stringByAppendingPathComponent:@"epub_files"];
    return basePath;
}


- (void)viewDidLoad
{
    
    self.bookArray = [[NSMutableArray alloc]init];
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    [hud setDelegate:self];
    [hud setLabelText:@"loading"];
    
    [hud showWhileExecuting:@selector(loadBookList:) onTarget:self withObject:nil animated:YES];
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
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
    return [self.bookArray count];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    BookCell *cell = (BookCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.selectionStyle = UITableViewCellEditingStyleNone;
    if (cell == nil) {
        NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"BookCell" owner:self options:nil];
		cell = [array objectAtIndex:0];
		[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    [[cell titleLabel] setText:[[self.bookArray objectAtIndex:indexPath.row]objectForKey:@"title"]];
    
    [[cell descriptionLabel] setText:[[self.bookArray objectAtIndex:indexPath.row]objectForKey:@"description"]];
    
    [[cell coverView] loadImageFromURLStr:[[self.bookArray objectAtIndex:indexPath.row] objectForKey:@"cover"]];
    
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
 
    BookEntryViewController *detailViewController = [[BookEntryViewController alloc] initWithNibName:@"BookEntryViewController" bundle:nil];

    [detailViewController setBookData:[self.bookArray objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
}

@end
