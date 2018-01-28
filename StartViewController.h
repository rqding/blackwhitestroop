//
//  StartViewController.h
//  Black and White
//
//  Created by cj on 16/6/30.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface StartViewController : UIViewController <UITextViewDelegate, UIAlertViewDelegate>


@property (strong, nonatomic)NSString *databasePath;

@property (nonatomic) sqlite3 *BWDB;

@property (strong, nonatomic) IBOutlet UITextField *pIDtext;

@property (strong, nonatomic) IBOutlet UITextField *pAgetext;

@property (strong, nonatomic) IBOutlet UISegmentedControl *GenderSegment;

@property (strong, nonatomic) IBOutlet UIButton *ResetButton;

@property (strong, nonatomic) IBOutlet UIButton *StartButton;

@property (strong, nonatomic) IBOutlet UIButton *SaveButton;

- (IBAction)GenderSegment:(id)sender;

- (IBAction)ResetButton:(id)sender;

- (IBAction)SaveButton:(id)sender;

@end
