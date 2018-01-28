//
//  StartViewController.m
//  Black and White
//
//  Created by cj on 16/6/30.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import "StartViewController.h"

@interface StartViewController ()

@end

@implementation StartViewController
{
    // array of the option number of trials per block
    NSArray *genderArray;
    NSString *maxRound;
    NSString *pgender;
    NSString *genderselected;
    NSString *docsDir;
    NSArray *dirPath;
    NSString *propertypath;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // Do any additional setup after loading the view, typically from a nib.
    
    _SaveButton.hidden = NO;
    _ResetButton.hidden = NO;
    _StartButton.hidden = YES;
    
    //set default gender
    
    genderselected = @"1";
    
    genderArray = @[@"Male", @"Female"];
    
    // Get the dirctory
    dirPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPath[0];
    
    //setup path for config file
    propertypath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"configure.plist"]];
    //Check file exist
    NSFileManager *configfilemgr = [NSFileManager defaultManager];
    // if not configure file not create
    if([configfilemgr fileExistsAtPath:propertypath]==NO){
        NSMutableDictionary *configDict = [[NSMutableDictionary alloc] init];
        [configDict setObject:@"3" forKey:@"time_limit"];
        [configDict setObject:@"4" forKey:@"number_of_rounds"];
        [configDict setObject:@"1" forKey:@"number_of_practice"];
        [configDict setObject:@"8" forKey:@"number_of_test"];
        [configDict setObject:@"Dans ce test, tu vas entendre un nom de couleur (noir ou blanc). Ensuite, tu devras appuyer sur le bouton de la même couleur ou sur le bouton d’une couleur différente selon les consignes." forKey:@"Main_Instruction"];
        
        [configDict setObject:@"Pour chaque essai, tu vas entendre un nom de couleur et tu dois appuyer sur le bouton de la MÊME couleur. Appuie sur « c’est parti » quand tu es prêt." forKey:@"Congruent_Instruction"];
        
        [configDict setObject:@"Pour chaque essai, tu vas entendre un nom de couleur et tu dois appuyer sur le bouton de l’AUTRE couleur. Appuie sur « c’est parti » quand tu es prêt." forKey:@"Incongruent_Instruction"];
        [configDict writeToFile:propertypath atomically:YES];
    }
        //Build the path for keep database
        _databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"blackwhite.db"]];
        
        NSFileManager *filemgr = [NSFileManager defaultManager];
        
        //Check file exist
        if([filemgr fileExistsAtPath:_databasePath]==NO){
            const char *dbpath= [_databasePath UTF8String];
            
            if(sqlite3_open(dbpath, &_BWDB) == SQLITE_OK){
                char * errorMessage;
                const char *sql_statement1= "CREATE TABLE IF NOT EXISTS participantdata (ID INTEGER PRIMARY KEY AUTOINCREMENT, PID TEXT, GENDER TEXT, AGE TEXT);";
                //fail to exec sql command
                if(sqlite3_exec(_BWDB, sql_statement1, NULL, NULL, &errorMessage)!=SQLITE_OK){
                    [self showUIAlerWithMessage:@"Failed to create the table" andTitle:@"Error"];
                }
                const char *sql_statement2= "CREATE TABLE IF NOT EXISTS resultdata (ID INTEGER PRIMARY KEY AUTOINCREMENT, date TEXT, PID TEXT, GENDER TEXT, AGE TEXT, question TEXT, blackposition TEXT, whiteposition TEXT, congruent TEXT, correct TEXT, response TEXT, reaction TEXT);";
                //fail to exec sql command
                if(sqlite3_exec(_BWDB, sql_statement2, NULL, NULL, &errorMessage)!=SQLITE_OK){
                    [self showUIAlerWithMessage:@"Failed to create the table" andTitle:@"Error"];
                }
                //close database
                sqlite3_close(_BWDB);
            }
            else{
                [self showUIAlerWithMessage:@"Failed to open/create the table" andTitle:@"Error"];
            }
            
        }

}
    
- (void) showUIAlerWithMessage:(NSString*)message andTitle:(NSString*)title{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
-(BOOL) textFieldShouldReturn:(UITextField *)textField {
        [textField resignFirstResponder];
        return YES;
    }

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)GenderSegment:(id)sender {
    //set participant gender value
    if (_GenderSegment.selectedSegmentIndex == 0 ) {
        genderselected = @"1"; //gender segment pick male record as 1
        
    } else if (_GenderSegment.selectedSegmentIndex == 1 ) {
        genderselected= @"0"; //gender segment pick female record as 0
        
    }
}

- (IBAction)ResetButton:(id)sender {
    //clear text fields
    _pIDtext.text = @"";
    _pAgetext.text = @"";
    _GenderSegment.selectedSegmentIndex = 0;
}

- (IBAction)SaveButton:(id)sender {
    NSString *age;
    //insert participant data to table
    if (![_pIDtext.text isEqual: @""]) {
        if ([_pAgetext.text isEqual: @""]) {
            age = @"999";
        } else {
            age = _pAgetext.text;
        }
        
        sqlite3_stmt *statment;
        const char * dbpath = [_databasePath UTF8String];
        
        if(sqlite3_open(dbpath, &_BWDB)==SQLITE_OK){
            
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO participantdata (pid, gender, age) VALUES (\"%@\", \"%@\", \"%@\")", _pIDtext.text, genderselected, age];
            const char *insert_statment =[insertSQL UTF8String];
            sqlite3_prepare_v2(_BWDB, insert_statment, -1, &statment, NULL);
            
            if(sqlite3_step(statment)==SQLITE_DONE){
                //[self showUIAlerWithMessage:@"Paticipant add to the Database" andTitle:@"Message"];
                //Display start button and hidden all other buttons
                _StartButton.hidden = NO;
                _SaveButton.hidden = YES;
                _ResetButton.hidden = YES;
                //disable text fields and change colour to gray
                _pIDtext.enabled = NO;
                _pAgetext.enabled = NO;
                _GenderSegment.enabled = NO;
                _pIDtext.backgroundColor = [UIColor grayColor];
                _pAgetext.backgroundColor = [UIColor grayColor];
            }
            
            else{
                [self showUIAlerWithMessage:@"Fail to create paticipant" andTitle:@"Error"];
                
            }
            sqlite3_finalize(statment);
            sqlite3_close(_BWDB);
        }// end of insert data
        
    } else {
        [self showUIAlerWithMessage:@"Please Enter Paticipant ID !" andTitle:@"Error"];
        
    }
    
    
}

@end
