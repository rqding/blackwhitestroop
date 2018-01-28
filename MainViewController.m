//
//  MainViewController.m
//  Black and White
//
//  Created by cj on 16/6/30.
//  Copyright © 2016年 Carleton University Math Lab. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    //test intro from property file
    NSString *cong_intro;
    NSString *incong_intro;
    NSString *startTestLabel;
    
    //property file setup related
    NSArray *paths;
    NSString *docsPath;
    NSString *propertypath;
    
    // counter for one loop
    NSInteger loopcount;
    NSInteger roundcount;
    NSInteger blinkcount;
    NSInteger practicecount;
    //pre defined trial list
    NSMutableArray *questionlist;
    NSMutableArray *blackpositionlist;
    NSMutableArray *congruentlist;
    
    NSMutableArray *practicequestionlist;
    NSMutableArray *practiceblackpositionlist;
    //record time related
    double timelimit; //comment out to set as no timelimit
    NSTimeInterval starttime;
    NSTimeInterval endtime;
    NSString *reactiontime;
    //get data from property table
    NSString *currentdate;
    NSString *pID;
    NSString *gender;
    NSString *age;
    NSInteger numofpractice; //number of practice trial of each round
    NSInteger trialperRound; //number of trial for each round
    NSInteger numofround; //number of rounds
    BOOL pause; // the game will only continous if pause is NO
    BOOL practiceOrTest; // if practice is YES, if Test is NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _CorrectLabel.hidden = YES;
    _CorrectFaceImage.hidden = YES;
    _WrongLabel.hidden = YES;
    _WrongFaceImage.hidden = YES;
    _blackButton.hidden = YES;
    _whiteButton.hidden = YES;
    _fixpoint.hidden = YES;
    _StartOverButton.hidden = YES;
    _finishTestButton.hidden = YES;
    _NextButton.hidden = YES;
    _textIntro.hidden = YES;
    _startTestButton.hidden = YES;
    _StartButton.hidden = YES;
     _PauseBarButton.enabled = NO;
    loopcount = 0;
    roundcount = 0;
    practicecount = 0;
    practiceOrTest = YES;
    pause = NO;
    //get current date
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    currentdate = [dateFormatter stringFromDate:now];
    
    //setup path for property file
    //get paticipant info from paticipant table and number of practice
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsPath = [paths objectAtIndex:0];
    
    
    propertypath = [[NSString alloc] initWithString:[docsPath stringByAppendingPathComponent:@"configure.plist"]];
    NSMutableDictionary *readDict = [NSMutableDictionary dictionaryWithContentsOfFile:propertypath];
    //get data from property file
    cong_intro = [readDict objectForKey:@"Congruent_Instruction"];
    incong_intro = [readDict objectForKey:@"Incongruent_Instruction"];
    trialperRound = [[readDict objectForKey:@"number_of_test"] integerValue];
    numofpractice = [[readDict objectForKey:@"number_of_practice"] integerValue];
    numofround =  [[readDict objectForKey:@"number_of_rounds"] integerValue];
    timelimit = [[readDict objectForKey:@"time_limit"] doubleValue];
    
    //get paticipant data from property database
    _databasePath = [docsPath stringByAppendingPathComponent:@"blackwhite.db"];
    
    sqlite3_stmt *statment;
    const char *dbpath = [_databasePath UTF8String];
    
    //read from paticipant database
    if(sqlite3_open(dbpath, &_BWDB)==SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM participantdata WHERE ID = (SELECT MAX(ID) FROM participantdata)"];
        
        const char *sql_statment =[querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_BWDB, sql_statment, -1, &statment, NULL) == SQLITE_OK){
            while(sqlite3_step(statment) == SQLITE_ROW){
                
                pID = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 1)];
                gender = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 2)];
                age = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 3)];
                
            }// end of while
            sqlite3_finalize(statment);
            sqlite3_close(_BWDB);
            
        }  else{
            
            [self showUIAlerWithMessage:@"Fail to get data from participant table" andTitle:@"Error"];
        }
    } //end of if
    
    //set congrouent round or incongruent round control list
    congruentlist = [[NSMutableArray alloc] init];
    for (int i=0; i<numofround; i++)
        if (i%2 == 0)
        {congruentlist[i] = @"1";}
        else
        {congruentlist[i] = @"0";}
    
    //start test ! show ready button
    [self practiceOrTest];
    
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

