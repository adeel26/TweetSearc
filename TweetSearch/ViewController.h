//
//  ViewController.h
//  TweetSearch
//
//  Created by Malik Adeel 
//  Copyright (c) 2013 Malik Adeel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property(nonatomic, copy) NSString *searchTerm;

@end
