//
//  SearchResult.h
//  TweetSearch
//
//  Created by Malik Adeel
//  Copyright (c) 2013 Malik Adeel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface SearchResult : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, copy) NSString *searchTerm;

@end
