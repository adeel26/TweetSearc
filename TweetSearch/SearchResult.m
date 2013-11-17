//
//  SearchResult.m
//  TweetSearch
//
//  Created by Malik Adeel
//  Copyright (c) 2013 Malik Adeel. All rights reserved.
//

#import "SearchResult.h"
#import "ViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

typedef NS_ENUM(NSUInteger, UYLTwitterSearchState)
{
    UYLTwitterSearchStateLoading,
    UYLTwitterSearchStateNotFound,
    UYLTwitterSearchStateRefused,
    UYLTwitterSearchStateFailed
};

@interface SearchResult ()


@property (nonatomic,strong) ACAccountStore *accStore;
@property (nonatomic,strong) NSMutableArray *SearchResults;
@property (nonatomic,assign) UYLTwitterSearchState SearchState;
@property (nonatomic,strong) NSMutableData *jsonData;
@property (nonatomic,strong) NSURLConnection *connect;
@end

@implementation SearchResult

@synthesize searchTerm, SearchState, accStore ,SearchResults, jsonData, connect;

- (ACAccountStore *)accountStore
{
    if (accStore == nil)
    {
        accStore = [[ACAccountStore alloc] init];
    }
    return accStore;
}

- (NSString *)searchMessageForState:(UYLTwitterSearchState)state
{
    switch (state)
    {
        case UYLTwitterSearchStateLoading:
            return @"Loading...";
            break;
        case UYLTwitterSearchStateNotFound:
            return @"No results found";
            break;
        case UYLTwitterSearchStateRefused:
            return @"Twitter Access Refused";
            break;
        default:
            return @"Not Available";
            break;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = searchTerm;
    [self loadQuery];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
   [self cancelConnection];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma DataSource Methods

// TableViews method Returning Rows

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger count = [SearchResults count];
    return count > 0 ? count : 1;
}
//  Creating Cells Loading Data
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ResultCellIdentifier = @"Cell1";
    static NSString *LoadCellIdentifier = @"Cell2";
    NSUInteger count = [SearchResults count];
    if ((count == 0) && (indexPath.row == 0))
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:LoadCellIdentifier];
        cell.textLabel.text = [self searchMessageForState:self.SearchState];
        return cell;
    }

    else {

    UITableViewCell *cell= [tableView dequeueReusableCellWithIdentifier:ResultCellIdentifier];
    NSDictionary *tweet = (SearchResults)[indexPath.row];
    cell.textLabel.text = tweet[@"text"];
    return cell;

    }

}
#define RESULTS_PERPAGE @"20"

- (void)loadQuery
{
    self.searchState = UYLTwitterSearchStateLoading;
    NSString *encodedQuery = [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
             NSDictionary *parameters = @{@"count" : RESULTS_PERPAGE,
                                          @"q" : encodedQuery};

             SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:url
                                                          parameters:parameters];
             NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
             slRequest.account = [accounts lastObject];
             NSURLRequest *request = [slRequest preparedURLRequest];
             dispatch_async(dispatch_get_main_queue(), ^{
                 connect = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
             });
         }
         else
         {
             self.searchState = UYLTwitterSearchStateRefused;
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self.tableView reloadData];
             });
         }
     }];
}



- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    jsonData = [NSMutableData data];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

    [jsonData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    connect = nil;

    NSError *error = nil;
    NSDictionary *jsonResults = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];


   SearchResults = jsonResults[@"statuses"];
    if ([SearchResults count] == 0)
    {
        NSArray *errors = jsonResults[@"errors"];
        if ([errors count])
        {
            self.searchState = UYLTwitterSearchStateFailed;
        }
        else
        {
            self.searchState = UYLTwitterSearchStateNotFound;
        }
    }

    jsonData = nil;
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
    [self.tableView flashScrollIndicators];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    connect = nil;
   jsonData = nil;
    [self.refreshControl endRefreshing];
    self.searchState = UYLTwitterSearchStateFailed;

    [self handleError:error];
    [self.tableView reloadData];
}

- (void)handleError:(NSError *)error
{
    NSString *errMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Connection"
                                                        message:errMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"Close"
                                              otherButtonTitles:nil];
    [alertView show];
}

- (void)cancelConnection
{
    if (connect != nil)
    {
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        [connect cancel];
        connect = nil;
        jsonData = nil;
    }
}

@end