- (void) showUIAlerWithMessage:(NSString*)message andTitle:(NSString*)title{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)practiceOrTest {
    if (practiceOrTest == YES) {
        [self generatepracticelist];
        [self practiceloop];
    } else {
        [self clearlabel];
        _StartButton.hidden = NO;
    }
}

- (IBAction)StartButton:(id)sender {
    _StartButton.hidden = YES;
        [self generatelist];
        [self testloop];
}

- (IBAction)PressStartOverButton:(id)sender {
    //exit app
    exit(0);
}

- (void) testloop{
    if(loopcount < trialperRound && roundcount < numofround)
    {
        //start test loop
        [self showfixpoint];
    }
    
    else if(loopcount >= trialperRound && roundcount < (numofround-1)) {
        //start another round
        roundcount++;
        loopcount =0;
        practicecount = 0;
        practiceOrTest = YES;
        [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(practiceOrTest) userInfo:nil repeats:NO];
    }
    
    else if(roundcount >= (numofround-1)) {
        //finish all rounds
        _startTestButton.hidden=YES; [self stoptest];
    }
}

- (void) practiceloop{
    //using count to track loop
    [self clearlabel];
    //congruent condition
    if (practicecount >0 && practicecount <numofpractice) {
        [self showfixpoint];
    } else if (practicecount>=numofpractice){
        [self practiceOrTest];
    } else if (practicecount ==0 && [congruentlist[roundcount] isEqual:@"1"]) {
        _textIntro.text= cong_intro;
        _textIntro.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(showstartbutton) userInfo:nil repeats:NO];
    } else if (practicecount ==0 && [congruentlist[roundcount] isEqual:@"0"]) {
            _textIntro.text= incong_intro;
            _textIntro.hidden = NO;
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(showstartbutton) userInfo:nil repeats:NO];
    }
}

-(void)showstartbutton {
    _startTestButton.hidden = NO;
    _PauseBarButton.enabled = YES;
}
- (IBAction)startTestButton:(id)sender {
    //start test or practice
    _startTestButton.hidden = YES;
    _textIntro.hidden =YES;
    _PauseBarButton.enabled = NO;
    [self showfixpoint];
}
-(void)shownextbutton {
    _NextButton.hidden = NO;
    _PauseBarButton.enabled = YES;
}
- (IBAction)NextButton:(id)sender {
    _NextButton.hidden = YES;
    _PauseBarButton.enabled = NO;
    [self testloop];
}

- (void) showfixpoint{
    if (pause == NO) {
        blinkcount = 0;
        _fixpoint.hidden = NO;
        [NSTimer scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(togglefixation:) userInfo:nil repeats:YES];
    }
}
-(void)togglefixation:(NSTimer *)sender {
    [_fixpoint setHidden:(!_fixpoint.hidden)];
    blinkcount++;
    if (blinkcount >=3) {
        [sender invalidate];
        [self hiddenfixpoint];
    }
}

- (void) hiddenfixpoint{
    _fixpoint.hidden = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(playaudio) userInfo:nil repeats:NO];
}

-(void) playaudio {
    if (practiceOrTest == YES){
        if ([practicequestionlist[practicecount] isEqualToString:@"1"] ) {
            [self playblack];
        }
        else{
            [self playwhite];
        }
    } else {
        if ([questionlist[loopcount] isEqualToString:@"1"] ) {
            [self playblack];
        }
        else{
            [self playwhite];
        }
    }
}

