//
//  ConfigureViewController.m
//  Black and White
//
//  Created by cj on 16/8/18.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import "ConfigureViewController.h"

@interface ConfigureViewController ()

@end

@implementation ConfigureViewController
{
    NSString *docsDir;
    NSArray *dirPath;
    NSString *numofpractice;
    NSString *numoftest;
    NSString *numofrounds;//default is 2 rounds, one congruent, one incongruent
    NSString *timelimit;
    NSString *mainintro;
    NSString *conintro;
    NSString *inconintro;
    NSString *propertypath;
    NSMutableDictionary *readDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _MainInstructionText.backgroundColor = [UIColor whiteColor];
    _CongInstructionText.backgroundColor =[UIColor whiteColor];
    _IncongInstructionText.backgroundColor = [UIColor whiteColor];
    
    // Get the dirctory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPath[0];
    
    //Build the path for keep database
    _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"blackwhite.db"]];
    
    //setup path for config file
    propertypath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"configure.plist"]];
    
    //read currect configure setup
    readDict = [NSMutableDictionary dictionaryWithContentsOfFile:propertypath];
    numofpractice = [readDict objectForKey:@"number_of_practice"];
    numoftest = [readDict objectForKey:@"number_of_test"];
    numofrounds = [readDict objectForKey:@"number_of_rounds"];
    timelimit = [readDict objectForKey:@"time_limit"];
    mainintro = [readDict objectForKey:@"Main_Instruction"];
    conintro = [readDict objectForKey:@"Congruent_Instruction"];
    inconintro = [readDict objectForKey:@"Incongruent_Instruction"];
    
    if (![mainintro isEqual:@""]) {
        _MainInstructionText.text = mainintro;
    } else {
        _MainInstructionText.text = @"Please enter the test instruction !";
    }
    
    if (![conintro isEqual:@""]) {
        _CongInstructionText.text = conintro;
    } else {
        _CongInstructionText.text = @"Please enter the test instruction !";
    }
    if (![inconintro isEqual:@""]) {
        _IncongInstructionText.text = inconintro;
    } else {
        _IncongInstructionText.text = @"Please enter the test instruction !";
    }
    
    if (![numoftest isEqual:@""]) {
        _NumTestText.text = numoftest;
    } else {
        _NumTestText.text = @"1";
    }
    if (![numofpractice isEqual:@""]) {
        _NumPracticeText.text = numofpractice;
    } else {
        _NumPracticeText.text = @"1";
    }
    
    if ([timelimit isEqual:@"n"]) {
        _TimeLimitSegment.selectedSegmentIndex = 3;
    } else if ([timelimit isEqual: @"3"]){
        _TimeLimitSegment.selectedSegmentIndex = 2;
    } else if ([timelimit isEqual: @"2"]) {
        _TimeLimitSegment.selectedSegmentIndex = 1;
    } else {
        _TimeLimitSegment.selectedSegmentIndex = 0;
    }
    
    
    if ([numofrounds isEqual:@"8"]) {
        _NumroundsSegment.selectedSegmentIndex = 3;
    } else if ([numofrounds isEqual: @"6"]){
        _NumroundsSegment.selectedSegmentIndex = 2;
    } else if ([numofrounds isEqual: @"4"]) {
        _NumroundsSegment.selectedSegmentIndex = 1;
    } else {
        _NumroundsSegment.selectedSegmentIndex = 0;
    }
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showUIAlerWithMessage:(NSString*)message andTitle:(NSString*)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)SaveAllTextButton:(id)sender {
    
    NSString *inputIntro;
    if (![_MainInstructionText isEqual:@""]) {
        inputIntro = _MainInstructionText.text;
    } else  {
        [self showUIAlerWithMessage:@"Please input test instruction" andTitle:@"Error"];
    }
    [readDict setValue:inputIntro forKey:@"Main_Instruction"];
    [readDict writeToFile:propertypath atomically:YES];
    _MainInstructionText.backgroundColor = [UIColor lightGrayColor];
    
    if (![_CongInstructionText isEqual:@""]) {
        inputIntro = _CongInstructionText.text;
    } else  {
        [self showUIAlerWithMessage:@"Please input Congruent instruction" andTitle:@"Error"];
    }
    [readDict setValue:inputIntro forKey:@"Congruent_Instruction"];
    [readDict writeToFile:propertypath atomically:YES];
    _CongInstructionText.backgroundColor = [UIColor lightGrayColor];
    
    if (![_IncongInstructionText isEqual:@""]) {
        inputIntro = _IncongInstructionText.text;
    } else  {
        [self showUIAlerWithMessage:@"Please input Incongruent instruction" andTitle:@"Error"];
    }
    [readDict setValue:inputIntro forKey:@"Incongruent_Instruction"];
    [readDict writeToFile:propertypath atomically:YES];
    _IncongInstructionText.backgroundColor = [UIColor lightGrayColor];

    if (![_NumPracticeText isEqual:@""]) {
        inputIntro = _NumPracticeText.text;
    } else  {
        [self showUIAlerWithMessage:@"Please input number of practice" andTitle:@"Error"];
    }
    [readDict setValue:inputIntro forKey:@"number_of_practice"];
    [readDict writeToFile:propertypath atomically:YES];
    _NumPracticeText.backgroundColor = [UIColor lightGrayColor];

    if (![_NumTestText isEqual:@""]) {
        inputIntro = _NumTestText.text;
    } else  {
        [self showUIAlerWithMessage:@"Please input number of test" andTitle:@"Error"];
    }
    [readDict setValue:inputIntro forKey:@"number_of_test"];
    [readDict writeToFile:propertypath atomically:YES];
    _NumTestText.backgroundColor = [UIColor lightGrayColor];
    
}


