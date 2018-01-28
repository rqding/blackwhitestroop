//
//  ConfigureViewController.h
//  Black and White
//
//  Created by cj on 16/8/18.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>


@interface ConfigureViewController : UIViewController <UIAlertViewDelegate>

@property (strong, nonatomic)NSString *databasePath;

@property (nonatomic) sqlite3 *BWDB;

@property (strong, nonatomic) IBOutlet UITextView *MainInstructionText;

@property (strong, nonatomic) IBOutlet UITextView *CongInstructionText;

@property (strong, nonatomic) IBOutlet UITextView *IncongInstructionText;

@property (strong, nonatomic) IBOutlet UITextField *NumPracticeText;

@property (strong, nonatomic) IBOutlet UITextField *NumTestText;

@property (strong, nonatomic) IBOutlet UISegmentedControl *NumroundsSegment;

@property (strong, nonatomic) IBOutlet UISegmentedControl *TimeLimitSegment;

- (IBAction)NumroundsSegment:(id)sender;

- (IBAction)TimeLimitSegment:(id)sender;

- (IBAction)DelTestDataButton:(id)sender;

- (IBAction)BackBarButton:(id)sender;

- (IBAction)SaveAllTextButton:(id)sender;


@end