- (void) playblack{
    CFBundleRef mainBundle=CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"Black", CFSTR("m4a"), NULL);
    UInt32 soundID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    AudioServicesPlaySystemSound(soundID);
    [NSThread sleepForTimeInterval:0.7f];
    if (practiceOrTest == YES) {
        [self showbuttons:practicequestionlist[practicecount] andString2:practiceblackpositionlist[practicecount]];

    } else {
        [self showbuttons:questionlist[loopcount] andString2:blackpositionlist[loopcount]];
    }
}

- (void) playwhite{
    CFBundleRef mainBundle=CFBundleGetMainBundle();
    CFURLRef soundFileURLRef;
    soundFileURLRef = CFBundleCopyResourceURL(mainBundle, (CFStringRef) @"White", CFSTR("m4a"), NULL);
    UInt32 soundID;
    AudioServicesCreateSystemSoundID(soundFileURLRef, &soundID);
    AudioServicesPlaySystemSound(soundID);
    [NSThread sleepForTimeInterval:0.7f];
    if (practiceOrTest == YES) {
        [self showbuttons:practicequestionlist[practicecount] andString2:practiceblackpositionlist[practicecount]];
        
    } else {
        [self showbuttons:questionlist[loopcount] andString2:blackpositionlist[loopcount]];
    }
}

- (void) showbuttons:(NSString*)answercolor andString2:(NSString*)answerposition {
    if (pause == NO) {
        //start timeer when button show
        starttime = [[NSDate date] timeIntervalSinceReferenceDate];
        
        if (answercolor == answerposition){
            //if the correct answer is equal to the position number black is on the right
            CGRect rightframe = _blackButton.frame;
            rightframe.origin.x = 645;
            rightframe.origin.y = 313;
            _blackButton.frame = rightframe;
            CGRect leftframe = _whiteButton.frame;
            leftframe.origin.x = 265;
            leftframe.origin.y = 313;
            _whiteButton.frame = leftframe;
            _blackButton.hidden = NO;
            _whiteButton.hidden = NO;
            if (practiceOrTest == YES) {
               [self performSelector:@selector(responsefeedback:) withObject:@"999" afterDelay:timelimit];
            } else {
              [self performSelector:@selector(insertData:) withObject:@"999" afterDelay:timelimit];
            }
        }
        else{
            //black is on the left
            CGRect rightframe = _whiteButton.frame;
            rightframe.origin.x = 645;
            rightframe.origin.y = 313;
            _whiteButton.frame = rightframe;
            CGRect leftframe = _blackButton.frame;
            leftframe.origin.x = 265;
            leftframe.origin.y = 313;
            _blackButton.frame = leftframe;
            _blackButton.hidden = NO;
            _whiteButton.hidden = NO;
            if (practiceOrTest == YES) {
                [self performSelector:@selector(responsefeedback:) withObject:@"999" afterDelay:timelimit];
            } else {
                [self performSelector:@selector(insertData:) withObject:@"999" afterDelay:timelimit];
            }
        }
    }
}

- (IBAction)blackButton:(id)sender {
    //end timer after button click and hidden
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    endtime = [[NSDate date] timeIntervalSinceReferenceDate];
    NSString *response = @"1";
    double rt = endtime-starttime;
    reactiontime = [NSString stringWithFormat:@"%f", rt];
    if (practiceOrTest == YES) {
        [self responsefeedback:response];
    }else {
        [self insertData:response];
    }
}

- (IBAction)whiteButton:(id)sender {
    //end timer after button click and hidden
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    endtime = [[NSDate date] timeIntervalSinceReferenceDate];
    NSString *response = @"0";
    double rt = endtime-starttime;
    reactiontime = [NSString stringWithFormat:@"%f", rt];
    if (practiceOrTest == YES) {
        [self responsefeedback:response];
    }else {
        [self insertData:response];
    }
}

- (void) stoptest {
    _finishTestButton.hidden = NO;
}

