//
//  ViewController.m
//  BackgroundFetchDemo
//
//  Created by Gabriel Theodoropoulos on 22/2/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "ViewController.h"
#import "XMLParser.h"
#define NewsFeed @"http://feeds.reuters.com/reuters/technologyNews"

@interface ViewController ()

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@property (nonatomic, strong) NSArray *arrNewsData;

@property (nonatomic, strong) NSString *dataFilePath;

- (void)refreshData;

- (void)performNewFetchedDataActionsWithDataArray:(NSArray *)dataArray;

@end

@implementation ViewController

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrNewsData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"idCellNewsTitle"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"idCellNewsTitle"];
    }
    
    NSDictionary *dict = [self.arrNewsData objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dict objectForKey:@"title"];
    cell.detailTextLabel.text = [dict objectForKey:@"pubDate"];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dict = [self.arrNewsData objectAtIndex:indexPath.row];
    
    NSString *newsLink = [dict objectForKey:@"link"];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:newsLink]];
}


- (void)refreshData
{
    XMLParser *xmlParser = [[XMLParser alloc] initWithXMLURLString:NewsFeed];
    [xmlParser startParsingWithCompletionHandler:^(BOOL success, NSArray *dataArray, NSError *error) {
        if (success) {
            [self performNewFetchedDataActionsWithDataArray:dataArray];
            
            [self.refreshControl endRefreshing];
        } else {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

- (void)performNewFetchedDataActionsWithDataArray:(NSArray *)dataArray
{
    // 1. Initialize the arrNewsData array with the parsed data array.
    if (self.arrNewsData != nil) {
        self.arrNewsData = nil;
    }
    self.arrNewsData = [[NSArray alloc] initWithArray:dataArray];
    
    // 2. Reload the table view.
    [self.tblNews reloadData];
    
    // 3. Save the data permanently to file.
    if (![self.arrNewsData writeToFile:self.dataFilePath atomically:YES]) {
        NSLog(@"Counldn't save data.");
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // 1. Make self the delegate and datasource of the table view.
    [self.tblNews setDelegate:self];
    [self.tblNews setDataSource:self];
    
    // 2. Specify the data storage file path.
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];
    self.dataFilePath = [docDirectory stringByAppendingPathComponent:@"newsdata"];
    
    // 3. Initialize the refresh control.
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self
                            action:@selector(refreshData)
                  forControlEvents:UIControlEventValueChanged];
    [self.tblNews addSubview:self.refreshControl];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
