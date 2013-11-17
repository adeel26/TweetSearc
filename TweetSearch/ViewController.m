//
//  ViewController.m
//  TweetSearch
//
//  Created by Malik Adeel
//  Copyright (c) 2013 Malik Adeel. All rights reserved.
//

#import "ViewController.h"
#import "SearchResult.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


}

// TextField Delegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

 [self performSegueWithIdentifier:@"SearchResulView" sender:textField];

    [textField resignFirstResponder];


    return YES;

}


// Passing Data using segue to SearchResults

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {


    self.textField = sender;

    SearchResult *nav = [segue destinationViewController];

    nav.searchTerm= self.textField.text ;


}





@end