- (IBAction)finishTestButton:(id)sender {
    // Get the dirctory
    
    NSString *csv = @"index,date,id,gender,age,Qcolor,blackposition,whiteposition,congruent,correct,response, RT\n";
    
    NSString *testfile = [docsPath stringByAppendingPathComponent:@"blackwhite.csv"];
    NSError *error;
    
    sqlite3_stmt *statment;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_BWDB)==SQLITE_OK){
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM resultdata"];
        
        const char *sql_statment =[querySQL UTF8String];
        
        if(sqlite3_prepare_v2(_BWDB, sql_statment, -1, &statment, NULL) == SQLITE_OK){
            while(sqlite3_step(statment) == SQLITE_ROW){
                
                NSInteger dataid = sqlite3_column_int(statment, 0);
                NSString *testdate = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 1)];
                NSString *pid = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 2)];
                NSString *Pgender = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 3)];
                NSString *Page = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 4)];
                NSString *question = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 5)];
                NSString *blackposition = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 6)];
                NSString *whiteposition = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 7)];
                NSString *conguent = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 8)];
                NSString *correct = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 9)];
                NSString *response = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 10)];
                NSString *reaction = [NSString stringWithUTF8String:(char *)sqlite3_column_text(statment, 11)];
                
                csv = [csv stringByAppendingFormat:@"%ld,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@\n", (long)dataid, testdate, pid, Pgender, Page,question, blackposition, whiteposition, conguent, correct, response, reaction];
                
            }// end of while
            sqlite3_finalize(statment);
            sqlite3_close(_BWDB);
            [self showUIAlerWithMessage:@"Create and Save csv file" andTitle:@"Message"];
            
            BOOL ok = [csv writeToFile:testfile atomically:NO encoding:NSUTF8StringEncoding error:&error];
            
            if (!ok) {
                // an error occurred
                NSLog(@"Error writing file the error is %@\n", error);
            }
            _finishTestButton.hidden = YES;
            _StartOverButton.hidden = NO;
        }
        
        else{
            
            [self showUIAlerWithMessage:@"Fail to get data from database" andTitle:@"Error"];
            
        }
        
    }//end of if
}

- (IBAction)PaueBarButton:(id)sender {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    pause = YES;
    [self pausepractice];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to quit now ?"
                                                    message:@"Press YES to quit. Press cancel to go back."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"YES", nil];
    alert.tag = 100;
    [alert show];
}

//if press yes call stop test function
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag ==100) {
        if (buttonIndex ==1)
           _finishTestButton.hidden = NO;
        if(buttonIndex ==0) {
            pause = NO;
            if(practiceOrTest == NO)
                [self testloop];
            else [self practiceloop];
        }
        
    }
}

-(void)pausepractice {
    //hidden all components
    _blackButton.hidden = YES;
    _whiteButton.hidden = YES;
    _fixpoint.hidden = YES;
    _startTestButton.hidden= YES;
    _StartOverButton.hidden = YES;
    _StartButton.hidden = YES;
    _NextButton.hidden = YES;
    _textIntro.hidden = YES;
}

-(void)insertData:(NSString*)response {
    [self clearbutton];
    NSString *correct;
    NSString *whiteposition;
    if ([response isEqual: @"999"]) {
        correct=@"0";
        reactiontime = @"999";
    } else if ([congruentlist[roundcount] isEqual:@"1"]){
        if ([questionlist[loopcount] isEqual:response])
        { correct = @"1";}
        else if (![questionlist[loopcount] isEqual:response])
        {correct=@"0";}
    }
    else if ([congruentlist[roundcount] isEqual:@"0"]) {
        if ([questionlist[loopcount] isEqual:response])
        {correct =@"0";}
        else if (![questionlist[loopcount] isEqual:response])
        {correct = @"1";}
    }
    if ([blackpositionlist[loopcount] isEqual:@"1"]) {whiteposition = @"0";}
    else {whiteposition =@"1";}
    
    sqlite3_stmt *statment;
    const char *dbpath = [_databasePath UTF8String];
    
    if(sqlite3_open(dbpath, &_BWDB)==SQLITE_OK){
        NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO resultdata (date, pid, gender, age, question, blackposition, whiteposition, congruent, correct, response, reaction) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\", \"%@\",\"%@\", \"%@\")", currentdate, pID, gender,age,questionlist[loopcount], blackpositionlist[loopcount], whiteposition, congruentlist[roundcount], correct, response, reactiontime];
        const char *insert_statment =[insertSQL UTF8String];
        sqlite3_prepare_v2(_BWDB, insert_statment, -1, &statment, NULL);
        
        if(sqlite3_step(statment)==SQLITE_DONE){
            loopcount++;
            [self shownextbutton];
        } else {
            [self showUIAlerWithMessage:@"Fail to insert row" andTitle:@"Error"];
        }
        sqlite3_finalize(statment);
        sqlite3_close(_BWDB);
    }
}

