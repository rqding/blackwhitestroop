//
//  MainViewController.h
//  Black and White
//
//  Created by cj on 16/6/30.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sqlite3.h>

@interface MainViewController : UIViewController <UIAlertViewDelegate>

@property (nonatomic) sqlite3 *BWDB;

@property (strong, nonatomic)NSString *databasePath;

@property (strong, nonatomic) IBOutlet UITextView *textIntro;

@property (strong, nonatomic)IBOutlet UIButton *blackButton;

@property (strong, nonatomic)IBOutlet UIButton *whiteButton;

@property (strong, nonatomic)IBOutlet UIButton *startTestButton;

@property (strong, nonatomic) IBOutlet UILabel *fixpoint;

@property (strong, nonatomic) IBOutlet UIButton *finishTestButton;

@property (strong, nonatomic) IBOutlet UIButton *StartOverButton;

@property (strong, nonatomic) IBOutlet UIImageView *CorrectFaceImage;

@property (strong, nonatomic) IBOutlet UILabel *CorrectLabel;

@property (strong, nonatomic) IBOutlet UIImageView *WrongFaceImage;

@property (strong, nonatomic) IBOutlet UILabel *WrongLabel;
@property (strong, nonatomic) IBOutlet UIButton *NextButton;
@property (strong, nonatomic) IBOutlet UIButton *StartButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *PauseBarButton;

- (IBAction)blackButton:(id)sender;

- (IBAction)whiteButton:(id)sender;

- (IBAction)startTestButton:(id)sender;

- (IBAction)finishTestButton:(id)sender;

- (IBAction)PaueBarButton:(id)sender;

- (IBAction)NextButton:(id)sender;

- (IBAction)StartButton:(id)sender;

- (IBAction)PressStartOverButton:(id)sender;

@end