- (IBAction)DelTestDataButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to DELETE ALL test data ?"
                                                    message:@"Press YES to Delete. Or Press Cancel."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"YES", nil];
    alert.tag = 100;
    [alert show];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag ==100) {
        if (buttonIndex ==1)
            [self delalltestdata];
    }
}

-(void)delalltestdata {
    sqlite3_stmt *statment;
    const char * dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_BWDB)==SQLITE_OK){
        
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM resultdata"];
        
        const char *del_statment =[deleteSQL UTF8String];
        sqlite3_prepare_v2(_BWDB, del_statment, -1, &statment, NULL);
        
        if(sqlite3_step(statment)==SQLITE_DONE){
            [self showUIAlerWithMessage:@"All Test Data Deleted" andTitle:@"Message"];
        } else {
            
            [self showUIAlerWithMessage:@"Fail to delete test data table" andTitle:@"Error"];
            
        }
        sqlite3_finalize(statment);
        sqlite3_close(_BWDB);
        
    }
}

- (IBAction)BackBarButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)TimeLimitSegment:(id)sender {
    NSString *timeSelected;
    if (_TimeLimitSegment.selectedSegmentIndex == 3 ) {
        timeSelected = @"n";
    } else  if (_TimeLimitSegment.selectedSegmentIndex ==2){
        timeSelected = @"3";
    } else if (_TimeLimitSegment.selectedSegmentIndex ==1){
        timeSelected = @"2";
    } else {
        timeSelected = @"1";
    }
    
    [readDict setValue:timeSelected forKey:@"time_limit"];
    [readDict writeToFile:propertypath atomically:YES];
    
}

- (IBAction)NumroundsSegment:(id)sender {
    NSString *numroundsSelected;
    
    if (_NumroundsSegment.selectedSegmentIndex == 3 ) {
        numroundsSelected = @"8";
    } else if (_NumroundsSegment.selectedSegmentIndex == 2) {
        numroundsSelected = @"6";
    } else if (_NumroundsSegment.selectedSegmentIndex == 1) {
        numroundsSelected = @"4";
    } else {
        numroundsSelected = @"2";
    }
    [readDict setValue:numroundsSelected forKey:@"number_of_rounds"];
    [readDict writeToFile:propertypath atomically:YES];
}

@end