-(void)responsefeedback:(NSString *)response {
    [self clearbutton];
    //congruent trial
    if ([congruentlist[roundcount] isEqual:@"1"]){
        if ([practicequestionlist[practicecount] isEqual:response])
        {
            _CorrectLabel.hidden = NO;
            _CorrectFaceImage.hidden = NO;
            practicecount++;
            if (practicecount >= numofpractice) {
                practiceOrTest = NO;
            }
            [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(practiceloop) userInfo:nil repeats:NO];
        }
        else if (![practicequestionlist[practicecount] isEqual:response])
        {
            _WrongLabel.hidden = NO;
            _WrongFaceImage.hidden = NO;
            [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(practiceloop) userInfo:nil repeats:NO];
        }
    }
    //incongruent trial
    else if ([congruentlist[roundcount] isEqual:@"0"]) {
        if ([practicequestionlist[practicecount] isEqual:response] || [response isEqual:@"999"])
        {
            _WrongLabel.hidden = NO;
            _WrongFaceImage.hidden = NO;
            [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(practiceloop) userInfo:nil repeats:NO];
        }
        else if (![practicequestionlist[practicecount] isEqual:response])
        {
            _CorrectLabel.hidden = NO;
            _CorrectFaceImage.hidden = NO;
            practicecount++;
            if (practicecount >= numofpractice) {
                practiceOrTest = NO;
            }
            [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(practiceloop) userInfo:nil repeats:NO];
        }
    }
    
}

-(void)generatelist {
    //setup random list
    //create a array from with 1 or 0
    questionlist = [[NSMutableArray alloc] init];
    blackpositionlist = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i <trialperRound; i++)
    {
        if( i%2 == 0) {[questionlist addObject:@"0"]; [blackpositionlist addObject:@"1"];}
        else {[questionlist addObject:@"1"]; [blackpositionlist addObject:@"0"];}
    }
    
    NSUInteger count = trialperRound;
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [questionlist exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    for (NSUInteger i = 0; i < count; ++i) {
        // Select a random element between i and end of array to swap with.
        NSUInteger nElements = count - i;
        NSUInteger n = (arc4random() % nElements) + i;
        [blackpositionlist exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
}

-(void)generatepracticelist {
    //create a array from with 1 or 0 for practice
    practicequestionlist = [[NSMutableArray alloc] init];
    practiceblackpositionlist = [[NSMutableArray alloc] init];
    for (NSUInteger i = 0; i <numofpractice; i++)
    {
        if( i%2 == 0) {[practicequestionlist addObject:@"0"]; [practiceblackpositionlist addObject:@"1"];}
        else {[practicequestionlist addObject:@"1"]; [practiceblackpositionlist addObject:@"0"];}
    }
}

-(void)clearbutton {
    _blackButton.hidden = YES;
    _whiteButton.hidden = YES;
}

-(void)clearlabel {
    _WrongLabel.hidden = YES;
    _WrongFaceImage.hidden = YES;
    _CorrectLabel.hidden = YES;
    _CorrectFaceImage.hidden = YES;
}

@end
